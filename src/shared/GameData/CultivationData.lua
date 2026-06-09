--!strict
-- CultivationData.lua
-- Die zentrale Datenbasis für das Cultivation-System: alle 26 Realms,
-- EXP-Formel, Lifespan-Basiswerte und abgeleitete Combat-Stats.
-- Werte stammen aus der Spielreferenz (index.html).
--
-- EXP-Formel:  EXP(realm, stage) = expStage1[realm] × STAGE_CURVE[stages][stage]
--   expStage1 = BASE_EXP(1000) × RealmMultiplier
--   Realm-Multiplikatoren (Mortal): ×1, ×8, ×60, ×400, ×2500, ×15000, ×80000, ×400000, ×2M
--   Stage-Kurve (9 Stages): ×1, ×1.5, ×2.2, ×3.2, ×4.5, ×6.5, ×9, ×13, ×18

local CultivationData = {}

CultivationData.BASE_EXP = 1000

-- Stage-Multiplikator-Kurven je nach Anzahl Stages eines Realms.
CultivationData.STAGE_CURVES = {
	[9] = { 1, 1.5, 2.2, 3.2, 4.5, 6.5, 9, 13, 18 },
	[6] = { 1, 3, 6, 9, 12, 15 },
	[4] = { 1, 5, 10, 15 },
	[1] = { 1 },
}

-- Alle 26 Realms. expStage1 = EXP für Stage 1 dieses Realms.
-- lifespan = Basis-Lebensspanne in Jahren (vor Aptitude-Bonus & Items).
export type Realm = {
	id: number,
	name: string,
	tier: string,
	stages: number,
	lifespan: number,
	expStage1: number,
	color: string,
}

CultivationData.REALMS = {
	-- ── Mortal Tier (9 Stages) ──
	{ id = 1,  name = "Qi Refinement",              tier = "Mortal",     stages = 9, lifespan = 85,        expStage1 = 1000,            color = "60A5FA" },
	{ id = 2,  name = "Foundation Establishment",   tier = "Mortal",     stages = 9, lifespan = 187,       expStage1 = 8000,            color = "34D399" },
	{ id = 3,  name = "Golden Core",                tier = "Mortal",     stages = 9, lifespan = 499,       expStage1 = 60000,           color = "FBBF24" },
	{ id = 4,  name = "Nascent Soul",               tier = "Mortal",     stages = 9, lifespan = 1080,      expStage1 = 400000,          color = "A78BFA" },
	{ id = 5,  name = "Soul Formation",             tier = "Mortal",     stages = 9, lifespan = 3007,      expStage1 = 2500000,         color = "F87171" },
	{ id = 6,  name = "Void Amalgamation",          tier = "Mortal",     stages = 9, lifespan = 8970,      expStage1 = 15000000,        color = "22D3EE" },
	{ id = 7,  name = "Body Integration",           tier = "Mortal",     stages = 9, lifespan = 27900,     expStage1 = 80000000,        color = "FB923C" },
	{ id = 8,  name = "Tribulation Transcendence",  tier = "Mortal",     stages = 9, lifespan = 109200,    expStage1 = 400000000,       color = "FACC15" },
	{ id = 9,  name = "Mahayana",                   tier = "Mortal",     stages = 9, lifespan = 1000000,   expStage1 = 2000000000,      color = "F0ABFC" },
	-- ── Immortal Tier (4 Stages) ──
	{ id = 10, name = "Loose Immortal",             tier = "Immortal",   stages = 4, lifespan = 1294000,   expStage1 = 10e9,            color = "67E8F9" },
	{ id = 11, name = "Earth Immortal",             tier = "Immortal",   stages = 4, lifespan = 5761200,   expStage1 = 20e9,            color = "86EFAC" },
	{ id = 12, name = "Heaven Immortal",            tier = "Immortal",   stages = 4, lifespan = 14004399,  expStage1 = 30e9,            color = "FDE68A" },
	{ id = 13, name = "True Immortal",              tier = "Immortal",   stages = 4, lifespan = 37800531,  expStage1 = 40e9,            color = "C4B5FD" },
	{ id = 14, name = "Mystic Immortal",            tier = "Immortal",   stages = 4, lifespan = 120459999, expStage1 = 50e9,            color = "FCA5A5" },
	{ id = 15, name = "Golden Immortal",            tier = "Immortal",   stages = 4, lifespan = 12399999999, expStage1 = 60e9,          color = "6EE7B7" },
	-- ── ImpEmperor Tier ──
	{ id = 16, name = "Immortal Emperor",           tier = "ImpEmperor", stages = 9, lifespan = 2001999999999, expStage1 = 70e9,        color = "93C5FD" },
	-- ── Deity Tier ──
	{ id = 17, name = "Mystic Divine Origin",       tier = "Deity",      stages = 6, lifespan = 1e18,      expStage1 = 80e9,            color = "DDD6FE" },
	-- ── Zenith Tier ──
	{ id = 18, name = "Zenith Heaven Golden Immortal", tier = "Zenith",  stages = 4, lifespan = 1.01e20,   expStage1 = 90e9,            color = "FED7AA" },
	-- ── QuasiSage Tier ──
	{ id = 19, name = "Quasi-Sage (Pseudo Primordial)", tier = "QuasiSage", stages = 4, lifespan = 9.89e21, expStage1 = 100e9,         color = "99F6E4" },
	-- ── Sage Tier ──
	{ id = 20, name = "Perfect Sage",               tier = "Sage",       stages = 4, lifespan = 1.3e25,    expStage1 = 110e9,           color = "BAE6FD" },
	{ id = 21, name = "Freedom Primordial Chaos",   tier = "Sage",       stages = 4, lifespan = 9.4e27,    expStage1 = 120e9,           color = "E9D5FF" },
	{ id = 22, name = "Great Dao Primordial Chaos", tier = "Sage",       stages = 4, lifespan = 1.089e34,  expStage1 = 130e9,           color = "FEF3C7" },
	{ id = 23, name = "Great Dao Supreme",          tier = "Sage",       stages = 4, lifespan = 1.09e45,   expStage1 = 140e9,           color = "FCE7F3" },
	-- ── DaoC Tier ──
	{ id = 24, name = "Dao Creator",                tier = "DaoC",       stages = 4, lifespan = 7.29e81,   expStage1 = 150e9,           color = "D1FAE5" },
	-- ── Creator Tier ──
	{ id = 25, name = "Creator Lord",               tier = "Creator",    stages = 1, lifespan = 1.029e130, expStage1 = 160e9,           color = "E0F2FE" },
	{ id = 26, name = "Ultimate Origin Supreme",    tier = "Creator",    stages = 1, lifespan = math.huge, expStage1 = 170e9,           color = "FFFFFF" },
} :: { Realm }

