--!strict
-- IdleService.lua
-- Idle-game layer: cultivation progresses on its own.
--   • Passive EXP every second — a fraction of the current stage requirement,
--     so every realm feels equally alive. Routed through
--     CultivationService.AddEXP, so Providence/buff/zone multipliers apply.
--   • Passive spirit-stone trickle (scales with realm).
--   • Auto-Hunt: the player picks a realm zone; every few seconds the server
--     simulates one fight and pays out the NPC's EXP/stones/kill. The realm
--     boss is challenged automatically as soon as the player can beat it,
--     which keeps stage gates flowing without manual combat.
--   • Offline progress: time away (capped) pays the same rewards at reduced
--     efficiency; the client shows a "Welcome back" summary.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local NPCData = require(GameData:WaitForChild("NPCData"))

local DataManager = require(script.Parent.DataManager)
local CultivationService = require(script.Parent.CultivationService)

local IdleService = {}

local notifyEvent = Net.Event("Notify")

local stoneAccum: { [number]: number } = {}      -- fractional stone carry-over
local sessionKills: { [number]: number } = {}    -- auto-hunt kills this session
local tooWeakNotified: { [number]: boolean } = {}
local gateHinted: { [number]: boolean } = {}
local offlineDone: { [number]: boolean } = {}    -- offline credit granted?
local pendingOffline: { [number]: any } = {}     -- summary waiting for the client

-- ── Helpers ──────────────────────────────────────────────────
local function passiveExpPerSec(profile: any): number
	return CultivationData.GetStageEXP(profile.realm, profile.stage)
		* Config.IDLE_STAGE_FRACTION_PER_SEC
end

-- Non-boss mobs + the boss of a realm.
local function huntPool(realmId: number): ({ NPCData.NPC }, NPCData.NPC?)
	local mobs: { NPCData.NPC } = {}
	local boss: NPCData.NPC? = nil
	for _, n in ipairs(NPCData.GetRealmNPCs(realmId) or {} :: { NPCData.NPC }) do
		if n.boss then boss = n else table.insert(mobs, n) end
	end
	return mobs, boss
end

-- Simulated fight: compare both time-to-kill values using the same stat
-- formulas as CombatService (attack cooldown vs. 1 counter per second).
local function canWin(player: Player, npc: NPCData.NPC): boolean
	local atk   = (player:GetAttribute("ATK")     or 10)  :: number
	local def   = (player:GetAttribute("Defense") or 0)   :: number
	local maxHP = (player:GetAttribute("MaxHP")   or 100) :: number
	local playerDps = math.max(atk - npc.def, 1) / Config.ATTACK_COOLDOWN
	local npcDps = math.max(npc.dmg - def, 1)
	return npc.hp / playerDps <= maxHP / npcDps
end

local function payKill(player: Player, npc: NPCData.NPC, realmId: number)
	CultivationService.AddEXP(player, npc.exp)
	CultivationService.AddStones(player, npc.stones)
	CultivationService.AddKill(player)
	sessionKills[player.UserId] = (sessionKills[player.UserId] or 0) + 1
	player:SetAttribute("HuntKills", sessionKills[player.UserId])
	if npc.boss then
		CultivationService.OnBossKilled(player, realmId)
		notifyEvent:FireClient(player,
			("👑 Auto-Hunt defeated %s! Stage gate opened."):format(npc.name), "gold")
	end
	local ok, QS = pcall(require, script.Parent.QuestService)
	if ok then (QS :: any).OnNPCKilled(player, npc.name, realmId) end
end

