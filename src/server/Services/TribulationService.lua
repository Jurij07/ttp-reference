--!strict
-- TribulationService.lua
-- Heaven Tribulation: ab Realm 3 löst ein Durchbruch eine Reihe von
-- Blitz-Wellen aus. Der Spieler muss alle Wellen überleben. Schaden pro
-- Welle = Bruchteil der MaxHP, beeinflusst von Karma und Durchbruch-Resistenz
-- (aus Sekte + Physique-Evolution). Überlebt der Spieler → Realm-Aufstieg
-- + Belohnung. Stirbt er → Durchbruch scheitert, erneuter Versuch möglich.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local TribulationData = require(GameData:WaitForChild("TribulationData"))
local SectData = require(GameData:WaitForChild("SectData"))
local PhysiqueEvolutionData = require(GameData:WaitForChild("PhysiqueEvolutionData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local TribulationService = {}

local notifyEvent = Net.Event("Notify")

-- Server-side signal fired when a player survives a tribulation. Other services
-- (e.g. TribulationPeakAnnouncementService) listen to this; the client-facing
-- TribulationEnded RemoteEvent cannot be observed on the server.
local survivedBindable = Instance.new("BindableEvent")
TribulationService.Survived = survivedBindable.Event

local WAVE_INTERVAL = 1.4  -- Sekunden zwischen Blitz-Wellen

-- Gesamte Durchbruch-Resistenz aus Sekte + Physique-Evolution (max. 0.75).
local function breakthroughResist(profile: any): number
	local resist = 0.0
	if profile.sectId then
		local sect = SectData.Get(profile.sectId)
		if sect then
			local buff = SectData.BuffAtLevel(sect, profile.sectLevel or 0)
			if buff then resist += buff.breakthroughBonus end
		end
	end
	local prov = profile.providence
	local evo = PhysiqueEvolutionData.ResolveStage(prov and prov.physique, profile.realm, profile.totalExpEarned or 0)
	resist += evo.breakthroughBonus
	-- Equipped title may add tribulation resist (break_bonus).
	if profile.activeTitle then
		local TitleData = require(GameData:WaitForChild("TitleData"))
		local t = TitleData.Get(profile.activeTitle)
		if t then resist += t.breakBonus end
	end
	return math.clamp(resist, 0, 0.75)
end

function TribulationService.Begin(player: Player, fromRealm: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	if player:GetAttribute("InTribulation") then return end

	local trib = TribulationData.GetForRealm(fromRealm)
	if not trib then
		-- Keine Tribulation → direkter Aufstieg
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.DoRealmUp(player)
		return
	end

	player:SetAttribute("InTribulation", true)
	player:SetAttribute("TribulationName", trib.name)
	player:SetAttribute("TribulationWave", 0)
	player:SetAttribute("TribulationWaves", trib.waves)

	Net.Event("TribulationStarted"):FireClient(player, trib.name, trib.waves)
	notifyEvent:FireClient(player, ("⚡ %s! Survive %d waves!"):format(trib.name, trib.waves), "warn")

	local resist = breakthroughResist(profile)
	local fraction = TribulationData.DamageFraction(trib, profile.karma or 0) * (1 - resist)

	task.spawn(function()
		for wave = 1, trib.waves do
			task.wait(WAVE_INTERVAL)
			-- Spieler verlassen? abbrechen
			if not player.Parent or not player:GetAttribute("InTribulation") then return end

			local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
			local hp    = (player:GetAttribute("HP")    or 0) :: number
			local dmg = math.floor(maxHP * fraction)
			hp -= dmg

			player:SetAttribute("TribulationWave", wave)
			Net.Event("TribulationWave"):FireClient(player, wave, trib.waves, dmg)

			if hp <= 0 then
				-- Durchbruch gescheitert
				player:SetAttribute("HP", math.max(1, math.floor(maxHP * 0.15)))
				player:SetAttribute("InTribulation", false)
				Net.Event("TribulationEnded"):FireClient(player, false)
				notifyEvent:FireClient(player, "💀 Tribulation failed! Heal up and try again.", "warn")
				return
			end
			player:SetAttribute("HP", hp)
		end

		-- Alle Wellen überlebt → Erfolg
		player:SetAttribute("InTribulation", false)
		Net.Event("TribulationEnded"):FireClient(player, true)
		survivedBindable:Fire(player, fromRealm)
		profile.tribulationsSurvived = (profile.tribulationsSurvived or 0) + 1
		local TitleService = require(script.Parent.TitleService)
		TitleService.CheckUnlocks(player)

		-- Erst aufsteigen (setzt exp=0, Realm+1), DANN Belohnung auf den
		-- neuen Realm gutschreiben — sonst würde die Belohnungs-EXP sofort
		-- erneut die Tribulation auslösen.
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.DoRealmUp(player)
		CultivationService.AddStones(player, trib.rewardStones)
		CultivationService.AddEXP(player, trib.rewardExp, true)
		notifyEvent:FireClient(player,
			("✨ Survived %s! +%d EXP, +%d 💰"):format(trib.name, trib.rewardExp, trib.rewardStones), "gold")
	end)
end

function TribulationService.Start()
	-- Events vorab erstellen, damit der Client sie sofort findet.
	Net.Event("TribulationStarted")
	Net.Event("TribulationWave")
	Net.Event("TribulationEnded")
end

return TribulationService
