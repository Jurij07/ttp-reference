--!strict
-- YellowSpringService.lua
-- The Yellow Spring (Netherworld river) is instant death on touch. The Hidden
-- Sect Island only reveals itself to members of the Six Paths Hidden Sect
-- (Han Jue's sect); members meditating there gain +50% EXP.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local YellowSpringService = {}

local notifyEvent = Net.Event("Notify")

-- The Six Paths Hidden Sect is Han Jue's legendary sect in SectData.
local HIDDEN_SECT_ID = "six_paths"

local function isHiddenMember(player: Player): boolean
	local profile = DataManager.Get(player)
	return profile ~= nil and profile.sectId == HIDDEN_SECT_ID
end

local function killPlayer(player: Player)
	player:SetAttribute("HP", 0)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if hum then hum.Health = 0 end
	notifyEvent:FireClient(player, "☠️ The Yellow Spring — instant death.", "warn")
end

local function refreshVisibility(player: Player)
	player:SetAttribute("CanSeeHiddenIsland", isHiddenMember(player))
end

local function wireSpring(seg: BasePart)
	seg.Touched:Connect(function(hit)
		local model = hit:FindFirstAncestorOfClass("Model")
		local player = model and Players:GetPlayerFromCharacter(model)
		if player then killPlayer(player) end
	end)
end

function YellowSpringService.Start()
	task.spawn(function()
		workspace:WaitForChild("World", 30)
		for _, s in ipairs(CollectionService:GetTagged("YellowSpring")) do wireSpring(s) end
		CollectionService:GetInstanceAddedSignal("YellowSpring"):Connect(wireSpring)
	end)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.7)
		refreshVisibility(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		player:GetAttributeChangedSignal("SectName"):Connect(function() refreshVisibility(player) end)
	end)

	task.spawn(function()
		local island = nil
		local spot: Vector3? = nil
		while not island do
			task.wait(1)
			local tagged = CollectionService:GetTagged("HiddenSectIsland")
			island = tagged[1]
			if island then spot = island:GetAttribute("MeditationSpot") end
		end
		while true do
			task.wait(2)
			if not spot then continue end
			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				local onIsland = root and (root.Position - spot).Magnitude < 34 and isHiddenMember(player)
				if onIsland then
					if player:GetAttribute("HiddenIslandBonus") ~= true then
						player:SetAttribute("HiddenIslandBonus", true)
						player:SetAttribute("MeditationBonus", 1.5)
						notifyEvent:FireClient(player, "🏝️ Hidden Sect Island — +50% EXP.", "gold")
					end
				elseif player:GetAttribute("HiddenIslandBonus") == true then
					player:SetAttribute("HiddenIslandBonus", nil)
					if not player:GetAttribute("InGrotto") then
						player:SetAttribute("MeditationBonus", nil)
					end
				end
			end
		end
	end)
end

return YellowSpringService
