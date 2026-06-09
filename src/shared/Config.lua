--!strict
-- Config.lua

local Config = {}

-- ── DataStore ──────────────────────────────────────────────
Config.DATASTORE_NAME    = "TTP_PlayerData_v4"
Config.AUTOSAVE_INTERVAL = 120
Config.USE_DATASTORE     = true

-- ── Zeitskala: 1 Spieljahr = 10 Echtminuten ───────────────
Config.REAL_SECS_PER_GAME_YEAR = 600
Config.LIFESPAN_DECAY_PER_SEC  = 1 / 600
Config.STARTING_AGE            = 18
Config.LIFESPAN_ENABLED        = true

-- ── Klausur (Seclusion) ────────────────────────────────────
Config.SECLUSION_SECS_PER_YEAR   = 120   -- 1 Klausurjahr = 2 Echtminuten
Config.SECLUSION_EXP_PER_YEAR    = 3     -- × aktuelle Stage-EXP
Config.SECLUSION_STONES_PER_YEAR = 80
Config.SECLUSION_CANCEL_FACTOR   = 0.70

-- ── Kampf ──────────────────────────────────────────────────
Config.NPC_RESPAWN_TIME    = 6
Config.ATTACK_RANGE        = 12
Config.ATTACK_RANGE_BUFFER = 6
Config.ATTACK_COOLDOWN     = 0.8   -- Sekunden zwischen Angriffen (kein Spam)

-- ── NPC-Spawn ──────────────────────────────────────────────
Config.NPC_SPAWN_ORIGIN = Vector3.new(-70, 4, 60)
Config.NPC_SPAWN_SPREAD = 16

-- ── Providence / Rerolls ───────────────────────────────────
Config.FREE_REROLLS_PER_ATTR = 2

-- ── Start-Werte ────────────────────────────────────────────
Config.STARTING_SPIRIT_STONES = 100
Config.STARTING_KARMA         = 0

--[[
  GESCHÄTZTE SPIELZEIT (Durchschnittliche Aptitude ×1.0, reines Spielen)
  ──────────────────────────────────────────────────────────────────────
  Grundannahmen:
  • Jede Stage dauert via Klausur ~40 Echtsek. (0.33 Jahre × 2 min/Jahr)
  • Boss-Kill: ~2-5 Min extra (Combat mit 0.8s Cooldown)
  • Realmwechsel nur nach Boss-Kill möglich

  Realm 1  Qi Refinement       (9 Stages)  ~10 Min    kumulativ: ~10 Min
  Realm 2  Foundation Est.     (9 Stages)  ~12 Min    kumulativ: ~22 Min
  Realm 3  Golden Core         (9 Stages)  ~14 Min    kumulativ: ~36 Min
  Realm 4  Nascent Soul        (9 Stages)  ~16 Min    kumulativ: ~52 Min
  Realm 5  Soul Formation      (9 Stages)  ~20 Min    kumulativ: ~72 Min
  Realm 6  Void Amalgamation   (9 Stages)  ~25 Min    kumulativ: ~97 Min
  Realm 7  Body Integration    (9 Stages)  ~30 Min    kumulativ: ~127 Min
  Realm 8  Tribulation Trans.  (9 Stages)  ~35 Min    kumulativ: ~162 Min
  Realm 9  Mahayana            (9 Stages)  ~40 Min    kumulativ: ~202 Min
  Realm 10-15 Immortal-Tiers   (4 Stages)  ~20 Min je kumulativ: ~322 Min
  Realm 16 Immortal Emperor    (9 Stages)  ~40 Min    kumulativ: ~362 Min
  Realm 17-23 Deity/Zenith/Sage (4-6 St.) ~25 Min je kumulativ: ~537 Min
  Realm 24-26 Dao Creator+     (1-4 St.)  ~30 Min je kumulativ: ~627 Min

  GESAMT: ~10 Stunden (Average Aptitude)
  God Aptitude (×10 EXP): ~1 Stunde
  Mortal Aptitude (×0.5 EXP): ~20 Stunden
]]

return Config
