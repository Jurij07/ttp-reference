--!strict
-- LeaderboardService.lua
-- Computes live standings among online players across 6 categories and pushes
-- them to clients. The #1 player in Realm / Kills / Stones also receives a
-- small rank-title bonus (folded into RecomputeStats via GetRankBonus).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local DataManager = require(script.Parent.DataManager)

local LeaderboardService = {}

local syncEvent = Net.Event("LeaderboardSync")

-- userId -> { allStats=mult, exp=mult, dmg=mult, stone=mult } from rank titles
local rankBonus: { [number]: { all: number, exp: number, dmg: number, stone: number } } = {}

function LeaderboardService.GetRankBonus(player: Player): { all: number, exp: number, dmg: number, stone: number }
	return rankBonus[player.UserId] or { all=1, exp=1, dmg=1, stone=1 }
end

local function statValue(player: Player, cat: string): number
	if cat == "realm" then return (player:GetAttribute("Realm") or 1) :: number
	elseif cat == "exp" then return (player:GetAttribute("TotalExp") or 0) :: number
	elseif cat == "kills" then return (player:GetAttribute("TotalKills") or 0) :: number
	elseif cat == "pvp" then
		local p = DataManager.Get(player); return p and p.pvpWins or 0
	elseif cat == "stones" then return (player:GetAttribute("SpiritStones") or 0) :: number
	elseif cat == "age" then return (player:GetAttribute("Age") or 18) :: number
	end
	return 0
end

local CATS = { "realm", "exp", "kills", "pvp", "stones", "age" }

local function rebuild()
	local board: { [string]: { { name: string, value: number, userId: number } } } = {}
	for _, cat in ipairs(CATS) do
		local rows = {}
		for _, pl in ipairs(Players:GetPlayers()) do
			table.insert(rows, { name = pl.Name, value = statValue(pl, cat), userId = pl.UserId })
		end
		table.sort(rows, function(a, b) return a.value > b.value end)
		board[cat] = rows
	end

	-- Assign rank bonuses: #1 in realm/kills/stones gets a small boost.
	local newBonus: typeof(rankBonus) = {}
	local function topUser(cat: string): number?
		local r = board[cat]; return r and r[1] and r[1].value > 0 and r[1].userId or nil
	end
	local r1 = topUser("realm"); if r1 then
		newBonus[r1] = newBonus[r1] or { all=1, exp=1, dmg=1, stone=1 }
		newBonus[r1].all *= 1.20; newBonus[r1].exp *= 1.30
	end
	local k1 = topUser("kills"); if k1 then
		newBonus[k1] = newBonus[k1] or { all=1, exp=1, dmg=1, stone=1 }
		newBonus[k1].dmg *= 1.20
	end
	local s1 = topUser("stones"); if s1 then
		newBonus[s1] = newBonus[s1] or { all=1, exp=1, dmg=1, stone=1 }
		newBonus[s1].stone *= 1.30; newBonus[s1].exp *= 1.15
	end

	-- Recompute stats for players whose rank bonus changed.
	for _, pl in ipairs(Players:GetPlayers()) do
		local old = rankBonus[pl.UserId]
		local new = newBonus[pl.UserId]
		local changed = (old ~= nil) ~= (new ~= nil)
			or (old and new and (old.all ~= new.all or old.dmg ~= new.dmg or old.exp ~= new.exp or old.stone ~= new.stone))
		if changed then
			rankBonus[pl.UserId] = new
			local CultivationService = require(script.Parent.CultivationService)
			CultivationService.RecomputeStats(pl)
		end
	end
	rankBonus = newBonus

	for _, pl in ipairs(Players:GetPlayers()) do
		syncEvent:FireClient(pl, board)
	end
end

function LeaderboardService.Start()
	task.spawn(function()
		while true do
			task.wait(10)
			rebuild()
		end
	end)
	Players.PlayerRemoving:Connect(function(pl) rankBonus[pl.UserId] = nil end)
end

return LeaderboardService
