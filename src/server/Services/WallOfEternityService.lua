--!strict
-- WallOfEternityService.lua
-- Records every player who reaches Realm 26 on a server-wide DataStore. New
-- entries are announced to all players and pushed to the Wall of Eternity
-- SurfaceGui in the Spawn Village.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local WallOfEternityService = {}

local serverAnnounce = Net.Event("ServerAnnounce")
local wallEvent      = Net.Event("WallOfEternity")

local STORE_NAME = "WallOfEternity_v1"
local KEY = "entries"

local store: DataStore? = nil
local entries: { { name: string, date: string, realm: number } } = {}

local function loadEntries()
	if not (store and Config.USE_DATASTORE) then return end
	local ok, result = pcall(function() return store:GetAsync(KEY) end)
	if ok and typeof(result) == "table" then
		entries = result :: any
	end
end

local function saveEntries()
	if not (store and Config.USE_DATASTORE) then return end
	pcall(function() store:SetAsync(KEY, entries) end)
end

local function pushToClient(player: Player)
	wallEvent:FireClient(player, entries)
end

function WallOfEternityService.AddPlayer(player: Player)
	for _, e in ipairs(entries) do
		if e.name == player.Name then return end
	end
	table.insert(entries, { name = player.Name, date = os.date("!%Y-%m-%d", os.time()), realm = 26 })
	saveEntries()
	for _, p in ipairs(Players:GetPlayers()) do
		serverAnnounce:FireClient(p, ("✨ %s has reached R26 — Ultimate Origin Supreme!"):format(player.Name))
		pushToClient(p)
	end
end

local function checkPlayer(player: Player)
	local realm = (player:GetAttribute("Realm") or 1) :: number
	local profile = DataManager.Get(player)
	if realm >= 26 and profile and not profile.wallOfEternityAdded then
		profile.wallOfEternityAdded = true
		WallOfEternityService.AddPlayer(player)
	end
end

function WallOfEternityService.Start()
	if Config.USE_DATASTORE then
		local ok, result = pcall(function() return DataStoreService:GetDataStore(STORE_NAME) end)
		if ok then store = result end
	end
	loadEntries()

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(1.0)
		pushToClient(player)
		checkPlayer(player)
		player:GetAttributeChangedSignal("Realm"):Connect(function() checkPlayer(player) end)
	end)
end

return WallOfEternityService
