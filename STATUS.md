# Top Tier Providence — Feature Comparison

**Legend:** ✅ Done · 🟡 Partial / data-only · ❌ Not started

This compares the main elements of *Top Tier Providence* (novel / manhwa + the
`index.html` game reference) against what our Roblox recreation currently has.

---

## 1. Core Cultivation Loop

| TTP Element | What it is | Our status |
|---|---|---|
| 26 Cultivation Realms | Qi Refinement → Ultimate Origin Supreme | ✅ All 26 in data (R1–R9 fully playable, R10–R26 progress past) |
| Stages per realm | 9 stages (Mortal tier), 4–6 (Immortal+) | ✅ |
| EXP / breakthrough curve | Escalating EXP per stage/realm | ✅ Real values from reference |
| Lifespan & aging | Each realm grants more lifespan; death = rebirth at 18 | ✅ Real lifespan values, time-scaled aging |
| Seclusion (closed-door cultivation) | Spend years meditating for EXP | ✅ Full system with year-spinner UI |

## 2. Providence (the "roll your fate" system)

| TTP Element | Our status |
|---|---|
| Aptitude grades (Mortal → God) | ✅ Rebalanced with multi-stat **pros & cons** |
| Physique types | ✅ 6 physiques with pros/cons |
| Connate rarity (+lifespan) | ✅ 8 rarities |
| Dao Affinity | ✅ 8 Daos, each tied to a signature technique |
| Per-attribute rerolls | ✅ **5 free rerolls each** (was 2) |
| Great-roll celebration FX | ✅ Golden burst / glow on Epic+ |

## 3. Combat & Content

| TTP Element | Reference count | Our status |
|---|---|---|
| NPCs / Beasts | 90 (R1–R9) | ✅ All 90, real names/stats, **blocky-creature models** |
| Mutations | Chance-based stronger variants | ✅ |
| Bosses & boss-kill gate | 1 boss per realm | ✅ Required before breakthrough |
| Items | 236 | ✅ All 236 with parsed effects |
| Equipment | 63 (weapon/armor/accessory) | ✅ Paperdoll equip system |
| Techniques | 59 catalog | 🟡 Catalog in data; 9 active Dao skills wired to [Q] |
| Quests | 54 | ✅ All 54, realm/stage completion |
| Shop / Pills | Realm-scaled stock | ✅ Realm-adaptive catalog |
| Status Effects | 14 (buffs/debuffs) | 🟡 Data done; not yet applied in combat |

## 4. Heaven & Progression Systems

| TTP Element | Our status |
|---|---|
| Heaven Tribulation (R3–R9) | ✅ Lightning-wave survival gate, karma-scaled damage |
| Physique Evolution (4 stages) | ✅ Auto-upgrades on realm + total-EXP |
| Hidden Sects (4) | ✅ Join, sect-EXP from combat, milestone buffs |
| Karma System (7 tiers) | 🟡 Karma stat affects tribulation; tiers/events not yet wired |

## 5. Side Systems

| TTP Element | Reference detail | Status |
|---|---|---|
| Spirit Companions | 8 pets, bond levels, combat assist | ✅ Buy/summon, bond-EXP from combat, scaling buffs |
| Formations | 10 (passive/active combat arrays) | ✅ Buy/activate, one active, stat buffs |
| Dungeons | 5 instances, floors, cooldowns, loot | ✅ Enter/exit, floors, EXP/Stone mult, cooldowns |
| Titles & Achievements | 25 milestone titles with stat bonuses | ✅ Auto-unlock, equip, passive bonuses |
| Fate Events / Book of Misfortune | Random good/bad events by karma ~every 35s | ✅ Book of Fortune & Misfortune + event log |
| Karma System | 7 tiers, affects tribulation & fate | ✅ Tiers + karma drives fate/tribulation |
| Leaderboard & Rank Titles | 6 categories, top-3 bonuses | ✅ Live standings + #1 rank bonuses |
| PvP | Player-vs-player victories | ✅ Opt-in toggle + [G] duel nearest |
| Robux monetization | Developer Products + GamePasses | ✅ Store + ProcessReceipt (placeholder IDs) |
| Status-effect combat hooks | Apply the 14 effects in fights | ✅ DoT/HoT/control wired; Dao debuffs; HUD badges |
| Per-realm distinct worlds | Unique terrain/theme per realm | ✅ Hub + 9 bounded themed zones, gates, signs, bridges |
| Monster variety | Recognizable creatures | ✅ 7 archetypes by icon (serpent/dragon/avian/turtle/spirit/humanoid/quadruped) |

## 6. World & UX

| Element | Our status |
|---|---|
| Terrain | ✅ Bubblegum candy world (checkerboard, hills, lakes, islands) |
| Teleport between zones | ✅ World menu (🌀) + button |
| HUD (realm/EXP/HP/stats/providence) | ✅ Fully in English, overlap-fixed |
| Hover/press button feedback | ✅ |
| Inventory + Equipment paperdoll | ✅ |
| Language | ✅ All English |

---

### Rough completeness
- **Core loop + Providence + combat content:** ~90%
- **Heaven/progression systems:** ~80%
- **Side systems (companions/formations/dungeons/titles/fate/leaderboard/PvP/Robux):** ~85%
- **World, monsters, status effects, UI:** ~85%
- **Overall vs. full TTP reference:** ~85%

### Remaining polish
- Configure real Robux product/GamePass IDs in `RobuxService.lua`
- Optional: animate monsters / idle wandering
- Optional: richer per-realm zone decoration (themed props)
