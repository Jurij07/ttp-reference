--!strict
-- WorldData.lua
-- Single source of truth for the world layout. Each implemented realm gets its
-- own themed zone arranged in a ring around the central hub. TerrainGenerator,
-- NPCService and the client teleport all read these positions so everything
-- lines up.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CultivationData = require(script.Parent:WaitForChild("CultivationData"))
local NPCData = require(script.Parent:WaitForChild("NPCData"))

local WorldData = {}

WorldData.HUB_CENTER   = Vector3.new(0, 4, 0)
WorldData.HUB_RADIUS   = 46
WorldData.RING_RADIUS  = 300      -- distance from hub to each zone centre
WorldData.ZONE_RADIUS  = 62       -- platform radius of each realm zone
WorldData.ZONE_HEIGHT  = 4        -- platform thickness

-- Per-realm theme: floor + accent colour + a short flavour name.
-- Falls back to the realm's own colour from CultivationData.
local THEMES: { [number]: { floor: Color3, accent: Color3, name: string } } = {
	[1] = { floor = Color3.fromRGB(186,235,210), accent = Color3.fromRGB(120,220,150), name = "Qi Meadow" },
	[2] = { floor = Color3.fromRGB(200,225,255), accent = Color3.fromRGB(120,180,255), name = "Foundation Cliffs" },
	[3] = { floor = Color3.fromRGB(255,235,170), accent = Color3.fromRGB(245,200,80),  name = "Golden Pagoda Grounds" },
	[4] = { floor = Color3.fromRGB(210,190,255), accent = Color3.fromRGB(170,120,255), name = "Nascent Soul Vale" },
	[5] = { floor = Color3.fromRGB(180,255,235), accent = Color3.fromRGB(80,220,200),  name = "Soul Spring" },
	[6] = { floor = Color3.fromRGB(190,170,210), accent = Color3.fromRGB(140,90,180),  name = "Void Reaches" },
	[7] = { floor = Color3.fromRGB(255,200,180), accent = Color3.fromRGB(255,140,90),  name = "Body Forge" },
	[8] = { floor = Color3.fromRGB(255,210,150), accent = Color3.fromRGB(255,170,60),  name = "Tribulation Plateau" },
	[9] = { floor = Color3.fromRGB(255,235,200), accent = Color3.fromRGB(255,215,120),  name = "Mahayana Summit" },
}

-- Ordered list of implemented realms (1..9).
function WorldData.Realms(): { number }
	return NPCData.GetImplementedRealms()
end

-- Centre of a realm's zone platform (on the ring around the hub).
function WorldData.ZoneCenter(realmId: number): Vector3
	local realms = WorldData.Realms()
	local n = #realms
	local idx = 1
	for i, r in ipairs(realms) do if r == realmId then idx = i end end
	local ang = (idx - 1) / n * math.pi * 2
	return Vector3.new(math.cos(ang) * WorldData.RING_RADIUS, 0, math.sin(ang) * WorldData.RING_RADIUS)
end

-- Theme for a realm zone.
function WorldData.Theme(realmId: number): { floor: Color3, accent: Color3, name: string }
	local t = THEMES[realmId]
	if t then return t end
	local realm = CultivationData.GetRealm(realmId)
	local c = realm and Color3.fromHex(realm.color or "60A5FA") or Color3.fromRGB(120,180,255)
	return { floor = c, accent = c, name = (realm and realm.name) or ("Realm " .. realmId) }
end

-- A spawn position for the i-th NPC (of count) inside a realm zone.
function WorldData.NPCPosition(realmId: number, index: number, count: number): Vector3
	local center = WorldData.ZoneCenter(realmId)
	-- arrange NPCs on an inner circle within the zone
	local r = WorldData.ZONE_RADIUS * 0.6
	local ang = (index - 1) / math.max(count, 1) * math.pi * 2
	return center + Vector3.new(math.cos(ang) * r, WorldData.ZONE_HEIGHT, math.sin(ang) * r)
end

-- Where the player lands when teleporting to a realm (just inside the gate).
function WorldData.TeleportPosition(realmId: number): Vector3
	local center = WorldData.ZoneCenter(realmId)
	return center + Vector3.new(0, WorldData.ZONE_HEIGHT + 3, 0)
end

return WorldData
