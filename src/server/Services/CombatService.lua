--!strict
-- CombatService.lua
-- Server-autoritatives Kampfsystem.
-- Neu: Angriffs-Cooldown (Config.ATTACK_COOLDOWN), Boss-Kill → Realm-Durchbruch.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net    = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager        = require(script.Parent.DataManager)
local CultivationService = require(script.Parent.CultivationService)

local CombatService = {}

local notifyEvent = Net.Event("Notify")
local hitEvent    = Net.Event("CombatHit")

-- Letzter Angriffs-Zeitstempel je Spieler (für Cooldown)
local lastAttack: { [number]: number } = {}
local NPC_COUNTER_COOLDOWN = 1.2

-- ── NPC-Gegenangriff ───────────────────────────────────────
local function npcCounterattack(player: Player, model: Model)
	local now = os.clock()
	if now - (model:GetAttribute("LastCounter") or 0) < NPC_COUNTER_COOLDOWN then return end
	model:SetAttribute("LastCounter", now)

	local npcDmg   = model:GetAttribute("Damage")   or 0
	local playerDef = player:GetAttribute("Defense") or 0
	local applied  = math.max(npcDmg - playerDef, 1)

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

-- ── Kill-Belohnung + Boss-Kill-Behandlung ──────────────────
local function rewardKill(player: Player, model: Model)
	local exp    = model:GetAttribute("EXP")    or 0
	local stones = model:GetAttribute("Stones") or 0
	CultivationService.AddEXP(player, exp)
	CultivationService.AddStones(player, stones)
	CultivationService.AddKill(player)

	local name = model:GetAttribute("NPCName") or model.Name
	notifyEvent:FireClient(player, ("⚔️ %s besiegt! +%d EXP, +%d Stones"):format(name, exp, stones), "good")

	-- Boss-Kill → Durchbruch freischalten
	if model:GetAttribute("Boss") == true then
		local realmId = model:GetAttribute("RealmId") or 0
		if realmId > 0 then
			CultivationService.OnBossKilled(player, realmId)
		end
	end
end

-- ── Spieler greift NPC an ──────────────────────────────────
function CombatService.PlayerAttackNPC(player: Player, model: Model)
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end

	-- Angriffs-Cooldown
	local now = os.clock()
	local uid = player.UserId
	if now - (lastAttack[uid] or 0) < Config.ATTACK_COOLDOWN then return end
	lastAttack[uid] = now

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	-- Distanz-Check (Anti-Cheat)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local prim = model.PrimaryPart
	if root and prim and (root.Position - prim.Position).Magnitude > Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER then
		return
	end

	local dmg    = player:GetAttribute("Damage")  or 10
	local npcDef = model:GetAttribute("Defense")  or 0
	local applied = math.max(dmg - npcDef, 1)

	hum.Health = math.max(hum.Health - applied, 0)
	hitEvent:FireClient(player, model:GetAttribute("NPCName") or model.Name, applied)

	if hum.Health <= 0 then
		rewardKill(player, model)
	else
		npcCounterattack(player, model)
	end
end

-- ── Service-Start ──────────────────────────────────────────
function CombatService.Start()
	-- Cleanup beim Verlassen
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
