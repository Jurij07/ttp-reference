--!strict
-- TerrainGenerator.server.lua
-- Bright, candy-coloured "Bubblegum"-style world: pastel checkerboard ground,
-- rounded colourful hills, glossy lakes and floating candy islands. No realistic
-- grass — everything is smooth, saturated and cheerful.

local Workspace = workspace
local Lighting  = game:GetService("Lighting")

-- ── Lighting: bright, clear, slightly warm ─────────────────
Lighting.Ambient        = Color3.fromRGB(150, 150, 170)
Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 200)
Lighting.Brightness     = 3
Lighting.ClockTime      = 14
Lighting.ShadowSoftness = 1
Lighting.GlobalShadows  = true
Lighting.FogEnd         = 100000
-- Remove any leftover moody atmosphere/fog effects.
for _, inst in ipairs(Lighting:GetChildren()) do
	if inst:IsA("Atmosphere") or inst:IsA("ColorCorrectionEffect") or inst:IsA("BloomEffect") then
		inst:Destroy()
	end
end
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.5; bloom.Size = 24; bloom.Threshold = 0.9; bloom.Parent = Lighting

-- ── Helpers ────────────────────────────────────────────────
local worldFolder = Workspace:FindFirstChild("World")
if worldFolder then worldFolder:Destroy() end
worldFolder = Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = Workspace

local function part(name: string, size: Vector3, pos: Vector3, color: Color3, mat: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.Size = size; p.Position = pos
	p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = worldFolder
	return p
end

local function ball(name: string, d: number, pos: Vector3, color: Color3, mat: Enum.Material?): Part
	local p = part(name, Vector3.new(d, d, d), pos, color, mat)
	p.Shape = Enum.PartType.Ball
	return p
end

-- Candy palette
local PINK   = Color3.fromRGB(255, 150, 200)
local MINT   = Color3.fromRGB(150, 240, 210)
local SKY    = Color3.fromRGB(150, 210, 255)
local LEMON  = Color3.fromRGB(255, 235, 150)
local LILAC  = Color3.fromRGB(200, 170, 255)
local CORAL  = Color3.fromRGB(255, 175, 160)

-- ── 1. Pastel checkerboard ground ──────────────────────────
local TILE = 48
local TILES = 16            -- 16×16 tiles → ~768 studs square
local half = TILES * TILE / 2
local tints = { Color3.fromRGB(186, 235, 220), Color3.fromRGB(200, 240, 255) }
for ix = 0, TILES - 1 do
	for iz = 0, TILES - 1 do
		local c = tints[((ix + iz) % 2) + 1]
		local x = -half + TILE/2 + ix * TILE
		local z = -half + TILE/2 + iz * TILE
		part("Tile", Vector3.new(TILE, 4, TILE), Vector3.new(x, -2, z), c)
	end
end

-- ── 2. Rounded candy hills around the edges ────────────────
local hillColors = { PINK, MINT, SKY, LEMON, LILAC, CORAL }
local function hill(x: number, z: number, r: number, color: Color3)
	ball("Hill", r * 2, Vector3.new(x, -r * 0.45, z), color)
	ball("HillTop", r * 0.4, Vector3.new(x, r * 0.5, z), Color3.fromRGB(255, 90, 130), Enum.Material.Neon)
end
local ring = half - 30
for i = 0, 11 do
	local ang = (i / 12) * math.pi * 2
	hill(math.cos(ang) * ring, math.sin(ang) * ring, 30 + (i % 3) * 10, hillColors[(i % #hillColors) + 1])
end

-- ── 3. Glossy lakes ────────────────────────────────────────
local function lake(x: number, z: number, r: number)
	local p = part("Lake", Vector3.new(2, r * 2, r * 2), Vector3.new(x, 0.3, z), Color3.fromRGB(120, 200, 255), Enum.Material.Glass)
	p.Shape = Enum.PartType.Cylinder
	p.Orientation = Vector3.new(0, 0, 90)
	p.Transparency = 0.25
end
lake(-220, -180, 34)
lake(240, 200, 30)

-- ── 4. Floating candy islands ──────────────────────────────
local floatSpots = {
	{ x = 0,    z = -240, y = 90,  r = 26, c = LILAC },
	{ x = 190,  z = 150,  y = 70,  r = 20, c = MINT },
	{ x = -180, z = 130,  y = 80,  r = 22, c = PINK },
	{ x = 240,  z = -150, y = 100, r = 18, c = LEMON },
}
for _, s in ipairs(floatSpots) do
	ball("Island", s.r * 2, Vector3.new(s.x, s.y, s.z), s.c)
	ball("IslandTop", s.r * 1.3, Vector3.new(s.x, s.y + s.r * 0.5, s.z), MINT)
	part("Lolly", Vector3.new(2, 14, 2), Vector3.new(s.x, s.y + s.r + 7, s.z), Color3.fromRGB(255, 255, 255))
	ball("LollyTop", 8, Vector3.new(s.x, s.y + s.r + 16, s.z), CORAL, Enum.Material.Neon)
end

-- ── 5. Central spawn platform (glossy donut pad) ───────────
local pad = part("SpawnPad", Vector3.new(4, 60, 60), Vector3.new(0, 2, 0), Color3.fromRGB(255, 200, 230))
pad.Shape = Enum.PartType.Cylinder
pad.Orientation = Vector3.new(0, 0, 90)
ball("SpawnGem", 10, Vector3.new(0, 9, 0), Color3.fromRGB(150, 255, 230), Enum.Material.Neon)

-- Candy pillars around the pad
for i = 0, 5 do
	local ang = (i / 6) * math.pi * 2
	local x, z = math.cos(ang) * 36, math.sin(ang) * 36
	part("Pillar", Vector3.new(4, 24, 4), Vector3.new(x, 14, z), hillColors[(i % #hillColors) + 1])
	ball("PillarTop", 6, Vector3.new(x, 28, z), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
end

-- Make sure players spawn on the pad
local sp = Workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
sp.Anchored = true
sp.Size = Vector3.new(12, 1, 12)
sp.Position = Vector3.new(0, 4.5, 0)
sp.Transparency = 1
sp.CanCollide = false
sp.Neutral = true
sp.Parent = worldFolder

print("[TTP] Bubblegum world generated.")
