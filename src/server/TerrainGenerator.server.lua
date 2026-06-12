--!strict
-- TerrainGenerator.server.lua
-- Builds the complete Top Tier Providence world: four stacked worlds on the
-- Y axis, faithful to the R1–R26 world concept.
--
--   World 1 "Mortal Earth"  (Y=0)    R1–9   — Spawn Village + 9 themed realm
--                                              zones (5 biomes) + Netherworld
--   World 2 "Immortal Sky"   (Y=1800) R10–16 — Jade Palace City, 33-Layer Heaven
--   World 3 "Sage Heaven"    (Y=3600) R17–23 — Mystic Divine Palace, Chaos edge
--   World 4 "Primal Chaos"   (Y=5400) R24–26 — Chaos Battlefield, Origin Realm
--
-- All World 1 zone positions come straight from WorldData.ZoneCenter() so the
-- NPCService spawn layout and the realm teleports line up exactly.
--
-- This script only builds GEOMETRY. Interactive parts are given stable names
-- and CollectionService tags; the gameplay services (WorldTransitionService,
-- SecretGrottoService, YellowSpringService, …) find them and attach behaviour.

local Workspace        = workspace
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local WorldData       = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("WorldData"))
local CultivationData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("CultivationData"))

-- ── Layer Y offsets ──────────────────────────────────────────────────────────
local Y1 = WorldData.WORLD_Y[1]
local Y2 = WorldData.WORLD_Y[2]
local Y3 = WorldData.WORLD_Y[3]
local Y4 = WorldData.WORLD_Y[4]

-- ── Lighting ─────────────────────────────────────────────────────────────────
Lighting.Ambient        = Color3.fromRGB(140, 140, 165)
Lighting.OutdoorAmbient = Color3.fromRGB(175, 175, 200)
Lighting.Brightness     = 3
Lighting.ClockTime      = 14
Lighting.ShadowSoftness = 1
Lighting.GlobalShadows  = true
Lighting.FogEnd         = 100000
for _, inst in ipairs(Lighting:GetChildren()) do
	if inst:IsA("Atmosphere") or inst:IsA("ColorCorrectionEffect") or inst:IsA("BloomEffect") then
		inst:Destroy()
	end
end
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.6; bloom.Size = 28; bloom.Threshold = 0.90; bloom.Parent = Lighting

-- ── World folder ─────────────────────────────────────────────────────────────
local world = Workspace:FindFirstChild("World")
if world then world:Destroy() end
world = Instance.new("Folder"); world.Name = "World"; world.Parent = Workspace

-- ── Floating-island terrain ──────────────────────────────────────────────────
-- Every walkable area sits on a low-poly floating island (reference art style):
-- a flat grassy top the size of a Baseplate (512×512), a tapered rock body in
-- stepped layers, a rounded bottom cap and hanging stalactite clusters.
local Terrain = Workspace.Terrain
local TM = Enum.Material
Terrain:Clear()

local function fillBox(cx: number, cy: number, cz: number, sx: number, sy: number, sz: number, mat: Enum.Material)
	Terrain:FillBlock(CFrame.new(cx, cy, cz), Vector3.new(sx, sy, sz), mat)
end

local function fillSphere(cx: number, cy: number, cz: number, r: number, mat: Enum.Material)
	Terrain:FillBall(Vector3.new(cx, cy, cz), r, mat)
end

-- Tapered body layers for a 512-stud island: { yOffset, height, width }.
-- Each layer overlaps the one above so the silhouette reads as carved rock.
local ISLAND_LAYERS = {
	{  -5,  8, 496 },
	{ -16, 16, 490 },
	{ -32, 18, 440 },
	{ -50, 20, 375 },
	{ -68, 20, 295 },
	{ -85, 18, 200 },
	{ -99, 14, 120 },
}

-- Hanging stalactite blobs: { dx, dy, dz, radius } — tuned so every sphere
-- overlaps the body layer above it (no floating rocks).
local ISLAND_STALACTITES = {
	{ 200, -40,  130, 28 }, { -195, -42,  100, 26 }, { 215, -38, -150, 30 },
	{ -170, -44, -210, 24 }, {  30, -34,  230, 28 }, { -230, -30,   20, 27 },
	{ 110, -60,  140, 22 }, {  -90, -64, -130, 22 }, {   0, -62,  185, 24 },
	{   0, -46, -190, 24 }, { 170, -58,  -50, 20 }, { -155, -60,   60, 22 },
	{  60, -95,   70, 18 }, {  -80, -98,  -50, 16 }, { 130, -78,  -90, 18 },
	{ -40, -74,  140, 16 },
}

-- size = side length of the square top (512 = Baseplate). surfaceY is the
-- centre of the 8-stud-thick top slab, so the walkable surface is surfaceY + 4.
local function makeIsland(cx: number, surfaceY: number, cz: number, size: number,
		topMat: Enum.Material, rockMat: Enum.Material)
	local k = size / 512
	fillBox(cx, surfaceY, cz, size, 8, size, topMat)
	for _, L in ipairs(ISLAND_LAYERS) do
		fillBox(cx, surfaceY + L[1] * k, cz, L[3] * k, math.max(L[2] * k, 6), L[3] * k, rockMat)
	end
	fillSphere(cx, surfaceY - 112 * k, cz, math.max(72 * k, 14), rockMat)
	for _, s in ipairs(ISLAND_STALACTITES) do
		fillSphere(cx + s[1] * k, surfaceY + s[2] * k, cz + s[3] * k, math.max(s[4] * k, 7), rockMat)
	end
end

