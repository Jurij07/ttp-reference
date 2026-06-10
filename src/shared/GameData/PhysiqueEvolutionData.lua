--!strict
-- PhysiqueEvolutionData.lua (from index.html — 4 evolution stages)
-- Checked automatically at realm break. Requires both a minimum Realm AND
-- enough total accumulated EXP. Each physique has its own evolution path.

local PhysiqueEvolutionData = {}

export type EvoStage = {
	stage: number,
	reqRealm: number,
	reqTotalExp: number,
	statMult: number,        -- "all stats" multiplier (1.0 = none)
	dmgMult: number,         -- extra DMG-only multiplier
	hpMult: number,
	defMult: number,
	expMult: number,
	breakthroughBonus: number,
	bonusLifespan: number,
	label: string,
}

-- Maps a Physique name (from ProvidenceData) to its evolution path.
-- Physiques not listed fall back to "Default".
PhysiqueEvolutionData.PATHS = {
	["Heaven Sealing"] = {
		{ stage=1, reqRealm=1, reqTotalExp=0,       statMult=1.05, dmgMult=1.00, hpMult=1.00, defMult=1.00, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0,     label="+5% all stats" },
		{ stage=2, reqRealm=3, reqTotalExp=50000,   statMult=1.12, dmgMult=1.00, hpMult=1.00, defMult=1.00, expMult=1.10, breakthroughBonus=0.00, bonusLifespan=0,     label="+12% all, +10% EXP" },
		{ stage=3, reqRealm=6, reqTotalExp=500000,  statMult=1.25, dmgMult=1.00, hpMult=1.00, defMult=1.00, expMult=1.25, breakthroughBonus=0.10, bonusLifespan=0,     label="+25% all, +25% EXP, +10% breakthrough" },
		{ stage=4, reqRealm=9, reqTotalExp=5000000, statMult=1.50, dmgMult=1.00, hpMult=1.00, defMult=1.00, expMult=1.50, breakthroughBonus=0.25, bonusLifespan=10000, label="+50% all, +50% EXP, +25% breakthrough, +10K Lifespan" },
	},
	["Six Paths"] = {
		{ stage=1, reqRealm=1, reqTotalExp=0,       statMult=1.00, dmgMult=1.08, hpMult=1.08, defMult=1.08, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0, label="+8% all combat" },
		{ stage=2, reqRealm=4, reqTotalExp=100000,  statMult=1.00, dmgMult=1.18, hpMult=1.18, defMult=1.18, expMult=1.15, breakthroughBonus=0.00, bonusLifespan=0, label="+18% combat, +15% EXP" },
		{ stage=3, reqRealm=7, reqTotalExp=1000000, statMult=1.00, dmgMult=1.35, hpMult=1.35, defMult=1.35, expMult=1.30, breakthroughBonus=0.00, bonusLifespan=0, label="+35% combat, +30% EXP, ×1.5 Dao Insights" },
		{ stage=4, reqRealm=9, reqTotalExp=9000000, statMult=1.20, dmgMult=1.60, hpMult=1.60, defMult=1.60, expMult=1.60, breakthroughBonus=0.00, bonusLifespan=0, label="+60% combat, +60% EXP, +20% all stats" },
	},
	["Calamity Star"] = {
		{ stage=1, reqRealm=1, reqTotalExp=0,       statMult=1.00, dmgMult=1.10, hpMult=1.00, defMult=1.00, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0, label="+10% DMG" },
		{ stage=2, reqRealm=3, reqTotalExp=60000,   statMult=1.00, dmgMult=1.22, hpMult=1.00, defMult=1.00, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0, label="+22% DMG, +5% crit" },
		{ stage=3, reqRealm=6, reqTotalExp=600000,  statMult=1.00, dmgMult=1.40, hpMult=1.00, defMult=1.00, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0, label="+40% DMG, +12% crit, +10% stun" },
		{ stage=4, reqRealm=9, reqTotalExp=6000000, statMult=1.00, dmgMult=1.70, hpMult=1.00, defMult=1.00, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0, label="+70% DMG, +25% crit, ×2 crit dmg" },
	},
	["Default"] = {
		{ stage=1, reqRealm=1, reqTotalExp=0,       statMult=1.00, dmgMult=1.00, hpMult=1.00, defMult=1.00, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0,    label="Base stats" },
		{ stage=2, reqRealm=3, reqTotalExp=50000,   statMult=1.00, dmgMult=1.00, hpMult=1.10, defMult=1.08, expMult=1.00, breakthroughBonus=0.00, bonusLifespan=0,    label="+10% HP, +8% DEF" },
		{ stage=3, reqRealm=6, reqTotalExp=500000,  statMult=1.00, dmgMult=1.00, hpMult=1.25, defMult=1.18, expMult=1.10, breakthroughBonus=0.00, bonusLifespan=0,    label="+25% HP, +18% DEF, +10% EXP" },
		{ stage=4, reqRealm=9, reqTotalExp=5000000, statMult=1.00, dmgMult=1.00, hpMult=1.50, defMult=1.35, expMult=1.25, breakthroughBonus=0.00, bonusLifespan=5000, label="+50% HP, +35% DEF, +25% EXP, +5K Lifespan" },
	},
}

-- Returns the evolution path for a physique name, or the Default path.
function PhysiqueEvolutionData.GetPath(physiqueName: string?): { EvoStage }
	if physiqueName and PhysiqueEvolutionData.PATHS[physiqueName] then
		return PhysiqueEvolutionData.PATHS[physiqueName]
	end
	return PhysiqueEvolutionData.PATHS["Default"]
end

-- Highest stage the player qualifies for given realm + total EXP.
function PhysiqueEvolutionData.ResolveStage(physiqueName: string?, realm: number, totalExp: number): EvoStage
	local path = PhysiqueEvolutionData.GetPath(physiqueName)
	local best = path[1]
	for _, s in ipairs(path) do
		if realm >= s.reqRealm and totalExp >= s.reqTotalExp then
			best = s
		end
	end
	return best
end

return PhysiqueEvolutionData
