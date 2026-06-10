--!strict
-- SecretGrottoService.lua
-- Hidden grotto behind the Spirit Forest waterfall. Players solve a 3-stone
-- Qi puzzle (click stones in order 1→2→3) to open the grotto, then meditate
-- inside for a 3× EXP bonus. Max 3 occupants. The visual parts (Waterfall,
-- GrottoTrigger, QiStone×3) are built and tagged by TerrainGenerator.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local SecretGrottoService = {}

local notifyEvent  = Net.Event("Notify")
local grottoStatus = Net.Event("GrottoStatus")

local MAX_OCCUPANTS = 3
local PUZZLE_RESET  = 30   -- seconds before an unfinished sequence resets

local progress = 0          -- next stone index expected (0 = none yet)
local lastClick = 0
local opened = false
local occupants: { [number]: boolean } = {}
local grottoSpot: Vector3? = nil

local function occupantCount(): number
	local n = 0
	for _ in pairs(occupants) do n += 1 end
	return n
end

local function enter(player: Player)
	if occupants[player.UserId] then return end
	if occupantCount() >= MAX_OCCUPANTS then
		notifyEvent:FireClient(player, ("🪨 Grotto is full (%d/%d)."):format(MAX_OCCUPANTS, MAX_OCCUPANTS), "warn")
		return
	end
	occupants[player.UserId] = true
	player:SetAttribute("MeditationBonus", 3)
	player:SetAttribute("InGrotto", true)
	notifyEvent:FireClient(player, "🧘 Secret Grotto — 3× meditation EXP, no PvP.", "gold")
	grottoStatus:FireAllClients(occupantCount(), MAX_OCCUPANTS)
end

local function leave(player: Player)
	if not occupants[player.UserId] then return end
	occupants[player.UserId] = nil
	if player:GetAttribute("InGrotto") then
		player:SetAttribute("MeditationBonus", nil)
		player:SetAttribute("InGrotto", nil)
	end
	grottoStatus:FireAllClients(occupantCount(), MAX_OCCUPANTS)
end

local function buildGrottoRoom(spot: Vector3)
	local folder = Instance.new("Folder"); folder.Name = "GrottoRoom"
	folder.Parent = workspace:WaitForChild("World"):WaitForChild("World1_MortalEarth")
	local function part(name, size, pos, color, mat)
		local p = Instance.new("Part"); p.Name = name; p.Anchored = true
		p.Size = size; p.Position = pos; p.Color = color; p.Material = mat
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = folder; return p
	end
	part("Floor", Vector3.new(60, 2, 60), spot - Vector3.new(0, 1, 0), Color3.fromRGB(60, 80, 100), Enum.Material.Rock)
	for i = 1, 4 do
		local a = i / 4 * math.pi * 2
		part("Wall", Vector3.new(60, 30, 2), spot + Vector3.new(math.cos(a) * 30, 14, math.sin(a) * 30), Color3.fromRGB(50, 70, 90), Enum.Material.Rock).Orientation = Vector3.new(0, math.deg(a), 0)
	end
	part("Ceiling", Vector3.new(60, 2, 60), spot + Vector3.new(0, 30, 0), Color3.fromRGB(40, 55, 75), Enum.Material.Rock)
	for _ = 1, 8 do
		local b = Instance.new("Part"); b.Anchored = true; b.Shape = Enum.PartType.Ball
		b.Size = Vector3.new(4, 4, 4); b.Material = Enum.Material.Neon; b.Color = Color3.fromRGB(80, 200, 255)
		b.Position = spot + Vector3.new(math.random(-25, 25), math.random(4, 24), math.random(-25, 25))
		b.CanCollide = false; b.Parent = folder
	end
	for i = 1, MAX_OCCUPANTS do
		part("MeditationSpot", Vector3.new(6, 1, 6), spot + Vector3.new((i - 2) * 10, 1, 0), Color3.fromRGB(100, 220, 255), Enum.Material.Neon)
	end
	local anchor = Instance.new("Part"); anchor.Anchored = true; anchor.CanCollide = false
	anchor.Transparency = 1; anchor.Size = Vector3.new(1, 1, 1); anchor.Position = spot + Vector3.new(0, 10, 0); anchor.Parent = folder
	local bg = Instance.new("BillboardGui"); bg.Size = UDim2.fromOffset(300, 50); bg.Adornee = anchor; bg.Parent = anchor
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.fromScale(1, 1); lbl.BackgroundTransparency = 1
	lbl.Text = "+3× EXP · No PvP · Capacity 3"; lbl.TextColor3 = Color3.fromRGB(120, 220, 255)
	lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBold; lbl.Parent = bg
