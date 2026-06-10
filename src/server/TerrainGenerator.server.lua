--!strict
-- TerrainGenerator.server.lua
-- 4-layer xianxia world stacked on the Y axis:
--   World 1 "Mortal Earth"   (R1-9):  Y=0    — ring of 9 themed zones around a central hub
--   World 2 "Immortal Sky"   (R10+):  Y=1800 — floating jade archipelago
--   World 3 "Sage Heaven"    (R17+):  Y=3600 — neon energy sphere / divine halls
--   World 4 "Primal Chaos"   (R24+):  Y=5400 — basalt darkness with neon veins
-- World 1 positions match WorldData.ZoneCenter() exactly so NPCService aligns.

local Workspace = workspace
local Lighting  = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldData       = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("WorldData"))
local CultivationData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("CultivationData"))

-- ── Layer Y offsets ───────────────────────────────────────────────────────────
local Y1 =    0   -- Mortal Earth
local Y2 = 1800   -- Immortal Sky
local Y3 = 3600   -- Sage Heaven
local Y4 = 5400   -- Primal Chaos

-- ── Lighting ──────────────────────────────────────────────────────────────────
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

-- ── World folder ──────────────────────────────────────────────────────────────
local world = Workspace:FindFirstChild("World")
if world then world:Destroy() end
world = Instance.new("Folder"); world.Name = "World"; world.Parent = Workspace

-- ── Part helpers ──────────────────────────────────────────────────────────────
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

local function billboard3d(parent: Instance, pos: Vector3, line1: string, col1: Color3,
		line2: string, col2: Color3)
	local anchor = Instance.new("Part"); anchor.Anchored = true; anchor.CanCollide = false
	anchor.Transparency = 1; anchor.Size = Vector3.new(1,1,1); anchor.Position = pos
	anchor.Parent = parent
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.fromOffset(360, 76); bg.StudsOffset = Vector3.new(0,0,0)
	bg.AlwaysOnTop = false; bg.Adornee = anchor; bg.Parent = anchor
	local lbl1 = Instance.new("TextLabel"); lbl1.Size = UDim2.fromScale(1,0.58)
	lbl1.BackgroundTransparency = 1; lbl1.Text = line1; lbl1.TextColor3 = col1
	lbl1.TextScaled = true; lbl1.Font = Enum.Font.GothamBlack
	lbl1.TextStrokeTransparency = 0.3; lbl1.Parent = bg
	local lbl2 = Instance.new("TextLabel"); lbl2.Size = UDim2.fromScale(1,0.42)
	lbl2.Position = UDim2.fromScale(0,0.58); lbl2.BackgroundTransparency = 1
	lbl2.Text = line2; lbl2.TextColor3 = col2; lbl2.TextScaled = true
	lbl2.Font = Enum.Font.GothamMedium; lbl2.TextStrokeTransparency = 0.5; lbl2.Parent = bg
end

local function portalArch(zone: Instance, pos: Vector3, accentCol: Color3, label: string)
	local pL = part("PortalL", Vector3.new(3,20,3), pos + Vector3.new(-7,10,0), accentCol, Enum.Material.Neon, zone)
	local pR = part("PortalR", Vector3.new(3,20,3), pos + Vector3.new( 7,10,0), accentCol, Enum.Material.Neon, zone)
	part("PortalTop", Vector3.new(17,3,3), pos + Vector3.new(0,21,0), accentCol, Enum.Material.Neon, zone)
	ball("PortalGem", 5, pos + Vector3.new(0,24,0), Color3.fromRGB(255,255,255), Enum.Material.Neon, zone)
	billboard3d(zone, pos + Vector3.new(0,30,0), label,
		accentCol, "[ ENTER ]", Color3.fromRGB(220,220,220))
	_ = pL; _ = pR
end

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 1 — MORTAL EARTH  (Y = 0)
-- ══════════════════════════════════════════════════════════════════════════════
local w1 = Instance.new("Folder"); w1.Name = "World1_MortalEarth"; w1.Parent = world

