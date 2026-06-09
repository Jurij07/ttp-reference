--!strict
-- CultivationService.lua
-- Das Herz des Spiels: verwaltet Realm/Stage/EXP, Meditation (passives Farmen),
-- Realm-Breakthroughs, abgeleitete Combat-Stats und die Lifespan-Alterung.
-- Spielerwerte werden als Attribute auf dem Player gespeichert und
-- replizieren dadurch automatisch zum Client (HUD).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)
local ProvidenceService = require(script.Parent.ProvidenceService)

local CultivationService = {}

local notifyEvent = Net.Event("Notify")

local LIFESPAN_INF_SENTINEL = 1e15 -- Attribut-sicherer Ersatz für "unendlich"

-- Schreibt die "leichten" Fortschritts-Attribute (ändern sich oft).
local function updateProgressAttributes(player: Player, profile: any)
	local realm = CultivationData.GetRealm(profile.realm)
	player:SetAttribute("Realm", profile.realm)
	player:SetAttribute("RealmName", realm and realm.name or "?")
	player:SetAttribute("Tier", realm and realm.tier or "?")
	player:SetAttribute("Stage", profile.stage)
	player:SetAttribute("MaxStage", CultivationData.GetMaxStage(profile.realm))
	player:SetAttribute("EXP", profile.exp)
	player:SetAttribute("EXPNeeded", CultivationData.GetStageEXP(profile.realm, profile.stage))
	player:SetAttribute("SpiritStones", profile.spiritStones)
	player:SetAttribute("Karma", profile.karma)
	player:SetAttribute("TotalKills", profile.totalKills)
end

-- Berechnet MaxHP/Damage/Defense + Lifespan neu (nach Realm/Stage/Providence)
-- und heilt den Spieler voll. Bei Breakthroughs aufrufen.
function CultivationService.RecomputeStats(player: Player)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end

	local baseHP, baseDmg, baseDef = CultivationData.GetCombatStats(profile.realm, profile.stage)
	local m = ProvidenceService.GetMultipliers(player)

	local maxHP = math.floor(baseHP * m.hp)
	player:SetAttribute("MaxHP", maxHP)
	player:SetAttribute("HP", maxHP) -- voll heilen
	player:SetAttribute("Damage", math.floor(baseDmg * m.dmg))
	player:SetAttribute("Defense", math.floor(baseDef * m.def))

	-- Lifespan
	local maxLife = CultivationData.GetLifespan(profile.realm)
	local infinite = maxLife == math.huge
	player:SetAttribute("LifespanInfinite", infinite)
	if infinite then
		maxLife = LIFESPAN_INF_SENTINEL
		profile.lifespanUsed = 0
	end
	player:SetAttribute("MaxLifespan", maxLife)
	player:SetAttribute("Lifespan", math.max(maxLife - profile.lifespanUsed, 0))

	updateProgressAttributes(player, profile)
end

-- Richtet einen Spieler beim Join ein.
local function initPlayer(player: Player)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end
	-- Providence sicherstellen, BEVOR die Stats berechnet werden.
	ProvidenceService.EnsureRolled(player, profile)
	player:SetAttribute("Meditating", false)
	CultivationService.RecomputeStats(player)
end

-- Fügt EXP hinzu (baseAmount wird mit dem Providence-EXP-Multiplikator skaliert)
-- und behandelt Stage-Ups sowie Realm-Breakthroughs.
function CultivationService.AddEXP(player: Player, baseAmount: number)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end

	local mult = ProvidenceService.GetMultipliers(player).exp
	profile.exp += baseAmount * mult

	local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	while profile.exp >= needed do
		local maxStage = CultivationData.GetMaxStage(profile.realm)
		if profile.stage < maxStage then
			profile.exp -= needed
			profile.stage += 1
		elseif profile.realm < #CultivationData.REALMS then
			-- Breakthrough in den nächsten Realm
			profile.exp -= needed
			profile.realm += 1
			profile.stage = 1
			local realm = CultivationData.GetRealm(profile.realm)
			notifyEvent:FireClient(player, ("⚡ BREAKTHROUGH! %s erreicht!"):format(realm and realm.name or "?"), "gold")
			CultivationService.RecomputeStats(player)
		else
			-- Maximaler Realm — EXP deckeln
			profile.exp = needed
			break
		end
		needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	end

	updateProgressAttributes(player, profile)
end

-- Vergibt Spirit Stones.
function CultivationService.AddStones(player: Player, amount: number)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end
	profile.spiritStones += amount
	player:SetAttribute("SpiritStones", profile.spiritStones)
end

function CultivationService.AddKill(player: Player)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end
	profile.totalKills += 1
	player:SetAttribute("TotalKills", profile.totalKills)
end

-- Meditation an/aus schalten.
local function setMeditating(player: Player, on: boolean)
	player:SetAttribute("Meditating", on)
end

function CultivationService.Start()
	-- Spieler beim Laden ihres Profils einrichten.
	DataManager.ProfileLoaded:Connect(initPlayer)

	-- Meditate-Toggle vom Client.
	local meditateEvent = Net.Event("ToggleMeditate")
	meditateEvent.OnServerEvent:Connect(function(player, on)
		setMeditating(player, on == true)
	end)

	-- Haupt-Loop: Meditation (EXP) + Lifespan-Alterung.
	RunService.Heartbeat:Connect(function(dt)
		for _, player in ipairs(Players:GetPlayers()) do
			local profile = DataManager.Get(player)
			if not profile then
				continue
			end

			-- Meditation
			if player:GetAttribute("Meditating") then
				local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
				CultivationService.AddEXP(player, needed * Config.MEDITATION_FRACTION_PER_SEC * dt)
			end

			-- Lifespan-Alterung
			if Config.LIFESPAN_ENABLED and not player:GetAttribute("LifespanInfinite") then
				profile.lifespanUsed += Config.LIFESPAN_DECAY_PER_SEC * dt
				local maxLife = player:GetAttribute("MaxLifespan") or 0
				local remaining = math.max(maxLife - profile.lifespanUsed, 0)
				player:SetAttribute("Lifespan", remaining)
				if remaining <= 0 then
					-- Tod durch Alter: neues Leben, sanfte Strafe (EXP der Stage verloren).
					profile.lifespanUsed = 0
					profile.exp = 0
					notifyEvent:FireClient(player, "☠️ Deine Lebensspanne ist erschöpft — ein neues Leben beginnt.", "warn")
					CultivationService.RecomputeStats(player)
				end
			end
		end
	end)
end

return CultivationService