end

local function openGrotto(player: Player)
	if opened then return end
	opened = true
	notifyEvent:FireClient(player, "✨ The Qi stones align — the grotto opens!", "gold")
	if grottoSpot then buildGrottoRoom(grottoSpot) end
end

local function wireStone(stone: BasePart)
	local order = (stone:GetAttribute("Order") or 0) :: number
	local cd = Instance.new("ClickDetector"); cd.MaxActivationDistance = 18; cd.Parent = stone
	cd.MouseClick:Connect(function(player)
		local now = os.clock()
		if now - lastClick > PUZZLE_RESET then progress = 0 end
		lastClick = now
		if order == progress + 1 then
			progress = order
			stone.Color = Color3.fromRGB(120, 255, 180)
			notifyEvent:FireClient(player, ("🔹 Qi stone %d activated."):format(order), "info")
			if progress >= 3 then
				openGrotto(player)
				progress = 0
			end
		else
			progress = 0
			stone.Color = Color3.fromRGB(80, 160, 220)
			notifyEvent:FireClient(player, "🔸 The stones dim — wrong order. Start again.", "warn")
		end
	end)
end

function SecretGrottoService.Start()
	task.spawn(function()
		workspace:WaitForChild("World", 30)

		for _, s in ipairs(CollectionService:GetTagged("QiStone")) do wireStone(s) end
		CollectionService:GetInstanceAddedSignal("QiStone"):Connect(wireStone)

		local w1 = workspace.World:FindFirstChild("World1_MortalEarth")
		local zone1 = w1 and w1:FindFirstChild("Zone_1")
		grottoSpot = Vector3.new(-160, -20, -160)
		if zone1 then
			local WorldData = require(ReplicatedStorage.GameData:WaitForChild("WorldData"))
			local c = WorldData.ZoneCenter(1)
			grottoSpot = Vector3.new(c.X - 46, -20, c.Z - 10)
		end

		for _, t in ipairs(CollectionService:GetTagged("GrottoTrigger")) do
			t.Touched:Connect(function(hit)
				local model = hit:FindFirstAncestorOfClass("Model")
				local player = model and Players:GetPlayerFromCharacter(model)
				if not player or not opened then return end
				if occupants[player.UserId] then return end
				if occupantCount() >= MAX_OCCUPANTS then
					notifyEvent:FireClient(player, ("🪨 Grotto is full (%d/%d)."):format(MAX_OCCUPANTS, MAX_OCCUPANTS), "warn")
					return
				end
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if root and grottoSpot then root.CFrame = CFrame.new(grottoSpot + Vector3.new(0, 4, 0)) end
				enter(player)
			end)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function() leave(player) end)
	end)
	Players.PlayerRemoving:Connect(leave)

	task.spawn(function()
		while true do
			task.wait(2)
			if not grottoSpot then continue end
			for _, player in ipairs(Players:GetPlayers()) do
				if occupants[player.UserId] then
					local char = player.Character
					local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
					if root and (root.Position - grottoSpot).Magnitude > 60 then
						leave(player)
					end
				end
			end
		end
	end)
end

return SecretGrottoService
