--!strict
-- UIController.client.lua
-- HUD, Providence menu, Seclusion, Shop, Quests, Inventory, Techniques.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local Net          = require(ReplicatedStorage:WaitForChild("Net"))
local GameData     = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData  = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))
local ItemData      = require(GameData:WaitForChild("ItemData"))
local QuestData     = require(GameData:WaitForChild("QuestData"))
local TechniqueCatalog = require(GameData:WaitForChild("TechniqueCatalog"))

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════════
-- Theme
-- ════════════════════════════════════════════════════════════
local C = {
	bg0    = Color3.fromHex("030407"),
	bg1    = Color3.fromHex("07090F"),
	bg2    = Color3.fromHex("0B0E19"),
	bg3    = Color3.fromHex("101420"),
	bg4    = Color3.fromHex("161B2D"),
	bg5    = Color3.fromHex("1C2238"),
	border = Color3.fromHex("252C4A"),
	gold   = Color3.fromHex("F5C542"),
	t1     = Color3.fromHex("EEF0FF"),
	t2     = Color3.fromHex("A8B2D8"),
	t3     = Color3.fromHex("5C6488"),
	a1     = Color3.fromHex("6C7EF8"),
	exp    = Color3.fromHex("A855F7"),
	hp     = Color3.fromHex("F87171"),
	green  = Color3.fromHex("34D399"),
	cyan   = Color3.fromHex("67E8F9"),
	warn   = Color3.fromHex("FB923C"),
}

local RARITY = {
	Common   = Color3.fromHex("9CA3AF"), Uncommon = Color3.fromHex("4ADE80"),
	Rare     = Color3.fromHex("60A5FA"), Epic     = Color3.fromHex("A78BFA"),
	Legendary= Color3.fromHex("FBBF24"), Mythic   = Color3.fromHex("F87171"),
	Divine   = Color3.fromHex("FCD34D"), Immortal = Color3.fromHex("67E8F9"),
	Chaos    = Color3.fromHex("F9A8D4"),
}

local QTYPE_COLOR = {
	TUTORIAL     = Color3.fromHex("34D399"),
	STORY        = Color3.fromHex("60A5FA"),
	DAILY        = Color3.fromHex("FBBF24"),
	WEEKLY       = Color3.fromHex("FB923C"),
	ACHIEVEMENT  = Color3.fromHex("A78BFA"),
	SECRET       = Color3.fromHex("F87171"),
	BREAKTHROUGH = Color3.fromHex("F5C542"),
	SOCIAL       = Color3.fromHex("67E8F9"),
}

-- ════════════════════════════════════════════════════════════
-- Helpers
-- ════════════════════════════════════════════════════════════
local function fmt(n: number?): string
	if not n then return "0" end
	local abs = math.abs(n)
	if abs >= 1e12 then return ("%.2fT"):format(n/1e12)
	elseif abs >= 1e9  then return ("%.2fB"):format(n/1e9)
	elseif abs >= 1e6  then return ("%.2fM"):format(n/1e6)
	elseif abs >= 1e3  then return ("%.1fK"):format(n/1e3)
	else return tostring(math.floor(n)) end
end

local function corner(p: Instance, r: number?)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end

local function stroke(p: Instance, col: Color3?)
	local s = Instance.new("UIStroke"); s.Color = col or C.border; s.Thickness = 1; s.Parent = p
end

local function mkLabel(parent: Instance, text: string, size: UDim2, pos: UDim2,
		col: Color3, ts: number, font: Enum.Font?, xAlign: Enum.TextXAlignment?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = size; l.Position = pos
	l.Text = text; l.TextColor3 = col; l.TextSize = ts
	l.Font = font or Enum.Font.Gotham
	l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.Parent = parent
	return l
end

local function mkPanel(name: string, size: UDim2, pos: UDim2, anchor: Vector2, parent: Instance): Frame
	local f = Instance.new("Frame")
	f.Name = name; f.Size = size; f.Position = pos; f.AnchorPoint = anchor
	f.BackgroundColor3 = C.bg2; f.BackgroundTransparency = 0.08
	corner(f, 10); stroke(f)
	f.Parent = parent
	return f
end

local function mkBar(parent: Instance, fillColor: Color3, pos: UDim2, h: number): Frame
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -24, 0, h); bg.Position = pos
	bg.BackgroundColor3 = C.bg4; bg.BorderSizePixel = 0
	corner(bg, 5); bg.Parent = parent
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1); fill.BackgroundColor3 = fillColor
	fill.BorderSizePixel = 0; corner(fill, 5); fill.Parent = bg
	return fill
end

local function mkButton(parent: Instance, text: string, size: UDim2, pos: UDim2,
		col: Color3, anchor: Vector2?): TextButton
	local b = Instance.new("TextButton")
	b.Size = size; b.Position = pos
	if anchor then b.AnchorPoint = anchor end
	b.BackgroundColor3 = col; b.Text = text
	b.TextColor3 = C.t1; b.TextSize = 14; b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = true; corner(b, 8); b.Parent = parent
	return b
end

local function mkScrollList(parent: Instance, size: UDim2, pos: UDim2): (ScrollingFrame, UIListLayout)
	local sf = Instance.new("ScrollingFrame")
	sf.Size = size; sf.Position = pos
	sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
	sf.ScrollBarThickness = 4; sf.ScrollBarImageColor3 = C.bg5
	sf.CanvasSize = UDim2.new(); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.Parent = parent
	local ll = Instance.new("UIListLayout")
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Padding = UDim.new(0, 4)
	ll.Parent = sf
	return sf, ll
end

local function bindAttr(name: string, fn: (any)->())
	player:GetAttributeChangedSignal(name):Connect(function() fn(player:GetAttribute(name)) end)
	fn(player:GetAttribute(name))
end

local function formatTime(secs: number): string
	secs = math.max(0, math.floor(secs))
	local m = math.floor(secs / 60); local s = secs % 60
	return ("%02d:%02d"):format(m, s)
end

-- ════════════════════════════════════════════════════════════
-- ScreenGui + Root frames
-- ════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TTP_HUD"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local hudRoot = Instance.new("Frame"); hudRoot.Name = "HUD"
hudRoot.Size = UDim2.fromScale(1,1); hudRoot.BackgroundTransparency = 1
hudRoot.Visible = false; hudRoot.Parent = gui

local menuRoot = Instance.new("Frame"); menuRoot.Name = "ProvidenceMenu"
menuRoot.Size = UDim2.fromScale(1,1); menuRoot.BackgroundColor3 = C.bg0
menuRoot.BackgroundTransparency = 0.05; menuRoot.Visible = false; menuRoot.Parent = gui

local function mkOverlay(name: string): Frame
	local f = Instance.new("Frame"); f.Name = name
	f.Size = UDim2.fromScale(1,1); f.BackgroundColor3 = C.bg0
	f.BackgroundTransparency = 0.3; f.Visible = false; f.Parent = gui
	return f
end

local mainMenuLayer  = mkOverlay("MainMenuLayer")
local inventoryLayer = mkOverlay("InventoryLayer")
local shopLayer      = mkOverlay("ShopLayer")
local questLayer     = mkOverlay("QuestLayer")
local sectLayer      = mkOverlay("SectLayer")
local SectData       = require(GameData:WaitForChild("SectData"))

