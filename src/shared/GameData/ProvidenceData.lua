--!strict
-- ProvidenceData.lua
-- Das Kernsystem: beim ersten Join werden 4 Attribute gerollt, die das
-- gesamte Spiel des Charakters definieren — Physique, Connate Providence,
-- Dao Affinity (Aptitude liegt in AptitudeData). Werte aus der Spielreferenz.

local ProvidenceData = {}

-- ── Physique (Körper-Typ) ──────────────────────────────────
-- Werte sind die kombinierten Multiplikatoren bei Max-Stufe.
export type Physique = {
	name: string,
	role: string,
	chance: number,
	hpMult: number,    -- Faktor auf MaxHP (1.0 = neutral)
	dmgMult: number,   -- Faktor auf Damage
	defMult: number,   -- Faktor auf Defense
	expMult: number,   -- Faktor auf EXP-Gewinn
	color: string,
}

ProvidenceData.PHYSIQUES = {
	{ name = "Heaven Sealing", role = "Balanced", chance = 25, hpMult = 1.5,  dmgMult = 1.5,  defMult = 1.5,  expMult = 1.5,  color = "FCD34D" },
	{ name = "Six Paths",      role = "Combat",   chance = 25, hpMult = 1.3,  dmgMult = 1.6,  defMult = 1.3,  expMult = 1.6,  color = "A78BFA" },
	{ name = "Calamity Star",  role = "DMG",      chance = 25, hpMult = 1.0,  dmgMult = 1.7,  defMult = 1.0,  expMult = 1.0,  color = "FBBF24" },
	{ name = "Mortal Body",    role = "Tank",     chance = 25, hpMult = 1.5,  dmgMult = 1.0,  defMult = 1.35, expMult = 1.0,  color = "9CA3AF" },
} :: { Physique }

-- ── Connate Providence (geheime Seltenheit) ────────────────
export type Connate = {
	name: string,
	chance: number,
	statBonus: number, -- pauschaler Bonus auf alle Stats (1.0 = +0%)
}

ProvidenceData.CONNATES = {
	{ name = "Common",    chance = 50.0,  statBonus = 1.00 },
	{ name = "Uncommon",  chance = 25.0,  statBonus = 1.05 },
	{ name = "Rare",      chance = 13.0,  statBonus = 1.12 },
	{ name = "Epic",      chance = 7.0,   statBonus = 1.20 },
	{ name = "Legendary", chance = 3.5,   statBonus = 1.35 },
	{ name = "Mythic",    chance = 1.2,   statBonus = 1.55 },
	{ name = "Divine",    chance = 0.3,   statBonus = 2.00 },
} :: { Connate }

-- ── Dao Affinity ───────────────────────────────────────────
ProvidenceData.DAO_AFFINITIES = {
	"Sword", "Fire", "Void", "Life", "Thunder", "Ice", "Earth", "Space",
}

-- Gewichteter Roll über eine Liste mit `chance`-Feldern.
local function weightedRoll<T>(list: { T }): T
	local roll = math.random() * 100
	local cumulative = 0
	for _, entry in ipairs(list) do
		cumulative += (entry :: any).chance
		if roll <= cumulative then
			return entry
		end
	end
	return list[1]
end

function ProvidenceData.RollPhysique(): Physique
	return weightedRoll(ProvidenceData.PHYSIQUES)
end

function ProvidenceData.RollConnate(): Connate
	return weightedRoll(ProvidenceData.CONNATES)
end

function ProvidenceData.RollDao(): string
	local list = ProvidenceData.DAO_AFFINITIES
	return list[math.random(1, #list)]
end

function ProvidenceData.GetPhysique(name: string): Physique?
	for _, p in ipairs(ProvidenceData.PHYSIQUES) do
		if p.name == name then return p end
	end
	return nil
end

function ProvidenceData.GetConnate(name: string): Connate?
	for _, c in ipairs(ProvidenceData.CONNATES) do
		if c.name == name then return c end
	end
	return nil
end

return ProvidenceData
