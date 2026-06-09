--!strict
-- DataManager.lua
-- Lädt / hält / speichert Spielerdaten. DataStore mit In-Memory-Fallback.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local DataManager = {}

local profiles: { [number]: any } = {}
local profileLoadedBindable = Instance.new("BindableEvent")
DataManager.ProfileLoaded = profileLoadedBindable.Event

local store: DataStore? = nil

-- ── Standard-Profil ────────────────────────────────────────
local function defaultProfile(): any
	return {
		version = 4,
		providence = nil,
		providenceConfirmed = false,
		rerolls = {
			aptitude = Config.FREE_REROLLS_PER_ATTR,
			physique  = Config.FREE_REROLLS_PER_ATTR,
			connate   = Config.FREE_REROLLS_PER_ATTR,
			dao       = Config.FREE_REROLLS_PER_ATTR,
		},
		realm          = 1,
		stage          = 1,
		exp            = 0,
		spiritStones   = Config.STARTING_SPIRIT_STONES,
		karma          = Config.STARTING_KARMA,
		age            = Config.STARTING_AGE,
		bonusLifespan  = 0,
		totalKills     = 0,
		bossesKilled   = {},
		inventory      = {},
		quests         = {},
	}
end

-- Migration: fehlende Felder ergänzen und alte Struktur (freeRerolls als Zahl) umwandeln.
local function reconcile(profile: any)
	local defaults = defaultProfile()
	for key, value in pairs(defaults) do
		if profile[key] == nil then
			profile[key] = value
		end
	end
	if type(profile.rerolls) ~= "table" then
		local old = type(profile.freeRerolls) == "number" and profile.freeRerolls or Config.FREE_REROLLS_PER_ATTR
		profile.rerolls = {
			aptitude = math.min(old, Config.FREE_REROLLS_PER_ATTR),
			physique  = Config.FREE_REROLLS_PER_ATTR,
			connate   = Config.FREE_REROLLS_PER_ATTR,
			dao       = Config.FREE_REROLLS_PER_ATTR,
		}
		profile.freeRerolls = nil
	end
	if type(profile.bossesKilled) ~= "table" then profile.bossesKilled = {} end
	if type(profile.bonusLifespan) ~= "number" then profile.bonusLifespan = 0 end
end

local function keyFor(userId: number): string
	return "player_" .. tostring(userId)
end

local function loadProfile(player: Player)
	local profile = defaultProfile()
	if store and Config.USE_DATASTORE then
		local ok, result = pcall(function()
			return store:GetAsync(keyFor(player.UserId))
		end)
		if ok and typeof(result) == "table" then
			profile = result
			reconcile(profile)
		elseif not ok then
			warn(("[DataManager] Laden fehlgeschlagen für %s: %s"):format(player.Name, tostring(result)))
		end
	end
	profiles[player.UserId] = profile
	profileLoadedBindable:Fire(player)
end

function DataManager.Save(player: Player)
	local profile = profiles[player.UserId]
	if not profile or not (store and Config.USE_DATASTORE) then return end
	local ok, err = pcall(function()
		store:SetAsync(keyFor(player.UserId), profile)
	end)
	if not ok then
		warn(("[DataManager] Speichern fehlgeschlagen für %s: %s"):format(player.Name, tostring(err)))
	end
end

function DataManager.Get(player: Player): any
	return profiles[player.UserId]
end

function DataManager.IsLoaded(player: Player): boolean
	return profiles[player.UserId] ~= nil
end

function DataManager.Start()
	if Config.USE_DATASTORE then
		local ok, result = pcall(function()
			return DataStoreService:GetDataStore(Config.DATASTORE_NAME)
		end)
		if ok then store = result
		else warn("[DataManager] Kein DataStore — In-Memory-Modus. (Studio: Game Settings → Security → Enable API Services)") end
	end

	Players.PlayerAdded:Connect(loadProfile)
	Players.PlayerRemoving:Connect(function(player)
		DataManager.Save(player)
		profiles[player.UserId] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		if not profiles[player.UserId] then
			task.spawn(loadProfile, player)
		end
	end

	task.spawn(function()
		while true do
			task.wait(Config.AUTOSAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				DataManager.Save(player)
			end
		end
	end)

	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.Save(player)
		end
	end)
end

return DataManager
