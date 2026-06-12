# Top Tier Providence — Feature Comparison

**Legend:** ✅ Done · 🟡 Partial / data-only · ❌ Not started

This compares the main elements of *Top Tier Providence* (novel / manhwa + the
`index.html` game reference) against what our Roblox recreation currently has.

---

## 1. Core Cultivation Loop (Idle Game)

| TTP Element | What it is | Our status |
|---|---|---|
| 26 Cultivation Realms | Qi Refinement → Ultimate Origin Supreme | ✅ **All 26 fully playable** (zones, NPCs, bosses, hunts) |
| Stages per realm | 9 stages (Mortal tier), 4–6 (Immortal+) | ✅ |
| EXP / breakthrough curve | Escalating EXP per stage/realm | ✅ Real values from reference |
| Lifespan & aging | Each realm grants more lifespan; death = rebirth at 18 | ✅ Real lifespan values, time-scaled aging |
| Seclusion (closed-door cultivation) | Spend years meditating for EXP | ✅ Full system with year-spinner UI |
| Idle cultivation | EXP flows passively every second | ✅ Passive tick + stone trickle (IdleService) |
| Auto-Hunt | Pick a zone, fights resolve automatically | ✅ Simulated fights, auto boss challenges, all 26 realms |
| Offline progress | Gains while logged out | ✅ Capped 12h at 50% efficiency, "Welcome back" popup |
| Idle upgrades | Permanent speed-ups | ✅ Spirit Cave / Stone Vein / Swift Hunt (EnhancementService) |
| Daily missions | 3 rotating tasks per day | ✅ 10-task pool, seeded per player, jade bonus |

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
| NPCs / Beasts | 90 (R1–R9) | ✅ **260 total** — 90 from reference + 170 generated for R10–26 |
| Mutations | Chance-based stronger variants | ✅ |
| Bosses & boss-kill gate | 1 boss per realm | ✅ All 26 realms, required before breakthrough |
| Items | 236 | ✅ All 236 with parsed effects |
| Equipment | 63 (weapon/armor/accessory) | ✅ Paperdoll equip system |
| Techniques | 59 catalog | ✅ **All 59 learnable** — passives feed stats/EXP/stones, actives equippable on [Q] |
| Quests | 54 realm + NPC chains | ✅ 54 realm quests + **46 NPC quests in 7 chains across all 4 worlds** |
| Shop / Pills | Realm-scaled stock | ✅ Realm-adaptive catalog |
| Status Effects | 14 (buffs/debuffs) | ✅ DoT/HoT/control wired; Dao debuffs; HUD badges |

## 4. Currencies

| Currency | Earned from | Spent on |
|---|---|---|
| 💰 Spirit Stones | Idle trickle, hunts, quests, dailies | Shop, enhancements, techniques, sects, companions, formations |
| 💎 Immortal Jade | Tribulations, first boss kills, R10+ breakthroughs, dailies | Jade Bazaar (Fortune Charm, Stone Magnet, Time Talisman, Tribulation Ward) |
| ⚖️ Karma | Shrine prayers, fate events | Drives tribulation damage + fate outcomes |

## 5. Heaven & Progression Systems

| TTP Element | Our status |
|---|---|
| Heaven Tribulation (R3+) | ✅ Lightning-wave survival gate, karma-scaled damage, jade reward, ward item |
| Physique Evolution (4 stages) | ✅ Auto-upgrades on realm + total-EXP |
| Hidden Sects (4) | ✅ Join, sect-EXP from combat, milestone buffs |
| Karma System (7 tiers) | ✅ Tiers + karma drives fate/tribulation |

## 6. Side Systems

