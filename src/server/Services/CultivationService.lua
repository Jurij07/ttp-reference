--!strict
-- CultivationService.lua
-- Realm/Stage/EXP, combat stats, lifespan aging.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local TribulationData = require(GameData:WaitForChild("TribulationData"))
local PhysiqueEvolutionData = require(GameData:WaitForChild("PhysiqueEvolutionData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager = require(script.Parent.DataManager)
local ProvidenceService = require(script.Parent.ProvidenceService)

local CultivationService = {}

local notifyEvent = Net.Event("Notify")
local LIFESPAN_INF_SENTINEL = 1e15

local function updateMovement(player: Player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not hum then return end
	local inMenu        = player:GetAttribute("InMenu")        == true
	local inSeclusion   = player:GetAttribute("InSeclusion")   == true
	local inTribulation = player:GetAttribute("InTribulation") == true
	local frozen = inMenu or inSeclusion or inTribulation
	hum.WalkSpeed  = frozen and 0  or 16
	hum.JumpPower  = frozen and 0  or 50
	hum.JumpHeight = frozen and 0  or 7.2
	hum.Sit        = inSeclusion
end

local function updateProgressAttributes(player: Player, profile: any)
	local realm = CultivationData.GetRealm(profile.realm)
	player:SetAttribute("Realm",       profile.realm)
	player:SetAttribute("RealmName",   realm and realm.name or "?")
	player:SetAttribute("Tier",        realm and realm.tier or "?")
	player:SetAttribute("Stage",       profile.stage)
	player:SetAttribute("MaxStage",    CultivationData.GetMaxStage(profile.realm))
	player:SetAttribute("EXP",         profile.exp)
	player:SetAttribute("EXPNeeded",   CultivationData.GetStageEXP(profile.realm, profile.stage))
	player:SetAttribute("SpiritStones", profile.spiritStones)
	player:SetAttribute("Karma",       profile.karma)
	player:SetAttribute("TotalKills",  profile.totalKills)
	player:SetAttribute("Age",         math.floor(profile.age))
	player:SetAttribute("TotalExp",    math.floor(profile.totalExpEarned or 0))
	player:SetAttribute("PhysiqueStage", profile.physiqueStage or 1)
end

-- Prüft, ob der Spieler eine neue Physique-Evolutions-Stufe erreicht hat.
-- Gibt true zurück, wenn eine Stufe aufstieg (für Benachrichtigung).
local function checkPhysiqueEvolution(player: Player, profile: any): boolean
	local prov = profile.providence
	local evo = PhysiqueEvolutionData.ResolveStage(
		prov and prov.physique, profile.realm, profile.totalExpEarned or 0)
	if evo.stage > (profile.physiqueStage or 1) then
		profile.physiqueStage = evo.stage
		profile.bonusLifespan = (profile.bonusLifespan or 0) + evo.bonusLifespan
		notifyEvent:FireClient(player,
			("💪 Physique Evolution! Stage %d: %s"):format(evo.stage, evo.label), "gold")
		return true
	end
	return false
end
CultivationService.CheckPhysiqueEvolution = checkPhysiqueEvolution

function CultivationService.RecomputeStats(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end

	local baseHP, baseDmg, baseDef = CultivationData.GetCombatStats(profile.realm, profile.stage)
	local m = ProvidenceService.GetMultipliers(player)

	-- Ausrüstungs-Boni einrechnen
	local EquipmentService = require(script.Parent.EquipmentService)
	local eq = EquipmentService.GetBonuses(player)

	-- Blank Realm Insight: permanent +1% to all stats once earned.
	local insight = player:GetAttribute("BlankRealmInsight") and 1.01 or 1.0

	local newMaxHP = math.floor(baseHP * m.hp * eq.hp * insight)
	local oldMaxHP = (player:GetAttribute("MaxHP") or 0) :: number
	local oldHP    = (player:GetAttribute("HP") or 0) :: number
	player:SetAttribute("MaxHP", newMaxHP)
	if oldMaxHP <= 0 or profile.fullHealOnRecompute then
		-- Erst-Setup oder Realm-Aufstieg: voll heilen
		player:SetAttribute("HP", newMaxHP)
		profile.fullHealOnRecompute = false
	else
		-- Sonst aktuelle HP beibehalten (kein Gratis-Heal durch Umrüsten)
		player:SetAttribute("HP", math.clamp(oldHP, 1, newMaxHP))
	end
	player:SetAttribute("ATK",     math.floor(baseDmg * m.dmg * eq.dmg * insight))
	player:SetAttribute("Defense", math.floor(baseDef * m.def * eq.def * insight))

	local baseLife = CultivationData.GetLifespan(profile.realm)
	local infinite = baseLife == math.huge
	player:SetAttribute("LifespanInfinite", infinite)
	local maxLife = (infinite and LIFESPAN_INF_SENTINEL or baseLife * m.lifespan) + (profile.bonusLifespan or 0) + (m.bonusLifespan or 0)
	player:SetAttribute("MaxLifespan", maxLife)

	updateProgressAttributes(player, profile)
end

function CultivationService.BeginGameplay(player: Player)
	CultivationService.RecomputeStats(player)
	player:SetAttribute("InMenu", false)
	updateMovement(player)
	local realm = player:GetAttribute("RealmName") or "Qi Refinement"
	notifyEvent:FireClient(player, ("☯️ Your path begins — %s, age 18."):format(realm), "gold")
	-- refresh quests on gameplay start
	local QuestService = require(script.Parent.QuestService)
	QuestService.Refresh(player)
end

local function setupCharacter(player: Player)
	player.CharacterAdded:Connect(function()
		player:SetAttribute("InSeclusion", false)
		task.wait(0.2)
		updateMovement(player)
	end)
	player:GetAttributeChangedSignal("InSeclusion"):Connect(function() updateMovement(player) end)
	player:GetAttributeChangedSignal("InMenu"):Connect(function() updateMovement(player) end)
	player:GetAttributeChangedSignal("InTribulation"):Connect(function() updateMovement(player) end)
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
		local QuestService = require(script.Parent.QuestService)
		QuestService.Refresh(player)
	else
		player:SetAttribute("InMenu", true)
		updateProgressAttributes(player, profile)
		updateMovement(player)
	end
end

-- Führt den eigentlichen Realm-Aufstieg durch (nach bestandener Tribulation).
function CultivationService.DoRealmUp(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	if profile.realm >= #CultivationData.REALMS then return end

	profile.exp = 0
	profile.realm += 1
	profile.stage = 1
	-- Each breakthrough deepens Dao insight (drives the Dao-mastery titles).
	if type(profile.daoMastered) == "table" then
		profile.daoMastered["insight_" .. tostring(profile.realm)] = true
	end
	local realm = CultivationData.GetRealm(profile.realm)
	notifyEvent:FireClient(player, ("⚡ BREAKTHROUGH! Reached %s!"):format(realm and realm.name or "?"), "gold")
	checkPhysiqueEvolution(player, profile)
	profile.fullHealOnRecompute = true
	CultivationService.RecomputeStats(player)
	local QuestService = require(script.Parent.QuestService)
	QuestService.Refresh(player)
	local TitleService = require(script.Parent.TitleService)
	TitleService.CheckUnlocks(player)
end

-- isRaw=true skips Providence + Buff multipliers (for quest/item rewards)
-- Multiplier from world zones / states: meditation grotto & hidden island
-- (MeditationBonus), the personal Dao Field (2×) and the Book of Misfortune
-- curse (0.9×). Applied to active cultivation/combat EXP only.
function CultivationService.ZoneExpMult(player: Player): number
	local mult = 1.0
	local med = player:GetAttribute("MeditationBonus")
	if typeof(med) == "number" and med > 0 then mult *= med end
	if player:GetAttribute("InDaoField") then mult *= 2 end
	local curse = player:GetAttribute("CursedExpMult")
	if typeof(curse) == "number" and curse > 0 then mult *= curse end
	return mult
end

function CultivationService.AddEXP(player: Player, baseAmount: number, isRaw: boolean?)
	local profile = DataManager.Get(player)
	if not profile then return end

	-- Während einer Tribulation friert die EXP-Gewinnung ein.
	if player:GetAttribute("InTribulation") then
		updateProgressAttributes(player, profile)
		return
	end

	local gained: number
	if isRaw then
		gained = baseAmount
	else
		local m = ProvidenceService.GetMultipliers(player)
		local buffMult = Buffs.GetMult(player, "Exp")
		gained = baseAmount * m.exp * buffMult * CultivationService.ZoneExpMult(player)
	end
	profile.exp += gained
	if gained > 0 then
		profile.totalExpEarned = (profile.totalExpEarned or 0) + gained
		checkPhysiqueEvolution(player, profile)
		-- Sekten-EXP: 5% der gewonnenen EXP fließt in die Sekte.
		if profile.sectId then
			local SectService = require(script.Parent.SectService)
			SectService.AddSectExp(player, gained * 0.05)
		end
		-- Begleiter-Bond-EXP: 10% der gewonnenen EXP.
		if profile.activeCompanion then
			local CompanionService = require(script.Parent.CompanionService)
			CompanionService.AddBondExp(player, gained * 0.10)
		end
	end

	local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	while profile.exp >= needed do
		local maxStage = CultivationData.GetMaxStage(profile.realm)
		if profile.stage < maxStage then
			-- Boss-gate: freeze at last stage until boss is killed
			if profile.stage == maxStage - 1 and not profile.bossesKilled[profile.realm] then
				profile.exp = needed - 1
				break
			end
			profile.exp -= needed
			profile.stage += 1
		elseif profile.realm < #CultivationData.REALMS then
			if not profile.bossesKilled[profile.realm] then
				profile.exp = needed - 1
				break
			end
			-- Heaven Tribulation gate ab R3
			local trib = TribulationData.GetForRealm(profile.realm)
			if trib and profile.realm >= 3 then
				profile.exp = needed - 1
				local TribulationService = require(script.Parent.TribulationService)
				TribulationService.Begin(player, profile.realm)
				break
			end
			-- R1→R2, R2→R3: direkter Aufstieg (keine Tribulation)
			profile.exp = 0
			profile.realm += 1
			profile.stage = 1
			local realm = CultivationData.GetRealm(profile.realm)
			notifyEvent:FireClient(player, ("⚡ BREAKTHROUGH! Reached %s!"):format(realm and realm.name or "?"), "gold")
			checkPhysiqueEvolution(player, profile)
			profile.fullHealOnRecompute = true
			CultivationService.RecomputeStats(player)
			local QuestService = require(script.Parent.QuestService)
			QuestService.Refresh(player)
		else
			profile.exp = needed - 1
			break
		end
		needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
	end

	updateProgressAttributes(player, profile)
end

function CultivationService.OnBossKilled(player: Player, realmId: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.bossesKilled[realmId] = true
	CultivationService.AddEXP(player, 0)
end

function CultivationService.AddStones(player: Player, amount: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.spiritStones = (profile.spiritStones or 0) + amount
	if amount > 0 then
		profile.lifetimeStones = (profile.lifetimeStones or 0) + amount
	end
	player:SetAttribute("SpiritStones", profile.spiritStones)
end

function CultivationService.AddKill(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.totalKills = (profile.totalKills or 0) + 1
	player:SetAttribute("TotalKills", profile.totalKills)
	-- Dungeon-Fortschritt + Titel-Freischaltungen
	local DungeonService = require(script.Parent.DungeonService)
	DungeonService.OnKill(player)
	local TitleService = require(script.Parent.TitleService)
	TitleService.CheckUnlocks(player)
end

function CultivationService.Start()
	DataManager.ProfileLoaded:Connect(initPlayer)

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
					notifyEvent:FireClient(player, "☠️ Lifespan exhausted — a new life begins (age 18).", "warn")
					profile.fullHealOnRecompute = true
					CultivationService.RecomputeStats(player)
				end
			end
		end
	end)
end

return CultivationService
