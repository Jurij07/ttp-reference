--!strict
-- UIController.client.lua
-- Baut zwei Oberflächen:
--   1) Das Providence-Start-Menü (würfeln, Chancen & Effekte ansehen, bestätigen)
--   2) Das eigentliche HUD (Realm/Stage/EXP, HP, Alter, Stones, Buttons)
-- Welche sichtbar ist, steuert das Attribut "InMenu" (vom Server gesetzt).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local AptitudeData = require(GameData:WaitForChild("AptitudeData"))
local ProvidenceData = require(GameData:WaitForChild("ProvidenceData"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Theme ──────────────────────────────────────────────────
local C = {
	bg0 = Color3.fromHex("040508"),
	bg1 = Color3.fromHex("080A12"),
	bg2 = Color3.fromHex("0C0F1A"),
	bg3 = Color3.fromHex("111525"),
	bg4 = Color3.fromHex("171C30"),
	border = Color3.fromHex("1A1F38"),
	gold = Color3.fromHex("F5C542"),
	t1 = Color3.fromHex("EEF0FF"),
	t2 = Color3.fromHex("A8B2D8"),
	t3 = Color3.fromHex("5C6488"),
	a1 = Color3.fromHex("6C7EF8"),
	exp = Color3.fromHex("A855F7"),
	hp = Color3.fromHex("F87171"),
	green = Color3.fromHex("34D399"),
}

local RARITY = {
	Common = Color3.fromHex("9CA3AF"), Uncommon = Color3.fromHex("4ADE80"),
	Rare = Color3.fromHex("60A5FA"), Epic = Color3.fromHex("A78BFA"),
	Legendary = Color3.fromHex("FBBF24"), Mythic = Color3.fromHex("F87171"),
	Divine = Color3.fromHex("FCD34D"), Immortal = Color3.fromHex("67E8F9"),
}

-- ── Helfer ─────────────────────────────────────────────────
local function fmt(n: number?): string
	if not n then return "0" end
	local abs = math.abs(n)
	if abs >= 1e12 then return string.format("%.2fT", n / 1e12)
	elseif abs >= 1e9 then return string.format("%.2fB", n / 1e9)
	elseif abs >= 1e6 then return string.format("%.2fM", n / 1e6)
	elseif abs >= 1e3 then return string.format("%.1fK", n / 1e3)
	else return tostring(math.floor(n)) end
end

local function pct(m: number): string
	return string.format("%+d%%", math.floor((m - 1) * 100 + 0.5))
end

local function physiqueEffect(p: any): string
	local parts = {}
	if p.hpMult ~= 1 then table.insert(parts, "HP " .. pct(p.hpMult)) end
	if p.dmgMult ~= 1 then table.insert(parts, "DMG " .. pct(p.dmgMult)) end
	if p.defMult ~= 1 then table.insert(parts, "DEF " .. pct(p.defMult)) end
	if p.expMult ~= 1 then table.insert(parts, "EXP " .. pct(p.expMult)) end
	return #parts > 0 and table.concat(parts, " · ") or "neutral"
end

local function corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
end

local function stroke(parent: Instance, color: Color3?)
	local s = Instance.new("UIStroke")
	s.Color = color or C.border
	s.Thickness = 1
	s.Parent = parent
end

local function label(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3, textSize: number, font: Enum.Font?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = size
	l.Position = pos
	l.Text = text
	l.TextColor3 = color
	l.TextSize = textSize
	l.Font = font or Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.Parent = parent
	return l
end

local function panel(name: string, size: UDim2, pos: UDim2, anchor: Vector2): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = pos
	f.AnchorPoint = anchor
	f.BackgroundColor3 = C.bg2
	f.BackgroundTransparency = 0.05
	corner(f, 10)
	stroke(f)
	return f
end

local function bar(parent: Instance, fillColor: Color3, pos: UDim2, sizeY: number): Frame
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -24, 0, sizeY)
	bg.Position = pos
	bg.BackgroundColor3 = C.bg4
	bg.BorderSizePixel = 0
	corner(bg, 5)
	bg.Parent = parent
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = fillColor
	fill.BorderSizePixel = 0
	corner(fill, 5)
	fill.Parent = bg
	return fill
end

local function bindAttr(name: string, fn: (any) -> ())
	player:GetAttributeChangedSignal(name):Connect(function()
		fn(player:GetAttribute(name))
	end)
	fn(player:GetAttribute(name))
end

local function button(parent: Instance, text: string, size: UDim2, pos: UDim2, color: Color3): TextButton
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = C.t1
	b.TextSize = 15
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = true
	corner(b, 8)
	b.Parent = parent
	return b
end

-- ════════════════════════════════════════════════════════════
-- ScreenGui + Wurzeln
-- ════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TTP_HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local hudRoot = Instance.new("Frame")
hudRoot.Name = "HUD"
hudRoot.Size = UDim2.fromScale(1, 1)
hudRoot.BackgroundTransparency = 1
hudRoot.Visible = false
hudRoot.Parent = gui

local menuRoot = Instance.new("Frame")
menuRoot.Name = "ProvidenceMenu"
menuRoot.Size = UDim2.fromScale(1, 1)
menuRoot.BackgroundColor3 = C.bg0
menuRoot.BackgroundTransparency = 0.08
menuRoot.Visible = false
menuRoot.Parent = gui

-- ════════════════════════════════════════════════════════════
-- HUD
-- ════════════════════════════════════════════════════════════
local realmPanel = panel("RealmPanel", UDim2.new(0, 320, 0, 132), UDim2.new(0, 16, 0, 16), Vector2.new(0, 0))
realmPanel.Parent = hudRoot
local realmName = label(realmPanel, "Qi Refinement", UDim2.new(1, -24, 0, 24), UDim2.new(0, 12, 0, 8), C.gold, 18, Enum.Font.GothamBold)
local stageLabel = label(realmPanel, "Stage 1 / 9", UDim2.new(1, -24, 0, 16), UDim2.new(0, 12, 0, 34), C.t2, 13)
local expFill = bar(realmPanel, C.exp, UDim2.new(0, 12, 0, 58), 14)
local expText = label(realmPanel, "0 / 0 EXP", UDim2.new(1, -24, 0, 14), UDim2.new(0, 12, 0, 74), C.t3, 11)
expText.TextXAlignment = Enum.TextXAlignment.Center
local lifeLabel = label(realmPanel, "⏳ Alter —", UDim2.new(1, -24, 0, 16), UDim2.new(0, 12, 0, 96), C.green, 12)

local statPanel = panel("StatPanel", UDim2.new(0, 200, 0, 92), UDim2.new(1, -16, 0, 16), Vector2.new(1, 0))
statPanel.Parent = hudRoot
local stonesLabel = label(statPanel, "💰 0", UDim2.new(1, -20, 0, 20), UDim2.new(0, 12, 0, 10), C.gold, 15, Enum.Font.GothamBold)
local karmaLabel = label(statPanel, "⚖️ Karma: 0", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 38), C.t2, 12)
local killsLabel = label(statPanel, "⚔️ Kills: 0", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 60), C.t2, 12)