-- Vast ground plate
part("W1Ground", Vector3.new(2000, 4, 2000), Vector3.new(0, Y1 - 2, 0),
	Color3.fromRGB(200, 240, 215), Enum.Material.Grass, w1)

-- Central hub
local hub     = WorldData.HUB_CENTER
local hubY    = Y1 + 4
local hubCtr  = Vector3.new(hub.X, hubY, hub.Z)
local hubZone = Instance.new("Folder"); hubZone.Name = "Hub"; hubZone.Parent = w1

cyl("HubPad",  WorldData.HUB_RADIUS * 2,     4, Vector3.new(hub.X, hubY/2 + Y1/2 + 2, hub.Z),
	Color3.fromRGB(255,200,230), Enum.Material.SmoothPlastic, hubZone)
cyl("HubRing", WorldData.HUB_RADIUS * 2 + 8, 2, Vector3.new(hub.X, hubY, hub.Z),
	Color3.fromRGB(255,120,180), Enum.Material.Neon, hubZone)
ball("HubGem",  12, hubCtr + Vector3.new(0,12,0), Color3.fromRGB(150,255,230), Enum.Material.Neon, hubZone)

for i = 0, 5 do
	local a = i / 6 * math.pi * 2
	local px = hub.X + math.cos(a) * (WorldData.HUB_RADIUS - 8)
	local pz = hub.Z + math.sin(a) * (WorldData.HUB_RADIUS - 8)
	part("HubPillar",    Vector3.new(4,22,4), Vector3.new(px, hubY+11, pz),
		Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, hubZone)
	ball("HubPillarTop", 6, Vector3.new(px, hubY+23, pz),
		Color3.fromRGB(150,255,230), Enum.Material.Neon, hubZone)
end

do  -- hub sign
	local sign = part("HubSign", Vector3.new(28,6,1),
		Vector3.new(hub.X, hubY+22, hub.Z), Color3.fromRGB(255,255,255),
		Enum.Material.SmoothPlastic, hubZone)
	sign.CanCollide = false
	local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front
	sg.AlwaysOnTop = false; sg.Parent = sign
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.fromScale(1,1)
	lbl.BackgroundTransparency = 1; lbl.Text = "☯️  CULTIVATION HUB"
	lbl.TextColor3 = Color3.fromRGB(120,60,160); lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBlack; lbl.Parent = sg
end

