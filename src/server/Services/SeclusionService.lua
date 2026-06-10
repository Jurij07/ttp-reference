--!strict
-- SeclusionService.lua
-- Klausur-System: Spieler wählt 1–N Jahre geschlossene Kultivierung.
-- Belohnung (EXP + Stones) proportional zu Jahren; Spieler altert entsprechend.
-- Real-Zeit-Kosten: 1 Klausurjahr = Config.SECLUSION_SECS_PER_YEAR Sekunden.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager    = require(script.Parent.DataManager)
local CultivationService = require(script.Parent.CultivationService)

local SeclusionService = {}

local notifyEvent = Net.Event("Notify")

-- Laufende Klausuren: userId → { startTime, years, thread }
local activeSeclusions: { [number]: { startTime: number, years: number, thread: thread } } = {}

-- ── Hilfsfunktion: Belohnung vergeben ──────────────────────
local function grantRewards(player: Player, yearsEffective: number, yearsAged: number)
	local profile = DataManager.Get(player)
	if not profile then return end

	local stageEXP = CultivationData.GetStageEXP(profile.realm, profile.stage)
	local totalEXP = stageEXP * Config.SECLUSION_EXP_PER_YEAR * yearsEffective
	local stones   = math.floor(Config.SECLUSION_STONES_PER_YEAR * yearsEffective)

	profile.age += yearsAged
	CultivationService.AddEXP(player, totalEXP)
	CultivationService.AddStones(player, stones)
	player:SetAttribute("Age", math.floor(profile.age))

	-- Alterungstod prüfen
	local maxLife = player:GetAttribute("MaxLifespan") or 0
	if profile.age >= maxLife then
		profile.age = Config.STARTING_AGE
		profile.exp = 0
		notifyEvent:FireClient(player, "☠️ Lifespan exhausted during seclusion — a new life begins (age 18).", "warn")
		CultivationService.RecomputeStats(player)
	end

	return math.floor(totalEXP), stones
end

-- ── Klausur abschließen (vollständig) ──────────────────────
local function finishSeclusion(player: Player, years: number)
	activeSeclusions[player.UserId] = nil
	player:SetAttribute("InSeclusion", false)
	player:SetAttribute("SeclusionYears", 0)

	local expGained, stonesGained = grantRewards(player, years, years)
	Net.Event("SeclusionFinished"):FireClient(player, expGained or 0, stonesGained or 0, years, false)
	notifyEvent:FireClient(
		player,
		("☯️ Seclusion complete! +%d years, +EXP, +%d Stones."):format(years, stonesGained or 0),
		"gold"
	)
	-- Quest-Meldung: Klausur abgeschlossen
	local QuestService = require(script.Parent.QuestService)
	QuestService.Report(player, "seclusion", 1)
end

-- ── Klausur starten ────────────────────────────────────────
function SeclusionService.StartSeclusion(player: Player, years: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end

	-- Jahre einschränken auf max. verbleibende Lebensspanne − 1
	local maxLife = player:GetAttribute("MaxLifespan") or 100
	local currentAge = math.floor(profile.age)
	local maxYears = math.max(1, math.floor(maxLife - currentAge - 1))
	years = math.clamp(math.floor(years), 1, maxYears)

	local duration = years * Config.SECLUSION_SECS_PER_YEAR

	player:SetAttribute("InSeclusion", true)
	player:SetAttribute("SeclusionYears", years)

	-- Dem Client Dauer mitteilen (für Countdown)
	Net.Event("SeclusionStarted"):FireClient(player, duration, years)
	notifyEvent:FireClient(player, ("🧘 Seclusion begun: %d years — %d real minutes."):format(years, math.ceil(duration / 60)), "info")

	local thread = task.delay(duration, function()
		if player.Parent then
			finishSeclusion(player, years)
		else
			activeSeclusions[player.UserId] = nil
		end
	end)

	activeSeclusions[player.UserId] = { startTime = os.clock(), years = years, thread = thread }
end

-- ── Klausur vorzeitig abbrechen ────────────────────────────
function SeclusionService.CancelSeclusion(player: Player)
	local data = activeSeclusions[player.UserId]
	if not data then return end

	task.cancel(data.thread)
	activeSeclusions[player.UserId] = nil
	player:SetAttribute("InSeclusion", false)
	player:SetAttribute("SeclusionYears", 0)

	local elapsed = os.clock() - data.startTime
	local yearsElapsed = elapsed / Config.SECLUSION_SECS_PER_YEAR
	local yearsEffective = yearsElapsed * Config.SECLUSION_CANCEL_FACTOR  -- Abzug
	local yearsAged = yearsElapsed  -- Alter trotzdem vergangen

	local expGained, stonesGained = grantRewards(player, yearsEffective, yearsAged)
	Net.Event("SeclusionFinished"):FireClient(player, expGained or 0, stonesGained or 0, math.floor(yearsAged), true)
	notifyEvent:FireClient(
		player,
		("⚠️ Seclusion canceled! Only %.1f years cultivated (−30%% penalty)."):format(yearsAged),
		"warn"
	)
end

-- ── Service-Start ──────────────────────────────────────────
function SeclusionService.Start()
	-- Alle Events vorab erstellen, damit der Client sie sofort findet.
	local startEvent    = Net.Event("StartSeclusion")
	local cancelEvent   = Net.Event("CancelSeclusion")
	Net.Event("SeclusionStarted")   -- pre-create
	Net.Event("SeclusionFinished")  -- pre-create

	startEvent.OnServerEvent:Connect(function(player, years)
		SeclusionService.StartSeclusion(player, tonumber(years) or 1)
	end)

	cancelEvent.OnServerEvent:Connect(function(player)
		SeclusionService.CancelSeclusion(player)
	end)

	-- Beim Verlassen laufende Klausur sofort (ohne Belohnung) abbrechen
	Players.PlayerRemoving:Connect(function(player)
		local data = activeSeclusions[player.UserId]
		if data then
			task.cancel(data.thread)
			activeSeclusions[player.UserId] = nil
		end
	end)
end

return SeclusionService
