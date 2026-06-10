--!strict
-- ShopService.lua
-- Buy items from the shop, use consumables from inventory.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local ItemData = require(GameData:WaitForChild("ItemData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager = require(script.Parent.DataManager)

local ShopService = {}

local notifyEvent    = Net.Event("Notify")
local inventorySync  = Net.Event("InventorySync")

local function syncInventory(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	inventorySync:FireClient(player, profile.inventory)
end

local function applyEffects(player: Player, item: any)
	local profile = DataManager.Get(player)
	if not profile then return end

	for _, eff in ipairs(item.effects) do
		local kind = eff.kind :: string
		if kind == "heal_pct" then
			local maxHP = (player:GetAttribute("MaxHP") or 100) :: number
			local hp    = (player:GetAttribute("HP")    or 0)   :: number
			local heal  = maxHP * (eff.value / 100)
			player:SetAttribute("HP", math.min(maxHP, hp + heal))

		elseif kind == "qi_pct" then
			-- QI not yet implemented; ignore

		elseif kind == "exp_flat" then
			local CultivationService = require(script.Parent.CultivationService)
			CultivationService.AddEXP(player, eff.value, true)

		elseif kind == "stones" then
			local CultivationService = require(script.Parent.CultivationService)
			CultivationService.AddStones(player, eff.value)

		elseif kind == "life" then
			profile.bonusLifespan = (profile.bonusLifespan or 0) + eff.value
			local CultivationService = require(script.Parent.CultivationService)
			CultivationService.RecomputeStats(player)

		elseif kind == "exp_buff" then
			Buffs.Apply(player, "Exp", eff.mult, eff.duration)
			notifyEvent:FireClient(player, ("⚡ EXP ×%.1f active for %ds!"):format(eff.mult, eff.duration), "gold")

		elseif kind == "dmg_pct" then
			-- Permanent equipment bonus — not yet stacking; ignore for consumables
		end
	end
end

-- Give item to player inventory (used by QuestService/admin)
function ShopService.GiveItem(player: Player, itemId: number, count: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.inventory[itemId] = (profile.inventory[itemId] or 0) + (count or 1)
	syncInventory(player)
end

function ShopService.Buy(player: Player, itemIdRaw: any)
	local itemId = tonumber(itemIdRaw)
	if not itemId then return end
	local item = ItemData.GetItem(itemId)
	if not item or not ItemData.IsBuyable(item) then
		notifyEvent:FireClient(player, "This item cannot be purchased.", "warn")
		return
	end

	local profile = DataManager.Get(player)
	if not profile then return end

	-- Realm-Gate: hochstufige Ware schaltet erst mit dem passenden Realm frei.
	if ItemData.UnlockRealm(item) > (profile.realm or 1) then
		notifyEvent:FireClient(player, "This item unlocks at a higher realm.", "warn")
		return
	end

	if profile.spiritStones < item.cost then
		notifyEvent:FireClient(player, "Not enough Spirit Stones.", "warn")
		return
	end

	local curStack = profile.inventory[itemId] or 0
	if curStack >= item.stack then
		notifyEvent:FireClient(player, "Stack full.", "warn")
		return
	end

	profile.spiritStones -= item.cost
	profile.inventory[itemId] = curStack + 1
	player:SetAttribute("SpiritStones", profile.spiritStones)
	notifyEvent:FireClient(player, ("Bought: %s"):format(item.name), "green")
	syncInventory(player)
end

function ShopService.Use(player: Player, itemIdRaw: any)
	local itemId = tonumber(itemIdRaw)
	if not itemId then return end
	local item = ItemData.GetItem(itemId)
	if not item or not ItemData.IsUsable(item) then
		notifyEvent:FireClient(player, "This item cannot be used.", "warn")
		return
	end

	local profile = DataManager.Get(player)
	if not profile then return end
	if (profile.inventory[itemId] or 0) <= 0 then
		notifyEvent:FireClient(player, "Item not in inventory.", "warn")
		return
	end

	profile.inventory[itemId] -= 1
	if profile.inventory[itemId] <= 0 then profile.inventory[itemId] = nil end
	applyEffects(player, item)
	notifyEvent:FireClient(player, ("Used: %s"):format(item.name), "green")
	syncInventory(player)
end

function ShopService.Start()
	local buyEvent = Net.Event("BuyItem")
	local useEvent = Net.Event("UseItem")

	buyEvent.OnServerEvent:Connect(function(player, itemId)
		ShopService.Buy(player, itemId)
	end)
	useEvent.OnServerEvent:Connect(function(player, itemId)
		ShopService.Use(player, itemId)
	end)

	-- Send inventory on join
	local DataManager_ = DataManager
	DataManager_.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.5)
		syncInventory(player)
	end)
end

return ShopService
