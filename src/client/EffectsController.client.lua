--!strict
-- EffectsController.client.lua
-- Visual/UI effects for the world systems: ascension flashes, server-wide
-- announcements, tribulation lightning, the Chaotic Forbidden Zone timer, the
-- Sage seat / shrine feedback, the Wall of Eternity surface, the passive Qi
-- mist in World 1, and the golden barrier-rejection vignette.
--
-- This script owns its own ScreenGui so it never touches UIController (which is
-- at the Luau local-register limit).

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Debris            = game:GetService("Debris")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local WorldData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("WorldData"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Own ScreenGui ─────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "TTP_Effects"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 20; gui.Parent = playerGui

local function newLabel(parent: Instance, text: string, col: Color3, ts: number): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = col
	l.TextScaled = false; l.TextSize = ts; l.Font = Enum.Font.GothamBlack
	l.TextStrokeTransparency = 0.4; l.Parent = parent
	return l
end

-- ── Server announcement banner ────────────────────────────────────────────────
local announceHolder = Instance.new("Frame")
announceHolder.Size = UDim2.new(1, 0, 0, 56); announceHolder.Position = UDim2.new(0, 0, 0, -60)
announceHolder.BackgroundColor3 = Color3.fromRGB(12, 10, 6); announceHolder.BackgroundTransparency = 0.1
announceHolder.BorderSizePixel = 0; announceHolder.Visible = false; announceHolder.ZIndex = 30
announceHolder.Parent = gui
local announceStroke = Instance.new("UIStroke"); announceStroke.Color = Color3.fromRGB(245, 200, 90)
announceStroke.Thickness = 1.5; announceStroke.Parent = announceHolder
local announceLabel = newLabel(announceHolder, "", Color3.fromRGB(245, 210, 120), 20)
announceLabel.Size = UDim2.fromScale(1, 1); announceLabel.ZIndex = 31

local announceQueue: { string } = {}
local announcing = false

local function runAnnounce()
	if announcing then return end
	announcing = true
	task.spawn(function()
		while #announceQueue > 0 do
			local msg = table.remove(announceQueue, 1)
			announceLabel.Text = msg
			announceHolder.Visible = true
			TweenService:Create(announceHolder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) }):Play()
			task.wait(3)
			TweenService:Create(announceHolder, TweenInfo.new(0.4),
				{ Position = UDim2.new(0, 0, 0, -60) }):Play()
			task.wait(0.5)
		end
		announceHolder.Visible = false
		announcing = false
	end)
end

Net.Event("ServerAnnounce").OnClientEvent:Connect(function(message: string)
	table.insert(announceQueue, message)
	runAnnounce()
end)

