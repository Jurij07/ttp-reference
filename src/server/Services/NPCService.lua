--!strict
-- NPCService.lua
-- Spawnt die Welt-NPCs als blockige Neon-Rigs mit Lebensbalken.
-- Klick → CombatService.PlayerAttackNPC. Tod → Respawn nach Cooldown.
-- MUTATIONEN: Mit Chance data.mut% spawnt ein Gegner mutiert — größer, leuchtend
-- magenta, ~2× HP/DMG, aber 3× EXP & Stones.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local NPCData = require(GameData:WaitForChild("NPCData"))
local CultivationData = require(GameData:WaitForChild("CultivationData"))
local WorldData = require(GameData:WaitForChild("WorldData"))

local CombatService = require(script.Parent.CombatService)

local NPCService = {}

local npcFolder: Folder

-- Mutation-Faktoren
local MUT_HP     = 2.2
local MUT_DMG    = 1.8
local MUT_REWARD = 3.0
local MUT_SCALE  = 1.7
local MUT_COLOR  = Color3.fromHex("E879F9") -- leuchtend magenta

local function hexColor(hex: string): Color3
	return Color3.fromHex(hex)
end

-- Baut Lebensbalken + Namens-Tag.
local function buildBillboard(parent: BasePart, displayName: string, isBoss: boolean): (BillboardGui, Frame)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Info"
	bb.Size = UDim2.fromScale(5, 1.2)
	bb.StudsOffset = Vector3.new(0, 3.4, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = parent
	bb.Parent = parent

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 0.55)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = isBoss and Color3.fromHex("F5C542") or Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Text = displayName
	nameLabel.Parent = bb

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.fromScale(0.9, 0.28)
	barBg.Position = UDim2.fromScale(0.05, 0.62)
	barBg.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
	barBg.BorderSizePixel = 0
	barBg.Parent = bb
	local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(0, 4); bgCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromHex("34D399")
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 4); fillCorner.Parent = barFill

	return bb, barFill
end

