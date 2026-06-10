--!strict
-- DungeonService.lua
-- Entering a dungeon sets an EXP/Stone multiplier (DungeonMult attributes that
-- CombatService reads) for a limited number of floors. Each floor is cleared by
-- defeating enough foes; a boss-style surge happens every 5 kills. Leaving (or
-- clearing all floors) starts the cooldown.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local DungeonData = require(GameData:WaitForChild("DungeonData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local DungeonService = {}

local notifyEvent = Net.Event("Notify")
local syncEvent   = Net.Event("DungeonSync")

-- runtime state per player (not persisted): dungeonId, floor, killsThisFloor, killsTotal
local active: { [number]: { id: string, floor: number, kills: number } } = {}
-- cooldown end times: [userId][dungeonId] = os.time
local cooldowns: { [number]: { [string]: number } } = {}

local KILLS_PER_FLOOR = 5

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local st = active[player.UserId]
	local cds = {}
	for id, t in pairs(cooldowns[player.UserId] or {}) do
		cds[id] = math.max(0, t - os.time())
	end
	syncEvent:FireClient(player, {
		active = st and { id = st.id, floor = st.floor, kills = st.kills } or nil,
		cooldowns = cds,
	})
end
DungeonService.Sync = sync

function DungeonService.IsInDungeon(player: Player): boolean
	return active[player.UserId] ~= nil
end

function DungeonService.GetMultipliers(player: Player): (number, number)
	local st = active[player.UserId]
	if not st then return 1, 1 end
	local d = DungeonData.Get(st.id)
	if not d then return 1, 1 end
	return d.expMult, d.stoneMult
end

function DungeonService.Enter(player: Player, idRaw: any)
	local id = tostring(idRaw)
	local d = DungeonData.Get(id)
	if not d then return end
	local profile = DataManager.Get(player)
	if not profile then return end
	if active[player.UserId] then
		notifyEvent:FireClient(player, "You are already in a dungeon.", "warn")
		return
	end
	if profile.realm < d.reqRealm then
		notifyEvent:FireClient(player, ("Requires Realm %d."):format(d.reqRealm), "warn")
		return
	end
	local cd = (cooldowns[player.UserId] or {})[id] or 0
	if os.time() < cd then
		notifyEvent:FireClient(player, ("On cooldown: %d min left."):format(math.ceil((cd - os.time())/60)), "warn")
		return
	end

	active[player.UserId] = { id = id, floor = 1, kills = 0 }
	player:SetAttribute("InDungeon", true)
	player:SetAttribute("DungeonName", d.name)
	player:SetAttribute("DungeonFloor", 1)
	notifyEvent:FireClient(player, ("🗺️ Entered %s — Floor 1/%d (EXP ×%.1f)"):format(d.name, d.floors, d.expMult), "gold")
	sync(player)
end

-- Called by CombatService after a kill while in a dungeon.
function DungeonService.OnKill(player: Player)
	local st = active[player.UserId]
	if not st then return end
	local d = DungeonData.Get(st.id)
	if not d then return end
	st.kills += 1
	if st.kills >= KILLS_PER_FLOOR then
		st.kills = 0
		if st.floor >= d.floors then
			-- cleared!
			local stones = math.floor(1000 * d.stoneMult * d.floors)
			local CultivationService = require(script.Parent.CultivationService)
			CultivationService.AddStones(player, stones)
			notifyEvent:FireClient(player, ("🏆 Cleared %s! Bonus +%d 💰. Loot: %s"):format(d.name, stones, d.loot[math.random(#d.loot)]), "gold")
			DungeonService.Exit(player, true)
			return
		else
			st.floor += 1
			player:SetAttribute("DungeonFloor", st.floor)
			notifyEvent:FireClient(player, ("🗺️ Floor %d/%d — a boss-beast surges forth!"):format(st.floor, d.floors), "info")
		end
	end
	sync(player)
end

function DungeonService.Exit(player: Player, cleared: boolean?)
	local st = active[player.UserId]
	if not st then return end
	local d = DungeonData.Get(st.id)
	active[player.UserId] = nil
	player:SetAttribute("InDungeon", false)
	player:SetAttribute("DungeonName", "")
	player:SetAttribute("DungeonFloor", 0)
	if d then
		cooldowns[player.UserId] = cooldowns[player.UserId] or {}
		cooldowns[player.UserId][st.id] = os.time() + d.cooldownSec
		if not cleared then
			notifyEvent:FireClient(player, ("Left %s. Cooldown started."):format(d.name), "info")
		end
	end
	sync(player)
end

function DungeonService.Start()
	local enterEvent = Net.Event("EnterDungeon")
	local exitEvent  = Net.Event("ExitDungeon")
	enterEvent.OnServerEvent:Connect(function(player, id) DungeonService.Enter(player, id) end)
	exitEvent.OnServerEvent:Connect(function(player) DungeonService.Exit(player, false) end)

	Players.PlayerRemoving:Connect(function(player)
		active[player.UserId] = nil
		cooldowns[player.UserId] = nil
	end)
	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.95); sync(player)
	end)
end

return DungeonService
