--!strict
-- UIController.client.lua
-- Baut das komplette HUD per Code auf und hält es über Player-Attribute
-- aktuell (die der Server setzt und automatisch repliziert). Bietet zudem
-- Meditate- und Reroll-Buttons sowie Benachrichtigungen & Schadenszahlen.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Theme (passend zur Referenz-Website) ───────────────────
local C = {
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

-- ── Hilfsfunktionen ────────────────────────────────────────
local function fmt(n: number?): string
	if not n then return "0" end
	local abs = math.abs(n)
	if abs >= 1e12 then return string.format("%.2fT", n / 1e12)
	elseif abs >= 1e9 then return string.format("%.2fB", n / 1e9)
	elseif abs >= 1e6 then return string.format("%.2fM", n / 1e6)
	elseif abs >= 1e3 then return string.format("%.1fK", n / 1e3)
	else return tostring(math.floor(n)) end
end

local function corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function stroke(parent: Instance, color: Color3?)
	local s = Instance.new("UIStroke")
	s.Color = color or C.border
	s.Thickness = 1
	s.Parent = parent
	return s
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
	l.Parent = parent
	return l
end

local function bar(parent: Instance, fillColor: Color3, pos: UDim2, sizeY: number): (Frame, Frame)
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -20, 0, sizeY)
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
	return bg, fill
end

-- Verbindet ein Attribut mit einer Update-Funktion (und ruft sie sofort auf).
local function bindAttr(name: string, fn: (any) -> ())
	local function update()
		fn(player:GetAttribute(name))
	end
	player:GetAttributeChangedSignal(name):Connect(update)
	update()
end

-- ════════════════════════════════════════════════════════════
-- ScreenGui
-- ════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TTP_HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- ── Realm / Stage / EXP / Lifespan (oben links) ────────────
local realmPanel = panel("RealmPanel", UDim2.new(0, 320, 0, 132), UDim2.new(0, 16, 0, 16), Vector2.new(0, 0))
realmPanel.Parent = gui

local realmName = label(realmPanel, "Qi Refinement", UDim2.new(1, -20, 0, 24), UDim2.new(0, 12, 0, 8), C.gold, 18, Enum.Font.GothamBold)
local stageLabel = label(realmPanel, "Stage 1 / 9", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 34), C.t2, 13)

local expBg, expFill = bar(realmPanel, C.exp, UDim2.new(0, 12, 0, 58), 14)
expFill.BackgroundColor3 = C.exp
local expText = label(realmPanel, "0 / 0 EXP", UDim2.new(1, -20, 0, 14), UDim2.new(0, 12, 0, 74), C.t3, 11)
expText.TextXAlignment = Enum.TextXAlignment.Center

local lifeLabel = label(realmPanel, "⏳ Lifespan: —", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 96), C.green, 12)

-- ── Spirit Stones / Karma / Kills (oben rechts) ────────────
local statPanel = panel("StatPanel", UDim2.new(0, 200, 0, 92), UDim2.new(1, -16, 0, 16), Vector2.new(1, 0))
statPanel.Parent = gui
local stonesLabel = label(statPanel, "💰 0", UDim2.new(1, -20, 0, 20), UDim2.new(0, 12, 0, 10), C.gold, 15, Enum.Font.GothamBold)
local karmaLabel = label(statPanel, "⚖️ Karma: 0", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 38), C.t2, 12)
local killsLabel = label(statPanel, "⚔️ Kills: 0", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 60), C.t2, 12)

