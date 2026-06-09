--!strict
-- Config.lua
-- Globale Spiel-Konfiguration. Liegt in ReplicatedStorage und ist von Server
-- und Client lesbar. Hier zentral alle "Stellschrauben" des Spiels.

local Config = {}

-- ── DataStore ──────────────────────────────────────────────
Config.DATASTORE_NAME = "TTP_PlayerData_v1"
Config.AUTOSAVE_INTERVAL = 120 -- Sekunden zwischen automatischen Saves
Config.USE_DATASTORE = true     -- false = nur In-Memory (zum Testen ohne API-Zugriff)

-- ── Meditation (passives EXP-Farmen) ───────────────────────
-- Anteil der für die aktuelle Stage benötigten EXP, der pro Sekunde
-- durch Meditation gewonnen wird (vor Aptitude-Multiplikator).
Config.MEDITATION_FRACTION_PER_SEC = 0.02 -- ~50s pro Stage bei Average Aptitude

-- ── Lifespan (Alterung) ────────────────────────────────────
-- Wie viele "Lebensjahre" pro echter Sekunde vergehen. Sehr niedrig halten,
-- sonst sterben Testspieler zu schnell. 0 = Alterung aus.
Config.LIFESPAN_DECAY_PER_SEC = 0.05
Config.LIFESPAN_ENABLED = true

-- ── Combat ─────────────────────────────────────────────────
Config.NPC_RESPAWN_TIME = 6        -- Sekunden bis ein getöteter NPC neu spawnt
Config.MAX_ATTACK_DISTANCE = 60    -- Maximale Distanz für einen gültigen Treffer

-- ── Spawn-Bereich für NPCs ─────────────────────────────────
Config.NPC_SPAWN_ORIGIN = Vector3.new(0, 4, 30) -- Mittelpunkt des Spawn-Felds
Config.NPC_SPAWN_SPREAD = 14                     -- Abstand zwischen NPCs

-- ── Start-Werte für neue Spieler ───────────────────────────
Config.STARTING_SPIRIT_STONES = 100
Config.STARTING_KARMA = 0
Config.FREE_REROLLS_PER_ATTRIBUTE = 5

return Config
