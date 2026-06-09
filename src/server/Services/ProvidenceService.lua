--!strict
-- ProvidenceService.lua
-- Verwaltet das Providence-System: würfelt die 4 Attribute (Aptitude, Physique,
-- Connate, Dao), stellt die Stat-Multiplikatoren bereit und steuert das
-- Start-Menü (Roll → Reroll → Bestätigen). Vor der Bestätigung ist der Spieler
-- im Menü-Zustand (InMenu) und kann nicht spielen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local ProvidenceService = {}

-- Schreibt die Providence-Attribute auf den Player (replizieren zum Client).
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

-- Stellt sicher, dass ein Spieler einen (Vorschau-)Providence-Satz hat.
function ProvidenceService.EnsureRolled(player: Player, profile: any)
	if not profile.providence then
		profile.providence = rollAll()
	end
	applyAttributes(player, profile.providence)
	player:SetAttribute("FreeRerolls", profile.freeRerolls)
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

-- Würfelt neu (verbraucht ein kostenloses Reroll-Credit).
-- Gibt (success, providence | fehlermeldung) zurück.
function ProvidenceService.Reroll(player: Player): (boolean, any)
	local profile = DataManager.Get(player)
	if not profile then
		return false, "Kein Profil geladen."
	end
	if profile.freeRerolls <= 0 then
		return false, "Keine kostenlosen Rerolls mehr (Robux-Reroll folgt später)."
	end
	profile.freeRerolls -= 1
	profile.providence = rollAll()
	applyAttributes(player, profile.providence)
	player:SetAttribute("FreeRerolls", profile.freeRerolls)

	-- Falls bereits bestätigt (In-Game-Reroll): Stats sofort neu berechnen.
	if profile.providenceConfirmed then
		local CultivationService = require(script.Parent.CultivationService)
		CultivationService.RecomputeStats(player)
	end
	return true, profile.providence
end

-- Bestätigt die Providence und startet das Gameplay.
function ProvidenceService.Confirm(player: Player)
	local profile = DataManager.Get(player)
	if not profile then
		return
	end
	profile.providenceConfirmed = true
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.BeginGameplay(player)
end

function ProvidenceService.Start()
	local rerollEvent = Net.Event("RerollProvidence")
	rerollEvent.OnServerEvent:Connect(function(player)
		local ok, payload = ProvidenceService.Reroll(player)
		local profile = DataManager.Get(player)
		rerollEvent:FireClient(player, ok, payload, profile and profile.freeRerolls or 0)
	end)

	local confirmEvent = Net.Event("ConfirmProvidence")
	confirmEvent.OnServerEvent:Connect(function(player)
		ProvidenceService.Confirm(player)
	end)
end

return ProvidenceService
