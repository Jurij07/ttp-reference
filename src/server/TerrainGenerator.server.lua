--!strict
-- TerrainGenerator.server.lua
-- Helles, kindliches Roblox-Terrain: große Fläche, bunte Berge,
-- einfaches Trainingslager. KEIN Nebel, KEIN realistisches Shading.

local Terrain  = workspace.Terrain
local Lighting = game:GetService("Lighting")
local M = Enum.Material

-- ── Helles, freundliches Licht (kein Nebel, keine Atmosphäre) ──
Lighting.Ambient        = Color3.fromRGB(130, 130, 130)
Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
Lighting.Brightness     = 3.0
Lighting.ClockTime      = 14   -- Nachmittag, helle Sonne
Lighting.ShadowSoftness = 0.3
Lighting.FogEnd         = 5000  -- praktisch kein Nebel
Lighting.FogStart       = 4000

-- Altes Atmosphere-Objekt entfernen, falls vorhanden
local oldAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
if oldAtmo then oldAtmo:Destroy() end
local oldCC = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if oldCC then oldCC:Destroy() end

-- ── Hilfsfunktionen ────────────────────────────────────────
local function box(x,y,z, sx,sy,sz, mat)
	Terrain:FillBlock(CFrame.new(x,y,z), Vector3.new(sx,sy,sz), mat)
end
local function sphere(x,y,z, r, mat)
	Terrain:FillBall(Vector3.new(x,y,z), r, mat)
end
local function part(name,pos,size,color,mat,anchor)
	local p = Instance.new("Part")
	p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true
	p.CanCollide = anchor~=false
	p.BrickColor = BrickColor.new(color)
	p.Material   = mat
	p.Parent     = workspace
	return p
end

-- ── 1. Großer flacher Grasboden (800×800) ──────────────────
box(0, -4, 0, 1600, 8, 1600, M.Grass)
box(0,-12, 0, 1600, 8, 1600, M.Rock)

-- ── 2. Einfache bunte Berge an den Rändern (Roblox-Stil) ───
-- Nord: leuchtend rot
box(0,  60, -440, 1000, 120, 140, M.SmoothPlastic)  -- Grundblock
box(0, 120, -460,  700, 120, 100, M.SmoothPlastic)  -- Stufe
box(0, 180, -480,  400, 100,  80, M.SmoothPlastic)  -- Spitze

-- Süd: leuchtend blau
box(0,  60,  440, 1000, 120, 140, M.SmoothPlastic)
box(0, 120,  460,  700, 120, 100, M.SmoothPlastic)
box(0, 180,  480,  400, 100,  80, M.SmoothPlastic)

-- West: leuchtend grün
box(-440, 60, 0, 140, 120, 1000, M.SmoothPlastic)
box(-460, 120, 0, 100, 120,  700, M.SmoothPlastic)
box(-480, 180, 0,  80, 100,  400, M.SmoothPlastic)

-- Ost: leuchtend gelb
box( 440, 60, 0, 140, 120, 1000, M.SmoothPlastic)
box( 460, 120, 0, 100, 120,  700, M.SmoothPlastic)
box( 480, 180, 0,  80, 100,  400, M.SmoothPlastic)

-- Berg-Farben über SurfaceAppearance (einfache BrickColor-Parts drüber)
-- Nord: Helle Ziegelrot-Parts
do
	local mtn = Instance.new("Part"); mtn.Anchored=true; mtn.Size=Vector3.new(980,118,138)
	mtn.Position=Vector3.new(0,60,-440); mtn.BrickColor=BrickColor.new("Bright red")
	mtn.Material=M.SmoothPlastic; mtn.CanCollide=true; mtn.Parent=workspace
	mtn.Name="MtnNorth"
	local top = Instance.new("Part"); top.Anchored=true; top.Size=Vector3.new(600,100,80)
	top.Position=Vector3.new(0,175,-475); top.BrickColor=BrickColor.new("White")
	top.Material=M.SmoothPlastic; top.CanCollide=true; top.Parent=workspace
