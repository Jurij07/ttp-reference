--!strict
-- ProvidenceService.lua
-- Verwaltet das Providence-System: würfelt beim ersten Join die 4 Attribute
-- (Aptitude, Physique, Connate, Dao), speichert sie und stellt die daraus
-- resultierenden Multiplikatoren bereit. Bietet zudem einen Reroll-Remote.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local ProvidenceService = {}

-- Schreibt die Providence-Attribute auf das Player-Objekt, damit der Client
-- sie automatisch (per Attribut-Replikation) anzeigen kann.
local function applyAttributes(player: Player, providence: any)
	player:SetAttribute("Aptitude", providence.aptitude)
	player:SetAttribute("Physique", providence.physique)
	player:SetAttribute("Connate", providence.connate)
	player:SetAttribute("DaoAffinity", providence.dao)

	local grade = AptitudeData.GetByName(providence.aptitude)
	player:SetAttribute("AptitudeMult", grade and grade.mult or 1.0)
end

-- Würfelt einen kompletten neuen Providence-Satz.
local function rollAll(): any
	return {
		aptitude = AptitudeData.Roll().name,
		physique = ProvidenceData.RollPhysique().name,
		connate = ProvidenceData.RollConnate().name,
		dao = ProvidenceData.RollDao(),
	}
end

-- Stellt sicher, dass ein Spieler Providence besitzt (würfelt beim 1. Join).
function ProvidenceService.EnsureRolled(player: Player, profile: any)
	if not profile.providence then
		profile.providence = rollAll()
	end
	applyAttributes(player, profile.providence)
end

-- Liefert die kombinierten Stat-Multiplikatoren eines Spielers.
function ProvidenceService.GetMultipliers(player: Player): { hp: number, dmg: number, def: number, exp: number }
	local profile = DataManager.Get(player)
	local prov = profile and profile.providence

	local physique = prov and ProvidenceData.GetPhysique(prov.physique)
	local connate = prov and ProvidenceData.GetConnate(prov.connate)
	local grade = prov and AptitudeData.GetByName(prov.aptitude)

	local statBonus = connate and connate.statBonus or 1.0

	return {
		hp = (physique and physique.hpMult or 1.0) * statBonus,
		dmg = (physique and physique.dmgMult or 1.0) * statBonus,
		def = (physique and physique.defMult or 1.0) * statBonus,
		exp = (physique and physique.expMult or 1.0) * (grade and grade.mult or 1.0),
	}
end

function ProvidenceService.Start()
	local rerollEvent = Net.Event("RerollProvidence")

	-- Client bittet um Reroll-All. Verbraucht ein kostenloses Reroll-Credit
	-- pro Attribut (vereinfachtes Modell für den ersten Stand).
	rerollEvent.OnServerEvent:Connect(function(player)
		local profile = DataManager.Get(player)
		if not profile then
			return
		end
		local r = profile.rerolls
		if not r or r.aptitude <= 0 then
			-- keine kostenlosen Rerolls mehr — hier später Robux-Kauf prüfen
			rerollEvent:FireClient(player, false, "Keine kostenlosen Rerolls mehr.")
			return
		end
		r.aptitude -= 1
		r.physique = math.max(r.physique - 1, 0)
		r.connate = math.max(r.connate - 1, 0)
		r.dao = math.max(r.dao - 1, 0)

		profile.providence = rollAll()
		applyAttributes(player, profile.providence)

		-- CultivationService neu berechnen lassen (Stats hängen von Providence ab).
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.RecomputeStats(player)

		rerollEvent:FireClient(player, true, profile.providence)
	end)
end

return ProvidenceService