-- Vorwärts-Deklaration (Definition weiter unten bei den Button-Bindungen).
local closeAllOverlays: () -> ()

-- ════════════════════════════════════════════════════════════
-- ── HUD ──────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════
local realmPanel = mkPanel("RealmPanel", UDim2.new(0,300,0,142), UDim2.new(0,14,0,14), Vector2.new(0,0), hudRoot)
local realmNameL = mkLabel(realmPanel,"Qi Refinement",UDim2.new(1,-20,0,22),UDim2.new(0,12,0,8),C.gold,17,Enum.Font.GothamBold)
local stageL     = mkLabel(realmPanel,"Stage 1 / 9",  UDim2.new(1,-20,0,16),UDim2.new(0,12,0,32),C.t2,12)
local expFill    = mkBar(realmPanel, C.exp, UDim2.new(0,12,0,56), 12)
local expText    = mkLabel(realmPanel,"0 / 0 EXP",    UDim2.new(1,-20,0,14),UDim2.new(0,12,0,72),C.t3,11,nil,Enum.TextXAlignment.Center)
local lifeL      = mkLabel(realmPanel,"⏳ Alter —",   UDim2.new(1,-20,0,14),UDim2.new(0,12,0,90),C.green,12)
local atkL       = mkLabel(realmPanel,"⚔️ ATK —",     UDim2.new(1,-20,0,14),UDim2.new(0,12,0,110),C.t3,11)
local defL       = mkLabel(realmPanel,"🛡️ DEF —",     UDim2.new(0.5,-16,0,14),UDim2.new(0.5,4,0,110),C.t3,11)

local statPanel = mkPanel("StatPanel", UDim2.new(0,192,0,88), UDim2.new(1,-14,0,14), Vector2.new(1,0), hudRoot)
local stonesL   = mkLabel(statPanel,"💰 0",          UDim2.new(1,-20,0,22),UDim2.new(0,12,0,8), C.gold,15,Enum.Font.GothamBold)
local karmaL    = mkLabel(statPanel,"⚖️ Karma: 0",   UDim2.new(1,-20,0,15),UDim2.new(0,12,0,36),C.t2,12)
local killsL    = mkLabel(statPanel,"⚔️ Kills: 0",   UDim2.new(1,-20,0,15),UDim2.new(0,12,0,56),C.t2,12)

