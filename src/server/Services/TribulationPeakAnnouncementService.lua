--!strict
-- TribulationPeakAnnouncementService.lua
-- When a player survives a Heaven Tribulation on the Mortal Earth (near the
-- Tribulation Peak), every player is told and a golden lightning bolt erupts
-- from the peak — public recognition, like the novel.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local TribulationService = require(script.Parent.TribulationService)

local TribulationPeakAnnouncementService = {}

local serverAnnounce = Net.Event("ServerAnnounce")
local lightning      = Net.Event("LightningEffect")

function TribulationPeakAnnouncementService.Start()
	TribulationService.Survived:Connect(function(player: Player, _realm: number)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		local onMortalEarth = (not root) or root.Position.Y < 300
		if not onMortalEarth then return end

		for _, p in ipairs(Players:GetPlayers()) do
			serverAnnounce:FireClient(p, ("⚡ %s survived Heaven's Tribulation at Tribulation Peak!"):format(player.Name))
			lightning:FireClient(p)
		end
	end)
end

return TribulationPeakAnnouncementService