local provPanel = panel("ProvPanel", UDim2.new(0, 200, 0, 116), UDim2.new(1, -16, 0, 116), Vector2.new(1, 0))
provPanel.Parent = hudRoot
label(provPanel, "🎲 PROVIDENCE", UDim2.new(1, -20, 0, 14), UDim2.new(0, 12, 0, 8), C.t3, 10, Enum.Font.GothamBold)
local aptLabel = label(provPanel, "🌟 —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 28), C.t1, 12)
local physLabel = label(provPanel, "💪 —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 48), C.t1, 12)
local connLabel = label(provPanel, "🎭 —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 68), C.t1, 12)
local daoLabel = label(provPanel, "☯️ —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 88), C.t1, 12)

local hpPanel = panel("HPPanel", UDim2.new(0, 360, 0, 52), UDim2.new(0.5, 0, 1, -90), Vector2.new(0.5, 1))
hpPanel.Parent = hudRoot
local hpFill = bar(hpPanel, C.hp, UDim2.new(0, 12, 0, 26), 16)
local hpText = label(hpPanel, "HP 0 / 0", UDim2.new(1, -24, 0, 16), UDim2.new(0, 12, 0, 5), C.t1, 13, Enum.Font.GothamBold)
hpText.TextXAlignment = Enum.TextXAlignment.Center

local meditateBtn = button(hudRoot, "🧘 Meditate: AUS", UDim2.new(0, 158, 0, 40), UDim2.new(0, 16, 1, -16), C.bg3)
meditateBtn.AnchorPoint = Vector2.new(0, 1)
local rerollBtnHud = button(hudRoot, "🎲 Reroll", UDim2.new(0, 158, 0, 40), UDim2.new(0, 182, 1, -16), C.bg3)
rerollBtnHud.AnchorPoint = Vector2.new(0, 1)

-- ════════════════════════════════════════════════════════════
-- Providence-Start-Menü
-- ════════════════════════════════════════════════════════════
local container = Instance.new("Frame")
container.Size = UDim2.fromScale(0.92, 0.88)
container.Position = UDim2.fromScale(0.5, 0.5)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BackgroundTransparency = 1
container.Parent = menuRoot

label(container, "🎲 PROVIDENCE — Würfle dein Schicksal", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), C.gold, 26, Enum.Font.GothamBlack).TextXAlignment = Enum.TextXAlignment.Center
local subTitle = label(container, "Diese 4 Attribute bestimmen dein ganzes Spiel. Du startest mit Alter 18.", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 40), C.t2, 14)
subTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Linke Karte: aktueller Roll
local rollCard = panel("RollCard", UDim2.new(0.42, 0, 1, -150), UDim2.new(0, 0, 0, 78), Vector2.new(0, 0))
rollCard.Parent = container
label(rollCard, "DEIN SCHICKSAL", UDim2.new(1, -40, 0, 18), UDim2.new(0, 20, 0, 16), C.t3, 12, Enum.Font.GothamBold)

local mAptName = label(rollCard, "—", UDim2.new(1, -40, 0, 30), UDim2.new(0, 20, 0, 48), C.t1, 26, Enum.Font.GothamBlack)
local mAptSub = label(rollCard, "Aptitude — EXP-Multiplikator", UDim2.new(1, -40, 0, 16), UDim2.new(0, 20, 0, 80), C.t3, 12)

local mPhysName = label(rollCard, "💪 —", UDim2.new(1, -40, 0, 22), UDim2.new(0, 20, 0, 116), C.t1, 17, Enum.Font.GothamBold)
local mPhysSub = label(rollCard, "Physique", UDim2.new(1, -40, 0, 16), UDim2.new(0, 20, 0, 140), C.t2, 12)

local mConnName = label(rollCard, "🎭 —", UDim2.new(1, -40, 0, 22), UDim2.new(0, 20, 0, 174), C.t1, 17, Enum.Font.GothamBold)
local mConnSub = label(rollCard, "Connate Providence", UDim2.new(1, -40, 0, 16), UDim2.new(0, 20, 0, 198), C.t2, 12)

local mDaoName = label(rollCard, "☯️ —", UDim2.new(1, -40, 0, 22), UDim2.new(0, 20, 0, 232), C.t1, 17, Enum.Font.GothamBold)
local mDaoSub = label(rollCard, "Dao Affinity", UDim2.new(1, -40, 0, 16), UDim2.new(0, 20, 0, 256), C.t2, 12)

local rerollBtnMenu = button(rollCard, "🎲 Reroll (5)", UDim2.new(0.5, -28, 0, 46), UDim2.new(0, 20, 1, -62), C.a1)
local startBtn = button(rollCard, "✓ Start", UDim2.new(0.5, -28, 0, 46), UDim2.new(0.5, 8, 1, -62), C.green)

-- Rechte Karte: alle Chancen & Effekte (scrollbar)
local infoCard = panel("InfoCard", UDim2.new(0.56, 0, 1, -150), UDim2.new(0.44, 0, 0, 78), Vector2.new(0, 0))
infoCard.Parent = container
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -16)
scroll.Position = UDim2.fromOffset(8, 8)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = C.bg4
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = infoCard
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = scroll
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingRight = UDim.new(0, 10)
pad.Parent = scroll

local order = 0
local function addRow(text: string, color: Color3, textSize: number, font: Enum.Font?, topGap: number?)
	order += 1
	local row = Instance.new("TextLabel")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, textSize + 8 + (topGap or 0))
	row.BackgroundTransparency = 1
	row.Text = text
	row.TextColor3 = color
	row.TextSize = textSize
	row.Font = font or Enum.Font.Gotham
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.TextYAlignment = Enum.TextYAlignment.Bottom
	row.RichText = true
	row.Parent = scroll
