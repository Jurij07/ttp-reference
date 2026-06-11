--!strict
-- QuestService.lua
-- Handles two quest systems:
--   1. Realm-based quests (QuestData.QUESTS): auto-unlock at reqRealm/reqStage.
--      Players claim rewards via ClaimQuest remote.
--   2. NPC sequential chains (QuestData.NPC_CHAINS): given by NPCs, max 3 active,
--      progression tracked by kills/realms/stones. AcceptNpcQuest/AbandonNpcQuest.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData  = ReplicatedStorage:WaitForChild("GameData")
local QuestData = require(GameData:WaitForChild("QuestData"))
local Net       = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local QuestService = {}

QuestService.MAX_NPC_ACTIVE = 3

-- ── Realm-quest helpers ──────────────────────────────────────
local questSyncEvent = Net.Event("QuestSync")
local notifyEvent    = Net.Event("Notify")

local function isRealmQuestComplete(profile: any, q: any): boolean
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
			complete = isRealmQuestComplete(profile, q),
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
	if not isRealmQuestComplete(profile, q) then
		notifyEvent:FireClient(player, "Quest not yet complete.", "warn")
		return
	end

	local qs = profile.quests[questId] or {}
	if qs.claimed then
		notifyEvent:FireClient(player, "Reward already claimed.", "warn")
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

-- ── NPC quest helpers ────────────────────────────────────────
-- profile.npcQuests = { active = { {id, progress={kills=n}} }, completed = {id, ...} }
local function npcQP(player: Player): any?
	local profile = DataManager.Get(player)
	if not profile then return nil end
	if type(profile.npcQuests) ~= "table" then
		profile.npcQuests = { active = {}, completed = {} }
	end
	profile.npcQuests.active    = profile.npcQuests.active    or {}
	profile.npcQuests.completed = profile.npcQuests.completed or {}
	return profile.npcQuests
end

local function npcIsCompleted(qp: any, id: string): boolean
	for _, cid in ipairs(qp.completed) do if cid == id then return true end end
	return false
end

local function npcGetActive(qp: any, id: string): any?
	for _, aq in ipairs(qp.active) do if aq.id == id then return aq end end
	return nil
end

local function sendNpcList(player: Player)
	local qp = npcQP(player); if not qp then return end
	Net.Event("NpcQuestList"):FireClient(player, qp.active, qp.completed)
end

-- Quests the player could accept right now: chain starters not yet done,
-- plus the next step of every completed quest.
local function sendNpcAvailable(player: Player)
	local qp = npcQP(player); if not qp then return end
	local avail: { any } = {}
	for _, starter in ipairs(QuestData.GetNpcStarterQuests()) do
		if not npcIsCompleted(qp, starter.id) and not npcGetActive(qp, starter.id) then
			table.insert(avail, starter)
		end
	end
	for _, cid in ipairs(qp.completed) do
		local nx = QuestData.GetNextNpcQuest(cid)
		if nx and not npcIsCompleted(qp, nx.id) and not npcGetActive(qp, nx.id) then
			table.insert(avail, nx)
		end
	end
	Net.Event("NpcAvailableQuests"):FireClient(player, avail)
end

function QuestService.CompleteNpcQuest(player: Player, questId: string)
	local qp = npcQP(player); if not qp then return end
	local profile = DataManager.Get(player); if not profile then return end
	for i, aq in ipairs(qp.active) do
		if aq.id == questId then table.remove(qp.active, i); break end
	end
	if npcIsCompleted(qp, questId) then return end
	table.insert(qp.completed, questId)
	local quest = QuestData.NPC_ALL[questId]
	if quest then
		local CS = require(script.Parent.CultivationService)
		if quest.rewards.exp and quest.rewards.exp > 0 then
			CS.AddEXP(player, quest.rewards.exp, true)
		end
		if quest.rewards.stones and quest.rewards.stones > 0 then
			CS.AddStones(player, quest.rewards.stones)
		end
		notifyEvent:FireClient(player, ("📜 Quest complete: %s — +%d EXP, +%d 💰")
			:format(quest.title, quest.rewards.exp or 0, quest.rewards.stones or 0), "gold")
	end
	Net.Event("NpcQuestCompleted"):FireClient(player, questId, quest and quest.rewards or {})
	sendNpcList(player)
	sendNpcAvailable(player)
end