-- World 1 realm zones — positions match WorldData.ZoneCenter() exactly
for _, realmId in ipairs(WorldData.Realms()) do
	local center = WorldData.ZoneCenter(realmId)   -- Y=0 already from WorldData
	local theme  = WorldData.Theme(realmId)
	local realm  = CultivationData.GetRealm(realmId)
	local zr     = WorldData.ZONE_RADIUS
	local zh     = WorldData.ZONE_HEIGHT
	local zBase  = Y1 + zh / 2

	local zone = Instance.new("Folder"); zone.Name = "Zone_" .. realmId; zone.Parent = w1

	-- Platform + glow border
	cyl("Floor",  zr*2,   zh, Vector3.new(center.X, zBase,    center.Z), theme.floor,   Enum.Material.SmoothPlastic, zone)
	cyl("Border", zr*2+6, 3,  Vector3.new(center.X, Y1+zh,    center.Z), theme.accent,  Enum.Material.Neon, zone)

	-- Boundary posts
	for i = 0, 15 do
		local a = i / 16 * math.pi * 2
		local px = center.X + math.cos(a) * (zr - 2)
		local pz = center.Z + math.sin(a) * (zr - 2)
		part("Post", Vector3.new(2.5,8,2.5), Vector3.new(px, Y1+zh+4, pz),
			theme.accent, Enum.Material.Neon, zone)
	end

	-- Centre feature
	ball("ZoneOrb",   14, Vector3.new(center.X, Y1+zh+12, center.Z), theme.accent,         Enum.Material.Neon, zone)
	part("ZoneSpire",  Vector3.new(3,26,3), Vector3.new(center.X, Y1+zh+13, center.Z),
		Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, zone)

	-- Portal arch facing hub
	local dir = (Vector3.new(hub.X,0,hub.Z) - Vector3.new(center.X,0,center.Z))
	dir = dir.Magnitude > 0 and dir.Unit or Vector3.new(0,0,1)
	local gatePos = Vector3.new(center.X, Y1, center.Z) + dir * (zr - 4)
	portalArch(zone, gatePos, theme.accent,
		("R%d · %s"):format(realmId, realm and realm.name or "?"))

	-- Billboard above zone
	billboard3d(zone,
		Vector3.new(center.X, Y1+zh+32, center.Z),
		("R%d · %s"):format(realmId, realm and realm.name or "?"), theme.accent,
		theme.name, Color3.fromRGB(255,255,255))

	-- Candy bridge hub → gate
	local from = Vector3.new(hub.X, Y1, hub.Z) + dir * WorldData.HUB_RADIUS
	local to   = gatePos
	local mid  = (from + to) * 0.5
	local len  = (to - from).Magnitude
	local bridge = part("Bridge", Vector3.new(10, 2, len),
		Vector3.new(mid.X, Y1+zh-1, mid.Z), theme.floor, Enum.Material.SmoothPlastic, zone)
	bridge.CFrame = CFrame.lookAt(Vector3.new(mid.X,Y1+zh-1,mid.Z), Vector3.new(to.X,Y1+zh-1,to.Z))
	bridge.Size   = Vector3.new(10, 2, len)
end

-- Spawn at hub (World 1)
local sp = Workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
sp.Anchored = true; sp.Size = Vector3.new(12,1,12)
sp.Position = Vector3.new(hub.X, hubY+1, hub.Z)
sp.Transparency = 1; sp.CanCollide = false; sp.Neutral = true; sp.Parent = w1

-- Portal arch up to World 2 (on hub platform)
portalArch(hubZone, Vector3.new(hub.X + 30, hubY, hub.Z),
	Color3.fromRGB(80,220,200), "↑  IMMORTAL SKY  (R10+)")

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 2 — IMMORTAL SKY  (Y = 1800)
-- ══════════════════════════════════════════════════════════════════════════════
local w2 = Instance.new("Folder"); w2.Name = "World2_ImmortalSky"; w2.Parent = world
local W2Y = Y2

-- Main jade island
cyl("JadeIsle",    600,  30, Vector3.new(0, W2Y+15, 0),
	Color3.fromRGB(140,240,200), Enum.Material.SmoothPlastic, w2)
cyl("JadeRim",     616,   8, Vector3.new(0, W2Y+30, 0),
	Color3.fromRGB(80,220,160), Enum.Material.Neon, w2)
ball("JadePeak",   40,       Vector3.new(0, W2Y+80,  0),
	Color3.fromRGB(180,255,230), Enum.Material.Neon, w2)
part("JadePalace", Vector3.new(80,60,80), Vector3.new(0, W2Y+60, 0),
	Color3.fromRGB(220,255,245), Enum.Material.SmoothPlastic, w2)

