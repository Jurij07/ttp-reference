--!strict
-- CombatService.lua
-- Server-authoritative combat. ClickDetector on NPC → damage, counter, rewards.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager        = require(script.Parent.DataManager)
local CultivationService = require(script.Parent.CultivationService)
local StatusEffectService = require(script.Parent.StatusEffectService)

local CombatService = {}

local notifyEvent   = Net.Event("Notify")
local hitEvent      = Net.Event("CombatHit")

local lastAttack: {[number]: number} = {}
local NPC_COUNTER_CD = 1.0

local function npcCounterattack(player: Player, model: Model)
	-- Stunned / frozen foes cannot retaliate.
	if StatusEffectService.IsControlled(model) then return end

	local now = os.clock()
	local last = (model:GetAttribute("LastCounter") or 0) :: number
	if now - last < NPC_COUNTER_CD then return end
	model:SetAttribute("LastCounter", now)

	local npcDmg   = (model:GetAttribute("Damage")  or 0) :: number
	local playerDef = ((player:GetAttribute("Defense") or 0) :: number) * StatusEffectService.DefenceMult(player)
	local applied  = math.max(npcDmg - playerDef, 1) * StatusEffectService.IncomingMult(player)

	-- Venomous / fiery beasts inflict a debuff on the player.
	local npcName = (model:GetAttribute("NPCName") or "") :: string
	if npcName:find("Poison") or npcName:find("Venom") or npcName:find("Snake") then
		StatusEffectService.Apply(player, "poison")
	elseif npcName:find("Fire") or npcName:find("Flame") or npcName:find("Burn") then
		StatusEffectService.Apply(player, "burn")
	end

	local hp = ((player:GetAttribute("HP") or 0) :: number) - applied
	if hp <= 0 then
		local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
		player:SetAttribute("HP", maxHP)
		local profile = DataManager.Get(player)
		if profile then
			local lost = math.floor(profile.spiritStones * 0.25)
			profile.spiritStones -= lost
			player:SetAttribute("SpiritStones", profile.spiritStones)
			notifyEvent:FireClient(player, ("💀 Defeated! Lost %d Spirit Stones."):format(lost), "warn")
		end
	else
		player:SetAttribute("HP", hp)
	end
end

local function rewardKill(player: Player, model: Model)
	local exp    = (model:GetAttribute("EXP")    or 0) :: number
	local stones = (model:GetAttribute("Stones") or 0) :: number
	local isBoss = model:GetAttribute("Boss") == true
	local realmId = (model:GetAttribute("RealmId") or 1) :: number

	-- Dungeon-Multiplikatoren auf EXP/Stones anwenden.
	local DungeonService = require(script.Parent.DungeonService)
	local expMult, stoneMult = DungeonService.GetMultipliers(player)
	exp    = math.floor(exp * expMult)
	stones = math.floor(stones * stoneMult)

	CultivationService.AddEXP(player, exp)
	CultivationService.AddStones(player, stones)
	CultivationService.AddKill(player)

	if isBoss then
		CultivationService.OnBossKilled(player, realmId)
	end

	local name = model:GetAttribute("NPCName") or model.Name
	notifyEvent:FireClient(player, ("⚔️ Defeated %s! +%d EXP, +%d 💰"):format(name, exp, stones), "good")
end

function CombatService.DealDamage(player: Player, model: Model, rawDmg: number, triggerCounter: boolean)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local npcDef = ((model:GetAttribute("Defense") or 0) :: number) * StatusEffectService.DefenceMult(model)
	local applied = math.max(rawDmg - npcDef, 1) * StatusEffectService.IncomingMult(model)
	hum.Health = math.max(hum.Health - applied, 0)
	hitEvent:FireClient(player, model:GetAttribute("NPCName") or model.Name, applied)

	if hum.Health <= 0 then
		rewardKill(player, model)
	elseif triggerCounter then
		npcCounterattack(player, model)
	end
end

function CombatService.PlayerAttackNPC(player: Player, model: Model)
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end

	local uid = player.UserId
	local now = os.clock()
	if now - (lastAttack[uid] or 0) < Config.ATTACK_COOLDOWN then return end
	lastAttack[uid] = now

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local prim = model.PrimaryPart
	local maxDist = Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER
	if root and prim and (root.Position - prim.Position).Magnitude > maxDist then return end

	local dmg = (player:GetAttribute("ATK") or player:GetAttribute("Damage") or 10) :: number
	local buffMult = Buffs.GetMult(player, "Dmg")
	CombatService.DealDamage(player, model, math.floor(dmg * buffMult), true)
end

function CombatService.Start()
	-- HP regen outside combat: +2% MaxHP every 0.5s
	local accum = 0
	RunService.Heartbeat:Connect(function(dt)
		accum += dt
		if accum < 0.5 then return end
		local step = accum; accum = 0
		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("InMenu") then continue end
			local maxHP = (player:GetAttribute("MaxHP") or 0) :: number
			local hp    = (player:GetAttribute("HP")    or 0) :: number
			if hp < maxHP then
				player:SetAttribute("HP", math.min(hp + maxHP * 0.02 * step, maxHP))
			end
		end
	end)
end

return CombatService
