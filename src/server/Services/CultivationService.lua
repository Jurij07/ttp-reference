--!strict
-- CultivationService.lua
-- Realm/Stage/EXP, Combat-Stats, Alterung.
-- WICHTIG: Realm-Durchbruch erfordert Boss-Kill (profile.bossesKilled[realmId]).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local Net   = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager       = require(script.Parent.DataManager)
local ProvidenceService = require(script.Parent.ProvidenceService)

local CultivationService = {}

local notifyEvent = Net.Event("Notify")
local LIFESPAN_INF_SENTINEL = 1e15

-- ── Bewegung ───────────────────────────────────────────────
local function updateMovement(player: Player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not hum then return end
	local frozen = player:GetAttribute("InMenu") == true
		or player:GetAttribute("InSeclusion") == true
	hum.WalkSpeed  = frozen and 0 or 16
	hum.JumpPower  = frozen and 0 or 50
	hum.JumpHeight = frozen and 0 or 7.2
	hum.Sit        = player:GetAttribute("InSeclusion") == true
end

-- ── Attribute schreiben ────────────────────────────────────
local function updateProgressAttributes(player: Player, profile: any)
	local realm = CultivationData.GetRealm(profile.realm)
	player:SetAttribute("Realm",        profile.realm)
	player:SetAttribute("RealmName",    realm and realm.name or "?")
	player:SetAttribute("Tier",         realm and realm.tier or "?")
	player:SetAttribute("Stage",        profile.stage)
	player:SetAttribute("MaxStage",     CultivationData.GetMaxStage(profile.realm))
	player:SetAttribute("EXP",          profile.exp)
	player:SetAttribute("EXPNeeded",    CultivationData.GetStageEXP(profile.realm, profile.stage))
	player:SetAttribute("SpiritStones", profile.spiritStones)
	player:SetAttribute("Karma",        profile.karma)
	player:SetAttribute("TotalKills",   profile.totalKills)
	player:SetAttribute("Age",          math.floor(profile.age))
	-- Boss-Status für HUD
	local bossRequired = profile.stage >= CultivationData.GetMaxStage(profile.realm)
		and not (profile.bossesKilled and profile.bossesKilled[profile.realm])
	player:SetAttribute("BossRequired", bossRequired)
end

-- ── Combat-Stats + Lebensspanne neu berechnen ──────────────
function CultivationService.RecomputeStats(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end

	local baseHP, baseDmg, baseDef = CultivationData.GetCombatStats(profile.realm, profile.stage)
	local m = ProvidenceService.GetMultipliers(player)

	local maxHP = math.floor(baseHP * m.hp)
	player:SetAttribute("MaxHP",    maxHP)
	player:SetAttribute("HP",       maxHP)
	player:SetAttribute("Damage",   math.floor(baseDmg * m.dmg))
	player:SetAttribute("Defense",  math.floor(baseDef * m.def))

	local maxLife = CultivationData.GetLifespan(profile.realm) * m.lifespan
	local infinite = maxLife == math.huge
	player:SetAttribute("LifespanInfinite", infinite)
	if infinite then maxLife = LIFESPAN_INF_SENTINEL end
	player:SetAttribute("MaxLifespan", maxLife)

	updateProgressAttributes(player, profile)
end

-- ── Gameplay starten ───────────────────────────────────────
function CultivationService.BeginGameplay(player: Player)
	CultivationService.RecomputeStats(player)
	player:SetAttribute("InMenu", false)
	updateMovement(player)
	local realm = player:GetAttribute("RealmName") or "Qi Refinement"
	notifyEvent:FireClient(player, ("☯️ Dein Weg beginnt — %s, Alter 18."):format(realm), "gold")
end

-- ── Player-Setup ───────────────────────────────────────────
local function setupCharacter(player: Player)
	player.CharacterAdded:Connect(function()
		player:SetAttribute("InSeclusion", false)
		task.wait(0.2); updateMovement(player)
	end)
	player:GetAttributeChangedSignal("InSeclusion"):Connect(function() updateMovement(player) end)
	player:GetAttributeChangedSignal("InMenu"):Connect(function() updateMovement(player) end)
	if player.Character then updateMovement(player) end
end

local function initPlayer(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	ProvidenceService.EnsureRolled(player, profile)
	player:SetAttribute("InSeclusion", false)
	setupCharacter(player)
	if profile.providenceConfirmed then
		CultivationService.RecomputeStats(player)
		player:SetAttribute("InMenu", false)
	else
		player:SetAttribute("InMenu", true)
		updateProgressAttributes(player, profile)
		updateMovement(player)
	end
end

-- ── EXP hinzufügen — BOSS-KILL-PFLICHT für Realm-Wechsel ──
function CultivationService.AddEXP(player: Player, baseAmount: number)
	local profile = DataManager.Get(player)
	if not profile then return end

	-- EXP-Multiplikator aus Providence × aktiver EXP-Buff (Pillen).
	local mult = ProvidenceService.GetMultipliers(player).exp * Buffs.GetMult(player, "Exp")
	profile.exp += baseAmount * mult

	local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	while profile.exp >= needed do
		local maxStage = CultivationData.GetMaxStage(profile.realm)

		if profile.stage < maxStage then
			-- Nächste Stage im gleichen Realm
			profile.exp -= needed
			profile.stage += 1
			needed = CultivationData.GetStageEXP(profile.realm, profile.stage)

		elseif profile.realm < #CultivationData.REALMS then
			-- Max-Stage erreicht — prüfe Boss-Kill-Pflicht
			local bossKilled = profile.bossesKilled and profile.bossesKilled[profile.realm]
			if not bossKilled then
				-- EXP auf Maximum deckeln, warten auf Boss-Kill
				profile.exp = needed
				notifyEvent:FireClient(player,
					"⚠️ Max-Stage erreicht! Besiege den Realm Guardian um den Durchbruch zu machen!",
					"warn")
				break
			end
			-- Boss besiegt → Realm-Durchbruch
			profile.exp -= needed
			profile.realm += 1
			profile.stage  = 1
			local newRealm = CultivationData.GetRealm(profile.realm)
			notifyEvent:FireClient(player,
				("⚡ REALM-DURCHBRUCH! %s erreicht!"):format(newRealm and newRealm.name or "?"),
				"gold")
			CultivationService.RecomputeStats(player)
			-- Quest-Meldung: Realm erreicht
			local QuestService = require(script.Parent.QuestService)
			QuestService.Report(player, "realm", profile.realm)
			needed = CultivationData.GetStageEXP(profile.realm, profile.stage)

		else
			-- Letztes Realm — EXP einfrieren
			profile.exp = needed
			break
		end
	end

	updateProgressAttributes(player, profile)
end

-- ── Nach Boss-Kill: Durchbruch ermöglichen ─────────────────
function CultivationService.OnBossKilled(player: Player, realmId: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	if not profile.bossesKilled then profile.bossesKilled = {} end
	profile.bossesKilled[realmId] = true
	notifyEvent:FireClient(player,
		("🏆 Realm Guardian besiegt! Durchbruch freigeschaltet!"),
		"gold")
	-- Versuche sofort Realm-Wechsel (falls EXP schon voll war)
	local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	if profile.exp >= needed then
		CultivationService.AddEXP(player, 0)
	end
	updateProgressAttributes(player, profile)
end

function CultivationService.AddStones(player: Player, amount: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.spiritStones += amount
	player:SetAttribute("SpiritStones", profile.spiritStones)
end

function CultivationService.AddKill(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.totalKills += 1
	player:SetAttribute("TotalKills", profile.totalKills)
end

-- ── Service-Start ──────────────────────────────────────────
function CultivationService.Start()
	DataManager.ProfileLoaded:Connect(initPlayer)

	-- Nur passives Altern im Heartbeat (kein Meditations-EXP)
	RunService.Heartbeat:Connect(function(dt)
		for _, player in ipairs(Players:GetPlayers()) do
			local profile = DataManager.Get(player)
			if not profile or player:GetAttribute("InMenu") then continue end
			if Config.LIFESPAN_ENABLED
				and not player:GetAttribute("LifespanInfinite")
				and not player:GetAttribute("InSeclusion")
			then
				profile.age += Config.LIFESPAN_DECAY_PER_SEC * dt
				player:SetAttribute("Age", math.floor(profile.age))
				local maxLife = player:GetAttribute("MaxLifespan") or 0
				if profile.age >= maxLife then
					profile.age = Config.STARTING_AGE
					profile.exp = 0
					notifyEvent:FireClient(player, "☠️ Lebensspanne erschöpft — neues Leben (Alter 18).", "warn")
					CultivationService.RecomputeStats(player)
				end
			end
		end
	end)
end

return CultivationService
