--!strict
-- RobuxService.lua
-- Robux monetization scaffold: Developer Products (consumable purchases) and
-- GamePasses (permanent perks). The IDs below are PLACEHOLDERS — replace them
-- with your real asset IDs from the Creator Dashboard before going live.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local DataManager = require(script.Parent.DataManager)

local RobuxService = {}

local notifyEvent = Net.Event("Notify")

-- ⚠️ Replace these with real IDs from the Roblox Creator Dashboard.
RobuxService.PRODUCTS = {
	[0] = { name = "1,000 Spirit Stones", grant = function(p) RobuxService.grantStones(p, 1000) end },
}
RobuxService.PRODUCT_LIST = {
	{ id = 0, name = "1,000 Spirit Stones",  icon = "💰", desc = "Instant 1,000 Spirit Stones." },
	{ id = 0, name = "Extra Reroll Pack",    icon = "🎲", desc = "+3 free rerolls per attribute." },
	{ id = 0, name = "10x EXP (1 hour)",     icon = "⚡", desc = "EXP ×10 for one hour." },
}
RobuxService.GAMEPASSES = {
	{ id = 0, name = "VIP — 2x EXP Forever", icon = "👑", desc = "Permanent +100% EXP." },
	{ id = 0, name = "Auto-Cultivate",       icon = "🤖", desc = "Cultivate while away." },
}

function RobuxService.grantStones(player: Player, amount: number)
	local CultivationService = require(script.Parent.CultivationService)
	CultivationService.AddStones(player, amount)
	notifyEvent:FireClient(player, ("💎 Purchase complete: +%d Spirit Stones!"):format(amount), "gold")
end

-- Prompt helpers (client fires these via remotes).
function RobuxService.PromptProduct(player: Player, productId: number)
	if productId and productId > 0 then
		MarketplaceService:PromptProductPurchase(player, productId)
	else
		notifyEvent:FireClient(player, "🛈 Store coming soon — product IDs not configured yet.", "info")
	end
end

function RobuxService.PromptPass(player: Player, passId: number)
	if passId and passId > 0 then
		MarketplaceService:PromptGamePassPurchase(player, passId)
	else
		notifyEvent:FireClient(player, "🛈 Store coming soon — GamePass IDs not configured yet.", "info")
	end
end

function RobuxService.Start()
	local promptProduct = Net.Event("PromptProduct")
	local promptPass    = Net.Event("PromptPass")
	promptProduct.OnServerEvent:Connect(function(player, id) RobuxService.PromptProduct(player, tonumber(id) or 0) end)
	promptPass.OnServerEvent:Connect(function(player, id) RobuxService.PromptPass(player, tonumber(id) or 0) end)

	-- Standard receipt handler for Developer Products.
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
		local prod = RobuxService.PRODUCTS[receiptInfo.ProductId]
		if prod then prod.grant(player) end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return RobuxService
