--!strict
-- TerrainGenerator.server.lua
-- Erzeugt eine xianxia-Kultivatoren-Welt: Bergring, Mittelplattform,
-- Seen, schwebende Inseln, spirituelle Kristalle und Atmosphäre.

local Workspace  = workspace
local Terrain    = Workspace.Terrain
local Lighting   = game:GetService("Lighting")

local M = Enum.Material

-- ── Atmosphäre & Beleuchtung ───────────────────────────────
Lighting.Ambient         = Color3.fromRGB(60, 45, 100)
Lighting.OutdoorAmbient  = Color3.fromRGB(90, 70, 140)
Lighting.Brightness      = 1.8
Lighting.ClockTime       = 6.5   -- Dämmerung / Morgen
Lighting.ShadowSoftness  = 0.5
Lighting.FogColor        = Color3.fromRGB(160, 130, 210)
Lighting.FogStart        = 180
Lighting.FogEnd          = 500

-- Atmosphere-Objekt für mystischen Dunst
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density  = 0.45
atmosphere.Offset   = 0.20
atmosphere.Color    = Color3.fromRGB(190, 160, 230)
atmosphere.Decay    = Color3.fromRGB(70, 50, 110)
atmosphere.Glare    = 0.15
atmosphere.Haze     = 2.5
atmosphere.Parent   = Lighting

-- ColorCorrection für goldenen xianxia-Look
local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
cc.Brightness  = 0.02
cc.Contrast    = 0.08
cc.Saturation  = 0.12
cc.TintColor   = Color3.fromRGB(255, 245, 220)
cc.Parent      = Lighting

-- ── Terrain-Hilfsfunktionen ────────────────────────────────
local function fillBox(x, y, z, sx, sy, sz, mat)
	Terrain:FillBlock(CFrame.new(x, y, z), Vector3.new(sx, sy, sz), mat)
end

local function fillSphere(x, y, z, r, mat)
	Terrain:FillBall(Vector3.new(x, y, z), r, mat)
end

local function fillCyl(x, y, z, h, r, mat)
	Terrain:FillCylinder(CFrame.new(x, y, z), h, r, mat)
end

-- ── 1. Basisboden ──────────────────────────────────────────
-- Gras-Ebene (600 × 600, 10 dick), Fels darunter
fillBox(0, -5,  0, 1200, 10, 1200, M.Grass)
fillBox(0, -15, 0, 1200, 10, 1200, M.Rock)
-- Leichte Hügel-Variation östlich und westlich
fillBox(200, 2, 0, 80, 6, 600, M.LeafyGrass)
fillBox(-200, 2, 0, 80, 6, 600, M.LeafyGrass)

-- ── 2. Zentraler Kultivierungs-Hof (erhöhte Steinplattform) ─
-- 120 × 120 Studs, 4 Studs über Boden
fillBox(0, 2, 0, 130, 4, 130, M.SmoothPlastic)
fillBox(0, 2, 0, 120, 3, 120, M.SmoothPlastic)
-- Kreuzförmige Pfade aus dunklem Stein
fillBox(0, 4.5, 0, 14, 1, 130, M.Concrete)  -- N-S
fillBox(0, 4.5, 0, 130, 1, 14, M.Concrete)  -- W-O

-- ── 3. Bergring (alle 4 Seiten) ────────────────────────────
-- Nord
fillBox(0,   0, -380, 900, 180, 200, M.Rock)
fillBox(0,  40, -440, 700, 220, 120, M.Rock)
fillBox(0,  80, -490, 400, 260,  80, M.Rock)
-- Süd
fillBox(0,   0,  380, 900, 180, 200, M.Rock)
fillBox(0,  40,  440, 700, 220, 120, M.Rock)
fillBox(0,  80,  490, 400, 260,  80, M.Rock)
-- West
fillBox(-380, 0, 0, 200, 180, 900, M.Rock)
fillBox(-440, 40, 0, 120, 220, 700, M.Rock)
-- Ost
fillBox( 380, 0, 0, 200, 180, 900, M.Rock)
fillBox( 440, 40, 0, 120, 220, 700, M.Rock)

-- Schnee-/Neon-Gipfel (glühende Kristalle an den Spitzen)
for _, pos in ipairs({ {0,-320}, {0,320}, {-320,0}, {320,0} }) do
	fillSphere(pos[1], 140, pos[2], 30, M.Glacier)
	fillSphere(pos[1], 155, pos[2], 18, M.Neon)  -- leuchtender Gipfel
end

-- ── 4. Spirituelle Seen (links und rechts) ─────────────────
-- Gruben zuerst mit Luft leeren, dann mit Wasser füllen
Terrain:FillBall(Vector3.new(160, -8, 0), 50, M.Air)
Terrain:FillBall(Vector3.new(160, -5, 0), 40, M.Water)
Terrain:FillBall(Vector3.new(-160, -8, 0), 50, M.Air)
Terrain:FillBall(Vector3.new(-160, -5, 0), 40, M.Water)