-- ── Part helpers ─────────────────────────────────────────────────────────────
local function part(name: string, size: Vector3, pos: Vector3, color: Color3,
		mat: Enum.Material?, parent: Instance?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.Size = size; p.Position = pos
	p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or world
	return p
end

local function cyl(name: string, dia: number, height: number, pos: Vector3, color: Color3,
		mat: Enum.Material?, parent: Instance?): Part
	local p = part(name, Vector3.new(dia, height, dia), pos, color, mat, parent)
	p.Shape = Enum.PartType.Cylinder
	p.Orientation = Vector3.new(0, 0, 90)
	return p
end

local function ball(name: string, dia: number, pos: Vector3, color: Color3,
		mat: Enum.Material?, parent: Instance?): Part
	local p = part(name, Vector3.new(dia, dia, dia), pos, color, mat, parent)
	p.Shape = Enum.PartType.Ball
	return p
end

local function billboard(parent: Instance, pos: Vector3, line1: string, col1: Color3,
		line2: string?, col2: Color3?)
	local anchor = Instance.new("Part"); anchor.Anchored = true; anchor.CanCollide = false
	anchor.Transparency = 1; anchor.Size = Vector3.new(1, 1, 1); anchor.Position = pos
	anchor.Name = "Label"; anchor.Parent = parent
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.fromOffset(360, line2 and 76 or 44); bg.AlwaysOnTop = false
	bg.Adornee = anchor; bg.Parent = anchor
	local l1 = Instance.new("TextLabel"); l1.BackgroundTransparency = 1
	l1.Size = UDim2.fromScale(1, line2 and 0.58 or 1); l1.Text = line1; l1.TextColor3 = col1
	l1.TextScaled = true; l1.Font = Enum.Font.GothamBlack; l1.TextStrokeTransparency = 0.3
	l1.Parent = bg
	if line2 then
		local l2 = Instance.new("TextLabel"); l2.BackgroundTransparency = 1
		l2.Position = UDim2.fromScale(0, 0.58); l2.Size = UDim2.fromScale(1, 0.42)
		l2.Text = line2; l2.TextColor3 = col2 or Color3.fromRGB(230, 230, 230)
		l2.TextScaled = true; l2.Font = Enum.Font.GothamMedium; l2.TextStrokeTransparency = 0.5
		l2.Parent = bg
	end
end

local function signBoard(parent: Instance, pos: Vector3, size: Vector3, text: string,
		col: Color3, bgCol: Color3): Part
	local p = part("Sign", size, pos, bgCol, Enum.Material.SmoothPlastic, parent)
	p.CanCollide = false
	local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.Parent = p
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = col
	lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBlack; lbl.Parent = sg
	return p
end

local function portalArch(parent: Instance, name: string, pos: Vector3, accent: Color3, label: string): Part
	part("PillarL", Vector3.new(3, 20, 3), pos + Vector3.new(-7, 10, 0), accent, Enum.Material.Neon, parent)
	part("PillarR", Vector3.new(3, 20, 3), pos + Vector3.new( 7, 10, 0), accent, Enum.Material.Neon, parent)
	part("Lintel", Vector3.new(17, 3, 3), pos + Vector3.new(0, 21, 0), accent, Enum.Material.Neon, parent)
	ball("Gem", 5, pos + Vector3.new(0, 24, 0), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, parent)
	local trig = part(name, Vector3.new(12, 18, 4), pos + Vector3.new(0, 9, 0), accent, Enum.Material.ForceField, parent)
	trig.Transparency = 0.6; trig.CanCollide = false
	CollectionService:AddTag(trig, "WorldPortal")
	billboard(parent, pos + Vector3.new(0, 30, 0), label, accent, "[ ENTER ]", Color3.fromRGB(220, 220, 220))
	return trig
end

local function tree(parent: Instance, pos: Vector3, canopyColor: Color3, canopyMat: Enum.Material)
	part("Trunk", Vector3.new(3, 16, 3), pos + Vector3.new(0, 8, 0), Color3.fromRGB(110, 75, 50), Enum.Material.Wood, parent)
	ball("Canopy", 14, pos + Vector3.new(0, 18, 0), canopyColor, canopyMat, parent)
end

-- A quest-giving NPC figure: robed body, head, hovering golden quest mark and
-- a name billboard. Pure decoration — quests are accepted via the Quest Log.
local function questGiverFigure(parent: Instance, pos: Vector3, icon: string, name: string, robe: Color3)
	local body = cyl("QuestGiver", 3.5, 5, pos + Vector3.new(0, 2.5, 0), robe, Enum.Material.Fabric, parent)
	body.Orientation = Vector3.new(0, 0, 0)
	ball("QuestGiverHead", 2.2, pos + Vector3.new(0, 6, 0), Color3.fromRGB(235, 200, 170), Enum.Material.SmoothPlastic, parent)
	ball("QuestMark", 1.4, pos + Vector3.new(0, 9, 0), Color3.fromRGB(255, 215, 60), Enum.Material.Neon, parent)
	billboard(parent, pos + Vector3.new(0, 11, 0),
		("%s %s"):format(icon, name), Color3.fromRGB(255, 215, 120),
		"❗ Quests [Quest Log]", Color3.fromRGB(255, 240, 200))
end

local rng = Random.new(20260610)

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 1 — MORTAL EARTH  (Y = 0)
-- ══════════════════════════════════════════════════════════════════════════════
local w1 = Instance.new("Folder"); w1.Name = "World1_MortalEarth"; w1.Parent = world

-- One Baseplate-sized floating island for the hub village and one per realm
-- zone (ring of 9). The walkable tops sit exactly at Y1, where the old flat
-- ground used to be, so every structure/NPC position stays valid.
makeIsland(WorldData.HUB_CENTER.X, Y1 - 4, WorldData.HUB_CENTER.Z, 512, TM.Grass, TM.Rock)
for _, islandRealmId in ipairs(WorldData.RealmsInWorld(1)) do
	local zc = WorldData.ZoneCenter(islandRealmId)
	makeIsland(zc.X, Y1 - 4, zc.Z, 512, TM.Grass, TM.Rock)
end

-- ── SPAWN VILLAGE (central hub) ───────────────────────────────────────────────
local hub    = WorldData.HUB_CENTER
local hubY   = Y1 + 4
local hubZone = Instance.new("Folder"); hubZone.Name = "Hub"; hubZone.Parent = w1

cyl("HubPad",  WorldData.HUB_RADIUS * 2,     4, Vector3.new(hub.X, hubY, hub.Z), Color3.fromRGB(245, 210, 180), Enum.Material.SmoothPlastic, hubZone)
cyl("HubRing", WorldData.HUB_RADIUS * 2 + 6, 2, Vector3.new(hub.X, hubY + 2, hub.Z), Color3.fromRGB(255, 180, 80), Enum.Material.Neon, hubZone)

for i = 0, 5 do
	local a = i / 6 * math.pi * 2
	local px = hub.X + math.cos(a) * (WorldData.HUB_RADIUS - 8)
	local pz = hub.Z + math.sin(a) * (WorldData.HUB_RADIUS - 8)
	part("Pillar", Vector3.new(4, 22, 4), Vector3.new(px, hubY + 11, pz), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, hubZone)
	ball("PillarTop", 6, Vector3.new(px, hubY + 23, pz), Color3.fromRGB(150, 255, 230), Enum.Material.Neon, hubZone)
end

local HOUSE_NAMES = { "茶館", "武具店", "藥鋪", "客棧", "丹房", "書齋", "鐵匠", "靈獸鋪" }
for i = 1, 8 do
	local a  = (i - 1) / 8 * math.pi * 2
	local px = hub.X + math.cos(a) * 35
	local pz = hub.Z + math.sin(a) * 35
	local house = part("House", Vector3.new(14, 10, 14), Vector3.new(px, Y1 + 5, pz), Color3.fromRGB(120, 80, 55), Enum.Material.Wood, hubZone)
	local roof = part("Roof", Vector3.new(18, 2, 18), Vector3.new(px, Y1 + 11, pz), Color3.fromRGB(150, 50, 45), Enum.Material.Slate, hubZone)
	roof.CanCollide = false
	local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.Adornee = house; sg.Parent = house
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.fromScale(1, 1); lbl.BackgroundTransparency = 1
	lbl.Text = HOUSE_NAMES[i]; lbl.TextColor3 = Color3.fromRGB(255, 230, 180); lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBlack; lbl.Parent = sg
end

cyl("Well", 6, 4, Vector3.new(hub.X, Y1 + 2, hub.Z), Color3.fromRGB(140, 120, 100), Enum.Material.Slate, hubZone)
cyl("WellWater", 5, 3, Vector3.new(hub.X, Y1 + 2.6, hub.Z), Color3.fromRGB(80, 140, 180), Enum.Material.Water, hubZone)

for i = 1, 6 do
	local a  = (i - 1) / 6 * math.pi * 2 + 0.4
	tree(hubZone, Vector3.new(hub.X + math.cos(a) * 22, Y1, hub.Z + math.sin(a) * 22), Color3.fromRGB(255, 180, 200), Enum.Material.Neon)
end

do  -- Providence Roll Shrine
	local sx, sz = hub.X, hub.Z - 18
	for step = 1, 3 do
		cyl("ProvStep", 16 - step * 3, 1.4, Vector3.new(sx, Y1 + step * 1.4 - 0.7, sz), Color3.fromRGB(220, 200, 170), Enum.Material.Marble, hubZone)
	end
	for _, dx in ipairs({ -7, 7 }) do
		cyl("Lantern", 2.4, 4, Vector3.new(sx + dx, Y1 + 7, sz), Color3.fromRGB(255, 60, 60), Enum.Material.Neon, hubZone)
	end
	part("ProvidenceShrine", Vector3.new(6, 5, 1.5), Vector3.new(sx, Y1 + 8, sz), Color3.fromRGB(255, 215, 120), Enum.Material.Neon, hubZone).CanCollide = false
	billboard(hubZone, Vector3.new(sx, Y1 + 13, sz), "🎲 Providence", Color3.fromRGB(255, 215, 120))
end

do  -- Han Jue's Shrine
	local sx, sz = hub.X + 20, hub.Z + 20
	cyl("ShrinePad", 8, 1, Vector3.new(sx, Y1 + 0.5, sz), Color3.fromRGB(40, 30, 60), Enum.Material.Marble, hubZone)
	local shrine = ball("HanJueShrine", 8, Vector3.new(sx, Y1 + 14, sz), Color3.fromRGB(255, 210, 60), Enum.Material.Neon, hubZone)
	CollectionService:AddTag(shrine, "Shrine")
	billboard(hubZone, Vector3.new(sx, Y1 + 20, sz), "📖 Book of Misfortune", Color3.fromRGB(255, 210, 60), "Pray daily for +100 Karma", Color3.fromRGB(255, 240, 200))
	local LORE = { "韓絕", "孤獨", "長生", "天道", "因果", "逍遙" }
	for i = 1, 6 do
		local a = (i - 1) / 6 * math.pi * 2
		signBoard(hubZone, Vector3.new(sx + math.cos(a) * 10, Y1 + 4, sz + math.sin(a) * 10), Vector3.new(3, 6, 0.6), LORE[i], Color3.fromRGB(200, 180, 255), Color3.fromRGB(50, 40, 70))
	end
end

do  -- Wall of Eternity
	local wx, wz = hub.X - 40, hub.Z
	local wall = part("WallOfEternity", Vector3.new(2, 8, 60), Vector3.new(wx, Y1 + 4, wz), Color3.fromRGB(120, 105, 70), Enum.Material.Marble, hubZone)
	part("WallGlow", Vector3.new(1, 9, 62), Vector3.new(wx - 1.4, Y1 + 4, wz), Color3.fromRGB(255, 210, 90), Enum.Material.Neon, hubZone)
	local sg = Instance.new("SurfaceGui"); sg.Name = "WallSurface"; sg.Face = Enum.NormalId.Left
	sg.CanvasSize = Vector2.new(800, 1200); sg.Adornee = wall; sg.Parent = wall
	local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 90); title.BackgroundTransparency = 1
	title.Text = "✨ WALL OF ETERNITY ✨"; title.TextColor3 = Color3.fromRGB(255, 220, 120); title.TextScaled = true
	title.Font = Enum.Font.GothamBlack; title.Parent = sg
	local list = Instance.new("ScrollingFrame"); list.Name = "Names"; list.Position = UDim2.new(0, 0, 0, 100)
	list.Size = UDim2.new(1, 0, 1, -100); list.BackgroundTransparency = 1; list.BorderSizePixel = 0
	list.ScrollBarThickness = 6; list.CanvasSize = UDim2.new(); list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.Parent = sg
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 6); ll.HorizontalAlignment = Enum.HorizontalAlignment.Center; ll.Parent = list
	CollectionService:AddTag(wall, "WallOfEternity")
end

do  -- Quest-giver NPCs (sequential quest chains — see QuestData.NPC_CHAINS)
	local GIVERS = {
		{ name = "Village Elder",      icon = "👴", dx =  28, dz =  -8, robe = Color3.fromRGB(120, 100, 70)  },
		{ name = "Cultivation Master", icon = "🧙", dx = -10, dz =  30, robe = Color3.fromRGB(90, 70, 140)   },
		{ name = "Merchant",           icon = "💰", dx = -24, dz = -22, robe = Color3.fromRGB(150, 110, 50)  },
		{ name = "Beast Hunter Lin",   icon = "🏹", dx =  12, dz = -32, robe = Color3.fromRGB(70, 110, 70)   },
	}
	for _, g in ipairs(GIVERS) do
		questGiverFigure(hubZone, Vector3.new(hub.X + g.dx, Y1, hub.Z + g.dz), g.icon, g.name, g.robe)
	end
end