-- ── World ascension flash ─────────────────────────────────────────────────────
Net.Event("WorldAscension").OnClientEvent:Connect(function(worldNum: number)
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1); flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flash.BackgroundTransparency = 0; flash.BorderSizePixel = 0; flash.ZIndex = 40; flash.Parent = gui
	local name = WorldData.WORLD_NAME[worldNum] or "?"
	local title = newLabel(gui, "ENTERING " .. string.upper(name), Color3.fromRGB(255, 245, 220), 40)
	title.Size = UDim2.new(1, 0, 0, 60); title.Position = UDim2.fromScale(0, 0.44)
	title.TextXAlignment = Enum.TextXAlignment.Center; title.ZIndex = 41
	TweenService:Create(flash, TweenInfo.new(1.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(title, TweenInfo.new(2), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(flash, 1.6); Debris:AddItem(title, 2.1)
end)

-- ── First ascension (Heaven's Gate) golden pillars + toast ────────────────────
local function goldenPillars()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		local beam = Instance.new("Part"); beam.Anchored = true; beam.CanCollide = false
		beam.Shape = Enum.PartType.Cylinder; beam.Material = Enum.Material.Neon
		beam.Color = Color3.fromRGB(255, 220, 120); beam.Size = Vector3.new(120, 4, 4)
		beam.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(a) * 8, 50, math.sin(a) * 8))
			* CFrame.Angles(0, 0, math.rad(90))
		beam.Parent = workspace
		TweenService:Create(beam, TweenInfo.new(3), { Transparency = 1 }):Play()
		Debris:AddItem(beam, 3.1)
	end
end

local function toast(message: string)
	-- Simple self-contained toast in the bottom-centre.
	local t = newLabel(gui, message, Color3.fromRGB(245, 210, 120), 18)
	t.Size = UDim2.new(0, 480, 0, 30); t.AnchorPoint = Vector2.new(0.5, 1)
	t.Position = UDim2.new(0.5, 0, 0.82, 0); t.TextXAlignment = Enum.TextXAlignment.Center
	t.ZIndex = 32
	task.delay(3, function()
		TweenService:Create(t, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		task.wait(0.6); t:Destroy()
	end)
end

Net.Event("FirstAscension").OnClientEvent:Connect(function()
	goldenPillars()
	toast("✨ Welcome, Immortal — you have ascended through Heaven's Gate!")
end)

-- WorldLevel attribute also flashes a toast (covers other ascensions).
player:GetAttributeChangedSignal("WorldLevel"):Connect(function()
	local v = player:GetAttribute("WorldLevel")
	if typeof(v) == "number" and v >= 2 then
		toast(("✨ You have ascended to the %s!"):format(WorldData.WORLD_NAME[v] or "next world"))
	end
end)

-- ── Tribulation Peak lightning bolt ───────────────────────────────────────────
Net.Event("LightningEffect").OnClientEvent:Connect(function()
	local w = workspace:FindFirstChild("World")
	local w1 = w and w:FindFirstChild("World1_MortalEarth")
	local zone5 = w1 and w1:FindFirstChild("Zone_5")
	local peak = zone5 and zone5:GetAttribute("PeakPosition")
	local basePos = (typeof(peak) == "Vector3" and peak) or Vector3.new(0, 24, 300)
	local bolt = Instance.new("Part"); bolt.Anchored = true; bolt.CanCollide = false
	bolt.Material = Enum.Material.Neon; bolt.Color = Color3.fromRGB(255, 220, 60)
	bolt.Size = Vector3.new(4, 500, 4); bolt.Position = basePos + Vector3.new(0, 250, 0)
	bolt.Parent = workspace
	TweenService:Create(bolt, TweenInfo.new(2), { Transparency = 1, Size = Vector3.new(1, 500, 1) }):Play()
	Debris:AddItem(bolt, 2.1)
end)

-- ── Chaotic Forbidden Zone timer ──────────────────────────────────────────────
local zoneTimer: TextLabel? = nil
Net.Event("ForbiddenZoneTimer").OnClientEvent:Connect(function(remaining: number)
	if remaining < 0 then
		if zoneTimer then zoneTimer:Destroy(); zoneTimer = nil end
		return
	end
	if not zoneTimer then
		zoneTimer = newLabel(gui, "", Color3.fromRGB(255, 80, 80), 22)
		local zt = zoneTimer :: TextLabel
		zt.Size = UDim2.new(0, 220, 0, 36); zt.AnchorPoint = Vector2.new(1, 0)
		zt.Position = UDim2.new(1, -16, 0, 70); zt.TextXAlignment = Enum.TextXAlignment.Right
		zt.ZIndex = 33
	end
	local zt = zoneTimer :: TextLabel
	local m = math.floor(remaining / 60); local s = remaining % 60
	zt.Text = ("⚠️ Forbidden Zone  %02d:%02d"):format(m, s)
	zt.TextColor3 = remaining < 60 and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 140, 90)
	if remaining < 60 then
		TweenService:Create(zt, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ TextTransparency = 0.4 }):Play()
	end
end)

-- ── Sage Seat granted ─────────────────────────────────────────────────────────
Net.Event("SageSeatGranted").OnClientEvent:Connect(function(seatNum: number)
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1); flash.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
	flash.BackgroundTransparency = 0.4; flash.BorderSizePixel = 0; flash.ZIndex = 38; flash.Parent = gui
	TweenService:Create(flash, TweenInfo.new(1), { BackgroundTransparency = 1 }):Play()
	Debris:AddItem(flash, 1.1)
	toast(("✨ Sage Seat #%d Claimed!"):format(seatNum))
end)

