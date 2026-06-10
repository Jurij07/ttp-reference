--!strict
-- CompanionService.lua
-- Spirit Companions: buy with stones, set one active, gain bond-EXP from combat
-- (10% of your EXP). Bond level (max 10) scales the companion's stat bonus,
-- which folds into RecomputeStats via GetActiveBonus.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local CompanionData = require(GameData:WaitForChild("CompanionData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local CompanionService = {}

local notifyEvent = Net.Event("Notify")
local syncEvent   = Net.Event("CompanionSync")

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	syncEvent:FireClient(player, {
		owned = profile.companions,
		active = profile.activeCompanion,
	})
	local active = profile.activeCompanion and profile.companions[profile.activeCompanion]
	player:SetAttribute("CompanionLevel", active and active.level or 0)
	local c = profile.activeCompanion and CompanionData.Get(profile.activeCompanion)
	player:SetAttribute("CompanionName", c and c.name or "")
end
CompanionService.Sync = sync

-- Aggregated bonus from the active companion (multipliers + flat lifespan).
function CompanionService.GetActiveBonus(player: Player): { dmg: number, def: number, hp: number, exp: number, lifespan: number }
	local profile = DataManager.Get(player)
	local none = { dmg=1, def=1, hp=1, exp=1, lifespan=0 }
	if not profile or not profile.activeCompanion then return none end
	local c = CompanionData.Get(profile.activeCompanion)
	local owned = profile.companions[profile.activeCompanion]
	if not c or not owned then return none end
	return CompanionData.BonusAt(c, owned.level or 1)
end

function CompanionService.Buy(player: Player, idRaw: any)
	local id = tostring(idRaw)
	local c = CompanionData.Get(id)
	if not c then return end
	local profile = DataManager.Get(player)
	if not profile then return end
	if profile.companions[id] then
		notifyEvent:FireClient(player, "You already own this companion.", "warn")
		return
	end
	if profile.spiritStones < c.cost then
		notifyEvent:FireClient(player, "Not enough Spirit Stones.", "warn")
		return
	end
	profile.spiritStones -= c.cost
	player:SetAttribute("SpiritStones", profile.spiritStones)
	profile.companions[id] = { level = 1, exp = 0 }
	profile.activeCompanion = profile.activeCompanion or id
	notifyEvent:FireClient(player, ("🐾 Tamed companion: %s!"):format(c.name), "gold")
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	sync(player)
end

function CompanionService.SetActive(player: Player, idRaw: any)
	local id = tostring(idRaw)
	local profile = DataManager.Get(player)
	if not profile or not profile.companions[id] then return end
	profile.activeCompanion = id
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	local c = CompanionData.Get(id)
	notifyEvent:FireClient(player, ("🐾 %s is now at your side."):format(c and c.name or "Companion"), "info")
	sync(player)
end

-- Bond-EXP from combat (10% of EXP gained). Levels up at 1000 each, max 10.
function CompanionService.AddBondExp(player: Player, amount: number)
	local profile = DataManager.Get(player)
	if not profile or not profile.activeCompanion then return end
	local owned = profile.companions[profile.activeCompanion]
	local c = CompanionData.Get(profile.activeCompanion)
	if not owned or not c then return end
	if owned.level >= 10 then return end

	owned.exp = (owned.exp or 0) + amount
	local leveled = false
	while owned.level < 10 and owned.exp >= CompanionData.BondExpForLevel(owned.level) do
		owned.exp -= CompanionData.BondExpForLevel(owned.level)
		owned.level += 1
		leveled = true
	end
	if leveled then
		notifyEvent:FireClient(player, ("🐾 %s reached bond level %d!"):format(c.name, owned.level), "gold")
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.RecomputeStats(player)
		sync(player)
	end
end

function CompanionService.Start()
	local buyEvent = Net.Event("BuyCompanion")
	local setEvent = Net.Event("SetCompanion")
	buyEvent.OnServerEvent:Connect(function(player, id) CompanionService.Buy(player, id) end)
	setEvent.OnServerEvent:Connect(function(player, id) CompanionService.SetActive(player, id) end)
	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.8); sync(player)
	end)
end

return CompanionService
