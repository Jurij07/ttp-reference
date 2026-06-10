--!strict
-- TerrainGenerator.server.lua
-- Bright "Bubblegum"-style world built from a central hub plus one themed,
-- clearly-bounded zone per realm arranged in a ring. Layout positions come from
-- WorldData so NPCs and teleports line up exactly. Each zone has its own floor
-- colour, a glowing boundary ring, a name sign, themed pillars and a portal gate
-- connected to the hub by a candy bridge.

local Workspace = workspace
local Lighting  = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("WorldData"))
local CultivationData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("CultivationData"))

-- ── Lighting: bright and clear ─────────────────────────────
Lighting.Ambient        = Color3.fromRGB(150,150,170)
Lighting.OutdoorAmbient = Color3.fromRGB(180,180,200)
Lighting.Brightness     = 3
Lighting.ClockTime      = 14
Lighting.ShadowSoftness = 1
Lighting.GlobalShadows  = true
Lighting.FogEnd         = 100000
for _, inst in ipairs(Lighting:GetChildren()) do
	if inst:IsA("Atmosphere") or inst:IsA("ColorCorrectionEffect") or inst:IsA("BloomEffect") then inst:Destroy() end
end
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.4; bloom.Size = 24; bloom.Threshold = 0.95; bloom.Parent = Lighting

-- ── World folder ───────────────────────────────────────────
local world = Workspace:FindFirstChild("World")
if world then world:Destroy() end
world = Instance.new("Folder"); world.Name = "World"; world.Parent = Workspace

