--!strict
-- UIController.client.lua
-- Vollständiges HUD: Providence-Startmenü, HUD, Klausur-UI,
-- Hauptmenü, Inventar, Toasts, Hit-Zahlen.

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Net          = require(ReplicatedStorage:WaitForChild("Net"))
local GameData     = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData  = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))
local ShopData      = require(GameData:WaitForChild("ShopData"))
local QuestData     = require(GameData:WaitForChild("QuestData"))
local TechniqueData = require(GameData:WaitForChild("TechniqueData"))
local Buffs         = require(ReplicatedStorage:WaitForChild("Buffs"))

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

-- ════════════════════════════════════════════════════════════
-- Helfer
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

local function pct(m: number): string
	return ("%+d%%"):format(math.floor((m-1)*100 + 0.5))
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
-- ScreenGui + Wurzel-Frames
-- ════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TTP_HUD"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- 4 Root-Layer
local hudRoot     = Instance.new("Frame"); hudRoot.Name = "HUD"
hudRoot.Size = UDim2.fromScale(1,1); hudRoot.BackgroundTransparency = 1
hudRoot.Visible = false; hudRoot.Parent = gui

local menuRoot    = Instance.new("Frame"); menuRoot.Name = "ProvidenceMenu"
menuRoot.Size = UDim2.fromScale(1,1); menuRoot.BackgroundColor3 = C.bg0
menuRoot.BackgroundTransparency = 0.05; menuRoot.Visible = false; menuRoot.Parent = gui

local mainMenuLayer = Instance.new("Frame"); mainMenuLayer.Name = "MainMenuLayer"
mainMenuLayer.Size = UDim2.fromScale(1,1); mainMenuLayer.BackgroundColor3 = C.bg0
mainMenuLayer.BackgroundTransparency = 0.3; mainMenuLayer.Visible = false; mainMenuLayer.Parent = gui

local inventoryLayer = Instance.new("Frame"); inventoryLayer.Name = "InventoryLayer"
inventoryLayer.Size = UDim2.fromScale(1,1); inventoryLayer.BackgroundColor3 = C.bg0
inventoryLayer.BackgroundTransparency = 0.3; inventoryLayer.Visible = false; inventoryLayer.Parent = gui

local shopLayer = Instance.new("Frame"); shopLayer.Name = "ShopLayer"
shopLayer.Size = UDim2.fromScale(1,1); shopLayer.BackgroundColor3 = C.bg0
shopLayer.BackgroundTransparency = 0.3; shopLayer.Visible = false; shopLayer.Parent = gui

local questLayer = Instance.new("Frame"); questLayer.Name = "QuestLayer"
questLayer.Size = UDim2.fromScale(1,1); questLayer.BackgroundColor3 = C.bg0
questLayer.BackgroundTransparency = 0.3; questLayer.Visible = false; questLayer.Parent = gui

-- ════════════════════════════════════════════════════════════
-- ── HUD ─────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════

-- ── Realm / Stage / EXP / Alter (oben links) ───────────────
local realmPanel = mkPanel("RealmPanel", UDim2.new(0,300,0,142), UDim2.new(0,14,0,14), Vector2.new(0,0), hudRoot)
local realmNameL = mkLabel(realmPanel,"Qi Refinement",UDim2.new(1,-20,0,22),UDim2.new(0,12,0,8),C.gold,17,Enum.Font.GothamBold)
local stageL     = mkLabel(realmPanel,"Stage 1 / 9",  UDim2.new(1,-20,0,16),UDim2.new(0,12,0,32),C.t2,12)
local expFill    = mkBar(realmPanel, C.exp, UDim2.new(0,12,0,56), 12)
local expText    = mkLabel(realmPanel,"0 / 0 EXP",    UDim2.new(1,-20,0,14),UDim2.new(0,12,0,72),C.t3,11,nil,Enum.TextXAlignment.Center)
local lifeL      = mkLabel(realmPanel,"⏳ Alter —",   UDim2.new(1,-20,0,14),UDim2.new(0,12,0,90),C.green,12)
local dmgL       = mkLabel(realmPanel,"⚔️ ATK —",     UDim2.new(1,-20,0,14),UDim2.new(0,12,0,110),C.t3,11)
local defL       = mkLabel(realmPanel,"🛡️ DEF —",     UDim2.new(0.5,-16,0,14),UDim2.new(0.5,4,0,110),C.t3,11)
-- ATK = Basisangriff; effektiver Schaden = ATK − NPC-Verteidigung (mindestens 1)

-- ── Stats (oben rechts) ────────────────────────────────────
local statPanel = mkPanel("StatPanel", UDim2.new(0,192,0,88), UDim2.new(1,-14,0,14), Vector2.new(1,0), hudRoot)
local stonesL   = mkLabel(statPanel,"💰 0",           UDim2.new(1,-20,0,22),UDim2.new(0,12,0,8), C.gold,15,Enum.Font.GothamBold)
local karmaL    = mkLabel(statPanel,"⚖️ Karma: 0",    UDim2.new(1,-20,0,15),UDim2.new(0,12,0,36),C.t2,12)
local killsL    = mkLabel(statPanel,"⚔️ Kills: 0",    UDim2.new(1,-20,0,15),UDim2.new(0,12,0,56),C.t2,12)