-- ── REALM ZONES (one platform per realm, themed into 5 biomes) ─────────────────
type Biome = { floor: Color3, border: Color3, name: string }
local function biomeFor(realmId: number): Biome
	if realmId <= 2 then
		return { floor = Color3.fromRGB(140, 200, 100), border = Color3.fromRGB(80, 200, 120), name = "Spirit Forest" }
	elseif realmId == 3 then
		return { floor = Color3.fromRGB(160, 210, 100), border = Color3.fromRGB(100, 200, 60), name = "Bamboo Valley" }
	elseif realmId <= 5 then
		return { floor = Color3.fromRGB(180, 160, 120), border = Color3.fromRGB(255, 200, 90), name = "Core Mountains" }
	elseif realmId <= 7 then
		return { floor = Color3.fromRGB(40, 20, 70), border = Color3.fromRGB(140, 0, 255), name = "Void Borderlands" }
	else
		return { floor = Color3.fromRGB(70, 60, 60), border = Color3.fromRGB(255, 210, 0), name = "Tribulation Peak" }
	end
end

local zr = WorldData.ZONE_RADIUS
local zh = WorldData.ZONE_HEIGHT

for _, realmId in ipairs(WorldData.RealmsInWorld(1)) do
	local center = WorldData.ZoneCenter(realmId)
	local realm  = CultivationData.GetRealm(realmId)
	local biome  = biomeFor(realmId)
	local lift   = realmId >= 8 and 16 or 0

	local zone = Instance.new("Folder"); zone.Name = "Zone_" .. realmId; zone.Parent = w1

	cyl("Floor",  zr * 2,     zh, Vector3.new(center.X, Y1 + zh / 2 + lift, center.Z), biome.floor, Enum.Material.SmoothPlastic, zone)
	cyl("Border", zr * 2 + 6, 3,  Vector3.new(center.X, Y1 + zh + lift, center.Z), biome.border, Enum.Material.Neon, zone)

	for i = 0, 15 do
		local a = i / 16 * math.pi * 2
		part("Post", Vector3.new(2.5, 8, 2.5), Vector3.new(center.X + math.cos(a) * (zr - 2), Y1 + zh + 4 + lift, center.Z + math.sin(a) * (zr - 2)), biome.border, Enum.Material.Neon, zone)
	end

	billboard(zone, Vector3.new(center.X, Y1 + zh + 30 + lift, center.Z), ("R%d · %s"):format(realmId, realm and realm.name or "?"), biome.border, biome.name, Color3.fromRGB(255, 255, 255))

	local dir = (Vector3.new(hub.X, 0, hub.Z) - Vector3.new(center.X, 0, center.Z))
	dir = dir.Magnitude > 0 and dir.Unit or Vector3.new(0, 0, 1)
	local from = Vector3.new(hub.X, Y1, hub.Z) + dir * WorldData.HUB_RADIUS
	local to   = Vector3.new(center.X, Y1, center.Z) + dir * zr
	local mid  = (from + to) * 0.5
	local len  = (to - from).Magnitude
	local bridge = part("Bridge", Vector3.new(10, 2, len), Vector3.new(mid.X, Y1 + zh - 1, mid.Z), biome.floor, Enum.Material.SmoothPlastic, zone)
	bridge.CFrame = CFrame.lookAt(Vector3.new(mid.X, Y1 + zh - 1, mid.Z), Vector3.new(to.X, Y1 + zh - 1, to.Z))
	bridge.Size = Vector3.new(10, 2, len)

	if realmId < 9 then
		local nextCenter = WorldData.ZoneCenter(realmId + 1)
		local bdir = (Vector3.new(nextCenter.X, 0, nextCenter.Z) - Vector3.new(center.X, 0, center.Z))
		bdir = bdir.Magnitude > 0 and bdir.Unit or Vector3.new(0, 0, 1)
		local bpos = Vector3.new(center.X, Y1, center.Z) + bdir * (zr + 8)
		part("BarrierL", Vector3.new(4, 20, 4), bpos + Vector3.new(-8, 10, 0), Color3.fromRGB(100, 90, 80), Enum.Material.Rock, zone)
		part("BarrierR", Vector3.new(4, 20, 4), bpos + Vector3.new( 8, 10, 0), Color3.fromRGB(100, 90, 80), Enum.Material.Rock, zone)
		part("BarrierTop", Vector3.new(20, 4, 4), bpos + Vector3.new(0, 21, 0), Color3.fromRGB(100, 90, 80), Enum.Material.Rock, zone)
		local ring = cyl("BarrierRing", 14, 1, bpos + Vector3.new(0, 0.6, 0), Color3.fromRGB(255, 210, 60), Enum.Material.Neon, zone)
		ring.Orientation = Vector3.new(0, 0, 0)
		local trig = part("RealmBarrier", Vector3.new(16, 18, 3), bpos + Vector3.new(0, 9, 0), Color3.fromRGB(255, 210, 60), Enum.Material.ForceField, zone)
		trig.Transparency = 0.7; trig.CanCollide = false
		trig:SetAttribute("ReqRealm", realmId + 1)
		CollectionService:AddTag(trig, "RealmBarrier")
		signBoard(zone, bpos + Vector3.new(0, 24, 0), Vector3.new(14, 4, 0.5), ("Realm %d Required"):format(realmId + 1), Color3.fromRGB(255, 230, 150), Color3.fromRGB(40, 35, 25))
	end
end

-- ── ZONE 1 · SPIRIT FOREST ────────────────────────────────────────────────────
do
	local c = WorldData.ZoneCenter(1)
	local zone = w1:FindFirstChild("Zone_1") :: Folder
	for _ = 1, 20 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(8, zr - 12)
		tree(zone, Vector3.new(c.X + math.cos(a) * r, Y1 + zh, c.Z + math.sin(a) * r), Color3.fromRGB(120, 255, 180), Enum.Material.Neon)
	end
	for _ = 1, 12 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(6, zr - 10)
		local crystal = part("QiCrystal", Vector3.new(2, 8, 2), Vector3.new(c.X + math.cos(a) * r, Y1 + zh + 4, c.Z + math.sin(a) * r), Color3.fromRGB(100, 220, 255), Enum.Material.Neon, zone)
		crystal.Orientation = Vector3.new(rng:NextNumber(-15, 15), 0, rng:NextNumber(-15, 15))
	end
	local d = c + Vector3.new(45, 0, 0)
	part("CaveL", Vector3.new(4, 16, 4), Vector3.new(d.X - 6, Y1 + zh + 8, d.Z), Color3.fromRGB(70, 70, 80), Enum.Material.Rock, zone)
	part("CaveR", Vector3.new(4, 16, 4), Vector3.new(d.X + 6, Y1 + zh + 8, d.Z), Color3.fromRGB(70, 70, 80), Enum.Material.Rock, zone)
	part("CaveTop", Vector3.new(16, 4, 4), Vector3.new(d.X, Y1 + zh + 17, d.Z), Color3.fromRGB(70, 70, 80), Enum.Material.Rock, zone)
	signBoard(zone, Vector3.new(d.X, Y1 + zh + 22, d.Z), Vector3.new(14, 4, 0.5), "Cave of Qi [Dungeon R1-2]", Color3.fromRGB(120, 220, 255), Color3.fromRGB(20, 30, 40))

	local wf = c + Vector3.new(-46, 0, -10)
	local fall = cyl("Waterfall", 10, 30, Vector3.new(wf.X, Y1 + zh + 15, wf.Z), Color3.fromRGB(220, 240, 255), Enum.Material.Neon, zone)
	fall.Orientation = Vector3.new(0, 0, 0); fall.Transparency = 0.6; fall.CanCollide = false
	local gate = part("GrottoTrigger", Vector3.new(10, 14, 3), Vector3.new(wf.X, Y1 + zh + 7, wf.Z + 3), Color3.fromRGB(40, 60, 80), Enum.Material.ForceField, zone)
	gate.Transparency = 0.5; gate.CanCollide = false
	CollectionService:AddTag(gate, "GrottoTrigger")
	for i = 1, 3 do
		local stone = part("QiStone", Vector3.new(3, 3, 3), Vector3.new(wf.X - 12 + i * 6, Y1 + zh + 2, wf.Z + 10), Color3.fromRGB(80, 160, 220), Enum.Material.Neon, zone)
		stone:SetAttribute("Order", i)
		CollectionService:AddTag(stone, "QiStone")
	end
end

