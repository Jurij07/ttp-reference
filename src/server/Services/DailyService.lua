--!strict
-- DailyService.lua
-- Draws 3 daily missions from the pool at the start of each day (UTC midnight).
-- Progress tracked in profile.daily.  Completed tasks can be claimed once.
-- Progress hooks: OnEXPEarned, OnStonesEarned, OnKill, OnSeclusion, OnHuntTick.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local DailyData = require(GameData:WaitForChild("DailyData"))

local DataManager = require(script.Parent.DataManager)

local DailyService = {}

local notifyEvent = Net.Event("Notify")

-- Numeric day index (days since epoch).
local function dayIndex(): number
	return math.floor(os.time() / 86400)
end

-- seed = day * userId so each player gets a different set each day.
local function drawThree(player: Player): { string }
	local pool = DailyData.POOL
	local seed = dayIndex() * 1000000 + player.UserId
	-- Simple deterministic shuffle via LCG.
	local indices: { number } = {}
	for i = 1, #pool do indices[i] = i end
	local rng = seed
	for i = #pool, 2, -1 do
		rng = (rng * 1664525 + 1013904223) % (2^32)
		local j = (rng % i) + 1
		indices[i], indices[j] = indices[j], indices[i]
	end
	return { pool[indices[1]].id, pool[indices[2]].id, pool[indices[3]].id }
end

local function ensureDaily(player: Player, profile: any): any
	local day = dayIndex()
	if type(profile.daily) ~= "table" or profile.daily.day ~= day then
		profile.daily = {
			day = day,
			tasks = drawThree(player),
			progress = {},
			claimed = {},
		}
	end
	profile.daily.progress = profile.daily.progress or {}
	profile.daily.claimed  = profile.daily.claimed  or {}
	return profile.daily
end

local function syncDaily(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local d = ensureDaily(player, profile)
	local out: { any } = {}
	for _, id in ipairs(d.tasks) do
		local task_ = DailyData.Get(id)
		if task_ then
			table.insert(out, {
				id       = id,
				title    = task_.title,
				icon     = task_.icon,
				progress = d.progress[id] or 0,
				target   = task_.target,
				claimed  = d.claimed[id] == true,
				rewardStones = task_.rewardStones,
				rewardExp    = task_.rewardExp,
			})
		end
	end
	Net.Event("DailySync"):FireClient(player, out)
end

-- ── Progress hooks ───────────────────────────────────────────
local function addProgress(player: Player, taskType: string, amount: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	local d = ensureDaily(player, profile)
	local changed = false
	for _, id in ipairs(d.tasks) do
		local task_ = DailyData.Get(id)
		if task_ and task_.type == taskType and not d.claimed[id] then
			local prev = d.progress[id] or 0
			if prev < task_.target then
				d.progress[id] = math.min(prev + amount, task_.target)
				if d.progress[id] >= task_.target then
					notifyEvent:FireClient(player,
						("%s Daily task done: %s — claim your reward!"):format(task_.icon, task_.title), "gold")
				end
				changed = true
			end
		end
	end
	if changed then syncDaily(player) end
end

function DailyService.OnEXPEarned(player: Player, amount: number)
	addProgress(player, "exp_earn", amount)
end

function DailyService.OnStonesEarned(player: Player, amount: number)
	addProgress(player, "stones_earn", amount)
end

function DailyService.OnKill(player: Player)
	addProgress(player, "kills", 1)
end

function DailyService.OnSeclusion(player: Player)
	addProgress(player, "seclusion", 1)
end

function DailyService.OnHuntTick(player: Player)
	addProgress(player, "realm_hunt", 1)
end

function DailyService.Start()
	Net.Event("DailySync")

	Net.Event("ClaimDailyTask").OnServerEvent:Connect(function(player: Player, idRaw: unknown)
		local id = tostring(idRaw)
		local profile = DataManager.Get(player)
		if not profile then return end
		local d = ensureDaily(player, profile)
		if d.claimed[id] then
			notifyEvent:FireClient(player, "Already claimed!", "warn"); return
		end
		local progress = d.progress[id] or 0
		local task_ = DailyData.Get(id)
		if not task_ or progress < task_.target then
			notifyEvent:FireClient(player, "Task not yet complete.", "warn"); return
		end
		d.claimed[id] = true
		local CS = require(script.Parent.CultivationService)
		if task_.rewardStones > 0 then CS.AddStones(player, task_.rewardStones) end
		if task_.rewardExp    > 0 then CS.AddEXP(player, task_.rewardExp, true) end
		notifyEvent:FireClient(player,
			("%s Claimed: %s! +%d 💰 +%d EXP"):format(task_.icon, task_.title, task_.rewardStones, task_.rewardExp), "gold")
		syncDaily(player)
	end)

	Net.Event("GetDailyTasks").OnServerEvent:Connect(function(player: Player)
		syncDaily(player)
	end)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.delay(2, function()
			if player.Parent then syncDaily(player) end
		end)
	end)

	print("[DailyService] Started.")
end

return DailyService
