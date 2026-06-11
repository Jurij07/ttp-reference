--!strict
-- EnhancementData.lua
-- Three permanent upgrade trees purchasable with spirit stones.
-- They feed directly into IdleService: faster EXP, more stones/s, quicker hunts.

local EnhancementData = {}

export type Upgrade = {
	id: string, name: string, icon: string, desc: string,
	maxLevel: number, baseCost: number, costMult: number,
	expBonus: number?,    -- additive multiplier per level  (0.20 = +20%)
	stoneBonus: number?,  -- additive multiplier per level
	huntBonus: number?,   -- fraction of tick shaved per level (0.10 = −10%)
}

EnhancementData.UPGRADES: { Upgrade } = {
	{
		id = "spirit_cave", name = "Spirit Cave", icon = "☯️",
		desc = "Deepen your cultivation grotto. +25% passive EXP rate per level.",
		maxLevel = 12, baseCost = 500, costMult = 1.85,
		expBonus = 0.25,
	},
	{
		id = "stone_vein", name = "Stone Vein", icon = "💎",
		desc = "Tap a richer spirit-stone vein. +25% passive stone income per level.",
		maxLevel = 12, baseCost = 400, costMult = 1.80,
		stoneBonus = 0.25,
	},
	{
		id = "swift_hunt", name = "Swift Hunt", icon = "🏹",
		desc = "Sharpen your techniques. Auto-Hunt fires 10% faster per level (min 2 s).",
		maxLevel = 8, baseCost = 900, costMult = 2.20,
		huntBonus = 0.10,
	},
}

function EnhancementData.Get(id: string): Upgrade?
	for _, u in ipairs(EnhancementData.UPGRADES) do
		if u.id == id then return u end
	end
	return nil
end

-- Spirit-stone cost to reach the next level.
function EnhancementData.NextCost(upg: Upgrade, currentLevel: number): number
	return math.floor(upg.baseCost * (upg.costMult ^ currentLevel))
end

-- Accumulated multiplier for EXP or stones at the given level (e.g. level 4 with
-- bonus 0.25 → 1 + 4*0.25 = 2.0×).
function EnhancementData.Mult(upg: Upgrade, level: number): number
	local bonus = upg.expBonus or upg.stoneBonus or 0
	return 1 + level * bonus
end

-- Hunt tick in seconds at the given upgrade level (base 5 s → min 2 s).
function EnhancementData.HuntTick(level: number): number
	local base = 5
	local huntUpg = EnhancementData.Get("swift_hunt")
	local huntBonus = huntUpg and huntUpg.huntBonus or 0
	return math.max(base * ((1 - huntBonus) ^ level), 2)
end

return EnhancementData
