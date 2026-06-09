--!strict
-- ProvidenceService.lua
-- Verwaltet Providence: würfelt 4 Attribute einzeln, steuert Startmenü.
-- Dao Affinity gibt echte Stat-Boni (hpMult, dmgMult, defMult, expMult).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData      = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData  = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local ProvidenceService = {}

local function applyAttributes(player: Player, prov: any, rerolls: any)
	player:SetAttribute("Aptitude",         prov.aptitude)
	player:SetAttribute("Physique",         prov.physique)
	player:SetAttribute("Connate",          prov.connate)
	player:SetAttribute("DaoAffinity",      prov.dao)
	local grade = AptitudeData.GetByName(prov.aptitude)
	player:SetAttribute("AptitudeMult",     grade and grade.mult or 1.0)
	player:SetAttribute("Rerolls_Aptitude", rerolls.aptitude)
	player:SetAttribute("Rerolls_Physique", rerolls.physique)
	player:SetAttribute("Rerolls_Connate",  rerolls.connate)
	player:SetAttribute("Rerolls_Dao",      rerolls.dao)
end

local function rollAll(): any
	return {
		aptitude = AptitudeData.Roll().name,
		physique  = ProvidenceData.RollPhysique().name,
		connate   = ProvidenceData.RollConnate().name,
		dao       = ProvidenceData.RollDao(),
	}
end

function ProvidenceService.EnsureRolled(player: Player, profile: any)
	if not profile.providence then profile.providence = rollAll() end
	applyAttributes(player, profile.providence, profile.rerolls)
end

-- ── Stat-Multiplikatoren (inkl. Dao-Boni) ─────────────────
function ProvidenceService.GetMultipliers(player: Player): { hp: number, dmg: number, def: number, exp: number, lifespan: number }
	local profile = DataManager.Get(player)
	local prov    = profile and profile.providence

	local physique  = prov and ProvidenceData.GetPhysique(prov.physique)
	local connate   = prov and ProvidenceData.GetConnate(prov.connate)
	local grade     = prov and AptitudeData.GetByName(prov.aptitude)
	local daoEntry  = prov and ProvidenceData.GetDaoData(prov.dao)

	local statBonus    = connate   and connate.statBonus    or 1.0
	local lifespanMult = connate   and connate.lifespanMult or 1.0

	return {
		hp  = (physique and physique.hpMult  or 1.0) * statBonus * (daoEntry and daoEntry.hpMult  or 1.0),
		dmg = (physique and physique.dmgMult or 1.0) * statBonus * (daoEntry and daoEntry.dmgMult or 1.0),
		def = (physique and physique.defMult or 1.0) * statBonus * (daoEntry and daoEntry.defMult or 1.0),
		exp = (physique and physique.expMult or 1.0) * (grade and grade.mult or 1.0) * (daoEntry and daoEntry.expMult or 1.0),
		lifespan = lifespanMult,
	}
end

-- ── Einzelnes Attribut reroll ──────────────────────────────
function ProvidenceService.RerollAttr(player: Player, attrName: string): (boolean, string)
	local profile = DataManager.Get(player)
	if not profile then return false, "Kein Profil." end
	if profile.providenceConfirmed then return false, "Bereits bestätigt — Reroll nur noch mit Robux." end

	local validAttrs = { aptitude=true, physique=true, connate=true, dao=true }
	if not validAttrs[attrName] then return false, "Unbekanntes Attribut." end

	if (profile.rerolls[attrName] or 0) <= 0 then
		return false, ("Keine freien %s-Rerolls mehr."):format(attrName)
	end

	profile.rerolls[attrName] -= 1
	if     attrName == "aptitude" then profile.providence.aptitude = AptitudeData.Roll().name
	elseif attrName == "physique" then profile.providence.physique = ProvidenceData.RollPhysique().name
	elseif attrName == "connate"  then profile.providence.connate  = ProvidenceData.RollConnate().name
	elseif attrName == "dao"      then profile.providence.dao      = ProvidenceData.RollDao()
	end

	applyAttributes(player, profile.providence, profile.rerolls)
	return true, "OK"
end

function ProvidenceService.Confirm(player: Player)
	local profile = DataManager.Get(player)
	if not profile or profile.providenceConfirmed then return end
	profile.providenceConfirmed = true
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.BeginGameplay(player)
end

function ProvidenceService.Start()
	local rerollEvent  = Net.Event("RerollAttr")
	local confirmEvent = Net.Event("ConfirmProvidence")

	rerollEvent.OnServerEvent:Connect(function(player, attrName)
		local ok, msg = ProvidenceService.RerollAttr(player, tostring(attrName))
		rerollEvent:FireClient(player, ok, msg)
	end)

	confirmEvent.OnServerEvent:Connect(function(player)
		ProvidenceService.Confirm(player)
	end)
end

return ProvidenceService
