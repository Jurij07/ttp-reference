--!strict
-- FateService.lua — "Book of Fortune & Misfortune"
-- Roughly every FATE_INTERVAL seconds, the Book turns a page and a fate event
-- befalls each active player. Good events need positive karma; bad events
-- strike when karma is low (Han Jue's signature luck system).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local FateEventData = require(GameData:WaitForChild("FateEventData"))
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local Buffs = require(ReplicatedStorage:WaitForChild("Buffs"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local FateService = {}

local fateEvent = Net.Event("FateEvent")
local FATE_INTERVAL = 35  -- seconds between pages

local function applyEffect(player: Player, profile: any, e: any)
	local CultivationService = require(script.Parent.CultivationService)
	local stageEXP = CultivationData.GetStageEXP(profile.realm, profile.stage)
	local realm = profile.realm or 1

	if e.effect == "exp_small" or e.effect == "exp_tiny" then
		CultivationService.AddEXP(player, math.floor(stageEXP * 0.5), true)
	elseif e.effect == "exp_med" then
		CultivationService.AddEXP(player, math.floor(stageEXP * 1.5), true)
	elseif e.effect == "exp_big" then
		CultivationService.AddEXP(player, math.floor(stageEXP * 4), true)
	elseif e.effect == "stones_tiny" then
		CultivationService.AddStones(player, 50 * realm)
	elseif e.effect == "stones_small" then
		CultivationService.AddStones(player, 200 * realm)
	elseif e.effect == "heal_full" then
		player:SetAttribute("HP", player:GetAttribute("MaxHP") or 1)
	elseif e.effect == "exp_buff" then
		Buffs.Apply(player, "Exp", 2.0, 300)
	elseif e.effect == "dmg_small" then
		local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
		local hp = (player:GetAttribute("HP") or 0) :: number
		player:SetAttribute("HP", math.max(1, hp - maxHP * 0.15))
	elseif e.effect == "dmg_big" then
		local maxHP = (player:GetAttribute("MaxHP") or 1) :: number
		local hp = (player:GetAttribute("HP") or 0) :: number
		player:SetAttribute("HP", math.max(1, hp - maxHP * 0.30))
	elseif e.effect == "exp_loss" then
		profile.exp = math.max(0, profile.exp - stageEXP * 0.25)
		player:SetAttribute("EXP", profile.exp)
	end
end

-- Trigger one fate event for the player right now.
function FateService.Trigger(player: Player)
	local profile = DataManager.Get(player)
	if not profile or player:GetAttribute("InMenu") or player:GetAttribute("InTribulation") then return end
	if player:GetAttribute("InSeclusion") then return end

	local e = FateEventData.Roll(profile.karma or 0)
	applyEffect(player, profile, e)

	local kindColor = e.kind == "GOOD" and "gold" or (e.kind == "BAD" and "warn" or "info")
	fateEvent:FireClient(player, e.icon, e.name, e.kind, e.desc)
	Net.Event("Notify"):FireClient(player, ("%s %s — %s"):format(e.icon, e.name, e.desc), kindColor)
end

function FateService.Start()
	-- fateEvent is already created at module load (pre-creates the remote).
	task.spawn(function()
		while true do
			task.wait(FATE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				-- slight per-player jitter so events don't all fire at once
				task.spawn(function()
					task.wait(math.random() * 4)
					FateService.Trigger(player)
				end)
			end
		end
	end)
end

return FateService
