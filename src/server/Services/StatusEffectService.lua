--!strict
-- StatusEffectService.lua
-- Applies the 14 status effects in combat. Targets are NPC Models or Players.
-- A 1s tick handles damage-over-time (burn/poison/bleed), heal-over-time
-- (regenerating) and expiry. Control effects (stun/freeze) suppress actions;
-- bleed amplifies incoming damage; weakened lowers defence.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local StatusEffectData = require(GameData:WaitForChild("StatusEffectData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local StatusEffectService = {}

local statusEvent = Net.Event("StatusEffect")

-- state[target] = { [effectId] = { stacks, expireAt } }
local state: { [Instance]: { [string]: { stacks: number, expireAt: number } } } = {}

local function npcHumanoid(target: Instance): Humanoid?
	if target:IsA("Model") then return target:FindFirstChildOfClass("Humanoid") end
	return nil
end

-- Apply (or refresh) a status effect on a target.
function StatusEffectService.Apply(target: Instance, effectId: string, stacks: number?)
	local def = StatusEffectData.Get(effectId)
	if not def then return end
	state[target] = state[target] or {}
	local cur = state[target][effectId]
	local addStacks = stacks or 1
	if cur then
		cur.stacks = math.min(def.maxStacks, cur.stacks + addStacks)
		cur.expireAt = os.clock() + def.duration
	else
		state[target][effectId] = { stacks = math.min(def.maxStacks, addStacks), expireAt = os.clock() + def.duration }
	end
	-- Notify a player target (for HUD), or fire to the owning hitter is N/A here.
	if target:IsA("Player") then
		statusEvent:FireClient(target, effectId, def.name, def.kind, def.duration)
	end
end

function StatusEffectService.Has(target: Instance, effectId: string): boolean
	local s = state[target]
	return s ~= nil and s[effectId] ~= nil
end

function StatusEffectService.IsControlled(target: Instance): boolean
	return StatusEffectService.Has(target, "stun") or StatusEffectService.Has(target, "freeze")
end

-- Incoming-damage multiplier on a target (bleed amplifies).
function StatusEffectService.IncomingMult(target: Instance): number
	return StatusEffectService.Has(target, "bleed") and 1.20 or 1.0
end

-- Defence multiplier (weakened lowers defence).
function StatusEffectService.DefenceMult(target: Instance): number
	return StatusEffectService.Has(target, "weakened") and 0.75 or 1.0
end

-- Maps a Dao to the debuff its techniques inflict.
local DAO_DEBUFF = {
	Fire = "burn", Ice = "freeze", Thunder = "stun", Sword = "bleed",
	Earth = "weakened", Void = "silence", Space = "stun",
}
function StatusEffectService.DaoDebuff(dao: string): string?
	return DAO_DEBUFF[dao]
end

local function tickTarget(target: Instance, effects: { [string]: any }, now: number)
	-- expire
	for id, data in pairs(effects) do
		if now >= data.expireAt then effects[id] = nil end
	end

	local hum = npcHumanoid(target)
	local isPlayer = target:IsA("Player")
	if not hum and not isPlayer then return end

	local maxHP: number = if isPlayer then ((target :: any):GetAttribute("MaxHP") or 1) else (hum :: Humanoid).MaxHealth
	local curHP: number = if isPlayer then ((target :: any):GetAttribute("HP") or 0) else (hum :: Humanoid).Health
	local delta = 0

	local burn = effects.burn;   if burn then delta -= maxHP * 0.04 * burn.stacks end
	local pois = effects.poison; if pois then delta -= maxHP * 0.03 * pois.stacks end
	local bleed = effects.bleed; if bleed then delta -= maxHP * 0.025 * bleed.stacks end
	local regen = effects.regenerating; if regen then delta += maxHP * 0.08 end

	if delta ~= 0 then
		local newHP = math.clamp(curHP + delta, isPlayer and 1 or 0, maxHP)
		if isPlayer then
			(target :: any):SetAttribute("HP", newHP)
		else
			(hum :: Humanoid).Health = newHP
		end
	end
end

function StatusEffectService.Start()
	local accum = 0
	RunService.Heartbeat:Connect(function(dt)
		accum += dt
		if accum < 1 then return end
		accum = 0
		local now = os.clock()
		for target, effects in pairs(state) do
			-- cleanup dead/removed targets
			if not target.Parent and not target:IsA("Player") then
				state[target] = nil
				continue
			end
			if next(effects) == nil then
				state[target] = nil
				continue
			end
			tickTarget(target, effects, now)
		end
	end)

	Players.PlayerRemoving:Connect(function(pl) state[pl] = nil end)
end

return StatusEffectService
