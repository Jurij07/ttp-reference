--!strict
-- ProvidenceService.lua
-- Verwaltet Providence: würfelt 4 Attribute einzeln, steuert das Startmenü.
-- Nach dem Bestätigen sind KEINE freien Rerolls mehr möglich (nur Robux).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData  = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local ProvidenceService = {}

-- ── Attribute auf den Player schreiben ─────────────────────
local function applyAttributes(player: Player, prov: any, rerolls: any)
	player:SetAttribute("Aptitude",    prov.aptitude)
	player:SetAttribute("Physique",    prov.physique)
	player:SetAttribute("Connate",     prov.connate)
	player:SetAttribute("DaoAffinity", prov.dao)

	local grade = AptitudeData.GetByName(prov.aptitude)
	player:SetAttribute("AptitudeMult", grade and grade.mult or 1.0)

	-- Individuelle Reroll-Zähler
	player:SetAttribute("Rerolls_Aptitude", rerolls.aptitude)
	player:SetAttribute("Rerolls_Physique",  rerolls.physique)
	player:SetAttribute("Rerolls_Connate",   rerolls.connate)
	player:SetAttribute("Rerolls_Dao",       rerolls.dao)
end

-- ── Kompletten Providence-Satz würfeln ─────────────────────
local function rollAll(): any
	return {
		aptitude = AptitudeData.Roll().name,
		physique  = ProvidenceData.RollPhysique().name,
		connate   = ProvidenceData.RollConnate().name,
		dao       = ProvidenceData.RollDao(),
	}
end

-- ── Sicherstellen, dass Spieler einen Providence-Satz hat ──
function ProvidenceService.EnsureRolled(player: Player, profile: any)
	if not profile.providence then
		profile.providence = rollAll()
	end
	applyAttributes(player, profile.providence, profile.rerolls)
end

-- ── Stat-Multiplikatoren ────────────────────────────────────
function ProvidenceService.GetMultipliers(player: Player): { hp: number, dmg: number, def: number, exp: number, lifespan: number }
	local profile = DataManager.Get(player)
	local prov = profile and profile.providence

	local physique = prov and ProvidenceData.GetPhysique(prov.physique)
	local connate  = prov and ProvidenceData.GetConnate(prov.connate)
	local grade    = prov and AptitudeData.GetByName(prov.aptitude)

	local statBonus    = connate and connate.statBonus    or 1.0
	local lifespanMult = connate and connate.lifespanMult or 1.0

	return {
		hp       = (physique and physique.hpMult  or 1.0) * statBonus,
		dmg      = (physique and physique.dmgMult or 1.0) * statBonus,
		def      = (physique and physique.defMult or 1.0) * statBonus,
		exp      = (physique and physique.expMult or 1.0) * (grade and grade.mult or 1.0),
		lifespan = lifespanMult,
	}
end

-- ── Einzelnes Attribut neu würfeln ─────────────────────────
-- attrName: "aptitude" | "physique" | "connate" | "dao"
function ProvidenceService.RerollAttr(player: Player, attrName: string): (boolean, string)
	local profile = DataManager.Get(player)
	if not profile then return false, "Kein Profil geladen." end

	-- Nach Bestätigung gesperrt
	if profile.providenceConfirmed then
		return false, "Providence bereits bestätigt — weitere Rerolls nur mit Robux."
	end

	-- Validiere attrName
	local validAttrs = { aptitude = true, physique = true, connate = true, dao = true }
	if not validAttrs[attrName] then
		return false, "Unbekanntes Attribut."
	end

	-- Prüfe Reroll-Zähler
	local remaining = profile.rerolls[attrName] or 0
	if remaining <= 0 then
		return false, ("Keine freien %s-Rerolls mehr."):format(attrName)
	end

	-- Würfeln
	profile.rerolls[attrName] = remaining - 1
	if attrName == "aptitude" then
		profile.providence.aptitude = AptitudeData.Roll().name
	elseif attrName == "physique" then
		profile.providence.physique = ProvidenceData.RollPhysique().name
	elseif attrName == "connate" then
		profile.providence.connate = ProvidenceData.RollConnate().name
	elseif attrName == "dao" then
		profile.providence.dao = ProvidenceData.RollDao()
	end

	applyAttributes(player, profile.providence, profile.rerolls)
	return true, "OK"
end

-- ── Providence bestätigen → Gameplay starten ───────────────
function ProvidenceService.Confirm(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	if profile.providenceConfirmed then return end
	profile.providenceConfirmed = true
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.BeginGameplay(player)
end

-- ── Service-Start ──────────────────────────────────────────
function ProvidenceService.Start()
	local rerollEvent   = Net.Event("RerollAttr")
	local confirmEvent  = Net.Event("ConfirmProvidence")

	rerollEvent.OnServerEvent:Connect(function(player, attrName)
		local ok, msg = ProvidenceService.RerollAttr(player, tostring(attrName))
		rerollEvent:FireClient(player, ok, msg)
	end)

	confirmEvent.OnServerEvent:Connect(function(player)
		ProvidenceService.Confirm(player)
	end)
end

return ProvidenceService