end

-- Aptitude-Tabelle
addRow("🌟  APTITUDE — EXP-Multiplikator", C.gold, 15, Enum.Font.GothamBold)
for _, g in ipairs(AptitudeData.GRADES) do
	local col = RARITY[g.rarity] or C.t1
	addRow(string.format('<b>%s</b>  ×%.1f   <font color="#5C6488">%.1f%% Chance</font>', g.name, g.mult, g.chance), col, 13)
end
-- Physique-Tabelle
addRow("💪  PHYSIQUE — Körper-Typ", C.gold, 15, Enum.Font.GothamBold, 12)
for _, p in ipairs(ProvidenceData.PHYSIQUES) do
	addRow(string.format('<b>%s</b> <font color="#5C6488">(%s, %.0f%%)</font>', p.name, p.role, p.chance), Color3.fromHex(p.color), 13)
	addRow(physiqueEffect(p), C.t2, 12)
end
-- Connate-Tabelle
addRow("🎭  CONNATE PROVIDENCE — Seltenheit", C.gold, 15, Enum.Font.GothamBold, 12)
for _, c in ipairs(ProvidenceData.CONNATES) do
	local col = RARITY[c.name] or C.t1
	addRow(string.format('<b>%s</b>  <font color="#5C6488">%.1f%% Chance</font>  ·  alle Stats %s', c.name, c.chance, pct(c.statBonus)), col, 13)