-- Erstellt ein einzelnes NPC-Rig an der gegebenen Position.
function NPCService.SpawnNPC(realmId: number, data: any, position: Vector3)
	local realm = CultivationData.GetRealm(realmId)
	local realmColor = hexColor(realm and realm.color or "60A5FA")

	-- Mutation würfeln (Bosse mutieren nicht — sie sind schon einzigartig).
	local mutated = (not data.boss) and (math.random(100) <= (data.mut or 0))

	local hp     = math.floor(data.hp     * (mutated and MUT_HP or 1))
	local dmg    = math.floor(data.dmg    * (mutated and MUT_DMG or 1))
	local def    = data.def
	local exp    = math.floor(data.exp    * (mutated and MUT_REWARD or 1))
	local stones = math.floor(data.stones * (mutated and MUT_REWARD or 1))
	local bodyScale = mutated and MUT_SCALE or 1

	local model = Instance.new("Model")
	model.Name = data.name

	-- Wurzel.
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1; root.Anchored = true; root.CanCollide = false
	root.CFrame = CFrame.new(position)
	root.Parent = model

	-- ── Recognisable creature body (archetype by icon/name) ────
	local creatureColor = mutated and MUT_COLOR or (data.boss and Color3.fromHex("F5C542") or realmColor)
	local s = bodyScale * (data.boss and 1.6 or 1.0)
	local mat = data.boss and Enum.Material.Neon or Enum.Material.SmoothPlastic
	local eyeColor = Color3.fromRGB(15, 15, 25)

	local function piece(name: string, size: Vector3, offset: Vector3, color: Color3, material: Enum.Material?, meshType: Enum.MeshType?): Part
		local p = Instance.new("Part")
		p.Name = name; p.Size = size * s
		p.Anchored = true; p.CanCollide = false; p.Material = material or mat
		p.Color = color
		p.CFrame = CFrame.new(position + offset * s)
		p.Parent = model
		local c = Instance.new("SpecialMesh"); c.MeshType = meshType or Enum.MeshType.Brick; c.Parent = p
		return p
	end
	local function eyes(y: number, z: number)
		piece("EyeL", Vector3.new(0.32,0.32,0.2), Vector3.new( 0.42,y,z), eyeColor, Enum.Material.Neon, Enum.MeshType.Sphere)
		piece("EyeR", Vector3.new(0.32,0.32,0.2), Vector3.new(-0.42,y,z), eyeColor, Enum.Material.Neon, Enum.MeshType.Sphere)
	end

	-- Pick an archetype from the icon (falls back to quadruped).
	local icon = data.icon or ""
	local function arche(): string
		if icon:find("🐍") then return "serpent" end
		if icon:find("🐉") or icon:find("🐲") then return "dragon" end
		if icon:find("🦅") or icon:find("🐦") then return "avian" end
		if icon:find("🐢") then return "shelled" end
		if icon:find("🪼") or icon:find("✨") or icon:find("👁") or icon:find("🌀") then return "spirit" end
		if icon:find("😈") or icon:find("👻") or icon:find("👴") or icon:find("🧙") or icon:find("🧛")
			or icon:find("💀") or icon:find("🗿") or icon:find("👤") or icon:find("😱") or icon:find("🧝") then return "humanoid" end
		return "quadruped"
	end

	local head: Part
	local a = arche()
	if a == "serpent" then
		-- coiled segments + raised head
		for i = 0, 5 do
			piece("Seg"..i, Vector3.new(1.6 - i*0.12, 1.0, 1.0), Vector3.new(0, 0.5, -1.2 + i*0.6), creatureColor, mat, Enum.MeshType.Sphere)
		end
		head = piece("Head", Vector3.new(1.4,1.2,1.6), Vector3.new(0, 1.8, 2.2), creatureColor)
		eyes(2.1, 3.0)
		piece("Tongue", Vector3.new(0.15,0.15,0.8), Vector3.new(0, 1.7, 3.1), Color3.fromRGB(220,60,90), Enum.Material.Neon)
	elseif a == "dragon" then
		local body = piece("Body", Vector3.new(3.0,2.2,4.0), Vector3.new(0,1.0,0), creatureColor)
		piece("Neck", Vector3.new(1.2,1.2,1.6), Vector3.new(0,2.2,1.8), creatureColor)
		head = piece("Head", Vector3.new(1.8,1.6,2.0), Vector3.new(0,3.0,2.8), creatureColor)
		piece("WingL", Vector3.new(0.3,2.6,3.0), Vector3.new( 2.4,2.4,-0.4), creatureColor, mat)
		piece("WingR", Vector3.new(0.3,2.6,3.0), Vector3.new(-2.4,2.4,-0.4), creatureColor, mat)
		piece("HornL", Vector3.new(0.3,1.0,0.3), Vector3.new( 0.5,3.9,2.6), Color3.fromRGB(255,255,255))
		piece("HornR", Vector3.new(0.3,1.0,0.3), Vector3.new(-0.5,3.9,2.6), Color3.fromRGB(255,255,255))
		piece("Tail", Vector3.new(0.8,0.8,3.0), Vector3.new(0,1.2,-3.2), creatureColor, mat, Enum.MeshType.Sphere)
		for _, dx in ipairs({0.9,-0.9}) do for _, dz in ipairs({1.2,-1.4}) do
			piece("Leg", Vector3.new(0.8,1.4,0.8), Vector3.new(dx,-0.3,dz), creatureColor)
		end end
		eyes(3.3, 3.7); _ = body
	elseif a == "avian" then
		local body = piece("Body", Vector3.new(1.8,2.0,2.2), Vector3.new(0,1.2,0), creatureColor, mat, Enum.MeshType.Sphere)
		head = piece("Head", Vector3.new(1.2,1.2,1.2), Vector3.new(0,2.8,0.4), creatureColor, mat, Enum.MeshType.Sphere)
		piece("Beak", Vector3.new(0.5,0.5,0.9), Vector3.new(0,2.7,1.1), Color3.fromRGB(255,180,60), Enum.Material.Neon)
		piece("WingL", Vector3.new(0.25,1.8,2.4), Vector3.new( 1.4,1.4,0), creatureColor, mat)
		piece("WingR", Vector3.new(0.25,1.8,2.4), Vector3.new(-1.4,1.4,0), creatureColor, mat)
		piece("LegL", Vector3.new(0.3,1.0,0.3), Vector3.new( 0.5,-0.2,0.2), Color3.fromRGB(255,180,60))
		piece("LegR", Vector3.new(0.3,1.0,0.3), Vector3.new(-0.5,-0.2,0.2), Color3.fromRGB(255,180,60))
		eyes(3.0, 1.0); _ = body
	elseif a == "shelled" then
		piece("Shell", Vector3.new(3.2,2.0,3.2), Vector3.new(0,1.2,0), creatureColor, mat, Enum.MeshType.Sphere)
		piece("ShellRim", Vector3.new(3.6,0.6,3.6), Vector3.new(0,0.6,0), Color3.fromRGB(255,255,255), mat, Enum.MeshType.Sphere)
		head = piece("Head", Vector3.new(1.1,1.1,1.3), Vector3.new(0,1.0,2.0), creatureColor, mat, Enum.MeshType.Sphere)
		for _, dx in ipairs({1.2,-1.2}) do for _, dz in ipairs({1.0,-1.0}) do
			piece("Leg", Vector3.new(0.7,0.8,0.7), Vector3.new(dx,0.0,dz), creatureColor)
		end end
		eyes(1.2, 2.6)
	elseif a == "spirit" then
		piece("Aura", Vector3.new(3.0,3.0,3.0), Vector3.new(0,1.6,0), creatureColor, Enum.Material.ForceField, Enum.MeshType.Sphere)
		head = piece("Core", Vector3.new(1.8,1.8,1.8), Vector3.new(0,1.6,0), creatureColor, Enum.Material.Neon, Enum.MeshType.Sphere)
		eyes(1.8, 0.9)
	elseif a == "humanoid" then
		piece("Torso", Vector3.new(1.8,2.4,1.0), Vector3.new(0,1.8,0), creatureColor)
		head = piece("Head", Vector3.new(1.2,1.2,1.2), Vector3.new(0,3.4,0), creatureColor)
		piece("ArmL", Vector3.new(0.5,2.0,0.5), Vector3.new( 1.3,1.9,0), creatureColor)
		piece("ArmR", Vector3.new(0.5,2.0,0.5), Vector3.new(-1.3,1.9,0), creatureColor)
		piece("LegL", Vector3.new(0.6,2.0,0.6), Vector3.new( 0.5,0.2,0), creatureColor)
		piece("LegR", Vector3.new(0.6,2.0,0.6), Vector3.new(-0.5,0.2,0), creatureColor)
		eyes(3.6, 0.7)
	else -- quadruped
		piece("Body", Vector3.new(2.2,1.8,3.0), Vector3.new(0,0.6,0), creatureColor)
		piece("LegFL", Vector3.new(0.6,1.0,0.6), Vector3.new( 0.7,-0.5, 1.0), creatureColor)
		piece("LegFR", Vector3.new(0.6,1.0,0.6), Vector3.new(-0.7,-0.5, 1.0), creatureColor)
		piece("LegBL", Vector3.new(0.6,1.0,0.6), Vector3.new( 0.7,-0.5,-1.0), creatureColor)
		piece("LegBR", Vector3.new(0.6,1.0,0.6), Vector3.new(-0.7,-0.5,-1.0), creatureColor)
		piece("Tail", Vector3.new(0.5,0.5,1.2), Vector3.new(0,0.8,-2.0), creatureColor)
		piece("Snout", Vector3.new(0.9,0.7,0.7), Vector3.new(0,1.4,2.3), creatureColor)
		head = piece("Head", Vector3.new(1.6,1.5,1.4), Vector3.new(0,1.7,1.6), creatureColor)
		piece("EarL", Vector3.new(0.4,0.6,0.2), Vector3.new( 0.55,2.6,1.5), creatureColor)
		piece("EarR", Vector3.new(0.4,0.6,0.2), Vector3.new(-0.55,2.6,1.5), creatureColor)
		eyes(2.0, 2.35)
	end

	local hum = Instance.new("Humanoid")
	hum.MaxHealth = hp; hum.Health = hp
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.Parent = model

	model.PrimaryPart = root

	-- Stats als Attribute (CombatService liest diese).
	model:SetAttribute("NPCName", data.name)
	model:SetAttribute("RealmId", realmId)
	model:SetAttribute("Damage",  dmg)
	model:SetAttribute("Defense", def)
	model:SetAttribute("EXP",     exp)
	model:SetAttribute("Stones",  stones)
	model:SetAttribute("Boss",    data.boss)
	model:SetAttribute("Mutated", mutated)

	-- Anzeigename
	local displayName = ("%s %s%s%s"):format(
		mutated and "✨" or data.icon,
		mutated and ("Mutierter " .. data.name) or data.name,
		data.boss and "  👑" or "",
		mutated and "  ✨" or "")
	local _, barFill = buildBillboard(head, displayName, data.boss)
	hum:GetPropertyChangedSignal("Health"):Connect(function()
		barFill.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)
		if hum.Health / hum.MaxHealth < 0.35 then
			barFill.BackgroundColor3 = Color3.fromHex("F87171")
		end
	end)

	-- Invisible click hull around the whole creature (so every archetype is clickable).
	local clickBox = Instance.new("Part")
	clickBox.Name = "ClickBox"; clickBox.Anchored = true; clickBox.CanCollide = false
	clickBox.Transparency = 1; clickBox.Size = Vector3.new(5, 6, 6) * s
	clickBox.CFrame = CFrame.new(position + Vector3.new(0, 1.6, 0) * s)
	clickBox.Parent = model

	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = Config.ATTACK_RANGE
	click.Parent = clickBox
	click.MouseClick:Connect(function(player)
		CombatService.PlayerAttackNPC(player, model)
	end)

	-- Tod → Respawn.
	hum.Died:Once(function()
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.Transparency = 0.75
			end
		end
		click.MaxActivationDistance = 0
		task.delay(Config.NPC_RESPAWN_TIME, function()
			if model.Parent then model:Destroy() end
			NPCService.SpawnNPC(realmId, data, position)
		end)
	end)

	model.Parent = npcFolder
end

-- Spawns every implemented realm's NPCs inside that realm's own zone.
function NPCService.Start()
	npcFolder = Instance.new("Folder")
	npcFolder.Name = "NPCs"
	npcFolder.Parent = workspace

	local realms = NPCData.GetImplementedRealms()
	for _, realmId in ipairs(realms) do
		local npcs = NPCData.GetRealmNPCs(realmId)
		if npcs then
			local count = #npcs
			for index, data in ipairs(npcs) do
				local pos = WorldData.NPCPosition(realmId, index, count)
				NPCService.SpawnNPC(realmId, data, pos)
			end
		end
	end
end

return NPCService