end
do
	local mtn = Instance.new("Part"); mtn.Anchored=true; mtn.Size=Vector3.new(980,118,138)
	mtn.Position=Vector3.new(0,60,440); mtn.BrickColor=BrickColor.new("Bright blue")
	mtn.Material=M.SmoothPlastic; mtn.CanCollide=true; mtn.Parent=workspace
	mtn.Name="MtnSouth"
	local top = Instance.new("Part"); top.Anchored=true; top.Size=Vector3.new(600,100,80)
	top.Position=Vector3.new(0,175,475); top.BrickColor=BrickColor.new("White")
	top.Material=M.SmoothPlastic; top.CanCollide=true; top.Parent=workspace
end
do
	local mtn = Instance.new("Part"); mtn.Anchored=true; mtn.Size=Vector3.new(138,118,980)
	mtn.Position=Vector3.new(-440,60,0); mtn.BrickColor=BrickColor.new("Bright green")
	mtn.Material=M.SmoothPlastic; mtn.CanCollide=true; mtn.Parent=workspace
	mtn.Name="MtnWest"
	local top = Instance.new("Part"); top.Anchored=true; top.Size=Vector3.new(80,100,600)
	top.Position=Vector3.new(-475,175,0); top.BrickColor=BrickColor.new("White")
	top.Material=M.SmoothPlastic; top.CanCollide=true; top.Parent=workspace
end
do
	local mtn = Instance.new("Part"); mtn.Anchored=true; mtn.Size=Vector3.new(138,118,980)
	mtn.Position=Vector3.new(440,60,0); mtn.BrickColor=BrickColor.new("Bright yellow")
	mtn.Material=M.SmoothPlastic; mtn.CanCollide=true; mtn.Parent=workspace
	mtn.Name="MtnEast"
	local top = Instance.new("Part"); top.Anchored=true; top.Size=Vector3.new(80,100,600)
	top.Position=Vector3.new(475,175,0); top.BrickColor=BrickColor.new("White")
	top.Material=M.SmoothPlastic; top.CanCollide=true; top.Parent=workspace
end

-- ── 3. Zentrales Trainingslager ────────────────────────────
-- Erhöhte helle Plattform
box(0, 2, 0, 140, 4, 140, M.SmoothPlastic)
do
	local floor = part("TrainingFloor",Vector3.new(0,4,0),Vector3.new(130,2,130),"Light stone grey",M.SmoothPlastic)
	-- Kreuzlinien
	local lineN = part("LineN",Vector3.new(0,5.1,0),Vector3.new(6,0.2,130),"Medium stone grey",M.SmoothPlastic); lineN.CanCollide=false
	local lineW = part("LineW",Vector3.new(0,5.1,0),Vector3.new(130,0.2,6),"Medium stone grey",M.SmoothPlastic); lineW.CanCollide=false
	_ = floor; _ = lineN; _ = lineW
end

-- Kleines Tor (Eingang)
do
	local gL = part("GateLeft", Vector3.new(-18,16,65), Vector3.new(4,28,4),"Medium stone grey",M.SmoothPlastic)
	local gR = part("GateRight",Vector3.new( 18,16,65), Vector3.new(4,28,4),"Medium stone grey",M.SmoothPlastic)
	local gT = part("GateTop",  Vector3.new(  0,30,65), Vector3.new(40,4,4),"Bright red",M.SmoothPlastic)
	local gS = part("GateSign", Vector3.new(  0,36,65), Vector3.new(30,6,2),"Bright red",M.SmoothPlastic); gS.CanCollide=false
	local sg = Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Front; sg.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; sg.PixelsPerStud=20; sg.Parent=gS
	local sl = Instance.new("TextLabel"); sl.Size=UDim2.fromScale(1,1); sl.BackgroundTransparency=1
	sl.Text="修 仙 门"; sl.TextColor3=Color3.fromRGB(255,220,0); sl.TextScaled=true; sl.Font=Enum.Font.GothamBlack; sl.Parent=sg
	_ = gL; _ = gR; _ = gT
end

