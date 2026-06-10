--!strict
-- WorldTransitionService.lua
-- Handles travel between the four stacked worlds via portal arches, and the
-- realm barriers inside World 1 that gate progression. Portal/barrier parts are
-- built and tagged by TerrainGenerator; this service attaches the behaviour.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local WorldData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("WorldData"))

local DataManager = require(script.Parent.DataManager)

local WorldTransitionService = {}

local notifyEvent     = Net.Event("Notify")
local worldAscension  = Net.Event("WorldAscension")
local firstAscension  = Net.Event("FirstAscension")
local serverAnnounce  = Net.Event("ServerAnnounce")

local lastTouch: { [number]: number } = {}
local TOUCH_CD = 1.0

local function playerFromPart(part: BasePart): Player?
	local model = part:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	return Players:GetPlayerFromCharacter(model)
end

local function teleportTo(player: Player, pos: Vector3)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then root.CFrame = CFrame.new(pos) end
end

-- Knock the player back from a barrier/portal they may not pass.
local function pushBack(player: Player)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		root.AssemblyLinearVelocity = -root.CFrame.LookVector * 60 + Vector3.new(0, 30, 0)
	end
end

local function handlePortal(portal: BasePart, player: Player)
	local fromW, toW = portal.Name:match("Portal_W(%d)_to_W(%d)")
	if not fromW then return end
	local from, to = tonumber(fromW), tonumber(toW)
	if not from or not to then return end

	local realm = (player:GetAttribute("Realm") or 1) :: number
	local stage = (player:GetAttribute("Stage") or 1) :: number

	-- Ascending requires meeting the world's minimum realm. Descending is free.
	if to > from then
		if to == 2 then
			if realm < 9 or (realm == 9 and stage < 9) then
				notifyEvent:FireClient(player, "⚡ Reach Mahayana (R9) Stage 9 first!", "warn")
				pushBack(player); return
			end
		else
			local need = WorldData.WORLD_MIN_REALM[to] or 1
			if realm < need then
				notifyEvent:FireClient(player, ("⚡ Realm %d required to ascend to %s."):format(need, WorldData.WORLD_NAME[to]), "warn")
				pushBack(player); return
			end
		end
	end

	local arrival = WorldData.WORLD_ARRIVAL[to]
	if not arrival then return end
	teleportTo(player, arrival)
	worldAscension:FireClient(player, to)

	-- Heaven's Gate: first time entering the Immortal World (W2).
	if to == 2 then
		local profile = DataManager.Get(player)
		local level = (player:GetAttribute("WorldLevel") or (profile and profile.worldLevel) or 1) :: number
		if level < 2 then
			player:SetAttribute("WorldLevel", 2)
			if profile then profile.worldLevel = 2 end
			firstAscension:FireClient(player)
			for _, p in ipairs(Players:GetPlayers()) do
				serverAnnounce:FireClient(p, ("⚡ %s has ascended through Heaven's Gate!"):format(player.Name))
			end
		end
	else
		local profile = DataManager.Get(player)
		if profile and to > (profile.worldLevel or 1) then
			profile.worldLevel = to
			player:SetAttribute("WorldLevel", to)
		end
	end
end

local function handleBarrier(barrier: BasePart, player: Player)
	local need = (barrier:GetAttribute("ReqRealm") or 1) :: number
	local realm = (player:GetAttribute("Realm") or 1) :: number
	if realm < need then
		notifyEvent:FireClient(player, ("⚡ Realm %d Required to pass."):format(need), "warn")
		pushBack(player)
	end
end

local function wire(part: Instance, handler: (BasePart, Player) -> ())
	if not part:IsA("BasePart") then return end
	part.Touched:Connect(function(hit)
		local player = playerFromPart(hit)
		if not player then return end
		local now = os.clock()
		if now - (lastTouch[player.UserId] or 0) < TOUCH_CD then return end
		lastTouch[player.UserId] = now
		handler(part :: BasePart, player)
	end)
end

function WorldTransitionService.Start()
	worldAscension; firstAscension; serverAnnounce

	task.spawn(function()
		workspace:WaitForChild("World", 30)

		for _, p in ipairs(CollectionService:GetTagged("WorldPortal")) do wire(p, handlePortal) end
		CollectionService:GetInstanceAddedSignal("WorldPortal"):Connect(function(p) wire(p, handlePortal) end)

		for _, p in ipairs(CollectionService:GetTagged("RealmBarrier")) do wire(p, handleBarrier) end
		CollectionService:GetInstanceAddedSignal("RealmBarrier"):Connect(function(p) wire(p, handleBarrier) end)
	end)

	Players.PlayerRemoving:Connect(function(player) lastTouch[player.UserId] = nil end)
end

return WorldTransitionService
