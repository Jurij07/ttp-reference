--!strict
-- TechniqueMasteryData.lua
-- Structured gameplay effects for every TechniqueCatalog entry so all 59
-- techniques are learnable. Passive bonuses are additive fractions applied
-- in CultivationService (hp/dmg/def multiply combat stats, exp multiplies
-- EXP gains, stones multiplies stone gains). Actives carry a dmgMult (and
-- optional healFrac) used by TechniqueService when the technique is equipped
-- on [Q]. Values follow each entry's catalog description, tamed where a
-- literal reading would break idle balance.

local TechniqueMasteryData = {}

export type Effect = {
	hp: number?, dmg: number?, def: number?,
	exp: number?, stones: number?,
	dmgMult: number?, healFrac: number?,   -- present → equippable active
	learnCost: number?,                    -- spirit stones (overrides realm default)
}

TechniqueMasteryData.EFFECTS = {
	-- ── Realm 1 ──────────────────────────────────────────────
	basic_qi_refinement_art = { exp = 0.10, learnCost = 100 },
	basic_strike            = { dmgMult = 1.2 },
	qi_guard                = { def = 0.10 },
	iron_fist               = { dmgMult = 1.4, learnCost = 150 },
	wind_step               = { exp = 0.05, learnCost = 150 },
	qi_healing              = { dmgMult = 1.0, healFrac = 0.20, learnCost = 200 },
	flame_palm              = { dmgMult = 1.6, learnCost = 250 },
	stone_skin              = { def = 0.25, hp = 0.10, learnCost = 300 },
	thunder_fist            = { dmgMult = 1.8, learnCost = 300 },
	water_mirror_technique  = { exp = 0.15, learnCost = 280 },
	qi_storage_method       = { exp = 0.08, learnCost = 120 },
	forest_qi_step          = { exp = 0.05, learnCost = 100 },
	body_tribulation_art    = { hp = 0.60, learnCost = 500 },
	five_elements_formation = { def = 0.10, learnCost = 400 },
	sword_array_formation   = { dmg = 0.10, learnCost = 400 },
	heavenly_dao_formation  = { hp = 0.10, dmg = 0.10, def = 0.10, learnCost = 1500 },
	-- ── Realm 2 ──────────────────────────────────────────────
	sword_qi                  = { dmgMult = 1.8, learnCost = 600 },
	foundation_crushing_fist  = { dmgMult = 2.0, learnCost = 700 },
	cloud_step                = { exp = 0.08, learnCost = 600 },
	iron_body_art             = { def = 0.35, learnCost = 800 },
	spirit_restoration        = { dmgMult = 1.0, healFrac = 0.35, learnCost = 900 },
	dao_heart_technique       = { exp = 0.30, learnCost = 1200 },
	flame_dao_burst           = { dmgMult = 2.5, learnCost = 1200 },
	lightning_domain          = { dmgMult = 2.0, learnCost = 1400 },
	shadow_step               = { exp = 0.08, learnCost = 900 },
	water_spirit_healing_art  = { dmgMult = 1.0, healFrac = 0.60, learnCost = 1100 },
	earth_wood_harmony        = { hp = 0.30, exp = 0.25, learnCost = 1300 },
	bloodline_awakening       = { hp = 0.08, dmg = 0.08, def = 0.08, learnCost = 600 },
	meridian_expansion_art    = { exp = 0.10, learnCost = 1200 },
	ancient_ruin_sensing      = { stones = 0.30, learnCost = 400 },
	-- ── Realm 3 ──────────────────────────────────────────────
	golden_core_art      = { hp = 0.20, dmg = 0.20, def = 0.20, learnCost = 5000 },
	sword_domain         = { dmgMult = 2.2, learnCost = 4000 },
	void_flash           = { exp = 0.10, learnCost = 3500 },
	lone_star_fate       = { dmg = 0.15, learnCost = 15000 },
	calamity_star_pulse  = { dmgMult = 2.2, learnCost = 3000 },
	will_hardening       = { exp = 0.20, learnCost = 4000 },
	-- ── Realm 4 ──────────────────────────────────────────────
	nascent_flame        = { dmgMult = 4.0, learnCost = 20000 },
	soul_brand           = { dmgMult = 3.0, learnCost = 18000 },
	heaven_sealing_art   = { dmgMult = 1.5, learnCost = 15000 },
	soul_formation_fist  = { dmgMult = 3.5, learnCost = 18000 },
	heaven_defying_will  = { exp = 0.15, learnCost = 15000 },
	sea_qi_breathing     = { hp = 0.10, learnCost = 2000 },
	-- ── Realm 5 ──────────────────────────────────────────────
	soul_formation_mastery     = { exp = 0.50, hp = 0.30, dmg = 0.30, def = 0.30, learnCost = 50000 },
	void_shatter_palm          = { dmgMult = 6.0, learnCost = 60000 },
	void_rupture               = { dmgMult = 4.0, learnCost = 45000 },
	space_lock                 = { dmgMult = 1.5, learnCost = 35000 },
	six_paths_divine_body_art  = { hp = 1.00, def = 0.60, learnCost = 80000 },
	void_stabilization         = { dmg = 0.10, learnCost = 8000 },
	-- ── Realm 6 ──────────────────────────────────────────────
	ten_thousand_swords_formation = { dmgMult = 8.0, learnCost = 400000 },
	body_rebirth_art              = { hp = 0.30, learnCost = 40000 },
	perfect_dao_heart             = { exp = 0.60, learnCost = 100000 },
	-- ── Realm 7 ──────────────────────────────────────────────
	tribulation_armor   = { def = 0.80, learnCost = 300000 },
	immortal_gate_ward  = { def = 0.40, learnCost = 50000 },
	-- ── Realm 8 ──────────────────────────────────────────────
	creation_will_fragment = { dmgMult = 5.0, healFrac = 0.50, learnCost = 2000000 },
	immortal_eye           = { exp = 0.40, learnCost = 200000 },
	-- ── Realm 9 ──────────────────────────────────────────────
	chaos_dao_manifestation  = { dmgMult = 10.0, learnCost = 8000000 },
	mahayana_breaking_palm   = { dmgMult = 7.0, learnCost = 5000000 },
	world_law_comprehension  = { dmg = 0.50, exp = 0.25, learnCost = 2000000 },
	reincarnation_technique  = { hp = 0.30, learnCost = 5000000 },
} :: { [string]: Effect }

-- Spirit-stone learn cost by the technique's realm if no explicit override.
local DEFAULT_COST: { [number]: number } = {
	[1] = 200, [2] = 1000, [3] = 5000, [4] = 20000, [5] = 60000,
	[6] = 300000, [7] = 1000000, [8] = 3000000, [9] = 8000000,
}

function TechniqueMasteryData.Get(id: string): Effect?
	return TechniqueMasteryData.EFFECTS[id]
end

function TechniqueMasteryData.LearnCost(id: string, realm: number): number
	local e = TechniqueMasteryData.EFFECTS[id]
	if e and e.learnCost then return e.learnCost end
	return DEFAULT_COST[math.clamp(realm, 1, 9)] or 200
end

-- Equippable on [Q]?
function TechniqueMasteryData.IsActive(id: string): boolean
	local e = TechniqueMasteryData.EFFECTS[id]
	return e ~= nil and e.dmgMult ~= nil
end

return TechniqueMasteryData
