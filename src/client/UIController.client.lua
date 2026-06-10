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
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local NPCData       = require(GameData:WaitForChild("NPCData"))
local Config        = require(ReplicatedStorage:WaitForChild("Config"))

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

local function lighten(c: Color3, amt: number): Color3
	return Color3.new(
		math.clamp(c.R + amt, 0, 1),
		math.clamp(c.G + amt, 0, 1),
		math.clamp(c.B + amt, 0, 1))
end

local function mkButton(parent: Instance, text: string, size: UDim2, pos: UDim2,
		col: Color3, anchor: Vector2?): TextButton
	local b = Instance.new("TextButton")
	b.Size = size; b.Position = pos
	if anchor then b.AnchorPoint = anchor end
	b.BackgroundColor3 = col; b.Text = text
	b.TextColor3 = C.t1; b.TextSize = 14; b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false; corner(b, 8); b.Parent = parent

	-- Hover + press feedback (lighten on enter, slight grow; restore on leave).
	local baseSize = size
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = lighten(col, 0.10) }):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = col, Size = baseSize }):Play()
	end)
	b.MouseButton1Down:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.08), { BackgroundColor3 = lighten(col, -0.06) }):Play()
	end)
	b.MouseButton1Up:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.08), { BackgroundColor3 = lighten(col, 0.10) }):Play()
	end)
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
local worldLayer     = mkOverlay("WorldLayer")
local companionLayer = mkOverlay("CompanionLayer")
local formationLayer = mkOverlay("FormationLayer")
local titleLayer     = mkOverlay("TitleLayer")
local dungeonLayer   = mkOverlay("DungeonLayer")
local leaderLayer    = mkOverlay("LeaderLayer")
local bookLayer      = mkOverlay("BookLayer")
local storeLayer     = mkOverlay("StoreLayer")
local SectData       = require(GameData:WaitForChild("SectData"))
local CompanionData  = require(GameData:WaitForChild("CompanionData"))
local FormationData  = require(GameData:WaitForChild("FormationData"))
local TitleData      = require(GameData:WaitForChild("TitleData"))
local DungeonData    = require(GameData:WaitForChild("DungeonData"))

-- Teleport target for a realm zone (matches the NPCService spawn layout).
local WorldData = require(GameData:WaitForChild("WorldData"))
local function realmZonePosition(realmId: number): Vector3
	return WorldData.TeleportPosition(realmId)
end

-- Vorwärts-Deklaration (Definition weiter unten bei den Button-Bindungen).
local closeAllOverlays: () -> ()
local showToast: (string, string?) -> ()

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
local techPanel = mkPanel("TechPanel", UDim2.new(0,380,0,34), UDim2.new(0.5,0,1,-150), Vector2.new(0.5,1), hudRoot)
local techFill  = mkBar(techPanel, C.a1, UDim2.new(0,12,0,18), 8)
local techLabel = mkLabel(techPanel,"[Q] Technique ready",UDim2.new(1,-24,0,14),UDim2.new(0,12,0,2),C.t3,10,nil,Enum.TextXAlignment.Center)

-- Status-effect badge strip (above the technique bar)
local statusStrip = Instance.new("Frame")
statusStrip.Size = UDim2.new(0,380,0,24); statusStrip.Position = UDim2.new(0.5,0,1,-186)
statusStrip.AnchorPoint = Vector2.new(0.5,1); statusStrip.BackgroundTransparency = 1
statusStrip.Parent = hudRoot
local statusLayout = Instance.new("UIListLayout")
statusLayout.FillDirection = Enum.FillDirection.Horizontal
statusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statusLayout.Padding = UDim.new(0,4); statusLayout.Parent = statusStrip

local STATUS_ICON = {
	burn="🔥", poison="🟢", freeze="❄️", stun="💫", bleed="🩸", weakened="🔻",
	silence="🔇", regenerating="💚", empowered="💪", shielded="🛡️", haste="💨",
	qi_surge="🌀", dao_insight="☯️", charged="⚡",
}
local activeBadges: { [string]: TextLabel } = {}
local function showStatus(effectId: string, kind: string, duration: number)
	local existing = activeBadges[effectId]
	if existing then existing:Destroy() end
	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.fromOffset(30,24); badge.BackgroundColor3 = kind == "BUFF" and Color3.fromHex("123022") or Color3.fromHex("301216")
	badge.Text = STATUS_ICON[effectId] or "✦"; badge.TextSize = 14; badge.Font = Enum.Font.GothamBold
	badge.TextColor3 = C.t1; corner(badge,5); stroke(badge, kind == "BUFF" and C.green or C.hp)
	badge.Parent = statusStrip
	activeBadges[effectId] = badge
	task.delay(duration, function()
		if activeBadges[effectId] == badge then activeBadges[effectId] = nil; badge:Destroy() end
	end)
end

local seclPanel = mkPanel("SeclPanel", UDim2.new(0,215,0,90), UDim2.new(0,14,1,-14), Vector2.new(0,1), hudRoot)
local seclBtn   = mkButton(seclPanel,"🧘 Enter Seclusion",UDim2.new(1,-16,0,36),UDim2.new(0,8,0,8),C.a1)
local seclStatus = mkLabel(seclPanel,"Seclusion: Inactive",UDim2.new(1,-16,0,16),UDim2.new(0,8,0,50),C.t3,11)
local seclTimer  = mkLabel(seclPanel,"",UDim2.new(1,-16,0,16),UDim2.new(0,8,0,68),C.cyan,11,Enum.Font.GothamBold)

-- Bottom-right buttons
local invBtn      = mkButton(hudRoot,"🎒",UDim2.new(0,46,0,46),UDim2.new(1,-14,1,-14),  C.bg4,Vector2.new(1,1))
local shopBtn     = mkButton(hudRoot,"🏪",UDim2.new(0,46,0,46),UDim2.new(1,-66,1,-14),  C.bg4,Vector2.new(1,1))
local questBtn    = mkButton(hudRoot,"📜",UDim2.new(0,46,0,46),UDim2.new(1,-118,1,-14), C.bg4,Vector2.new(1,1))
local sectBtn     = mkButton(hudRoot,"🏯",UDim2.new(0,46,0,46),UDim2.new(1,-170,1,-14), C.bg4,Vector2.new(1,1))
local worldBtn    = mkButton(hudRoot,"🌀",UDim2.new(0,46,0,46),UDim2.new(1,-222,1,-14), C.bg4,Vector2.new(1,1))
local mainMenuBtn = mkButton(hudRoot,"≡", UDim2.new(0,38,0,38),UDim2.new(1,-14,0,14),   C.bg4,Vector2.new(1,0))

