--!strict
-- CultivationService.lua
-- Das Herz des Spiels: Realm/Stage/EXP, Meditation, Realm-Breakthroughs,
-- abgeleitete Combat-Stats und die Alterung (Lifespan, Start mit Alter 18).
-- Spielerwerte liegen als Attribute auf dem Player und replizieren zum Client.
--
-- Zustände:
--   InMenu      = true  → Spieler ist im Providence-Start-Menü (eingefroren,
--                         keine Alterung, kein Combat, keine Meditation)
--   Meditating  = true  → Spieler sitzt, farmt EXP, kann sich nicht bewegen/angreifen

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

-- ── Bewegung / Sitzen ──────────────────────────────────────
-- Friert den Charakter ein, wenn er im Menü ist oder meditiert (= sitzt).
local function updateMovement(player: Player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not hum then
		return
	end
	local meditating = player:GetAttribute("Meditating") == true
	local inMenu = player:GetAttribute("InMenu") == true
	local frozen = meditating or inMenu

	hum.WalkSpeed = frozen and 0 or 16
	hum.JumpPower = frozen and 0 or 50
	hum.JumpHeight = frozen and 0 or 7.2
	hum.Sit = meditating -- beim Meditieren hinsetzen
end

-- ── Attribute schreiben ────────────────────────────────────
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
	player:SetAttribute("Age", math.floor(profile.age))
end

-- Berechnet MaxHP/Damage/Defense + Lifespan neu und heilt voll.
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

	local maxLife = CultivationData.GetLifespan(profile.realm)
	local infinite = maxLife == math.huge
	player:SetAttribute("LifespanInfinite", infinite)
	if infinite then
		maxLife = LIFESPAN_INF_SENTINEL
	end
	player:SetAttribute("MaxLifespan", maxLife)

	updateProgressAttributes(player, profile)
end

-- Startet das eigentliche Gameplay (nach Providence-Bestätigung).
function CultivationService.BeginGameplay(player: Player)
	CultivationService.RecomputeStats(player) -- erst Stats, dann HUD zeigen
	player:SetAttribute("InMenu", false)
	updateMovement(player)
	local realm = player:GetAttribute("RealmName") or "Qi Refinement"
	notifyEvent:FireClient(player, ("☯️ Dein Weg beginnt — %s, Alter 18."):format(realm), "gold")
end

-- ── Spieler-Setup beim Join ────────────────────────────────
local function setupCharacter(player: Player)
	player.CharacterAdded:Connect(function()
		player:SetAttribute("Meditating", false)
		task.wait(0.2) -- Humanoid kurz settlen lassen
		updateMovement(player)
	end)
	player:GetAttributeChangedSignal("Meditating"):Connect(function()
		updateMovement(player)
	end)
	player:GetAttributeChangedSignal("InMenu"):Connect(function()
		updateMovement(player)
	end)
	if player.Character then
		updateMovement(player)
	end
end

local function initPlayer(player: Player)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end

	ProvidenceService.EnsureRolled(player, profile)
	player:SetAttribute("Meditating", false)
	setupCharacter(player)

	if profile.providenceConfirmed then
		-- Wiederkehrender Spieler: direkt ins Spiel.
		CultivationService.RecomputeStats(player)
		player:SetAttribute("InMenu", false)
	else
		-- Neuer Spieler: ins Providence-Start-Menü.
		player:SetAttribute("InMenu", true)
		updateProgressAttributes(player, profile)
		updateMovement(player)
	end
end

-- ── EXP / Stages / Breakthrough ────────────────────────────
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
			profile.exp -= needed
			profile.realm += 1
			profile.stage = 1
			local realm = CultivationData.GetRealm(profile.realm)
			notifyEvent:FireClient(player, ("⚡ BREAKTHROUGH! %s erreicht!"):format(realm and realm.name or "?"), "gold")
			CultivationService.RecomputeStats(player)
		else
			profile.exp = needed
			break
		end
		needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	end

	updateProgressAttributes(player, profile)
end

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

function CultivationService.Start()
	DataManager.ProfileLoaded:Connect(initPlayer)

	-- Meditate-Toggle (im Menü blockiert).
	local meditateEvent = Net.Event("ToggleMeditate")
	meditateEvent.OnServerEvent:Connect(function(player, on)
		if player:GetAttribute("InMenu") then
			return
		end
		player:SetAttribute("Meditating", on == true)
	end)

	-- Haupt-Loop: Meditation (EXP) + Alterung.
	RunService.Heartbeat:Connect(function(dt)
		for _, player in ipairs(Players:GetPlayers()) do
			local profile = DataManager.Get(player)
			if not profile or player:GetAttribute("InMenu") then
				continue
			end

			-- Meditation
			if player:GetAttribute("Meditating") then
				local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
				CultivationService.AddEXP(player, needed * Config.MEDITATION_FRACTION_PER_SEC * dt)
			end

			-- Alterung
			if Config.LIFESPAN_ENABLED and not player:GetAttribute("LifespanInfinite") then
				profile.age += Config.LIFESPAN_DECAY_PER_SEC * dt
				player:SetAttribute("Age", math.floor(profile.age))
				local maxLife = player:GetAttribute("MaxLifespan") or 0
				if profile.age >= maxLife then
					-- Tod durch Alter: neues Leben (Alter 18), Stage-EXP verloren.
					profile.age = Config.STARTING_AGE
					profile.exp = 0
					notifyEvent:FireClient(player, "☠️ Deine Lebensspanne ist erschöpft — ein neues Leben beginnt (Alter 18).", "warn")
					CultivationService.RecomputeStats(player)
				end
			end
		end
	end)
end

return CultivationService
