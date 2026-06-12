--!strict
-- TechniqueMasteryService.lua
-- Makes the entire technique catalog learnable. Players spend spirit stones
-- to learn techniques (realm-gated, providence-gated); learned passives feed
-- multipliers into CultivationService, learned actives can be equipped onto
-- the [Q] slot (consumed by TechniqueService).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local TechniqueCatalog = require(GameData:WaitForChild("TechniqueCatalog"))
local TechniqueMasteryData = require(GameData:WaitForChild("TechniqueMasteryData"))

local DataManager = require(script.Parent.DataManager)

local TechniqueMasteryService = {}

local notifyEvent = Net.Event("Notify")

local function known(profile: any): { [string]: boolean }
	if type(profile.techniques) ~= "table" then profile.techniques = {} end
	return profile.techniques
end

local function countKnown(profile: any): number
	local n = 0
	for _ in pairs(known(profile)) do n += 1 end
	return n
end

-- Aggregated passive bonuses from every learned technique.
function TechniqueMasteryService.GetBonuses(player: Player): { hp: number, dmg: number, def: number, exp: number, stones: number }
	local out = { hp = 0, dmg = 0, def = 0, exp = 0, stones = 0 }
	local profile = DataManager.Get(player)
	if not profile then return out end
	for id in pairs(known(profile)) do
		local e = TechniqueMasteryData.Get(id)
		if e then
			out.hp += e.hp or 0
			out.dmg += e.dmg or 0
			out.def += e.def or 0
			out.exp += e.exp or 0
			out.stones += e.stones or 0
		end
	end
	return out
end

-- The equipped active technique (id) or nil.
function TechniqueMasteryService.GetEquipped(player: Player): string?
	local profile = DataManager.Get(player)
	if not profile then return nil end
	local id = profile.activeTechnique
	if type(id) == "string" and known(profile)[id] and TechniqueMasteryData.IsActive(id) then
		return id
	end
	return nil
end

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	Net.Event("TechniqueMasterySync"):FireClient(player, known(profile), profile.activeTechnique)
	player:SetAttribute("TechniquesKnown", countKnown(profile))
end

-- Grant auto-unlock techniques + dao starter for free.
local function grantFreebies(player: Player, profile: any)
	local k = known(profile)
	local changed = false
	for _, entry in ipairs(TechniqueCatalog.ENTRIES) do
		if entry.autoUnlock and not k[entry.id] then
			k[entry.id] = true
			changed = true
		end
	end
	if changed then sync(player) end
end

function TechniqueMasteryService.Start()
	Net.Event("TechniqueMasterySync")

	Net.Event("LearnTechnique").OnServerEvent:Connect(function(player: Player, idRaw: unknown)
		local id = tostring(idRaw)
		local entry = TechniqueCatalog.Get(id)
		if not entry then return end
		local profile = DataManager.Get(player)
		if not profile then return end
		local k = known(profile)
		if k[id] then
			notifyEvent:FireClient(player, "Technique already mastered.", "warn"); return
		end
		if (profile.realm or 1) < entry.realm then
			notifyEvent:FireClient(player, ("🔒 Requires Realm %d."):format(entry.realm), "warn"); return
		end
		-- Providence gates (e.g. Lone Star fate techniques).
		if entry.reqProvidence then
			local prov = profile.providence
			local connate = prov and prov.connate and prov.connate.name
			local apt = prov and prov.aptitude and prov.aptitude.name
			if connate ~= entry.reqProvidence and apt ~= entry.reqProvidence then
				notifyEvent:FireClient(player, ("🔒 Requires providence: %s."):format(entry.reqProvidence :: string), "warn")
				return
			end
		end
		local cost = TechniqueMasteryData.LearnCost(id, entry.realm)
		if (profile.spiritStones or 0) < cost then
			notifyEvent:FireClient(player, ("💰 Need %d Spirit Stones."):format(cost), "warn"); return
		end
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.AddStones(player, -cost)
		k[id] = true
		notifyEvent:FireClient(player, ("📘 Technique mastered: %s!"):format(entry.name), "gold")
		CultivationService.RecomputeStats(player)
		sync(player)
	end)

	Net.Event("EquipTechnique").OnServerEvent:Connect(function(player: Player, idRaw: unknown)
		local id = tostring(idRaw)
		local profile = DataManager.Get(player)
		if not profile then return end
		if not known(profile)[id] or not TechniqueMasteryData.IsActive(id) then return end
		profile.activeTechnique = id
		local entry = TechniqueCatalog.Get(id)
		notifyEvent:FireClient(player, ("⚔️ [Q] technique set: %s"):format(entry and entry.name or id), "good")
		sync(player)
	end)

	Net.Event("GetTechniques").OnServerEvent:Connect(sync)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.delay(2, function()
			if not player.Parent then return end
			local profile = DataManager.Get(player)
			if profile then
				grantFreebies(player, profile)
				sync(player)
			end
		end)
	end)

	print("[TechniqueMasteryService] Started — full 59-technique catalog learnable.")
end

return TechniqueMasteryService
