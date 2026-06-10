--!strict
-- ItemData.lua (generated from index.html)

local ItemData = {}

export type Effect = { kind: string, value: number?, mult: number?, duration: number? }
export type Item = {
	id: number, icon: string, name: string,
	rarity: string, itype: string,
	stack: number, cost: number?,
	slot: string?,    -- equipment paperdoll slot (weapon/head/body/legs/feet/hands/necklace/ring)
	desc: string, effects: {Effect},
}

ItemData.ITEMS = {
	{ id=1, icon="💊", name="Qi Fragment Pill", rarity="Common", itype="consumable", stack=99, cost=50, slot=nil, desc="Restores 15% HP. A basic alchemist's concoction.", effects={ { kind="heal_pct", value=15 } } },
	{ id=2, icon="💊", name="Minor Healing Pill", rarity="Common", itype="consumable", stack=99, cost=120, slot=nil, desc="Restores 30% HP.", effects={ { kind="heal_pct", value=30 } } },
	{ id=3, icon="💧", name="Qi Restoration Pill", rarity="Common", itype="consumable", stack=99, cost=80, slot=nil, desc="Restores 30% QI.", effects={ { kind="qi_pct", value=30 } } },
	{ id=4, icon="📗", name="Cultivation Fragment", rarity="Common", itype="consumable", stack=99, cost=200, slot=nil, desc="Grants 200 EXP.", effects={ { kind="exp_flat", value=200 } } },
	{ id=5, icon="📗", name="Minor Cultivation Pill", rarity="Common", itype="consumable", stack=99, cost=500, slot=nil, desc="Grants 500 EXP.", effects={ { kind="exp_flat", value=500 } } },
	{ id=6, icon="🍵", name="Spirit Tea", rarity="Common", itype="consumable", stack=99, cost=30, slot=nil, desc="Restores 10% QI. A cultivator's daily staple.", effects={ { kind="qi_pct", value=10 } } },
	{ id=7, icon="🍚", name="Spirit Rice Meal", rarity="Common", itype="consumable", stack=50, cost=80, slot=nil, desc="A nutritious meal. Restores 20% HP.", effects={ { kind="heal_pct", value=20 } } },
	{ id=8, icon="🧪", name="Universal Antidote", rarity="Uncommon", itype="consumable", stack=20, cost=800, slot=nil, desc="Removes all poison and debuff effects.", effects={} },
	{ id=9, icon="🧠", name="Focus Pill", rarity="Uncommon", itype="consumable", stack=20, cost=600, slot=nil, desc="Prevents stun for 2 turns.", effects={} },
	{ id=10, icon="🔥", name="Warm Qi Pill", rarity="Uncommon", itype="consumable", stack=20, cost=600, slot=nil, desc="Prevents freeze for 2 turns.", effects={} },
	{ id=11, icon="💚", name="Regeneration Pill", rarity="Uncommon", itype="consumable", stack=20, cost=1200, slot=nil, desc="Restores 8% HP per turn for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=12, icon="🔴", name="Healing Pill", rarity="Uncommon", itype="consumable", stack=50, cost=300, slot=nil, desc="Restores 60% HP. Standard alchemical grade.", effects={ { kind="heal_pct", value=60 } } },
	{ id=13, icon="💙", name="Greater Qi Pill", rarity="Uncommon", itype="consumable", stack=50, cost=250, slot=nil, desc="Restores 70% QI.", effects={ { kind="qi_pct", value=70 } } },
	{ id=14, icon="📘", name="Cultivation Pill", rarity="Uncommon", itype="consumable", stack=50, cost=1200, slot=nil, desc="Grants 2,000 EXP.", effects={ { kind="exp_flat", value=2000 } } },
	{ id=15, icon="🏳", name="Qi Gathering Flag", rarity="Uncommon", itype="consumable", stack=20, cost=800, slot=nil, desc="×2 EXP for 5 minutes.", effects={ { kind="exp_mult_passive", mult=2.0 }, { kind="invincibility", duration=300 } } },
	{ id=16, icon="⚡", name="Breakthrough Charm", rarity="Uncommon", itype="consumable", stack=20, cost=1500, slot=nil, desc="+20% breakthrough success rate.", effects={ { kind="break_pct", value=20 } } },
	{ id=17, icon="☯️", name="Seclusion Talisman", rarity="Uncommon", itype="consumable", stack=20, cost=600, slot=nil, desc="-25% Qi Deviation risk in seclusion.", effects={} },
	{ id=18, icon="🕯️", name="Focus Incense", rarity="Uncommon", itype="consumable", stack=20, cost=500, slot=nil, desc="+20% EXP gain during seclusion.", effects={} },
	{ id=19, icon="💧", name="Spirit Spring Water", rarity="Uncommon", itype="consumable", stack=30, cost=300, slot=nil, desc="Heals 20% HP per seclusion year.", effects={} },
	{ id=20, icon="💪", name="Strength Pill", rarity="Uncommon", itype="consumable", stack=20, cost=800, slot=nil, desc="+25% damage for 3 combat turns.", effects={ { kind="dmg_pct", value=25 } } },
	{ id=21, icon="🛡️", name="Iron Body Pill", rarity="Uncommon", itype="consumable", stack=20, cost=800, slot=nil, desc="+30% defense for 3 combat turns.", effects={ { kind="def_pct", value=30 } } },
	{ id=22, icon="💨", name="Wind Speed Pill", rarity="Uncommon", itype="consumable", stack=20, cost=700, slot=nil, desc="+40% dodge chance for 3 turns.", effects={} },
	{ id=23, icon="🍎", name="Qi Nourishment Fruit", rarity="Uncommon", itype="consumable", stack=20, cost=600, slot=nil, desc="Restores 25% HP and 25% QI.", effects={ { kind="heal_pct", value=25 }, { kind="qi_pct", value=25 } } },
	{ id=24, icon="🧪", name="Universal Antidote", rarity="Uncommon", itype="consumable", stack=20, cost=800, slot=nil, desc="Removes all poison and debuff effects.", effects={} },
	{ id=25, icon="🧠", name="Focus Pill", rarity="Uncommon", itype="consumable", stack=20, cost=600, slot=nil, desc="Prevents stun for 2 turns.", effects={} },
	{ id=26, icon="🔥", name="Warm Qi Pill", rarity="Uncommon", itype="consumable", stack=20, cost=600, slot=nil, desc="Prevents freeze for 2 turns.", effects={} },
	{ id=27, icon="💚", name="Regeneration Pill", rarity="Uncommon", itype="consumable", stack=20, cost=1200, slot=nil, desc="Restores 8% HP per turn for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=28, icon="🔵", name="Qi Barrier Pill", rarity="Rare", itype="consumable", stack=10, cost=3500, slot=nil, desc="Absorbs the next hit entirely (1 use shield).", effects={} },
	{ id=29, icon="🔱", name="Piercing Qi Pill", rarity="Rare", itype="consumable", stack=10, cost=4000, slot=nil, desc="+25% defense penetration for 3 turns.", effects={} },
	{ id=30, icon="🩸", name="Blood Drain Pill", rarity="Rare", itype="consumable", stack=10, cost=5000, slot=nil, desc="+20% lifesteal for 4 turns.", effects={} },
	{ id=31, icon="✕✕", name="Combo Trigger Pill", rarity="Rare", itype="consumable", stack=10, cost=6000, slot=nil, desc="+30% combo chance for 3 turns.", effects={} },
	{ id=32, icon="🔇", name="Silent Step Pill", rarity="Rare", itype="consumable", stack=10, cost=4500, slot=nil, desc="Makes your next 2 attacks impossible to dodge.", effects={} },
	{ id=33, icon="⚡", name="Power Surge Pill", rarity="Rare", itype="consumable", stack=10, cost=5500, slot=nil, desc="Activates Empowered buff for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=34, icon="💨", name="Wind Body Pill", rarity="Rare", itype="consumable", stack=10, cost=5000, slot=nil, desc="Activates Haste buff for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=35, icon="🔥", name="Dao Fire Pill", rarity="Rare", itype="consumable", stack=5, cost=15000, slot=nil, desc="+80% EXP for 20 minutes. Burns away impurities.", effects={ { kind="exp_mult_passive", mult=1.8 }, { kind="invincibility", duration=1200 } } },
	{ id=36, icon="🔴", name="Grand Healing Pill", rarity="Rare", itype="consumable", stack=20, cost=800, slot=nil, desc="Fully restores HP.", effects={ { kind="heal_pct", value=100 } } },
	{ id=37, icon="🌀", name="Pure Qi Pill", rarity="Rare", itype="consumable", stack=20, cost=900, slot=nil, desc="Fully restores QI.", effects={ { kind="qi_pct", value=100 } } },
	{ id=38, icon="📙", name="Greater Cultivation Pill", rarity="Rare", itype="consumable", stack=20, cost=5000, slot=nil, desc="Grants 10,000 EXP.", effects={ { kind="exp_flat", value=10000 } } },
	{ id=39, icon="🚩", name="Grand Qi Flag", rarity="Rare", itype="consumable", stack=10, cost=3000, slot=nil, desc="×2.5 EXP for 15 minutes.", effects={ { kind="exp_mult_passive", mult=2.5 }, { kind="invincibility", duration=900 } } },
	{ id=40, icon="🍀", name="Fortune Charm", rarity="Rare", itype="consumable", stack=10, cost=2000, slot=nil, desc="×1.5 EXP and ×1.5 Stones for 10 minutes.", effects={ { kind="exp_mult_passive", mult=1.5 }, { kind="invincibility", duration=600 } } },
	{ id=41, icon="🌟", name="Breakthrough Pill", rarity="Rare", itype="consumable", stack=10, cost=6000, slot=nil, desc="+35% breakthrough success rate.", effects={ { kind="break_pct", value=35 } } },
	{ id=42, icon="💊", name="Foundation Pill", rarity="Rare", itype="consumable", stack=5, cost=8000, slot=nil, desc="+30% success for Realm 1→2 breakthrough.", effects={ { kind="break_pct", value=30 } } },
	{ id=43, icon="⏳", name="Minor Lifespan Pill", rarity="Rare", itype="consumable", stack=5, cost=10000, slot=nil, desc="+50 years lifespan.", effects={ { kind="life", value=50 } } },
	{ id=44, icon="☯️", name="Grand Seclusion Talisman", rarity="Rare", itype="consumable", stack=10, cost=2500, slot=nil, desc="-50% Qi Deviation risk in seclusion.", effects={} },
	{ id=45, icon="🕯️", name="Premium Focus Incense", rarity="Rare", itype="consumable", stack=10, cost=2000, slot=nil, desc="+50% EXP gain during seclusion.", effects={} },
	{ id=46, icon="🕯️", name="Dao Candle", rarity="Rare", itype="consumable", stack=10, cost=3000, slot=nil, desc="+100% EXP in seclusion for this session.", effects={} },
	{ id=47, icon="💡", name="Insight Pill", rarity="Rare", itype="consumable", stack=10, cost=4000, slot=nil, desc="Guarantees 1 Seclusion Insight this session.", effects={} },
	{ id=48, icon="🎯", name="Critical Strike Pill", rarity="Rare", itype="consumable", stack=10, cost=2500, slot=nil, desc="+20% critical hit chance for 5 turns.", effects={} },
	{ id=49, icon="😤", name="Berserk Pill", rarity="Rare", itype="consumable", stack=10, cost=3000, slot=nil, desc="+60% damage but -40% defense for 4 turns.", effects={ { kind="dmg_pct", value=60 } } },
	{ id=50, icon="🩸", name="Blood Strengthening Pill", rarity="Rare", itype="consumable", stack=10, cost=2000, slot=nil, desc="+15% lifesteal for 3 turns.", effects={} },
	{ id=51, icon="⚡", name="Thunder Pill", rarity="Rare", itype="consumable", stack=10, cost=2500, slot=nil, desc="+30% stun chance for 3 turns.", effects={} },
	{ id=52, icon="🍷", name="Heavenly Wine", rarity="Rare", itype="consumable", stack=10, cost=5000, slot=nil, desc="+30% EXP for 20 minutes.", effects={ { kind="exp_mult_passive", mult=1.3 }, { kind="invincibility", duration=1200 } } },
	{ id=53, icon="🔵", name="Qi Barrier Pill", rarity="Rare", itype="consumable", stack=10, cost=3500, slot=nil, desc="Absorbs the next hit entirely (1 use shield).", effects={} },
	{ id=54, icon="🔱", name="Piercing Qi Pill", rarity="Rare", itype="consumable", stack=10, cost=4000, slot=nil, desc="+25% defense penetration for 3 turns.", effects={} },
	{ id=55, icon="🩸", name="Blood Drain Pill", rarity="Rare", itype="consumable", stack=10, cost=5000, slot=nil, desc="+20% lifesteal for 4 turns.", effects={} },
	{ id=56, icon="✕✕", name="Combo Trigger Pill", rarity="Rare", itype="consumable", stack=10, cost=6000, slot=nil, desc="+30% combo chance for 3 turns.", effects={} },
	{ id=57, icon="🔇", name="Silent Step Pill", rarity="Rare", itype="consumable", stack=10, cost=4500, slot=nil, desc="Makes your next 2 attacks impossible to dodge.", effects={} },
	{ id=58, icon="⚡", name="Power Surge Pill", rarity="Rare", itype="consumable", stack=10, cost=5500, slot=nil, desc="Activates Empowered buff for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=59, icon="💨", name="Wind Body Pill", rarity="Rare", itype="consumable", stack=10, cost=5000, slot=nil, desc="Activates Haste buff for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=60, icon="🔥", name="Dao Fire Pill", rarity="Rare", itype="consumable", stack=5, cost=15000, slot=nil, desc="+80% EXP for 20 minutes. Burns away impurities.", effects={ { kind="exp_mult_passive", mult=1.8 }, { kind="invincibility", duration=1200 } } },
	{ id=61, icon="🪞", name="Mirror Qi Pill", rarity="Epic", itype="consumable", stack=5, cost=12000, slot=nil, desc="+30% damage reflect for 3 turns.", effects={} },
	{ id=62, icon="🌀", name="Qi Surge Pill", rarity="Epic", itype="consumable", stack=5, cost=15000, slot=nil, desc="Activates Qi Surge buff (halves all technique costs) for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=63, icon="📈", name="Aptitude Enhancing Pill", rarity="Epic", itype="consumable", stack=3, cost=50000, slot=nil, desc="Temporarily boosts cultivation speed by 50% for 1 hour.", effects={ { kind="exp_mult_passive", mult=1.5 }, { kind="invincibility", duration=3600 } } },
	{ id=64, icon="🟣", name="Purple Qi Pill", rarity="Epic", itype="consumable", stack=3, cost=40000, slot=nil, desc="+100% EXP, +50% QI capacity for 45 minutes.", effects={ { kind="exp_mult_passive", mult=2.0 }, { kind="invincibility", duration=2700 } } },
	{ id=65, icon="💎", name="Immortal Healing Pill", rarity="Epic", itype="consumable", stack=10, cost=3000, slot=nil, desc="Fully restores HP and QI.", effects={ { kind="heal_pct", value=100 }, { kind="qi_pct", value=100 } } },
	{ id=66, icon="🌟", name="Revitalization Pill", rarity="Epic", itype="consumable", stack=5, cost=5000, slot=nil, desc="Fully restores HP and QI. Grants Regenerating buff for 3 turns.", effects={ { kind="heal_pct", value=100 }, { kind="qi_pct", value=100 }, { kind="invincibility", duration=3 } } },
	{ id=67, icon="📕", name="Grand Cultivation Pill", rarity="Epic", itype="consumable", stack=10, cost=20000, slot=nil, desc="Grants 50,000 EXP.", effects={ { kind="exp_flat", value=50000 } } },
	{ id=68, icon="☯️", name="Dao Essence Pill", rarity="Epic", itype="consumable", stack=10, cost=25000, slot=nil, desc="Grants 80,000 EXP and +10% EXP gain for 1 hour.", effects={ { kind="exp_flat", value=80000 }, { kind="exp_mult_passive", mult=1.1 }, { kind="invincibility", duration=3600 } } },
	{ id=69, icon="🎌", name="Immortal Qi Flag", rarity="Epic", itype="consumable", stack=5, cost=12000, slot=nil, desc="×3 EXP for 30 minutes.", effects={ { kind="exp_mult_passive", mult=3.0 }, { kind="invincibility", duration=1800 } } },
	{ id=70, icon="💥", name="Grand Breakthrough Pill", rarity="Epic", itype="consumable", stack=5, cost=25000, slot=nil, desc="+55% breakthrough success rate.", effects={ { kind="break_pct", value=55 } } },
	{ id=71, icon="🟡", name="Core Formation Pill", rarity="Epic", itype="consumable", stack=3, cost=40000, slot=nil, desc="+40% success for Realm 2→3 breakthrough.", effects={ { kind="break_pct", value=40 } } },
	{ id=72, icon="👻", name="Soul Nourishment Pill", rarity="Epic", itype="consumable", stack=3, cost=60000, slot=nil, desc="+35% success for Realm 3→4 breakthrough.", effects={ { kind="break_pct", value=35 } } },
	{ id=73, icon="⌛", name="Lifespan Pill", rarity="Epic", itype="consumable", stack=3, cost=40000, slot=nil, desc="+200 years lifespan.", effects={ { kind="life", value=200 } } },
	{ id=74, icon="☯️", name="Immortal Talisman", rarity="Epic", itype="consumable", stack=5, cost=10000, slot=nil, desc="-75% Qi Deviation risk in seclusion.", effects={} },
	{ id=75, icon="💠", name="Time Compression Jade", rarity="Epic", itype="consumable", stack=5, cost=15000, slot=nil, desc="Halves seclusion real-time (same EXP, half the wait).", effects={} },
	{ id=76, icon="💥", name="Spirit Burst Pill", rarity="Epic", itype="consumable", stack=5, cost=12000, slot=nil, desc="Doubles all stats for 2 turns. Single use.", effects={} },
	{ id=77, icon="👁️", name="Void Step Pill", rarity="Epic", itype="consumable", stack=5, cost=8000, slot=nil, desc="+60% dodge chance for 2 turns.", effects={} },
	{ id=78, icon="🍑", name="Immortal Peach", rarity="Epic", itype="consumable", stack=3, cost=30000, slot=nil, desc="Fully restores HP, QI, and grants +100 years lifespan.", effects={ { kind="heal_pct", value=100 }, { kind="qi_pct", value=100 }, { kind="life", value=100 } } },
	{ id=79, icon="🍲", name="Dao Comprehension Soup", rarity="Epic", itype="consumable", stack=5, cost=20000, slot=nil, desc="+50% EXP for 30 minutes.", effects={ { kind="exp_mult_passive", mult=1.5 }, { kind="invincibility", duration=1800 } } },
	{ id=80, icon="🪞", name="Mirror Qi Pill", rarity="Epic", itype="consumable", stack=5, cost=12000, slot=nil, desc="+30% damage reflect for 3 turns.", effects={} },
	{ id=81, icon="🌀", name="Qi Surge Pill", rarity="Epic", itype="consumable", stack=5, cost=15000, slot=nil, desc="Activates Qi Surge buff (halves all technique costs) for 3 turns.", effects={ { kind="invincibility", duration=3 } } },
	{ id=82, icon="📈", name="Aptitude Enhancing Pill", rarity="Epic", itype="consumable", stack=3, cost=50000, slot=nil, desc="Temporarily boosts cultivation speed by 50% for 1 hour.", effects={ { kind="exp_mult_passive", mult=1.5 }, { kind="invincibility", duration=3600 } } },
	{ id=83, icon="🟣", name="Purple Qi Pill", rarity="Epic", itype="consumable", stack=3, cost=40000, slot=nil, desc="+100% EXP, +50% QI capacity for 45 minutes.", effects={ { kind="exp_mult_passive", mult=2.0 }, { kind="invincibility", duration=2700 } } },
	{ id=84, icon="🌐", name="Realm Resonance Pill", rarity="Legendary", itype="consumable", stack=2, cost=200000, slot=nil, desc="×3 EXP for 2 hours. Resonates with the next realm.", effects={ { kind="exp_mult_passive", mult=3.0 }, { kind="invincibility", duration=7200 } } },
	{ id=85, icon="9️⃣", name="Nine Revolution Pill", rarity="Legendary", itype="consumable", stack=1, cost=1000000, slot=nil, desc="The legendary alchemical pill. ×10 EXP for 30 minutes.", effects={ { kind="exp_mult_passive", mult=10.0 }, { kind="invincibility", duration=1800 } } },
	{ id=86, icon="✨", name="Divine Mending Pill", rarity="Legendary", itype="consumable", stack=5, cost=15000, slot=nil, desc="Restores HP, QI, and removes all debuffs.", effects={ { kind="heal_pct", value=100 }, { kind="qi_pct", value=100 } } },
	{ id=87, icon="📔", name="Supreme Cultivation Pill", rarity="Legendary", itype="consumable", stack=5, cost=80000, slot=nil, desc="Grants 200,000 EXP.", effects={ { kind="exp_flat", value=200000 } } },
	{ id=88, icon="⭐", name="Heaven's Insight Pill", rarity="Legendary", itype="consumable", stack=3, cost=150000, slot=nil, desc="Grants 500,000 EXP and +25% EXP gain for 2 hours.", effects={ { kind="exp_flat", value=500000 }, { kind="exp_mult_passive", mult=1.25 }, { kind="invincibility", duration=7200 } } },
	{ id=89, icon="💫", name="Dao Resonance Stone", rarity="Legendary", itype="consumable", stack=3, cost=50000, slot=nil, desc="×5 EXP for 1 hour. Rare cosmic energy.", effects={ { kind="exp_mult_passive", mult=5.0 }, { kind="invincibility", duration=3600 } } },
	{ id=90, icon="✨", name="Supreme Breakthrough Pill", rarity="Legendary", itype="consumable", stack=2, cost=100000, slot=nil, desc="+80% breakthrough success rate.", effects={ { kind="break_pct", value=80 } } },
	{ id=91, icon="🌌", name="Void Amalgamation Pill", rarity="Legendary", itype="consumable", stack=2, cost=150000, slot=nil, desc="+40% success for Realm 5→6 breakthrough.", effects={ { kind="break_pct", value=40 } } },
	{ id=92, icon="⚡", name="Tribulation Pill", rarity="Legendary", itype="consumable", stack=1, cost=400000, slot=nil, desc="+30% success for Realm 7→8 breakthrough.", effects={ { kind="break_pct", value=30 } } },
	{ id=93, icon="🕰️", name="Grand Lifespan Pill", rarity="Legendary", itype="consumable", stack=2, cost=150000, slot=nil, desc="+1,000 years lifespan.", effects={ { kind="life", value=1000 } } },
	{ id=94, icon="🔷", name="Temporal Crystal", rarity="Legendary", itype="consumable", stack=2, cost=80000, slot=nil, desc="Reduces seclusion time to 20% (5× faster).", effects={} },
	{ id=95, icon="☯️", name="Dao Combat Pill", rarity="Legendary", itype="consumable", stack=3, cost=50000, slot=nil, desc="Activates Dao Insight buff for 5 turns.", effects={} },
	{ id=96, icon="🌐", name="Realm Resonance Pill", rarity="Legendary", itype="consumable", stack=2, cost=200000, slot=nil, desc="×3 EXP for 2 hours. Resonates with the next realm.", effects={ { kind="exp_mult_passive", mult=3.0 }, { kind="invincibility", duration=7200 } } },
	{ id=97, icon="9️⃣", name="Nine Revolution Pill", rarity="Legendary", itype="consumable", stack=1, cost=1000000, slot=nil, desc="The legendary alchemical pill. ×10 EXP for 30 minutes.", effects={ { kind="exp_mult_passive", mult=10.0 }, { kind="invincibility", duration=1800 } } },
	{ id=98, icon="🌠", name="Divine Insight Pill", rarity="Divine", itype="consumable", stack=2, cost=500000, slot=nil, desc="Grants 1,000,000 EXP. A fragment of heaven's insight.", effects={ { kind="exp_flat", value=1000000 } } },
	{ id=99, icon="🌈", name="Divine Breakthrough Pill", rarity="Divine", itype="consumable", stack=1, cost=500000, slot=nil, desc="Guarantees breakthrough success.", effects={ { kind="break_pct", value=100 } } },
	{ id=100, icon="♾️", name="Divine Lifespan Pill", rarity="Divine", itype="consumable", stack=1, cost=800000, slot=nil, desc="+10,000 years lifespan. Near-immortal.", effects={ { kind="life", value=10000 } } },
	{ id=101, icon="☯️", name="Immortal Dao Pill", rarity="Immortal", itype="consumable", stack=1, cost=5000000, slot=nil, desc="Grants 10,000,000 EXP. Rumoured to exist only in myth.", effects={ { kind="exp_flat", value=10000000 } } },
	{ id=102, icon="🌊", name="Elixir of Immortality", rarity="Immortal", itype="consumable", stack=1, cost=0, slot=nil, desc="Grants true immortality. +99,999 years.", effects={ { kind="life", value=99999 } } },
	{ id=103, icon="💰", name="Spirit Stone Bag (100)", rarity="Common", itype="currency", stack=99, cost=100, slot=nil, desc="Contains 100 Spirit Stones.", effects={ { kind="stones", value=100 } } },
	{ id=104, icon="💰", name="Spirit Stone Pouch (500)", rarity="Uncommon", itype="currency", stack=50, cost=450, slot=nil, desc="Contains 500 Spirit Stones.", effects={ { kind="stones", value=500 } } },
	{ id=105, icon="💰", name="Spirit Stone Chest (2000)", rarity="Rare", itype="currency", stack=20, cost=1800, slot=nil, desc="Contains 2,000 Spirit Stones.", effects={ { kind="stones", value=2000 } } },
	{ id=106, icon="💰", name="Spirit Stone Vault (10k)", rarity="Epic", itype="currency", stack=5, cost=8000, slot=nil, desc="Contains 10,000 Spirit Stones.", effects={ { kind="stones", value=10000 } } },
	{ id=107, icon="⚔️", name="Iron Sword", rarity="Common", itype="equipment", stack=1, cost=500, slot="weapon", desc="+5% damage.", effects={ { kind="dmg_pct", value=5 } } },
	{ id=108, icon="👘", name="Qi Cultivation Robe", rarity="Common", itype="equipment", stack=1, cost=600, slot="body", desc="+5% defense, +5% seclusion EXP.", effects={ { kind="def_pct", value=5 } } },
	{ id=109, icon="🦺", name="Iron Cultivator Vest", rarity="Common", itype="equipment", stack=1, cost=400, slot="body", desc="+8% defense.", effects={ { kind="def_pct", value=8 } } },
	{ id=110, icon="🪃", name="Iron Spear", rarity="Uncommon", itype="equipment", stack=1, cost=5000, slot="weapon", desc="+15% damage, +5% defense penetration.", effects={ { kind="dmg_pct", value=15 } } },
	{ id=111, icon="⚔️", name="Qi-Infused Sword", rarity="Uncommon", itype="equipment", stack=1, cost=3000, slot="weapon", desc="+12% damage.", effects={ { kind="dmg_pct", value=12 } } },
	{ id=112, icon="👊", name="Iron Fist Gauntlets", rarity="Uncommon", itype="equipment", stack=1, cost=4000, slot="weapon", desc="+15% physical damage, +10% stun chance.", effects={ { kind="dmg_pct", value=15 } } },
	{ id=113, icon="👘", name="Spirit Cultivation Robe", rarity="Uncommon", itype="equipment", stack=1, cost=4000, slot="body", desc="+12% defense, +10% seclusion EXP.", effects={ { kind="def_pct", value=12 } } },
	{ id=114, icon="💚", name="Jade Pendant", rarity="Uncommon", itype="equipment", stack=1, cost=2000, slot="necklace", desc="+10% defense.", effects={ { kind="def_pct", value=10 } } },
	{ id=115, icon="📿", name="Spirit Bracelet", rarity="Uncommon", itype="equipment", stack=1, cost=3000, slot="necklace", desc="+8% QI capacity.", effects={} },
	{ id=116, icon="🪃", name="Iron Spear", rarity="Uncommon", itype="equipment", stack=1, cost=5000, slot="weapon", desc="+15% damage, +5% defense penetration.", effects={ { kind="dmg_pct", value=15 } } },
	{ id=117, icon="💍", name="Fleeting Wind Ring", rarity="Rare", itype="equipment", stack=1, cost=25000, slot="ring", desc="+18% dodge chance.", effects={} },
	{ id=118, icon="🏹", name="Spirit Bow", rarity="Rare", itype="equipment", stack=1, cost=20000, slot="weapon", desc="+25% damage, +10% crit chance.", effects={ { kind="dmg_pct", value=25 } } },
	{ id=119, icon="🐾", name="Spirit Beast Claws", rarity="Rare", itype="equipment", stack=1, cost=22000, slot="weapon", desc="+20% damage, +10% bleed chance.", effects={ { kind="dmg_pct", value=20 } } },
	{ id=120, icon="🦺", name="Spirit Absorbing Vest", rarity="Rare", itype="equipment", stack=1, cost=30000, slot="body", desc="+25% defense, +5% lifesteal.", effects={ { kind="def_pct", value=25 } } },
	{ id=121, icon="⚔️", name="Spirit Sword", rarity="Rare", itype="equipment", stack=1, cost=15000, slot="weapon", desc="+22% damage, +5% crit chance.", effects={ { kind="dmg_pct", value=22 } } },
	{ id=122, icon="🔥", name="Flame Palm Gloves", rarity="Rare", itype="equipment", stack=1, cost=18000, slot="weapon", desc="+20% damage, fire techniques deal +30%.", effects={ { kind="dmg_pct", value=20 } } },
	{ id=123, icon="👘", name="Dao Cultivation Robe", rarity="Rare", itype="equipment", stack=1, cost=20000, slot="body", desc="+22% defense, +20% seclusion EXP.", effects={ { kind="def_pct", value=22 } } },
	{ id=124, icon="🦴", name="Spirit Bone Armor", rarity="Rare", itype="equipment", stack=1, cost=25000, slot="body", desc="+30% defense, +10% HP bonus.", effects={ { kind="def_pct", value=30 }, { kind="hp_pct", value=10 } } },
	{ id=125, icon="💍", name="Qi Concentration Ring", rarity="Rare", itype="equipment", stack=1, cost=12000, slot="ring", desc="+15% QI, +10% EXP.", effects={ { kind="exp_mult_passive", mult=1.1 } } },
	{ id=126, icon="💎", name="Critical Strike Gem", rarity="Rare", itype="equipment", stack=1, cost=15000, slot="necklace", desc="+8% crit chance, +20% crit damage.", effects={} },
	{ id=127, icon="💨", name="Dodge Talisman", rarity="Rare", itype="equipment", stack=1, cost=18000, slot="necklace", desc="+12% dodge chance.", effects={} },
	{ id=128, icon="👁️", name="Insight Pendant", rarity="Rare", itype="equipment", stack=1, cost=20000, slot="necklace", desc="+15% seclusion EXP.", effects={} },
	{ id=129, icon="💍", name="Fleeting Wind Ring", rarity="Rare", itype="equipment", stack=1, cost=25000, slot="ring", desc="+18% dodge chance.", effects={} },
	{ id=130, icon="🏹", name="Spirit Bow", rarity="Rare", itype="equipment", stack=1, cost=20000, slot="weapon", desc="+25% damage, +10% crit chance.", effects={ { kind="dmg_pct", value=25 } } },
	{ id=131, icon="🐾", name="Spirit Beast Claws", rarity="Rare", itype="equipment", stack=1, cost=22000, slot="weapon", desc="+20% damage, +10% bleed chance.", effects={ { kind="dmg_pct", value=20 } } },
	{ id=132, icon="🦺", name="Spirit Absorbing Vest", rarity="Rare", itype="equipment", stack=1, cost=30000, slot="body", desc="+25% defense, +5% lifesteal.", effects={ { kind="def_pct", value=25 } } },
	{ id=133, icon="👁️", name="Heavenly Eye Stone", rarity="Epic", itype="equipment", stack=1, cost=80000, slot="necklace", desc="+10% crit chance, your crits deal ×3 instead of ×2.", effects={} },
	{ id=134, icon="📿", name="Blood Pact Bracelet", rarity="Epic", itype="equipment", stack=1, cost=100000, slot="necklace", desc="+20% lifesteal.", effects={} },
	{ id=135, icon="🌌", name="Void Space Necklace", rarity="Epic", itype="equipment", stack=1, cost=150000, slot="necklace", desc="+15% damage penetration.", effects={} },
	{ id=136, icon="🔱", name="Dao Piercing Spear", rarity="Epic", itype="equipment", stack=1, cost=100000, slot="weapon", desc="+45% damage, +15% defense penetration.", effects={ { kind="dmg_pct", value=45 } } },
	{ id=137, icon="🪭", name="Dao Wind Fan", rarity="Epic", itype="equipment", stack=1, cost=85000, slot="weapon", desc="+30% damage, wind techniques ×1.8.", effects={ { kind="dmg_pct", value=30 } } },
	{ id=138, icon="🌌", name="Void Cloak", rarity="Epic", itype="equipment", stack=1, cost=130000, slot="body", desc="+35% defense, +15% dodge.", effects={ { kind="def_pct", value=35 } } },
	{ id=139, icon="🗡️", name="Dao Sword", rarity="Epic", itype="equipment", stack=1, cost=80000, slot="weapon", desc="+40% damage, sword techniques ×1.5.", effects={ { kind="dmg_pct", value=40 } } },
	{ id=140, icon="⚡", name="Thunder Staff", rarity="Epic", itype="equipment", stack=1, cost=90000, slot="weapon", desc="+35% damage, +25% stun chance.", effects={ { kind="dmg_pct", value=35 } } },
	{ id=141, icon="💚", name="Jade Protection Armor", rarity="Epic", itype="equipment", stack=1, cost=120000, slot="body", desc="+45% defense, reduces stun duration by 50%.", effects={ { kind="def_pct", value=45 } } },
	{ id=142, icon="🟠", name="Fortune Bead", rarity="Epic", itype="equipment", stack=1, cost=90000, slot="necklace", desc="+20% Spirit Stone drops.", effects={} },
	{ id=143, icon="♾️", name="Lifespan Ring", rarity="Epic", itype="equipment", stack=1, cost=100000, slot="ring", desc="+500 years lifespan.", effects={ { kind="life", value=500 } } },
	{ id=144, icon="👁️", name="Heavenly Eye Stone", rarity="Epic", itype="equipment", stack=1, cost=80000, slot="necklace", desc="+10% crit chance, your crits deal ×3 instead of ×2.", effects={} },
	{ id=145, icon="📿", name="Blood Pact Bracelet", rarity="Epic", itype="equipment", stack=1, cost=100000, slot="necklace", desc="+20% lifesteal.", effects={} },
	{ id=146, icon="🌌", name="Void Space Necklace", rarity="Epic", itype="equipment", stack=1, cost=150000, slot="necklace", desc="+15% damage penetration.", effects={} },
	{ id=147, icon="🔱", name="Dao Piercing Spear", rarity="Epic", itype="equipment", stack=1, cost=100000, slot="weapon", desc="+45% damage, +15% defense penetration.", effects={ { kind="dmg_pct", value=45 } } },
	{ id=148, icon="🪭", name="Dao Wind Fan", rarity="Epic", itype="equipment", stack=1, cost=85000, slot="weapon", desc="+30% damage, wind techniques ×1.8.", effects={ { kind="dmg_pct", value=30 } } },
	{ id=149, icon="🌌", name="Void Cloak", rarity="Epic", itype="equipment", stack=1, cost=130000, slot="body", desc="+35% defense, +15% dodge.", effects={ { kind="def_pct", value=35 } } },
	{ id=150, icon="⚡", name="Thunder God Pendant", rarity="Legendary", itype="equipment", stack=1, cost=400000, slot="necklace", desc="+20% stun chance, +30% damage.", effects={ { kind="dmg_pct", value=30 } } },
	{ id=151, icon="☯️", name="Sun and Moon Ring", rarity="Legendary", itype="equipment", stack=1, cost=700000, slot="ring", desc="+20% all stats during day, +20% at night.", effects={} },
	{ id=152, icon="🔨", name="Heavenly Hammer", rarity="Legendary", itype="equipment", stack=1, cost=600000, slot="weapon", desc="+80% damage, guaranteed stun on crit.", effects={ { kind="dmg_pct", value=80 } } },
	{ id=153, icon="🐉", name="Dragon Scale Armor", rarity="Legendary", itype="equipment", stack=1, cost=600000, slot="body", desc="+70% defense, -20% damage taken from fire/ice.", effects={ { kind="def_pct", value=70 } } },
	{ id=154, icon="🗡️", name="Immortal Sword", rarity="Legendary", itype="equipment", stack=1, cost=500000, slot="weapon", desc="+70% damage, +15% crit chance, sword ×2.", effects={ { kind="dmg_pct", value=70 } } },
	{ id=155, icon="✨", name="Immortal Robe", rarity="Legendary", itype="equipment", stack=1, cost=400000, slot="body", desc="+50% defense, +40% EXP gain.", effects={ { kind="def_pct", value=50 }, { kind="exp_mult_passive", mult=1.4 } } },
	{ id=156, icon="🧭", name="Dao Compass", rarity="Legendary", itype="equipment", stack=1, cost=300000, slot="necklace", desc="+25% EXP, +15% breakthrough rate.", effects={ { kind="exp_mult_passive", mult=1.25 }, { kind="break_pct", value=15 } } },
	{ id=157, icon="☯️", name="Dao Bead", rarity="Legendary", itype="equipment", stack=1, cost=600000, slot="necklace", desc="+30% all combat stats.", effects={} },
	{ id=158, icon="⚡", name="Thunder God Pendant", rarity="Legendary", itype="equipment", stack=1, cost=400000, slot="necklace", desc="+20% stun chance, +30% damage.", effects={ { kind="dmg_pct", value=30 } } },
	{ id=159, icon="☯️", name="Sun and Moon Ring", rarity="Legendary", itype="equipment", stack=1, cost=700000, slot="ring", desc="+20% all stats during day, +20% at night.", effects={} },
	{ id=160, icon="🔨", name="Heavenly Hammer", rarity="Legendary", itype="equipment", stack=1, cost=600000, slot="weapon", desc="+80% damage, guaranteed stun on crit.", effects={ { kind="dmg_pct", value=80 } } },
	{ id=161, icon="🐉", name="Dragon Scale Armor", rarity="Legendary", itype="equipment", stack=1, cost=600000, slot="body", desc="+70% defense, -20% damage taken from fire/ice.", effects={ { kind="def_pct", value=70 } } },
	{ id=162, icon="💍", name="Fate Binding Ring", rarity="Mythic", itype="equipment", stack=1, cost=5000000, slot="ring", desc="All stats +20%. Binds to your fate.", effects={} },
	{ id=163, icon="💍", name="Fate Binding Ring", rarity="Mythic", itype="equipment", stack=1, cost=5000000, slot="ring", desc="All stats +20%. Binds to your fate.", effects={} },
	{ id=164, icon="⚡", name="Heavenly Blade", rarity="Divine", itype="equipment", stack=1, cost=2000000, slot="weapon", desc="+120% damage, ignores 30% defense.", effects={ { kind="dmg_pct", value=120 } } },
	{ id=165, icon="🌟", name="Heavenly Armor", rarity="Divine", itype="equipment", stack=1, cost=1500000, slot="body", desc="+90% defense, +20% reflect damage.", effects={ { kind="def_pct", value=90 } } },
	{ id=166, icon="🌑", name="Chaos Bead", rarity="Divine", itype="equipment", stack=1, cost=3000000, slot="necklace", desc="+50% all stats.", effects={} },
	{ id=167, icon="🌟", name="True Immortal Armor", rarity="Immortal", itype="equipment", stack=1, cost=0, slot="body", desc="+200% defense, immune to one-shot kills.", effects={ { kind="def_pct", value=200 } } },
	{ id=168, icon="🌑", name="Chaos Blade", rarity="Immortal", itype="equipment", stack=1, cost=0, slot="weapon", desc="+200% damage, all combat effects ×2.", effects={ { kind="dmg_pct", value=200 } } },
	{ id=169, icon="🌟", name="True Immortal Armor", rarity="Immortal", itype="equipment", stack=1, cost=0, slot="body", desc="+200% defense, immune to one-shot kills.", effects={ { kind="def_pct", value=200 } } },
	{ id=170, icon="🌿", name="Spirit Herb", rarity="Common", itype="material", stack=999, cost=50, slot=nil, desc="Basic Qi-infused herb. Used in alchemy.", effects={} },
	{ id=171, icon="⚙️", name="Iron Essence", rarity="Common", itype="material", stack=999, cost=30, slot=nil, desc="Purified metal. Used to forge weapons and armor.", effects={} },
	{ id=172, icon="💚", name="Spirit Jade Fragment", rarity="Common", itype="material", stack=99, cost=80, slot=nil, desc="Broken piece of spirit jade. Common crafting material.", effects={} },
	{ id=173, icon="🔮", name="Minor Beast Core", rarity="Common", itype="material", stack=99, cost=100, slot=nil, desc="Core from a weak spirit beast. Small amount of Qi.", effects={} },
	{ id=174, icon="💎", name="Spirit Crystal (Small)", rarity="Common", itype="material", stack=99, cost=80, slot=nil, desc="Small crystal with condensed spirit energy.", effects={} },
	{ id=175, icon="💧", name="Spirit Spring Water", rarity="Uncommon", itype="material", stack=50, cost=200, slot=nil, desc="Water from a spirit spring. Healing properties.", effects={} },
	{ id=176, icon="🔥", name="Fire Lotus", rarity="Uncommon", itype="material", stack=99, cost=200, slot=nil, desc="Fire-affinity herb. Used for fire technique scrolls.", effects={} },
	{ id=177, icon="❄️", name="Frost Lily", rarity="Uncommon", itype="material", stack=99, cost=200, slot=nil, desc="Ice-affinity herb. Used for water technique scrolls.", effects={} },
	{ id=178, icon="🔩", name="Spirit Iron", rarity="Uncommon", itype="material", stack=99, cost=150, slot=nil, desc="Qi-infused iron. Better than regular iron essence.", effects={} },
	{ id=179, icon="🦴", name="Spirit Beast Bone", rarity="Uncommon", itype="material", stack=50, cost=500, slot=nil, desc="Bone from a powerful spirit beast. Strong crafting base.", effects={} },
	{ id=180, icon="✨", name="Star Dust", rarity="Uncommon", itype="material", stack=99, cost=400, slot=nil, desc="Dust from a fallen star. Magical crafting material.", effects={} },
	{ id=181, icon="🔮", name="Beast Core", rarity="Uncommon", itype="material", stack=50, cost=400, slot=nil, desc="Core from a spirit beast. Decent Qi concentration.", effects={} },
	{ id=182, icon="💎", name="Spirit Crystal (Medium)", rarity="Uncommon", itype="material", stack=50, cost=350, slot=nil, desc="Medium crystal with condensed spirit energy.", effects={} },
	{ id=183, icon="🔷", name="Technique Memory Shard", rarity="Uncommon", itype="material", stack=30, cost=800, slot=nil, desc="A shard containing a fragment of martial memory.", effects={} },
	{ id=184, icon="💧", name="Spirit Spring Water", rarity="Uncommon", itype="material", stack=50, cost=200, slot=nil, desc="Water from a spirit spring. Healing properties.", effects={} },
	{ id=185, icon="🔮", name="Formation Stone", rarity="Rare", itype="material", stack=20, cost=8000, slot=nil, desc="Used to draw cultivation formations.", effects={} },
	{ id=186, icon="📝", name="Ancient Rune Fragment", rarity="Rare", itype="material", stack=15, cost=10000, slot=nil, desc="A fragment of an ancient inscription. Used in technique scrolls.", effects={} },
	{ id=187, icon="⚡", name="Thunder Vine", rarity="Rare", itype="material", stack=50, cost=800, slot=nil, desc="Lightning-charged plant. Rare crafting component.", effects={} },
	{ id=188, icon="💎", name="Dao Crystal", rarity="Rare", itype="material", stack=50, cost=2000, slot=nil, desc="Crystallized Dao energy. Core crafting material.", effects={} },
	{ id=189, icon="🌙", name="Moon Stone", rarity="Rare", itype="material", stack=30, cost=3000, slot=nil, desc="Stone bathed in moonlight for 1000 years. Yin-affinity.", effects={} },
	{ id=190, icon="☀️", name="Sun Core Fragment", rarity="Rare", itype="material", stack=30, cost=4000, slot=nil, desc="Fragment of concentrated Yang energy.", effects={} },
	{ id=191, icon="🌳", name="Ancient Spirit Tree Bark", rarity="Rare", itype="material", stack=30, cost=2500, slot=nil, desc="Bark from a 10,000 year old spirit tree.", effects={} },
	{ id=192, icon="🔮", name="Grand Beast Core", rarity="Rare", itype="material", stack=20, cost=2000, slot=nil, desc="Core from a powerful beast. Dense Qi.", effects={} },
	{ id=193, icon="🧬", name="Mutant Beast Gland", rarity="Rare", itype="material", stack=10, cost=5000, slot=nil, desc="Gland from a mutated beast. Used in special pill crafting.", effects={} },
	{ id=194, icon="🌀", name="Realm Essence", rarity="Rare", itype="material", stack=20, cost=3000, slot=nil, desc="Essence of a cultivation realm. Drops from realm-level bosses.", effects={} },
	{ id=195, icon="🔮", name="Formation Stone", rarity="Rare", itype="material", stack=20, cost=8000, slot=nil, desc="Used to draw cultivation formations.", effects={} },
	{ id=196, icon="📝", name="Ancient Rune Fragment", rarity="Rare", itype="material", stack=15, cost=10000, slot=nil, desc="A fragment of an ancient inscription. Used in technique scrolls.", effects={} },
	{ id=197, icon="⌛", name="Time Sand", rarity="Epic", itype="material", stack=10, cost=80000, slot=nil, desc="Sand from the River of Time. Used in lifespan items.", effects={} },
	{ id=198, icon="⭐", name="Star Falling Iron", rarity="Epic", itype="material", stack=10, cost=60000, slot=nil, desc="Iron forged in a falling star. Extremely hard.", effects={} },
	{ id=199, icon="🏖️", name="Heavenly Sand", rarity="Epic", itype="material", stack=20, cost=30000, slot=nil, desc="Sand from the Heavenly Desert. Purifies Qi.", effects={} },
	{ id=200, icon="💠", name="Heaven Crystal", rarity="Epic", itype="material", stack=20, cost=15000, slot=nil, desc="Crystal containing heavenly energy.", effects={} },
	{ id=201, icon="🦅", name="Phoenix Feather", rarity="Epic", itype="material", stack=10, cost=50000, slot=nil, desc="Feather from a divine phoenix. Used in resurrection items.", effects={} },
	{ id=202, icon="🌌", name="Void Crystal", rarity="Epic", itype="material", stack=10, cost=30000, slot=nil, desc="Crystal from between realms. Used in Void technique crafting.", effects={} },
	{ id=203, icon="🩸", name="Divine Beast Blood", rarity="Epic", itype="material", stack=10, cost=40000, slot=nil, desc="Blood from a divine-grade beast. Rare alchemical ingredient.", effects={} },
	{ id=204, icon="🔮", name="Divine Beast Core", rarity="Epic", itype="material", stack=5, cost=15000, slot=nil, desc="Core from a divine-grade beast. Extremely dense Qi.", effects={} },
	{ id=205, icon="⌛", name="Time Sand", rarity="Epic", itype="material", stack=10, cost=80000, slot=nil, desc="Sand from the River of Time. Used in lifespan items.", effects={} },
	{ id=206, icon="⭐", name="Star Falling Iron", rarity="Epic", itype="material", stack=10, cost=60000, slot=nil, desc="Iron forged in a falling star. Extremely hard.", effects={} },
	{ id=207, icon="🏖️", name="Heavenly Sand", rarity="Epic", itype="material", stack=20, cost=30000, slot=nil, desc="Sand from the Heavenly Desert. Purifies Qi.", effects={} },
	{ id=208, icon="💀", name="Death Lotus", rarity="Legendary", itype="material", stack=5, cost=200000, slot=nil, desc="A flower that blooms only at death. Used in extreme combat pills.", effects={} },
	{ id=209, icon="☯️", name="Yin-Yang Ore", rarity="Legendary", itype="material", stack=5, cost=150000, slot=nil, desc="Ore with perfect Yin-Yang balance. Divine crafting material.", effects={} },
	{ id=210, icon="🧵", name="Immortal Silk", rarity="Legendary", itype="material", stack=10, cost=80000, slot=nil, desc="Silk from immortal silkworms. Extremely rare.", effects={} },
	{ id=211, icon="🐉", name="Dragon Scale Fragment", rarity="Legendary", itype="material", stack=5, cost=100000, slot=nil, desc="A scale from an ancient dragon. Divine defense material.", effects={} },
	{ id=212, icon="💫", name="Boss Essence", rarity="Legendary", itype="material", stack=3, cost=80000, slot=nil, desc="Essence from a realm boss. Used in legendary crafting.", effects={} },
	{ id=213, icon="💀", name="Death Lotus", rarity="Legendary", itype="material", stack=5, cost=200000, slot=nil, desc="A flower that blooms only at death. Used in extreme combat pills.", effects={} },
	{ id=214, icon="☯️", name="Yin-Yang Ore", rarity="Legendary", itype="material", stack=5, cost=150000, slot=nil, desc="Ore with perfect Yin-Yang balance. Divine crafting material.", effects={} },
	{ id=215, icon="🌟", name="Divine Beast Core", rarity="Divine", itype="material", stack=3, cost=500000, slot=nil, desc="The core of a divine beast. The most sought-after crafting material.", effects={} },
	{ id=216, icon="🌈", name="Heaven Weave Silk", rarity="Divine", itype="material", stack=5, cost=300000, slot=nil, desc="Silk woven from heavenly energy. Used for divine-grade equipment.", effects={} },
	{ id=217, icon="🌑", name="Chaos Ore", rarity="Divine", itype="material", stack=5, cost=400000, slot=nil, desc="Ore from the primordial chaos. Cannot be forged conventionally.", effects={} },
	{ id=218, icon="🌟", name="Divine Beast Core", rarity="Divine", itype="material", stack=3, cost=500000, slot=nil, desc="The core of a divine beast. The most sought-after crafting material.", effects={} },
	{ id=219, icon="🌈", name="Heaven Weave Silk", rarity="Divine", itype="material", stack=5, cost=300000, slot=nil, desc="Silk woven from heavenly energy. Used for divine-grade equipment.", effects={} },
	{ id=220, icon="📜", name="Iron Fist Manual", rarity="Common", itype="scroll", stack=1, cost=1000, slot=nil, desc="Teaches the Iron Fist technique.", effects={} },
	{ id=221, icon="📜", name="Flame Palm Manual", rarity="Uncommon", itype="scroll", stack=1, cost=5000, slot=nil, desc="Teaches the Flame Palm technique.", effects={} },
	{ id=222, icon="📜", name="Thunder Step Manual", rarity="Rare", itype="scroll", stack=1, cost=20000, slot=nil, desc="Teaches Thunder Fist, a lightning-type attack.", effects={} },
	{ id=223, icon="📜", name="Void Flash Manual", rarity="Epic", itype="scroll", stack=1, cost=80000, slot=nil, desc="Teaches Void Flash, a space-type movement technique.", effects={} },
	{ id=224, icon="📜", name="Five Elements Formation", rarity="Epic", itype="scroll", stack=1, cost=150000, slot=nil, desc="Teaches the Five Elements Formation technique.", effects={} },
	{ id=225, icon="📜", name="Dao Palm Manual", rarity="Legendary", itype="scroll", stack=1, cost=300000, slot=nil, desc="Teaches Dao Palm, the pinnacle of palm techniques.", effects={} },
	{ id=226, icon="📜", name="Six Paths Manual", rarity="Divine", itype="scroll", stack=1, cost=2000000, slot=nil, desc="Teaches all Six Paths techniques simultaneously.", effects={} },
	{ id=227, icon="✏️", name="Name Change Token", rarity="Common", itype="special", stack=5, cost=500, slot=nil, desc="Change your cultivator display name.", effects={} },
	{ id=228, icon="👑", name="VIP Cultivation Charm", rarity="Rare", itype="special", stack=1, cost=50000, slot=nil, desc="×1.25 EXP gain permanently on this character.", effects={} },
	{ id=229, icon="📱", name="Immortal Jade Tablet", rarity="Legendary", itype="special", stack=1, cost=1000000, slot=nil, desc="Ancient tablet with immortal inscriptions. +5,000 years lifespan.", effects={ { kind="life", value=5000 } } },
	{ id=230, icon="📔", name="Han Jue's Personal Diary", rarity="Mythic", itype="special", stack=1, cost=999999, slot=nil, desc="The diary of the First Immortal. Reading it grants deep insight into the Six Paths. ×2 EXP for 1 hour.", effects={ { kind="exp_mult_passive", mult=2.0 }, { kind="invincibility", duration=3600 } } },
	{ id=231, icon="🎭", name="Fate Redirection Token", rarity="Mythic", itype="special", stack=1, cost=5000000, slot=nil, desc="Allows one re-roll of a Legendary or lower attribute.", effects={} },
	{ id=232, icon="🌑", name="Primordial Chaos Bead", rarity="Divine", itype="special", stack=1, cost=0, slot=nil, desc="A bead formed from primordial Chaos. Contains the energy of all creation.", effects={} },
	{ id=233, icon="⚡", name="Heavenly Tribulation Token", rarity="Divine", itype="special", stack=3, cost=2000000, slot=nil, desc="A token earned from Heaven itself. Required for high-level breakthroughs.", effects={ { kind="break_pct", value=30 } } },
	{ id=234, icon="❤️", name="Dao Heart Stone", rarity="Divine", itype="special", stack=1, cost=8000000, slot=nil, desc="A stone containing a fragment of the Dao. Permanently +10% EXP gain.", effects={} },
	{ id=235, icon="🌱", name="Six Paths Physique Seed", rarity="Divine", itype="special", stack=1, cost=0, slot=nil, desc="A seed containing the Six Paths Physique potential. Legendary physique enhancement.", effects={} },
	{ id=236, icon="✨", name="Creation Will Fragment", rarity="Immortal", itype="special", stack=1, cost=0, slot=nil, desc="A fragment of the Creation Will itself. Radiates immeasurable power.", effects={ { kind="exp_flat", value=10000000 } } },
}

local _byId: {[number]: Item} = {}
for _, it in ipairs(ItemData.ITEMS) do _byId[it.id] = it end

function ItemData.GetItem(id: number): Item?
	return _byId[id]
end

function ItemData.IsBuyable(item: Item): boolean
	return item.cost ~= nil
end

function ItemData.IsUsable(item: Item): boolean
	return #item.effects > 0 and (item.itype == "consumable" or item.itype == "scroll")
end

function ItemData.IsEquippable(item: Item): boolean
	return item.itype == "equipment" and item.slot ~= nil
end

-- Realm at which an item becomes available in the shop, derived from its cost.
-- Higher-cost goods unlock as the player advances, so the shop scales with realm.
function ItemData.UnlockRealm(item: Item): number
	local cost = item.cost
	if cost == nil then return 99 end       -- not buyable
	if cost < 300       then return 1 end
	if cost < 3000      then return 2 end
	if cost < 30000     then return 3 end
	if cost < 300000    then return 4 end
	if cost < 3000000   then return 5 end
	if cost < 30000000  then return 6 end
	return 7
end

-- Items buyable at (or below) the given realm, of the allowed kinds.
function ItemData.CatalogForRealm(realm: number): { Item }
	local out = {}
	for _, it in ipairs(ItemData.ITEMS) do
		if ItemData.IsBuyable(it)
			and (it.itype == "consumable" or it.itype == "scroll" or it.itype == "equipment")
			and ItemData.UnlockRealm(it) <= realm
		then
			table.insert(out, it)
		end
	end
	return out
end

return ItemData
