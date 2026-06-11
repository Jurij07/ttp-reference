--!strict
-- IdleService.lua
-- Idle-game layer: cultivation progresses on its own.
--   • Passive EXP every second (fraction of stage EXP × EnhancementService mult).
--   • Passive spirit-stone trickle (scales with realm × Enhancement mult).
--   • Auto-Hunt: simulated fights every EnhancementService.GetHuntTick seconds.
--   • Offline progress: up to 12h at 50% efficiency, "Welcome back" popup.
--   • Feeds DailyService hooks for every gain and kill.

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

local stoneAccum: { [number]: number } = {}
local sessionKills: { [number]: number } = {}
local huntAccum: { [number]: number } = {}       -- per-player seconds since last hunt
local tooWeakNotified: { [number]: boolean } = {}
local gateHinted: { [number]: boolean } = {}
local offlineDone: { [number]: boolean } = {}
local pendingOffline: { [number]: any } = {}

local function passiveExpPerSec(profile: any): number
	return CultivationData.GetStageEXP(profile.realm, profile.stage)
		* Config.IDLE_STAGE_FRACTION_PER_SEC
end

local function huntPool(realmId: number): ({ NPCData.NPC }, NPCData.NPC?)
	local mobs: { NPCData.NPC } = {}
	local boss: NPCData.NPC? = nil
	for _, n in ipairs(NPCData.GetRealmNPCs(realmId) or {} :: { NPCData.NPC }) do
		if n.boss then boss = n else table.insert(mobs, n) end
	end
	return mobs, boss
end

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
	local ok1, QS = pcall(require, script.Parent.QuestService)
	if ok1 then (QS :: any).OnNPCKilled(player, npc.name, realmId) end
	local ok2, DS = pcall(require, script.Parent.DailyService)
	if ok2 then (DS :: any).OnKill(player) end
end

local function huntTick(player: Player, profile: any)
	local realmId = math.floor(tonumber(profile.idleHuntRealm) or 0)
	if realmId < 1 then return end
	local mobs, boss = huntPool(realmId)
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
	-- Daily: count hunt ticks
	local ok, DS = pcall(require, script.Parent.DailyService)
	if ok then (DS :: any).OnHuntTick(player) end
end

local function passiveTick(player: Player, profile: any, dt: number)
	local maxStage = CultivationData.GetMaxStage(profile.realm)
	if profile.realm >= 3 and profile.stage >= maxStage then
		local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
		if profile.exp >= needed - 1 then
			local hp    = (player:GetAttribute("HP")    or 0) :: number
			local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
			if hp < maxHP * 0.9 then return end
		end
	end

	local okE, ES = pcall(require, script.Parent.EnhancementService)
	local expMult   = okE and (ES :: any).GetExpMult(player)   or 1
	local stoneMult = okE and (ES :: any).GetStoneMult(player) or 1

	local expGain = passiveExpPerSec(profile) * expMult * dt
	CultivationService.AddEXP(player, expGain)
	local ok2, DS2 = pcall(require, script.Parent.DailyService)
	if ok2 then (DS2 :: any).OnEXPEarned(player, expGain) end

	local uid = player.UserId
	stoneAccum[uid] = (stoneAccum[uid] or 0)
		+ Config.IDLE_STONES_PER_SEC_BASE * profile.realm * stoneMult * dt
	if stoneAccum[uid] >= 1 then
		local whole = math.floor(stoneAccum[uid])
		stoneAccum[uid] -= whole
		CultivationService.AddStones(player, whole)
		-- Stone daily progress is tracked inside CultivationService.AddStones
		-- via QuestService.OnStonesChanged; re-use that same path.
	end

	-- Boss-gate hint
	local uid2 = player.UserId
	if not profile.bossesKilled[profile.realm] then
		local needed = CultivationData.GetStageEXP(profile.realm, profile.stage)
		if profile.stage >= maxStage - 1 and profile.exp >= needed - 1
			and math.floor(tonumber(profile.idleHuntRealm) or 0) ~= profile.realm
			and not gateHinted[uid2] then
			gateHinted[uid2] = true
			notifyEvent:FireClient(player,
				"💡 A realm boss blocks your progress — set Auto-Hunt to your current realm to challenge it.", "info")
		end
	end
end

-- Daily stone progress: piggy-back on AddStones — hook it via CultivationService.
-- We intercept the actual stone gain by wrapping the AddStones signal via a small
-- shim that DailyService also listens to (see DailyService.OnStonesEarned).

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

	local okE2, ES2 = pcall(require, script.Parent.EnhancementService)
	local expMult2   = okE2 and (ES2 :: any).GetExpMult(player)   or 1
	local stoneMult2 = okE2 and (ES2 :: any).GetStoneMult(player) or 1

	local exp    = passiveExpPerSec(profile) * expMult2 * elapsed * eff
	local stones = Config.IDLE_STONES_PER_SEC_BASE * profile.realm * stoneMult2 * elapsed * eff

	local kills = 0
	local realmId = math.floor(tonumber(profile.idleHuntRealm) or 0)
	if realmId >= 1 then
		local mobs = huntPool(realmId)
		if #mobs > 0 then
			local huntTick2 = 5
			if okE2 then huntTick2 = (ES2 :: any).GetHuntTick(player) end
			kills = math.min(
				math.floor(elapsed / huntTick2 * eff),
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

	Net.Event("GetOfflineSummary").OnServerEvent:Connect(pushOffline)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.delay(2, function()
			if not player.Parent then return end
			grantOffline(player)
			local profile = DataManager.Get(player)
			player:SetAttribute("HuntRealm", profile and math.floor(tonumber(profile.idleHuntRealm) or 0) or 0)
			player:SetAttribute("HuntKills", 0)
		end)
		task.delay(8, function()
			if player.Parent then pushOffline(player) end
		end)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local profile = DataManager.Get(player)
		if profile and offlineDone[player.UserId] then
			profile.lastSeenAt = os.time()
		end
		local uid = player.UserId
		stoneAccum[uid] = nil; sessionKills[uid] = nil; huntAccum[uid] = nil
		tooWeakNotified[uid] = nil; gateHinted[uid] = nil
		offlineDone[uid] = nil; pendingOffline[uid] = nil
	end)

	-- Main idle loop: 1-second tick.  Hunt uses per-player counters so each
	-- player's Swift-Hunt upgrade takes effect independently.
	task.spawn(function()
		while true do
			task.wait(1)
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

				-- Per-player hunt timer
				local uid = player.UserId
				huntAccum[uid] = (huntAccum[uid] or 0) + 1
				local okES, ES = pcall(require, script.Parent.EnhancementService)
				local htick = okES and (ES :: any).GetHuntTick(player) or Config.IDLE_HUNT_TICK_SECS
				if huntAccum[uid] >= htick then
					huntAccum[uid] = 0
					huntTick(player, profile)
				end
			end
		end
	end)

	print("[IdleService] Started — passive cultivation, auto-hunt, offline progress.")
end

return IdleService