local provPanel = mkPanel("ProvPanel", UDim2.new(0,192,0,112), UDim2.new(1,-14,0,110), Vector2.new(1,0), hudRoot)
mkLabel(provPanel,"🎲 PROVIDENCE",UDim2.new(1,-20,0,12),UDim2.new(0,12,0,6),C.t3,10,Enum.Font.GothamBold)
local hAptL  = mkLabel(provPanel,"🌟 —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,24),C.t1,12)
local hPhysL = mkLabel(provPanel,"💪 —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,42),C.t1,12)
local hConnL = mkLabel(provPanel,"🎭 —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,60),C.t1,12)
local hDaoL  = mkLabel(provPanel,"☯️ —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,78),C.t1,12)

local hpPanel = mkPanel("HPPanel", UDim2.new(0,380,0,52), UDim2.new(0.5,0,1,-90), Vector2.new(0.5,1), hudRoot)
local hpFill  = mkBar(hpPanel, C.hp, UDim2.new(0,12,0,26), 16)
local hpText  = mkLabel(hpPanel,"HP 0 / 0",UDim2.new(1,-24,0,18),UDim2.new(0,12,0,4),C.t1,13,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

-- Technique cooldown bar (above HP panel)
local techPanel = mkPanel("TechPanel", UDim2.new(0,380,0,34), UDim2.new(0.5,0,1,-130), Vector2.new(0.5,1), hudRoot)
local techFill  = mkBar(techPanel, C.a1, UDim2.new(0,12,0,10), 10)
local techLabel = mkLabel(techPanel,"[Q] Technik bereit",UDim2.new(1,-24,0,14),UDim2.new(0,12,0,0),C.t3,10,nil,Enum.TextXAlignment.Center)

local seclPanel = mkPanel("SeclPanel", UDim2.new(0,215,0,90), UDim2.new(0,14,1,-14), Vector2.new(0,1), hudRoot)
local seclBtn   = mkButton(seclPanel,"🧘 Klausur betreten",UDim2.new(1,-16,0,36),UDim2.new(0,8,0,8),C.a1)
local seclStatus = mkLabel(seclPanel,"Klausur: Inaktiv",UDim2.new(1,-16,0,16),UDim2.new(0,8,0,50),C.t3,11)
local seclTimer  = mkLabel(seclPanel,"",UDim2.new(1,-16,0,16),UDim2.new(0,8,0,68),C.cyan,11,Enum.Font.GothamBold)

-- Bottom-right buttons
local invBtn      = mkButton(hudRoot,"🎒",UDim2.new(0,46,0,46),UDim2.new(1,-14,1,-14),  C.bg4,Vector2.new(1,1))
local shopBtn     = mkButton(hudRoot,"🏪",UDim2.new(0,46,0,46),UDim2.new(1,-66,1,-14),  C.bg4,Vector2.new(1,1))
local questBtn    = mkButton(hudRoot,"📜",UDim2.new(0,46,0,46),UDim2.new(1,-118,1,-14), C.bg4,Vector2.new(1,1))
local sectBtn     = mkButton(hudRoot,"🏯",UDim2.new(0,46,0,46),UDim2.new(1,-170,1,-14), C.bg4,Vector2.new(1,1))
local mainMenuBtn = mkButton(hudRoot,"≡", UDim2.new(0,38,0,38),UDim2.new(1,-14,0,14),   C.bg4,Vector2.new(1,0))

local seclAbortBtn = mkButton(hudRoot,"⚠️ Klausur abbrechen (−30%)",
	UDim2.new(0,240,0,36), UDim2.new(0,14,1,-68), C.hp, Vector2.new(0,1))
seclAbortBtn.Visible = false

-- ════════════════════════════════════════════════════════════
-- ── Seclusion popup
-- ════════════════════════════════════════════════════════════
local seclPopup = mkPanel("SeclPopup",UDim2.new(0,320,0,230),UDim2.new(0.5,0,1,-136),Vector2.new(0.5,1), hudRoot)
seclPopup.Visible = false; seclPopup.ZIndex = 10
mkLabel(seclPopup,"🧘  KLAUSUR BETRETEN",UDim2.new(1,-20,0,20),UDim2.new(0,10,0,10),C.gold,15,Enum.Font.GothamBold)

local seclYearsValue = 1
local spinnerRow = Instance.new("Frame"); spinnerRow.Size = UDim2.new(1,-20,0,36)
spinnerRow.Position = UDim2.new(0,10,0,40); spinnerRow.BackgroundTransparency=1; spinnerRow.Parent = seclPopup
local yearMinusBtn = mkButton(spinnerRow,"−",UDim2.new(0,36,0,36),UDim2.fromOffset(0,0),C.bg5)
local yearLabel    = mkLabel(spinnerRow,"1 Jahr",UDim2.new(1,-80,1,0),UDim2.fromOffset(42,0),C.t1,16,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
yearLabel.TextYAlignment = Enum.TextYAlignment.Center
local yearPlusBtn  = mkButton(spinnerRow,"＋",UDim2.new(0,36,0,36),UDim2.new(1,-36,0,0),C.bg5)
local seclPreviewEXP    = mkLabel(seclPopup,"⚡ EXP: —",      UDim2.new(1,-20,0,16),UDim2.new(0,10,0,88), C.exp,12)
local seclPreviewStones = mkLabel(seclPopup,"💰 Stones: —",   UDim2.new(1,-20,0,16),UDim2.new(0,10,0,108),C.gold,12)
local seclPreviewAge    = mkLabel(seclPopup,"⏳ Altert um: —", UDim2.new(1,-20,0,16),UDim2.new(0,10,0,128),C.warn,12)
local seclPreviewTime   = mkLabel(seclPopup,"🕑 Echtzeit: —",  UDim2.new(1,-20,0,16),UDim2.new(0,10,0,148),C.t2,12)
local seclConfirmBtn    = mkButton(seclPopup,"✓ Klausur starten",UDim2.new(1,-20,0,36),UDim2.new(0,10,1,-46),C.green)
local seclCancelPopup   = mkButton(seclPopup,"✕ Abbrechen",      UDim2.new(1,-20,0,20),UDim2.new(0,10,1,-22),C.bg4)

-- ════════════════════════════════════════════════════════════
-- ── Main Menu overlay
-- ════════════════════════════════════════════════════════════
local mainMenuCard = mkPanel("Card",UDim2.new(0,320,0,240),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), mainMenuLayer)
mkLabel(mainMenuCard,"HAUPTMENÜ",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,16),C.gold,20,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local closeMainMenu = mkButton(mainMenuCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5); closeMainMenu.TextSize = 16
local mmItems = {
	{ text="📖 Providence ansehen", y=56 },
	{ text="🏪 Shop",               y=104 },
	{ text="📜 Quests",             y=152 },
	{ text="🔄 Spiel verlassen",    y=200 },
}
local mmButtons: { TextButton } = {}
for _, item in ipairs(mmItems) do
	local b = mkButton(mainMenuCard, item.text, UDim2.new(1,-30,0,40), UDim2.fromOffset(15, item.y), C.bg4)
	b.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(mmButtons, b)
end

-- ════════════════════════════════════════════════════════════
-- ── Inventory overlay
-- ════════════════════════════════════════════════════════════
local invCard = mkPanel("InvCard",UDim2.new(0,540,0,480),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), inventoryLayer)
mkLabel(invCard,"🎒  INVENTAR",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeInv = mkButton(invCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)

local invList, _ = mkScrollList(invCard, UDim2.new(1,-20,1,-60), UDim2.fromOffset(10,52))

local function rebuildInventory(inventory: {[any]: any})
	-- Clear existing
	for _, c in ipairs(invList:GetChildren()) do
		if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
	end

	local hasItems = false
	for rawId, count in pairs(inventory) do
		local itemId = tonumber(rawId)
		if not itemId or count <= 0 then continue end
		local item = ItemData.GetItem(itemId)
		if not item then continue end
		hasItems = true

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1,0,0,52); row.BackgroundColor3 = C.bg3
		row.BorderSizePixel = 0; corner(row, 6); stroke(row, C.border)
		row.Parent = invList

		local rarCol = RARITY[item.rarity] or C.t1
		mkLabel(row, item.icon .. "  " .. item.name, UDim2.new(0.6,0,0,22), UDim2.fromOffset(8,6), rarCol, 13, Enum.Font.GothamBold)
		mkLabel(row, item.rarity, UDim2.new(0.3,0,0,16), UDim2.fromOffset(8,28), rarCol, 10)
		mkLabel(row, "×" .. tostring(count), UDim2.new(0,40,0,22), UDim2.new(0.6,0,0,6), C.t2, 14, Enum.Font.GothamBold, Enum.TextXAlignment.Right)

		if ItemData.IsUsable(item) then
			local useBtn = mkButton(row, "Verwenden", UDim2.new(0,90,0,28), UDim2.new(1,-98,0,12), C.green)
			useBtn.TextSize = 12
			local thisId = itemId
			useBtn.MouseButton1Click:Connect(function()
				Net.Event("UseItem"):FireServer(thisId)
			end)
		else
			mkLabel(row, item.itype, UDim2.new(0,90,0,20), UDim2.new(1,-98,0,16), C.t3, 10, nil, Enum.TextXAlignment.Center)
		end
	end

	if not hasItems then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,0,0,40); empty.BackgroundTransparency = 1
		empty.Text = "— Inventar leer —"; empty.TextColor3 = C.t3
		empty.TextSize = 13; empty.Font = Enum.Font.Gotham
		empty.TextXAlignment = Enum.TextXAlignment.Center
		empty.Parent = invList
	end
end

-- ════════════════════════════════════════════════════════════
-- ── Shop overlay
-- ════════════════════════════════════════════════════════════
local shopCard = mkPanel("ShopCard",UDim2.new(0,560,0,500),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), shopLayer)
mkLabel(shopCard,"🏪  SHOP — Spirit Stone Händler",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeShop = mkButton(shopCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
local shopStoneL = mkLabel(shopCard,"💰 —",UDim2.new(0,160,0,20),UDim2.new(1,-180,0,20),C.gold,13,Enum.Font.GothamBold,Enum.TextXAlignment.Right)

local shopList, _ = mkScrollList(shopCard, UDim2.new(1,-20,1,-68), UDim2.fromOffset(10,60))

-- Build shop items once
task.spawn(function()
	task.wait(0.1) -- wait for ItemData to be ready
	local buyRemote = Net.Event("BuyItem")
	local order = 0
	for _, item in ipairs(ItemData.ITEMS) do
		if not ItemData.IsBuyable(item) then continue end
		if item.itype ~= "consumable" and item.itype ~= "scroll" then continue end
		order += 1
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,56); row.BackgroundColor3 = C.bg3
		row.BorderSizePixel = 0; corner(row,6); stroke(row,C.border)
		row.Parent = shopList

		local rarCol = RARITY[item.rarity] or C.t1
		mkLabel(row, item.icon .. "  " .. item.name, UDim2.new(0.55,0,0,22), UDim2.fromOffset(8,4), rarCol, 13, Enum.Font.GothamBold)
		mkLabel(row, item.desc, UDim2.new(0.7,0,0,14), UDim2.fromOffset(8,28), C.t3, 10)
		mkLabel(row, "💰 " .. tostring(item.cost), UDim2.new(0,80,0,20), UDim2.new(0.7,-8,0,6), C.gold, 13, Enum.Font.GothamBold, Enum.TextXAlignment.Right)

		local buyBtn = mkButton(row,"Kaufen",UDim2.new(0,70,0,32),UDim2.new(1,-78,0,12),C.a1)
		buyBtn.TextSize = 12
		local thisId = item.id
		buyBtn.MouseButton1Click:Connect(function()
			buyRemote:FireServer(thisId)
		end)
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Quest overlay
-- ════════════════════════════════════════════════════════════
local questCard = mkPanel("QuestCard",UDim2.new(0,580,0,520),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), questLayer)
mkLabel(questCard,"📜  QUESTS",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeQuest = mkButton(questCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)

local questList, _ = mkScrollList(questCard, UDim2.new(1,-20,1,-52), UDim2.fromOffset(10,44))

-- Quest state cache
local questState: {[number]: {complete: boolean, claimed: boolean}} = {}

local function reqText(q: any): string
	local parts = {}
	table.insert(parts, "Realm " .. tostring(q.reqRealm))
	if q.reqStage then table.insert(parts, "Stage " .. tostring(q.reqStage)) end
	if q.reqConfirmed then table.insert(parts, "Providence ✓") end
	return table.concat(parts, " · ")
end

local function rebuildQuests()
	for _, c in ipairs(questList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local claimRemote = Net.Event("ClaimQuest")
	local order = 0

	for _, q in ipairs(QuestData.QUESTS) do
		order += 1
		local qs = questState[q.id] or { complete = false, claimed = false }

		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,60); row.BorderSizePixel = 0
		row.BackgroundColor3 = qs.claimed and C.bg3 or (qs.complete and Color3.fromHex("0D1F16") or C.bg3)
		corner(row,6); stroke(row, qs.complete and (qs.claimed and C.border or C.green) or C.border)
		row.Parent = questList

		local qtypeCol = QTYPE_COLOR[q.qtype] or C.t2
		mkLabel(row, q.qtype, UDim2.new(0,80,0,14), UDim2.fromOffset(8,4), qtypeCol, 9, Enum.Font.GothamBold)
		mkLabel(row, q.name, UDim2.new(0.55,0,0,20), UDim2.fromOffset(8,18), C.t1, 13, Enum.Font.GothamBold)
		mkLabel(row, reqText(q), UDim2.new(0.5,0,0,14), UDim2.fromOffset(8,40), C.t3, 10)

		-- Rewards
		local rewStr = ""
		if q.rewardExp > 0 then rewStr = rewStr .. "+EXP " end
		if q.rewardStones > 0 then rewStr = rewStr .. "💰" .. fmt(q.rewardStones) end
		mkLabel(row, rewStr, UDim2.new(0.3,0,0,16), UDim2.new(0.65,0,0,10), C.gold, 11, nil, Enum.TextXAlignment.Right)

		if qs.claimed then
			mkLabel(row,"✓ Abgeholt",UDim2.new(0,88,0,28),UDim2.new(1,-96,0,16),C.t3,11,nil,Enum.TextXAlignment.Center)
		elseif qs.complete then
			local claimBtn = mkButton(row,"Abholen",UDim2.new(0,88,0,28),UDim2.new(1,-96,0,16),C.green)
			claimBtn.TextSize = 12
			local thisId = q.id
			claimBtn.MouseButton1Click:Connect(function()
				claimRemote:FireServer(thisId)
			end)
		else
			mkLabel(row,"⏳ Offen",UDim2.new(0,88,0,28),UDim2.new(1,-96,0,16),C.t3,11,nil,Enum.TextXAlignment.Center)
		end
	end
end

Net.Event("QuestSync").OnClientEvent:Connect(function(syncData: any)
	for qid, qs in pairs(syncData) do
		questState[tonumber(qid) :: number] = qs
	end
	if questLayer.Visible then
		rebuildQuests()
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Sect overlay
-- ════════════════════════════════════════════════════════════
local sectCard = mkPanel("SectCard",UDim2.new(0,580,0,520),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), sectLayer)
mkLabel(sectCard,"🏯  HIDDEN SECTS",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeSect = mkButton(sectCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
local sectStatusL = mkLabel(sectCard,"Keine Sekte beigetreten",UDim2.new(1,-30,0,18),UDim2.fromOffset(15,40),C.t2,12)

local sectList, _ = mkScrollList(sectCard, UDim2.new(1,-20,1,-72), UDim2.fromOffset(10,64))

local joinSectRemote = Net.Event("JoinSect")
local currentSectId: string? = nil
local currentSectLevel = 0

local function rebuildSects()
	for _, c in ipairs(sectList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	local playerRealm = (player:GetAttribute("Realm") or 1) :: number
	local order = 0
	for _, sect in ipairs(SectData.SECTS) do
		order += 1
		local joined = currentSectId == sect.id
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,118); row.BorderSizePixel = 0
		row.BackgroundColor3 = joined and Color3.fromHex("121E2E") or C.bg3
		corner(row,6); stroke(row, joined and C.gold or C.border)
		row.Parent = sectList

		mkLabel(row, sect.icon .. "  " .. sect.name, UDim2.new(0.7,0,0,20), UDim2.fromOffset(10,8), C.t1, 14, Enum.Font.GothamBold)
		mkLabel(row, sect.desc, UDim2.new(1,-20,0,28), UDim2.fromOffset(10,30), C.t3, 11)
		mkLabel(row, ("Realm %d erforderlich · Max Level %d"):format(sect.reqRealm, sect.maxLevel),
			UDim2.new(1,-20,0,14), UDim2.fromOffset(10,60), C.t2, 10)

		-- Milestone preview
		local msParts = {}
		for _, m in ipairs(sect.milestones) do
			table.insert(msParts, ("L%d: %s"):format(m.level, m.name))
		end
		mkLabel(row, table.concat(msParts, "  ·  "), UDim2.new(1,-20,0,14), UDim2.fromOffset(10,76), C.a1, 9)

		if joined then
			mkLabel(row, ("✓ Beigetreten — Level %d"):format(currentSectLevel),
				UDim2.new(0,200,0,28), UDim2.new(0,10,0,90), C.gold, 12, Enum.Font.GothamBold)
		elseif playerRealm >= sect.reqRealm then
			local joinBtn = mkButton(row,"Beitreten",UDim2.new(0,110,0,30),UDim2.new(1,-120,0,82),C.a1)
			joinBtn.TextSize = 12
			local thisId = sect.id
			joinBtn.MouseButton1Click:Connect(function() joinSectRemote:FireServer(thisId) end)
		else
			mkLabel(row, ("🔒 Realm %d nötig"):format(sect.reqRealm),
				UDim2.new(0,140,0,28), UDim2.new(1,-150,0,90), C.t3, 11, nil, Enum.TextXAlignment.Center)
		end
	end
end

Net.Event("SectSync").OnClientEvent:Connect(function(data: any)
	currentSectId = data.sectId
	currentSectLevel = data.level or 0
	if data.sectName then
		sectStatusL.Text = ("Sekte: %s · Level %d · %s (EXP %d/%d)"):format(
			data.sectName, data.level or 0, data.buffName or "—",
			math.floor(data.exp or 0), math.floor(data.expNeeded or 0))
		sectStatusL.TextColor3 = C.gold
	else
		sectStatusL.Text = "Keine Sekte beigetreten"
		sectStatusL.TextColor3 = C.t2
	end
	if sectLayer.Visible then rebuildSects() end
end)

-- ════════════════════════════════════════════════════════════
-- ── Heaven Tribulation overlay
-- ════════════════════════════════════════════════════════════
local tribLayer = Instance.new("Frame"); tribLayer.Name = "TribulationLayer"
tribLayer.Size = UDim2.fromScale(1,1); tribLayer.BackgroundColor3 = Color3.fromHex("0A0612")
tribLayer.BackgroundTransparency = 0.35; tribLayer.Visible = false
tribLayer.ZIndex = 40; tribLayer.Parent = gui

local tribTitle = mkLabel(tribLayer,"⚡ HEAVEN TRIBULATION",UDim2.new(1,0,0,40),UDim2.fromScale(0,0.28),
	Color3.fromHex("C4B5FD"),30,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
tribTitle.ZIndex = 41
local tribName = mkLabel(tribLayer,"",UDim2.new(1,0,0,26),UDim2.fromScale(0,0.36),
	C.gold,18,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
tribName.ZIndex = 41
local tribWaveL = mkLabel(tribLayer,"",UDim2.new(1,0,0,24),UDim2.fromScale(0,0.45),
	C.t1,16,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
tribWaveL.ZIndex = 41
local tribHint = mkLabel(tribLayer,"Überlebe alle Wellen! Nutze Heil-Pillen [I] zum Heilen.",
	UDim2.new(1,0,0,20),UDim2.fromScale(0,0.52),C.t2,13,nil,Enum.TextXAlignment.Center)
tribHint.ZIndex = 41

local function flashLightning()
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1,1); flash.BackgroundColor3 = Color3.fromHex("E9D5FF")
	flash.BackgroundTransparency = 0.3; flash.ZIndex = 45; flash.Parent = tribLayer
	local tw = TweenService:Create(flash, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
	tw:Play(); tw.Completed:Connect(function() flash:Destroy() end)
end

Net.Event("TribulationStarted").OnClientEvent:Connect(function(name: string, waves: number)
	tribLayer.Visible = true
	tribName.Text = name
	tribWaveL.Text = ("Welle 0 / %d"):format(waves)
	closeAllOverlays()
end)

Net.Event("TribulationWave").OnClientEvent:Connect(function(wave: number, waves: number, dmg: number)
	tribWaveL.Text = ("Welle %d / %d   (−%s HP)"):format(wave, waves, fmt(dmg))
	flashLightning()
end)

Net.Event("TribulationEnded").OnClientEvent:Connect(function(success: boolean)
	tribLayer.Visible = false
	if success then
		showToast("✨ Tribulation überstanden — Durchbruch!", "gold")
	else
		showToast("💀 Tribulation gescheitert! Heile dich und brich erneut durch.", "warn")
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Providence start menu
-- ════════════════════════════════════════════════════════════
local mContainer = Instance.new("Frame")
mContainer.Size = UDim2.fromScale(0.94, 0.90)
mContainer.Position = UDim2.fromScale(0.5, 0.5)
mContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mContainer.BackgroundTransparency = 1
mContainer.Parent = menuRoot

mkLabel(mContainer,"🎲  PROVIDENCE — Würfle dein Schicksal",
	UDim2.new(1,0,0,32), UDim2.fromOffset(0,0), C.gold, 24, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
mkLabel(mContainer,"Diese 4 Attribute bestimmen dein gesamtes Leben. Du startest mit Alter 18.",
	UDim2.new(1,0,0,18), UDim2.fromOffset(0,36), C.t2, 13, nil, Enum.TextXAlignment.Center)

local rollCard = mkPanel("RollCard", UDim2.new(0.44,0,1,-68), UDim2.fromOffset(0,62), Vector2.new(0,0), mContainer)
local scrollLeft, _ = mkScrollList(rollCard, UDim2.new(1,-12,1,-12), UDim2.fromOffset(6,6))
local llPad = Instance.new("UIPadding"); llPad.PaddingLeft=UDim.new(0,8); llPad.PaddingRight=UDim.new(0,8); llPad.PaddingBottom=UDim.new(0,8); llPad.Parent=scrollLeft

local ATTR_ORDER = { "aptitude", "physique", "connate", "dao" }
local ATTR_LABEL = { aptitude="🌟 APTITUDE", physique="💪 PHYSIQUE", connate="🎭 CONNATE", dao="☯️ DAO AFFINITY" }
local attrBlocks: { [string]: { nameLabel: TextLabel, subLabel: TextLabel, prosLabel: TextLabel, consLabel: TextLabel, rerollBtn: TextButton } } = {}

local rerollAttrRemote = Net.Event("RerollAttr")

for i, attrName in ipairs(ATTR_ORDER) do
	local block = Instance.new("Frame"); block.LayoutOrder = i
	block.Size = UDim2.new(1,0,0,105); block.BackgroundColor3 = C.bg3
	block.BorderSizePixel = 0; corner(block,8); stroke(block,C.border)
	block.Parent = scrollLeft

	mkLabel(block, ATTR_LABEL[attrName], UDim2.new(1,-100,0,16), UDim2.fromOffset(10,8), C.t3, 10, Enum.Font.GothamBold)
	local nameL = mkLabel(block,"—",UDim2.new(1,-110,0,22),UDim2.fromOffset(10,26),C.t1,18,Enum.Font.GothamBlack)
	local subL  = mkLabel(block,"...",UDim2.new(1,-110,0,14),UDim2.fromOffset(10,52),C.t2,11); subL.TextWrapped = true
	local prosL = mkLabel(block,"Pros: ...",UDim2.new(1,-110,0,12),UDim2.fromOffset(10,70),C.green,10); prosL.TextWrapped = true
	local consL = mkLabel(block,"Cons: ...",UDim2.new(1,-110,0,12),UDim2.fromOffset(10,85),C.hp,10);   consL.TextWrapped = true
	local rerollBtn = mkButton(block,"🎲 (2)",UDim2.new(0,85,0,28),UDim2.new(1,-95,0,10),C.a1); rerollBtn.TextSize = 12
	rerollBtn.MouseButton1Click:Connect(function() rerollAttrRemote:FireServer(attrName) end)
	attrBlocks[attrName] = { nameLabel=nameL, subLabel=subL, prosLabel=prosL, consLabel=consL, rerollBtn=rerollBtn }
end

local confirmBtn = mkButton(scrollLeft,"✓ Providence bestätigen & Spiel beginnen",UDim2.new(1,0,0,50),UDim2.fromOffset(0,0),C.green)
confirmBtn.LayoutOrder = 10; confirmBtn.TextSize = 16; confirmBtn.Font = Enum.Font.GothamBold

local infoCard = mkPanel("InfoCard", UDim2.new(0.54,0,1,-68), UDim2.new(0.46,0,0,62), Vector2.new(0,0), mContainer)
local scrollR, _ = mkScrollList(infoCard, UDim2.new(1,-12,1,-12), UDim2.fromOffset(6,6))
local rlPad = Instance.new("UIPadding"); rlPad.PaddingLeft=UDim.new(0,8); rlPad.PaddingRight=UDim.new(0,8); rlPad.Parent=scrollR

local rowOrder = 0
local function infoRow(text: string, col: Color3, ts: number, font: Enum.Font?, gap: number?)
	rowOrder += 1
	local r = Instance.new("TextLabel"); r.LayoutOrder = rowOrder
	r.Size = UDim2.new(1,0,0,ts+6+(gap or 0))
	r.BackgroundTransparency=1; r.Text=text; r.TextColor3=col
	r.TextSize=ts; r.Font=font or Enum.Font.Gotham
	r.TextXAlignment=Enum.TextXAlignment.Left
	r.TextYAlignment=Enum.TextYAlignment.Bottom
	r.RichText=true; r.TextWrapped=true
	r.Parent=scrollR
end

infoRow("🌟  APTITUDE — EXP-Multiplikator",C.gold,14,Enum.Font.GothamBold)
for _, g in ipairs(AptitudeData.GRADES) do
	local col = RARITY[g.rarity] or C.t1
	infoRow(('<b>%s</b>  ×%.1f  <font color="#5C6488">%.1f%%</font>'):format(g.name,g.mult,g.chance),col,12)
end

infoRow("💪  PHYSIQUE — Körper-Typ",C.gold,14,Enum.Font.GothamBold,10)
for _, p in ipairs(ProvidenceData.PHYSIQUES) do
	infoRow(('<b><font color="#%s">%s</font></b>  <font color="#5C6488">%s  %.0f%%</font>'):format(p.color,p.name,p.role,p.chance), Color3.fromHex(p.color),12)
	infoRow('<font color="#34D399">✓ ' .. p.pros .. '</font>', C.green, 11)
	infoRow('<font color="#F87171">✗ ' .. p.cons .. '</font>', C.hp, 11)
end

infoRow("🎭  CONNATE — Seltenheit & Lebensspanne",C.gold,14,Enum.Font.GothamBold,10)
for _, c in ipairs(ProvidenceData.CONNATES) do
	local col = RARITY[c.name] or C.t1
	infoRow(('<b>%s</b>  <font color="#5C6488">%.1f%%</font>'):format(c.name, c.chance), col, 12)
	if c.pros ~= "—" and c.pros ~= "" then infoRow('<font color="#34D399">✓ ' .. c.pros .. '</font>', C.green, 11) end
	if c.cons ~= "—" and c.cons ~= "" then infoRow('<font color="#F87171">✗ ' .. c.cons .. '</font>', C.hp, 11) end
end

infoRow("☯️  DAO AFFINITY — Dao-Neigung",C.gold,14,Enum.Font.GothamBold,10)
for _, d in ipairs(ProvidenceData.DAO_DATA) do
	infoRow(('<b><font color="#%s">%s Dao</font></b>  <font color="#5C6488">%s</font>'):format(d.color,d.name,d.desc), Color3.fromHex(d.color), 12)
end

-- ════════════════════════════════════════════════════════════
-- ── Toasts
-- ════════════════════════════════════════════════════════════
local toastHolder = Instance.new("Frame")
toastHolder.Size=UDim2.new(0,440,1,0); toastHolder.Position=UDim2.new(0.5,0,0,14)
toastHolder.AnchorPoint=Vector2.new(0.5,0); toastHolder.BackgroundTransparency=1
toastHolder.Parent=gui; toastHolder.ZIndex=50
local toastLayout=Instance.new("UIListLayout"); toastLayout.Padding=UDim.new(0,5)
toastLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center; toastLayout.Parent=toastHolder

local toastColors = { good=C.green, warn=C.hp, gold=C.gold, info=C.a1 }
local function showToast(message: string, kind: string?)
	local t = Instance.new("TextLabel")
	t.Size=UDim2.new(0,440,0,34); t.BackgroundColor3=C.bg3
	t.Text=message; t.TextColor3=toastColors[kind or "info"] or C.t1
	t.TextSize=13; t.Font=Enum.Font.GothamBold; t.TextWrapped=true
	corner(t,8); stroke(t,toastColors[kind or "info"] or C.border); t.Parent=toastHolder
	task.delay(3.5, function()
		local tw = TweenService:Create(t,TweenInfo.new(0.4),{BackgroundTransparency=1,TextTransparency=1})
		tw:Play(); tw.Completed:Wait(); t:Destroy()
	end)
end

-- ════════════════════════════════════════════════════════════
-- ── HUD attribute bindings
-- ════════════════════════════════════════════════════════════
bindAttr("RealmName", function(v) realmNameL.Text = v or "—" end)

local function updateStage()
	stageL.Text = ("Stage %d / %d  ·  %s"):format(
		player:GetAttribute("Stage") or 1, player:GetAttribute("MaxStage") or 9,
		player:GetAttribute("Tier") or "")
end
bindAttr("Stage", updateStage); bindAttr("MaxStage", updateStage); bindAttr("Tier", updateStage)

local function updateEXP()
	local exp = player:GetAttribute("EXP") or 0
	local needed = player:GetAttribute("EXPNeeded") or 1
	local ratio = math.clamp(exp / math.max(needed,1), 0, 1)
	TweenService:Create(expFill, TweenInfo.new(0.25), { Size=UDim2.fromScale(ratio,1) }):Play()
	expText.Text = ("%s / %s EXP  (%.0f%%)"):format(fmt(exp), fmt(needed), ratio*100)
end
bindAttr("EXP", updateEXP); bindAttr("EXPNeeded", updateEXP)

local function updateHP()
	local hp = player:GetAttribute("HP") or 0
	local maxHP = player:GetAttribute("MaxHP") or 1
	local ratio = math.clamp(hp / math.max(maxHP,1), 0, 1)
	TweenService:Create(hpFill, TweenInfo.new(0.2), { Size=UDim2.fromScale(ratio,1) }):Play()
	hpText.Text = ("HP  %s / %s"):format(fmt(hp), fmt(maxHP))
end
bindAttr("HP", updateHP); bindAttr("MaxHP", updateHP)

local function updateAge()
	if player:GetAttribute("LifespanInfinite") then
		lifeL.Text = "⏳ Alter: ∞ (unsterblich)"; lifeL.TextColor3 = C.cyan; return
	end
	local age = player:GetAttribute("Age") or 18
	local maxLife = player:GetAttribute("MaxLifespan") or 85
	local ratio = age / math.max(maxLife,1)
	lifeL.Text = ("⏳ Alter %s / %s"):format(fmt(age), fmt(maxLife))
	lifeL.TextColor3 = ratio > 0.85 and C.hp or (ratio > 0.65 and C.warn or C.green)
end
bindAttr("Age", updateAge); bindAttr("MaxLifespan", updateAge); bindAttr("LifespanInfinite", updateAge)

bindAttr("ATK",     function(v) atkL.Text = ("⚔️ ATK %s"):format(fmt(v)) end)
bindAttr("Defense", function(v) defL.Text = ("🛡️ DEF %s"):format(fmt(v)) end)
bindAttr("SpiritStones", function(v)
	stonesL.Text = "💰 " .. fmt(v)
	shopStoneL.Text = "💰 " .. fmt(v)
end)
bindAttr("Karma",      function(v) karmaL.Text = "⚖️ Karma: " .. tostring(math.floor(v or 0)) end)
bindAttr("TotalKills", function(v) killsL.Text = "⚔️ Kills: " .. tostring(v or 0) end)

bindAttr("Aptitude", function(v)
	local g = v and AptitudeData.GetByName(v)
	hAptL.Text = "🌟 " .. (v or "—"); hAptL.TextColor3 = (g and RARITY[g.rarity]) or C.t1
end)
local function updatePhysiqueLabel()
	local v = player:GetAttribute("Physique")
	local p = v and ProvidenceData.GetPhysique(v)
	local stage = player:GetAttribute("PhysiqueStage") or 1
	hPhysL.Text = ("💪 %s (Stufe %d)"):format(v or "—", stage)
	hPhysL.TextColor3 = p and Color3.fromHex(p.color) or C.t1
end
bindAttr("Physique", updatePhysiqueLabel)
bindAttr("PhysiqueStage", updatePhysiqueLabel)
bindAttr("Connate", function(v)
	hConnL.Text = "🎭 " .. (v or "—"); hConnL.TextColor3 = (v and RARITY[v]) or C.t1
end)
bindAttr("DaoAffinity", function(v)
	local d = v and ProvidenceData.GetDaoData(v)
	hDaoL.Text = "☯️ " .. (v or "—"); hDaoL.TextColor3 = d and Color3.fromHex(d.color) or C.t1
end)

bindAttr("InMenu", function(v)
	if v == nil then return end
	menuRoot.Visible = (v == true)
	hudRoot.Visible  = (v ~= true)
end)

-- ── Technique cooldown display ──────────────────────────────
local techCooldownEnd = 0
task.spawn(function()
	while true do
		task.wait(0.1)
		local remaining = math.max(0, techCooldownEnd - os.time())
		if remaining > 0 then
			local total = (player:GetAttribute("TechCooldownDuration") or 6) :: number
			local ratio = remaining / total
			techFill.Size = UDim2.fromScale(1 - ratio, 1)
			techLabel.Text = ("[Q] %s — %.1fs"):format(
				(player:GetAttribute("TechName") or "Technik"),
				remaining)
		else
			techFill.Size = UDim2.fromScale(1, 1)
			techLabel.Text = "[Q] Technik bereit"
		end
	end
end)

Net.Event("TechniqueUsed").OnClientEvent:Connect(function(techName: string, cooldown: number)
	player:SetAttribute("TechName", techName)
	player:SetAttribute("TechCooldownDuration", cooldown)
	techCooldownEnd = os.time() + cooldown
	showToast(("✨ %s eingesetzt!"):format(techName), "gold")
end)

-- ════════════════════════════════════════════════════════════
-- ── Seclusion bindings + popup
-- ════════════════════════════════════════════════════════════
local seclusionCountdown = 0
local inSeclusionLocal = false

bindAttr("InSeclusion", function(v)
	inSeclusionLocal = v == true
	seclBtn.Visible      = not inSeclusionLocal
	seclAbortBtn.Visible = inSeclusionLocal
	seclPopup.Visible    = false
	if inSeclusionLocal then
		seclStatus.Text = "🧘 In Klausur"; seclStatus.TextColor3 = C.cyan
	else
		seclStatus.Text = "Klausur: Inaktiv"; seclStatus.TextColor3 = C.t3
		seclTimer.Text = ""; seclusionCountdown = 0
	end
end)

local function getMaxSeclYears(): number
	local maxLife = player:GetAttribute("MaxLifespan") or 85
	local age     = player:GetAttribute("Age")         or 18
	return math.max(1, math.floor(maxLife - age - 1))
end

local function updateSeclPreview()
	local years = seclYearsValue
	yearLabel.Text = years == 1 and "1 Jahr" or (tostring(years) .. " Jahre")
	seclPreviewEXP.Text    = ("⚡ EXP: ~%d Stufen-Fortschritte"):format(years * 3)
	seclPreviewStones.Text = ("💰 Stones: +%d"):format(years * 80)
	seclPreviewAge.Text    = ("⏳ Altert um: %d %s"):format(years, years==1 and "Jahr" or "Jahre")
	seclPreviewTime.Text   = ("🕑 Echtzeit: ~%d Min."):format(math.ceil(years * 120 / 60))
end

seclBtn.MouseButton1Click:Connect(function()
	if inSeclusionLocal then return end
	seclYearsValue = 1; updateSeclPreview(); seclPopup.Visible = true
end)
seclCancelPopup.MouseButton1Click:Connect(function() seclPopup.Visible = false end)
yearMinusBtn.MouseButton1Click:Connect(function() seclYearsValue = math.max(1, seclYearsValue-1); updateSeclPreview() end)
yearPlusBtn.MouseButton1Click:Connect(function() seclYearsValue = math.min(getMaxSeclYears(), seclYearsValue+1); updateSeclPreview() end)

local startSeclusionRemote  = Net.Event("StartSeclusion")
local cancelSeclusionRemote = Net.Event("CancelSeclusion")
seclConfirmBtn.MouseButton1Click:Connect(function() seclPopup.Visible = false; startSeclusionRemote:FireServer(seclYearsValue) end)
seclAbortBtn.MouseButton1Click:Connect(function() cancelSeclusionRemote:FireServer() end)

Net.Event("SeclusionStarted").OnClientEvent:Connect(function(durationSec: number, years: number)
	seclusionCountdown = durationSec
	seclStatus.Text = ("🧘 Klausur: %d %s"):format(years, years==1 and "Jahr" or "Jahre")
end)

Net.Event("SeclusionFinished").OnClientEvent:Connect(function(expGained: number, stonesGained: number, years: number, canceled: boolean)
	local prefix = canceled and "⚠️ Abgebrochen" or "✅ Abgeschlossen"
	showToast(("%s — +%d EXP, +%d Stones, +%d Jahre"):format(prefix, expGained, stonesGained, years), canceled and "warn" or "gold")
end)

task.spawn(function()
	while true do
		task.wait(1)
		if seclusionCountdown > 0 then
			seclusionCountdown -= 1
			seclTimer.Text = "⏱ " .. formatTime(seclusionCountdown) .. " verbleibend"
		end
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Providence menu attribute blocks
-- ════════════════════════════════════════════════════════════
local REROLL_ATTR_FOR_BLOCK = { aptitude="Rerolls_Aptitude", physique="Rerolls_Physique", connate="Rerolls_Connate", dao="Rerolls_Dao" }
local ATTR_PLAYER_NAME = { aptitude="Aptitude", physique="Physique", connate="Connate", dao="DaoAffinity" }

local function updateAttrBlock(attrName: string)
	local block   = attrBlocks[attrName]
	local rerolls = (player:GetAttribute(REROLL_ATTR_FOR_BLOCK[attrName]) or 0) :: number
	block.rerollBtn.Text = rerolls > 0 and ("🎲 (%d)"):format(rerolls) or "🔒"
	block.rerollBtn.BackgroundColor3 = rerolls > 0 and C.a1 or C.bg4
	block.rerollBtn.Active = rerolls > 0

	if attrName == "aptitude" then
		local v = player:GetAttribute("Aptitude") :: string?
		local g = v and AptitudeData.GetByName(v)
		block.nameLabel.Text = v or "—"; block.nameLabel.TextColor3 = (g and RARITY[g.rarity]) or C.t1
		block.subLabel.Text = g and ("EXP ×%.1f  |  %s  |  %.1f%% Chance"):format(g.mult, g.rarity, g.chance) or "—"
		block.prosLabel.Text = g and g.desc or ""; block.consLabel.Text = ""
	elseif attrName == "physique" then
		local v = player:GetAttribute("Physique") :: string?
		local p = v and ProvidenceData.GetPhysique(v)
		block.nameLabel.Text = v or "—"; block.nameLabel.TextColor3 = p and Color3.fromHex(p.color) or C.t1
		block.subLabel.Text = p and p.role or "—"
		block.prosLabel.Text = p and ("✓ " .. p.pros) or ""; block.prosLabel.TextColor3 = C.green
		block.consLabel.Text = p and ("✗ " .. p.cons) or ""; block.consLabel.TextColor3 = C.hp
	elseif attrName == "connate" then
		local v = player:GetAttribute("Connate") :: string?
		local c = v and ProvidenceData.GetConnate(v)
		block.nameLabel.Text = v or "—"; block.nameLabel.TextColor3 = (v and RARITY[v]) or C.t1
		block.subLabel.Text = c and ("%.1f%% Chance"):format(c.chance) or "—"
		block.prosLabel.Text = c and ("✓ " .. c.pros) or ""; block.prosLabel.TextColor3 = C.green
		block.consLabel.Text = c and (c.cons ~= "—" and ("✗ " .. c.cons) or "") or ""; block.consLabel.TextColor3 = C.hp
	elseif attrName == "dao" then
		local v = player:GetAttribute("DaoAffinity") :: string?
		local d = v and ProvidenceData.GetDaoData(v)
		block.nameLabel.Text = (v or "—") .. " Dao"; block.nameLabel.TextColor3 = d and Color3.fromHex(d.color) or C.t1
		block.subLabel.Text = d and d.desc or "—"
		block.prosLabel.Text = "☯️ Erleichtert das Erlernen dieses Daos"; block.prosLabel.TextColor3 = C.cyan
		block.consLabel.Text = ""
	end
end

for _, attrName in ipairs(ATTR_ORDER) do
	bindAttr(ATTR_PLAYER_NAME[attrName], function(_) updateAttrBlock(attrName) end)
	bindAttr(REROLL_ATTR_FOR_BLOCK[attrName], function(_) updateAttrBlock(attrName) end)
	updateAttrBlock(attrName)
end

local confirmRemote = Net.Event("ConfirmProvidence")
confirmBtn.MouseButton1Click:Connect(function() confirmRemote:FireServer() end)
rerollAttrRemote.OnClientEvent:Connect(function(success: boolean, msg: string)
	if success then showToast("🎲 Neu gewürfelt!", "gold") else showToast("❌ " .. tostring(msg), "warn") end
end)

-- ════════════════════════════════════════════════════════════
-- ── Button wiring
-- ════════════════════════════════════════════════════════════
function closeAllOverlays()
	mainMenuLayer.Visible = false; inventoryLayer.Visible = false
	shopLayer.Visible = false;     questLayer.Visible = false
	sectLayer.Visible = false
end

mainMenuBtn.MouseButton1Click:Connect(function() closeAllOverlays(); mainMenuLayer.Visible = true end)
closeMainMenu.MouseButton1Click:Connect(function() mainMenuLayer.Visible = false end)

invBtn.MouseButton1Click:Connect(function() closeAllOverlays(); inventoryLayer.Visible = true end)
closeInv.MouseButton1Click:Connect(function() inventoryLayer.Visible = false end)

shopBtn.MouseButton1Click:Connect(function() closeAllOverlays(); shopLayer.Visible = true end)
closeShop.MouseButton1Click:Connect(function() shopLayer.Visible = false end)

questBtn.MouseButton1Click:Connect(function()
	closeAllOverlays()
	questLayer.Visible = true
	rebuildQuests()
end)
closeQuest.MouseButton1Click:Connect(function() questLayer.Visible = false end)

sectBtn.MouseButton1Click:Connect(function()
	closeAllOverlays()
	sectLayer.Visible = true
	rebuildSects()
end)
closeSect.MouseButton1Click:Connect(function() sectLayer.Visible = false end)

mmButtons[1].MouseButton1Click:Connect(function()
	mainMenuLayer.Visible = false
	showToast("☯️ " ..
		(player:GetAttribute("Aptitude") or "?") .. " · " ..
		(player:GetAttribute("Physique") or "?") .. " · " ..
		(player:GetAttribute("Connate")  or "?") .. " · " ..
		(player:GetAttribute("DaoAffinity") or "?"), "gold")
end)
mmButtons[2].MouseButton1Click:Connect(function() mainMenuLayer.Visible = false; shopLayer.Visible = true end)
mmButtons[3].MouseButton1Click:Connect(function() mainMenuLayer.Visible = false; questLayer.Visible = true; rebuildQuests() end)
mmButtons[4].MouseButton1Click:Connect(function()
	showToast("Nutze das Roblox-Menü (Esc → Disconnect) zum Verlassen.", "info")
	mainMenuLayer.Visible = false
end)

-- ════════════════════════════════════════════════════════════
-- ── Keyboard shortcuts
-- ════════════════════════════════════════════════════════════
local useTechRemote = Net.Event("UseTechnique")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.Escape then
		if mainMenuLayer.Visible or inventoryLayer.Visible or shopLayer.Visible or questLayer.Visible or sectLayer.Visible then
			closeAllOverlays()
		elseif seclPopup.Visible then
			seclPopup.Visible = false
		end
	elseif key == Enum.KeyCode.I then
		if not player:GetAttribute("InMenu") then
			local vis = not inventoryLayer.Visible; closeAllOverlays(); inventoryLayer.Visible = vis
		end
	elseif key == Enum.KeyCode.Q then
		if not player:GetAttribute("InMenu") and not player:GetAttribute("InSeclusion")
			and not player:GetAttribute("InTribulation") then
			useTechRemote:FireServer()
		end
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Network events
-- ════════════════════════════════════════════════════════════
Net.Event("Notify").OnClientEvent:Connect(showToast)

Net.Event("InventorySync").OnClientEvent:Connect(function(inventory: any)
	rebuildInventory(inventory)
end)

Net.Event("CombatHit").OnClientEvent:Connect(function(_name, amount)
	local d = Instance.new("TextLabel")
	d.Size = UDim2.new(0,120,0,40)
	d.Position = UDim2.new(0.5, math.random(-80,80), 0.5, math.random(-30,30))
	d.AnchorPoint = Vector2.new(0.5,0.5); d.BackgroundTransparency = 1
	d.Text = "-" .. fmt(amount); d.TextColor3 = C.gold
	d.TextSize = 22; d.Font = Enum.Font.GothamBlack
	d.TextStrokeTransparency = 0.3; d.Parent = gui
	local tw = TweenService:Create(d, TweenInfo.new(0.7,Enum.EasingStyle.Quad),
		{ Position=d.Position - UDim2.fromOffset(0,60), TextTransparency=1, TextStrokeTransparency=1 })
	tw:Play(); tw.Completed:Connect(function() d:Destroy() end)
end)

print("[TTP] UIController geladen.")
