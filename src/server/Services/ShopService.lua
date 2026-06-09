--!strict
-- ShopService.lua
-- Kauf & Nutzung von Pillen/Elixieren. Gekaufte Items landen im Inventar
-- (profile.inventory[itemId] = Anzahl). Der Client erhält das Inventar über
-- das RemoteEvent "InventorySync". Effekte siehe ShopData.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local ShopData = require(GameData:WaitForChild("ShopData"))
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local Net    = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs  = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager = require(script.Parent.DataManager)

local ShopService = {}

local notifyEvent    = Net.Event("Notify")
local inventorySync  = Net.Event("InventorySync")

local function ensureInventory(profile: any)
	if type(profile.inventory) ~= "table" then profile.inventory = {} end
end

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	ensureInventory(profile)
	inventorySync:FireClient(player, profile.inventory)
end
ShopService.Sync = sync

-- Fügt dem Inventar ein Item hinzu (z.B. Quest-Belohnung).
function ShopService.GiveItem(player: Player, itemId: string, count: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	ensureInventory(profile)
	profile.inventory[itemId] = (profile.inventory[itemId] or 0) + count
	sync(player)
end

-- Kauf eines Items (zieht Spirit Stones ab, legt es ins Inventar).
function ShopService.Buy(player: Player, itemId: string): (boolean, string)
	local profile = DataManager.Get(player)
	if not profile then return false, "Kein Profil." end
	if player:GetAttribute("InMenu") then return false, "Nicht im Startmenü." end

	local item = ShopData.GetItem(itemId)
	if not item then return false, "Unbekanntes Item." end
	if profile.spiritStones < item.price then
		return false, "Nicht genug Spirit Stones."
	end

	profile.spiritStones -= item.price
	player:SetAttribute("SpiritStones", profile.spiritStones)
	ShopService.GiveItem(player, itemId, 1)
	notifyEvent:FireClient(player, ("🛒 %s gekauft (−%d Stones)."):format(item.name, item.price), "good")
	return true, "OK"
end

-- Wendet den Effekt eines Items an.
local function applyEffect(player: Player, item: any): (boolean, string)
	local profile = DataManager.Get(player)
	if not profile then return false, "Kein Profil." end
	local CultivationService = require(script.Parent.CultivationService)

	if item.effect == "exp_instant" then
		local stageEXP = CultivationData.GetStageEXP(profile.realm, profile.stage)
		CultivationService.AddEXP(player, stageEXP * (item.param or 1))
		return true, ("⚡ %s: EXP erhalten!"):format(item.name)

	elseif item.effect == "exp_fill" then
		local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
		local missing = math.max(0, needed - profile.exp)
		-- +1 EXP, damit die Stage sicher überschritten wird (Boss-Gate greift trotzdem).
		CultivationService.AddEXP(player, missing + 1)
		return true, ("⚡ %s: Stage aufgefüllt!"):format(item.name)

	elseif item.effect == "buff_exp" then
		Buffs.Apply(player, "Exp", item.mult or 2, item.duration or 300)
		return true, ("🌀 %s aktiv: EXP ×%.1f"):format(item.name, item.mult or 2)

	elseif item.effect == "buff_dmg" then
		Buffs.Apply(player, "Dmg", item.mult or 2, item.duration or 180)
		return true, ("🔴 %s aktiv: Schaden ×%.1f"):format(item.name, item.mult or 2)

	elseif item.effect == "heal" then
		player:SetAttribute("HP", player:GetAttribute("MaxHP") or 1)
		return true, ("💊 %s: voll geheilt!"):format(item.name)

	elseif item.effect == "age_reduce" then
		-- Nicht unter das Startalter (18) verjüngen.
		profile.age = math.max(18, profile.age - (item.param or 0))
		player:SetAttribute("Age", math.floor(profile.age))
		return true, ("🍃 %s: −%d Jahre!"):format(item.name, item.param or 0)
	end

	return false, "Unbekannter Effekt."
end

-- Item aus dem Inventar verwenden.
function ShopService.Use(player: Player, itemId: string): (boolean, string)
	local profile = DataManager.Get(player)
	if not profile then return false, "Kein Profil." end
	if player:GetAttribute("InMenu") then return false, "Nicht im Startmenü." end
	if player:GetAttribute("InSeclusion") then return false, "Nicht während der Klausur." end
	ensureInventory(profile)

	local count = profile.inventory[itemId] or 0
	if count <= 0 then return false, "Item nicht im Inventar." end

	local item = ShopData.GetItem(itemId)
	if not item then return false, "Unbekanntes Item." end

	local ok, msg = applyEffect(player, item)
	if not ok then return false, msg end

	profile.inventory[itemId] = count - 1
	if profile.inventory[itemId] <= 0 then profile.inventory[itemId] = nil end
	sync(player)
	notifyEvent:FireClient(player, msg, "good")
	return true, "OK"
end

function ShopService.Start()
	-- InventorySync wird bereits beim Modul-Laden erstellt (siehe oben).
	DataManager.ProfileLoaded:Connect(function(player)
		sync(player)
	end)

	local buyEvent = Net.Event("BuyItem")
	buyEvent.OnServerEvent:Connect(function(player, itemId)
		local ok, msg = ShopService.Buy(player, tostring(itemId))
		buyEvent:FireClient(player, ok, msg)
	end)

	local useEvent = Net.Event("UseItem")
	useEvent.OnServerEvent:Connect(function(player, itemId)
		local ok, msg = ShopService.Use(player, tostring(itemId))
		useEvent:FireClient(player, ok, msg)
	end)
end

return ShopService