-- 8 bunte Pfeiler um die Plattform
local pillarColors = {"Bright red","Bright blue","Bright green","Bright yellow","Cyan","Lime green","Hot pink","White"}
local pillarPos = {
	Vector3.new(58,16,58),  Vector3.new(-58,16,58),
	Vector3.new(58,16,-58), Vector3.new(-58,16,-58),
	Vector3.new(58,16,0),   Vector3.new(-58,16,0),
	Vector3.new(0,16,58),   Vector3.new(0,16,-58),
}
for i,pos in ipairs(pillarPos) do
	local c = pillarColors[(i-1)%#pillarColors+1]
	local p = part("Pillar"..i, pos, Vector3.new(4,28,4), c, M.SmoothPlastic)
	local crown = part("Crown"..i, pos+Vector3.new(0,16,0), Vector3.new(6,3,6), c, M.SmoothPlastic)
	local gem   = part("Gem"..i,   pos+Vector3.new(0,19,0), Vector3.new(2,4,2), "White", M.Neon)
	gem.CanCollide=false; _ = p; _ = crown; _ = gem
end

-- Zentraler Qi-Altar
do
	local base  = part("Altar",     Vector3.new(0,7,0),   Vector3.new(14,4,14),  "Medium stone grey",M.SmoothPlastic)
	local mid   = part("AltarMid",  Vector3.new(0,10,0),  Vector3.new(8,3,8),    "Light stone grey", M.SmoothPlastic)
	local orb   = part("AltarOrb",  Vector3.new(0,13.5,0),Vector3.new(5,5,5),    "Cyan",             M.Neon)
	local mesh  = Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=orb
	orb.CanCollide=false; _ = base; _ = mid
end

-- ── 4. Klare blaue Seen (links und rechts) ─────────────────
sphere(160, -6, 0, 45, M.Air)
sphere(160, -3, 0, 36, M.Water)
sphere(-160,-6, 0, 45, M.Air)
sphere(-160,-3, 0, 36, M.Water)

-- Bunte Ränder um die Seen
do
	local rim1 = part("LakeRim1",Vector3.new(160,0,0),Vector3.new(100,4,100),"Bright blue",M.SmoothPlastic); rim1.CanCollide=false
	local rim2 = part("LakeRim2",Vector3.new(-160,0,0),Vector3.new(100,4,100),"Bright blue",M.SmoothPlastic); rim2.CanCollide=false
	_ = rim1; _ = rim2
end

-- ── 5. Schwebende Inseln (einfache bunte Blöcke) ───────────
local islandData = {
	{ x=0,    y=130, z=-200, r=30, col="Bright orange" },
	{ x=160,  y=100, z= 150, r=22, col="Bright violet" },
	{ x=-130, y=115, z=-130, r=25, col="Lime green"    },
	{ x=-150, y=150, z= 180, r=18, col="Cyan"          },
	{ x= 180, y=120, z=-100, r=20, col="Bright yellow" },
}
for i,d in ipairs(islandData) do
	sphere(d.x, d.y, d.z, d.r, M.Rock)
	-- Bunte Part-Oberfläche
	local ip = part("Island"..i, Vector3.new(d.x, d.y + d.r*0.6, d.z),
		Vector3.new(d.r*1.2, d.r*0.4, d.r*1.2), d.col, M.SmoothPlastic)
	ip.CanCollide = false
	-- Kleiner Neon-Kristall oben
	local ik = part("IslKrystal"..i, Vector3.new(d.x, d.y + d.r + 6, d.z),
		Vector3.new(3, 10, 3), "White", M.Neon)
	ik.CanCollide = false
end

-- ── 6. NPC-Bereich (großes flaches Gras nördlich des Hofs) ─
-- Helles gelbes Gras-Band um den Spawn-Bereich
box(0, 0, 250, 700, 2, 500, M.Grass)
do
	local npcFloor = part("NPCZone",Vector3.new(0,1,250),Vector3.new(680,2,480),"Bright yellow",M.SmoothPlastic)
	npcFloor.BrickColor = BrickColor.new("Pastel yellow")
	npcFloor.CanCollide = true; npcFloor.Transparency = 0.85
end

-- ── 7. Farbige Wegmarkierungen ─────────────────────────────
-- Weg vom Gate zum NPC-Bereich
box(0, 1, 140, 12, 2, 200, M.SmoothPlastic)
do
	local path = part("MainPath",Vector3.new(0,2,140),Vector3.new(10,2,200),"Medium stone grey",M.SmoothPlastic)
	path.CanCollide = true
end

print("[TTP] Terrain (kindlich/schlicht) generiert.")
