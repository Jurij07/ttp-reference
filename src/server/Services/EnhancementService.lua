--!strict
-- EnhancementService.lua
-- Handles permanent idle-game upgrades purchased with spirit stones.
-- Exposes GetExpMult / GetStoneMult / GetHuntTick so IdleService can read them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net  = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local EnhancementData = require(GameData:WaitForChild("EnhancementData"))

local DataManager = require(script.Parent.DataManager)

local EnhancementService = {}

local notifyEvent = Net.Event("Notify")

local function getLevels(profile: any): { [string]: number }
	if type(profile.enhancements) ~= "table" then
		profile.enhancements = {}
	end
	return profile.enhancements
end

function EnhancementService.GetExpMult(player: Player): number
	local profile = DataManager.Get(player)
	if not profile then return 1 end
	local upg = EnhancementData.Get("spirit_cave")
	if not upg then return 1 end
	local lvl = (getLevels(profile)["spirit_cave"] or 0) :: number
	return EnhancementData.Mult(upg, lvl)
end

function EnhancementService.GetStoneMult(player: Player): number
	local profile = DataManager.Get(player)
	if not profile then return 1 end
	local upg = EnhancementData.Get("stone_vein")
	if not upg then return 1 end
	local lvl = (getLevels(profile)["stone_vein"] or 0) :: number
	return EnhancementData.Mult(upg, lvl)
end

function EnhancementService.GetHuntTick(player: Player): number
	local profile = DataManager.Get(player)
	if not profile then return 5 end
	local lvl = (getLevels(profile)["swift_hunt"] or 0) :: number
	return EnhancementData.HuntTick(lvl)
end

local function syncEnhancements(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	Net.Event("EnhancementSync"):FireClient(player, getLevels(profile))
end

function EnhancementService.Start()
	Net.Event("EnhancementSync")

	Net.Event("BuyEnhancement").OnServerEvent:Connect(function(player: Player, idRaw: unknown)
		local id = tostring(idRaw)
		local upg = EnhancementData.Get(id)
		if not upg then return end

		local profile = DataManager.Get(player)
		if not profile then return end

		local levels = getLevels(profile)
		local lvl = (levels[id] or 0) :: number
		if lvl >= upg.maxLevel then
			notifyEvent:FireClient(player, "🔒 Already at max level!", "warn"); return
		end

		local cost = EnhancementData.NextCost(upg, lvl)
		if (profile.spiritStones or 0) < cost then
			notifyEvent:FireClient(player,
				("💰 Need %d Spirit Stones (have %d)."):format(cost, profile.spiritStones or 0), "warn")
			return
		end

		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.AddStones(player, -cost)
		levels[id] = lvl + 1
		notifyEvent:FireClient(player,
			("%s %s upgraded to level %d!"):format(upg.icon, upg.name, lvl + 1), "gold")
		syncEnhancements(player)
	end)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.delay(2, function()
			if player.Parent then syncEnhancements(player) end
		end)
	end)

	print("[EnhancementService] Started.")
end

return EnhancementService