-- Floating outer isles
local isleColors = {
	Color3.fromRGB(200,240,255), Color3.fromRGB(180,220,255),
	Color3.fromRGB(255,240,200), Color3.fromRGB(220,200,255),
	Color3.fromRGB(200,255,220), Color3.fromRGB(255,200,200),
}
for i = 1, 6 do
	local a   = (i-1) / 6 * math.pi * 2
	local rx  = math.cos(a) * 420
	local rz  = math.sin(a) * 420
	local ry  = W2Y + math.sin(i * 1.3) * 60
	cyl("FloatIsle" .. i, 120, 18, Vector3.new(rx, ry, rz),
		isleColors[i], Enum.Material.SmoothPlastic, w2)
	ball("IsleOrb" .. i,  20,     Vector3.new(rx, ry+24, rz),
		Color3.fromRGB(100,220,180), Enum.Material.Neon, w2)
	-- Connecting beam to centre
	local mid2  = Vector3.new(rx/2, (ry+W2Y+30)/2, rz/2)
	local len2  = math.sqrt(rx*rx + (ry-W2Y-30)*(ry-W2Y-30) + rz*rz)
	local beam  = part("IsleBeam" .. i, Vector3.new(4, len2, 4), mid2,
		Color3.fromRGB(80,220,200), Enum.Material.Neon, w2)
	beam.CFrame = CFrame.lookAt(mid2, Vector3.new(0, W2Y+30, 0)) *
		CFrame.Angles(math.pi/2, 0, 0)
	beam.Size   = Vector3.new(4, 4, len2)
end

-- 33-layer heaven staircase pillars circling up
for i = 1, 33 do
	local a  = i / 33 * math.pi * 2
	local px = math.cos(a) * 200
	local pz = math.sin(a) * 200
	local py = W2Y + 40 + i * 20
	part("HeavenPillar" .. i, Vector3.new(6, 30, 6), Vector3.new(px, py, pz),
		Color3.fromRGB(255, 255 - i*3, 200 - i*2), Enum.Material.SmoothPlastic, w2)
	ball("HeavenGlobe" .. i, 8, Vector3.new(px, py+20, pz),
		Color3.fromRGB(255,220,100), Enum.Material.Neon, w2)
end

-- Arrival pad & portal to World 1 and World 3
cyl("W2ArrivalPad", 60, 6, Vector3.new(-100, W2Y+3, 0),
	Color3.fromRGB(200,255,240), Enum.Material.SmoothPlastic, w2)
portalArch(w2, Vector3.new(-100, W2Y, 0),
	Color3.fromRGB(80,200,255), "↓ MORTAL EARTH  (R1-9)")
portalArch(w2, Vector3.new(100, W2Y, 0),
	Color3.fromRGB(180,100,255), "↑ SAGE HEAVEN  (R17+)")

billboard3d(w2, Vector3.new(0, W2Y+140, 0),
	"✦  IMMORTAL SKY", Color3.fromRGB(100,255,200),
	"Realm 10 — Realm 16", Color3.fromRGB(255,255,255))

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 3 — SAGE HEAVEN  (Y = 3600)
-- ══════════════════════════════════════════════════════════════════════════════
local w3 = Instance.new("Folder"); w3.Name = "World3_SageHeaven"; w3.Parent = world
local W3Y = Y3

-- Vast neon floor ring
cyl("SageFloor",  700, 8, Vector3.new(0, W3Y+4, 0),
	Color3.fromRGB(30,20,60), Enum.Material.SmoothPlastic, w3)
cyl("SageGlow",   710, 4, Vector3.new(0, W3Y+8, 0),
	Color3.fromRGB(120,60,255), Enum.Material.Neon, w3)

-- Dao energy hollow sphere (shell of orbiting balls)
for i = 1, 48 do
	local phi   = math.acos(1 - 2*(i-1)/47)
	local theta = math.pi * (1 + math.sqrt(5)) * (i-1)
	local sr    = 280
	local sx    = sr * math.sin(phi) * math.cos(theta)
	local sy    = sr * math.cos(phi)
	local sz    = sr * math.sin(phi) * math.sin(theta)
	ball("DaoSphere" .. i, 12, Vector3.new(sx, W3Y+280+sy, sz),
		Color3.fromHex(i % 2 == 0 and "A855F7" or "06B6D4"), Enum.Material.Neon, w3)
end

-- Zenith rings
for r = 1, 4 do
	local ry  = W3Y + 200 + r * 60
	local rdia = 600 - r * 80
	cyl("ZenithRing" .. r, rdia, 4, Vector3.new(0, ry, 0),
		Color3.fromHex(r % 2 == 0 and "C084FC" or "67E8F9"), Enum.Material.Neon, w3)