-- ── ZONE 2 · BAMBOO VALLEY + SECT GATES ───────────────────────────────────────
do
	local c = WorldData.ZoneCenter(2)
	local zone = w1:FindFirstChild("Zone_2") :: Folder
	for _ = 1, 16 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(8, zr - 12)
		local bx, bz = c.X + math.cos(a) * r, c.Z + math.sin(a) * r
		for _ = 1, rng:NextInteger(3, 5) do
			part("Bamboo", Vector3.new(2, 24, 2), Vector3.new(bx + rng:NextNumber(-3, 3), Y1 + zh + 12, bz + rng:NextNumber(-3, 3)), Color3.fromRGB(100, 180, 60), Enum.Material.Grass, zone)
		end
	end
	local g1 = c + Vector3.new(0, 0, -40)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		part("SixPathsWall", Vector3.new(3, 18, 8), Vector3.new(g1.X + math.cos(a) * 8, Y1 + zh + 9, g1.Z + math.sin(a) * 8), Color3.fromRGB(160, 80, 255), Enum.Material.Neon, zone)
	end
	part("SixPathsSpire", Vector3.new(3, 14, 3), Vector3.new(g1.X, Y1 + zh + 24, g1.Z), Color3.fromRGB(200, 140, 255), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(g1.X, Y1 + zh + 34, g1.Z), "☯️ Six Paths Hidden Sect", Color3.fromRGB(180, 120, 255))
	local g2 = c + Vector3.new(38, 0, 0)
	cyl("CalamityCrater", 20, 4, Vector3.new(g2.X, Y1 + zh - 1, g2.Z), Color3.fromRGB(120, 30, 20), Enum.Material.Rock, zone)
	cyl("CalamityRing", 22, 2, Vector3.new(g2.X, Y1 + zh + 1, g2.Z), Color3.fromRGB(220, 60, 40), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(g2.X, Y1 + zh + 12, g2.Z), "💫 Calamity Star Sect", Color3.fromRGB(255, 90, 70))
	local g3 = c + Vector3.new(0, 0, 40)
	cyl("WaterPool", 18, 2, Vector3.new(g3.X, Y1 + zh, g3.Z), Color3.fromRGB(60, 150, 255), Enum.Material.Water, zone)
	part("WaterArchL", Vector3.new(3, 16, 3), Vector3.new(g3.X - 7, Y1 + zh + 8, g3.Z), Color3.fromRGB(80, 180, 255), Enum.Material.Neon, zone)
	part("WaterArchR", Vector3.new(3, 16, 3), Vector3.new(g3.X + 7, Y1 + zh + 8, g3.Z), Color3.fromRGB(80, 180, 255), Enum.Material.Neon, zone)
	part("WaterArchTop", Vector3.new(17, 3, 3), Vector3.new(g3.X, Y1 + zh + 17, g3.Z), Color3.fromRGB(80, 180, 255), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(g3.X, Y1 + zh + 24, g3.Z), "💧 Water Spirit Sect", Color3.fromRGB(120, 200, 255))
	local g4 = c + Vector3.new(-zr - 20, 0, 0)
	part("LoneStarTower", Vector3.new(6, 40, 6), Vector3.new(g4.X, Y1 + 20, g4.Z), Color3.fromRGB(235, 235, 245), Enum.Material.Marble, zone)
	ball("LoneStarTop", 8, Vector3.new(g4.X, Y1 + 42, g4.Z), Color3.fromRGB(255, 220, 120), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(g4.X, Y1 + 50, g4.Z), "⭐ Lone Star Sect", Color3.fromRGB(255, 230, 150))
	local d = c + Vector3.new(-40, 0, -20)
	part("IronFortress", Vector3.new(20, 14, 14), Vector3.new(d.X, Y1 + zh + 7, d.Z), Color3.fromRGB(80, 70, 60), Enum.Material.DiamondPlate, zone)
	signBoard(zone, Vector3.new(d.X, Y1 + zh + 18, d.Z), Vector3.new(16, 4, 0.5), "Iron Fortress [Dungeon R2-3]", Color3.fromRGB(200, 190, 170), Color3.fromRGB(35, 30, 25))
end

-- ── ZONE 3 · CORE MOUNTAINS ───────────────────────────────────────────────────
do
	local c = WorldData.ZoneCenter(3)
	local zone = w1:FindFirstChild("Zone_3") :: Folder
	local peakX, peakZ, peakH = c.X, c.Z, 0
	for i = 0, 6 do
		local a = i / 7 * math.pi * 2
		local h = rng:NextNumber(40, 120)
		local mx, mz = c.X + math.cos(a) * (zr - 16), c.Z + math.sin(a) * (zr - 16)
		part("Mountain", Vector3.new(28, h, 28), Vector3.new(mx, Y1 + h / 2, mz), Color3.fromRGB(160, 140, 100), Enum.Material.Rock, zone)
		if h > peakH then peakH = h; peakX = mx; peakZ = mz end
	end
	for f = 1, 9 do
		local dia = 20 - (f - 1) * 1.5
		cyl("PagodaFloor", dia, 6, Vector3.new(peakX, Y1 + peakH + f * 7 - 3, peakZ), Color3.fromRGB(255, 210, 60), Enum.Material.Neon, zone)
	end
	part("PagodaSpire", Vector3.new(2, 12, 2), Vector3.new(peakX, Y1 + peakH + 9 * 7 + 4, peakZ), Color3.fromRGB(255, 240, 160), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(peakX, Y1 + peakH + 9 * 7 + 14, peakZ), "🏯 Golden Core Pagoda", Color3.fromRGB(255, 220, 100), "9 Floors", Color3.fromRGB(255, 240, 200))
	local d = c + Vector3.new(20, 0, 24)
	part("LabyrinthArch", Vector3.new(14, 10, 4), Vector3.new(d.X, Y1 + zh + 5, d.Z), Color3.fromRGB(50, 45, 55), Enum.Material.Rock, zone)
	signBoard(zone, Vector3.new(d.X, Y1 + zh + 13, d.Z), Vector3.new(16, 4, 0.5), "Nascent Soul Labyrinth [R4-5]", Color3.fromRGB(200, 180, 220), Color3.fromRGB(25, 22, 30))
	local wbp = c + Vector3.new(-24, 0, 18)
	cyl("WBPlateau", 36, 3, Vector3.new(wbp.X, Y1 + zh + 0.5, wbp.Z), Color3.fromRGB(100, 90, 70), Enum.Material.Rock, zone)
	cyl("WBRing", 38, 1.5, Vector3.new(wbp.X, Y1 + zh + 2, wbp.Z), Color3.fromRGB(255, 160, 0), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(wbp.X, Y1 + zh + 10, wbp.Z), "⚔️ World Boss Plateau", Color3.fromRGB(255, 170, 60))
end

-- ── ZONE 4 · VOID BORDERLANDS ─────────────────────────────────────────────────
do
	local c = WorldData.ZoneCenter(4)
	local zone = w1:FindFirstChild("Zone_4") :: Folder
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		local s = part("SkyCrack", Vector3.new(4, 0.5, 30), Vector3.new(c.X + math.cos(a) * 20, Y1 + rng:NextNumber(60, 80), c.Z + math.sin(a) * 20), Color3.fromRGB(80, 0, 140), Enum.Material.Neon, zone)
		s.Orientation = Vector3.new(rng:NextNumber(-40, 40), rng:NextNumber(0, 180), rng:NextNumber(-40, 40)); s.CanCollide = false
	end
	for _ = 1, 12 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(6, zr - 8)
		part("FloatRock", Vector3.new(rng:NextNumber(8, 20), rng:NextNumber(6, 12), rng:NextNumber(10, 18)), Vector3.new(c.X + math.cos(a) * r, Y1 + rng:NextNumber(15, 40), c.Z + math.sin(a) * r), Color3.fromRGB(50, 30, 80), Enum.Material.Rock, zone)
	end
	for _ = 1, 8 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(6, zr - 8)
		cyl("VoidFire", 3, 20, Vector3.new(c.X + math.cos(a) * r, Y1 + zh + 10, c.Z + math.sin(a) * r), Color3.fromRGB(140, 0, 255), Enum.Material.Neon, zone).Orientation = Vector3.new(0, 0, 0)
	end
	local d = c + Vector3.new(0, 0, 30)
	cyl("VoidAbyss", 30, 4, Vector3.new(d.X, Y1 + zh - 3, d.Z), Color3.fromRGB(8, 4, 16), Enum.Material.Slate, zone)
	signBoard(zone, Vector3.new(d.X, Y1 + zh + 8, d.Z), Vector3.new(16, 4, 0.5), "Void Abyss [Dungeon R6-7]", Color3.fromRGB(180, 100, 255), Color3.fromRGB(15, 8, 25))
	local wb = c + Vector3.new(-26, 0, -10)
	cyl("VoidWBRing", 30, 1.5, Vector3.new(wb.X, Y1 + zh + 1, wb.Z), Color3.fromRGB(255, 200, 0), Enum.Material.Neon, zone)
	billboard(zone, Vector3.new(wb.X, Y1 + zh + 9, wb.Z), "⚔️ World Boss Spawn", Color3.fromRGB(255, 210, 60))
end

-- ── ZONE 5 · TRIBULATION PEAK ─────────────────────────────────────────────────
do
	local c = WorldData.ZoneCenter(5)
	local zone = w1:FindFirstChild("Zone_5") :: Folder
	local baseY = Y1 + zh + 16
	for _ = 1, 14 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(4, zr - 6)
		local b = part("StormBolt", Vector3.new(1.5, rng:NextNumber(14, 22), 1.5), Vector3.new(c.X + math.cos(a) * r, baseY + rng:NextNumber(18, 34), c.Z + math.sin(a) * r), Color3.fromRGB(220, 220, 255), Enum.Material.Neon, zone)
		b.Orientation = Vector3.new(rng:NextNumber(-25, 25), 0, rng:NextNumber(-25, 25)); b.CanCollide = false
	end
	for i = 0, 3 do
		local a = i / 4 * math.pi * 2
		local rx, rz = c.X + math.cos(a) * (zr - 8), c.Z + math.sin(a) * (zr - 8)
		part("LightningRod", Vector3.new(2, 30, 2), Vector3.new(rx, baseY + 15, rz), Color3.fromRGB(255, 210, 0), Enum.Material.Neon, zone)
		ball("RodTop", 4, Vector3.new(rx, baseY + 31, rz), Color3.fromRGB(255, 240, 120), Enum.Material.Neon, zone)
	end
	cyl("Arena", 40, 2, Vector3.new(c.X, baseY, c.Z), Color3.fromRGB(80, 70, 60), Enum.Material.Rock, zone)
	for i = 0, 23 do
		local a = i / 24 * math.pi * 2
		part("ArenaWall", Vector3.new(3, 4, 3), Vector3.new(c.X + math.cos(a) * 21, baseY + 2, c.Z + math.sin(a) * 21), Color3.fromRGB(90, 80, 70), Enum.Material.Rock, zone)
	end
	local hg = cyl("HeavensGateGlow", 60, 2, Vector3.new(c.X, baseY + 60, c.Z), Color3.fromRGB(255, 240, 180), Enum.Material.Neon, zone)
	hg.Orientation = Vector3.new(0, 0, 0); hg.CanCollide = false
	cyl("HanJueAvatarPedestal", 8, 3, Vector3.new(c.X, baseY + 1.5, c.Z), Color3.fromRGB(120, 90, 160), Enum.Material.Marble, zone)
	billboard(zone, Vector3.new(c.X, baseY + 10, c.Z), "⚔️ Han Jue [Avatar]", Color3.fromRGB(255, 210, 120), "R9 MYTHIC Boss", Color3.fromRGB(255, 240, 200))
	zone:SetAttribute("PeakPosition", Vector3.new(c.X, baseY, c.Z))
