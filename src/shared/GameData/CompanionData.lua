--!strict
-- CompanionData.lua (from index.html — 8 Spirit Companions)
-- Bond level rises by feeding (1000 bond-EXP = +1 level, max 10). Bond-EXP
-- comes from combat (10% of your EXP). Stat bonuses scale linearly from the
-- base value (level 1) to the level-10 value.

local CompanionData = {}

export type Companion = {
	id: string,
	icon: string,
	name: string,
	rarity: string,
	cost: number,
	desc: string,
	-- percentage bonuses at level 1 / level 10 (0 = none)
	baseDmg: number, maxDmg: number,
	baseDef: number, maxDef: number,
	baseHp: number,  maxHp: number,
	baseExp: number, maxExp: number,
	maxLifespan: number,   -- flat lifespan at level 10 (interpolated)
}

CompanionData.COMPANIONS = {
	{ id="spirit_rabbit", icon="🐰", name="Spirit Rabbit", rarity="Common",    cost=3000,
	  desc="A quick beast that distracts foes. (+dodge)",
	  baseDmg=0,  maxDmg=0,  baseDef=0,  maxDef=0,  baseHp=0,  maxHp=0,  baseExp=5,  maxExp=22, maxLifespan=0 },
	{ id="spirit_wolf",   icon="🐺", name="Spirit Wolf",   rarity="Uncommon",  cost=5000,
	  desc="A loyal wolf that fights alongside you.",
	  baseDmg=10, maxDmg=35, baseDef=0,  maxDef=0,  baseHp=0,  maxHp=0,  baseExp=0,  maxExp=0,  maxLifespan=0 },
	{ id="fire_fox",      icon="🦊", name="Fire Fox",      rarity="Rare",      cost=12000,
	  desc="A cunning fox that burns enemies.",
	  baseDmg=8,  maxDmg=30, baseDef=0,  maxDef=0,  baseHp=0,  maxHp=0,  baseExp=0,  maxExp=20, maxLifespan=0 },
	{ id="thunder_hawk",  icon="🦅", name="Thunder Hawk",  rarity="Epic",      cost=25000,
	  desc="A hawk with lightning wings. (+stun)",
	  baseDmg=12, maxDmg=40, baseDef=0,  maxDef=0,  baseHp=0,  maxHp=0,  baseExp=0,  maxExp=0,  maxLifespan=0 },
	{ id="jade_turtle",   icon="🐢", name="Jade Turtle",   rarity="Rare",      cost=20000,
	  desc="An ancient turtle that shields you.",
	  baseDmg=0,  maxDmg=0,  baseDef=15, maxDef=50, baseHp=10, maxHp=45, baseExp=0,  maxExp=0,  maxLifespan=0 },
	{ id="void_panther",  icon="🐆", name="Void Panther",  rarity="Legendary", cost=80000,
	  desc="A panther that leaps through the Void. (+pen)",
	  baseDmg=15, maxDmg=45, baseDef=0,  maxDef=0,  baseHp=0,  maxHp=0,  baseExp=0,  maxExp=0,  maxLifespan=0 },
	{ id="golden_dragon", icon="🐉", name="Golden Dragon", rarity="Mythic",    cost=500000,
	  desc="A young golden dragon — power incarnate.",
	  baseDmg=20, maxDmg=60, baseDef=20, maxDef=60, baseHp=20, maxHp=60, baseExp=20, maxExp=60, maxLifespan=2000 },
	{ id="phoenix_chick", icon="🐦", name="Phoenix Chick", rarity="Divine",    cost=150000,
	  desc="A baby phoenix that revives you once.",
	  baseDmg=0,  maxDmg=0,  baseDef=0,  maxDef=0,  baseHp=15, maxHp=55, baseExp=15, maxExp=50, maxLifespan=3000 },
}

local _byId: {[string]: Companion} = {}
for _, c in ipairs(CompanionData.COMPANIONS) do _byId[c.id] = c end

function CompanionData.Get(id: string): Companion?
	return _byId[id]
end

function CompanionData.BondExpForLevel(level: number): number
	return 1000  -- flat 1000 per level
end

-- Linearly interpolated bonus at the given bond level (1..10).
local function lerp(base: number, max: number, level: number): number
	local t = math.clamp((level - 1) / 9, 0, 1)
	return base + (max - base) * t
end

function CompanionData.BonusAt(c: Companion, level: number): { dmg: number, def: number, hp: number, exp: number, lifespan: number }
	return {
		dmg = 1 + lerp(c.baseDmg, c.maxDmg, level) / 100,
		def = 1 + lerp(c.baseDef, c.maxDef, level) / 100,
		hp  = 1 + lerp(c.baseHp,  c.maxHp,  level) / 100,
		exp = 1 + lerp(c.baseExp, c.maxExp, level) / 100,
		lifespan = c.maxLifespan * math.clamp((level - 1) / 9, 0, 1),
	}
end

return CompanionData
