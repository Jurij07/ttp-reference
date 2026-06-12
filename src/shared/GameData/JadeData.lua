--!strict
-- JadeData.lua
-- Immortal Jade 💎 — the prestige currency. Earned through tribulations,
-- first boss kills, breakthroughs beyond Mahayana and daily missions.
-- Spent in the Jade Bazaar on permanent account upgrades and consumables.

local JadeData = {}

export type JadeItem = {
	id: string, name: string, icon: string,
	kind: string,              -- "permanent" (levelled) | "consumable"
	desc: string,
	-- permanent upgrades
	maxLevel: number?, baseCost: number?, costMult: number?,
	expBonus: number?,         -- additive EXP multiplier per level
	stoneBonus: number?,       -- additive stone multiplier per level
	-- consumables
	cost: number?,
}

JadeData.ITEMS = {
	{
		id = "fortune_charm", name = "Fortune Charm", icon = "🍀", kind = "permanent",
		desc = "Providence smiles on you. +10% to ALL EXP gains per level — passive, hunts, quests, everything.",
		maxLevel = 5, baseCost = 50, costMult = 2.0, expBonus = 0.10,
	},
	{
		id = "stone_magnet", name = "Stone Magnet", icon = "🧲", kind = "permanent",
		desc = "Spirit stones roll toward you of their own accord. +10% to ALL stone gains per level.",
		maxLevel = 5, baseCost = 40, costMult = 2.0, stoneBonus = 0.10,
	},
	{
		id = "time_talisman", name = "Time Talisman", icon = "⏳", kind = "consumable",
		desc = "Fold two hours of cultivation into a single breath. Instantly grants 2h of idle EXP and stones.",
		cost = 30,
	},
	{
		id = "tribulation_ward", name = "Tribulation Ward", icon = "🛡️", kind = "consumable",
		desc = "A single-use ward inscribed against heavenly lightning. Your next tribulation deals 50% less damage.",
		cost = 25,
	},
} :: { JadeItem }

function JadeData.Get(id: string): JadeItem?
	for _, it in ipairs(JadeData.ITEMS) do
		if it.id == id then return it end
	end
	return nil
end

-- Jade cost for the next level of a permanent upgrade.
function JadeData.NextCost(item: JadeItem, currentLevel: number): number
	return math.floor((item.baseCost or 0) * ((item.costMult or 2) ^ currentLevel))
end

-- ── Earning rules (read by the services that grant jade) ─────
JadeData.TRIBULATION_JADE_PER_REALM = 5    -- survive tribulation from realm R → R*5
JadeData.BOSS_FIRSTKILL_JADE_PER_REALM = 10 -- first kill of realm-R boss → R*10
JadeData.BREAKTHROUGH_JADE_PER_REALM = 20  -- realm-up at R10+ → R*20
JadeData.DAILY_CLAIM_JADE = 5              -- each claimed daily mission

return JadeData
