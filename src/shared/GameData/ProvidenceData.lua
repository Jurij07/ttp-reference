--!strict
-- ProvidenceData.lua
-- Physique, Connate und Dao Affinity mit Pros/Cons und Dao-Stat-Boni.

local ProvidenceData = {}

-- ── Physique ───────────────────────────────────────────────
export type Physique = {
	name: string, role: string, chance: number,
	hpMult: number, dmgMult: number, defMult: number, expMult: number,
	pros: string, cons: string, lore: string, color: string,
}

ProvidenceData.PHYSIQUES = {
	{
		name="Heaven Sealing", role="Ausgewogen", chance=28,
		hpMult=1.5, dmgMult=1.5, defMult=1.5, expMult=0.9,
		pros="HP +50% · DMG +50% · DEF +50%",
		cons="EXP −10% (Himmelsketten drosseln Kultivierung)",
		lore="Vom Himmel selbst versiegelt — gleichzeitig beschützt. Perfekte Balance, aber der Himmel bremst dein Wachstum.",
		color="FCD34D",
	},
	{
		name="Six Paths", role="Kampf", chance=22,
		hpMult=1.0, dmgMult=2.0, defMult=0.8, expMult=1.6,
		pros="DMG ×2.0 · EXP +60%",
		cons="DEF −20% (zu aggressiv zum Verteidigen)",
		lore="Verkörpert die Sechs Pfade der Reinkarnation. Jeder Kampf bringt Einsicht — aber der Körper ist anfällig.",
		color="A78BFA",
	},
	{
		name="Calamity Star", role="Glaskanone", chance=18,
		hpMult=0.7, dmgMult=2.5, defMult=0.6, expMult=1.2,
		pros="DMG ×2.5 · EXP +20%",
		cons="HP −30% · DEF −40% (Katastrophe trifft auch dich selbst)",
		lore="Unter einem Unstern geboren — Glück und Verhängnis im gleichen Atemzug. Feinde schmelzen, doch das Schicksal schlägt zurück.",
		color="F87171",
	},
	{
		name="Mortal Sacred", role="Tank", chance=20,
		hpMult=2.2, dmgMult=0.7, defMult=2.0, expMult=0.6,
		pros="HP ×2.2 · DEF ×2.0",
		cons="DMG −30% · EXP −40% (Sterbliche Wurzeln — langsam zu blühen)",
		lore="Scheinbar der schwächste aller Körper — in Wahrheit ein schlafender Heiliger. Zeit und Leid verwandeln Sterbliches in Göttliches.",
		color="94A3B8",
	},
	{
		name="Peerless Saint", role="Kultivator", chance=9,
		hpMult=1.2, dmgMult=1.2, defMult=1.2, expMult=3.0,
		pros="EXP ×3.0 · alle Stats +20%",
		cons="Keine Kampf-Spezialisierung",
		lore="Ein Körper, der für den Dao geschaffen wurde. Der Dao offenbart sich schneller als bei allen anderen — kämpfen ist Nebensache.",
		color="34D399",
	},
	{
		name="Blood Demon", role="Berserker", chance=3,
		hpMult=0.8, dmgMult=3.0, defMult=0.5, expMult=1.5,
		pros="DMG ×3.0 · EXP +50%",
		cons="HP −20% · DEF −50% · zieht Himmelsgerichte an",
		lore="Von dämonischem Blut verflucht und gesegnet. Unvergleichliche Vernichtungskraft — doch der Himmel selbst will dich zerschmettern.",
		color="EF4444",
	},
} :: { Physique }

-- ── Connate Providence ─────────────────────────────────────
export type Connate = {
	name: string, chance: number,
	statBonus: number, lifespanMult: number,
	pros: string, cons: string,
}

ProvidenceData.CONNATES = {
	{ name="Common",    chance=44.0, statBonus=1.00, lifespanMult=1.00, pros="Keine Einschränkungen",            cons="Kein Bonus" },
	{ name="Uncommon",  chance=25.0, statBonus=1.05, lifespanMult=1.00, pros="Alle Stats +5%",                   cons="—" },
	{ name="Rare",      chance=14.0, statBonus=1.12, lifespanMult=1.00, pros="Alle Stats +12%",                  cons="—" },
	{ name="Epic",      chance=8.5,  statBonus=1.22, lifespanMult=1.05, pros="Alle Stats +22% · Lebensspanne +5%",cons="—" },
	{ name="Legendary", chance=5.0,  statBonus=1.40, lifespanMult=1.10, pros="Alle Stats +40% · Lebensspanne +10%",cons="—" },
	{ name="Mythic",    chance=2.0,  statBonus=1.70, lifespanMult=0.85, pros="Alle Stats +70%",                  cons="Lebensspanne −15%" },
	{ name="Divine",    chance=1.0,  statBonus=2.20, lifespanMult=0.70, pros="Alle Stats ×2.2",                  cons="Lebensspanne −30%" },
	{ name="Chaos",     chance=0.5,  statBonus=3.00, lifespanMult=0.50, pros="Alle Stats ×3.0",                  cons="Lebensspanne −50%" },
} :: { Connate }

