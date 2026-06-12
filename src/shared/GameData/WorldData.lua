--!strict
-- WorldData.lua
-- Single source of truth for the world layout. Every implemented realm gets
-- its own themed zone island: realms 1-9 ring the Mortal Earth hub, realms
-- 10-26 ring the arrival pads of their respective upper worlds (Immortal Sky,
-- Sage Heaven, Primal Chaos). TerrainGenerator, NPCService and the client
-- teleport all read these positions so everything lines up.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CultivationData = require(script.Parent:WaitForChild("CultivationData"))
local NPCData = require(script.Parent:WaitForChild("NPCData"))

local WorldData = {}

WorldData.HUB_CENTER   = Vector3.new(0, 4, 0)
WorldData.HUB_RADIUS   = 46
-- Each zone sits on its own 512×512 floating island; at ring radius 900 the
-- nine islands are ~615 studs apart centre-to-centre (≈100-stud air gaps).
WorldData.RING_RADIUS  = 900      -- W1 ring (kept for backwards compatibility)
WorldData.ZONE_RADIUS  = 62       -- platform radius of each realm zone
WorldData.ZONE_HEIGHT  = 4        -- platform thickness

-- Zone rings per world: radius + base angle. The angle offsets keep the new
-- zone islands clear of each world's existing landmark islands (the east
-- island in W2 at x=560, the satellite islet in W3 at z=420, the Forbidden
-- Zone islet in W4 at x=-450).
WorldData.WORLD_RING   = { [1] = 900, [2] = 1000, [3] = 1000, [4] = 1000 }
WorldData.WORLD_ANGLE0 = { [1] = 0, [2] = math.pi / 6, [3] = math.rad(25), [4] = math.rad(45) }

-- Per-realm theme: floor + accent colour + a short flavour name.
-- Falls back to the realm's own colour from CultivationData.
local THEMES: { [number]: { floor: Color3, accent: Color3, name: string } } = {
	[1]  = { floor = Color3.fromRGB(186,235,210), accent = Color3.fromRGB(120,220,150), name = "Qi Meadow" },
	[2]  = { floor = Color3.fromRGB(200,225,255), accent = Color3.fromRGB(120,180,255), name = "Foundation Cliffs" },
	[3]  = { floor = Color3.fromRGB(255,235,170), accent = Color3.fromRGB(245,200,80),  name = "Golden Pagoda Grounds" },
	[4]  = { floor = Color3.fromRGB(210,190,255), accent = Color3.fromRGB(170,120,255), name = "Nascent Soul Vale" },
	[5]  = { floor = Color3.fromRGB(180,255,235), accent = Color3.fromRGB(80,220,200),  name = "Soul Spring" },
	[6]  = { floor = Color3.fromRGB(190,170,210), accent = Color3.fromRGB(140,90,180),  name = "Void Reaches" },
	[7]  = { floor = Color3.fromRGB(255,200,180), accent = Color3.fromRGB(255,140,90),  name = "Body Forge" },
	[8]  = { floor = Color3.fromRGB(255,210,150), accent = Color3.fromRGB(255,170,60),  name = "Tribulation Plateau" },
	[9]  = { floor = Color3.fromRGB(255,235,200), accent = Color3.fromRGB(255,215,120), name = "Mahayana Summit" },
	-- World 2 · Immortal Sky (R10-15)
	[10] = { floor = Color3.fromRGB(205,235,250), accent = Color3.fromRGB(120,220,255), name = "Drifting Cloud Isle" },
	[11] = { floor = Color3.fromRGB(215,205,180), accent = Color3.fromRGB(190,160,90),  name = "Earthvein Terrace" },
	[12] = { floor = Color3.fromRGB(195,205,250), accent = Color3.fromRGB(140,160,255), name = "Star Bridge Heights" },
	[13] = { floor = Color3.fromRGB(230,240,255), accent = Color3.fromRGB(200,220,255), name = "True Immortal Gardens" },
	[14] = { floor = Color3.fromRGB(215,195,235), accent = Color3.fromRGB(180,130,230), name = "Mystic Veil Hollow" },
	[15] = { floor = Color3.fromRGB(250,235,180), accent = Color3.fromRGB(255,210,80),  name = "Golden Radiance Bastion" },
	-- World 3 · Sage Heaven (R16-22)
	[16] = { floor = Color3.fromRGB(225,210,170), accent = Color3.fromRGB(230,180,90),  name = "Imperial Court Ruins" },
	[17] = { floor = Color3.fromRGB(235,225,250), accent = Color3.fromRGB(210,190,255), name = "Origin Wellspring" },
	[18] = { floor = Color3.fromRGB(250,225,195), accent = Color3.fromRGB(255,190,120), name = "Zenith Summit" },
	[19] = { floor = Color3.fromRGB(200,240,230), accent = Color3.fromRGB(130,230,200), name = "Half-Step Plateau" },
	[20] = { floor = Color3.fromRGB(205,230,250), accent = Color3.fromRGB(150,205,255), name = "Sage Lecture Halls" },
	[21] = { floor = Color3.fromRGB(230,210,250), accent = Color3.fromRGB(200,150,255), name = "Unbound Chaos Reach" },
	[22] = { floor = Color3.fromRGB(250,240,210), accent = Color3.fromRGB(255,225,140), name = "Dao Sea Shelf" },
	-- World 4 · Primal Chaos (R23-26)
	[23] = { floor = Color3.fromRGB(250,225,240), accent = Color3.fromRGB(255,170,220), name = "Supreme Mandate Spire" },
	[24] = { floor = Color3.fromRGB(205,250,225), accent = Color3.fromRGB(130,255,190), name = "Worldseed Nursery" },
	[25] = { floor = Color3.fromRGB(220,240,250), accent = Color3.fromRGB(170,225,255), name = "Creation Forge" },
	[26] = { floor = Color3.fromRGB(255,255,255), accent = Color3.fromRGB(255,250,230), name = "Origin Point" },
}

