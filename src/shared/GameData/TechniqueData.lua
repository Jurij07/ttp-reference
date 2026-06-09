--!strict
-- TechniqueData.lua
-- Active combat techniques (Q-key). One per Dao affinity + generics.
-- dmgMult: multiplier on base ATK; cooldown in seconds; healFrac: fraction of damage healed.

local TechniqueData = {}

export type Technique = {
	id: string,
	name: string,
	dao: string?,
	dmgMult: number,
	cooldown: number,
	healFrac: number?,
	desc: string,
}

TechniqueData.TECHNIQUES = {
	{ id = "basic_strike",      name = "Basic Strike",         dao = nil,       dmgMult = 1.2, cooldown = 3,  desc = "A simple strike using condensed Qi." },
	{ id = "sword_strike",      name = "Sword Qi Slash",       dao = "Sword",   dmgMult = 3.0, cooldown = 6,  desc = "A razor-sharp Sword Qi slash." },
	{ id = "fire_burst",        name = "Flame Eruption",       dao = "Fire",    dmgMult = 2.5, cooldown = 7,  desc = "Erupt with scorching flame Qi." },
	{ id = "void_strike",       name = "Void Collapse",        dao = "Void",    dmgMult = 2.8, cooldown = 8,  desc = "Collapse space around the target." },
	{ id = "life_drain",        name = "Life Absorption",      dao = "Life",    dmgMult = 1.6, cooldown = 8,  healFrac = 0.35, desc = "Drain life from the target." },
	{ id = "thunder_strike",    name = "Heaven's Wrath",       dao = "Thunder", dmgMult = 2.6, cooldown = 5,  desc = "Call down a bolt of heaven lightning." },
	{ id = "ice_shard",         name = "Glacial Spear",        dao = "Ice",     dmgMult = 2.2, cooldown = 6,  desc = "Launch a piercing shard of glacial Qi." },
	{ id = "earth_crash",       name = "Mountain Crash",       dao = "Earth",   dmgMult = 2.4, cooldown = 9,  desc = "Bring the weight of a mountain down." },
	{ id = "space_rend",        name = "Dimensional Rend",     dao = "Space",   dmgMult = 3.2, cooldown = 10, desc = "Tear open a dimensional rift." },
} :: { Technique }

local _byId: {[string]: Technique} = {}
for _, t in ipairs(TechniqueData.TECHNIQUES) do _byId[t.id] = t end

local _byDao: {[string]: Technique} = {}
for _, t in ipairs(TechniqueData.TECHNIQUES) do
	if t.dao then _byDao[t.dao] = t end
end

function TechniqueData.Get(id: string): Technique?
	return _byId[id]
end

function TechniqueData.GetForDao(dao: string): Technique?
	return _byDao[dao] or _byId["basic_strike"]
end

return TechniqueData