-- ── Dao Affinity (mit echten Stat-Boni) ────────────────────
export type DaoEntry = {
	name: string, desc: string, color: string,
	hpMult: number, dmgMult: number, defMult: number, expMult: number,
	pros: string, cons: string,
}

ProvidenceData.DAO_DATA = {
	{
		name="Sword",   color="F87171",
		desc="Schneidet durch alles. Pure offensive Perfection.",
		hpMult=1.0,  dmgMult=1.10, defMult=1.00, expMult=1.0,
		pros="DMG +10%", cons="—",
	},
	{
		name="Fire",    color="FB923C",
		desc="Verbrennendes Qi. Reinigt Unreinheiten durch Flammen.",
		hpMult=0.95, dmgMult=1.12, defMult=1.00, expMult=1.0,
		pros="DMG +12%", cons="HP −5%",
	},
	{
		name="Void",    color="A78BFA",
		desc="Die Leere zwischen den Welten. Nichts und Raum als Waffe.",
		hpMult=1.0,  dmgMult=1.15, defMult=0.85, expMult=1.0,
		pros="DMG +15%", cons="DEF −15%",
	},
	{
		name="Life",    color="34D399",
		desc="Der Fluss der Vitalität. Verbesserte Heilung und Langlebigkeit.",
		hpMult=1.15, dmgMult=1.00, defMult=1.00, expMult=1.05,
		pros="HP +15% · EXP +5%", cons="—",
	},
	{
		name="Thunder", color="FBBF24",
		desc="Himmelsblitz in körperlicher Form. Geschwindigkeit und Macht.",
		hpMult=1.0,  dmgMult=1.15, defMult=0.95, expMult=1.0,
		pros="DMG +15%", cons="DEF −5%",
	},
	{
		name="Ice",     color="67E8F9",
		desc="Unbewegte Kälte. Verlangsamt Feinde, kristallisiert Qi.",
		hpMult=1.0,  dmgMult=0.95, defMult=1.10, expMult=1.0,
		pros="DEF +10%", cons="DMG −5%",
	},
	{
		name="Earth",   color="A3E635",
		desc="Unerschütterlich wie ein Berg. Defensive Macht und Ausdauer.",
		hpMult=1.10, dmgMult=0.90, defMult=1.15, expMult=1.0,
		pros="HP +10% · DEF +15%", cons="DMG −10%",
	},
	{
		name="Space",   color="818CF8",
		desc="Realität selbst verbiegen. Teleportation, dimensionale Kräfte.",
		hpMult=1.0,  dmgMult=1.00, defMult=0.92, expMult=1.10,
		pros="EXP +10%", cons="DEF −8%",
	},
} :: { DaoEntry }

ProvidenceData.DAO_AFFINITIES = {}
for _, d in ipairs(ProvidenceData.DAO_DATA) do
	table.insert(ProvidenceData.DAO_AFFINITIES, d.name)
end

local function weightedRoll<T>(list: { T }): T
	local roll = math.random() * 100
	local cumulative = 0
	for _, entry in ipairs(list) do
		cumulative += (entry :: any).chance
		if roll <= cumulative then return entry end
	end
	return list[1]
end

function ProvidenceData.RollPhysique(): Physique  return weightedRoll(ProvidenceData.PHYSIQUES) end
function ProvidenceData.RollConnate():  Connate   return weightedRoll(ProvidenceData.CONNATES)  end
function ProvidenceData.RollDao(): string
	local list = ProvidenceData.DAO_DATA
	return list[math.random(1, #list)].name
end
function ProvidenceData.GetPhysique(n: string): Physique?  for _,p in ipairs(ProvidenceData.PHYSIQUES) do if p.name==n then return p end end; return nil end
function ProvidenceData.GetConnate(n: string):  Connate?   for _,c in ipairs(ProvidenceData.CONNATES)  do if c.name==n then return c end end; return nil end
function ProvidenceData.GetDaoData(n: string):  DaoEntry?  for _,d in ipairs(ProvidenceData.DAO_DATA)  do if d.name==n then return d end end; return nil end

return ProvidenceData