-- Ordered list of implemented realms (1..26).
function WorldData.Realms(): { number }
	return NPCData.GetImplementedRealms()
end

-- Implemented realms belonging to one world, in ascending order.
function WorldData.RealmsInWorld(worldId: number): { number }
	local out: { number } = {}
	for _, r in ipairs(WorldData.Realms()) do
		if WorldData.GetWorldForRealm(r) == worldId then
			table.insert(out, r)
		end
	end
	return out
end

-- Centre of a realm's zone platform. Realms ring the hub of their own world
-- at that world's Y layer, so the returned Y is the world's base height.
function WorldData.ZoneCenter(realmId: number): Vector3
	local w = WorldData.GetWorldForRealm(realmId)
	local realms = WorldData.RealmsInWorld(w)
	local n = math.max(#realms, 1)
	local idx = 1
	for i, r in ipairs(realms) do if r == realmId then idx = i end end
	local ang = WorldData.WORLD_ANGLE0[w] + (idx - 1) / n * math.pi * 2
	local radius = WorldData.WORLD_RING[w]
	return Vector3.new(math.cos(ang) * radius, WorldData.WORLD_Y[w], math.sin(ang) * radius)
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

-- ════════════════════════════════════════════════════════════
-- Stacked-world layout (4 worlds on the Y axis). TerrainGenerator,
-- WorldTransitionService and the client all read these so portals,
-- spawns and effects line up.
-- ════════════════════════════════════════════════════════════
WorldData.WORLD_Y = { [1] = 0, [2] = 1800, [3] = 3600, [4] = 5400 }

-- Minimum realm to belong to / enter each world.
--   World 2 (Immortal Sky) unlocks at the Mahayana (R9) breakthrough.
--   World 3 (Sage Heaven) at R16.   World 4 (Primal Chaos) at R23.
WorldData.WORLD_MIN_REALM = { [1] = 1, [2] = 9, [3] = 16, [4] = 23 }

WorldData.WORLD_NAME = {
	[1] = "Mortal Earth",
	[2] = "Immortal Sky",
	[3] = "Sage Heaven",
	[4] = "Primal Chaos",
}

-- Arrival pad position for each world (where a portal drops you).
WorldData.WORLD_ARRIVAL = {
	[1] = Vector3.new(0, 6, 0),
	[2] = Vector3.new(0, 1806, 0),
	[3] = Vector3.new(-200, 3609, 0),
	[4] = Vector3.new(0, 5412, 0),
}

-- Which world a given realm belongs to (1-4). R9 still lives on Mortal
-- Earth; R10 and above belong to the Immortal Sky.
function WorldData.GetWorldForRealm(realm: number): number
	if realm >= WorldData.WORLD_MIN_REALM[4] then return 4
	elseif realm >= WorldData.WORLD_MIN_REALM[3] then return 3
	elseif realm >= 10 then return 2
	else return 1 end
end

return WorldData