local function part(name: string, size: Vector3, pos: Vector3, color: Color3, mat: Enum.Material?, parent: Instance?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.Size = size; p.Position = pos
	p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or world
	return p
end
local function cyl(name: string, dia: number, height: number, pos: Vector3, color: Color3, mat: Enum.Material?, parent: Instance?): Part
	local p = part(name, Vector3.new(dia, height, dia), pos, color, mat, parent)
	p.Shape = Enum.PartType.Cylinder
	p.Orientation = Vector3.new(0, 0, 90)
	return p
end
local function ball(name: string, dia: number, pos: Vector3, color: Color3, mat: Enum.Material?, parent: Instance?): Part
	local p = part(name, Vector3.new(dia, dia, dia), pos, color, mat, parent)
	p.Shape = Enum.PartType.Ball
	return p
end

-- ── Backdrop ground (far below, so the world floats brightly) ─
part("Backdrop", Vector3.new(2000, 4, 2000), Vector3.new(0, -40, 0), Color3.fromRGB(205,240,255))

-- ── Central hub (spawn) ────────────────────────────────────
local hub = WorldData.HUB_CENTER
local hubZone = Instance.new("Folder"); hubZone.Name = "Hub"; hubZone.Parent = world
cyl("HubPad", WorldData.HUB_RADIUS * 2, 4, Vector3.new(hub.X, 2, hub.Z), Color3.fromRGB(255,200,230), Enum.Material.SmoothPlastic, hubZone)
cyl("HubRing", WorldData.HUB_RADIUS * 2 + 8, 2, Vector3.new(hub.X, 4, hub.Z), Color3.fromRGB(255,120,180), Enum.Material.Neon, hubZone)
ball("HubGem", 12, Vector3.new(hub.X, 12, hub.Z), Color3.fromRGB(150,255,230), Enum.Material.Neon, hubZone)
for i = 0, 5 do
	local a = i / 6 * math.pi * 2
	local x, z = hub.X + math.cos(a) * (WorldData.HUB_RADIUS - 8), hub.Z + math.sin(a) * (WorldData.HUB_RADIUS - 8)
	part("HubPillar", Vector3.new(4, 22, 4), Vector3.new(x, 15, z), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, hubZone)
	ball("HubPillarTop", 6, Vector3.new(x, 27, z), Color3.fromRGB(150,255,230), Enum.Material.Neon, hubZone)
end
-- Hub sign
do
	local sign = part("HubSign", Vector3.new(24, 6, 1), Vector3.new(hub.X, 24, hub.Z), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, hubZone)
	sign.CanCollide = false
	local gui = Instance.new("SurfaceGui"); gui.Face = Enum.NormalId.Front; gui.AlwaysOnTop = false; gui.Parent = sign
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.fromScale(1,1); lbl.BackgroundTransparency = 1
	lbl.Text = "☯️ CULTIVATION HUB"; lbl.TextColor3 = Color3.fromRGB(120,60,160); lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBlack; lbl.Parent = gui
end

-- ── Realm zones (one per implemented realm) ────────────────
for _, realmId in ipairs(WorldData.Realms()) do
	local center = WorldData.ZoneCenter(realmId)
	local theme  = WorldData.Theme(realmId)
	local realm  = CultivationData.GetRealm(realmId)
	local zr     = WorldData.ZONE_RADIUS

	local zone = Instance.new("Folder"); zone.Name = "Zone_" .. realmId; zone.Parent = world

	-- Platform + glowing boundary ring (the "abgrenzung")
	cyl("Floor", zr * 2, WorldData.ZONE_HEIGHT, Vector3.new(center.X, WorldData.ZONE_HEIGHT/2, center.Z), theme.floor, Enum.Material.SmoothPlastic, zone)
	cyl("Border", zr * 2 + 6, 3, Vector3.new(center.X, WorldData.ZONE_HEIGHT, center.Z), theme.accent, Enum.Material.Neon, zone)

	-- Low boundary wall posts around the rim (visual fence)
	local posts = 16
	for i = 0, posts - 1 do
		local a = i / posts * math.pi * 2
		local x, z = center.X + math.cos(a) * (zr - 2), center.Z + math.sin(a) * (zr - 2)
		part("Post", Vector3.new(2.5, 8, 2.5), Vector3.new(x, WorldData.ZONE_HEIGHT + 4, z), theme.accent, Enum.Material.Neon, zone)
	end

	-- Themed centre feature
	ball("ZoneOrb", 14, Vector3.new(center.X, WorldData.ZONE_HEIGHT + 12, center.Z), theme.accent, Enum.Material.Neon, zone)
	part("ZoneSpire", Vector3.new(3, 24, 3), Vector3.new(center.X, WorldData.ZONE_HEIGHT + 12, center.Z), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, zone)

	-- Portal gate facing the hub
	local dir = (Vector3.new(hub.X,0,hub.Z) - Vector3.new(center.X,0,center.Z))
	dir = dir.Magnitude > 0 and dir.Unit or Vector3.new(0,0,1)
	local gatePos = Vector3.new(center.X,0,center.Z) + dir * (zr - 4)
	local gateL = part("GateL", Vector3.new(3, 20, 3), gatePos + Vector3.new(6,10,0), theme.accent, Enum.Material.Neon, zone)
	local gateR = part("GateR", Vector3.new(3, 20, 3), gatePos + Vector3.new(-6,10,0), theme.accent, Enum.Material.Neon, zone)
	_ = gateL; _ = gateR

	-- Name sign above the zone
	local signPos = Vector3.new(center.X, WorldData.ZONE_HEIGHT + 30, center.Z)
	local bb = Instance.new("Part"); bb.Anchored = true; bb.CanCollide = false; bb.Transparency = 1
	bb.Size = Vector3.new(1,1,1); bb.Position = signPos; bb.Parent = zone
	local billboard = Instance.new("BillboardGui"); billboard.Size = UDim2.fromOffset(320, 70)
	billboard.StudsOffset = Vector3.new(0, 0, 0); billboard.AlwaysOnTop = false; billboard.Adornee = bb; billboard.Parent = bb
	local nameL = Instance.new("TextLabel"); nameL.Size = UDim2.fromScale(1,0.6); nameL.BackgroundTransparency = 1
	nameL.Text = ("R%d · %s"):format(realmId, realm and realm.name or "?"); nameL.TextColor3 = theme.accent
	nameL.TextScaled = true; nameL.Font = Enum.Font.GothamBlack; nameL.TextStrokeTransparency = 0.4; nameL.Parent = billboard
	local subL = Instance.new("TextLabel"); subL.Size = UDim2.fromScale(1,0.4); subL.Position = UDim2.fromScale(0,0.6)
	subL.BackgroundTransparency = 1; subL.Text = theme.name; subL.TextColor3 = Color3.fromRGB(255,255,255)
	subL.TextScaled = true; subL.Font = Enum.Font.GothamMedium; subL.TextStrokeTransparency = 0.5; subL.Parent = billboard

	-- Candy bridge from hub edge toward the zone gate
	local bridgeStart = Vector3.new(hub.X,0,hub.Z) + dir * -1 * (WorldData.HUB_RADIUS - 2) * -1  -- toward zone
	local from = Vector3.new(hub.X,0,hub.Z) + dir * (WorldData.HUB_RADIUS)
	local to   = gatePos
	local mid  = (from + to) / 2
	local len  = (to - from).Magnitude
	local bridge = part("Bridge", Vector3.new(10, 2, len), Vector3.new(mid.X, WorldData.ZONE_HEIGHT - 1, mid.Z), theme.floor, Enum.Material.SmoothPlastic, zone)
	bridge.CFrame = CFrame.lookAt(Vector3.new(mid.X, WorldData.ZONE_HEIGHT - 1, mid.Z), Vector3.new(to.X, WorldData.ZONE_HEIGHT - 1, to.Z))
	bridge.Size = Vector3.new(10, 2, len)
	_ = bridgeStart
end

-- ── Spawn at the hub ───────────────────────────────────────
local sp = Workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
sp.Anchored = true; sp.Size = Vector3.new(12,1,12); sp.Position = Vector3.new(hub.X, 5, hub.Z)
sp.Transparency = 1; sp.CanCollide = false; sp.Neutral = true; sp.Parent = world

print("[TTP] World generated: hub + " .. #WorldData.Realms() .. " realm zones.")