end

-- ── UNDERGROUND · YELLOW SPRING / NETHERWORLD ─────────────────────────────────
do
	local nether = Instance.new("Folder"); nether.Name = "Netherworld"; nether.Parent = w1
	-- Deep below the islands so the hub island's rock body and stalactites
	-- (which reach ~190 studs down) never clip into the Netherworld.
	local netherY = -320
	local shaftH = (Y1 + zh) - netherY
	local sf = WorldData.ZoneCenter(1) + Vector3.new(30, 0, 30)
	part("Shaft", Vector3.new(16, shaftH, 16), Vector3.new(sf.X, netherY + shaftH / 2, sf.Z), Color3.fromRGB(20, 18, 26), Enum.Material.Rock, nether).Transparency = 0.5
	signBoard(nether, Vector3.new(sf.X, Y1 + zh + 4, sf.Z), Vector3.new(8, 3, 0.5), "↓ Netherworld", Color3.fromRGB(255, 200, 80), Color3.fromRGB(20, 18, 10))
	part("NetherFloor", Vector3.new(600, 8, 600), Vector3.new(0, netherY, 0), Color3.fromRGB(10, 8, 16), Enum.Material.Slate, nether)
	local prev = Vector3.new(-260, netherY + 5, -200)
	for i = 1, 14 do
		local nextP = prev + Vector3.new(38, 0, math.sin(i) * 30 + 10)
		local mid = (prev + nextP) * 0.5
		local len = (nextP - prev).Magnitude
		local seg = part("YellowSpring", Vector3.new(10, 2, len), mid, Color3.fromRGB(255, 200, 0), Enum.Material.Neon, nether)
		seg.CFrame = CFrame.lookAt(mid, nextP); seg.Size = Vector3.new(10, 2, len); seg.CanCollide = false
		CollectionService:AddTag(seg, "YellowSpring")
		prev = nextP
	end
	local island = Instance.new("Folder"); island.Name = "HiddenSectIsland"; island.Parent = nether
	local ix, iz = 0, 40
	cyl("IslandPad", 60, 6, Vector3.new(ix, netherY + 8, iz), Color3.fromRGB(30, 25, 40), Enum.Material.Rock, island)
	part("CaveAbode", Vector3.new(20, 15, 20), Vector3.new(ix, netherY + 18, iz), Color3.fromRGB(50, 45, 60), Enum.Material.Rock, island)
	billboard(island, Vector3.new(ix, netherY + 32, iz), "🏝️ Hidden Sect Island", Color3.fromRGB(160, 100, 220), "Six Paths members only", Color3.fromRGB(200, 180, 255))
	island:SetAttribute("MeditationSpot", Vector3.new(ix, netherY + 11, iz))
	CollectionService:AddTag(island, "HiddenSectIsland")
	for _, info in ipairs({ { -18, "Ah Da" }, { 18, "Xiao Er" } }) do
		local gx = ix + (info[1] :: number)
		part("Guardian", Vector3.new(8, 30, 8), Vector3.new(gx, netherY + 23, iz - 22), Color3.fromRGB(20, 16, 28), Enum.Material.Slate, island)
		ball("GuardianEye", 3, Vector3.new(gx, netherY + 34, iz - 18), Color3.fromRGB(255, 60, 0), Enum.Material.Neon, island)
		billboard(island, Vector3.new(gx, netherY + 40, iz - 22), info[2] :: string, Color3.fromRGB(255, 90, 40))
	end
end

local sp = Workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
sp.Anchored = true; sp.Size = Vector3.new(12, 1, 12)
sp.Position = Vector3.new(hub.X, hubY + 1, hub.Z)
sp.Transparency = 1; sp.CanCollide = false; sp.Neutral = true; sp.Parent = w1

portalArch(hubZone, "Portal_W1_to_W2", Vector3.new(hub.X + 30, hubY, hub.Z), Color3.fromRGB(80, 220, 200), "↑ HEAVEN'S GATE (R9·9 Required)")

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 2 — IMMORTAL SKY  (Y = 1800)
-- ══════════════════════════════════════════════════════════════════════════════
local w2 = Instance.new("Folder"); w2.Name = "World2_ImmortalSky"; w2.Parent = world

-- Two floating sky islands replace the old cloud sea: one under the Jade
-- Palace City / arrival gate, one under the Immortal Plain to the east.
makeIsland(0,   Y2, 0, 512, TM.LeafyGrass, TM.Glacier)
makeIsland(560, Y2, 0, 512, TM.LeafyGrass, TM.Glacier)

local av = WorldData.WORLD_ARRIVAL[2]
cyl("W2ArrivalPad", 40, 6, Vector3.new(av.X, Y2 + 3, av.Z), Color3.fromRGB(140, 220, 180), Enum.Material.Marble, w2)
for i = 0, 5 do
	local a = i / 6 * math.pi * 2
	cyl("ArrivalPillar", 6, 60, Vector3.new(av.X + math.cos(a) * 80, Y2 + 30, av.Z + math.sin(a) * 80), Color3.fromRGB(255, 210, 60), Enum.Material.Neon, w2).Orientation = Vector3.new(0, 0, 0)
end
part("HeavensGateL", Vector3.new(8, 80, 8), Vector3.new(av.X - 24, Y2 + 40, av.Z), Color3.fromRGB(255, 230, 120), Enum.Material.Neon, w2)
part("HeavensGateR", Vector3.new(8, 80, 8), Vector3.new(av.X + 24, Y2 + 40, av.Z), Color3.fromRGB(255, 230, 120), Enum.Material.Neon, w2)
part("HeavensGateTop", Vector3.new(56, 8, 8), Vector3.new(av.X, Y2 + 80, av.Z), Color3.fromRGB(255, 230, 120), Enum.Material.Neon, w2)
billboard(w2, Vector3.new(av.X, Y2 + 92, av.Z), "⚡ Heaven's Gate", Color3.fromRGB(255, 230, 120), "Welcome, Immortal", Color3.fromRGB(255, 250, 220))
cyl("ReincarnationPedestal", 6, 3, Vector3.new(av.X + 14, Y2 + 4.5, av.Z + 10), Color3.fromRGB(180, 220, 255), Enum.Material.Marble, w2)
billboard(w2, Vector3.new(av.X + 14, Y2 + 11, av.Z + 10), "🧙 Ancient Immortal", Color3.fromRGB(180, 220, 255), "Reincarnation Guide", Color3.fromRGB(220, 235, 255))

do
	cyl("JadeIsle", 300, 12, Vector3.new(0, Y2 + 9, 0), Color3.fromRGB(160, 230, 200), Enum.Material.SmoothPlastic, w2)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		local bx, bz = math.cos(a) * 90, math.sin(a) * 90
		part("JadeBuilding", Vector3.new(40, 50, 40), Vector3.new(bx, Y2 + 40, bz), Color3.fromRGB(180, 240, 210), Enum.Material.Marble, w2)
		part("JadeRoof", Vector3.new(48, 4, 48), Vector3.new(bx, Y2 + 66, bz), Color3.fromRGB(255, 220, 120), Enum.Material.Neon, w2).CanCollide = false
		part("JadeSpire", Vector3.new(3, 14, 3), Vector3.new(bx, Y2 + 74, bz), Color3.fromRGB(255, 240, 180), Enum.Material.Neon, w2)
	end
	for i = 1, 8 do
		local a = (i - 1) / 8 * math.pi * 2
		local lx, lz = math.cos(a) * 50, math.sin(a) * 50
		cyl("LotusPond", 20, 2, Vector3.new(lx, Y2 + 16, lz), Color3.fromRGB(100, 180, 255), Enum.Material.Water, w2).Orientation = Vector3.new(0, 0, 0)
		ball("Lotus", 5, Vector3.new(lx, Y2 + 17, lz), Color3.fromRGB(255, 150, 200), Enum.Material.Neon, w2)
	end
	for i = 1, 40 do
		local a, r = (i / 40) * math.pi * 2, rng:NextNumber(40, 140)
		ball("JadeLantern", 3, Vector3.new(math.cos(a) * r, Y2 + 18, math.sin(a) * r), Color3.fromRGB(200, 255, 230), Enum.Material.Neon, w2)
	end
	local daoPortal = portalArch(w2, "DaoFieldPortal", Vector3.new(0, Y2 + 15, 120), Color3.fromRGB(100, 255, 200), "Personal Dao Field (R11)")
	CollectionService:AddTag(daoPortal, "DaoFieldPortal")
end