-- One auto-hunt round for a player.
local function huntTick(player: Player, profile: any)
	local realmId = math.floor(tonumber(profile.idleHuntRealm) or 0)
	if realmId < 1 then return end
	local mobs, boss = huntPool(realmId)
	-- Boss first: it gates stage progression.
	if boss and not profile.bossesKilled[realmId] and canWin(player, boss) then
		payKill(player, boss, realmId)
		return
	end
	if #mobs == 0 then return end
	local npc = mobs[math.random(#mobs)]
	if canWin(player, npc) then
		tooWeakNotified[player.UserId] = nil
		payKill(player, npc, realmId)
	elseif not tooWeakNotified[player.UserId] then
		tooWeakNotified[player.UserId] = true
		notifyEvent:FireClient(player,
			("⚠️ Auto-Hunt: %s is too strong — train or pick a lower zone."):format(npc.name), "warn")
	end
end

-- Passive cultivation + stone trickle, once per second.
local function passiveTick(player: Player, profile: any, dt: number)
	-- Don't slam a tribulation gate with low HP — the auto-retry would fail
	-- forever. Wait until regen brings the player back to ≥90% MaxHP.
	local maxStage = CultivationData.GetMaxStage(profile.realm)
	if profile.realm >= 3 and profile.stage >= maxStage then
		local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
		if profile.exp >= needed - 1 then
			local hp    = (player:GetAttribute("HP")    or 0) :: number
			local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
			if hp < maxHP * 0.9 then return end
		end
	end

	CultivationService.AddEXP(player, passiveExpPerSec(profile) * dt)

	local uid = player.UserId
	stoneAccum[uid] = (stoneAccum[uid] or 0) + Config.IDLE_STONES_PER_SEC_BASE * profile.realm * dt
	if stoneAccum[uid] >= 1 then
		local whole = math.floor(stoneAccum[uid])
		stoneAccum[uid] -= whole
		CultivationService.AddStones(player, whole)
	end

	-- Stuck at a boss gate without hunting the right realm? Hint once.
	if not profile.bossesKilled[profile.realm] then
		local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
		if profile.stage >= maxStage - 1 and profile.exp >= needed - 1
			and math.floor(tonumber(profile.idleHuntRealm) or 0) ~= profile.realm
			and not gateHinted[uid] then
			gateHinted[uid] = true
			notifyEvent:FireClient(player,
				"💡 A realm boss blocks your progress — set Auto-Hunt to your current realm to challenge it.", "info")
		end
	end
end

-- ── Offline progress ─────────────────────────────────────────
local function grantOffline(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local last = tonumber(profile.lastSeenAt) or 0
	profile.lastSeenAt = os.time()
	offlineDone[player.UserId] = true
	if last <= 0 or not profile.providenceConfirmed then return end

	local away = os.time() - last
	if away < Config.OFFLINE_MIN_SECS then return end
	local elapsed = math.min(away, Config.OFFLINE_CAP_HOURS * 3600)
	local eff = Config.OFFLINE_EFFICIENCY

	local exp    = passiveExpPerSec(profile) * elapsed * eff
	local stones = Config.IDLE_STONES_PER_SEC_BASE * profile.realm * elapsed * eff

	local kills = 0
	local realmId = math.floor(tonumber(profile.idleHuntRealm) or 0)
	if realmId >= 1 then
		local mobs = huntPool(realmId)
		if #mobs > 0 then
			kills = math.min(
				math.floor(elapsed / Config.IDLE_HUNT_TICK_SECS * eff),
				Config.OFFLINE_MAX_HUNT_KILLS)
			local sumExp, sumStones = 0, 0
			for _, n in ipairs(mobs) do sumExp += n.exp; sumStones += n.stones end
			exp    += sumExp / #mobs * kills
			stones += sumStones / #mobs * kills
		end
	end

	exp = math.floor(exp); stones = math.floor(stones)
	CultivationService.AddEXP(player, exp, true)
	CultivationService.AddStones(player, stones)
	if kills > 0 then
		profile.totalKills = (profile.totalKills or 0) + kills
		player:SetAttribute("TotalKills", profile.totalKills)
		local TitleService = require(script.Parent.TitleService)
		TitleService.CheckUnlocks(player)
	end

	pendingOffline[player.UserId] = {
		seconds = away, capped = away > elapsed,
		exp = exp, stones = stones, kills = kills,
	}
end

local function pushOffline(player: Player)
	local sum = pendingOffline[player.UserId]
	if not sum then return end
	pendingOffline[player.UserId] = nil
	Net.Event("OfflineProgress"):FireClient(player, sum)
end

-- ── Start ────────────────────────────────────────────────────
function IdleService.Start()
	-- Client-bound remote must exist before the client's WaitForChild.
	Net.Event("OfflineProgress")

	Net.Event("SetHuntRealm").OnServerEvent:Connect(function(player: Player, realmRaw: unknown)
		local profile = DataManager.Get(player)
		if not profile then return end
		local realmId = math.floor(tonumber(realmRaw) or -1)
		if realmId < 0 then return end
		if realmId ~= 0 and NPCData.GetRealmNPCs(realmId) == nil then return end
		if realmId > profile.realm then
			notifyEvent:FireClient(player, "🔒 Reach that realm before hunting there.", "warn")
			return
		end
		profile.idleHuntRealm = realmId
		tooWeakNotified[player.UserId] = nil
		gateHinted[player.UserId] = nil
		player:SetAttribute("HuntRealm", realmId)
		if realmId >= 1 then
			notifyEvent:FireClient(player, ("🏹 Auto-Hunt started in realm %d."):format(realmId), "good")
		else
			notifyEvent:FireClient(player, "🏹 Auto-Hunt stopped.", "info")
		end
	end)

	-- Client asks for the offline summary once its UI is ready.
	Net.Event("GetOfflineSummary").OnServerEvent:Connect(pushOffline)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		-- Small delay so CultivationService.initPlayer has set the combat
		-- attributes (an offline lump can trigger an instant tribulation).
		task.delay(2, function()
			if not player.Parent then return end
			grantOffline(player)
			local profile = DataManager.Get(player)
			player:SetAttribute("HuntRealm", profile and math.floor(tonumber(profile.idleHuntRealm) or 0) or 0)
			player:SetAttribute("HuntKills", 0)
		end)
		-- Fallback push in case the client requested before we computed.
		task.delay(8, function()
			if player.Parent then pushOffline(player) end
		end)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local profile = DataManager.Get(player)
		-- Only stamp if offline credit was already granted this session —
		-- otherwise a quick rejoin would swallow the pending offline time.
		if profile and offlineDone[player.UserId] then
			profile.lastSeenAt = os.time()
		end
		local uid = player.UserId
		stoneAccum[uid] = nil; sessionKills[uid] = nil
		tooWeakNotified[uid] = nil; gateHinted[uid] = nil
		offlineDone[uid] = nil; pendingOffline[uid] = nil
	end)

	-- Main idle loop: passive tick every second, hunt tick every few seconds.
	task.spawn(function()
		local sinceHunt = 0
		while true do
			task.wait(1)
			sinceHunt += 1
			local doHunt = sinceHunt >= Config.IDLE_HUNT_TICK_SECS
			if doHunt then sinceHunt = 0 end
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = DataManager.Get(player)
				if not profile then continue end
				if offlineDone[player.UserId] then
					profile.lastSeenAt = os.time()
				end
				if not profile.providenceConfirmed then continue end
				if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion")
					or player:GetAttribute("InTribulation") then continue end
				passiveTick(player, profile, 1)
				if doHunt then huntTick(player, profile) end
			end
		end
	end)

	print("[IdleService] Started — passive cultivation, auto-hunt, offline progress.")
end

return IdleService
