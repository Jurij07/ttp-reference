--!strict
-- TechniqueService.lua
-- Aktive Dao-Technik (Taste Q / HUD-Button). Trifft den nächsten Gegner in
-- Reichweite, verursacht (dmgMult × ATK) Schaden, dann Abklingzeit.
-- Cooldown wird serverseitig validiert und als Attribut "TechCooldownUntil"
-- (os.clock-basiert) für die Client-Anzeige repliziert.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local TechniqueData = require(GameData:WaitForChild("TechniqueData"))
local Net   = require(ReplicatedStorage:WaitForChild("Net"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))

local DataManager   = require(script.Parent.DataManager)
local CombatService = require(script.Parent.CombatService)

local TechniqueService = {}

local notifyEvent = Net.Event("Notify")

-- Letzter Technik-Einsatz je Spieler (os.clock).
local lastUse: { [number]: number } = {}

-- Findet den nächsten lebenden NPC in Angriffsreichweite.
local function nearestNPC(player: Player): Model?
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return nil end

	local npcFolder = workspace:FindFirstChild("NPCs")
	if not npcFolder then return nil end

	local maxDist = Config.ATTACK_RANGE + Config.ATTACK_RANGE_BUFFER
	local best: Model? = nil
	local bestDist = maxDist

	for _, model in ipairs(npcFolder:GetChildren()) do
		if model:IsA("Model") and model.PrimaryPart then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local d = (root.Position - model.PrimaryPart.Position).Magnitude
				if d <= bestDist then
					best = model
					bestDist = d
				end
			end
		end
	end
	return best
end

function TechniqueService.UseTechnique(player: Player)
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end

	local dao  = player:GetAttribute("DaoAffinity")
	local tech = dao and TechniqueData.GetForDao(dao)
	if not tech then return end

	-- Cooldown prüfen
	local now = os.clock()
	if now < (lastUse[player.UserId] or 0) then
		return -- noch in Abklingzeit
	end

	local target = nearestNPC(player)
	if not target then
		notifyEvent:FireClient(player, "🎯 Kein Gegner in Reichweite!", "warn")
		return
	end

	-- Cooldown setzen + replizieren
	lastUse[player.UserId] = now + tech.cooldown
	player:SetAttribute("TechCooldown", tech.cooldown)
	player:SetAttribute("TechCooldownUntil", os.time() + tech.cooldown)

	-- Schaden (× DMG-Buff)
	local atk = (player:GetAttribute("Damage") or 10) * Buffs.GetMult(player, "Dmg")
	local raw = atk * tech.dmgMult
	CombatService.DealDamage(player, target, raw, true)

	-- Heileffekt (z.B. Life-Dao)
	if tech.healFrac then
		local maxHP = player:GetAttribute("MaxHP") or 1
		local hp    = player:GetAttribute("HP") or maxHP
		player:SetAttribute("HP", math.min(maxHP, hp + maxHP * tech.healFrac))
	end

	-- Feedback an Client (für Effekt-Anzeige)
	Net.Event("TechniqueUsed"):FireClient(player, tech.name, tech.icon)
end

function TechniqueService.Start()
	Net.Event("TechniqueUsed") -- pre-create

	Players.PlayerRemoving:Connect(function(player)
		lastUse[player.UserId] = nil
	end)

	local useEvent = Net.Event("UseTechnique")
	useEvent.OnServerEvent:Connect(function(player)
		TechniqueService.UseTechnique(player)
	end)
end

return TechniqueService
