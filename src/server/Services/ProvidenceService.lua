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
function ProvidenceService.GetMultipliers(player: Player): { hp: number, dmg: number, def: number, exp: number, lifespan: number, bonusLifespan: number? }
	local profile = DataManager.Get(player)
	local prov    = profile and profile.providence

	local physique  = prov and ProvidenceData.GetPhysique(prov.physique)
	local connate   = prov and ProvidenceData.GetConnate(prov.connate)
	local grade     = prov and AptitudeData.GetByName(prov.aptitude)
	local daoEntry  = prov and ProvidenceData.GetDaoData(prov.dao)

	local statBonus    = connate   and connate.statBonus    or 1.0
	local lifespanMult = connate   and connate.lifespanMult or 1.0

	-- Physique-Evolution (skaliert mit Realm + Total-EXP)
	local PhysiqueEvolutionData = require(GameData:WaitForChild("PhysiqueEvolutionData"))
	local evo = PhysiqueEvolutionData.ResolveStage(
		prov and prov.physique,
		profile and profile.realm or 1,
		profile and profile.totalExpEarned or 0
	)
	local eHp  = evo.statMult * evo.hpMult
	local eDmg = evo.statMult * evo.dmgMult
	local eDef = evo.statMult * evo.defMult
	local eExp = evo.statMult * evo.expMult

	-- Sekten-Buffs (falls beigetreten)
	local sHp, sDmg, sDef, sExp = 1.0, 1.0, 1.0, 1.0
	if profile and profile.sectId then
		local SectData = require(GameData:WaitForChild("SectData"))
		local sect = SectData.Get(profile.sectId)
		if sect then
			local buff = SectData.BuffAtLevel(sect, profile.sectLevel or 0)
			if buff then
				sHp, sDmg, sDef, sExp = buff.hpMult, buff.dmgMult, buff.defMult, buff.expMult
			end
		end
	end

	-- Aptitude trägt jetzt mehrere Stats bei (nicht nur EXP).
	local aHp   = grade and grade.hpMult       or 1.0
	local aDmg  = grade and grade.dmgMult      or 1.0
	local aDef  = grade and grade.defMult      or 1.0
	local aExp  = grade and grade.expMult      or (grade and grade.mult) or 1.0
	local aLife = grade and grade.lifespanMult or 1.0

	-- Companion / Formation / Title / Leaderboard-rank bonuses
	local CompanionService   = require(script.Parent.CompanionService)
	local FormationService    = require(script.Parent.FormationService)
	local TitleService        = require(script.Parent.TitleService)
	local LeaderboardService  = require(script.Parent.LeaderboardService)
	local comp = CompanionService.GetActiveBonus(player)
	local form = FormationService.GetActiveBonus(player)
	local titl = TitleService.GetActiveBonus(player)
	local rank = LeaderboardService.GetRankBonus(player)

	return {
		hp  = (physique and physique.hpMult  or 1.0) * statBonus * (daoEntry and daoEntry.hpMult  or 1.0) * eHp  * sHp  * aHp  * comp.hp  * form.hp  * titl.hp  * rank.all,
		dmg = (physique and physique.dmgMult or 1.0) * statBonus * (daoEntry and daoEntry.dmgMult or 1.0) * eDmg * sDmg * aDmg * comp.dmg * form.dmg * titl.dmg * rank.all * rank.dmg,
		def = (physique and physique.defMult or 1.0) * statBonus * (daoEntry and daoEntry.defMult or 1.0) * eDef * sDef * aDef * comp.def * form.def * titl.def * rank.all,
		exp = (physique and physique.expMult or 1.0) * aExp * (daoEntry and daoEntry.expMult or 1.0) * eExp * sExp * comp.exp * form.exp * titl.exp * rank.exp,
		lifespan = lifespanMult * aLife,
		bonusLifespan = comp.lifespan,
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
