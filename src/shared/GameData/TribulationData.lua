--!strict
-- TribulationData.lua (from index.html — Heaven Tribulation R3-R9)
-- Auto-triggered at realm breakthrough from R3 onward. Karma multiplier
-- affects damage: Karma ≤ -800 → ×2 damage, Karma ≥ +800 → ×0.5 damage.
-- Resist = -40% damage; Counter = full damage but cooler animation.

local TribulationData = {}

export type Tribulation = {
	fromRealm: number,
	toRealm: number,
	name: string,
	waves: number,
	dmgPerWaveBase: number,    -- fraction of max HP, neutral karma
	dmgPerWaveHighKarma: number, -- karma >= +800 (×0.5)
	dmgPerWaveLowKarma: number,  -- karma <= -800 (×2)
	rewardExp: number,
	rewardStones: number,
}

TribulationData.TRIBULATIONS = {
	{ fromRealm=3, toRealm=4, name="Minor Heaven Tribulation", waves=3,  dmgPerWaveBase=0.20, dmgPerWaveLowKarma=0.40, dmgPerWaveHighKarma=0.10, rewardExp=5000,     rewardStones=500 },
	{ fromRealm=4, toRealm=5, name="Earth Tribulation",        waves=5,  dmgPerWaveBase=0.25, dmgPerWaveLowKarma=0.50, dmgPerWaveHighKarma=0.12, rewardExp=15000,    rewardStones=1500 },
	{ fromRealm=5, toRealm=6, name="Sky Thunder Tribulation",  waves=7,  dmgPerWaveBase=0.30, dmgPerWaveLowKarma=0.60, dmgPerWaveHighKarma=0.15, rewardExp=50000,    rewardStones=5000 },
	{ fromRealm=6, toRealm=7, name="Nine Thunder Tribulation", waves=9,  dmgPerWaveBase=0.35, dmgPerWaveLowKarma=0.70, dmgPerWaveHighKarma=0.18, rewardExp=150000,   rewardStones=15000 },
	{ fromRealm=7, toRealm=8, name="Immortal Tribulation",     waves=9,  dmgPerWaveBase=0.40, dmgPerWaveLowKarma=0.80, dmgPerWaveHighKarma=0.20, rewardExp=500000,   rewardStones=50000 },
	{ fromRealm=8, toRealm=9, name="Great Dao Tribulation",    waves=9,  dmgPerWaveBase=0.45, dmgPerWaveLowKarma=0.90, dmgPerWaveHighKarma=0.22, rewardExp=2000000,  rewardStones=200000 },
	{ fromRealm=9, toRealm=9, name="Heaven's Final Wrath",     waves=12, dmgPerWaveBase=0.50, dmgPerWaveLowKarma=1.00, dmgPerWaveHighKarma=0.25, rewardExp=10000000, rewardStones=999999 },
}

local _byFrom: {[number]: Tribulation} = {}
for _, t in ipairs(TribulationData.TRIBULATIONS) do _byFrom[t.fromRealm] = t end

-- Returns the tribulation that gates breakthrough FROM the given realm.
function TribulationData.GetForRealm(fromRealm: number): Tribulation?
	return _byFrom[fromRealm]
end

-- Damage per wave as fraction of max HP, given karma.
function TribulationData.DamageFraction(trib: Tribulation, karma: number): number
	if karma <= -800 then return trib.dmgPerWaveLowKarma end
	if karma >= 800 then return trib.dmgPerWaveHighKarma end
	return trib.dmgPerWaveBase
end

return TribulationData