local seclAbortBtn = mkButton(hudRoot,"⚠️ Cancel Seclusion (−30%)",
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
local yearLabel    = mkLabel(spinnerRow,"1 Year",UDim2.new(1,-80,1,0),UDim2.fromOffset(42,0),C.t1,16,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
yearLabel.TextYAlignment = Enum.TextYAlignment.Center
local yearPlusBtn  = mkButton(spinnerRow,"＋",UDim2.new(0,36,0,36),UDim2.new(1,-36,0,0),C.bg5)
local seclPreviewEXP    = mkLabel(seclPopup,"⚡ EXP: —",      UDim2.new(1,-20,0,16),UDim2.new(0,10,0,88), C.exp,12)
local seclPreviewStones = mkLabel(seclPopup,"💰 Stones: —",   UDim2.new(1,-20,0,16),UDim2.new(0,10,0,108),C.gold,12)
local seclPreviewAge    = mkLabel(seclPopup,"⏳ Ages by: —", UDim2.new(1,-20,0,16),UDim2.new(0,10,0,128),C.warn,12)
local seclPreviewTime   = mkLabel(seclPopup,"🕑 Real time: —",  UDim2.new(1,-20,0,16),UDim2.new(0,10,0,148),C.t2,12)
local seclConfirmBtn    = mkButton(seclPopup,"✓ Start Seclusion",UDim2.new(1,-20,0,36),UDim2.new(0,10,1,-46),C.green)
local seclCancelPopup   = mkButton(seclPopup,"✕ Cancel",      UDim2.new(1,-20,0,20),UDim2.new(0,10,1,-22),C.bg4)

-- ════════════════════════════════════════════════════════════
-- ── Main Menu overlay
-- ════════════════════════════════════════════════════════════
local mainMenuCard = mkPanel("Card",UDim2.new(0,420,0,420),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), mainMenuLayer)
mkLabel(mainMenuCard,"☯️  CULTIVATION HUB",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,20,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local closeMainMenu = mkButton(mainMenuCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5); closeMainMenu.TextSize = 16

local hubGrid = Instance.new("Frame")
hubGrid.Size = UDim2.new(1,-24,1,-56); hubGrid.Position = UDim2.fromOffset(12,48)
hubGrid.BackgroundTransparency = 1; hubGrid.Parent = mainMenuCard
local hubLayout = Instance.new("UIGridLayout")
hubLayout.CellSize = UDim2.fromOffset(126,56); hubLayout.CellPadding = UDim2.fromOffset(8,8)
hubLayout.Parent = hubGrid

-- hub buttons are wired further down once all rebuild fns exist
local hubButtons: { [string]: TextButton } = {}
local function hubBtn(key: string, text: string)
	local b = mkButton(hubGrid, text, UDim2.fromOffset(126,56), UDim2.fromOffset(0,0), C.bg4)
	b.TextSize = 13
	hubButtons[key] = b
end
hubBtn("providence","📖 Providence")
hubBtn("shop","🏪 Shop")
hubBtn("quests","📜 Quests")
hubBtn("sects","🏯 Sects")
hubBtn("companions","🐾 Companions")
hubBtn("formations","⭕ Formations")
hubBtn("titles","🏆 Titles")
hubBtn("dungeons","🗺️ Dungeons")
hubBtn("world","🌀 Teleport")
hubBtn("leaderboard","👑 Leaderboard")
hubBtn("book","📖 Book of Fate")
hubBtn("pvp","⚔️ Toggle PvP")
hubBtn("store","💎 Store")
hubBtn("leave","🔄 Leave")

-- ════════════════════════════════════════════════════════════
-- ── Inventory overlay
-- ════════════════════════════════════════════════════════════
local invCard = mkPanel("InvCard",UDim2.new(0,720,0,500),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), inventoryLayer)
mkLabel(invCard,"🎒  INVENTORY & EQUIPMENT",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeInv = mkButton(invCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)

-- ── Left: character paperdoll ───────────────────────────────
local dollPanel = Instance.new("Frame")
dollPanel.Size = UDim2.new(0,300,1,-60); dollPanel.Position = UDim2.fromOffset(12,50)
dollPanel.BackgroundColor3 = C.bg3; dollPanel.BorderSizePixel = 0
corner(dollPanel,8); stroke(dollPanel,C.border); dollPanel.Parent = invCard
mkLabel(dollPanel,"EQUIPMENT",UDim2.new(1,-20,0,16),UDim2.fromOffset(12,8),C.t3,11,Enum.Font.GothamBold)

-- Simple character silhouette in the centre
local charBody = Instance.new("Frame")
charBody.Size = UDim2.fromOffset(70,150); charBody.Position = UDim2.new(0.5,0,0,40)
charBody.AnchorPoint = Vector2.new(0.5,0); charBody.BackgroundColor3 = C.bg5
charBody.BorderSizePixel = 0; corner(charBody,10); stroke(charBody, C.a1); charBody.Parent = dollPanel
mkLabel(charBody,"🧍",UDim2.fromScale(1,1),UDim2.fromOffset(0,0),C.t2,46,nil,Enum.TextXAlignment.Center).TextYAlignment = Enum.TextYAlignment.Center

-- Slot definitions: label + position around the silhouette
local SLOT_DEFS = {
	{ slot="head",     icon="⛑️", name="Head",     pos=UDim2.new(0.5,-35,0,40) },
	{ slot="necklace", icon="📿", name="Necklace", pos=UDim2.new(0.5,-35,0,90) },
	{ slot="body",     icon="🥋", name="Body",     pos=UDim2.new(0,16,0,140) },
	{ slot="weapon",   icon="⚔️", name="Weapon",   pos=UDim2.new(1,-76,0,140) },
	{ slot="ring",     icon="💍", name="Ring",     pos=UDim2.new(1,-76,0,196) },
	{ slot="legs",     icon="👖", name="Legs",     pos=UDim2.new(0,16,0,196) },
	{ slot="feet",     icon="🥾", name="Feet",     pos=UDim2.new(0.5,-35,0,250) },
}
local slotFrames: { [string]: { frame: Frame, label: TextLabel } } = {}
local equipState: { [string]: number? } = {}

local unequipRemote = Net.Event("UnequipItem")
for _, def in ipairs(SLOT_DEFS) do
	local sf = Instance.new("TextButton")
	sf.Size = UDim2.fromOffset(60,60); sf.Position = def.pos
	sf.BackgroundColor3 = C.bg4; sf.BorderSizePixel = 0; sf.AutoButtonColor = false
	sf.Text = ""; corner(sf,8); stroke(sf,C.border); sf.Parent = dollPanel
	local ic = mkLabel(sf, def.icon, UDim2.new(1,0,0,28), UDim2.fromOffset(0,6), C.t3, 20, nil, Enum.TextXAlignment.Center)
	ic.TextYAlignment = Enum.TextYAlignment.Center
	local nm = mkLabel(sf, def.name, UDim2.new(1,0,0,14), UDim2.fromOffset(0,40), C.t3, 9, nil, Enum.TextXAlignment.Center)
	local thisSlot = def.slot
	sf.MouseButton1Click:Connect(function()
		if equipState[thisSlot] then unequipRemote:FireServer(thisSlot) end
	end)
	sf.MouseEnter:Connect(function() sf.BackgroundColor3 = C.bg5 end)
	sf.MouseLeave:Connect(function() sf.BackgroundColor3 = C.bg4 end)
	slotFrames[def.slot] = { frame = sf, label = nm }
	_ = ic
end

local function rebuildEquipment(equipment: { [string]: number? })
	for slot, data in pairs(slotFrames) do
		local itemId = equipment[slot]
		equipState[slot] = itemId
		local item = itemId and ItemData.GetItem(itemId)
		if item then
			local rar = RARITY[item.rarity] or C.gold
			data.frame.Text = item.icon
			data.frame.TextColor3 = rar
			data.frame.TextScaled = false
			data.frame.Font = Enum.Font.GothamBold
			data.frame.TextSize = 22
			(data.frame :: any).TextYAlignment = Enum.TextYAlignment.Center
			data.label.Text = item.name
			data.label.TextColor3 = rar
			local st = data.frame:FindFirstChildOfClass("UIStroke"); if st then st.Color = rar end
		else
			-- restore empty look
			for _, def in ipairs(SLOT_DEFS) do
				if def.slot == slot then
					data.frame.Text = def.icon
					data.frame.TextColor3 = C.t3
					data.frame.TextSize = 20
					data.label.Text = def.name
					data.label.TextColor3 = C.t3
					local st = data.frame:FindFirstChildOfClass("UIStroke"); if st then st.Color = C.border end
				end
			end
		end
	end
end

-- ── Right: scrollable item list ─────────────────────────────
local invList, _ = mkScrollList(invCard, UDim2.new(1,-336,1,-60), UDim2.fromOffset(324,50))

local function rebuildInventory(inventory: {[any]: any})
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
		mkLabel(row, item.icon .. "  " .. item.name, UDim2.new(1,-110,0,20), UDim2.fromOffset(8,6), rarCol, 12, Enum.Font.GothamBold)
		mkLabel(row, ("%s · ×%d"):format(item.rarity, count), UDim2.new(1,-110,0,16), UDim2.fromOffset(8,28), C.t3, 10)

		local thisId = itemId
		if ItemData.IsUsable(item) then
			local useBtn = mkButton(row, "Use", UDim2.new(0,90,0,30), UDim2.new(1,-98,0.5,-15), C.green)
			useBtn.TextSize = 12
			useBtn.MouseButton1Click:Connect(function() Net.Event("UseItem"):FireServer(thisId) end)
		elseif ItemData.IsEquippable(item) then
			local eqBtn = mkButton(row, "Equip", UDim2.new(0,90,0,30), UDim2.new(1,-98,0.5,-15), C.a1)
			eqBtn.TextSize = 12
			eqBtn.MouseButton1Click:Connect(function() Net.Event("EquipItem"):FireServer(thisId) end)
		else
			mkLabel(row, item.itype, UDim2.new(0,90,0,20), UDim2.new(1,-98,0.5,-10), C.t3, 10, nil, Enum.TextXAlignment.Center)
		end
	end

	if not hasItems then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,0,0,40); empty.BackgroundTransparency = 1
		empty.Text = "— Inventory empty —"; empty.TextColor3 = C.t3
		empty.TextSize = 13; empty.Font = Enum.Font.Gotham
		empty.TextXAlignment = Enum.TextXAlignment.Center
		empty.Parent = invList
	end
end

Net.Event("EquipmentSync").OnClientEvent:Connect(function(equipment: any)
	rebuildEquipment(equipment)
end)

-- ════════════════════════════════════════════════════════════
-- ── Shop overlay
-- ════════════════════════════════════════════════════════════
local shopCard = mkPanel("ShopCard",UDim2.new(0,580,0,520),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), shopLayer)
mkLabel(shopCard,"🏪  SHOP — Spirit Stone Merchant",UDim2.new(1,-200,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeShop = mkButton(shopCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
local shopStoneL = mkLabel(shopCard,"💰 —",UDim2.new(0,160,0,20),UDim2.new(1,-180,0,12),C.gold,13,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
local shopRealmL = mkLabel(shopCard,"",UDim2.new(0,160,0,16),UDim2.new(1,-180,0,32),C.t3,10,nil,Enum.TextXAlignment.Right)

local shopList, _ = mkScrollList(shopCard, UDim2.new(1,-20,1,-68), UDim2.fromOffset(10,60))

-- Rebuild the shop catalogue for the player's current realm (items unlock
-- progressively, so the stock scales with cultivation level).
local function rebuildShop()
	for _, c in ipairs(shopList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	local realm = (player:GetAttribute("Realm") or 1) :: number
	local realmName = player:GetAttribute("RealmName") or "?"
	shopRealmL.Text = ("Realm %d · %s"):format(realm, realmName)

	local buyRemote = Net.Event("BuyItem")
	local catalog = ItemData.CatalogForRealm(realm)
	for order, item in ipairs(catalog) do
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,56); row.BackgroundColor3 = C.bg3
		row.BorderSizePixel = 0; corner(row,6); stroke(row,C.border)
		row.Parent = shopList

		local rarCol = RARITY[item.rarity] or C.t1
		local tag = item.itype == "equipment" and ("  [%s]"):format(item.slot or "gear") or ""
		mkLabel(row, item.icon .. "  " .. item.name .. tag, UDim2.new(1,-95,0,20), UDim2.fromOffset(8,4), rarCol, 12, Enum.Font.GothamBold)
		mkLabel(row, item.desc, UDim2.new(1,-180,0,28), UDim2.fromOffset(8,26), C.t3, 10).TextWrapped = true
		mkLabel(row, "💰 " .. fmt(item.cost), UDim2.new(0,90,0,18), UDim2.new(1,-98,0,6), C.gold, 12, Enum.Font.GothamBold, Enum.TextXAlignment.Right)

		local buyBtn = mkButton(row,"Buy",UDim2.new(0,82,0,28),UDim2.new(1,-90,0,26),C.a1)
		buyBtn.TextSize = 12
		local thisId = item.id
		buyBtn.MouseButton1Click:Connect(function() buyRemote:FireServer(thisId) end)
	end
end

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
		row.Size = UDim2.new(1,0,0,64); row.BorderSizePixel = 0
		row.BackgroundColor3 = qs.claimed and C.bg3 or (qs.complete and Color3.fromHex("0D1F16") or C.bg3)
		corner(row,6); stroke(row, qs.complete and (qs.claimed and C.border or C.green) or C.border)
		row.Parent = questList

		-- Left text block (leaves 110px on the right for the action button)
		local qtypeCol = QTYPE_COLOR[q.qtype] or C.t2
		mkLabel(row, q.qtype, UDim2.new(1,-120,0,14), UDim2.fromOffset(10,5), qtypeCol, 9, Enum.Font.GothamBold)
		mkLabel(row, q.name, UDim2.new(1,-120,0,20), UDim2.fromOffset(10,19), C.t1, 13, Enum.Font.GothamBold)

		-- Combined requirement + reward on one line (no overlap with button)
		local rewStr = ""
		if q.rewardExp > 0 then rewStr = "+" .. fmt(q.rewardExp) .. " EXP" end
		if q.rewardStones > 0 then
			rewStr = rewStr .. (rewStr ~= "" and " · " or "") .. "💰" .. fmt(q.rewardStones)
		end
		local botLine = reqText(q) .. (rewStr ~= "" and ("   →   " .. rewStr) or "")
		mkLabel(row, botLine, UDim2.new(1,-120,0,14), UDim2.fromOffset(10,42), C.t3, 10)

		-- Right-side action (vertically centred, fixed 96px column)
		if qs.claimed then
			mkLabel(row,"✓ Claimed",UDim2.new(0,96,0,28),UDim2.new(1,-104,0.5,-14),C.t3,11,nil,Enum.TextXAlignment.Center)
		elseif qs.complete then
			local claimBtn = mkButton(row,"Claim",UDim2.new(0,96,0,30),UDim2.new(1,-104,0.5,-15),C.green)
			claimBtn.TextSize = 12
			local thisId = q.id
			claimBtn.MouseButton1Click:Connect(function()
				claimRemote:FireServer(thisId)
			end)
		else
			mkLabel(row,"⏳ Locked",UDim2.new(0,96,0,28),UDim2.new(1,-104,0.5,-14),C.t3,11,nil,Enum.TextXAlignment.Center)
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
local sectStatusL = mkLabel(sectCard,"No sect joined",UDim2.new(1,-30,0,18),UDim2.fromOffset(15,40),C.t2,12)

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
		mkLabel(row, ("Realm %d required · Max Level %d"):format(sect.reqRealm, sect.maxLevel),
			UDim2.new(1,-20,0,14), UDim2.fromOffset(10,60), C.t2, 10)

		-- Milestone preview
		local msParts = {}
		for _, m in ipairs(sect.milestones) do
			table.insert(msParts, ("L%d: %s"):format(m.level, m.name))
		end
		mkLabel(row, table.concat(msParts, "  ·  "), UDim2.new(1,-20,0,14), UDim2.fromOffset(10,76), C.a1, 9)

		if joined then
			mkLabel(row, ("✓ Joined — Level %d"):format(currentSectLevel),
				UDim2.new(0,200,0,28), UDim2.new(0,10,0,90), C.gold, 12, Enum.Font.GothamBold)
		elseif playerRealm >= sect.reqRealm then
			local joinBtn = mkButton(row,"Join",UDim2.new(0,110,0,30),UDim2.new(1,-120,0,82),C.a1)
			joinBtn.TextSize = 12
			local thisId = sect.id
			joinBtn.MouseButton1Click:Connect(function() joinSectRemote:FireServer(thisId) end)
		else
			mkLabel(row, ("🔒 Realm %d needed"):format(sect.reqRealm),
				UDim2.new(0,140,0,28), UDim2.new(1,-150,0,90), C.t3, 11, nil, Enum.TextXAlignment.Center)
		end
	end
end

Net.Event("SectSync").OnClientEvent:Connect(function(data: any)
	currentSectId = data.sectId
	currentSectLevel = data.level or 0
	if data.sectName then
		sectStatusL.Text = ("Sect: %s · Level %d · %s (EXP %d/%d)"):format(
			data.sectName, data.level or 0, data.buffName or "—",
			math.floor(data.exp or 0), math.floor(data.expNeeded or 0))
		sectStatusL.TextColor3 = C.gold
	else
		sectStatusL.Text = "No sect joined"
		sectStatusL.TextColor3 = C.t2
	end
	if sectLayer.Visible then rebuildSects() end
end)

-- ════════════════════════════════════════════════════════════
-- ── World / Teleport overlay
-- ════════════════════════════════════════════════════════════
local worldCard = mkPanel("WorldCard",UDim2.new(0,560,0,520),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), worldLayer)
mkLabel(worldCard,"🌀  WORLDS — Teleport",UDim2.new(1,-30,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
local closeWorld = mkButton(worldCard,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
mkLabel(worldCard,"Travel between cultivation realms. Higher realms hold deadlier foes.",
	UDim2.new(1,-30,0,16),UDim2.fromOffset(15,40),C.t3,11)

local worldList, _ = mkScrollList(worldCard, UDim2.new(1,-20,1,-66), UDim2.fromOffset(10,58))

local function doTeleport(realmId: number)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end
	root.CFrame = CFrame.new(realmZonePosition(realmId) + Vector3.new(0, 3, 0))
	worldLayer.Visible = false
	local realm = CultivationData.GetRealm(realmId)
	showToast(("🌀 Teleported to %s (Realm %d)"):format(realm and realm.name or "?", realmId), "info")
end

local function rebuildWorlds()
	for _, c in ipairs(worldList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	local playerRealm = (player:GetAttribute("Realm") or 1) :: number
	local realms = NPCData.GetImplementedRealms()
	for order, realmId in ipairs(realms) do
		local realm = CultivationData.GetRealm(realmId)
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,56); row.BorderSizePixel = 0
		row.BackgroundColor3 = realmId == playerRealm and Color3.fromHex("121E2E") or C.bg3
		corner(row,6); stroke(row, realmId == playerRealm and C.gold or C.border)
		row.Parent = worldList

		local col = realm and Color3.fromHex(realm.color or "60A5FA") or C.t1
		mkLabel(row, ("Realm %d — %s"):format(realmId, realm and realm.name or "?"),
			UDim2.new(1,-130,0,22), UDim2.fromOffset(10,6), col, 14, Enum.Font.GothamBold)
		mkLabel(row, ("%s Tier · 10 foes%s"):format(realm and realm.tier or "?",
			realmId == playerRealm and "  · YOU ARE HERE" or ""),
			UDim2.new(1,-130,0,16), UDim2.fromOffset(10,30), C.t3, 10)

		local danger = realmId > playerRealm
		local tpBtn = mkButton(row, danger and "⚠ Travel" or "Travel",
			UDim2.new(0,100,0,30), UDim2.new(1,-110,0.5,-15), danger and C.warn or C.a1)
		tpBtn.TextSize = 12
		local thisRealm = realmId
		tpBtn.MouseButton1Click:Connect(function() doTeleport(thisRealm) end)
	end
end

-- ════════════════════════════════════════════════════════════
-- ── Generic system overlays (companions, formations, titles, …)
-- ════════════════════════════════════════════════════════════
local function mkSystemCard(layer: Frame, title: string): (Frame, ScrollingFrame, TextLabel)
	local card = mkPanel("Card",UDim2.new(0,600,0,520),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5), layer)
	mkLabel(card,title,UDim2.new(1,-200,0,24),UDim2.fromOffset(15,14),C.gold,18,Enum.Font.GothamBold)
	local close = mkButton(card,"✕",UDim2.new(0,28,0,28),UDim2.new(1,-36,0,8),C.bg5)
	close.MouseButton1Click:Connect(function() layer.Visible = false end)
	local info = mkLabel(card,"",UDim2.new(0,260,0,18),UDim2.new(1,-300,0,18),C.t2,11,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
	local list, _ = mkScrollList(card, UDim2.new(1,-20,1,-60), UDim2.fromOffset(10,52))
	return card, list, info
end

-- ── Companions ──────────────────────────────────────────────
local _, compList, compInfo = mkSystemCard(companionLayer, "🐾  SPIRIT COMPANIONS")
local compState = { owned = {}, active = nil }
local buyCompanion = Net.Event("BuyCompanion")
local setCompanion = Net.Event("SetCompanion")
local function rebuildCompanions()
	for _, c in ipairs(compList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local stones = player:GetAttribute("SpiritStones") or 0
	compInfo.Text = "💰 " .. fmt(stones)
	for order, c in ipairs(CompanionData.COMPANIONS) do
		local owned = compState.owned[c.id]
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,64); row.BorderSizePixel = 0
		row.BackgroundColor3 = compState.active == c.id and Color3.fromHex("121E2E") or C.bg3
		corner(row,6); stroke(row, compState.active == c.id and C.gold or C.border); row.Parent = compList
		local rar = RARITY[c.rarity] or C.t1
		mkLabel(row, c.icon .. "  " .. c.name, UDim2.new(1,-130,0,20), UDim2.fromOffset(10,6), rar, 13, Enum.Font.GothamBold)
		mkLabel(row, c.desc, UDim2.new(1,-130,0,16), UDim2.fromOffset(10,28), C.t3, 10)
		mkLabel(row, owned and ("Bond Lv %d/10"):format(owned.level) or ("💰 " .. fmt(c.cost)),
			UDim2.new(1,-130,0,14), UDim2.fromOffset(10,46), owned and C.cyan or C.gold, 10)
		if not owned then
			local b = mkButton(row,"Tame",UDim2.new(0,100,0,30),UDim2.new(1,-110,0.5,-15),C.a1); b.TextSize=12
			b.MouseButton1Click:Connect(function() buyCompanion:FireServer(c.id) end)
		elseif compState.active == c.id then
			mkLabel(row,"✓ Active",UDim2.new(0,100,0,28),UDim2.new(1,-110,0.5,-14),C.gold,12,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
		else
			local b = mkButton(row,"Summon",UDim2.new(0,100,0,30),UDim2.new(1,-110,0.5,-15),C.green); b.TextSize=12
			b.MouseButton1Click:Connect(function() setCompanion:FireServer(c.id) end)
		end
	end
end
Net.Event("CompanionSync").OnClientEvent:Connect(function(data: any)
	compState.owned = data.owned or {}; compState.active = data.active
	if companionLayer.Visible then rebuildCompanions() end
end)

-- ── Formations ──────────────────────────────────────────────
local _, formList, formInfo = mkSystemCard(formationLayer, "⭕  FORMATIONS")
local formState = { owned = {}, active = nil }
local buyFormation = Net.Event("BuyFormation")
local setFormation = Net.Event("SetFormation")
local function rebuildFormations()
	for _, c in ipairs(formList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	formInfo.Text = "💰 " .. fmt(player:GetAttribute("SpiritStones") or 0)
	local realm = player:GetAttribute("Realm") or 1
	for order, f in ipairs(FormationData.FORMATIONS) do
		local owned = formState.owned[f.id]
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,62); row.BorderSizePixel = 0
		row.BackgroundColor3 = formState.active == f.id and Color3.fromHex("121E2E") or C.bg3
		corner(row,6); stroke(row, formState.active == f.id and C.gold or C.border); row.Parent = formList
		mkLabel(row, f.icon .. "  " .. f.name .. ("  [%s]"):format(f.ftype), UDim2.new(1,-130,0,20), UDim2.fromOffset(10,5), C.t1, 12, Enum.Font.GothamBold)
		mkLabel(row, f.bonusText, UDim2.new(1,-130,0,16), UDim2.fromOffset(10,26), C.green, 10)
		mkLabel(row, ("Realm %d · %s"):format(f.reqRealm, f.cost > 0 and ("💰"..fmt(f.cost)) or "Free"),
			UDim2.new(1,-130,0,14), UDim2.fromOffset(10,44), C.t3, 10)
		if not owned then
			local locked = realm < f.reqRealm
			local b = mkButton(row, locked and "🔒" or "Learn", UDim2.new(0,100,0,30),UDim2.new(1,-110,0.5,-15), locked and C.bg5 or C.a1); b.TextSize=12
			if not locked then b.MouseButton1Click:Connect(function() buyFormation:FireServer(f.id) end) end
		elseif formState.active == f.id then
			mkLabel(row,"✓ Active",UDim2.new(0,100,0,28),UDim2.new(1,-110,0.5,-14),C.gold,12,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
		else
			local b = mkButton(row,"Activate",UDim2.new(0,100,0,30),UDim2.new(1,-110,0.5,-15),C.green); b.TextSize=12
			b.MouseButton1Click:Connect(function() setFormation:FireServer(f.id) end)
		end
	end
end
Net.Event("FormationSync").OnClientEvent:Connect(function(data: any)
	formState.owned = data.owned or {}; formState.active = data.active
	if formationLayer.Visible then rebuildFormations() end
end)

-- ── Titles ──────────────────────────────────────────────────
local _, titleList, titleInfo = mkSystemCard(titleLayer, "🏆  TITLES")
local titleState = { unlocked = {}, active = nil }
local setTitle = Net.Event("SetTitle")
local function rebuildTitles()
	for _, c in ipairs(titleList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local n = 0; for _ in pairs(titleState.unlocked) do n += 1 end
	titleInfo.Text = ("%d / %d unlocked"):format(n, #TitleData.TITLES)
	for order, t in ipairs(TitleData.TITLES) do
		local unlocked = titleState.unlocked[t.id]
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,52); row.BorderSizePixel = 0
		row.BackgroundColor3 = titleState.active == t.id and Color3.fromHex("121E2E") or C.bg3
		corner(row,6); stroke(row, titleState.active == t.id and C.gold or C.border); row.Parent = titleList
		local rar = RARITY[t.rarity] or C.t1
		mkLabel(row, t.icon .. "  " .. t.name, UDim2.new(1,-120,0,20), UDim2.fromOffset(10,6), unlocked and rar or C.t3, 13, Enum.Font.GothamBold)
		mkLabel(row, unlocked and t.desc or ("🔒 " .. t.desc), UDim2.new(1,-120,0,16), UDim2.fromOffset(10,28), C.t3, 10)
		if unlocked then
			if titleState.active == t.id then
				mkLabel(row,"✓ Worn",UDim2.new(0,96,0,28),UDim2.new(1,-106,0.5,-14),C.gold,12,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
			else
				local b = mkButton(row,"Equip",UDim2.new(0,96,0,28),UDim2.new(1,-106,0.5,-14),C.green); b.TextSize=12
				b.MouseButton1Click:Connect(function() setTitle:FireServer(t.id) end)
			end
		end
	end
end
Net.Event("TitleSync").OnClientEvent:Connect(function(data: any)
	titleState.unlocked = data.unlocked or {}; titleState.active = data.active
	if titleLayer.Visible then rebuildTitles() end
end)

-- ── Dungeons ────────────────────────────────────────────────
local _, dungList, dungInfo = mkSystemCard(dungeonLayer, "🗺️  DUNGEONS")
local dungState = { active = nil, cooldowns = {} }
local enterDungeon = Net.Event("EnterDungeon")
local exitDungeon  = Net.Event("ExitDungeon")
local function rebuildDungeons()
	for _, c in ipairs(dungList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local realm = player:GetAttribute("Realm") or 1
	dungInfo.Text = dungState.active and ("In: " .. (dungState.active.id or "")) or "Not in a dungeon"
	for order, d in ipairs(DungeonData.DUNGEONS) do
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,64); row.BorderSizePixel = 0
		local inThis = dungState.active and dungState.active.id == d.id
		row.BackgroundColor3 = inThis and Color3.fromHex("121E2E") or C.bg3
		corner(row,6); stroke(row, inThis and C.gold or C.border); row.Parent = dungList
		mkLabel(row, d.icon .. "  " .. d.name, UDim2.new(1,-130,0,20), UDim2.fromOffset(10,5), C.t1, 13, Enum.Font.GothamBold)
		mkLabel(row, ("%s · %d floors · EXP×%.1f Stones×%.1f"):format(d.desc, d.floors, d.expMult, d.stoneMult),
			UDim2.new(1,-130,0,16), UDim2.fromOffset(10,26), C.t3, 10)
		local cd = dungState.cooldowns[d.id] or 0
		mkLabel(row, ("Realm %d+%s"):format(d.reqRealm, cd > 0 and ("  · CD " .. formatTime(cd)) or ""),
			UDim2.new(1,-130,0,14), UDim2.fromOffset(10,44), cd>0 and C.warn or C.t3, 10)
		if inThis then
			local b = mkButton(row, ("Exit (F%d)"):format(dungState.active.floor or 1), UDim2.new(0,100,0,30),UDim2.new(1,-110,0.5,-15),C.hp); b.TextSize=12
			b.MouseButton1Click:Connect(function() exitDungeon:FireServer() end)
		else
			local locked = realm < d.reqRealm or cd > 0 or dungState.active ~= nil
			local b = mkButton(row, locked and "🔒" or "Enter", UDim2.new(0,100,0,30),UDim2.new(1,-110,0.5,-15), locked and C.bg5 or C.a1); b.TextSize=12
			if not locked then b.MouseButton1Click:Connect(function() enterDungeon:FireServer(d.id) end) end
		end
	end
end
Net.Event("DungeonSync").OnClientEvent:Connect(function(data: any)
	dungState.active = data.active; dungState.cooldowns = data.cooldowns or {}
	if dungeonLayer.Visible then rebuildDungeons() end
end)

-- ── Leaderboard ─────────────────────────────────────────────
local _, leaderList, _ = mkSystemCard(leaderLayer, "👑  LEADERBOARD")
local CAT_LABELS = { realm="⚡ Realm", exp="✨ Total EXP", kills="⚔️ Kills", pvp="🥊 PvP Wins", stones="💰 Stones", age="⏳ Oldest" }
local function rebuildLeaderboard(board: any)
	for _, c in ipairs(leaderList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local order = 0
	for _, cat in ipairs({"realm","exp","kills","pvp","stones","age"}) do
		order += 1
		local header = Instance.new("Frame"); header.LayoutOrder = order
		header.Size = UDim2.new(1,0,0,26); header.BackgroundColor3 = C.bg4; header.BorderSizePixel = 0
		corner(header,5); header.Parent = leaderList
		mkLabel(header, CAT_LABELS[cat], UDim2.new(1,-12,1,0), UDim2.fromOffset(10,0), C.gold, 12, Enum.Font.GothamBold).TextYAlignment = Enum.TextYAlignment.Center
		local rows = (board and board[cat]) or {}
		for i = 1, math.min(3, #rows) do
			order += 1
			local r = Instance.new("Frame"); r.LayoutOrder = order
			r.Size = UDim2.new(1,0,0,24); r.BackgroundColor3 = C.bg3; r.BorderSizePixel = 0; corner(r,4); r.Parent = leaderList
			local medal = i == 1 and "🥇" or i == 2 and "🥈" or "🥉"
			mkLabel(r, ("%s %s"):format(medal, rows[i].name), UDim2.new(0.6,0,1,0), UDim2.fromOffset(10,0), C.t1, 11).TextYAlignment = Enum.TextYAlignment.Center
			mkLabel(r, fmt(rows[i].value), UDim2.new(0.35,0,1,0), UDim2.new(0.6,0,0,0), C.cyan, 11, Enum.Font.GothamBold, Enum.TextXAlignment.Right).TextYAlignment = Enum.TextYAlignment.Center
		end
	end
end
Net.Event("LeaderboardSync").OnClientEvent:Connect(function(board: any)
	if leaderLayer.Visible then rebuildLeaderboard(board) end
	_G.__ttpBoard = board
end)

-- ── Book of Fate (event log) ────────────────────────────────
local _, bookList, bookInfo = mkSystemCard(bookLayer, "📖  BOOK OF FORTUNE & MISFORTUNE")
bookInfo.Text = "Karma-driven fate"
local fateLog: { any } = {}
local function rebuildBook()
	for _, c in ipairs(bookList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	if #fateLog == 0 then
		local e = Instance.new("TextLabel"); e.Size = UDim2.new(1,0,0,40); e.BackgroundTransparency=1
		e.Text = "The Book is quiet… a fate event occurs roughly every 35s."; e.TextColor3 = C.t3
		e.TextSize = 12; e.Font = Enum.Font.Gotham; e.TextWrapped = true; e.Parent = bookList
		return
	end
	for order, ev in ipairs(fateLog) do
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,48); row.BorderSizePixel = 0; row.BackgroundColor3 = C.bg3; corner(row,6)
		local col = ev.kind == "GOOD" and C.green or (ev.kind == "BAD" and C.hp or C.a1)
		stroke(row, col); row.Parent = bookList
		mkLabel(row, ev.icon .. "  " .. ev.name, UDim2.new(1,-16,0,18), UDim2.fromOffset(10,6), col, 12, Enum.Font.GothamBold)
		mkLabel(row, ev.desc, UDim2.new(1,-16,0,16), UDim2.fromOffset(10,26), C.t3, 10)
	end
end
Net.Event("FateEvent").OnClientEvent:Connect(function(icon, name, kind, desc)
	table.insert(fateLog, 1, { icon=icon, name=name, kind=kind, desc=desc })
	if #fateLog > 20 then table.remove(fateLog) end
	if bookLayer.Visible then rebuildBook() end
end)

-- ── Store (Robux) ───────────────────────────────────────────
local _, storeList, _ = mkSystemCard(storeLayer, "💎  STORE")
local promptProduct = Net.Event("PromptProduct")
local promptPass    = Net.Event("PromptPass")
local STORE_ITEMS = {
	{ icon="💰", name="1,000 Spirit Stones", desc="Instant Spirit Stones", kind="product", id=0 },
	{ icon="🎲", name="Extra Reroll Pack",   desc="+3 rerolls per attribute", kind="product", id=0 },
	{ icon="⚡", name="10x EXP (1 hour)",     desc="EXP ×10 for one hour", kind="product", id=0 },
	{ icon="👑", name="VIP — 2x EXP Forever", desc="Permanent +100% EXP", kind="pass", id=0 },
	{ icon="🤖", name="Auto-Cultivate",       desc="Cultivate while away", kind="pass", id=0 },
}
do
	for order, it in ipairs(STORE_ITEMS) do
		local row = Instance.new("Frame"); row.LayoutOrder = order
		row.Size = UDim2.new(1,0,0,56); row.BackgroundColor3 = C.bg3; row.BorderSizePixel = 0
		corner(row,6); stroke(row,C.border); row.Parent = storeList
		mkLabel(row, it.icon .. "  " .. it.name, UDim2.new(1,-110,0,20), UDim2.fromOffset(10,6), C.gold, 13, Enum.Font.GothamBold)
		mkLabel(row, it.desc, UDim2.new(1,-110,0,16), UDim2.fromOffset(10,28), C.t3, 10)
		local b = mkButton(row,"Buy",UDim2.new(0,90,0,30),UDim2.new(1,-100,0.5,-15),C.green); b.TextSize=12
		local kind, id = it.kind, it.id
		b.MouseButton1Click:Connect(function()
			if kind == "pass" then promptPass:FireServer(id) else promptProduct:FireServer(id) end
		end)
	end
end

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
local tribHint = mkLabel(tribLayer,"Survive every wave! Use healing pills [I] to recover.",
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
	tribWaveL.Text = ("Wave 0 / %d"):format(waves)
	closeAllOverlays()
end)

Net.Event("TribulationWave").OnClientEvent:Connect(function(wave: number, waves: number, dmg: number)
	tribWaveL.Text = ("Wave %d / %d   (−%s HP)"):format(wave, waves, fmt(dmg))
	flashLightning()
end)

Net.Event("TribulationEnded").OnClientEvent:Connect(function(success: boolean)
	tribLayer.Visible = false
	if success then
		showToast("✨ Tribulation survived — Breakthrough!", "gold")
	else
		showToast("💀 Tribulation failed! Heal up and break through again.", "warn")
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

mkLabel(mContainer,"🎲  PROVIDENCE — Roll Your Fate",
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

local confirmBtn = mkButton(scrollLeft,"✓ Confirm Providence & Begin",UDim2.new(1,0,0,50),UDim2.fromOffset(0,0),C.green)
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

infoRow("🌟  APTITUDE — Talent (pros & cons)",C.gold,14,Enum.Font.GothamBold)
for _, g in ipairs(AptitudeData.GRADES) do
	local col = RARITY[g.rarity] or C.t1
	infoRow(('<b>%s</b>  <font color="#5C6488">%.1f%%</font>'):format(g.name,g.chance),col,12)
	infoRow('<font color="#34D399">✓ ' .. (g.pros or "") .. '</font>', C.green, 11)
	infoRow('<font color="#F87171">✗ ' .. (g.cons or "") .. '</font>', C.hp, 11)
end

infoRow("💪  PHYSIQUE — Body type",C.gold,14,Enum.Font.GothamBold,10)
for _, p in ipairs(ProvidenceData.PHYSIQUES) do
	infoRow(('<b><font color="#%s">%s</font></b>  <font color="#5C6488">%s  %.0f%%</font>'):format(p.color,p.name,p.role,p.chance), Color3.fromHex(p.color),12)
	infoRow('<font color="#34D399">✓ ' .. p.pros .. '</font>', C.green, 11)
	infoRow('<font color="#F87171">✗ ' .. p.cons .. '</font>', C.hp, 11)
end

infoRow("🎭  CONNATE — Rarity & Lifespan",C.gold,14,Enum.Font.GothamBold,10)
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
function showToast(message: string, kind: string?)
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
			techLabel.Text = "[Q] Technique ready"
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
		seclStatus.Text = "🧘 In Seclusion"; seclStatus.TextColor3 = C.cyan
	else
		seclStatus.Text = "Seclusion: Inactive"; seclStatus.TextColor3 = C.t3
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
	yearLabel.Text = years == 1 and "1 Year" or (tostring(years) .. " Years")
	seclPreviewEXP.Text    = ("⚡ EXP: ~%d stage gains"):format(years * 3)
	seclPreviewStones.Text = ("💰 Stones: +%d"):format(years * 80)
	seclPreviewAge.Text    = ("⏳ Ages by: %d %s"):format(years, years==1 and "Year" or "Years")
	seclPreviewTime.Text   = ("🕑 Real time: ~%d min"):format(math.ceil(years * 120 / 60))
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
	seclStatus.Text = ("🧘 Seclusion: %d %s"):format(years, years==1 and "Year" or "Years")
end)

Net.Event("SeclusionFinished").OnClientEvent:Connect(function(expGained: number, stonesGained: number, years: number, canceled: boolean)
	local prefix = canceled and "⚠️ Abgebrochen" or "✅ Abgeschlossen"
	showToast(("%s — +%d EXP, +%d Stones, +%d Years"):format(prefix, expGained, stonesGained, years), canceled and "warn" or "gold")
end)

task.spawn(function()
	while true do
		task.wait(1)
		if seclusionCountdown > 0 then
			seclusionCountdown -= 1
			seclTimer.Text = "⏱ " .. formatTime(seclusionCountdown) .. " remaining"
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
		block.subLabel.Text = g and ("%s  |  %.1f%% Chance"):format(g.rarity, g.chance) or "—"
		block.prosLabel.Text = g and ("✓ " .. (g.pros or "")) or ""; block.prosLabel.TextColor3 = C.green
		block.consLabel.Text = g and ("✗ " .. (g.cons or "")) or ""; block.consLabel.TextColor3 = C.hp
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
		block.prosLabel.Text = "☯️ Eases learning this Dao"; block.prosLabel.TextColor3 = C.cyan
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
-- Rarity rank for celebration intensity.
local RARITY_RANK = {
	Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Divine=7, Immortal=8, Chaos=8,
}
local function bestRollRank(): number
	local rank = 0
	local apt = player:GetAttribute("Aptitude")
	local g = apt and AptitudeData.GetByName(apt)
	if g then rank = math.max(rank, RARITY_RANK[g.rarity] or 0) end
	local conn = player:GetAttribute("Connate")
	if conn then rank = math.max(rank, RARITY_RANK[conn] or 0) end
	local phys = player:GetAttribute("Physique")
	local p = phys and ProvidenceData.GetPhysique(phys)
	if p and p.chance <= 9 then rank = math.max(rank, 5) end  -- rare physiques
	return rank
end

-- Golden burst + glow over the providence menu for a great roll.
local function celebrateRoll(rank: number)
	local glow = Instance.new("ImageLabel")
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"  -- soft radial gradient
	glow.ImageColor3 = rank >= 7 and Color3.fromHex("67E8F9") or (rank >= 6 and Color3.fromHex("F87171") or C.gold)
	glow.ImageTransparency = 0.1
	glow.Size = UDim2.fromScale(0.1, 0.1)
	glow.Position = UDim2.fromScale(0.5, 0.5)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.ZIndex = 30
	glow.Parent = menuRoot
	TweenService:Create(glow, TweenInfo.new(0.9, Enum.EasingStyle.Quad),
		{ Size = UDim2.fromScale(1.4, 1.4), ImageTransparency = 1 }):Play()
	game:GetService("Debris"):AddItem(glow, 1.0)

	-- Rising sparkle text
	local tier = rank >= 7 and "✨ HEAVEN-DEFYING ROLL! ✨"
		or rank >= 6 and "🌟 LEGENDARY ROLL!"
		or "✨ Great roll!"
	local lbl = mkLabel(menuRoot, tier, UDim2.new(1,0,0,40), UDim2.fromScale(0,0.42),
		glow.ImageColor3, 26, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
	lbl.ZIndex = 31; lbl.TextStrokeTransparency = 0.3
	TweenService:Create(lbl, TweenInfo.new(1.2, Enum.EasingStyle.Quad),
		{ Position = UDim2.fromScale(0,0.34), TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	game:GetService("Debris"):AddItem(lbl, 1.3)
end

rerollAttrRemote.OnClientEvent:Connect(function(success: boolean, msg: string)
	if success then
		showToast("🎲 Rerolled!", "gold")
		task.wait(0.05)
		local rank = bestRollRank()
		if rank >= 4 then celebrateRoll(rank) end  -- Epic or better
	else
		showToast("❌ " .. tostring(msg), "warn")
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Button wiring
-- ════════════════════════════════════════════════════════════
function closeAllOverlays()
	mainMenuLayer.Visible = false; inventoryLayer.Visible = false
	shopLayer.Visible = false;     questLayer.Visible = false
	sectLayer.Visible = false;     worldLayer.Visible = false
	companionLayer.Visible = false; formationLayer.Visible = false
	titleLayer.Visible = false;     dungeonLayer.Visible = false
	leaderLayer.Visible = false;    bookLayer.Visible = false
	storeLayer.Visible = false
end

mainMenuBtn.MouseButton1Click:Connect(function() closeAllOverlays(); mainMenuLayer.Visible = true end)
closeMainMenu.MouseButton1Click:Connect(function() mainMenuLayer.Visible = false end)

invBtn.MouseButton1Click:Connect(function() closeAllOverlays(); inventoryLayer.Visible = true end)
closeInv.MouseButton1Click:Connect(function() inventoryLayer.Visible = false end)

shopBtn.MouseButton1Click:Connect(function() closeAllOverlays(); rebuildShop(); shopLayer.Visible = true end)
closeShop.MouseButton1Click:Connect(function() shopLayer.Visible = false end)
-- Refresh the catalogue whenever the realm changes (new stock unlocks).
player:GetAttributeChangedSignal("Realm"):Connect(function()
	if shopLayer.Visible then rebuildShop() end
end)

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

worldBtn.MouseButton1Click:Connect(function()
	closeAllOverlays()
	worldLayer.Visible = true
	rebuildWorlds()
end)
closeWorld.MouseButton1Click:Connect(function() worldLayer.Visible = false end)

-- ── Hub buttons (the ≡ main menu grid) ──────────────────────
local function openOnly(layer: Frame, rebuild: (() -> ())?)
	closeAllOverlays()
	if rebuild then rebuild() end
	layer.Visible = true
end
hubButtons.providence.MouseButton1Click:Connect(function()
	closeAllOverlays()
	showToast("☯️ " ..
		(player:GetAttribute("Aptitude") or "?") .. " · " ..
		(player:GetAttribute("Physique") or "?") .. " · " ..
		(player:GetAttribute("Connate")  or "?") .. " · " ..
		(player:GetAttribute("DaoAffinity") or "?"), "gold")
end)
hubButtons.shop.MouseButton1Click:Connect(function() openOnly(shopLayer, rebuildShop) end)
hubButtons.quests.MouseButton1Click:Connect(function() openOnly(questLayer, rebuildQuests) end)
hubButtons.sects.MouseButton1Click:Connect(function() openOnly(sectLayer, rebuildSects) end)
hubButtons.companions.MouseButton1Click:Connect(function() openOnly(companionLayer, rebuildCompanions) end)
hubButtons.formations.MouseButton1Click:Connect(function() openOnly(formationLayer, rebuildFormations) end)
hubButtons.titles.MouseButton1Click:Connect(function() openOnly(titleLayer, rebuildTitles) end)
hubButtons.dungeons.MouseButton1Click:Connect(function() openOnly(dungeonLayer, rebuildDungeons) end)
hubButtons.world.MouseButton1Click:Connect(function() openOnly(worldLayer, rebuildWorlds) end)
hubButtons.leaderboard.MouseButton1Click:Connect(function()
	openOnly(leaderLayer)
	rebuildLeaderboard(_G.__ttpBoard)
end)
hubButtons.book.MouseButton1Click:Connect(function() openOnly(bookLayer, rebuildBook) end)
hubButtons.store.MouseButton1Click:Connect(function() openOnly(storeLayer) end)
hubButtons.pvp.MouseButton1Click:Connect(function() Net.Event("TogglePvP"):FireServer() end)
hubButtons.leave.MouseButton1Click:Connect(function()
	showToast("Use the Roblox menu (Esc → Leave) to exit.", "info")
	mainMenuLayer.Visible = false
end)
bindAttr("PvPEnabled", function(v)
	hubButtons.pvp.Text = v and "⚔️ PvP: ON" or "⚔️ Toggle PvP"
	hubButtons.pvp.BackgroundColor3 = v and C.hp or C.bg4
end)
-- Live-refresh open system overlays when stones change (affordability).
player:GetAttributeChangedSignal("SpiritStones"):Connect(function()
	if companionLayer.Visible then rebuildCompanions() end
	if formationLayer.Visible then rebuildFormations() end
end)

-- ════════════════════════════════════════════════════════════
-- ── Keyboard shortcuts
-- ════════════════════════════════════════════════════════════
local useTechRemote = Net.Event("UseTechnique")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.Escape then
		if mainMenuLayer.Visible or inventoryLayer.Visible or shopLayer.Visible or questLayer.Visible
			or sectLayer.Visible or worldLayer.Visible or companionLayer.Visible or formationLayer.Visible
			or titleLayer.Visible or dungeonLayer.Visible or leaderLayer.Visible or bookLayer.Visible or storeLayer.Visible then
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
	elseif key == Enum.KeyCode.G then
		-- PvP strike on the nearest enabled cultivator
		if player:GetAttribute("PvPEnabled") and not player:GetAttribute("InMenu")
			and not player:GetAttribute("InSeclusion") and not player:GetAttribute("InTribulation") then
			Net.Event("PvPAttack"):FireServer()
		end
	end
end)

-- ════════════════════════════════════════════════════════════
-- ── Network events
-- ════════════════════════════════════════════════════════════
Net.Event("Notify").OnClientEvent:Connect(showToast)

Net.Event("StatusEffect").OnClientEvent:Connect(function(effectId: string, _name: string, kind: string, duration: number)
	showStatus(effectId, kind, duration)
end)

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
