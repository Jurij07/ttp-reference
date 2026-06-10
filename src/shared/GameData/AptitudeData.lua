--!strict
-- AptitudeData.lua
-- Aptitude grades shape your cultivation. Higher talent = faster growth but
-- a more fragile body and shorter lifespan (the heavens envy genius).
-- Every grade has clear PROS and CONS — nothing is strictly better.

local AptitudeData = {}

export type Grade = {
	name: string,
	mult: number,        -- EXP multiplier (alias kept for UI compatibility)
	expMult: number,
	hpMult: number,
	dmgMult: number,
	defMult: number,
	lifespanMult: number,
	chance: number,      -- roll probability in percent
	rarity: string,      -- UI colour
	pros: string,
	cons: string,
	desc: string,
}

-- Order = ascending rarity. chance sums to 100.
AptitudeData.GRADES = {
	{
		name = "Mortal", chance = 20.0, rarity = "Common",
		expMult = 0.8, hpMult = 1.20, dmgMult = 0.90, defMult = 1.15, lifespanMult = 1.25,
		pros = "HP +20% · DEF +15% · Lifespan +25%",
		cons = "EXP −20% · DMG −10%",
		desc = "A sturdy, long-lived body but slow to cultivate. The tortoise's path.",
	},
	{
		name = "Average", chance = 35.0, rarity = "Common",
		expMult = 1.0, hpMult = 1.0, dmgMult = 1.0, defMult = 1.0, lifespanMult = 1.0,
		pros = "Perfectly balanced — no weakness",
		cons = "No special strength",
		desc = "Standard talent. A blank slate shaped entirely by effort.",
	},
	{
		name = "Good", chance = 20.0, rarity = "Uncommon",
		expMult = 1.2, hpMult = 1.05, dmgMult = 1.05, defMult = 1.0, lifespanMult = 0.98,
		pros = "EXP +20% · HP/DMG +5%",
		cons = "Lifespan −2%",
		desc = "Above-average talent. Peers begin to take notice.",
	},
	{
		name = "Excellent", chance = 12.0, rarity = "Rare",
		expMult = 1.4, hpMult = 1.0, dmgMult = 1.12, defMult = 1.0, lifespanMult = 0.95,
		pros = "EXP +40% · DMG +12%",
		cons = "Lifespan −5% · no HP bonus",
		desc = "Rare natural talent. A rising star of the sect.",
	},
	{
		name = "Outstanding", chance = 7.0, rarity = "Epic",
		expMult = 1.6, hpMult = 0.95, dmgMult = 1.18, defMult = 1.1, lifespanMult = 0.92,
		pros = "EXP +60% · DMG +18% · DEF +10%",
		cons = "HP −5% · Lifespan −8%",
		desc = "One in a thousand. The heavens watch you closely.",
	},
	{
		name = "Peerless", chance = 4.0, rarity = "Legendary",
		expMult = 1.9, hpMult = 0.90, dmgMult = 1.25, defMult = 1.0, lifespanMult = 0.88,
		pros = "EXP +90% · DMG +25%",
		cons = "HP −10% · Lifespan −12%",
		desc = "One in ten thousand — a genius of the age, burning bright.",
	},
	{
		name = "Supreme", chance = 1.5, rarity = "Mythic",
		expMult = 2.2, hpMult = 0.88, dmgMult = 1.30, defMult = 1.05, lifespanMult = 0.84,
		pros = "EXP ×2.2 · DMG +30% · DEF +5%",
		cons = "HP −12% · Lifespan −16%",
		desc = "Once in an era. Legends are written about such talent.",
	},
	{
		name = "Immortal", chance = 0.4, rarity = "Divine",
		expMult = 2.6, hpMult = 0.85, dmgMult = 1.38, defMult = 1.0, lifespanMult = 0.78,
		pros = "EXP ×2.6 · DMG +38%",
		cons = "HP −15% · Lifespan −22% (the heavens fear you)",
		desc = "Heaven-defying aptitude — and the heavens push back hard.",
	},
	{
		name = "God", chance = 0.1, rarity = "Immortal",
		expMult = 3.0, hpMult = 0.82, dmgMult = 1.45, defMult = 1.1, lifespanMult = 0.70,
		pros = "EXP ×3.0 · DMG +45% · DEF +10%",
		cons = "HP −18% · Lifespan −30% (heaven envies you)",
		desc = "The Dao chose you personally — a candle that blazes and burns out fast.",
	},
} :: { Grade }

-- Keep `mult` as an alias of expMult so existing UI code keeps working.
for _, g in ipairs(AptitudeData.GRADES) do
	(g :: any).mult = g.expMult
end

function AptitudeData.GetByName(name: string): Grade?
	for _, g in ipairs(AptitudeData.GRADES) do
		if g.name == name then return g end
	end
	return nil
end

function AptitudeData.Roll(): Grade
	local roll = math.random() * 100
	local cumulative = 0
	for _, g in ipairs(AptitudeData.GRADES) do
		cumulative += g.chance
		if roll <= cumulative then return g end
	end
	return AptitudeData.GRADES[2]
end

return AptitudeData
