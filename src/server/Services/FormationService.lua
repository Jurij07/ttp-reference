--!strict
-- FormationService.lua
-- Formations grant passive stat multipliers. Buy/unlock them, then set one
-- active at a time. Its bonus folds into RecomputeStats via GetActiveBonus.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local FormationData = require(GameData:WaitForChild("FormationData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local FormationService = {}

local notifyEvent = Net.Event("Notify")
local syncEvent   = Net.Event("FormationSync")

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	syncEvent:FireClient(player, {
		owned = profile.ownedFormations,
		active = profile.activeFormation,
	})
	local f = profile.activeFormation and FormationData.Get(profile.activeFormation)
	player:SetAttribute("FormationName", f and f.name or "")
end
FormationService.Sync = sync

function FormationService.GetActiveBonus(player: Player): { dmg: number, def: number, hp: number, exp: number }
	local profile = DataManager.Get(player)
	local none = { dmg=1, def=1, hp=1, exp=1 }
	if not profile or not profile.activeFormation then return none end
	local f = FormationData.Get(profile.activeFormation)
	if not f or not profile.ownedFormations[profile.activeFormation] then return none end
	return { dmg=f.dmgMult, def=f.defMult, hp=f.hpMult, exp=f.expMult }
end

function FormationService.Buy(player: Player, idRaw: any)
	local id = tostring(idRaw)
	local f = FormationData.Get(id)
	if not f then return end
	local profile = DataManager.Get(player)
	if not profile then return end
	if profile.ownedFormations[id] then
		notifyEvent:FireClient(player, "Formation already learned.", "warn")
		return
	end
	if profile.realm < f.reqRealm then
		notifyEvent:FireClient(player, ("Requires Realm %d."):format(f.reqRealm), "warn")
		return
	end
	-- Sect-locked formations
	if f.unlock ~= "Buy" and f.unlock ~= "Standard" then
		if profile.sectId ~= f.unlock then
			notifyEvent:FireClient(player, "Locked — requires the matching sect.", "warn")
			return
		end
	end
	if f.cost > 0 then
		if profile.spiritStones < f.cost then
			notifyEvent:FireClient(player, "Not enough Spirit Stones.", "warn")
			return
		end
		profile.spiritStones -= f.cost
		player:SetAttribute("SpiritStones", profile.spiritStones)
	end
	profile.ownedFormations[id] = true
	notifyEvent:FireClient(player, ("⭕ Learned formation: %s!"):format(f.name), "gold")
	sync(player)
end

function FormationService.SetActive(player: Player, idRaw: any)
	local id = tostring(idRaw)
	local profile = DataManager.Get(player)
	if not profile or not profile.ownedFormations[id] then return end
	profile.activeFormation = id
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	local f = FormationData.Get(id)
	notifyEvent:FireClient(player, ("⭕ %s activated."):format(f and f.name or "Formation"), "info")
	sync(player)
end

function FormationService.Start()
	local buyEvent = Net.Event("BuyFormation")
	local setEvent = Net.Event("SetFormation")
	buyEvent.OnServerEvent:Connect(function(player, id) FormationService.Buy(player, id) end)
	setEvent.OnServerEvent:Connect(function(player, id) FormationService.SetActive(player, id) end)
	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.85); sync(player)
	end)
end

return FormationService