do
	local ox = 500
	part("ImmortalPlain", Vector3.new(400, 8, 400), Vector3.new(ox, Y2 + 4, 0), Color3.fromRGB(200, 220, 180), Enum.Material.Grass, w2)
	for i = 1, 20 do
		local a = (i / 20) * math.pi * 2
		part("MountainSilhouette", Vector3.new(6, rng:NextNumber(40, 90), 30), Vector3.new(ox + math.cos(a) * 210, Y2 + 40, math.sin(a) * 210), Color3.fromRGB(120, 140, 100), Enum.Material.Rock, w2).CanCollide = false
	end
	part("HiddenSectHQ", Vector3.new(100, 30, 100), Vector3.new(ox, Y2 + 20, 0), Color3.fromRGB(140, 100, 180), Enum.Material.Marble, w2)
	part("HQTower", Vector3.new(10, 60, 10), Vector3.new(ox, Y2 + 38, 0), Color3.fromRGB(160, 120, 200), Enum.Material.Marble, w2)
	billboard(w2, Vector3.new(ox, Y2 + 74, 0), "🏯 Hundred Mountains Sect", Color3.fromRGB(190, 150, 240))
	for i = 1, 6 do
		cyl("Samsara", 16 - i, 6, Vector3.new(ox - 120, Y2 + 6 + i * 6, 80), Color3.fromRGB(60, 150, 255), Enum.Material.Neon, w2).Orientation = Vector3.new(0, 0, 0)
	end
	billboard(w2, Vector3.new(ox - 120, Y2 + 52, 80), "🌀 Samsara Space", Color3.fromRGB(100, 180, 255))
	part("TrialsArch", Vector3.new(16, 12, 4), Vector3.new(ox + 120, Y2 + 10, -80), Color3.fromRGB(120, 100, 160), Enum.Material.Rock, w2)
	signBoard(w2, Vector3.new(ox + 120, Y2 + 20, -80), Vector3.new(18, 4, 0.5), "Immortal Plain Trials [12 Floors]", Color3.fromRGB(210, 190, 255), Color3.fromRGB(30, 25, 40))
end

do
	for layer = 1, 33 do
		local t = (layer - 1) / 32
		local ly = Y2 + 50 + (layer - 1) * 40
		local dia = 200 - t * 100
		local col = Color3.fromRGB(math.floor(180 + t * 75), math.floor(210 + t * 45), math.floor(255 - t * 15))
		cyl("Heaven_" .. layer, dia, 6, Vector3.new(0, ly, -400), col, Enum.Material.SmoothPlastic, w2).Orientation = Vector3.new(0, 0, 0)
		cyl("HeavenPortal_" .. layer, 20, 2, Vector3.new(0, ly + 4, -400), col, Enum.Material.Neon, w2).Orientation = Vector3.new(0, 0, 0)
	end
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		part("HeavenColumn", Vector3.new(4, 1320, 4), Vector3.new(math.cos(a) * 90, Y2 + 50 + 660, -400 + math.sin(a) * 90), Color3.fromRGB(220, 230, 255), Enum.Material.Marble, w2)
	end
	local qy = Y2 + 50 + 32 * 40
	part("QiankunHall", Vector3.new(120, 40, 80), Vector3.new(0, qy + 24, -400), Color3.fromRGB(255, 220, 100), Enum.Material.Neon, w2)
	for i = 1, 12 do
		local a = (i - 1) / 12 * math.pi * 2
		part("LotusThrone", Vector3.new(6, 6, 6), Vector3.new(math.cos(a) * 40, qy + 8, -400 + math.sin(a) * 30), Color3.fromRGB(255, 240, 160), Enum.Material.Marble, w2)
	end
	billboard(w2, Vector3.new(0, qy + 54, -400), "🏛️ Qiankun Hall", Color3.fromRGB(255, 230, 130), "Sage Council", Color3.fromRGB(255, 250, 210))
end

do
	local ox, oz = -480, 200
	for i = 1, 5 do
		local a = (i / 5) * math.pi * 2
		local dia = rng:NextNumber(40, 100)
		cyl("EmperorIsle", dia, 10, Vector3.new(ox + math.cos(a) * 120, Y2 + 100 + math.sin(i) * 40, oz + math.sin(a) * 120), Color3.fromRGB(60, 50, 90), Enum.Material.Rock, w2).Orientation = Vector3.new(0, 0, 0)
	end
	cyl("CrowPlatform", 50, 6, Vector3.new(ox, Y2 + 100, oz), Color3.fromRGB(30, 25, 45), Enum.Material.Rock, w2).Orientation = Vector3.new(0, 0, 0)
	cyl("CrowRing", 52, 2, Vector3.new(ox, Y2 + 104, oz), Color3.fromRGB(140, 60, 200), Enum.Material.Neon, w2).Orientation = Vector3.new(0, 0, 0)
	billboard(w2, Vector3.new(ox, Y2 + 116, oz), "⚔️ Great Freedom Crow", Color3.fromRGB(180, 100, 240), "World Boss R16", Color3.fromRGB(220, 190, 255))
	cyl("HanJueDaoField", 60, 8, Vector3.new(ox - 80, Y2 + 160, oz - 80), Color3.fromRGB(40, 30, 60), Enum.Material.Rock, w2).Orientation = Vector3.new(0, 0, 0)
	cyl("DaoAura", 64, 2, Vector3.new(ox - 80, Y2 + 165, oz - 80), Color3.fromRGB(120, 60, 255), Enum.Material.Neon, w2).Orientation = Vector3.new(0, 0, 0)
	billboard(w2, Vector3.new(ox - 80, Y2 + 178, oz - 80), "☯️ Han Jue's Dao Field", Color3.fromRGB(150, 100, 255), "R16+", Color3.fromRGB(220, 200, 255))
	part("ChaosHorizon", Vector3.new(2000, 2, 8), Vector3.new(0, Y2 + 100, -900), Color3.fromRGB(10, 5, 20), Enum.Material.Neon, w2).CanCollide = false
end

portalArch(w2, "Portal_W2_to_W1", Vector3.new(av.X - 60, Y2 + 3, av.Z), Color3.fromRGB(120, 200, 120), "↓ Mortal Earth")
portalArch(w2, "Portal_W2_to_W3", Vector3.new(av.X + 60, Y2 + 3, av.Z), Color3.fromRGB(180, 100, 255), "↑ Sage Heaven (R16)")
questGiverFigure(w2, Vector3.new(av.X - 18, Y2 + 6, av.Z + 22), "🏮", "Immortal Envoy", Color3.fromRGB(180, 60, 60))
billboard(w2, Vector3.new(0, Y2 + 140, 0), "✦ IMMORTAL SKY", Color3.fromRGB(100, 255, 200), "Realm 10 — 15", Color3.fromRGB(255, 255, 255))

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 3 — SAGE HEAVEN  (Y = 3600)
-- ══════════════════════════════════════════════════════════════════════════════
local w3 = Instance.new("Folder"); w3.Name = "World3_SageHeaven"; w3.Parent = world

-- Main Sage Heaven island (walkable top at Y3+6, where the old floor was)
-- plus a satellite islet carrying the Supreme Platform pillar to the south.
makeIsland(0, Y3 + 2, 0,   512, TM.Grass, TM.Slate)
makeIsland(0, Y3 + 2, 420, 256, TM.Grass, TM.Slate)
cyl("SageGlow", 510, 3, Vector3.new(0, Y3 + 6, 0), Color3.fromRGB(120, 60, 255), Enum.Material.Neon, w3)

do
	part("MysticPalace", Vector3.new(120, 80, 120), Vector3.new(0, Y3 + 46, 0), Color3.fromRGB(30, 15, 60), Enum.Material.Marble, w3)
	ball("MysticCore", 40, Vector3.new(0, Y3 + 100, 0), Color3.fromRGB(200, 100, 255), Enum.Material.Neon, w3)
	local daoColors = { Color3.fromRGB(255, 215, 90), Color3.fromRGB(170, 100, 255), Color3.fromRGB(100, 220, 255) }
	for i = 1, 20 do
		local a = (i / 20) * math.pi * 2
		local r = rng:NextNumber(70, 130)
		local d = part("DaoLine", Vector3.new(2, 0.5, 80), Vector3.new(math.cos(a) * r, Y3 + rng:NextNumber(10, 80), math.sin(a) * r), daoColors[(i % 3) + 1], Enum.Material.Neon, w3)
		d.Orientation = Vector3.new(0, rng:NextNumber(0, 180), 0); d.CanCollide = false
	end
	local board = part("SageSeatsBoard", Vector3.new(40, 20, 1), Vector3.new(0, Y3 + 30, 66), Color3.fromRGB(40, 30, 20), Enum.Material.Marble, w3)
	board.CanCollide = false
	local sg = Instance.new("SurfaceGui"); sg.Name = "BoardSurface"; sg.Face = Enum.NormalId.Front; sg.Adornee = board; sg.Parent = board
	local lbl = Instance.new("TextLabel"); lbl.Name = "Status"; lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1; lbl.Text = "Sage Seats Available: 12/12"
	lbl.TextColor3 = Color3.fromRGB(255, 215, 120); lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBlack; lbl.Parent = sg
	CollectionService:AddTag(board, "SageSeatsBoard")
	for i = 1, 12 do
		local a = (i - 1) / 12 * math.pi * 2
		cyl("SageThrone", 8, 3, Vector3.new(math.cos(a) * 45, Y3 + 8, math.sin(a) * 45), Color3.fromRGB(60, 40, 90), Enum.Material.Marble, w3).Orientation = Vector3.new(0, 0, 0)
		ball("SageMarker", 5, Vector3.new(math.cos(a) * 45, Y3 + 14, math.sin(a) * 45), Color3.fromRGB(200, 150, 255), Enum.Material.Neon, w3)
	end
	billboard(w3, Vector3.new(0, Y3 + 130, 0), "⋆ Mystic Divine Palace", Color3.fromRGB(200, 120, 255), "R17 · Sage", Color3.fromRGB(240, 220, 255))
end