-- ── Shrine blessing (lore popup) ──────────────────────────────────────────────
Net.Event("ShrineBlessing").OnClientEvent:Connect(function(karma: number, lore: string)
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 520, 0, 160); panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.4); panel.BackgroundColor3 = Color3.fromRGB(20, 16, 10)
	panel.BackgroundTransparency = 0.05; panel.BorderSizePixel = 0; panel.ZIndex = 36; panel.Parent = gui
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 12); corner.Parent = panel
	local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(245, 200, 90); stroke.Thickness = 1.5; stroke.Parent = panel
	local title = newLabel(panel, ("📖 Han Jue's Shrine  ·  +%d Karma"):format(karma), Color3.fromRGB(245, 210, 120), 18)
	title.Size = UDim2.new(1, -20, 0, 28); title.Position = UDim2.fromOffset(10, 12)
	title.TextXAlignment = Enum.TextXAlignment.Center; title.ZIndex = 37
	local body = newLabel(panel, lore, Color3.fromRGB(220, 210, 190), 15)
	body.Font = Enum.Font.GothamMedium; body.TextWrapped = true
	body.Size = UDim2.new(1, -40, 1, -56); body.Position = UDim2.fromOffset(20, 48)
	body.TextXAlignment = Enum.TextXAlignment.Center; body.ZIndex = 37
	panel.BackgroundTransparency = 1
	for _, d in ipairs(panel:GetDescendants()) do
		if d:IsA("TextLabel") then d.TextTransparency = 1 end
	end
	TweenService:Create(panel, TweenInfo.new(0.4), { BackgroundTransparency = 0.05 }):Play()
	TweenService:Create(title, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
	TweenService:Create(body, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
	task.delay(5, function()
		TweenService:Create(panel, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		for _, d in ipairs(panel:GetDescendants()) do
			if d:IsA("TextLabel") then TweenService:Create(d, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play() end
		end
		task.wait(0.6); panel:Destroy()
	end)
end)

-- ── Wall of Eternity surface population ───────────────────────────────────────
Net.Event("WallOfEternity").OnClientEvent:Connect(function(entries: { any })
	task.spawn(function()
		local w = workspace:WaitForChild("World", 20)
		local w1 = w and w:WaitForChild("World1_MortalEarth", 10)
		local hubFolder = w1 and w1:FindFirstChild("Hub")
		local wall = hubFolder and hubFolder:FindFirstChild("WallOfEternity")
		if not wall then return end
		local sg = wall:FindFirstChild("WallSurface")
		local list = sg and sg:FindFirstChild("Names")
		if not (list and list:IsA("ScrollingFrame")) then return end
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextLabel") then c:Destroy() end
		end
		for i, e in ipairs(entries) do
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, -20, 0, 40); row.BackgroundTransparency = 1
			row.Text = ("%d.  %s   ·   R%d   ·   %s"):format(i, tostring(e.name), tonumber(e.realm) or 26, tostring(e.date))
			row.TextColor3 = Color3.fromRGB(255, 225, 140); row.TextScaled = true
			row.Font = Enum.Font.GothamBold; row.LayoutOrder = i; row.Parent = list
		end
	end)
end)

-- ── Realm-barrier golden vignette on rejection ────────────────────────────────
Net.Event("Notify").OnClientEvent:Connect(function(message: string, _kind: string?)
	if typeof(message) ~= "string" or not message:find("Required") then return end
	local vig = Instance.new("Frame")
	vig.Size = UDim2.fromScale(1, 1); vig.BackgroundTransparency = 1; vig.BorderSizePixel = 0
	vig.ZIndex = 28; vig.Parent = gui
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Color3.fromRGB(255, 210, 60))
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.25, 1),
		NumberSequenceKeypoint.new(0.75, 1),
		NumberSequenceKeypoint.new(1, 0.2),
	})
	grad.Parent = vig
	local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(255, 210, 60)
	stroke.Thickness = 8; stroke.Transparency = 0.2; stroke.Parent = vig
	TweenService:Create(stroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
	Debris:AddItem(vig, 0.6)
end)

-- ── Passive Qi mist (World 1 only) ────────────────────────────────────────────
task.spawn(function()
	while true do
		task.wait(60)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root and root.Position.Y < 200 then
			for _ = 1, 5 do
				local mist = Instance.new("Part"); mist.Anchored = true; mist.CanCollide = false
				mist.Shape = Enum.PartType.Ball; mist.Material = Enum.Material.Neon
				mist.Color = Color3.fromRGB(235, 245, 255); mist.Transparency = 0.6
				local dia = math.random(6, 10); mist.Size = Vector3.new(dia, dia, dia)
				mist.Position = root.Position + Vector3.new(math.random(-12, 12), 1, math.random(-12, 12))
				mist.Parent = workspace
				TweenService:Create(mist, TweenInfo.new(8), {
					Position = mist.Position + Vector3.new(0, 20, 0), Transparency = 1,
				}):Play()
				Debris:AddItem(mist, 8.1)
			end
		end
	end
end)

-- ── Hidden Sect Island visibility ─────────────────────────────────────────────
local function applyIslandVisibility()
	local canSee = player:GetAttribute("CanSeeHiddenIsland") == true
	local w = workspace:FindFirstChild("World")
	local w1 = w and w:FindFirstChild("World1_MortalEarth")
	local nether = w1 and w1:FindFirstChild("Netherworld")
	local island = nether and nether:FindFirstChild("HiddenSectIsland")
	if not island then return end
	for _, d in ipairs(island:GetDescendants()) do
		if d:IsA("BasePart") then
			d.LocalTransparencyModifier = canSee and 0 or 1
		elseif d:IsA("BillboardGui") then
			d.Enabled = canSee
		end
	end
end
player:GetAttributeChangedSignal("CanSeeHiddenIsland"):Connect(applyIslandVisibility)
task.spawn(function()
	workspace:WaitForChild("World", 30)
	task.wait(1)
	applyIslandVisibility()
end)
