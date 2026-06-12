--!strict
-- JadeService.lua
-- Immortal Jade 💎: prestige currency plus the Jade Bazaar.
--   • AddJade / GetExpMult / GetStoneMult are consumed by other services.
--   • Permanent upgrades (Fortune Charm, Stone Magnet) multiply ALL exp /
--     stone gains via the CultivationService hooks.
--   • Consumables: Time Talisman (instant 2h idle gains), Tribulation Ward
--     (next tribulation −50% damage — read by TribulationService).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local JadeData = require(GameData:WaitForChild("JadeData"))
local CultivationData = require(GameData:WaitForChild("CultivationData"))

local DataManager = require(script.Parent.DataManager)

local JadeService = {}

local notifyEvent = Net.Event("Notify")

local function levels(profile: any): { [string]: number }
	if type(profile.jadeUpgrades) ~= "table" then profile.jadeUpgrades = {} end
	return profile.jadeUpgrades
end

-- ── Currency ─────────────────────────────────────────────────
function JadeService.AddJade(player: Player, amount: number)
	local profile = DataManager.Get(player)
	if not profile then return end
	profile.jade = math.max((profile.jade or 0) + amount, 0)
	if amount > 0 then
		profile.jadeLifetime = (profile.jadeLifetime or 0) + amount
		notifyEvent:FireClient(player, ("💎 +%d Immortal Jade"):format(amount), "gold")
	end
	player:SetAttribute("Jade", profile.jade)
end

-- ── Multipliers consumed by CultivationService ───────────────
function JadeService.GetExpMult(player: Player): number
	local profile = DataManager.Get(player)
	if not profile then return 1 end
	local item = JadeData.Get("fortune_charm")
	local lvl = (levels(profile)["fortune_charm"] or 0) :: number
	return 1 + lvl * (item and item.expBonus or 0)
end

function JadeService.GetStoneMult(player: Player): number
	local profile = DataManager.Get(player)
	if not profile then return 1 end
	local item = JadeData.Get("stone_magnet")
	local lvl = (levels(profile)["stone_magnet"] or 0) :: number
	return 1 + lvl * (item and item.stoneBonus or 0)
end

-- Tribulation Ward: consume the one-shot flag (TribulationService asks).
function JadeService.ConsumeTribulationWard(player: Player): boolean
	local profile = DataManager.Get(player)
	if profile and profile.tribulationWard then
		profile.tribulationWard = false
		return true
	end
	return false
end

local function syncBazaar(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	Net.Event("JadeBazaarSync"):FireClient(player, levels(profile), profile.tribulationWard == true)
end

-- ── Consumable effects ───────────────────────────────────────
local function useTimeTalisman(player: Player, profile: any)
	-- 2h of idle gains at full efficiency, at the player's current rates.
	local CultivationService = require(script.Parent.CultivationService)
	local stageExp = CultivationData.GetStageEXP(profile.realm, profile.stage)
	local expMult, stoneMult = 1, 1
	local okE, ES = pcall(require, script.Parent.EnhancementService)
	if okE then
		expMult = (ES :: any).GetExpMult(player)
		stoneMult = (ES :: any).GetStoneMult(player)
	end
	local secs = 7200
	local exp = math.floor(stageExp * Config.IDLE_STAGE_FRACTION_PER_SEC * expMult * secs)
	local stones = math.floor(Config.IDLE_STONES_PER_SEC_BASE * profile.realm * stoneMult * secs)
	CultivationService.AddEXP(player, exp, true)
	CultivationService.AddStones(player, stones)
	notifyEvent:FireClient(player,
		("⏳ Time Talisman: +%d EXP, +%d 💰 (2h folded into a breath)"):format(exp, stones), "gold")
end

-- ── Start ────────────────────────────────────────────────────
function JadeService.Start()
	Net.Event("JadeBazaarSync")

	Net.Event("BuyJadeItem").OnServerEvent:Connect(function(player: Player, idRaw: unknown)
		local id = tostring(idRaw)
		local item = JadeData.Get(id)
		if not item then return end
		local profile = DataManager.Get(player)
		if not profile then return end
		local jade = (profile.jade or 0) :: number

		if item.kind == "permanent" then
			local lv = levels(profile)
			local lvl = (lv[id] or 0) :: number
			if lvl >= (item.maxLevel or 1) then
				notifyEvent:FireClient(player, "🔒 Already at max level!", "warn"); return
			end
			local cost = JadeData.NextCost(item, lvl)
			if jade < cost then
				notifyEvent:FireClient(player, ("💎 Need %d Jade (have %d)."):format(cost, jade), "warn"); return
			end
			JadeService.AddJade(player, -cost)
			lv[id] = lvl + 1
			notifyEvent:FireClient(player,
				("%s %s upgraded to level %d!"):format(item.icon, item.name, lvl + 1), "gold")
		else
			local cost = item.cost or 0
			if jade < cost then
				notifyEvent:FireClient(player, ("💎 Need %d Jade (have %d)."):format(cost, jade), "warn"); return
			end
			if id == "tribulation_ward" then
				if profile.tribulationWard then
					notifyEvent:FireClient(player, "A ward is already inscribed.", "warn"); return
				end
				JadeService.AddJade(player, -cost)
				profile.tribulationWard = true
				notifyEvent:FireClient(player, "🛡️ Tribulation Ward inscribed — next tribulation −50% damage.", "gold")
			elseif id == "time_talisman" then
				JadeService.AddJade(player, -cost)
				useTimeTalisman(player, profile)
			end
		end
		syncBazaar(player)
	end)

	Net.Event("GetJadeBazaar").OnServerEvent:Connect(syncBazaar)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.delay(2, function()
			if not player.Parent then return end
			local profile = DataManager.Get(player)
			player:SetAttribute("Jade", profile and (profile.jade or 0) or 0)
			syncBazaar(player)
		end)
	end)

	print("[JadeService] Started — Immortal Jade + Jade Bazaar.")
end

return JadeService
