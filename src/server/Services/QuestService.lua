--!strict
-- QuestService.lua
-- Verfolgt Quest-Fortschritt und vergibt Belohnungen. Andere Services melden
-- Ereignisse via QuestService.Report(player, kind, value). Der Client erhält den
-- Quest-Zustand über das RemoteEvent "QuestSync".
--
-- profile.quests[questId] = { progress = number, claimed = boolean }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData  = ReplicatedStorage:WaitForChild("GameData")
local QuestData = require(GameData:WaitForChild("QuestData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local QuestService = {}

local notifyEvent = Net.Event("Notify")
local questSync   = Net.Event("QuestSync")

-- Stellt sicher, dass die Quest-Struktur existiert.
local function ensureQuests(profile: any)
	if type(profile.quests) ~= "table" then profile.quests = {} end
	for _, q in ipairs(QuestData.QUESTS) do
		if type(profile.quests[q.id]) ~= "table" then
			profile.quests[q.id] = { progress = 0, claimed = false }
		end
	end
end

-- Baut eine zum Client schickbare Zustandstabelle.
local function buildState(profile: any): any
	local state = {}
	for _, q in ipairs(QuestData.QUESTS) do
		local pq = profile.quests[q.id]
		state[q.id] = {
			progress = pq.progress,
			target   = q.target,
			claimed  = pq.claimed,
			complete = pq.progress >= q.target,
		}
	end
	return state
end

local function sync(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	ensureQuests(profile)
	questSync:FireClient(player, buildState(profile))
end
QuestService.Sync = sync

-- Meldet ein Ereignis. kind: "kills" | "boss" | "realm" | "seclusion".
function QuestService.Report(player: Player, kind: string, value: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	ensureQuests(profile)

	local changed = false
	for _, q in ipairs(QuestData.QUESTS) do
		if q.qtype == kind then
			local pq = profile.quests[q.id]
			if q.qtype == "realm" then
				if value > pq.progress then pq.progress = value; changed = true end
			else
				pq.progress += value; changed = true
			end
		end
	end

	if changed then sync(player) end
end

-- Belohnung auszahlen (lazy require, um Zyklen zu vermeiden).
local function grantReward(player: Player, q: any)
	local CultivationService = require(script.Parent.CultivationService)
	if q.stones and q.stones > 0 then
		CultivationService.AddStones(player, q.stones)
	end
	if q.expFactor and q.expFactor > 0 then
		local profile = DataManager.Get(player)
		if profile then
			local CultivationData = require(GameData:WaitForChild("CultivationData"))
			local stageEXP = CultivationData.GetStageEXP(profile.realm, profile.stage)
			CultivationService.AddEXP(player, stageEXP * q.expFactor)
		end
	end
	if q.rewardItem then
		local ShopService = require(script.Parent.ShopService)
		ShopService.GiveItem(player, q.rewardItem, 1)
	end
end

-- Spieler beansprucht die Belohnung einer abgeschlossenen Quest.
function QuestService.Claim(player: Player, questId: string)
	local profile = DataManager.Get(player)
	if not profile then return end
	ensureQuests(profile)

	local q = QuestData.GetQuest(questId)
	local pq = q and profile.quests[questId]
	if not q or not pq then return end
	if pq.claimed then return end
	if pq.progress < q.target then return end

	pq.claimed = true
	grantReward(player, q)

	local reward = {}
	if q.stones and q.stones > 0 then table.insert(reward, ("%d Stones"):format(q.stones)) end
	if q.expFactor then table.insert(reward, "EXP") end
	if q.rewardItem then table.insert(reward, "1 Item") end
	notifyEvent:FireClient(player, ("🏅 Quest '%s' belohnt: %s"):format(q.name, table.concat(reward, ", ")), "gold")

	sync(player)
end

function QuestService.Start()
	-- Beim Profil-Laden: Struktur sichern, aktuellen Realm-Fortschritt setzen, syncen.
	DataManager.ProfileLoaded:Connect(function(player)
		local profile = DataManager.Get(player)
		if not profile then return end
		ensureQuests(profile)
		-- Realm-Quests auf aktuellen Realm initialisieren.
		QuestService.Report(player, "realm", profile.realm)
		sync(player)
	end)

	local claimEvent = Net.Event("ClaimQuest")
	claimEvent.OnServerEvent:Connect(function(player, questId)
		QuestService.Claim(player, tostring(questId))
	end)
end

return QuestService
