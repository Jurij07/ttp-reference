--!strict
-- BookOfMisfortuneService.lua
-- Han Jue's signature mechanic. Once per day a player may curse a target,
-- giving them -10% EXP for 24h. Casting costs -50 Karma. Curses persist across
-- sessions via the target's profile and re-apply on login.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local BookOfMisfortuneService = {}

local notifyEvent = Net.Event("Notify")
local curseEvent  = Net.Event("CursePlayer")

local DAY_SECONDS = 24 * 60 * 60
local CURSE_MULT  = 0.9
local KARMA_COST  = 50

local function applyCurseAttribute(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local expiry = (profile.cursedExpMultExpiry or 0) :: number
	if os.time() < expiry then
		player:SetAttribute("CursedExpMult", CURSE_MULT)
	else
		player:SetAttribute("CursedExpMult", nil)
		profile.cursedExpMultExpiry = 0
	end
end

local function findTarget(name: string): Player?
	local lname = name:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower() == lname or p.DisplayName:lower() == lname then return p end
	end
	return nil
end

local function cast(caster: Player, targetName: any)
	local profile = DataManager.Get(caster)
	if not profile then return end
	local now = os.time()
	local last = (profile.bookOfMisfortuneLastUsed or 0) :: number
	if now - last < DAY_SECONDS then
		local hrs = math.ceil((DAY_SECONDS - (now - last)) / 3600)
		notifyEvent:FireClient(caster, ("📕 The Book rests — curse again in ~%dh."):format(hrs), "info")
		return
	end

	local target = findTarget(tostring(targetName))
	if not target then
		notifyEvent:FireClient(caster, "Target not found in this realm.", "warn")
		return
	end
	if target == caster then
		notifyEvent:FireClient(caster, "You cannot curse yourself.", "warn")
		return
	end

	profile.bookOfMisfortuneLastUsed = now
	profile.karma = (profile.karma or 0) - KARMA_COST
	caster:SetAttribute("Karma", profile.karma)

	local tprofile = DataManager.Get(target)
	if tprofile then
		tprofile.cursedExpMultExpiry = now + DAY_SECONDS
		applyCurseAttribute(target)
	end

	notifyEvent:FireClient(caster, ("📖 You cursed %s with misfortune (-10%% EXP, 24h). -%d Karma."):format(target.Name, KARMA_COST), "warn")
	notifyEvent:FireClient(target, ("🌑 %s cursed you with the Book of Misfortune (-10%% EXP, 24h)."):format(caster.Name), "warn")
end

function BookOfMisfortuneService.Start()
	curseEvent.OnServerEvent:Connect(cast)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.8)
		applyCurseAttribute(player)
	end)

	task.spawn(function()
		while true do
			task.wait(60)
			for _, player in ipairs(Players:GetPlayers()) do
				if player:GetAttribute("CursedExpMult") then applyCurseAttribute(player) end
			end
		end
	end)
end

return BookOfMisfortuneService
