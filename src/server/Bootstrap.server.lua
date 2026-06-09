--!strict
-- Bootstrap.server.lua
-- Einstiegspunkt des Servers. Services in korrekter Reihenfolge starten.

local Services = script.Parent.Services

local DataManager       = require(Services.DataManager)
local ProvidenceService = require(Services.ProvidenceService)
local CultivationService = require(Services.CultivationService)
local SeclusionService  = require(Services.SeclusionService)
local CombatService     = require(Services.CombatService)
local TechniqueService  = require(Services.TechniqueService)
local ShopService       = require(Services.ShopService)
local QuestService      = require(Services.QuestService)
local NPCService        = require(Services.NPCService)

-- Listener zuerst verbinden, dann DataManager starten (löst ProfileLoaded aus).
ProvidenceService.Start()
CultivationService.Start()
SeclusionService.Start()
CombatService.Start()
TechniqueService.Start()
ShopService.Start()
QuestService.Start()
NPCService.Start()

DataManager.Start()

print("[TTP] Server gestartet — alle Systeme aktiv.")
