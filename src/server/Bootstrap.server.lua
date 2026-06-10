--!strict
-- Bootstrap.server.lua
-- Start all services in the correct order.

local DataManager        = require(script.Parent.Services.DataManager)
local ProvidenceService  = require(script.Parent.Services.ProvidenceService)
local CultivationService = require(script.Parent.Services.CultivationService)
local SeclusionService   = require(script.Parent.Services.SeclusionService)
local CombatService      = require(script.Parent.Services.CombatService)
local TechniqueService   = require(script.Parent.Services.TechniqueService)
local ShopService        = require(script.Parent.Services.ShopService)
local QuestService       = require(script.Parent.Services.QuestService)
local TribulationService = require(script.Parent.Services.TribulationService)
local SectService        = require(script.Parent.Services.SectService)
local EquipmentService   = require(script.Parent.Services.EquipmentService)
local NPCService         = require(script.Parent.Services.NPCService)

-- Listener first, then DataManager (which fires ProfileLoaded)
ProvidenceService.Start()
CultivationService.Start()
SeclusionService.Start()
CombatService.Start()
TechniqueService.Start()
ShopService.Start()
QuestService.Start()
TribulationService.Start()
SectService.Start()
EquipmentService.Start()
NPCService.Start()

DataManager.Start()

print("[TTP] Server gestartet — alle Systeme aktiv.")