end

-- Orbiting crystal pillars
for i = 1, 12 do
	local a  = i / 12 * math.pi * 2
	local px = math.cos(a) * 240
	local pz = math.sin(a) * 240
	local py = W3Y + 40
	part("DaoPillar" .. i, Vector3.new(5, 80, 5), Vector3.new(px, py+40, pz),
		Color3.fromRGB(180, 80, 255), Enum.Material.Neon, w3)
	ball("DaoCrystal" .. i, 16, Vector3.new(px, py+90, pz),
		Color3.fromHex(i % 3 == 0 and "F0ABFC" or (i % 3 == 1 and "67E8F9" or "FDE68A")),
		Enum.Material.Neon, w3)
end

-- Central Sage Hall
part("SageHall", Vector3.new(100,100,100), Vector3.new(0, W3Y+50, 0),
	Color3.fromRGB(20,10,40), Enum.Material.SmoothPlastic, w3)
ball("SageCore",  60, Vector3.new(0, W3Y+120, 0),
	Color3.fromRGB(200,100,255), Enum.Material.Neon, w3)

-- Arrival pad & portals
cyl("W3ArrivalPad", 60, 6, Vector3.new(-200, W3Y+3, 0),
	Color3.fromRGB(180,140,255), Enum.Material.SmoothPlastic, w3)
portalArch(w3, Vector3.new(-200, W3Y, 0),
	Color3.fromRGB(80,200,255), "↓ IMMORTAL SKY  (R10-16)")
portalArch(w3, Vector3.new(200, W3Y, 0),
	Color3.fromRGB(255,50,50), "↑ PRIMAL CHAOS  (R24+)")

billboard3d(w3, Vector3.new(0, W3Y+380, 0),
	"⋆  SAGE HEAVEN", Color3.fromRGB(200,100,255),
	"Realm 17 — Realm 23", Color3.fromRGB(255,255,255))

-- ══════════════════════════════════════════════════════════════════════════════
-- WORLD 4 — PRIMAL CHAOS  (Y = 5400)
-- ══════════════════════════════════════════════════════════════════════════════
local w4 = Instance.new("Folder"); w4.Name = "World4_PrimalChaos"; w4.Parent = world
local W4Y = Y4

-- Black basalt ground
cyl("ChaosFloor", 800, 10, Vector3.new(0, W4Y+5, 0),
	Color3.fromRGB(12, 8, 20), Enum.Material.Basalt, w4)

