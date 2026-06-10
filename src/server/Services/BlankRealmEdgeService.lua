--!strict
-- BlankRealmEdgeService.lua
-- Standing at the edge of the Blank Realm (World 4) for a cumulative hour grants
-- the one-time "Blank Realm Insight": a permanent +1% to all stats. The bonus
-- is applied through CultivationService.RecomputeStats (reads the attribute).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local BlankRealmEdgeService = {}

local notifyEvent = Net.Event("Notify")

local REQUIRED = 3600
local accrued: { [number]: number } = {}

local function applyInsight(player: Player)
	player:SetAttribute("BlankRealmInsight", true)
	local ok, CultivationService = pcall(require, script.Parent.CultivationService)
	if ok and CultivationService then CultivationService.RecomputeStats(player) end
end

local function grant(player: Player)
	local profile = DataManager.Get(player)
	if not profile or profile.blankRealmInsight then return end
	profile.blankRealmInsight = true
	applyInsight(player)
	notifyEvent:FireClient(player, "🌟 Blank Realm Insight — +1% to all stats, permanently.", "gold")
end

function BlankRealmEdgeService.Start()
	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.9)
		local profile = DataManager.Get(player)
		if profile and profile.blankRealmInsight then applyInsight(player) end
	end)

	task.spawn(function()
		workspace:WaitForChild("World", 30)
		local edges = CollectionService:GetTagged("BlankRealmEdge")

		local function insideAnyEdge(pos: Vector3): boolean
			for _, edge in ipairs(edges) do
				if edge:IsA("BasePart") then
					local local_ = edge.CFrame:PointToObjectSpace(pos)
					local h = edge.Size * 0.5 + Vector3.new(8, 20, 8)
					if math.abs(local_.X) <= h.X and math.abs(local_.Y) <= h.Y and math.abs(local_.Z) <= h.Z then
						return true
					end
				end
			end
			return false
		end

		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = DataManager.Get(player)
				if not profile or profile.blankRealmInsight then continue end
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if root and insideAnyEdge(root.Position) then
					accrued[player.UserId] = (accrued[player.UserId] or 0) + 1
					local t = accrued[player.UserId]
					if t == 60 or t == 600 or t == 1800 then
						notifyEvent:FireClient(player,
							("∞ The Blank Realm whispers... %d/%d min toward insight."):format(math.floor(t / 60), REQUIRED // 60), "info")
					end
					if t >= REQUIRED then grant(player) end
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player) accrued[player.UserId] = nil end)
end

return BlankRealmEdgeService
