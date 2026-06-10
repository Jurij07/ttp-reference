--!strict
-- ChaoticForbiddenZoneService.lua
-- The Chaotic Forbidden Zone (World 4, R24+) is opt-in: touching the gate
-- starts a 10-minute survival timer. While inside, combat kills yield 5×
-- spirit stones (CombatService reads the ForbiddenZoneActive attribute). If the
-- timer expires the player dies and is returned to the R24 arrival point.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local WorldData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("WorldData"))

local ChaoticForbiddenZoneService = {}

local notifyEvent = Net.Event("Notify")
local timerEvent  = Net.Event("ForbiddenZoneTimer")

local DURATION = 600
local MIN_REALM = 24

local active: { [number]: number } = {}
local touchCd: { [number]: number } = {}

local function stop(player: Player, killed: boolean)
	if active[player.UserId] == nil then return end
	active[player.UserId] = nil
	player:SetAttribute("ForbiddenZoneActive", nil)
	timerEvent:FireClient(player, -1)
	if killed then
		player:SetAttribute("HP", 0)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid") :: Humanoid?
		if hum then hum.Health = 0 end
		local av = WorldData.WORLD_ARRIVAL[4]
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then root.CFrame = CFrame.new(av + Vector3.new(0, 4, 0)) end
		notifyEvent:FireClient(player, "☠️ The Chaos consumed you — returned to the Battlefield.", "warn")
	end
end

local function start(player: Player)
	if active[player.UserId] then return end
	local realm = (player:GetAttribute("Realm") or 1) :: number
	if realm < MIN_REALM then
		notifyEvent:FireClient(player, ("⚠️ Realm %d required to enter the Chaotic Forbidden Zone."):format(MIN_REALM), "warn")
		return
	end
	active[player.UserId] = os.time() + DURATION
	player:SetAttribute("ForbiddenZoneActive", true)
	notifyEvent:FireClient(player, "⚠️ Entered the Chaotic Forbidden Zone — survive 10 minutes! Kills give 5× stones.", "warn")
	timerEvent:FireClient(player, DURATION)
end

function ChaoticForbiddenZoneService.Start()
	task.spawn(function()
		workspace:WaitForChild("World", 30)
		for _, gate in ipairs(CollectionService:GetTagged("ChaoticForbiddenZone")) do
			gate.Touched:Connect(function(hit)
				local model = hit:FindFirstAncestorOfClass("Model")
				local player = model and Players:GetPlayerFromCharacter(model)
				if not player then return end
				local now = os.clock()
				if now - (touchCd[player.UserId] or 0) < 2 then return end
				touchCd[player.UserId] = now
				start(player)
			end)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.time()
			for userId, deadline in pairs(active) do
				local player = Players:GetPlayerByUserId(userId)
				if not player then
					active[userId] = nil
				else
					local remaining = deadline - now
					if remaining <= 0 then
						stop(player, true)
					else
						timerEvent:FireClient(player, remaining)
					end
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		active[player.UserId] = nil
		touchCd[player.UserId] = nil
	end)
end

return ChaoticForbiddenZoneService
