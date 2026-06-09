--!strict
-- Config.lua
-- Alle Spielparameter zentral. In ReplicatedStorage (Server + Client lesbar).

local Config = {}

-- ── DataStore ──────────────────────────────────────────────
Config.DATASTORE_NAME    = "TTP_PlayerData_v4"
Config.AUTOSAVE_INTERVAL = 120
Config.USE_DATASTORE     = true

-- ── Alterung / Zeitskala ───────────────────────────────────
-- 1 Spieljahr = REAL_SECS_PER_GAME_YEAR echte Sekunden (Standard: 10 Minuten)
Config.REAL_SECS_PER_GAME_YEAR = 600   -- 600 s = 10 Echtminuten
-- Ergibt sich direkt daraus (benutzt im Heartbeat):
Config.LIFESPAN_DECAY_PER_SEC  = 1 / 600  -- ≈ 0.001667 Jahre/s
Config.STARTING_AGE            = 18
Config.LIFESPAN_ENABLED        = true

-- ── Klausur / Seclusion ────────────────────────────────────
-- Seclusion ist beschleunigtes Kultivieren — "Tür zu, Jahre vergehen".
-- 1 Klausurjahr kostet SECLUSION_SECS_PER_YEAR echte Sekunden (Standard: 2 min).
Config.SECLUSION_SECS_PER_YEAR    = 120   -- 1 Klausurjahr = 2 Echtminuten (5× schneller)
-- EXP-Ertrag pro Klausurjahr als Vielfaches der aktuellen Stage-EXP
Config.SECLUSION_EXP_PER_YEAR     = 3     -- 3 Stage-Fortschritte pro Klausurjahr
-- Spirit Stones pro Klausurjahr
Config.SECLUSION_STONES_PER_YEAR  = 80
-- Effizienz bei vorzeitigem Abbruch (70 % der proportionalen Belohnung)
Config.SECLUSION_CANCEL_FACTOR    = 0.70

-- ── Providence / Rerolls ───────────────────────────────────
-- Jedes der 4 Attribute hat eigene kostenlose Rerolls im Startmenü.
-- Nach Bestätigung sind KEINE weiteren freien Rerolls möglich (nur Robux).
Config.FREE_REROLLS_PER_ATTR = 2

-- ── Combat ─────────────────────────────────────────────────
Config.NPC_RESPAWN_TIME    = 6
Config.ATTACK_RANGE        = 12
Config.ATTACK_RANGE_BUFFER = 6
Config.ATTACK_COOLDOWN     = 0.8

-- ── NPC-Spawn ──────────────────────────────────────────────
Config.NPC_SPAWN_ORIGIN = Vector3.new(0, 4, 60)
Config.NPC_SPAWN_SPREAD = 16

-- ── Start-Werte ────────────────────────────────────────────
Config.STARTING_SPIRIT_STONES = 100
Config.STARTING_KARMA         = 0

return Config
