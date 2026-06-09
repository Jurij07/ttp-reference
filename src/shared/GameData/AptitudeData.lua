--!strict
-- AptitudeData.lua
-- Aptitude-Grade bestimmen den EXP-Multiplikator aus ALLEN Quellen.
-- Wird bei der Providence-Roll bestimmt. Werte aus der Spielreferenz.

local AptitudeData = {}

export type Grade = {
	name: string,
	mult: number,    -- EXP-Multiplikator
	chance: number,  -- Roll-Wahrscheinlichkeit in Prozent
	rarity: string,  -- für UI-Farbe
	desc: string,
}

-- Reihenfolge = aufsteigende Seltenheit. chance summiert sich auf 100.
AptitudeData.GRADES = {
	{ name = "Mortal",      mult = 0.5,  chance = 20.0, rarity = "Common",    desc = "Barely above ordinary folk. Very slow cultivation." },
	{ name = "Average",     mult = 1.0,  chance = 35.0, rarity = "Common",    desc = "Standard cultivation talent. Normal speed." },
	{ name = "Good",        mult = 1.3,  chance = 20.0, rarity = "Uncommon",  desc = "Above average. Noticeable talent." },
	{ name = "Excellent",   mult = 1.6,  chance = 12.0, rarity = "Rare",      desc = "Rare natural talent. Peers take notice." },
	{ name = "Outstanding", mult = 2.0,  chance = 7.0,  rarity = "Epic",      desc = "One in a thousand talent. Heaven-favored." },
	{ name = "Peerless",    mult = 2.8,  chance = 4.0,  rarity = "Legendary", desc = "One in ten thousand. A genius of the age." },
	{ name = "Supreme",     mult = 4.0,  chance = 1.5,  rarity = "Mythic",    desc = "Once in an era genius. Legends speak of such." },
	{ name = "Immortal",    mult = 6.0,  chance = 0.4,  rarity = "Divine",    desc = "Heaven-defying aptitude. The heavens fear you." },
	{ name = "God",         mult = 10.0, chance = 0.1,  rarity = "Immortal",  desc = "The Dao chose you personally. Unique in all history." },
} :: { Grade }

-- Findet einen Grade per Name.
function AptitudeData.GetByName(name: string): Grade?
	for _, g in ipairs(AptitudeData.GRADES) do
		if g.name == name then
			return g
		end
	end
	return nil
end

-- Würfelt einen Aptitude-Grade gewichtet nach seiner Chance.
function AptitudeData.Roll(): Grade
	local roll = math.random() * 100
	local cumulative = 0
	for _, g in ipairs(AptitudeData.GRADES) do
		cumulative += g.chance
		if roll <= cumulative then
			return g
		end
	end
	return AptitudeData.GRADES[2] -- Fallback: Average
end

return AptitudeData
