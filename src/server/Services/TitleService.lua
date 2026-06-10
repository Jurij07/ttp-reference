--!strict
-- TitleService.lua
-- Titles auto-unlock when their condition is met (checked on progress). The
-- player equips one title for its passive bonus, folded into RecomputeStats.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local TitleData = require(GameData:WaitForChild("TitleData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local TitleService = {}

local notifyEvent = Net.Event("Notify")
local syncEvent   = Net.Event("TitleSync")

-- Tracked stats a title condition can reference.
local function statsFor(profile: any): any
	local daoCount = 0
	for _ in pairs(profile.daoMastered or {}) do daoCount += 1 end
	return {
		realm        = profile.realm or 1,
		kills        = profile.totalKills or 0,
		pvp_wins     = profile.pvpWins or 0,
		sect         = profile.sectId and 1 or 0,
		sect_level   = profile.sectLevel or 0,
		dao_count    = daoCount,
		stones       = profile.lifetimeStones or 0,
		tribulations = profile.tribulationsSurvived or 0,
		karma        = profile.karma or 0,
	}
end

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	syncEvent:FireClient(player, {
		unlocked = profile.unlockedTitles,
		active = profile.activeTitle,
	})
	local t = profile.activeTitle and TitleData.Get(profile.activeTitle)
	player:SetAttribute("TitleName", t and (t.icon .. " " .. t.name) or "")
end
TitleService.Sync = sync

function TitleService.GetActiveBonus(player: Player): { dmg: number, def: number, hp: number, exp: number, stone: number, breakBonus: number }
	local profile = DataManager.Get(player)
	local none = { dmg=1, def=1, hp=1, exp=1, stone=1, breakBonus=0 }
	if not profile or not profile.activeTitle then return none end
	local t = TitleData.Get(profile.activeTitle)
	if not t or not profile.unlockedTitles[profile.activeTitle] then return none end
	return { dmg=t.dmgMult, def=t.defMult, hp=t.hpMult, exp=t.expMult, stone=t.stoneMult, breakBonus=t.breakBonus }
end

-- Check for any newly-unlocked titles; auto-equip the first one earned.
function TitleService.CheckUnlocks(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local stats = statsFor(profile)
	local changed = false
	for _, t in ipairs(TitleData.TITLES) do
		if not profile.unlockedTitles[t.id] and TitleData.IsUnlocked(t, stats) then
			profile.unlockedTitles[t.id] = true
			changed = true
			notifyEvent:FireClient(player, ("🏆 Title unlocked: %s %s"):format(t.icon, t.name), "gold")
			if not profile.activeTitle then profile.activeTitle = t.id end
		end
	end
	if changed then sync(player) end
end

function TitleService.SetActive(player: Player, idRaw: any)
	local id = tostring(idRaw)
	local profile = DataManager.Get(player)
	if not profile or not profile.unlockedTitles[id] then return end
	profile.activeTitle = id
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	sync(player)
end

function TitleService.Start()
	local setEvent = Net.Event("SetTitle")
	setEvent.OnServerEvent:Connect(function(player, id) TitleService.SetActive(player, id) end)
	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.9)
		TitleService.CheckUnlocks(player)
		sync(player)
	end)
end

return TitleService
