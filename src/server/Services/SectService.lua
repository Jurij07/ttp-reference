--!strict
-- SectService.lua
-- Hidden Sects: Spieler tritt einer von 4 Sekten bei (Realm-Voraussetzung).
-- Sekten-EXP kommt aus Combat (5% der EXP), Quests und Klausur. Bei Level-Ups
-- (Level × 1000 EXP) schalten sich Meilenstein-Buffs frei, die in
-- ProvidenceService.GetMultipliers einfließen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local SectData = require(GameData:WaitForChild("SectData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local SectService = {}

local notifyEvent  = Net.Event("Notify")
local sectSyncEvent = Net.Event("SectSync")

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local sect = profile.sectId and SectData.Get(profile.sectId)
	local buff = sect and SectData.BuffAtLevel(sect, profile.sectLevel or 0)
	sectSyncEvent:FireClient(player, {
		sectId   = profile.sectId,
		sectName = sect and sect.name or nil,
		level    = profile.sectLevel or 0,
		exp      = profile.sectExp or 0,
		expNeeded = SectData.ExpForLevel((profile.sectLevel or 0) + 1),
		buffName = buff and buff.name or nil,
		maxLevel = sect and sect.maxLevel or 10,
	})
	player:SetAttribute("SectName", sect and sect.name or "")
	player:SetAttribute("SectLevel", profile.sectLevel or 0)
end
SectService.Sync = sync

function SectService.Join(player: Player, sectIdRaw: any)
	local profile = DataManager.Get(player)
	if not profile then return end
	local sectId = tostring(sectIdRaw)
	local sect = SectData.Get(sectId)
	if not sect then
		notifyEvent:FireClient(player, "Unknown sect.", "warn")
		return
	end
	if profile.sectId == sectId then return end
	if profile.realm < sect.reqRealm then
		notifyEvent:FireClient(player, ("%s requires Realm %d."):format(sect.name, sect.reqRealm), "warn")
		return
	end

	profile.sectId = sectId
	profile.sectLevel = math.max(1, profile.sectLevel or 0)
	profile.sectExp = profile.sectExp or 0
	notifyEvent:FireClient(player, ("🏯 You joined the %s!"):format(sect.name), "gold")

	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.RecomputeStats(player)
	sync(player)
end

-- Fügt Sekten-EXP hinzu und bearbeitet Level-Ups.
function SectService.AddSectExp(player: Player, amount: number)
	local profile = DataManager.Get(player)
	if not profile or not profile.sectId then return end
	local sect = SectData.Get(profile.sectId)
	if not sect then return end

	profile.sectExp = (profile.sectExp or 0) + amount
	local leveledUp = false

	while profile.sectLevel < sect.maxLevel do
		local needed = SectData.ExpForLevel(profile.sectLevel + 1)
		if profile.sectExp < needed then break end
		profile.sectExp -= needed
		profile.sectLevel += 1
		leveledUp = true

		local buff = SectData.BuffAtLevel(sect, profile.sectLevel)
		if buff and buff.level == profile.sectLevel then
			notifyEvent:FireClient(player,
				("🏯 Sect Level %d: %s unlocked!"):format(profile.sectLevel, buff.name), "gold")
		end
	end

	if leveledUp then
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.RecomputeStats(player)
	end
	sync(player)
end

function SectService.Start()
	local joinEvent = Net.Event("JoinSect")
	joinEvent.OnServerEvent:Connect(function(player, sectId)
		SectService.Join(player, sectId)
	end)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(0.6)
		sync(player)
	end)
end

return SectService
