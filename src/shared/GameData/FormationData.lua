--!strict
-- FormationData.lua (from index.html — 10 Formations)
-- A formation grants passive stat multipliers while active. Only one formation
-- can be active at a time. Some are bought, some unlock via a sect.

local FormationData = {}

export type Formation = {
	id: string,
	icon: string,
	name: string,
	ftype: string,      -- "PASSIVE" | "ACTIVE"
	reqRealm: number,
	cost: number,       -- 0 = free / sect-unlock
	unlock: string,     -- "Standard" | "Buy" | sect id
	bonusText: string,
	dmgMult: number, defMult: number, hpMult: number, expMult: number,
}

FormationData.FORMATIONS = {
	{ id="five_elements",   icon="⭕", name="Five Elements Formation", ftype="PASSIVE", reqRealm=1, cost=0,      unlock="Standard",
	  bonusText="+8% all combat, +5% EXP",    dmgMult=1.08, defMult=1.08, hpMult=1.08, expMult=1.05 },
	{ id="sword_array",     icon="⚔️", name="Ten Thousand Sword Array", ftype="ACTIVE", reqRealm=2, cost=5000,   unlock="Buy",
	  bonusText="+40% DMG, +15% crit",         dmgMult=1.40, defMult=1.00, hpMult=1.00, expMult=1.00 },
	{ id="qi_convergence",  icon="🌀", name="Qi Convergence Circle",   ftype="PASSIVE", reqRealm=2, cost=3000,   unlock="Buy",
	  bonusText="+30% EXP, +20% Seclusion EXP", dmgMult=1.00, defMult=1.00, hpMult=1.00, expMult=1.30 },
	{ id="iron_fortress",   icon="🛡️", name="Iron Fortress Formation",  ftype="PASSIVE", reqRealm=3, cost=10000,  unlock="Buy",
	  bonusText="+35% DEF, +15% HP, +10% reflect", dmgMult=1.00, defMult=1.35, hpMult=1.15, expMult=1.00 },
	{ id="thunder_domain",  icon="⚡", name="Thunder Domain",          ftype="ACTIVE", reqRealm=4, cost=25000,  unlock="Buy",
	  bonusText="+35% stun, +25% DMG",         dmgMult=1.25, defMult=1.00, hpMult=1.00, expMult=1.00 },
	{ id="yin_yang",        icon="☯️", name="Yin-Yang Balance",         ftype="PASSIVE", reqRealm=3, cost=15000,  unlock="Buy",
	  bonusText="+12% all stats, +8% lifesteal", dmgMult=1.12, defMult=1.12, hpMult=1.12, expMult=1.12 },
	{ id="six_paths_domain",icon="✨", name="Six Paths Domain",         ftype="PASSIVE", reqRealm=6, cost=200000, unlock="six_paths",
	  bonusText="+25% all stats, +40% EXP",    dmgMult=1.25, defMult=1.25, hpMult=1.25, expMult=1.40 },
	{ id="heaven_earth",    icon="🌍", name="Heaven+Earth Sealing",     ftype="ACTIVE", reqRealm=7, cost=500000, unlock="Buy",
	  bonusText="+50% pen, +50% DMG",          dmgMult=1.50, defMult=1.00, hpMult=1.00, expMult=1.00 },
	{ id="calamity_array",  icon="💫", name="Calamity Star Array",      ftype="ACTIVE", reqRealm=5, cost=80000,  unlock="calamity_star",
	  bonusText="+60% DMG, +40% burn",         dmgMult=1.60, defMult=1.00, hpMult=1.00, expMult=1.00 },
	{ id="lone_star_form",  icon="⭐", name="Lone Star Formation",      ftype="PASSIVE", reqRealm=4, cost=30000,  unlock="lone_star",
	  bonusText="+20% all combat, +20% EXP",   dmgMult=1.20, defMult=1.20, hpMult=1.20, expMult=1.20 },
}

local _byId: {[string]: Formation} = {}
for _, f in ipairs(FormationData.FORMATIONS) do _byId[f.id] = f end

function FormationData.Get(id: string): Formation?
	return _byId[id]
end

return FormationData