-- Gibt die Realm-Definition zurück (oder nil).
function CultivationData.GetRealm(realmId: number): Realm?
	return CultivationData.REALMS[realmId]
end

-- Höchste Stage eines Realms.
function CultivationData.GetMaxStage(realmId: number): number
	local r = CultivationData.REALMS[realmId]
	return r and r.stages or 9
end

-- EXP, die für die angegebene Stage benötigt wird.
function CultivationData.GetStageEXP(realmId: number, stage: number): number
	local r = CultivationData.REALMS[realmId]
	if not r then
		return math.huge
	end
	local curve = CultivationData.STAGE_CURVES[r.stages] or CultivationData.STAGE_CURVES[9]
	local mult = curve[stage] or curve[#curve]
	return math.floor(r.expStage1 * mult)
end

-- Basis-Lebensspanne (Jahre) eines Realms vor jeglichen Boni.
function CultivationData.GetLifespan(realmId: number): number
	local r = CultivationData.REALMS[realmId]
	return r and r.lifespan or 85
end

-- Abgeleitete Combat-Stats (HP, Damage, Defense) für Realm + Stage.
-- Skaliert exponentiell mit dem Realm und linear innerhalb der Stages,
-- damit der Spieler immer etwas stärker als die NPCs seines Realms ist.
function CultivationData.GetCombatStats(realmId: number, stage: number): (number, number, number)
	local r = math.max(realmId - 1, 0)
	local s = math.max(stage - 1, 0)
	local hp = math.floor(120 * (1.6 ^ r) * (1 + 0.12 * s))
	local dmg = math.floor(12 * (1.5 ^ r) * (1 + 0.10 * s))
	local def = math.floor(3 * (1.4 ^ r) * (1 + 0.05 * s))
	return hp, dmg, def
end

return CultivationData