do
	local ox, oz = 300, -200
	for i = 1, 5 do
		local a = (i / 5) * math.pi * 2
		cyl("ZenithIsle", rng:NextNumber(30, 60), 8, Vector3.new(ox + math.cos(a) * 120, Y3 + rng:NextNumber(20, 80), oz + math.sin(a) * 120), Color3.fromRGB(60, 40, 100), Enum.Material.Rock, w3).Orientation = Vector3.new(0, 0, 0)
	end
	for i = 1, 8 do
		local a = (i / 8) * math.pi * 2
		local q = cyl("PrimordialPurpleQi", 2, 60, Vector3.new(ox + math.cos(a) * 80, Y3 + 40, oz + math.sin(a) * 80), Color3.fromRGB(180, 0, 255), Enum.Material.ForceField, w3)
		q.Orientation = Vector3.new(0, 0, 0); q.Transparency = 0.3
		CollectionService:AddTag(q, "PrimordialPurpleQi")
	end
	billboard(w3, Vector3.new(ox, Y3 + 110, oz), "💜 Primordial Chaos Purple Qi", Color3.fromRGB(200, 80, 255), "Ultra-rare · 0.01%", Color3.fromRGB(230, 190, 255))
	for _ = 1, 14 do
		local f = part("RealityFlicker", Vector3.new(rng:NextNumber(6, 14), rng:NextNumber(6, 14), 0.5), Vector3.new(ox + rng:NextNumber(-150, 150), Y3 + rng:NextNumber(20, 90), oz + rng:NextNumber(-150, 150)), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, w3)
		f.Transparency = 0.85; f.CanCollide = false
	end
end

do
	part("ChaosOcean", Vector3.new(2000, 2, 2000), Vector3.new(0, Y3 - 200, 0), Color3.fromRGB(6, 4, 14), Enum.Material.Neon, w3).CanCollide = false
	local daoColors = { Color3.fromRGB(255, 215, 90), Color3.fromRGB(100, 220, 255), Color3.fromRGB(170, 100, 255), Color3.fromRGB(255, 80, 80), Color3.fromRGB(100, 255, 150) }
	for i = 1, 30 do
		local a = (i / 30) * math.pi * 2
		local d = part("GreatDaoLine", Vector3.new(1.5, 1.5, rng:NextNumber(200, 400)), Vector3.new(math.cos(a) * 250, Y3 + rng:NextNumber(-100, 150), math.sin(a) * 250), daoColors[(i % 5) + 1], Enum.Material.Neon, w3)
		d.CFrame = CFrame.lookAt(d.Position, Vector3.new(0, Y3, 0)); d.CanCollide = false
	end
	local tp = Vector3.new(-300, Y3 + 6, 300)
	cyl("TranscendentPlatform", 40, 4, tp, Color3.fromRGB(40, 30, 60), Enum.Material.Rock, w3).Orientation = Vector3.new(0, 0, 0)
	cyl("TranscendentAura", 44, 2, tp + Vector3.new(0, 3, 0), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, w3).Orientation = Vector3.new(0, 0, 0)
	billboard(w3, tp + Vector3.new(0, 14, 0), "⚪ Transcendent Dao Expert", Color3.fromRGB(255, 255, 255))
end

do
	local sx, sz = 0, 300
	local plY = Y3 + 60
	part("SupremePillar", Vector3.new(12, 60, 12), Vector3.new(sx, Y3 + 30, sz), Color3.fromRGB(20, 0, 40), Enum.Material.Rock, w3)
	cyl("SupremePlatform", 100, 6, Vector3.new(sx, plY, sz), Color3.fromRGB(35, 15, 55), Enum.Material.Rock, w3).Orientation = Vector3.new(0, 0, 0)
	for i = 1, 4 do
		cyl("ForbiddenAura", 50 + i * 6, 1.5, Vector3.new(sx, plY + i * 6, sz), Color3.fromRGB(20, 0, 40), Enum.Material.Neon, w3).Orientation = Vector3.new(0, 0, 0)
	end
	for i = 0, 3 do
		local a = i / 4 * math.pi * 2
		cyl("MeritColumn", 3, 200, Vector3.new(sx + math.cos(a) * 30, plY + 100, sz + math.sin(a) * 30), Color3.fromRGB(255, 220, 60), Enum.Material.Neon, w3).Orientation = Vector3.new(0, 0, 0)
	end
	local book = part("BookOfMisfortuneShrine", Vector3.new(20, 25, 2), Vector3.new(sx, plY + 20, sz), Color3.fromRGB(255, 200, 60), Enum.Material.Neon, w3)
	book.CanCollide = false
	CollectionService:AddTag(book, "BookOfMisfortune")
	billboard(w3, Vector3.new(sx, plY + 36, sz), "📖 Book of Misfortune", Color3.fromRGB(255, 200, 60), "Daily Curse", Color3.fromRGB(255, 240, 200))
	cyl("HanJueSageThrone", 10, 4, Vector3.new(sx, plY + 5, sz - 30), Color3.fromRGB(80, 50, 110), Enum.Material.Marble, w3).Orientation = Vector3.new(0, 0, 0)
	billboard(w3, Vector3.new(sx, plY + 14, sz - 30), "☯️ Han Jue [Sage]", Color3.fromRGB(255, 210, 120))
end

cyl("W3ArrivalPad", 40, 6, Vector3.new(WorldData.WORLD_ARRIVAL[3].X, Y3 + 9, WorldData.WORLD_ARRIVAL[3].Z), Color3.fromRGB(120, 80, 160), Enum.Material.Marble, w3)
questGiverFigure(w3, Vector3.new(WorldData.WORLD_ARRIVAL[3].X + 20, Y3 + 12, WorldData.WORLD_ARRIVAL[3].Z + 18), "🔮", "Sage Oracle", Color3.fromRGB(110, 70, 160))
portalArch(w3, "Portal_W3_to_W2", Vector3.new(-240, Y3 + 6, 0), Color3.fromRGB(120, 200, 120), "↓ Immortal Sky")
portalArch(w3, "Portal_W3_to_W4", Vector3.new(240, Y3 + 6, 0), Color3.fromRGB(255, 60, 60), "↑ Primal Chaos (R23)")
billboard(w3, Vector3.new(0, Y3 + 200, 0), "⋆ SAGE HEAVEN", Color3.fromRGB(200, 100, 255), "Realm 16 — 22", Color3.fromRGB(255, 255, 255))

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 4 — PRIMAL CHAOS  (Y = 5400)
-- ══════════════════════════════════════════════════════════════════════════════
local w4 = Instance.new("Folder"); w4.Name = "World4_PrimalChaos"; w4.Parent = world

-- Primal Chaos: a black basalt main island (top at Y4+10, like the old floor)
-- and a detached islet to the west carrying the Chaotic Forbidden Zone.
makeIsland(0,    Y4 + 6, 0, 512, TM.Basalt, TM.Basalt)
makeIsland(-450, Y4 + 6, 0, 320, TM.Basalt, TM.Basalt)

