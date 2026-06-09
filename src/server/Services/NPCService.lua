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

	-- Sichtbarer Körper.
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 2, 2) * bodyScale
	body.Anchored = true; body.CanCollide = false
	body.Material = Enum.Material.Neon
	body.Color = mutated and MUT_COLOR or (data.boss and Color3.fromHex("F5C542") or realmColor)
	body.CFrame = CFrame.new(position)
	body.Parent = model
	local mesh = Instance.new("SpecialMesh"); mesh.MeshType = Enum.MeshType.Sphere; mesh.Parent = body

	-- Kopf (Adornee).
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1, 1, 1)
	head.Transparency = 1; head.Anchored = true; head.CanCollide = false
	head.CFrame = CFrame.new(position + Vector3.new(0, 1.5 * bodyScale, 0))
	head.Parent = model

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

	-- Klick = Angriff.
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = Config.ATTACK_RANGE
	click.Parent = body
	click.MouseClick:Connect(function(player)
		CombatService.PlayerAttackNPC(player, model)
	end)

	-- Tod → Respawn.
	hum.Died:Once(function()
		body.Transparency = 0.75
		click.MaxActivationDistance = 0
		task.delay(Config.NPC_RESPAWN_TIME, function()
			if model.Parent then model:Destroy() end
			NPCService.SpawnNPC(realmId, data, position)
		end)
	end)

	model.Parent = npcFolder
end

-- Spawnt alle implementierten NPCs in Reihen pro Realm.
function NPCService.Start()
	npcFolder = Instance.new("Folder")
	npcFolder.Name = "NPCs"
	npcFolder.Parent = workspace

	local origin = Config.NPC_SPAWN_ORIGIN
	local spread = Config.NPC_SPAWN_SPREAD

	local realms = NPCData.GetImplementedRealms()
	for rowIndex, realmId in ipairs(realms) do
		local npcs = NPCData.GetRealmNPCs(realmId)
		if npcs then
			for colIndex, data in ipairs(npcs) do
				local pos = origin + Vector3.new(
					(colIndex - 1) * spread, 0, (rowIndex - 1) * spread)
				NPCService.SpawnNPC(realmId, data, pos)
			end
		end
	end
end

return NPCService