| TTP Element | Reference detail | Status |
|---|---|---|
| Spirit Companions | 8 pets, bond levels, combat assist | ✅ Buy/summon, bond-EXP from combat, scaling buffs |
| Formations | 10 (passive/active combat arrays) | ✅ Buy/activate, one active, stat buffs |
| Dungeons | 5 instances, floors, cooldowns, loot | ✅ Enter/exit, floors, EXP/Stone mult, cooldowns |
| Titles & Achievements | 25 milestone titles with stat bonuses | ✅ Auto-unlock, equip, passive bonuses |
| Fate Events / Book of Misfortune | Random good/bad events by karma ~every 35s | ✅ Book of Fortune & Misfortune + event log |
| Leaderboard & Rank Titles | 6 categories, top-3 bonuses | ✅ Live standings + #1 rank bonuses |
| PvP | Player-vs-player victories | ✅ Opt-in toggle + [G] duel nearest |
| Robux monetization | Developer Products + GamePasses | ✅ Store + ProcessReceipt (placeholder IDs) |
| Per-realm distinct worlds | Unique terrain/theme per realm | ✅ 26 themed floating-island zones across 4 stacked worlds |
| Monster variety | Recognizable creatures | ✅ 7 archetypes by icon (serpent/dragon/avian/turtle/spirit/humanoid/quadruped) |

## 7. Worlds & Places

| World | Y layer | Realms | Landmarks |
|---|---|---|---|
| 1 · Mortal Earth | 0 | R1–9 | Spawn Village, 9 realm islands, Netherworld, Yellow Spring, Hidden Sect Island, Wall of Eternity, shrines |
| 2 · Immortal Sky | 1800 | R10–15 | Heaven's Gate, Jade Palace City, 33-Layer Heaven, Qiankun Hall, 6 realm islands |
| 3 · Sage Heaven | 3600 | R16–22 | Mystic Divine Palace, Sage Seats, Supreme Platform, 7 realm islands |
| 4 · Primal Chaos | 5400 | R23–26 | Chaos Battlefield, Forbidden Zone, Blank Realm Edge, Origin Realm, 4 realm islands |

## 8. Questlines (NPC chains, sequential, max 3 active)

| Chain | Giver (location) | Steps | Arc |
|---|---|---|---|
| village_elder | Village Elder (W1 hub) | 6 | Beast culling around the village |
| cultivation_master | Cultivation Master (W1 hub) | 8 | Realm ascension R2 → R9 |
| merchant | Merchant (W1 hub) | 6 | Wealth: 2K → 1M lifetime stones |
| beast_hunter | Beast Hunter Lin (W1 hub) | 8 | Boss-trophy ladder R2 → R9 |
| immortal_envoy | Immortal Envoy (W2 arrival) | 6 | Immortal Sky R10 → R15 |
| sage_oracle | Sage Oracle (W3 arrival) | 7 | Sage Heaven R16 → R22 |
| chaos_warden | Chaos Warden (W4 arrival) | 5 | Endgame R23 → R26 finale |

## 9. UX & Assets

| Element | Our status |
|---|---|
| Terrain | ✅ Floating-island sky world (Baseplate-sized islands, 4 stacked worlds) |
| Teleport between zones | ✅ World menu (🌀) lists all 26 realms |
| HUD | ✅ Realm/EXP/HP/stats/providence + idle rate + currencies (💰💎⚖️) |
| Inventory | ✅ Character / Inventory / Quest Log / Daily tabs |
| Overlays | ✅ Shop, Sects, Hunt, Enhancements, Jade Bazaar, Technique Compendium, … |
| Icon set | ✅ 13 generated PNGs in `assets/icons/` (see `assets/README_ASSETS.md`) |
| Language | ✅ All English |

---

### Rough completeness
- **Core idle loop (passive, hunts, offline, upgrades, dailies):** ~100%
- **Content (26 realms, 260 NPCs, 100 quests, 59 techniques, 236 items):** ~95%
- **Side systems:** ~90%
- **Overall vs. full TTP reference:** ~95%

### Remaining polish
- Upload `assets/icons/*.png` as Decals and fill `IconAssets.lua`
- Configure real Robux product/GamePass IDs in `RobuxService.lua`
- Optional: animate monsters / idle wandering
- Optional: richer per-realm zone decoration for R10–26 (themed props)