-- Called by CombatService.rewardKill after every NPC kill.
function QuestService.OnNPCKilled(player: Player, npcName: string, realmId: number)
	local qp = npcQP(player); if not qp then return end
	local changed = false
	for _, aq in ipairs(qp.active) do
		local quest = QuestData.NPC_ALL[aq.id]
		if quest then
			for _, obj in ipairs(quest.objectives) do
				local hit = false
				if obj.type == "kill" and obj.target
					and string.find(npcName, obj.target :: string, 1, true) then
					hit = true
				elseif obj.type == "kill_realm" and obj.realm == realmId then
					hit = true
				end
				if hit then
					aq.progress = aq.progress or {}
					aq.progress.kills = (aq.progress.kills or 0) + 1
					changed = true
					if aq.progress.kills >= (obj.count or 1) then
						QuestService.CompleteNpcQuest(player, aq.id)
						return
					end
				end
			end
		end
	end
	if changed then sendNpcList(player) end
end

-- Called by CultivationService after a realm breakthrough.
function QuestService.OnRealmReached(player: Player, realm: number)
	local qp = npcQP(player); if not qp then return end
	for _, aq in ipairs(qp.active) do
		local quest = QuestData.NPC_ALL[aq.id]
		if quest then
			for _, obj in ipairs(quest.objectives) do
				if obj.type == "reach_realm" and realm >= (obj.realm or math.huge) then
					QuestService.CompleteNpcQuest(player, aq.id)
					return
				end
			end
		end
	end
end

-- Called by CultivationService.AddStones (lifetime earnings check).
function QuestService.OnStonesChanged(player: Player, lifetimeStones: number)
	local qp = npcQP(player); if not qp then return end
	for _, aq in ipairs(qp.active) do
		local quest = QuestData.NPC_ALL[aq.id]
		if quest then
			for _, obj in ipairs(quest.objectives) do
				if obj.type == "earn_stones" and lifetimeStones >= (obj.count or math.huge) then
					QuestService.CompleteNpcQuest(player, aq.id)
					return
				end
			end
		end
	end
end

-- ── Start ────────────────────────────────────────────────────
function QuestService.Start()
	-- Create client-bound remotes eagerly: the client's Net.Event() blocks in
	-- WaitForChild, so they must exist before any UIController references them.
	Net.Event("NpcQuestList")
	Net.Event("NpcAvailableQuests")
	Net.Event("NpcQuestCompleted")

	-- Realm-based quest claim
	Net.Event("ClaimQuest").OnServerEvent:Connect(function(player, questId)
		QuestService.Claim(player, questId)
	end)

	-- NPC quest accept (max 3 active at a time)
	Net.Event("AcceptNpcQuest").OnServerEvent:Connect(function(player: Player, questIdRaw: unknown)
		local id = tostring(questIdRaw)
		local qp = npcQP(player); if not qp then return end
		if #qp.active >= QuestService.MAX_NPC_ACTIVE then
			notifyEvent:FireClient(player,
				("Max %d active quests at a time."):format(QuestService.MAX_NPC_ACTIVE), "warn")
			return
		end
		if npcIsCompleted(qp, id) or npcGetActive(qp, id) then return end
		local quest = QuestData.NPC_ALL[id]
		if not quest then return end
		-- Sequential gate: non-starter steps require the previous step done.
		if quest.step > 1 then
			local chain = QuestData.NPC_CHAINS[quest.chain]
			local prev = chain and chain[quest.step - 1]
			if prev and not npcIsCompleted(qp, prev.id) then
				notifyEvent:FireClient(player, "Complete the previous quest of this chain first.", "warn")
				return
			end
		end
		table.insert(qp.active, { id = id, progress = {} })
		sendNpcList(player)
		sendNpcAvailable(player)
		notifyEvent:FireClient(player, ("%s Quest accepted: %s"):format(quest.icon, quest.title), "good")
	end)

	-- NPC quest abandon
	Net.Event("AbandonNpcQuest").OnServerEvent:Connect(function(player: Player, questIdRaw: unknown)
		local id = tostring(questIdRaw)
		local qp = npcQP(player); if not qp then return end
		for i, aq in ipairs(qp.active) do
			if aq.id == id then
				table.remove(qp.active, i)
				sendNpcList(player)
				sendNpcAvailable(player)
				notifyEvent:FireClient(player, "Quest abandoned.", "warn")
				return
			end
		end
	end)

	-- Client requests the full NPC quest state
	Net.Event("GetNpcQuests").OnServerEvent:Connect(function(player: Player)
		sendNpcList(player)
		sendNpcAvailable(player)
	end)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.delay(1.5, function()
			if player.Parent then
				QuestService.Refresh(player)
				sendNpcList(player)
				sendNpcAvailable(player)
			end
		end)
	end)

	print("[QuestService] Started — realm quests + NPC sequential chains (max "
		.. QuestService.MAX_NPC_ACTIVE .. " active).")
end

return QuestService
