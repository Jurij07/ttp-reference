--!strict
-- Bootstrap.server.lua
-- Einstiegspunkt des Servers. Startet alle Services in der richtigen Reihenfolge.
-- Liegt direkt in ServerScriptService und läuft automatisch beim Server-Start.

local DataManager = require(script.Parent.Services.DataManager)
local ProvidenceService = require(script.Parent.Services.ProvidenceService)
local CultivationService = require(script.Parent.Services.CultivationService)
local CombatService = require(script.Parent.Services.CombatService)
local NPCService = require(script.Parent.Services.NPCService)

-- Zuerst die Services starten, die auf das Profil-Laden REAGIEREN
-- (sie verbinden sich mit DataManager.ProfileLoaded)...
ProvidenceService.Start()
CultivationService.Start()
CombatService.Start()
NPCService.Start()

-- ...und ZULETZT den DataManager, der das Laden auslöst. So sind alle
-- Listener bereits verbunden, bevor das erste Profil feuert.
DataManager.Start()

print("[TTP] Server gestartet — alle Systeme aktiv.")