end
-- Dao-Tabelle
addRow("☯️  DAO AFFINITY — Dao-Neigung", C.gold, 15, Enum.Font.GothamBold, 12)
addRow(table.concat(ProvidenceData.DAO_AFFINITIES, "  ·  "), C.t2, 13)

-- ── Menü-Bindings ──────────────────────────────────────────
bindAttr("Aptitude", function(v)
	local g = v and AptitudeData.GetByName(v)
	mAptName.Text = "🌟 " .. (v or "—")
	mAptName.TextColor3 = (g and RARITY[g.rarity]) or C.t1
	mAptSub.Text = g and string.format("Aptitude — EXP ×%.1f  (%.1f%% Chance)", g.mult, g.chance) or "Aptitude"
	aptLabel.Text = ("🌟 %s (×%.1f)"):format(v or "—", player:GetAttribute("AptitudeMult") or 1)
end)
bindAttr("Physique", function(v)
	local p = v and ProvidenceData.GetPhysique(v)
	mPhysName.Text = "💪 " .. (v or "—")
	mPhysName.TextColor3 = p and Color3.fromHex(p.color) or C.t1
	mPhysSub.Text = p and (p.role .. ": " .. physiqueEffect(p)) or "Physique"
	physLabel.Text = "💪 " .. (v or "—")
end)
bindAttr("Connate", function(v)
	local c = v and ProvidenceData.GetConnate(v)
	mConnName.Text = "🎭 " .. (v or "—")
	mConnName.TextColor3 = (v and RARITY[v]) or C.t1
	mConnSub.Text = c and ("Connate — alle Stats " .. pct(c.statBonus)) or "Connate Providence"
	connLabel.Text = "🎭 " .. (v or "—")
end)
bindAttr("DaoAffinity", function(v)
	mDaoName.Text = "☯️ " .. (v or "—")
	mDaoSub.Text = "Dao Affinity — leichteres Erlernen dieses Dao"
	daoLabel.Text = "☯️ " .. (v or "—") .. " Dao"
end)
bindAttr("FreeRerolls", function(v)
	local n = v or 0
	rerollBtnMenu.Text = "🎲 Reroll (" .. tostring(n) .. ")"
	rerollBtnMenu.BackgroundColor3 = n > 0 and C.a1 or C.bg4
	rerollBtnHud.Text = "🎲 Reroll (" .. tostring(n) .. ")"
end)

-- ════════════════════════════════════════════════════════════
-- HUD-Bindings
-- ════════════════════════════════════════════════════════════
bindAttr("RealmName", function(v) realmName.Text = v or "—" end)

local function updateStage()
	stageLabel.Text = ("Stage %d / %d  ·  %s"):format(
		player:GetAttribute("Stage") or 1, player:GetAttribute("MaxStage") or 9, player:GetAttribute("Tier") or "")
end
bindAttr("Stage", updateStage); bindAttr("MaxStage", updateStage); bindAttr("Tier", updateStage)

local function updateEXP()
	local exp = player:GetAttribute("EXP") or 0
	local needed = player:GetAttribute("EXPNeeded") or 1
	local ratio = math.clamp(exp / math.max(needed, 1), 0, 1)
	TweenService:Create(expFill, TweenInfo.new(0.25), { Size = UDim2.fromScale(ratio, 1) }):Play()
	expText.Text = ("%s / %s EXP  (%.0f%%)"):format(fmt(exp), fmt(needed), ratio * 100)
end
bindAttr("EXP", updateEXP); bindAttr("EXPNeeded", updateEXP)

local function updateHP()
	local hp = player:GetAttribute("HP") or 0
	local maxHP = player:GetAttribute("MaxHP") or 1
	local ratio = math.clamp(hp / math.max(maxHP, 1), 0, 1)
	TweenService:Create(hpFill, TweenInfo.new(0.2), { Size = UDim2.fromScale(ratio, 1) }):Play()
	hpText.Text = ("HP  %s / %s"):format(fmt(hp), fmt(maxHP))
end
bindAttr("HP", updateHP); bindAttr("MaxHP", updateHP)