-- Neon veins across the floor
local veinCols = {
	Color3.fromRGB(255,30,30), Color3.fromRGB(255,120,0), Color3.fromRGB(180,0,255),
	Color3.fromRGB(0,200,255), Color3.fromRGB(255,220,0),
}
for i = 1, 20 do
	local a  = i / 20 * math.pi * 2
	local r1 = 50 + math.random() * 300
	local r2 = r1 + 40 + math.random() * 120
	local mid3 = (r1 + r2) / 2
	local len3 = r2 - r1
	local col3 = veinCols[((i-1) % #veinCols) + 1]
	local vein = part("Vein" .. i, Vector3.new(3, 4, len3),
		Vector3.new(math.cos(a)*mid3, W4Y+10, math.sin(a)*mid3), col3, Enum.Material.Neon, w4)
	vein.CFrame = CFrame.lookAt(
		Vector3.new(math.cos(a)*mid3, W4Y+10, math.sin(a)*mid3),
		Vector3.new(0, W4Y+10, 0)
	)
	vein.Size = Vector3.new(3, 4, len3)
end

-- Chaos monolith towers
for i = 1, 8 do
	local a   = i / 8 * math.pi * 2
	local px  = math.cos(a) * 300
	local pz  = math.sin(a) * 300
	local h   = 80 + (i % 3) * 40
	part("Monolith" .. i, Vector3.new(14, h, 14), Vector3.new(px, W4Y+h/2+10, pz),
		Color3.fromRGB(8,4,16), Enum.Material.Basalt, w4)
	ball("MonolithTop" .. i, 18, Vector3.new(px, W4Y+h+19, pz),
		veinCols[((i-1) % #veinCols)+1], Enum.Material.Neon, w4)
end

-- Craters
for i = 1, 5 do
	local a   = i / 5 * math.pi * 2
	local cx  = math.cos(a) * 180
	local cz  = math.sin(a) * 180
	cyl("Crater" .. i, 80, 6, Vector3.new(cx, W4Y+7, cz),
		Color3.fromRGB(6,4,12), Enum.Material.Basalt, w4)
	cyl("CraterGlow" .. i, 82, 3, Vector3.new(cx, W4Y+10, cz),
		veinCols[i], Enum.Material.Neon, w4)
end

-- Origin Realm — the primordial sphere at the centre
ball("OriginCore",  120, Vector3.new(0, W4Y+200, 0),
	Color3.fromRGB(40, 0, 80), Enum.Material.Neon, w4)
ball("OriginShell", 140, Vector3.new(0, W4Y+200, 0),
	Color3.fromRGB(180,0,255), Enum.Material.ForceField, w4)
for i = 1, 6 do
	local a  = i / 6 * math.pi * 2
	local ox = math.cos(a) * 160
	local oz = math.sin(a) * 160
	ball("OriginSat" .. i, 30, Vector3.new(ox, W4Y+200, oz),
		veinCols[((i-1) % #veinCols)+1], Enum.Material.Neon, w4)
end

-- Arrival pad & portal back down
cyl("W4ArrivalPad", 60, 6, Vector3.new(-180, W4Y+3, 0),
	Color3.fromRGB(60,0,80), Enum.Material.SmoothPlastic, w4)
portalArch(w4, Vector3.new(-180, W4Y, 0),
	Color3.fromRGB(200,100,255), "↓ SAGE HEAVEN  (R17-23)")

billboard3d(w4, Vector3.new(0, W4Y+360, 0),
	"✧  PRIMAL CHAOS", Color3.fromRGB(255,40,120),
	"Realm 24 — Realm 26+", Color3.fromRGB(255,200,200))

-- ══════════════════════════════════════════════════════════════════════════════
-- HAN JUE'S SECRET SHRINE  (hidden corner of World 1)
-- ══════════════════════════════════════════════════════════════════════════════
local shrine = Instance.new("Folder"); shrine.Name = "SecretShrine"; shrine.Parent = w1
local sx, sz = -320, -320
cyl("ShrinePad",   30, 3, Vector3.new(sx, Y1+1.5, sz),
	Color3.fromRGB(20,20,40), Enum.Material.SmoothPlastic, shrine)
ball("ShrineOrb",  16, Vector3.new(sx, Y1+14,   sz),
	Color3.fromRGB(255,220,80), Enum.Material.Neon, shrine)
part("ShrinePillarF", Vector3.new(3,16,3), Vector3.new(sx-8, Y1+8, sz-8),
	Color3.fromRGB(80,60,120), Enum.Material.SmoothPlastic, shrine)
part("ShrinePillarB", Vector3.new(3,16,3), Vector3.new(sx+8, Y1+8, sz+8),
	Color3.fromRGB(80,60,120), Enum.Material.SmoothPlastic, shrine)
billboard3d(shrine, Vector3.new(sx, Y1+28, sz),
	"🌟  Han Jue's Shrine", Color3.fromRGB(255,220,80),
	"The Solitary Immortal", Color3.fromRGB(200,180,255))

-- ══════════════════════════════════════════════════════════════════════════════
print(string.format(
	"[TTP] World generated — W1 Mortal (Y=%d), W2 Immortal (Y=%d), W3 Sage (Y=%d), W4 Chaos (Y=%d)",
	Y1, Y2, Y3, Y4
))
