--!strict
-- DataManager.lua
-- Lädt, hält und speichert die Spielerdaten. Nutzt DataStore mit sicherem
-- Fallback auf In-Memory (z.B. wenn in Studio "API Services" nicht aktiv sind),
-- damit das Spiel IMMER startet — auch ohne DataStore-Zugriff.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local DataManager = {}

-- Geladene Profile, Schlüssel = UserId.
local profiles: { [number]: any } = {}

-- Signal, das nach erfolgreichem Laden eines Profils feuert.
local profileLoadedBindable = Instance.new("BindableEvent")
DataManager.ProfileLoaded = profileLoadedBindable.Event

-- DataStore-Handle (kann nil sein, wenn API-Zugriff fehlt).
local store: DataStore? = nil

-- ── Standard-Profil für neue Spieler ───────────────────────
local function defaultProfile(): any
	return {
		version = 1,
		providence = nil, -- { aptitude, physique, connate, dao } — wird beim 1. Join gerollt
		rerolls = {
			aptitude = Config.FREE_REROLLS_PER_ATTRIBUTE,
			physique = Config.FREE_REROLLS_PER_ATTRIBUTE,
			connate = Config.FREE_REROLLS_PER_ATTRIBUTE,
			dao = Config.FREE_REROLLS_PER_ATTRIBUTE,
		},
		realm = 1,
		stage = 1,
		exp = 0,
		spiritStones = Config.STARTING_SPIRIT_STONES,
		karma = Config.STARTING_KARMA,
		lifespanUsed = 0, -- bereits vergangene Lebensjahre
		totalKills = 0,
		inventory = {},
		quests = {},
	}
end

-- Fügt fehlende Standard-Felder zu einem geladenen Profil hinzu (Migration).
local function reconcile(profile: any)
	local defaults = defaultProfile()
	for key, value in pairs(defaults) do
		if profile[key] == nil then
			profile[key] = value
		end
	end
	if typeof(profile.rerolls) == "table" then
		for key, value in pairs(defaults.rerolls) do
			if profile.rerolls[key] == nil then
				profile.rerolls[key] = value
			end
		end
	end
end

local function keyFor(userId: number): string
	return "player_" .. tostring(userId)
end

-- Lädt das Profil eines Spielers (oder erzeugt ein neues).
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
			warn(("[DataManager] Laden fehlgeschlagen für %s, nutze Standardprofil: %s"):format(player.Name, tostring(result)))
		end
	end

	profiles[player.UserId] = profile
	profileLoadedBindable:Fire(player)
end

-- Speichert das Profil eines Spielers.
function DataManager.Save(player: Player)
	local profile = profiles[player.UserId]
	if not profile then
		return
	end
	if not (store and Config.USE_DATASTORE) then
		return -- In-Memory-Modus: nichts zu tun
	end
	local ok, err = pcall(function()
		store:SetAsync(keyFor(player.UserId), profile)
	end)
	if not ok then
		warn(("[DataManager] Speichern fehlgeschlagen für %s: %s"):format(player.Name, tostring(err)))
	end
end

-- Gibt das geladene Profil zurück (oder nil, falls noch nicht geladen).
function DataManager.Get(player: Player): any
	return profiles[player.UserId]
end

function DataManager.IsLoaded(player: Player): boolean
	return profiles[player.UserId] ~= nil
end

-- Startet den Service: DataStore holen, Player-Events verbinden, Autosave-Loop.
function DataManager.Start()
	if Config.USE_DATASTORE then
		local ok, result = pcall(function()
			return DataStoreService:GetDataStore(Config.DATASTORE_NAME)
		end)
		if ok then
			store = result
		else
			warn("[DataManager] Kein DataStore-Zugriff — laufe im In-Memory-Modus. " ..
				"(In Studio: Game Settings → Security → 'Enable Studio Access to API Services')")
		end
	end

	Players.PlayerAdded:Connect(loadProfile)
	Players.PlayerRemoving:Connect(function(player)
		DataManager.Save(player)
		profiles[player.UserId] = nil
	end)

	-- Falls beim Start (Live-Sync) schon Spieler da sind.
	for _, player in ipairs(Players:GetPlayers()) do
		if not profiles[player.UserId] then
			task.spawn(loadProfile, player)
		end
	end

	-- Autosave-Loop.
	task.spawn(function()
		while true do
			task.wait(Config.AUTOSAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				DataManager.Save(player)
			end
		end
	end)

	-- Beim Server-Shutdown alles speichern.
	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.Save(player)
		end
	end)
end

return DataManager