local veinCols = {
	Color3.fromRGB(255, 30, 30), Color3.fromRGB(255, 120, 0), Color3.fromRGB(180, 0, 255),
	Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 220, 0),
}
for i = 1, 30 do
	local a = (i / 30) * math.pi * 2
	local r1 = rng:NextNumber(40, 280)
	local len = rng:NextNumber(40, 160)
	local mid = r1 + len / 2
	local v = part("ChaosVein", Vector3.new(3, 4, len), Vector3.new(math.cos(a) * mid, Y4 + 10, math.sin(a) * mid), veinCols[((i - 1) % #veinCols) + 1], Enum.Material.Neon, w4)
	v.CFrame = CFrame.lookAt(v.Position, Vector3.new(0, Y4 + 10, 0)); v.Size = Vector3.new(3, 4, len); v.CanCollide = false
end
for i = 1, 8 do
	local a = i / 8 * math.pi * 2
	local h = rng:NextNumber(80, 160)
	part("Monolith", Vector3.new(14, h, 14), Vector3.new(math.cos(a) * 320, Y4 + h / 2 + 10, math.sin(a) * 320), Color3.fromRGB(6, 3, 12), Enum.Material.Basalt, w4)
	ball("MonolithCrown", 16, Vector3.new(math.cos(a) * 320, Y4 + h + 18, math.sin(a) * 320), veinCols[((i - 1) % #veinCols) + 1], Enum.Material.Neon, w4)
end
for i = 1, 60 do
	local a = (i / 60) * math.pi * 2
	local col = Color3.fromHSV((i / 60) % 1, 0.9, 1)
	local d = part("DaoSkyBeam", Vector3.new(1, 1, rng:NextNumber(200, 500)), Vector3.new(math.cos(a) * 200, Y4 + 100 + rng:NextNumber(0, 200), math.sin(a) * 200), col, Enum.Material.Neon, w4)
	d.CFrame = CFrame.lookAt(d.Position, Vector3.new(0, Y4 + 100, 0)); d.CanCollide = false
end

do
	local av4 = WorldData.WORLD_ARRIVAL[4]
	cyl("BattlefieldPad", 50, 4, Vector3.new(av4.X, Y4 + 11, av4.Z), Color3.fromRGB(20, 10, 30), Enum.Material.Basalt, w4)
	for _ = 1, 6 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(60, 200)
		cyl("Crater", rng:NextNumber(20, 50), 4, Vector3.new(math.cos(a) * r, Y4 + 9, math.sin(a) * r), Color3.fromRGB(4, 2, 8), Enum.Material.Basalt, w4).Orientation = Vector3.new(0, 0, 0)
	end
	ball("PanguDaoWorld", 200, Vector3.new(400, Y4 + 200, 0), Color3.fromRGB(60, 40, 100), Enum.Material.ForceField, w4).Transparency = 0.3
	for i = 1, 8 do
		local a = (i - 1) / 8 * math.pi * 2
		part("EmperorThrone", Vector3.new(8, 12, 8), Vector3.new(math.cos(a) * 90, Y4 + 16, math.sin(a) * 90), Color3.fromRGB(30, 15, 45), Enum.Material.Rock, w4)
	end
	billboard(w4, Vector3.new(av4.X, Y4 + 40, av4.Z), "💥 Chaos Battlefield", Color3.fromRGB(255, 80, 100), "R24 · Dao Creator", Color3.fromRGB(255, 200, 200))
	local fzpos = Vector3.new(-450, Y4 + 10, 0)
	cyl("ForbiddenFloor", 300, 4, fzpos, Color3.fromRGB(2, 1, 4), Enum.Material.Basalt, w4).Orientation = Vector3.new(0, 0, 0)
	for _ = 1, 8 do
		local f = part("DarkFog", Vector3.new(rng:NextNumber(40, 80), 30, rng:NextNumber(40, 80)), fzpos + Vector3.new(rng:NextNumber(-120, 120), 20, rng:NextNumber(-120, 120)), Color3.fromRGB(0, 0, 0), Enum.Material.Slate, w4)
		f.Transparency = 0.4; f.CanCollide = false
	end
	local fz = part("ChaoticForbiddenZone", Vector3.new(20, 18, 4), fzpos + Vector3.new(150, 9, 0), Color3.fromRGB(60, 0, 0), Enum.Material.ForceField, w4)
	fz.Transparency = 0.5; fz.CanCollide = false
	CollectionService:AddTag(fz, "ChaoticForbiddenZone")
	signBoard(w4, fzpos + Vector3.new(150, 24, 0), Vector3.new(20, 4, 0.5), "⚠️ Chaotic Forbidden Zone — 10min", Color3.fromRGB(255, 60, 60), Color3.fromRGB(20, 0, 0))
end

do
	for _ = 1, 16 do
		local f = ball("VoidEnergy", rng:NextNumber(10, 30), Vector3.new(rng:NextNumber(-300, 300), Y4 + rng:NextNumber(60, 220), rng:NextNumber(-300, 300)), Color3.fromRGB(120, 80, 200), Enum.Material.ForceField, w4)
		f.Transparency = 0.7
	end
	for i = 1, 3 do
		local fx = -200 + i * 200
		part("Fiendcelestial", Vector3.new(10, 100, 10), Vector3.new(fx, Y4 + 150, -300), Color3.fromRGB(20, 10, 30), Enum.Material.Slate, w4)
		ball("FiendEye", 6, Vector3.new(fx, Y4 + 200, -296), Color3.fromRGB(180, 0, 255), Enum.Material.Neon, w4)
	end
	billboard(w4, Vector3.new(0, Y4 + 260, -300), "🌑 Primordial Fiendcelestials", Color3.fromRGB(200, 80, 255), "R25 · Creator Lord", Color3.fromRGB(230, 190, 255))
	local bw = part("BlankRealmHorizon", Vector3.new(3000, 1000, 2), Vector3.new(0, Y4 + 200, 700), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, w4)
	bw.Transparency = 0.4; bw.CanCollide = false
	local edge = part("BlankRealmEdge", Vector3.new(400, 40, 30), Vector3.new(0, Y4 + 30, 600), Color3.fromRGB(240, 240, 255), Enum.Material.ForceField, w4)
	edge.Transparency = 0.85; edge.CanCollide = false
	CollectionService:AddTag(edge, "BlankRealmEdge")
	billboard(w4, Vector3.new(0, Y4 + 70, 600), "∞ Blank Realm Edge", Color3.fromRGB(220, 220, 255), "Stand 1h → +1% all stats", Color3.fromRGB(240, 240, 255))
	cyl("HanHuangIsle", 30, 6, Vector3.new(-300, Y4 + 60, 200), Color3.fromRGB(40, 20, 50), Enum.Material.Rock, w4).Orientation = Vector3.new(0, 0, 0)
	billboard(w4, Vector3.new(-300, Y4 + 72, 200), "🔥 Han Huang", Color3.fromRGB(255, 90, 120), "Daily Quests", Color3.fromRGB(255, 200, 200))
end

do
	local oy = 5700
	cyl("OriginIsle", 200, 12, Vector3.new(0, oy, 600), Color3.fromRGB(240, 230, 200), Enum.Material.SmoothPlastic, w4)
	part("HanJueCaveAbode", Vector3.new(30, 20, 30), Vector3.new(0, oy + 16, 600), Color3.fromRGB(60, 50, 40), Enum.Material.Rock, w4)
	local holo = part("SystemInterface", Vector3.new(20, 12, 0.5), Vector3.new(0, oy + 16, 612), Color3.fromRGB(10, 20, 40), Enum.Material.Neon, w4)
	holo.CanCollide = false
	local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.Adornee = holo; sg.Parent = holo
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.fromScale(1, 1); lbl.BackgroundTransparency = 1
	lbl.Text = "◈ SYSTEM ◈\nRealm: 26 / Ultimate Origin\nLifespan: ∞\nStatus: Supreme"
	lbl.TextColor3 = Color3.fromRGB(120, 220, 255); lbl.TextScaled = true; lbl.Font = Enum.Font.Code; lbl.Parent = sg
	part("NinthChaos", Vector3.new(8, 24, 8), Vector3.new(40, oy + 18, 600), Color3.fromRGB(20, 10, 30), Enum.Material.Slate, w4)
	billboard(w4, Vector3.new(40, oy + 34, 600), "🌀 Ninth Chaos", Color3.fromRGB(160, 100, 220))
	ball("OriginBook", 14, Vector3.new(0, oy + 40, 600), Color3.fromRGB(255, 210, 60), Enum.Material.Neon, w4)
	billboard(w4, Vector3.new(0, oy + 52, 600), "👑 Ultimate Origin Realm", Color3.fromRGB(255, 220, 120), "R26 — Immortalized", Color3.fromRGB(255, 245, 210))
end

portalArch(w4, "Portal_W4_to_W3", Vector3.new(WorldData.WORLD_ARRIVAL[4].X, Y4 + 11, WorldData.WORLD_ARRIVAL[4].Z + 40), Color3.fromRGB(180, 100, 255), "↓ Sage Heaven")
questGiverFigure(w4, Vector3.new(WorldData.WORLD_ARRIVAL[4].X + 24, Y4 + 13, WorldData.WORLD_ARRIVAL[4].Z - 16), "🌑", "Chaos Warden", Color3.fromRGB(40, 30, 60))
billboard(w4, Vector3.new(0, Y4 + 360, 0), "✧ PRIMAL CHAOS", Color3.fromRGB(255, 40, 120), "Realm 23 — 26", Color3.fromRGB(255, 200, 200))

-- ══════════════════════════════════════════════════════════════════════════════
-- UPPER-WORLD REALM ZONES (R10-26) — one floating island per realm, ringing the
-- arrival area of its world. Positions come from WorldData.ZoneCenter so the
-- NPC spawns and teleports line up automatically.
-- ══════════════════════════════════════════════════════════════════════════════
local UPPER_STYLE: { [number]: { folder: Folder, top: Enum.Material, rock: Enum.Material } } = {
	[2] = { folder = w2, top = TM.LeafyGrass, rock = TM.Glacier },
	[3] = { folder = w3, top = TM.Grass,      rock = TM.Slate   },
	[4] = { folder = w4, top = TM.Basalt,     rock = TM.Basalt  },
}

for worldId = 2, 4 do
	local style = UPPER_STYLE[worldId]
	local wy = WorldData.WORLD_Y[worldId]
	for _, realmId in ipairs(WorldData.RealmsInWorld(worldId)) do
		local center = WorldData.ZoneCenter(realmId)   -- Y == wy
		local realm  = CultivationData.GetRealm(realmId)
		local theme  = WorldData.Theme(realmId)

		makeIsland(center.X, wy - 4, center.Z, 512, style.top, style.rock)

		local zone = Instance.new("Folder"); zone.Name = "Zone_" .. realmId; zone.Parent = style.folder
		cyl("Floor",  zr * 2,     zh, Vector3.new(center.X, wy + zh / 2, center.Z), theme.floor, Enum.Material.SmoothPlastic, zone)
		cyl("Border", zr * 2 + 6, 3,  Vector3.new(center.X, wy + zh, center.Z), theme.accent, Enum.Material.Neon, zone)
		for i = 0, 15 do
			local a = i / 16 * math.pi * 2
			part("Post", Vector3.new(2.5, 8, 2.5),
				Vector3.new(center.X + math.cos(a) * (zr - 2), wy + zh + 4, center.Z + math.sin(a) * (zr - 2)),
				theme.accent, Enum.Material.Neon, zone)
		end
		-- Themed decoration ring (spires + glow orbs in the zone's accent)
		for i = 0, 3 do
			local a = i / 4 * math.pi * 2 + 0.4
			local sx = center.X + math.cos(a) * (zr + 24)
			local sz = center.Z + math.sin(a) * (zr + 24)
			part("ZoneSpire", Vector3.new(5, 36, 5), Vector3.new(sx, wy + 18, sz), theme.floor, Enum.Material.Marble, zone)
			ball("ZoneSpireTop", 7, Vector3.new(sx, wy + 39, sz), theme.accent, Enum.Material.Neon, zone)
		end
		billboard(zone, Vector3.new(center.X, wy + zh + 30, center.Z),
			("R%d · %s"):format(realmId, realm and realm.name or "?"),
			theme.accent, theme.name, Color3.fromRGB(255, 255, 255))
	end
end

-- ══════════════════════════════════════════════════════════════════════════════
print(string.format("[TTP] World generated — W1 (Y=%d), W2 (Y=%d), W3 (Y=%d), W4 (Y=%d)", Y1, Y2, Y3, Y4))
