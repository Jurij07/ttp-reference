--!strict
-- CombatService.lua
-- Server-autoritatives Kampfsystem. Spieler klicken NPCs an (ClickDetector,
-- von NPCService gesetzt) → hier wird Schaden berechnet, Gegenangriff
-- ausgeführt und beim Tod des NPCs die Belohnung (EXP + Stones) vergeben.
-- Außerdem: langsame HP-Regeneration des Spielers außerhalb des Kampfes.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)
local CultivationService = require(script.Parent.CultivationService)

local CombatService = {}

local notifyEvent = Net.Event("Notify")
local hitEvent = Net.Event("CombatHit") -- für Client-Feedback (Schadenszahlen)

local NPC_COUNTERATTACK_COOLDOWN = 1.0 -- Sekunden zwischen Gegenangriffen eines NPCs

-- NPC schlägt zurück (mit Cooldown pro NPC).
local function npcCounterattack(player: Player, model: Model)
	local now = os.clock()
	local last = model:GetAttribute("LastCounter") or 0
	if now - last < NPC_COUNTERATTACK_COOLDOWN then
		return
	end
	model:SetAttribute("LastCounter", now)

	local npcDmg = model:GetAttribute("Damage") or 0
	local playerDef = player:GetAttribute("Defense") or 0
	local applied = math.max(npcDmg - playerDef, 1)

	local hp = (player:GetAttribute("HP") or 0) - applied
	if hp <= 0 then
		-- Spieler besiegt: voll heilen, sanfte Strafe (25% Stones).
		local maxHP = player:GetAttribute("MaxHP") or 1
		player:SetAttribute("HP", maxHP)
		local profile = DataManager.Get(player)
		if profile then
			local lost = math.floor(profile.spiritStones * 0.25)
			profile.spiritStones -= lost
			player:SetAttribute("SpiritStones", profile.spiritStones)
			notifyEvent:FireClient(player, ("💀 Besiegt! %d Spirit Stones verloren."):format(lost), "warn")
		end
	else
		player:SetAttribute("HP", hp)
	end
end

-- Belohnt den Spieler für einen NPC-Kill.
local function rewardKill(player: Player, model: Model)
	local exp = model:GetAttribute("EXP") or 0
	local stones = model:GetAttribute("Stones") or 0
	CultivationService.AddEXP(player, exp)
	CultivationService.AddStones(player, stones)
	CultivationService.AddKill(player)

	local name = model:GetAttribute("NPCName") or model.Name
	notifyEvent:FireClient(player, ("⚔️ %s besiegt! +%d EXP, +%d Stones"):format(name, exp, stones), "good")
end

-- Wird vom ClickDetector aufgerufen, wenn ein Spieler einen NPC anklickt.
function CombatService.PlayerAttackNPC(player: Player, model: Model)
	-- Im Menü oder beim Meditieren kann nicht angegriffen werden.
	if player:GetAttribute("InMenu") or player:GetAttribute("Meditating") then
		return
	end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return -- schon tot
	end

	-- Distanz-Check (Nahkampf-Reichweite, Anti-Cheat).
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local prim = model.PrimaryPart
	local maxDist = Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER
	if root and prim and (root.Position - prim.Position).Magnitude > maxDist then
		return
	end

	local dmg = player:GetAttribute("Damage") or 10
	local npcDef = model:GetAttribute("Defense") or 0
	local applied = math.max(dmg - npcDef, 1)

	hum.Health = math.max(hum.Health - applied, 0)
	hitEvent:FireClient(player, model:GetAttribute("NPCName") or model.Name, applied)

	if hum.Health <= 0 then
		rewardKill(player, model)
	else
		npcCounterattack(player, model)
	end
end

function CombatService.Start()
	-- Langsame HP-Regeneration außerhalb des Kampfes.
	local accum = 0
	RunService.Heartbeat:Connect(function(dt)
		accum += dt
		if accum < 0.5 then
			return
		end
		local step = accum
		accum = 0
		for _, player in ipairs(Players:GetPlayers()) do
			local maxHP = player:GetAttribute("MaxHP")
			local hp = player:GetAttribute("HP")
			if maxHP and hp and hp < maxHP then
				player:SetAttribute("HP", math.min(hp + maxHP * 0.05 * step, maxHP))
			end
		end
	end)
end

return CombatService
