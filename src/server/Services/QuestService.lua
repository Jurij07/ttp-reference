--!strict
-- QuestService.lua
-- Realm/stage-based quest completion. Quests unlock when the player
-- reaches the required realm (and optionally stage/confirmed state).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local QuestData = require(GameData:WaitForChild("QuestData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local QuestService = {}

local questSyncEvent = Net.Event("QuestSync")
local notifyEvent    = Net.Event("Notify")

local function isComplete(profile: any, q: any): boolean
	if q.reqConfirmed and not profile.providenceConfirmed then return false end
	if profile.realm > q.reqRealm then return true end
	if profile.realm == q.reqRealm then
		if q.reqStage == nil then return true end
		return profile.stage >= q.reqStage
	end
	return false
end

-- Build and fire the quest state table to the client
function QuestService.Refresh(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end

	local syncData: { [number]: { complete: boolean, claimed: boolean } } = {}
	for _, q in ipairs(QuestData.QUESTS) do
		local qs = profile.quests[q.id] or {}
		syncData[q.id] = {
			complete = isComplete(profile, q),
			claimed  = qs.claimed == true,
		}
	end
	questSyncEvent:FireClient(player, syncData)
end

function QuestService.Claim(player: Player, questIdRaw: any)
	local questId = tonumber(questIdRaw)
	if not questId then return end
	local profile = DataManager.Get(player)
	if not profile then return end

	local q = QuestData.GetQuest(questId)
	if not q then return end
	if not isComplete(profile, q) then
		notifyEvent:FireClient(player, "Quest not yet complete.", "warn")
		return
	end

	local qs = profile.quests[questId] or {}
	if qs.claimed then
		notifyEvent:FireClient(player, "Belohnung bereits abgeholt.", "warn")
		return
	end
	qs.claimed = true
	profile.quests[questId] = qs

	-- Grant rewards (raw EXP bypasses multipliers)
	if q.rewardExp and q.rewardExp > 0 then
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.AddEXP(player, q.rewardExp, true)
	end
	if q.rewardStones and q.rewardStones > 0 then
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.AddStones(player, q.rewardStones)
	end

	notifyEvent:FireClient(player, ("📜 Quest complete: %s"):format(q.name), "gold")
	QuestService.Refresh(player)
end

function QuestService.Start()
	local claimEvent = Net.Event("ClaimQuest")
	claimEvent.OnServerEvent:Connect(function(player, questId)
		QuestService.Claim(player, questId)
	end)
end

return QuestService