-- ── Providence (unter den Stats) ───────────────────────────
local provPanel = panel("ProvPanel", UDim2.new(0, 200, 0, 116), UDim2.new(1, -16, 0, 116), Vector2.new(1, 0))
provPanel.Parent = gui
label(provPanel, "🎲 PROVIDENCE", UDim2.new(1, -20, 0, 14), UDim2.new(0, 12, 0, 8), C.t3, 10, Enum.Font.GothamBold)
local aptLabel = label(provPanel, "🌟 —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 28), C.t1, 12)
local physLabel = label(provPanel, "💪 —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 48), C.t1, 12)
local connLabel = label(provPanel, "🎭 —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 68), C.t1, 12)
local daoLabel = label(provPanel, "☯️ —", UDim2.new(1, -20, 0, 15), UDim2.new(0, 12, 0, 88), C.t1, 12)

-- ── HP-Balken (unten Mitte) ────────────────────────────────
local hpPanel = panel("HPPanel", UDim2.new(0, 360, 0, 52), UDim2.new(0.5, 0, 1, -90), Vector2.new(0.5, 1))
hpPanel.Parent = gui
local hpBg, hpFill = bar(hpPanel, C.hp, UDim2.new(0, 12, 0, 26), 16)
local hpText = label(hpPanel, "HP 0 / 0", UDim2.new(1, -20, 0, 16), UDim2.new(0, 12, 0, 5), C.t1, 13, Enum.Font.GothamBold)
hpText.TextXAlignment = Enum.TextXAlignment.Center

-- ── Buttons (unten links) ──────────────────────────────────
local function makeButton(text: string, pos: UDim2, color: Color3): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 150, 0, 40)
	b.Position = pos
	b.AnchorPoint = Vector2.new(0, 1)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = C.t1
	b.TextSize = 14
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = true
	corner(b, 8)
	b.Parent = gui
	return b
end

local meditateBtn = makeButton("🧘 Meditate: AUS", UDim2.new(0, 16, 1, -16), C.bg3)
local rerollBtn = makeButton("🎲 Reroll Providence", UDim2.new(0, 174, 1, -16), C.bg3)

-- ── Benachrichtigungen (oben Mitte) ────────────────────────
local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.new(0, 420, 1, 0)
toastHolder.Position = UDim2.new(0.5, 0, 0, 16)
toastHolder.AnchorPoint = Vector2.new(0.5, 0)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = gui
local toastLayout = Instance.new("UIListLayout")
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Padding = UDim.new(0, 6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Parent = toastHolder

local toastColors = {
	good = C.green, warn = C.hp, gold = C.gold, info = C.a1,
}

local function showToast(message: string, kind: string?)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0, 420, 0, 34)
	t.BackgroundColor3 = C.bg3
	t.BackgroundTransparency = 0.05
	t.Text = message
	t.TextColor3 = toastColors[kind or "info"] or C.t1
	t.TextSize = 14
	t.Font = Enum.Font.GothamBold
	t.TextWrapped = true
	corner(t, 8)
	stroke(t, toastColors[kind or "info"] or C.border)
	t.Parent = toastHolder
	task.delay(3.5, function()
		local tween = TweenService:Create(t, TweenInfo.new(0.4), { BackgroundTransparency = 1, TextTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		t:Destroy()
	end)
end

-- ── Schadenszahlen (flüchtig, Bildschirmmitte) ─────────────
local function showDamage(amount: number)
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
	local tween = TweenService:Create(d, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
		Position = d.Position - UDim2.fromOffset(0, 60),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		d:Destroy()
	end)
end

-- ════════════════════════════════════════════════════════════
-- Attribut-Bindings
-- ════════════════════════════════════════════════════════════
bindAttr("RealmName", function(v) realmName.Text = v or "—" end)

local function updateStage()
	stageLabel.Text = ("Stage %d / %d  ·  %s"):format(
		player:GetAttribute("Stage") or 1,
		player:GetAttribute("MaxStage") or 9,
		player:GetAttribute("Tier") or ""
	)
end
bindAttr("Stage", updateStage)
bindAttr("MaxStage", updateStage)
bindAttr("Tier", updateStage)

local function updateEXP()
	local exp = player:GetAttribute("EXP") or 0
	local needed = player:GetAttribute("EXPNeeded") or 1
	local ratio = math.clamp(exp / math.max(needed, 1), 0, 1)
	TweenService:Create(expFill, TweenInfo.new(0.25), { Size = UDim2.fromScale(ratio, 1) }):Play()
	expText.Text = ("%s / %s EXP  (%.0f%%)"):format(fmt(exp), fmt(needed), ratio * 100)
end
bindAttr("EXP", updateEXP)
bindAttr("EXPNeeded", updateEXP)

local function updateHP()
	local hp = player:GetAttribute("HP") or 0
	local maxHP = player:GetAttribute("MaxHP") or 1
	local ratio = math.clamp(hp / math.max(maxHP, 1), 0, 1)
	TweenService:Create(hpFill, TweenInfo.new(0.2), { Size = UDim2.fromScale(ratio, 1) }):Play()
	hpText.Text = ("HP  %s / %s"):format(fmt(hp), fmt(maxHP))
end
bindAttr("HP", updateHP)
bindAttr("MaxHP", updateHP)

local function updateLife()
	if player:GetAttribute("LifespanInfinite") then
		lifeLabel.Text = "⏳ Lifespan: ∞ Infinite"
		return
	end
	local life = player:GetAttribute("Lifespan") or 0
	local maxLife = player:GetAttribute("MaxLifespan") or 0
	lifeLabel.Text = ("⏳ Lifespan: %s / %s Jahre"):format(fmt(life), fmt(maxLife))
	lifeLabel.TextColor3 = (life / math.max(maxLife, 1) < 0.2) and C.hp or C.green
end
bindAttr("Lifespan", updateLife)
bindAttr("MaxLifespan", updateLife)
bindAttr("LifespanInfinite", updateLife)

bindAttr("SpiritStones", function(v) stonesLabel.Text = "💰 " .. fmt(v) end)
bindAttr("Karma", function(v) karmaLabel.Text = "⚖️ Karma: " .. tostring(math.floor(v or 0)) end)
bindAttr("TotalKills", function(v) killsLabel.Text = "⚔️ Kills: " .. tostring(v or 0) end)

bindAttr("Aptitude", function(v)
	aptLabel.Text = ("🌟 %s (×%.1f)"):format(v or "—", player:GetAttribute("AptitudeMult") or 1)
end)
bindAttr("Physique", function(v) physLabel.Text = "💪 " .. (v or "—") end)
bindAttr("Connate", function(v) connLabel.Text = "🎭 " .. (v or "—") end)
bindAttr("DaoAffinity", function(v) daoLabel.Text = "☯️ " .. (v or "—") .. " Dao" end)

bindAttr("Meditating", function(on)
	if on then
		meditateBtn.Text = "🧘 Meditate: AN"
		meditateBtn.BackgroundColor3 = C.green
	else
		meditateBtn.Text = "🧘 Meditate: AUS"
		meditateBtn.BackgroundColor3 = C.bg3
	end
end)

-- ════════════════════════════════════════════════════════════
-- Remotes / Buttons
-- ════════════════════════════════════════════════════════════
local meditateRemote = Net.Event("ToggleMeditate")
meditateBtn.MouseButton1Click:Connect(function()
	meditateRemote:FireServer(not player:GetAttribute("Meditating"))
end)

local rerollRemote = Net.Event("RerollProvidence")
rerollBtn.MouseButton1Click:Connect(function()
	rerollRemote:FireServer()
end)
rerollRemote.OnClientEvent:Connect(function(success, payload)
	if success then
		showToast("🎲 Neue Providence gerollt!", "gold")
	else
		showToast("❌ " .. tostring(payload), "warn")
	end
end)

Net.Event("Notify").OnClientEvent:Connect(function(message, kind)
	showToast(message, kind)
end)

Net.Event("CombatHit").OnClientEvent:Connect(function(_npcName, amount)
	showDamage(amount)
end)

print("[TTP] HUD geladen.")
