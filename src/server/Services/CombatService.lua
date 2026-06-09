--!strict
-- CombatService.lua
-- Server-autoritatives Kampfsystem.
-- DealDamage() ist die zentrale Schadensfunktion (genutzt von Klick-Angriff
-- UND von Dao-Techniken). Angriffs-Cooldown, DMG-Buff, Mutation-Belohnung,
-- Boss-Kill → Realm-Durchbruch, Quest-Meldungen.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net    = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs  = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager        = require(script.Parent.DataManager)
local CultivationService = require(script.Parent.CultivationService)

local CombatService = {}

local notifyEvent = Net.Event("Notify")
local hitEvent    = Net.Event("CombatHit")

local lastAttack: { [number]: number } = {}
local NPC_COUNTER_COOLDOWN = 1.2

-- ── NPC-Gegenangriff ───────────────────────────────────────
function CombatService.NpcCounterattack(player: Player, model: Model)
	local now = os.clock()
	if now - (model:GetAttribute("LastCounter") or 0) < NPC_COUNTER_COOLDOWN then return end
	model:SetAttribute("LastCounter", now)

	local npcDmg    = model:GetAttribute("Damage")   or 0
	local playerDef = player:GetAttribute("Defense") or 0
	local applied   = math.max(npcDmg - playerDef, 1)

	local hp = (player:GetAttribute("HP") or 0) - applied
	if hp <= 0 then
		player:SetAttribute("HP", player:GetAttribute("MaxHP") or 1)
		local profile = DataManager.Get(player)
		if profile then
			local lost = math.floor(profile.spiritStones * 0.25)
			profile.spiritStones = math.max(0, profile.spiritStones - lost)
			player:SetAttribute("SpiritStones", profile.spiritStones)
			notifyEvent:FireClient(player, ("💀 Besiegt! %d Spirit Stones verloren."):format(lost), "warn")
		end
	else
		player:SetAttribute("HP", hp)
	end
end

-- ── Kill-Belohnung + Boss/Quest-Behandlung ────────────────
local function rewardKill(player: Player, model: Model)
	local exp    = model:GetAttribute("EXP")    or 0
	local stones = model:GetAttribute("Stones") or 0
	CultivationService.AddEXP(player, exp)
	CultivationService.AddStones(player, stones)
	CultivationService.AddKill(player)

	local name = model:GetAttribute("NPCName") or model.Name
	local mutTag = model:GetAttribute("Mutated") and " ✨MUTIERT✨" or ""
	notifyEvent:FireClient(player, ("⚔️ %s%s besiegt! +%d EXP, +%d Stones"):format(name, mutTag, exp, stones), "good")

	-- Quest-Meldung: Kill (+ Boss)
	local QuestService = require(script.Parent.QuestService)
	QuestService.Report(player, "kills", 1)

	if model:GetAttribute("Boss") == true then
		local realmId = model:GetAttribute("RealmId") or 0
		if realmId > 0 then
			CultivationService.OnBossKilled(player, realmId)
		end
		QuestService.Report(player, "boss", 1)
	end
end

-- ── Zentrale Schadensfunktion ──────────────────────────────
-- rawDamage: bereits berechneter Roh-Schaden (vor NPC-Verteidigung).
-- triggerCounter: ob der NPC zurückschlagen darf.
function CombatService.DealDamage(player: Player, model: Model, rawDamage: number, triggerCounter: boolean): boolean
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end

	local npcDef  = model:GetAttribute("Defense") or 0
	local applied = math.max(math.floor(rawDamage) - npcDef, 1)

	hum.Health = math.max(hum.Health - applied, 0)
	hitEvent:FireClient(player, model:GetAttribute("NPCName") or model.Name, applied)

	if hum.Health <= 0 then
		rewardKill(player, model)
		return true
	elseif triggerCounter then
		CombatService.NpcCounterattack(player, model)
	end
	return false
end

-- Prüft, ob der Spieler den NPC angreifen darf (Reichweite/Status).
function CombatService.CanAttack(player: Player, model: Model): boolean
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return false end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local prim = model.PrimaryPart
	if root and prim and (root.Position - prim.Position).Magnitude > Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER then
		return false
	end
	return true
end

-- ── Klick-Angriff ──────────────────────────────────────────
function CombatService.PlayerAttackNPC(player: Player, model: Model)
	if not CombatService.CanAttack(player, model) then return end

	-- Angriffs-Cooldown
	local now = os.clock()
	local uid = player.UserId
	if now - (lastAttack[uid] or 0) < Config.ATTACK_COOLDOWN then return end
	lastAttack[uid] = now

	-- Basisangriff × aktiver DMG-Buff
	local dmg = (player:GetAttribute("Damage") or 10) * Buffs.GetMult(player, "Dmg")
	CombatService.DealDamage(player, model, dmg, true)
end

function CombatService.Start()
	Players.PlayerRemoving:Connect(function(player)
		lastAttack[player.UserId] = nil
	end)

	-- HP-Regen alle 0.5 s (+5% MaxHP)
	local accum = 0
	RunService.Heartbeat:Connect(function(dt)
		accum += dt
		if accum < 0.5 then return end
		local step = accum; accum = 0
		for _, player in ipairs(Players:GetPlayers()) do
			local maxHP = player:GetAttribute("MaxHP")
			local hp    = player:GetAttribute("HP")
			if maxHP and hp and hp < maxHP then
				player:SetAttribute("HP", math.min(hp + maxHP * 0.05 * step, maxHP))
			end
		end
	end)
end

return CombatService