local function updateAge()
	if player:GetAttribute("LifespanInfinite") then
		lifeLabel.Text = "⏳ Alter: ∞ (unsterblich)"
		lifeLabel.TextColor3 = C.green
		return
	end
	local age = player:GetAttribute("Age") or 18
	local maxLife = player:GetAttribute("MaxLifespan") or 85
	lifeLabel.Text = ("⏳ Alter %s / %s Jahre"):format(fmt(age), fmt(maxLife))
	lifeLabel.TextColor3 = (age / math.max(maxLife, 1) > 0.85) and C.hp or C.green
end
bindAttr("Age", updateAge); bindAttr("MaxLifespan", updateAge); bindAttr("LifespanInfinite", updateAge)

bindAttr("SpiritStones", function(v) stonesLabel.Text = "💰 " .. fmt(v) end)
bindAttr("Karma", function(v) karmaLabel.Text = "⚖️ Karma: " .. tostring(math.floor(v or 0)) end)
bindAttr("TotalKills", function(v) killsLabel.Text = "⚔️ Kills: " .. tostring(v or 0) end)

bindAttr("Meditating", function(on)
	meditateBtn.Text = on and "🧘 Meditate: AN (sitzt)" or "🧘 Meditate: AUS"
	meditateBtn.BackgroundColor3 = on and C.green or C.bg3
end)

-- ── Sichtbarkeit Menü vs HUD ───────────────────────────────
bindAttr("InMenu", function(v)
	if v == nil then return end
	menuRoot.Visible = v == true
	hudRoot.Visible = v ~= true
end)

-- ════════════════════════════════════════════════════════════
-- Remotes / Buttons / Feedback
-- ════════════════════════════════════════════════════════════
local meditateRemote = Net.Event("ToggleMeditate")
meditateBtn.MouseButton1Click:Connect(function()
	meditateRemote:FireServer(not player:GetAttribute("Meditating"))
end)

local rerollRemote = Net.Event("RerollProvidence")
local function doReroll() rerollRemote:FireServer() end
rerollBtnMenu.MouseButton1Click:Connect(doReroll)
rerollBtnHud.MouseButton1Click:Connect(doReroll)

local confirmRemote = Net.Event("ConfirmProvidence")
startBtn.MouseButton1Click:Connect(function()
	confirmRemote:FireServer()
end)

-- Benachrichtigungen (Toasts) — immer ganz oben
local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.new(0, 440, 1, 0)
toastHolder.Position = UDim2.new(0.5, 0, 0, 14)
toastHolder.AnchorPoint = Vector2.new(0.5, 0)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = gui
local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Parent = toastHolder

local toastColors = { good = C.green, warn = C.hp, gold = C.gold, info = C.a1 }
local function showToast(message: string, kind: string?)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0, 440, 0, 34)
	t.BackgroundColor3 = C.bg3
	t.Text = message
	t.TextColor3 = toastColors[kind or "info"] or C.t1
	t.TextSize = 14
	t.Font = Enum.Font.GothamBold
	t.TextWrapped = true
	corner(t, 8)
	stroke(t, toastColors[kind or "info"] or C.border)
	t.Parent = toastHolder
	task.delay(3.5, function()
		local tw = TweenService:Create(t, TweenInfo.new(0.4), { BackgroundTransparency = 1, TextTransparency = 1 })
		tw:Play(); tw.Completed:Wait(); t:Destroy()
	end)
end

rerollRemote.OnClientEvent:Connect(function(success, payload, _remaining)
	if success then
		showToast("🎲 Neue Providence gewürfelt!", "gold")
	else
		showToast("❌ " .. tostring(payload), "warn")
	end
end)

Net.Event("Notify").OnClientEvent:Connect(showToast)

Net.Event("CombatHit").OnClientEvent:Connect(function(_npcName, amount)
	local d = Instance.new("TextLabel")
	d.Size = UDim2.new(0, 120, 0, 40)
	d.Position = UDim2.new(0.5, math.random(-80, 80), 0.5, math.random(-30, 30))
	d.AnchorPoint = Vector2.new(0.5, 0.5)
	d.BackgroundTransparency = 1
	d.Text = "-" .. fmt(amount)
	d.TextColor3 = C.gold
	d.TextSize = 22
	d.Font = Enum.Font.GothamBlack
	d.TextStrokeTransparency = 0.3
	d.Parent = gui
	local tw = TweenService:Create(d, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
		Position = d.Position - UDim2.fromOffset(0, 60), TextTransparency = 1, TextStrokeTransparency = 1,
	})
	tw:Play()
	tw.Completed:Connect(function() d:Destroy() end)
end)

print("[TTP] HUD + Providence-Menü geladen.")
