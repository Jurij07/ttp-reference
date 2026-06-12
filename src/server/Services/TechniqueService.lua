--!strict
-- TechniqueService.lua
-- Handles Q-key active technique use. Finds nearest NPC and applies the
-- player's Dao technique (or Basic Strike as fallback).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local TechniqueData = require(GameData:WaitForChild("TechniqueData"))

local CombatService = require(script.Parent.CombatService)

local TechniqueService = {}

local lastUse: {[number]: number} = {}

local function nearestNPC(player: Player): Model?
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return nil end

	local folder = workspace:FindFirstChild("NPCs")
	if not folder then return nil end

	local best: Model? = nil
	local bestDist = Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER

	for _, child in ipairs(folder:GetChildren()) do
		local model = child :: Model
		local prim = model.PrimaryPart
		local hum = model:FindFirstChildOfClass("Humanoid")
		if prim and hum and hum.Health > 0 then
			local dist = (root.Position - prim.Position).Magnitude
			if dist < bestDist then
				bestDist = dist
				best = model
			end
		end
	end
	return best
end

function TechniqueService.UseActive(player: Player)
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end

	local uid = player.UserId
	local now = os.clock()
	local cooldownUntil = (player:GetAttribute("TechCooldownUntil") or 0) :: number
	if os.time() < cooldownUntil then return end

	-- Equipped catalog technique (TechniqueMasteryService) takes priority;
	-- otherwise the Dao-affinity default applies.
	local dao = (player:GetAttribute("DaoAffinity") or "") :: string
	local tech: any = TechniqueData.GetForDao(dao) or TechniqueData.Get("basic_strike")
	local okM, TMS = pcall(require, script.Parent.TechniqueMasteryService)
	if okM then
		local equippedId = (TMS :: any).GetEquipped(player)
		if equippedId then
			local GameData_ = ReplicatedStorage:WaitForChild("GameData")
			local TechniqueCatalog = require(GameData_:WaitForChild("TechniqueCatalog"))
			local TechniqueMasteryData = require(GameData_:WaitForChild("TechniqueMasteryData"))
			local entry = TechniqueCatalog.Get(equippedId)
			local eff = TechniqueMasteryData.Get(equippedId)
			if entry and eff and eff.dmgMult then
				tech = {
					name = entry.name,
					dmgMult = eff.dmgMult,
					healFrac = eff.healFrac,
					cooldown = math.clamp(3 + eff.dmgMult * 0.8, 4, 12),
				}
			end
		end
	end
	if not tech then return end

	-- Per-player server-side cooldown
	if now - (lastUse[uid] or 0) < tech.cooldown then return end
	lastUse[uid] = now
	player:SetAttribute("TechCooldownUntil", os.time() + tech.cooldown)

	local target = nearestNPC(player)
	if not target then return end

	local atk = (player:GetAttribute("ATK") or player:GetAttribute("Damage") or 10) :: number
	local rawDmg = math.floor(atk * tech.dmgMult)

	CombatService.DealDamage(player, target, rawDmg, false)

	-- Dao-flavoured status effect on the struck foe.
	local StatusEffectService = require(script.Parent.StatusEffectService)
	local dao = (player:GetAttribute("DaoAffinity") or "") :: string
	local debuff = StatusEffectService.DaoDebuff(dao)
	if debuff then StatusEffectService.Apply(target, debuff) end

	-- Healing technique → also grants Regenerating to self.
	if tech.healFrac then
		local heal = rawDmg * tech.healFrac
		local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
		local hp    = (player:GetAttribute("HP")    or 0) :: number
		player:SetAttribute("HP", math.min(maxHP, hp + heal))
		StatusEffectService.Apply(player, "regenerating")
	end

	Net.Event("TechniqueUsed"):FireClient(player, tech.name, tech.cooldown)
end

function TechniqueService.Start()
	Net.Event("TechniqueUsed") -- pre-create for client WaitForChild
	local useEvent = Net.Event("UseTechnique")
	useEvent.OnServerEvent:Connect(function(player)
		TechniqueService.UseActive(player)
	end)
end

return TechniqueService
