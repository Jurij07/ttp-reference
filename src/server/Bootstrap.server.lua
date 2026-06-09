--!strict
-- Bootstrap.server.lua
-- Einstiegspunkt des Servers. Services in korrekter Reihenfolge starten.

local DataManager       = require(script.Parent.Services.DataManager)
local ProvidenceService = require(script.Parent.Services.ProvidenceService)
local CultivationService = require(script.Parent.Services.CultivationService)
local SeclusionService  = require(script.Parent.Services.SeclusionService)
local CombatService     = require(script.Parent.Services.CombatService)
local NPCService        = require(script.Parent.Services.NPCService)

-- Listener zuerst verbinden, dann DataManager starten (der ProfileLoaded auslöst)
ProvidenceService.Start()
CultivationService.Start()
SeclusionService.Start()
CombatService.Start()
NPCService.Start()

DataManager.Start()

print("[TTP] Server gestartet — alle Systeme aktiv.")
