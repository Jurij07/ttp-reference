--!strict
-- DungeonData.lua (from index.html — 5 Dungeon instances)
-- A dungeon run grants boosted EXP/Stones per cleared floor. A boss appears on
-- every 5th kill. Cooldown starts on exit. Loot scales with floor depth.

local DungeonData = {}

export type Dungeon = {
	id: string,
	icon: string,
	name: string,
	reqRealm: number,
	floors: number,
	cooldownSec: number,
	expMult: number,
	stoneMult: number,
	rareChance: number,
	desc: string,
	loot: { string },
}

DungeonData.DUNGEONS = {
	{ id="cave_of_qi",       icon="🌿", name="Cave of Qi",            reqRealm=1, floors=3, cooldownSec=3600,  expMult=1.5, stoneMult=1.5, rareChance=0.15,
	  desc="A Qi-dense cave. Ideal for fresh cultivators.",
	  loot={"Spirit Herb","Beast Core","EXP Fragment","Healing Pill","Breakthrough Charm"} },
	{ id="iron_fortress",    icon="🪨", name="Iron Fortress",         reqRealm=2, floors=5, cooldownSec=7200,  expMult=2.0, stoneMult=2.0, rareChance=0.20,
	  desc="An ancient fortress. Iron-type beasts.",
	  loot={"Iron Essence","Spirit Iron","Dao Crystal","Foundation Pill"} },
	{ id="golden_pagoda",    icon="🏯", name="Golden Core Pagoda",    reqRealm=3, floors=9, cooldownSec=14400, expMult=2.5, stoneMult=2.5, rareChance=0.25,
	  desc="A 9-storey pagoda for Golden Core cultivators.",
	  loot={"Dao Crystal","Core Pill","Thunder Herb","Formation Stone"} },
	{ id="nascent_labyrinth",icon="🌀", name="Nascent Soul Labyrinth",reqRealm=4, floors=9, cooldownSec=28800, expMult=3.0, stoneMult=3.0, rareChance=0.30,
	  desc="A magical labyrinth full of soul energy.",
	  loot={"Void Crystal","Heaven Crystal","Soul Pill","Dragon Scale"} },
	{ id="void_abyss",       icon="🌑", name="Void Abyss",            reqRealm=5, floors=9, cooldownSec=86400, expMult=4.0, stoneMult=4.0, rareChance=0.40,
	  desc="A rift in space. Extremely dangerous.",
	  loot={"Chaos Ore","Immortal Silk","Boss Essence","Void Pill","Divine Core"} },
}

local _byId: {[string]: Dungeon} = {}
for _, d in ipairs(DungeonData.DUNGEONS) do _byId[d.id] = d end

function DungeonData.Get(id: string): Dungeon?
	return _byId[id]
end

return DungeonData