-- ── Providence-Info (oben rechts, unter Stats) ─────────────
local provPanel = mkPanel("ProvPanel", UDim2.new(0,192,0,112), UDim2.new(1,-14,0,110), Vector2.new(1,0), hudRoot)
mkLabel(provPanel,"🎲 PROVIDENCE",UDim2.new(1,-20,0,12),UDim2.new(0,12,0,6),C.t3,10,Enum.Font.GothamBold)
local hAptL  = mkLabel(provPanel,"🌟 —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,24),C.t1,12)
local hPhysL = mkLabel(provPanel,"💪 —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,42),C.t1,12)
local hConnL = mkLabel(provPanel,"🎭 —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,60),C.t1,12)
local hDaoL  = mkLabel(provPanel,"☯️ —",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,78),C.t1,12)

-- ── HP-Balken (Mitte unten) ─────────────────────────────────
local hpPanel = mkPanel("HPPanel", UDim2.new(0,380,0,52), UDim2.new(0.5,0,1,-90), Vector2.new(0.5,1), hudRoot)
local hpFill  = mkBar(hpPanel, C.hp, UDim2.new(0,12,0,26), 16)
local hpText  = mkLabel(hpPanel,"HP 0 / 0",UDim2.new(1,-24,0,18),UDim2.new(0,12,0,4),C.t1,13,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

-- ── Klausur-Panel (unten links) ────────────────────────────
local seclPanel = mkPanel("SeclPanel", UDim2.new(0,215,0,90), UDim2.new(0,14,1,-14), Vector2.new(0,1), hudRoot)
local seclBtn   = mkButton(seclPanel,"🧘 Klausur betreten",UDim2.new(1,-16,0,36),UDim2.new(0,8,0,8),C.a1)
local seclStatus = mkLabel(seclPanel,"Klausur: Inaktiv",UDim2.new(1,-16,0,16),UDim2.new(0,8,0,50),C.t3,11)
local seclTimer  = mkLabel(seclPanel,"",UDim2.new(1,-16,0,16),UDim2.new(0,8,0,68),C.cyan,11,Enum.Font.GothamBold)

-- ── Inventar-Button (unten rechts) ─────────────────────────
local invBtn = mkButton(hudRoot,"🎒",UDim2.new(0,46,0,46),UDim2.new(1,-14,1,-14),C.bg4,Vector2.new(1,1))

-- ── Hauptmenü-Button (oben rechts Ecke) ────────────────────
local mainMenuBtn = mkButton(hudRoot,"≡",UDim2.new(0,38,0,38),UDim2.new(1,-14,0,14),C.bg4,Vector2.new(1,0))

-- ════════════════════════════════════════════════════════════
-- ── Klausur-Popup (erscheint beim Klick auf "Klausur betreten")
-- ════════════════════════════════════════════════════════════
local seclPopup = mkPanel("SeclPopup",UDim2.new(0,320,0,230),UDim2.new(0.5,0,1,-110),Vector2.new(0.5,1), hudRoot)
seclPopup.Visible = false
seclPopup.ZIndex = 10

mkLabel(seclPopup,"🧘  KLAUSUR BETRETEN",UDim2.new(1,-20,0,20),UDim2.new(0,10,0,10),C.gold,15,Enum.Font.GothamBold)

-- Jahr-Spinner
local seclYearsValue = 1  -- lokale State-Variable
local spinnerRow = Instance.new("Frame"); spinnerRow.Size = UDim2.new(1,-20,0,36)
spinnerRow.Position = UDim2.new(0,10,0,40); spinnerRow.BackgroundTransparency=1; spinnerRow.Parent = seclPopup

local yearMinusBtn = mkButton(spinnerRow,"−",UDim2.new(0,36,0,36),UDim2.fromOffset(0,0),C.bg5)
local yearLabel    = mkLabel(spinnerRow,"1 Jahr",UDim2.new(1,-80,1,0),UDim2.fromOffset(42,0),C.t1,16,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
yearLabel.TextYAlignment = Enum.TextYAlignment.Center
local yearPlusBtn  = mkButton(spinnerRow,"＋",UDim2.new(0,36,0,36),UDim2.new(1,-36,0,0),C.bg5)

-- Preview-Info
local seclPreviewEXP    = mkLabel(seclPopup,"⚡ EXP: —",     UDim2.new(1,-20,0,16),UDim2.new(0,10,0,88),C.exp,12)
local seclPreviewStones = mkLabel(seclPopup,"💰 Stones: —",  UDim2.new(1,-20,0,16),UDim2.new(0,10,0,108),C.gold,12)
local seclPreviewAge    = mkLabel(seclPopup,"⏳ Altert um: —",UDim2.new(1,-20,0,16),UDim2.new(0,10,0,128),C.warn,12)
local seclPreviewTime   = mkLabel(seclPopup,"🕑 Echtzeit: —", UDim2.new(1,-20,0,16),UDim2.new(0,10,0,148),C.t2,12)

local seclConfirmBtn  = mkButton(seclPopup,"✓ Klausur starten", UDim2.new(1,-20,0,36), UDim2.new(0,10,1,-46), C.green)
local seclCancelPopup = mkButton(seclPopup,"✕ Abbrechen",       UDim2.new(1,-20,0,20), UDim2.new(0,10,1,-22), C.bg4)

-- Klausur-Abbrechen-Button (erscheint wenn in Klausur)
local seclAbortBtn = mkButton(hudRoot,"⚠️ Klausur abbrechen (−30%)",
	UDim2.new(0,240,0,36), UDim2.new(0,14,1,-68), C.hp, Vector2.new(0,1))
seclAbortBtn.Visible = false

-- ════════════════════════════════════════════════════════════
-- ── Hauptmenü-Overlay
-- ════════════════════════════════════════════════════════════
local mainMenuCard = mkPanel("Card",UDim2.new(0,320,0,280),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), mainMenuLayer)
mkLabel(mainMenuCard,"HAUPTMENÜ",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,16),C.gold,20,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)

local closeMainMenu = mkButton(mainMenuCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
closeMainMenu.TextSize = 16

local mmItems = {
	{ text="📖 Providence ansehen",  y=60 },
	{ text="⚙️ Einstellungen (bald)", y=108 },
	{ text="❓ Hilfe (bald)",         y=156 },
	{ text="🔄 Spiel verlassen",      y=204 },
}
local mmButtons: { TextButton } = {}
for _, item in ipairs(mmItems) do
	local b = mkButton(mainMenuCard, item.text, UDim2.new(1,-30,0,40), UDim2.fromOffset(15, item.y), C.bg4)
	b.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(mmButtons, b)
end

-- ════════════════════════════════════════════════════════════
-- ── Inventar-Overlay
-- ════════════════════════════════════════════════════════════
local invCard = mkPanel("InvCard",UDim2.new(0,520,0,440),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), inventoryLayer)
mkLabel(invCard,"🎒  INVENTAR",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeInv = mkButton(invCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)

local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1,-20,1,-58); invScroll.Position = UDim2.fromOffset(10,50)
invScroll.BackgroundTransparency = 1; invScroll.BorderSizePixel = 0
invScroll.ScrollBarThickness = 5; invScroll.ScrollBarImageColor3 = C.bg5
invScroll.CanvasSize = UDim2.new(); invScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
invScroll.Parent = invCard
local invListLayout = Instance.new("UIListLayout")
invListLayout.SortOrder = Enum.SortOrder.LayoutOrder; invListLayout.Padding = UDim.new(0,6)
invListLayout.Parent = invScroll

local invEmpty = mkLabel(invCard,"— Inventar leer —\nKaufe Pillen im Shop 🏪",
	UDim2.new(1,-40,0,50), UDim2.fromOffset(20,180), C.t3, 14, nil, Enum.TextXAlignment.Center)
invEmpty.TextYAlignment = Enum.TextYAlignment.Center

-- ════════════════════════════════════════════════════════════
-- ── Providence-Start-Menü
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

-- ── Linke Karte: dein Roll ────────────────────────────────
local rollCard = mkPanel("RollCard", UDim2.new(0.44,0,1,-68), UDim2.fromOffset(0,62), Vector2.new(0,0), mContainer)
local scrollLeft = Instance.new("ScrollingFrame")
scrollLeft.Size = UDim2.new(1,-12,1,-12); scrollLeft.Position = UDim2.fromOffset(6,6)
scrollLeft.BackgroundTransparency=1; scrollLeft.BorderSizePixel=0
scrollLeft.ScrollBarThickness=4; scrollLeft.ScrollBarImageColor3=C.bg5
scrollLeft.CanvasSize=UDim2.new(); scrollLeft.AutomaticCanvasSize=Enum.AutomaticSize.Y
scrollLeft.Parent = rollCard
local llLayout = Instance.new("UIListLayout"); llLayout.SortOrder=Enum.SortOrder.LayoutOrder
llLayout.Padding=UDim.new(0,8); llLayout.Parent=scrollLeft
local llPad = Instance.new("UIPadding"); llPad.PaddingLeft=UDim.new(0,8); llPad.PaddingRight=UDim.new(0,8); llPad.PaddingBottom=UDim.new(0,8); llPad.Parent=scrollLeft

-- Hilfsfunktion: Attribut-Block im Roll-Card
local ATTR_ORDER = { "aptitude", "physique", "connate", "dao" }
local ATTR_LABEL = { aptitude="🌟 APTITUDE", physique="💪 PHYSIQUE", connate="🎭 CONNATE", dao="☯️ DAO AFFINITY" }
local attrBlocks: { [string]: {
	nameLabel: TextLabel, subLabel: TextLabel, prosLabel: TextLabel, consLabel: TextLabel, rerollBtn: TextButton } } = {}

local rerollAttrRemote = Net.Event("RerollAttr")

for i, attrName in ipairs(ATTR_ORDER) do
	local block = Instance.new("Frame")
	block.LayoutOrder = i
	block.Size = UDim2.new(1,0,0,105)
	block.BackgroundColor3 = C.bg3
	block.BorderSizePixel = 0
	corner(block, 8); stroke(block, C.border)
	block.Parent = scrollLeft

	mkLabel(block, ATTR_LABEL[attrName], UDim2.new(1,-100,0,16), UDim2.fromOffset(10,8), C.t3, 10, Enum.Font.GothamBold)

	local nameL = mkLabel(block,"—",UDim2.new(1,-110,0,22),UDim2.fromOffset(10,26),C.t1,18,Enum.Font.GothamBlack)
	local subL  = mkLabel(block,"...",UDim2.new(1,-110,0,14),UDim2.fromOffset(10,52),C.t2,11)
	subL.TextWrapped = true

	local prosL = mkLabel(block,"Pros: ...",UDim2.new(1,-110,0,12),UDim2.fromOffset(10,70),C.green,10)
	prosL.TextWrapped = true
	local consL = mkLabel(block,"Cons: ...",UDim2.new(1,-110,0,12),UDim2.fromOffset(10,85),C.hp,10)
	consL.TextWrapped = true

	local rerollBtn = mkButton(block,"🎲 (" .. tostring(2) .. ")",
		UDim2.new(0,85,0,28), UDim2.new(1,-95,0,10), C.a1)
	rerollBtn.TextSize = 12
	rerollBtn.MouseButton1Click:Connect(function()
		rerollAttrRemote:FireServer(attrName)
	end)

	attrBlocks[attrName] = { nameLabel=nameL, subLabel=subL, prosLabel=prosL, consLabel=consL, rerollBtn=rerollBtn }
end

-- Bestätigungs-Button
local confirmBtn = mkButton(scrollLeft,"✓ Providence bestätigen & Spiel beginnen",
	UDim2.new(1,0,0,50), UDim2.fromOffset(0,0), C.green)
confirmBtn.LayoutOrder = 10
confirmBtn.TextSize = 16; confirmBtn.Font = Enum.Font.GothamBold

-- ── Rechte Karte: Chancen & Effekte ──────────────────────
local infoCard = mkPanel("InfoCard", UDim2.new(0.54,0,1,-68), UDim2.new(0.46,0,0,62), Vector2.new(0,0), mContainer)
local scrollR = Instance.new("ScrollingFrame")
scrollR.Size=UDim2.new(1,-12,1,-12); scrollR.Position=UDim2.fromOffset(6,6)
scrollR.BackgroundTransparency=1; scrollR.BorderSizePixel=0
scrollR.ScrollBarThickness=4; scrollR.ScrollBarImageColor3=C.bg5
scrollR.CanvasSize=UDim2.new(); scrollR.AutomaticCanvasSize=Enum.AutomaticSize.Y
scrollR.Parent=infoCard

local rlLayout = Instance.new("UIListLayout"); rlLayout.SortOrder=Enum.SortOrder.LayoutOrder
rlLayout.Padding=UDim.new(0,2); rlLayout.Parent=scrollR
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

-- Aptitude-Tabelle
infoRow("🌟  APTITUDE — EXP-Multiplikator",C.gold,14,Enum.Font.GothamBold)
for _, g in ipairs(AptitudeData.GRADES) do
	local col = RARITY[g.rarity] or C.t1
	infoRow(('<b>%s</b>  ×%.1f  <font color="#5C6488">%.1f%%</font>'):format(g.name,g.mult,g.chance),col,12)
end

-- Physique-Tabelle
infoRow("💪  PHYSIQUE — Körper-Typ",C.gold,14,Enum.Font.GothamBold,10)
for _, p in ipairs(ProvidenceData.PHYSIQUES) do
	infoRow(('<b><font color="#%s">%s</font></b>  <font color="#5C6488">%s  %.0f%%</font>'):format(p.color,p.name,p.role,p.chance), Color3.fromHex(p.color),12)
	infoRow('<font color="#34D399">✓ ' .. p.pros .. '</font>', C.green, 11)
	infoRow('<font color="#F87171">✗ ' .. p.cons .. '</font>', C.hp, 11)
end

-- Connate-Tabelle
infoRow("🎭  CONNATE — Seltenheit & Lebensspanne",C.gold,14,Enum.Font.GothamBold,10)
for _, c in ipairs(ProvidenceData.CONNATES) do
	local col = RARITY[c.name] or C.t1
	infoRow(('<b>%s</b>  <font color="#5C6488">%.1f%%</font>'):format(c.name, c.chance), col, 12)
	if c.pros ~= "—" and c.pros ~= "" then
		infoRow('<font color="#34D399">✓ ' .. c.pros .. '</font>', C.green, 11)
	end
	if c.cons ~= "—" and c.cons ~= "" then
		infoRow('<font color="#F87171">✗ ' .. c.cons .. '</font>', C.hp, 11)
	end
end

-- Dao-Tabelle
infoRow("☯️  DAO AFFINITY — Dao-Neigung & Boni",C.gold,14,Enum.Font.GothamBold,10)
for _, d in ipairs(ProvidenceData.DAO_DATA) do
	infoRow(('<b><font color="#%s">%s Dao</font></b>  <font color="#5C6488">%s</font>'):format(d.color,d.name,d.desc), Color3.fromHex(d.color), 12)
	infoRow('<font color="#34D399">✓ ' .. d.pros .. '</font>', C.green, 11)
	if d.cons ~= "—" then
		infoRow('<font color="#F87171">✗ ' .. d.cons .. '</font>', C.hp, 11)
	end
end
-- Hinweis
infoRow('<font color="#5C6488">ℹ️ ATK = Basiswert. Schaden = ATK − NPC-Verteidigung (mind. 1).</font>', C.t3, 11, nil, 10)

-- ════════════════════════════════════════════════════════════
-- ── Toasts (immer ganz oben)
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
-- ── Bindings: HUD ───────────────────────────────────────────
-- ════════════════════════════════════════════════════════════
bindAttr("RealmName",  function(v) realmNameL.Text = v or "—" end)

local function updateStage()
	stageL.Text = ("Stage %d / %d  ·  %s"):format(
		player:GetAttribute("Stage")    or 1,
		player:GetAttribute("MaxStage") or 9,
		player:GetAttribute("Tier")     or "")
end
bindAttr("Stage",    updateStage)
bindAttr("MaxStage", updateStage)
bindAttr("Tier",     updateStage)

local function updateEXP()
	local exp    = player:GetAttribute("EXP")       or 0
	local needed = player:GetAttribute("EXPNeeded") or 1
	local ratio  = math.clamp(exp / math.max(needed,1), 0, 1)
	TweenService:Create(expFill, TweenInfo.new(0.25), { Size=UDim2.fromScale(ratio,1) }):Play()
	expText.Text = ("%s / %s EXP  (%.0f%%)"):format(fmt(exp), fmt(needed), ratio*100)
end
bindAttr("EXP",       updateEXP)
bindAttr("EXPNeeded", updateEXP)

local function updateHP()
	local hp    = player:GetAttribute("HP")    or 0
	local maxHP = player:GetAttribute("MaxHP") or 1
	local ratio = math.clamp(hp / math.max(maxHP,1), 0, 1)
	TweenService:Create(hpFill, TweenInfo.new(0.2), { Size=UDim2.fromScale(ratio,1) }):Play()
	hpText.Text = ("HP  %s / %s"):format(fmt(hp), fmt(maxHP))
end
bindAttr("HP",    updateHP)
bindAttr("MaxHP", updateHP)

local function updateAge()
	if player:GetAttribute("LifespanInfinite") then
		lifeL.Text = "⏳ Alter: ∞ (unsterblich)"; lifeL.TextColor3 = C.cyan; return
	end
	local age     = player:GetAttribute("Age")         or 18
	local maxLife = player:GetAttribute("MaxLifespan") or 85
	local ratio   = age / math.max(maxLife,1)
	lifeL.Text = ("⏳ Alter %s / %s"):format(fmt(age), fmt(maxLife))
	lifeL.TextColor3 = ratio > 0.85 and C.hp or (ratio > 0.65 and C.warn or C.green)
end
bindAttr("Age",            updateAge)
bindAttr("MaxLifespan",    updateAge)
bindAttr("LifespanInfinite", updateAge)

bindAttr("Damage",  function(v) dmgL.Text = ("⚔️ ATK %s"):format(fmt(v)) end)
bindAttr("Defense", function(v) defL.Text = ("🛡️ DEF %s"):format(fmt(v)) end)
-- BossRequired-Anzeige: blinkende Warnung wenn Boss besiegt werden muss
local bossWarnLabel = mkLabel(realmPanel,"",UDim2.new(1,-20,0,14),UDim2.new(0,12,0,126),C.hp,10,Enum.Font.GothamBold)
bossWarnLabel.TextWrapped = true
bindAttr("BossRequired", function(v)
	bossWarnLabel.Text = v and "⚠️ Boss besiegen für Realm-Durchbruch!" or ""
end)

bindAttr("SpiritStones", function(v) stonesL.Text = "💰 " .. fmt(v) end)
bindAttr("Karma",        function(v) karmaL.Text  = "⚖️ Karma: " .. tostring(math.floor(v or 0)) end)
bindAttr("TotalKills",   function(v) killsL.Text  = "⚔️ Kills: " .. tostring(v or 0) end)

bindAttr("Aptitude",    function(v)
	local g = v and AptitudeData.GetByName(v)
	hAptL.Text = "🌟 " .. (v or "—")
	hAptL.TextColor3 = (g and RARITY[g.rarity]) or C.t1
end)
bindAttr("Physique",    function(v)
	local p = v and ProvidenceData.GetPhysique(v)
	hPhysL.Text = "💪 " .. (v or "—")
	hPhysL.TextColor3 = p and Color3.fromHex(p.color) or C.t1
end)
bindAttr("Connate",     function(v)
	hConnL.Text = "🎭 " .. (v or "—")
	hConnL.TextColor3 = (v and RARITY[v]) or C.t1
end)
bindAttr("DaoAffinity", function(v)
	local d = v and ProvidenceData.GetDaoData(v)
	hDaoL.Text = "☯️ " .. (v or "—")
	hDaoL.TextColor3 = d and Color3.fromHex(d.color) or C.t1
end)

-- ── Sichtbarkeit ────────────────────────────────────────────
bindAttr("InMenu", function(v)
	if v == nil then return end
	menuRoot.Visible = (v == true)
	hudRoot.Visible  = (v ~= true)
end)

-- ── Klausur-Status ─────────────────────────────────────────
local seclusionCountdown = 0
local inSeclusionLocal   = false

bindAttr("InSeclusion", function(v)
	inSeclusionLocal = v == true
	seclBtn.Visible      = not inSeclusionLocal
	seclAbortBtn.Visible = inSeclusionLocal
	seclPopup.Visible    = false
	if inSeclusionLocal then
		seclStatus.Text = "🧘 In Klausur"
		seclStatus.TextColor3 = C.cyan
	else
		seclStatus.Text = "Klausur: Inaktiv"
		seclStatus.TextColor3 = C.t3
		seclTimer.Text = ""
		seclusionCountdown = 0
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Bindings: Providence-Menü ───────────────────────────────
-- ════════════════════════════════════════════════════════════
local REROLL_ATTR_FOR_BLOCK: { [string]: string } = {
	aptitude = "Rerolls_Aptitude", physique = "Rerolls_Physique",
	connate  = "Rerolls_Connate",  dao      = "Rerolls_Dao",
}

local function updateAttrBlock(attrName: string)
	local block   = attrBlocks[attrName]
	local rerolls = player:GetAttribute(REROLL_ATTR_FOR_BLOCK[attrName]) or 0

	local locked = player:GetAttribute("ProvidenceConfirmed") == true or rerolls <= 0
	block.rerollBtn.Text = rerolls > 0 and ("🎲 (%d)"):format(rerolls) or "🔒"
	block.rerollBtn.BackgroundColor3 = rerolls > 0 and C.a1 or C.bg4
	block.rerollBtn.Active = rerolls > 0

	if attrName == "aptitude" then
		local v = player:GetAttribute("Aptitude")
		local g = v and AptitudeData.GetByName(v)
		block.nameLabel.Text = v or "—"
		block.nameLabel.TextColor3 = (g and RARITY[g.rarity]) or C.t1
		block.subLabel.Text = g and ("EXP ×%.1f  |  %s  |  %.1f%% Chance"):format(g.mult, g.rarity, g.chance) or "—"
		block.prosLabel.Text = g and "Cultivates " .. (g.mult < 1 and "slowly" or g.mult >= 4 and "at godlike speed" or "efficiently") or ""
		block.consLabel.Text = g and g.desc or ""
	elseif attrName == "physique" then
		local v = player:GetAttribute("Physique")
		local p = v and ProvidenceData.GetPhysique(v)
		block.nameLabel.Text = v or "—"
		block.nameLabel.TextColor3 = p and Color3.fromHex(p.color) or C.t1
		block.subLabel.Text = p and p.role or "—"
		block.prosLabel.Text = p and ("✓ " .. p.pros) or ""
		block.consLabel.Text = p and ("✗ " .. p.cons) or ""
		block.prosLabel.TextColor3 = C.green
		block.consLabel.TextColor3 = C.hp
	elseif attrName == "connate" then
		local v = player:GetAttribute("Connate")
		local c = v and ProvidenceData.GetConnate(v)
		block.nameLabel.Text = v or "—"
		block.nameLabel.TextColor3 = (v and RARITY[v]) or C.t1
		block.subLabel.Text = c and ("%.1f%% Chance"):format(c.chance) or "—"
		block.prosLabel.Text = c and ("✓ " .. c.pros) or ""
		block.consLabel.Text = c and (c.cons ~= "—" and ("✗ " .. c.cons) or "") or ""
		block.prosLabel.TextColor3 = C.green
		block.consLabel.TextColor3 = C.hp
	elseif attrName == "dao" then
		local v = player:GetAttribute("DaoAffinity")
		local d = v and ProvidenceData.GetDaoData(v)
		block.nameLabel.Text = (v or "—") .. " Dao"
		block.nameLabel.TextColor3 = d and Color3.fromHex(d.color) or C.t1
		block.subLabel.Text = d and d.desc or "—"
		block.prosLabel.Text = "☯️ Erleichtert das Erlernen dieses Daos"
		block.prosLabel.TextColor3 = C.cyan
		block.consLabel.Text = ""
	end
end

-- Mapping attrName -> tatsächlicher Player-Attribut-Name
local ATTR_PLAYER_NAME: { [string]: string } = {
	aptitude = "Aptitude",
	physique  = "Physique",
	connate   = "Connate",
	dao       = "DaoAffinity",
}
local REROLL_ATTR_NAME: { [string]: string } = {
	aptitude = "Rerolls_Aptitude",
	physique  = "Rerolls_Physique",
	connate   = "Rerolls_Connate",
	dao       = "Rerolls_Dao",
}

for _, attrName in ipairs(ATTR_ORDER) do
	local playerAttr  = ATTR_PLAYER_NAME[attrName]
	local rerollAttr  = REROLL_ATTR_NAME[attrName]
	bindAttr(playerAttr,  function(_) updateAttrBlock(attrName) end)
	bindAttr(rerollAttr,  function(_) updateAttrBlock(attrName) end)
	updateAttrBlock(attrName)
end

-- ════════════════════════════════════════════════════════════
-- ── Klausur-Popup Logik ─────────────────────────────────────
-- ════════════════════════════════════════════════════════════
local function getMaxSeclYears(): number
	local maxLife   = player:GetAttribute("MaxLifespan") or 85
	local age       = player:GetAttribute("Age")         or 18
	return math.max(1, math.floor(maxLife - age - 1))
end

local function updateSeclPreview()
	local years = seclYearsValue
	yearLabel.Text = years == 1 and "1 Jahr" or (tostring(years) .. " Jahre")
	local realMins = math.ceil(years * 60 / 1)  -- SECLUSION_SECS_PER_YEAR = 120 → 2 min/year

	-- Rough EXP estimate (client doesn't know exact stage EXP, so show relative)
	seclPreviewEXP.Text    = ("⚡ EXP: ~%d Stufen-Fortschritte"):format(years * 3)
	seclPreviewStones.Text = ("💰 Stones: +%d"):format(years * 80)
	seclPreviewAge.Text    = ("⏳ Altert um: %d %s"):format(years, years==1 and "Jahr" or "Jahre")
	seclPreviewTime.Text   = ("🕑 Echtzeit: ~%d Min."):format(math.ceil(years * 120 / 60))
end

seclBtn.MouseButton1Click:Connect(function()
	if inSeclusionLocal then return end
	seclYearsValue = 1
	updateSeclPreview()
	seclPopup.Visible = true
end)

seclCancelPopup.MouseButton1Click:Connect(function()
	seclPopup.Visible = false
end)

yearMinusBtn.MouseButton1Click:Connect(function()
	seclYearsValue = math.max(1, seclYearsValue - 1)
	updateSeclPreview()
end)

yearPlusBtn.MouseButton1Click:Connect(function()
	seclYearsValue = math.min(getMaxSeclYears(), seclYearsValue + 1)
	updateSeclPreview()
end)

local startSeclusionRemote  = Net.Event("StartSeclusion")
local cancelSeclusionRemote = Net.Event("CancelSeclusion")

seclConfirmBtn.MouseButton1Click:Connect(function()
	seclPopup.Visible = false
	startSeclusionRemote:FireServer(seclYearsValue)
end)

seclAbortBtn.MouseButton1Click:Connect(function()
	cancelSeclusionRemote:FireServer()
end)

-- Klausur-Countdown (empfangen vom Server)
Net.Event("SeclusionStarted").OnClientEvent:Connect(function(durationSec: number, years: number)
	seclusionCountdown = durationSec
	seclStatus.Text = ("🧘 Klausur: %d %s"):format(years, years==1 and "Jahr" or "Jahre")
end)

Net.Event("SeclusionFinished").OnClientEvent:Connect(function(expGained: number, stonesGained: number, years: number, canceled: boolean)
	local prefix = canceled and "⚠️ Abgebrochen" or "✅ Abgeschlossen"
	showToast(("%s — +%d EXP, +%d Stones, +%d Jahre"):format(prefix, expGained, stonesGained, years), canceled and "warn" or "gold")
end)

-- Countdown-Tick (per Heartbeat emuliert via task.spawn loop)
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
-- ── Hauptmenü + Inventar Buttons ────────────────────────────
-- ════════════════════════════════════════════════════════════
mainMenuBtn.MouseButton1Click:Connect(function()
	local wasOpen = mainMenuLayer.Visible
	inventoryLayer.Visible = false; shopLayer.Visible = false; questLayer.Visible = false
	mainMenuLayer.Visible = not wasOpen
end)

closeMainMenu.MouseButton1Click:Connect(function()
	mainMenuLayer.Visible = false
end)

invBtn.MouseButton1Click:Connect(function()
	local wasOpen = inventoryLayer.Visible
	mainMenuLayer.Visible = false; shopLayer.Visible = false; questLayer.Visible = false
	inventoryLayer.Visible = not wasOpen
end)

closeInv.MouseButton1Click:Connect(function()
	inventoryLayer.Visible = false
end)

-- ESC schließt offene Overlays
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape then
		if mainMenuLayer.Visible then mainMenuLayer.Visible = false
		elseif inventoryLayer.Visible then inventoryLayer.Visible = false
		elseif seclPopup.Visible then seclPopup.Visible = false
		end
	elseif input.KeyCode == Enum.KeyCode.I then
		if not player:GetAttribute("InMenu") then
			inventoryLayer.Visible = not inventoryLayer.Visible
			mainMenuLayer.Visible  = false
		end
	end
end)

-- Hauptmenü-Buttons Logik
mmButtons[1].MouseButton1Click:Connect(function()
	-- Providence ansehen: Menü kurz öffnen, nur Lese-Modus
	mainMenuLayer.Visible = false
	showToast("☯️ Dein Providence: " ..
		(player:GetAttribute("Aptitude") or "?") .. " · " ..
		(player:GetAttribute("Physique") or "?") .. " · " ..
		(player:GetAttribute("Connate")  or "?") .. " · " ..
		(player:GetAttribute("DaoAffinity") or "?"), "gold")
end)
mmButtons[4].MouseButton1Click:Connect(function()
	-- Spiel verlassen (back to Roblox menu)
	game:GetService("TeleportService") -- placeholder, can't actually leave without teleport
	showToast("Nutze das Roblox-Menü (Esc → Disconnect) zum Verlassen.", "info")
	mainMenuLayer.Visible = false
end)

-- ════════════════════════════════════════════════════════════
-- ── Providence-Menü: Bestätigen ─────────────────────────────
-- ════════════════════════════════════════════════════════════
local confirmRemote = Net.Event("ConfirmProvidence")
confirmBtn.MouseButton1Click:Connect(function()
	confirmRemote:FireServer()
end)

-- ── Reroll-Feedback ────────────────────────────────────────
rerollAttrRemote.OnClientEvent:Connect(function(success: boolean, msg: string)
	if success then
		showToast("🎲 Neu gewürfelt!", "gold")
	else
		showToast("❌ " .. tostring(msg), "warn")
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Hit-Zahlen (Schadens-Feedback) ──────────────────────────
-- ════════════════════════════════════════════════════════════
Net.Event("Notify").OnClientEvent:Connect(showToast)

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

-- ════════════════════════════════════════════════════════════
-- ── Erweiterte HUD-Buttons (Shop / Quests / Technik / Buffs) ─
-- ════════════════════════════════════════════════════════════
local shopBtn  = mkButton(hudRoot,"🏪",UDim2.new(0,46,0,46),UDim2.new(1,-14,1,-66), C.bg4,Vector2.new(1,1))
local questBtn = mkButton(hudRoot,"📜",UDim2.new(0,46,0,46),UDim2.new(1,-14,1,-118),C.bg4,Vector2.new(1,1))

-- Grüner Punkt auf dem Quest-Button, wenn Belohnungen abholbereit sind.
local questDot = Instance.new("Frame")
questDot.Size = UDim2.fromOffset(14,14); questDot.AnchorPoint = Vector2.new(1,0)
questDot.Position = UDim2.new(1,-1,0,1); questDot.BackgroundColor3 = C.green
questDot.BorderSizePixel = 0; questDot.Visible = false; corner(questDot,7)
stroke(questDot, C.bg0); questDot.Parent = questBtn

-- Technik-Button (rechts neben der HP-Leiste).
local techBtn = mkButton(hudRoot,"⚔️ Technik (Q)",UDim2.new(0,154,0,52),UDim2.new(0.5,200,1,-90),C.bg3,Vector2.new(0,1))
techBtn.TextSize = 13

-- Buff-Statuszeile (unter dem Realm-Panel).
local buffPanel = mkPanel("BuffPanel", UDim2.new(0,300,0,30), UDim2.new(0,14,0,164), Vector2.new(0,0), hudRoot)
local buffLabel = mkLabel(buffPanel,"Keine aktiven Buffs",UDim2.new(1,-16,1,0),UDim2.fromOffset(10,0),C.t3,11,Enum.Font.GothamBold)
buffLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Technik-Name aus Dao ableiten (zusätzlicher Listener auf DaoAffinity).
bindAttr("DaoAffinity", function(v)
	local t = v and TechniqueData.GetForDao(v)
	techBtn.Text = t and (t.icon .. " " .. t.name .. "  (Q)") or "⚔️ Technik (Q)"
end)

-- ════════════════════════════════════════════════════════════
-- ── Overlay-Verwaltung ──────────────────────────────────────
-- ════════════════════════════════════════════════════════════
local function closeAllOverlays()
	mainMenuLayer.Visible  = false
	inventoryLayer.Visible = false
	shopLayer.Visible      = false
	questLayer.Visible     = false
end

local function toggleOverlay(layer: Frame)
	local wasOpen = layer.Visible
	closeAllOverlays()
	layer.Visible = not wasOpen
end

shopBtn.MouseButton1Click:Connect(function()  toggleOverlay(shopLayer)  end)
questBtn.MouseButton1Click:Connect(function() toggleOverlay(questLayer) end)

-- ════════════════════════════════════════════════════════════
-- ── SHOP-Overlay ────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════
local shopCard = mkPanel("ShopCard",UDim2.new(0,580,0,470),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), shopLayer)
mkLabel(shopCard,"🏪  SHOP — Pillen & Elixiere",UDim2.new(1,-160,0,24),UDim2.fromOffset(16,14),C.gold,18,Enum.Font.GothamBold)
local shopStonesL = mkLabel(shopCard,"💰 0",UDim2.new(0,120,0,22),UDim2.new(1,-150,0,16),C.gold,15,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
local closeShop = mkButton(shopCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
closeShop.MouseButton1Click:Connect(function() shopLayer.Visible = false end)

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1,-20,1,-58); shopScroll.Position = UDim2.fromOffset(10,50)
shopScroll.BackgroundTransparency = 1; shopScroll.BorderSizePixel = 0
shopScroll.ScrollBarThickness = 5; shopScroll.ScrollBarImageColor3 = C.bg5
shopScroll.CanvasSize = UDim2.new(); shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopScroll.Parent = shopCard
local shopLayout = Instance.new("UIListLayout")
shopLayout.SortOrder = Enum.SortOrder.LayoutOrder; shopLayout.Padding = UDim.new(0,6)
shopLayout.Parent = shopScroll

local buyRemote = Net.Event("BuyItem")
for i, item in ipairs(ShopData.ITEMS) do
	local row = Instance.new("Frame")
	row.LayoutOrder = i; row.Size = UDim2.new(1,0,0,64)
	row.BackgroundColor3 = C.bg3; row.BorderSizePixel = 0
	corner(row,8); stroke(row,C.border); row.Parent = shopScroll

	local col = RARITY[item.rarity] or C.t1
	mkLabel(row, item.icon .. "  " .. item.name, UDim2.new(1,-120,0,20), UDim2.fromOffset(12,8), col, 15, Enum.Font.GothamBold)
	local d = mkLabel(row, item.desc, UDim2.new(1,-120,0,28), UDim2.fromOffset(12,28), C.t2, 11)
	d.TextWrapped = true

	local buy = mkButton(row, ("💰 %d"):format(item.price), UDim2.new(0,96,0,40), UDim2.new(1,-108,0.5,-20), C.a1)
	buy.TextSize = 13
	buy.MouseButton1Click:Connect(function()
		buyRemote:FireServer(item.id)
	end)
end

-- ════════════════════════════════════════════════════════════
-- ── QUEST-Overlay ───────────────────────────────────────────
-- ════════════════════════════════════════════════════════════
local questCard = mkPanel("QuestCard",UDim2.new(0,580,0,470),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), questLayer)
mkLabel(questCard,"📜  QUESTS",UDim2.new(1,-60,0,24),UDim2.fromOffset(16,14),C.gold,18,Enum.Font.GothamBold)
local closeQuest = mkButton(questCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
closeQuest.MouseButton1Click:Connect(function() questLayer.Visible = false end)

local questScroll = Instance.new("ScrollingFrame")
questScroll.Size = UDim2.new(1,-20,1,-58); questScroll.Position = UDim2.fromOffset(10,50)
questScroll.BackgroundTransparency = 1; questScroll.BorderSizePixel = 0
questScroll.ScrollBarThickness = 5; questScroll.ScrollBarImageColor3 = C.bg5
questScroll.CanvasSize = UDim2.new(); questScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
questScroll.Parent = questCard
local questLayout = Instance.new("UIListLayout")
questLayout.SortOrder = Enum.SortOrder.LayoutOrder; questLayout.Padding = UDim.new(0,6)
questLayout.Parent = questScroll

local claimRemote = Net.Event("ClaimQuest")
-- Quest-Zeilen einmal bauen, später nur Werte aktualisieren.
local questRows: { [string]: { progress: TextLabel, claim: TextButton } } = {}
for i, q in ipairs(QuestData.QUESTS) do
	local row = Instance.new("Frame")
	row.LayoutOrder = i; row.Size = UDim2.new(1,0,0,68)
	row.BackgroundColor3 = C.bg3; row.BorderSizePixel = 0
	corner(row,8); stroke(row,C.border); row.Parent = questScroll

	-- Belohnungs-Text
	local rewardBits = {}
	if q.stones and q.stones > 0 then table.insert(rewardBits, ("%d Stones"):format(q.stones)) end
	if q.expFactor then table.insert(rewardBits, "EXP") end
	if q.rewardItem then
		local it = ShopData.GetItem(q.rewardItem)
		table.insert(rewardBits, it and it.name or "Item")
	end

	mkLabel(row, q.name, UDim2.new(1,-130,0,18), UDim2.fromOffset(12,7), C.t1, 14, Enum.Font.GothamBold)
	local desc = mkLabel(row, q.desc, UDim2.new(1,-130,0,24), UDim2.fromOffset(12,26), C.t2, 11)
	desc.TextWrapped = true
	mkLabel(row, "🎁 " .. table.concat(rewardBits, " · "), UDim2.new(1,-130,0,14), UDim2.fromOffset(12,50), C.gold, 10)

	local progress = mkLabel(row, "0/0", UDim2.new(0,110,0,16), UDim2.new(1,-122,0,8), C.t3, 11, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
	local claim = mkButton(row, "—", UDim2.new(0,110,0,32), UDim2.new(1,-122,0,28), C.bg4)
	claim.TextSize = 12
	claim.MouseButton1Click:Connect(function()
		claimRemote:FireServer(q.id)
	end)

	questRows[q.id] = { progress = progress, claim = claim }
end

Net.Event("QuestSync").OnClientEvent:Connect(function(state: any)
	local anyClaimable = false
	for questId, info in pairs(state) do
		local row = questRows[questId]
		if row then
			row.progress.Text = ("%d/%d"):format(math.min(info.progress, info.target), info.target)
			if info.claimed then
				row.claim.Text = "✓ Belohnt"
				row.claim.BackgroundColor3 = C.bg5
				row.claim.Active = false
			elseif info.complete then
				row.claim.Text = "🎁 Beanspruchen"
				row.claim.BackgroundColor3 = C.green
				row.claim.Active = true
				anyClaimable = true
			else
				row.claim.Text = "In Arbeit"
				row.claim.BackgroundColor3 = C.bg4
				row.claim.Active = false
			end
		end
	end
	questDot.Visible = anyClaimable
end)

-- ════════════════════════════════════════════════════════════
-- ── INVENTAR-Befüllung (InventorySync) ──────────────────────
-- ════════════════════════════════════════════════════════════
local useRemote = Net.Event("UseItem")
local function rebuildInventory(inv: any)
	for _, child in ipairs(invScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local count = 0
	local order = 0
	for itemId, n in pairs(inv) do
		if n and n > 0 then
			local item = ShopData.GetItem(itemId)
			if item then
				count += 1; order += 1
				local row = Instance.new("Frame")
				row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,56)
				row.BackgroundColor3 = C.bg3; row.BorderSizePixel = 0
				corner(row,8); stroke(row,C.border); row.Parent = invScroll

				local col = RARITY[item.rarity] or C.t1
				mkLabel(row, ("%s  %s  ×%d"):format(item.icon, item.name, n), UDim2.new(1,-120,0,18), UDim2.fromOffset(12,8), col, 14, Enum.Font.GothamBold)
				local d = mkLabel(row, item.desc, UDim2.new(1,-120,0,20), UDim2.fromOffset(12,28), C.t2, 11)
				d.TextWrapped = true

				local use = mkButton(row, "Verwenden", UDim2.new(0,100,0,36), UDim2.new(1,-112,0.5,-18), C.green)
				use.TextSize = 12
				use.MouseButton1Click:Connect(function()
					useRemote:FireServer(itemId)
				end)
			end
		end
	end
	invEmpty.Visible = (count == 0)
end

Net.Event("InventorySync").OnClientEvent:Connect(rebuildInventory)

-- Kauf-/Nutzungs-Feedback (Fehlermeldungen; Erfolg kommt via Notify).
buyRemote.OnClientEvent:Connect(function(ok: boolean, msg: string)
	if not ok then showToast("❌ " .. tostring(msg), "warn") end
end)
useRemote.OnClientEvent:Connect(function(ok: boolean, msg: string)
	if not ok then showToast("❌ " .. tostring(msg), "warn") end
end)

-- Shop-Stones-Anzeige aktuell halten.
bindAttr("SpiritStones", function(v) shopStonesL.Text = "💰 " .. fmt(v) end)

-- ════════════════════════════════════════════════════════════
-- ── TECHNIK (aktive Dao-Fähigkeit) ──────────────────────────
-- ════════════════════════════════════════════════════════════
local useTechRemote = Net.Event("UseTechnique")
local function tryUseTechnique()
	if player:GetAttribute("InMenu") or player:GetAttribute("InSeclusion") then return end
	useTechRemote:FireServer()
end
techBtn.MouseButton1Click:Connect(tryUseTechnique)

Net.Event("TechniqueUsed").OnClientEvent:Connect(function(name: string, icon: string)
	showToast(("%s %s eingesetzt!"):format(icon, name), "info")
end)

-- ── Tastatur: Q = Technik ──────────────────────────────────
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Q then
		tryUseTechnique()
	elseif input.KeyCode == Enum.KeyCode.Escape then
		closeAllOverlays()
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Sekündlicher Tick: Technik-Cooldown + Buff-Anzeige ──────
-- ════════════════════════════════════════════════════════════
task.spawn(function()
	while true do
		task.wait(0.25)

		-- Technik-Cooldown
		local cdUntil = player:GetAttribute("TechCooldownUntil") or 0
		local remaining = cdUntil - os.time()
		local dao = player:GetAttribute("DaoAffinity")
		local tech = dao and TechniqueData.GetForDao(dao)
		if remaining > 0 then
			techBtn.Text = ("⏳ %ds"):format(math.ceil(remaining))
			techBtn.BackgroundColor3 = C.bg5
		else
			techBtn.Text = tech and (tech.icon .. " " .. tech.name .. "  (Q)") or "⚔️ Technik (Q)"
			techBtn.BackgroundColor3 = C.bg3
		end

		-- Buff-Anzeige
		local expR = Buffs.Remaining(player, "Exp")
		local dmgR = Buffs.Remaining(player, "Dmg")
		local parts = {}
		if expR > 0 then
			table.insert(parts, ("🌀 EXP ×%.1f %s"):format(player:GetAttribute("ExpBuffMult") or 1, formatTime(expR)))
		end
		if dmgR > 0 then
			table.insert(parts, ("🔴 DMG ×%.1f %s"):format(player:GetAttribute("DmgBuffMult") or 1, formatTime(dmgR)))
		end
		if #parts > 0 then
			buffLabel.Text = table.concat(parts, "   ")
			buffLabel.TextColor3 = C.cyan
			buffPanel.Visible = true
		else
			buffLabel.Text = "Keine aktiven Buffs"
			buffLabel.TextColor3 = C.t3
			buffPanel.Visible = true
		end
	end
end)

print("[TTP] UIController geladen — Shop, Quests, Technik, Inventar aktiv.")
