--!strict
-- DaoFieldService.lua
-- Personal Dao Field (unlocks at R11): a private meditation instance giving 2×
-- EXP with no combat. Each player gets their own garden room at a unique X
-- offset (high above the worlds). EnterDaoField teleports in; LeaveDaoField
-- returns the player to where they were standing.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DaoFieldService = {}

local notifyEvent = Net.Event("Notify")
local enterEvent  = Net.Event("EnterDaoField")
local leaveEvent  = Net.Event("LeaveDaoField")

local FIELD_Y = 8000
local SPACING = 300
local UNLOCK_REALM = 11

local returnPos: { [number]: Vector3 } = {}
local priorPvP: { [number]: boolean } = {}
local builtFor: { [number]: Vector3 } = {}

local function fieldCenter(player: Player): Vector3
	local slot = player.UserId % 100
	return Vector3.new(slot * SPACING, FIELD_Y, 0)
end

local function buildRoom(player: Player): Vector3
	local center = fieldCenter(player)
	if builtFor[player.UserId] then return center end
	builtFor[player.UserId] = center

	local folder = Instance.new("Folder"); folder.Name = "DaoField_" .. player.UserId
	folder.Parent = workspace:FindFirstChild("World") or workspace

	local function part(name, size, pos, color, mat)
		local p = Instance.new("Part"); p.Name = name; p.Anchored = true
		p.Size = size; p.Position = pos; p.Color = color; p.Material = mat
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = folder; return p
	end

	part("Floor", Vector3.new(40, 2, 40), center - Vector3.new(0, 1, 0), Color3.fromRGB(120, 200, 150), Enum.Material.Grass)
	local pond = part("KoiPond", Vector3.new(14, 1, 14), center + Vector3.new(8, 0.5, 8), Color3.fromRGB(80, 160, 220), Enum.Material.Water)
	pond.Shape = Enum.PartType.Cylinder; pond.Orientation = Vector3.new(0, 0, 90)
	for i = 1, 3 do
		local a = i / 3 * math.pi * 2
		part("BonsaiTrunk", Vector3.new(1.5, 5, 1.5), center + Vector3.new(math.cos(a) * 12, 2.5, math.sin(a) * 12), Color3.fromRGB(110, 75, 50), Enum.Material.Wood)
		local can = part("BonsaiCanopy", Vector3.new(6, 6, 6), center + Vector3.new(math.cos(a) * 12, 6, math.sin(a) * 12), Color3.fromRGB(120, 230, 150), Enum.Material.Neon)
		can.Shape = Enum.PartType.Ball
	end
	local ring = part("DaoAura", Vector3.new(30, 0.5, 30), center + Vector3.new(0, 0.5, 0), Color3.fromRGB(100, 255, 200), Enum.Material.Neon)
	ring.Shape = Enum.PartType.Cylinder; ring.Orientation = Vector3.new(0, 0, 90); ring.CanCollide = false
	local exit = part("ExitDaoField", Vector3.new(4, 8, 4), center + Vector3.new(-14, 4, -14), Color3.fromRGB(255, 150, 150), Enum.Material.Neon)
	local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Leave Dao Field"
	prompt.ObjectText = "Dao Field"; prompt.HoldDuration = 0.5; prompt.MaxActivationDistance = 12; prompt.Parent = exit
	prompt.Triggered:Connect(function(p) if p == player then DaoFieldService.Leave(player) end end)

	return center
end

function DaoFieldService.Enter(player: Player)
	local realm = (player:GetAttribute("Realm") or 1) :: number
	if realm < UNLOCK_REALM then
		notifyEvent:FireClient(player, ("Personal Dao Field unlocks at Realm %d."):format(UNLOCK_REALM), "warn")
		return
	end
	if player:GetAttribute("InDaoField") then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then returnPos[player.UserId] = root.Position end

	local center = buildRoom(player)
	if root then root.CFrame = CFrame.new(center + Vector3.new(0, 4, 0)) end

	player:SetAttribute("InDaoField", true)
	priorPvP[player.UserId] = player:GetAttribute("PvPEnabled") == true
	player:SetAttribute("PvPEnabled", false)
	notifyEvent:FireClient(player, "🧘 Personal Dao Field — 2× EXP, no combat.", "gold")
end

function DaoFieldService.Leave(player: Player)
	if not player:GetAttribute("InDaoField") then return end
	player:SetAttribute("InDaoField", nil)
	if priorPvP[player.UserId] then player:SetAttribute("PvPEnabled", true) end
	priorPvP[player.UserId] = nil

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local back = returnPos[player.UserId] or Vector3.new(0, 6, 0)
	if root then root.CFrame = CFrame.new(back + Vector3.new(0, 2, 0)) end
	notifyEvent:FireClient(player, "↩️ You leave the Dao Field.", "info")
end

function DaoFieldService.Start()
	enterEvent.OnServerEvent:Connect(function(player) DaoFieldService.Enter(player) end)
	leaveEvent.OnServerEvent:Connect(function(player) DaoFieldService.Leave(player) end)

	Players.PlayerRemoving:Connect(function(player)
		returnPos[player.UserId] = nil
		priorPvP[player.UserId] = nil
		local f = workspace:FindFirstChild("World")
		local room = f and f:FindFirstChild("DaoField_" .. player.UserId)
		if room then room:Destroy() end
		builtFor[player.UserId] = nil
	end)
end

return DaoFieldService
