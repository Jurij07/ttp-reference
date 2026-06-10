--!strict
-- EquipmentService.lua
-- Paperdoll equipment: weapon, head, body, legs, feet, necklace, ring.
-- Equipping moves an item from the inventory into a slot; its stat effects
-- (dmg_pct / def_pct / hp_pct) fold into RecomputeStats.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local ItemData = require(GameData:WaitForChild("ItemData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local EquipmentService = {}

local notifyEvent     = Net.Event("Notify")
local equipSyncEvent  = Net.Event("EquipmentSync")
local inventorySync   = Net.Event("InventorySync")

EquipmentService.SLOTS = { "weapon", "head", "body", "legs", "feet", "necklace", "ring" }

local function syncInventory(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	inventorySync:FireClient(player, profile.inventory)
end

local function syncEquipment(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	equipSyncEvent:FireClient(player, profile.equipment)
end
EquipmentService.Sync = syncEquipment

-- Aggregierte Ausrüstungs-Boni (additive Prozent → Multiplikatoren).
function EquipmentService.GetBonuses(player: Player): { hp: number, dmg: number, def: number }
	local profile = DataManager.Get(player)
	local hp, dmg, def = 0, 0, 0
	if profile and profile.equipment then
		for _, slot in ipairs(EquipmentService.SLOTS) do
			local itemId = profile.equipment[slot]
			if itemId then
				local item = ItemData.GetItem(itemId)
				if item then
					for _, eff in ipairs(item.effects) do
						if eff.kind == "hp_pct"  then hp  += (eff.value or 0) end
						if eff.kind == "dmg_pct" then dmg += (eff.value or 0) end
						if eff.kind == "def_pct" then def += (eff.value or 0) end
					end
				end
			end
		end
	end
	return { hp = 1 + hp/100, dmg = 1 + dmg/100, def = 1 + def/100 }
end

function EquipmentService.Equip(player: Player, itemIdRaw: any)
	local itemId = tonumber(itemIdRaw)
	if not itemId then return end
	local item = ItemData.GetItem(itemId)
	if not item or not ItemData.IsEquippable(item) then
		notifyEvent:FireClient(player, "This item cannot be equipped.", "warn")
		return
	end

	local profile = DataManager.Get(player)
	if not profile then return end
	if (profile.inventory[itemId] or 0) <= 0 then
		notifyEvent:FireClient(player, "Item not in inventory.", "warn")
		return
	end

	local slot = item.slot :: string
	-- Vorhandenes Item im Slot zurück ins Inventar.
	local prev = profile.equipment[slot]
	if prev then
		profile.inventory[prev] = (profile.inventory[prev] or 0) + 1
	end

	-- Item aus Inventar entfernen und anlegen.
	profile.inventory[itemId] -= 1
	if profile.inventory[itemId] <= 0 then profile.inventory[itemId] = nil end
	profile.equipment[slot] = itemId

	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	notifyEvent:FireClient(player, ("Equipped: %s"):format(item.name), "green")
	syncInventory(player)
	syncEquipment(player)
end

function EquipmentService.Unequip(player: Player, slotRaw: any)
	local slot = tostring(slotRaw)
	local profile = DataManager.Get(player)
	if not profile or not profile.equipment then return end
	local itemId = profile.equipment[slot]
	if not itemId then return end

	profile.equipment[slot] = nil
	profile.inventory[itemId] = (profile.inventory[itemId] or 0) + 1

	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	local item = ItemData.GetItem(itemId)
	notifyEvent:FireClient(player, ("Unequipped: %s"):format(item and item.name or "item"), "info")
	syncInventory(player)
	syncEquipment(player)
end

function EquipmentService.Start()
	local equipEvent   = Net.Event("EquipItem")
	local unequipEvent = Net.Event("UnequipItem")

	equipEvent.OnServerEvent:Connect(function(player, itemId)
		EquipmentService.Equip(player, itemId)
	end)
	unequipEvent.OnServerEvent:Connect(function(player, slot)
		EquipmentService.Unequip(player, slot)
	end)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.7)
		syncEquipment(player)
	end)
end

return EquipmentService
