--!strict
-- SectData.lua (from index.html — 4 Hidden Sects)
-- EXP per level = level × 1000. Sect EXP comes from combat (5% of your EXP),
-- quests and dungeons. Each milestone level grants stacking passive buffs.

local SectData = {}

export type SectBuff = {
	level: number,
	name: string,
	expMult: number,    -- multiplicative EXP bonus (1.0 = none)
	dmgMult: number,
	defMult: number,
	hpMult: number,
	breakthroughBonus: number, -- additive fraction (tribulation resist etc.)
}

export type Sect = {
	id: string,
	name: string,
	icon: string,
	reqRealm: number,
	maxLevel: number,
	desc: string,
	milestones: { SectBuff },
}

-- Parsed cumulative multipliers at each milestone (already folded into mult form).
SectData.SECTS = {
	{
		id="six_paths", name="Six Paths Hidden Sect", icon="☯️", reqRealm=3, maxLevel=10,
		desc="Han Jue's legendary sect. Buffs for every cultivation aspect.",
		milestones = {
			{ level=1,  name="Dao Foundation",       expMult=1.10, dmgMult=1.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=3,  name="Six Paths Insight",     expMult=1.25, dmgMult=1.10, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=5,  name="Hidden Sect Legacy",    expMult=1.50, dmgMult=1.20, defMult=1.15, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=8,  name="Immortal Inheritance",  expMult=2.00, dmgMult=1.30, defMult=1.30, hpMult=1.30, breakthroughBonus=0.00 },
			{ level=10, name="Han Jue's Will",        expMult=3.00, dmgMult=1.50, defMult=1.50, hpMult=1.50, breakthroughBonus=0.20 },
		},
	},
	{
		id="calamity_star", name="Calamity Star Sect", icon="💫", reqRealm=2, maxLevel=10,
		desc="Damage-focused sect. Makes you the strongest attacker.",
		milestones = {
			{ level=1,  name="Calamity Brand",     expMult=1.00, dmgMult=1.15, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=3,  name="Star Curse",         expMult=1.00, dmgMult=1.25, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=5,  name="Calamity Domain",    expMult=1.00, dmgMult=1.40, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=8,  name="Star Annihilation",  expMult=1.00, dmgMult=1.65, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=10, name="Calamity God",       expMult=1.00, dmgMult=2.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
		},
	},
	{
		id="water_spirit", name="Water Spirit Sect", icon="💧", reqRealm=2, maxLevel=10,
		desc="Tank & healing sect. Survives anything.",
		milestones = {
			{ level=1,  name="Water Blessing",   expMult=1.00, dmgMult=1.00, defMult=1.00, hpMult=1.10, breakthroughBonus=0.00 },
			{ level=3,  name="Spirit Flow",      expMult=1.00, dmgMult=1.00, defMult=1.00, hpMult=1.20, breakthroughBonus=0.00 },
			{ level=5,  name="Ocean's Heart",    expMult=1.00, dmgMult=1.00, defMult=1.15, hpMult=1.35, breakthroughBonus=0.00 },
			{ level=8,  name="Tidal Domain",     expMult=1.00, dmgMult=1.00, defMult=1.25, hpMult=1.50, breakthroughBonus=0.00 },
			{ level=10, name="Immortal Waters",  expMult=1.00, dmgMult=1.00, defMult=1.40, hpMult=1.80, breakthroughBonus=0.00 },
		},
	},
	{
		id="lone_star", name="Lone Star Sect", icon="⭐", reqRealm=1, maxLevel=10,
		desc="Solo-player sect. Maximum EXP gain when alone.",
		milestones = {
			{ level=1,  name="Lone Path",        expMult=1.20, dmgMult=1.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=3,  name="Solitary Star",    expMult=1.40, dmgMult=1.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.00 },
			{ level=5,  name="Star Isolation",   expMult=1.60, dmgMult=1.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.10 },
			{ level=8,  name="Lone Ascension",   expMult=2.20, dmgMult=1.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.20 },
			{ level=10, name="Eternal Lone Star",expMult=3.00, dmgMult=1.00, defMult=1.00, hpMult=1.00, breakthroughBonus=0.35 },
		},
	},
}

local _byId: {[string]: Sect} = {}
for _, s in ipairs(SectData.SECTS) do _byId[s.id] = s end

function SectData.Get(id: string): Sect?
	return _byId[id]
end

-- EXP needed to advance FROM the given level (level × 1000).
function SectData.ExpForLevel(level: number): number
	return level * 1000
end

-- Returns the cumulative buff active at the given sect level (highest milestone reached).
function SectData.BuffAtLevel(sect: Sect, level: number): SectBuff?
	local active: SectBuff? = nil
	for _, m in ipairs(sect.milestones) do
		if level >= m.level then active = m end
	end
	return active
end

return SectData
