--!strict
-- PvPService.lua
-- Opt-in PvP. Toggling marks you PvP-enabled. A PvP-enabled player can strike
-- the nearest other PvP-enabled player in range; on defeat the winner gains a
-- PvP win (and karma drops, per the Karma table).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager = require(script.Parent.DataManager)

local PvPService = {}

local notifyEvent = Net.Event("Notify")
local hitEvent    = Net.Event("CombatHit")
local lastAttack: { [number]: number } = {}

local function nearestEnemy(player: Player): Player?
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return nil end
	local best: Player? = nil
	local bestDist = Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other:GetAttribute("PvPEnabled") then
			local oc = other.Character
			local oroot = oc and oc:FindFirstChild("HumanoidRootPart") :: BasePart?
			if oroot then
				local d = (root.Position - oroot.Position).Magnitude
				if d < bestDist then bestDist = d; best = other end
			end
		end
	end
	return best
end

function PvPService.Toggle(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.pvpEnabled = not profile.pvpEnabled
	player:SetAttribute("PvPEnabled", profile.pvpEnabled)
	notifyEvent:FireClient(player, profile.pvpEnabled and "⚔️ PvP enabled — you can now fight other cultivators." or "🕊️ PvP disabled.", profile.pvpEnabled and "warn" or "info")
end

function PvPService.Attack(player: Player)
	local profile = DataManager.Get(player)
	if not profile or not profile.pvpEnabled then return end
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end

	local now = os.clock()
	if now - (lastAttack[player.UserId] or 0) < Config.ATTACK_COOLDOWN then return end
	lastAttack[player.UserId] = now

	local target = nearestEnemy(player)
	if not target then return end

	local dmg = (player:GetAttribute("ATK") or 10) :: number
	dmg *= Buffs.GetMult(player, "Dmg")
	local def = (target:GetAttribute("Defense") or 0) :: number
	local applied = math.max(dmg - def, 1)

	local thp = ((target:GetAttribute("HP") or 0) :: number) - applied
	hitEvent:FireClient(player, target.Name, applied)
	if thp <= 0 then
		-- victory
		target:SetAttribute("HP", target:GetAttribute("MaxHP") or 1)
		local tchar = target.Character
		local troot = tchar and tchar:FindFirstChild("HumanoidRootPart") :: BasePart?
		if troot then troot.CFrame = CFrame.new(0, 6, 0) end  -- send loser to spawn
		profile.pvpWins = (profile.pvpWins or 0) + 1
		profile.karma = (profile.karma or 0) - 5  -- kill_player karma cost
		player:SetAttribute("Karma", profile.karma)
		notifyEvent:FireClient(player, ("🏆 You defeated %s! PvP wins: %d"):format(target.Name, profile.pvpWins), "gold")
		notifyEvent:FireClient(target, ("💀 You were defeated by %s."):format(player.Name), "warn")
		local TitleService = require(script.Parent.TitleService)
		TitleService.CheckUnlocks(player)
	else
		target:SetAttribute("HP", thp)
	end
end

function PvPService.Start()
	local toggleEvent = Net.Event("TogglePvP")
	local attackEvent = Net.Event("PvPAttack")
	toggleEvent.OnServerEvent:Connect(function(player) PvPService.Toggle(player) end)
	attackEvent.OnServerEvent:Connect(function(player) PvPService.Attack(player) end)
	DataManager.ProfileLoaded:Connect(function(player: Player)
		local profile = DataManager.Get(player)
		if profile then player:SetAttribute("PvPEnabled", profile.pvpEnabled == true) end
	end)
end

return PvPService