-- ── 5. Schwebende Inseln ────────────────────────────────────
local floatSpots = {
	{ x=0,    y=140, z=-200, r=35 },
	{ x=150,  y=110, z= 150, r=25 },
	{ x=-120, y=125, z=-120, r=28 },
	{ x=-160, y=160, z= 200, r=20 },
	{ x= 200, y=130, z=-100, r=22 },
}
for _, s in ipairs(floatSpots) do
	fillSphere(s.x, s.y, s.z,     s.r,           M.Rock)
	fillSphere(s.x, s.y + s.r * 0.6, s.z, s.r * 0.5, M.LeafyGrass)
	-- Kristall-Spitze auf jeder Insel
	fillBox(s.x, s.y + s.r + 4, s.z, 5, 12, 5, M.Neon)
end

-- ── 6. NPC-Bereich (nördlich des Hofs, flaches Gras) ───────
fillBox(0, 0, 160, 500, 2, 320, M.Grass)

-- ── 7. Dekorative Architektur (Parts) ──────────────────────
local decoFolder = Instance.new("Folder")
decoFolder.Name = "WorldDeco"
decoFolder.Parent = Workspace

local function makePart(name, pos, size, color, mat, anchored)
	local p = Instance.new("Part")
	p.Name     = name
	p.Size     = size
	p.Position = pos
	p.Anchored = true
	p.CanCollide = anchored ~= false
	p.BrickColor = BrickColor.new(color)
	p.Material   = mat
	p.Parent     = decoFolder
	return p
end

-- 8 Steinpfeiler um den Hof
local pillarPositions = {
	Vector3.new( 55, 14, 55), Vector3.new(-55, 14, 55),
	Vector3.new( 55, 14,-55), Vector3.new(-55, 14,-55),
	Vector3.new( 55, 14,  0), Vector3.new(-55, 14,  0),
	Vector3.new(  0, 14, 55), Vector3.new(  0, 14,-55),
}
for i, pos in ipairs(pillarPositions) do
	-- Pfeiler-Stamm
	local pillar = makePart("Pillar"..i, pos, Vector3.new(4, 28, 4), "Fossil", Enum.Material.SmoothPlastic)
	-- Leuchtende Pfeiler-Krone
	local crown = makePart("PillarCrown"..i, pos + Vector3.new(0, 16, 0), Vector3.new(5.5, 2, 5.5), "Fossil", Enum.Material.SmoothPlastic)
	local gem   = makePart("PillarGem"..i,   pos + Vector3.new(0, 18, 0), Vector3.new(2, 3, 2), "Cyan", Enum.Material.Neon)
	gem.CanCollide = false
	_ = pillar; _ = crown; _ = gem
end

-- Zentraler Qi-Altar (Mittelpunkt)
local altar = makePart("QiAltar", Vector3.new(0, 6, 0), Vector3.new(12, 3, 12), "Fossil", Enum.Material.SmoothPlastic)
local altarGlow = makePart("AltarGlow", Vector3.new(0, 8.5, 0), Vector3.new(6, 2, 6), "Cyan", Enum.Material.Neon)
altarGlow.CanCollide = false
local altarOrb  = makePart("AltarOrb",  Vector3.new(0, 11, 0), Vector3.new(4, 4, 4), "Cyan", Enum.Material.Neon)
altarOrb.CanCollide = false
local orbMesh = Instance.new("SpecialMesh"); orbMesh.MeshType = Enum.MeshType.Sphere; orbMesh.Parent = altarOrb
_ = altar; _ = altarGlow; _ = altarOrb

-- Torportal (Eingang von Süden)
local gateL = makePart("GateLeft",  Vector3.new(-18, 14, 65), Vector3.new(4, 28, 4), "Fossil", Enum.Material.SmoothPlastic)
local gateR = makePart("GateRight", Vector3.new( 18, 14, 65), Vector3.new(4, 28, 4), "Fossil", Enum.Material.SmoothPlastic)
local gateT = makePart("GateTop",   Vector3.new(  0, 28, 65), Vector3.new(40, 4, 4), "Fossil", Enum.Material.SmoothPlastic)
local gateSign = makePart("GateSign", Vector3.new(0, 35, 65), Vector3.new(28, 6, 2), "Reddish brown", Enum.Material.SmoothPlastic)
gateSign.CanCollide = false
_ = gateL; _ = gateR; _ = gateT; _ = gateSign

local signBg = Instance.new("SurfaceGui")
signBg.Face = Enum.NormalId.Front
signBg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
signBg.PixelsPerStud = 20
signBg.Parent = gateSign
local signLabel = Instance.new("TextLabel")
signLabel.Size = UDim2.fromScale(1, 1)
signLabel.BackgroundTransparency = 1
signLabel.Text = "修 仙 门"
signLabel.TextColor3 = Color3.fromHex("FCD34D")
signLabel.TextScaled = true
signLabel.Font = Enum.Font.GothamBlack
signLabel.Parent = signBg

-- Glühende Kristall-Säulen um die Seen
local crystalSpots = {
	{ 130, 2,  50 }, { 190, 2,  50 }, { 130, 2, -50 }, { 190, 2, -50 },
	{-130, 2,  50 }, {-190, 2,  50 }, {-130, 2, -50 }, {-190, 2, -50 },
}
for _, sp in ipairs(crystalSpots) do
	local c = makePart("Crystal", Vector3.new(sp[1], sp[2]+5, sp[3]), Vector3.new(2, 10, 2), "Cyan", Enum.Material.Neon)
	c.CanCollide = false
	local cm = Instance.new("SpecialMesh"); cm.MeshType = Enum.MeshType.Diamond; cm.Parent = c
end

print("[TTP] Terrain generiert.")
