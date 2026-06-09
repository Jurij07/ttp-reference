--!strict
-- NPCService.lua
-- Spawnt die Welt-NPCs als einfache blockige Rigs mit Humanoid, Namens-Tag
-- und Lebensbalken. Klick auf einen NPC ruft CombatService.PlayerAttackNPC.
-- Beim Tod respawnt der NPC nach Config.NPC_RESPAWN_TIME an derselben Stelle.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GameData = ReplicatedStorage:WaitForChild("GameData")
local NPCData = require(GameData:WaitForChild("NPCData"))
local CultivationData = require(GameData:WaitForChild("CultivationData"))

local CombatService = require(script.Parent.CombatService)

local NPCService = {}

local npcFolder: Folder

local function hexColor(hex: string): Color3
	return Color3.fromHex(hex)
end

-- Baut den Lebensbalken + Namens-Tag über dem NPC.
local function buildBillboard(parent: BasePart, data: any, realmColor: Color3): (BillboardGui, Frame)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Info"
	bb.Size = UDim2.fromScale(4.5, 1.1)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = parent
	bb.Parent = parent

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 0.55)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = data.boss and Color3.fromHex("F5C542") or Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Text = ("%s %s%s"):format(data.icon, data.name, data.boss and "  👑" or "")
	nameLabel.Parent = bb

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.fromScale(0.9, 0.28)
	barBg.Position = UDim2.fromScale(0.05, 0.62)
	barBg.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
	barBg.BorderSizePixel = 0
	barBg.Parent = bb
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 4)
	bgCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromHex("34D399")
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = barFill

	return bb, barFill
end

-- Erstellt ein einzelnes NPC-Rig an der gegebenen Position.
function NPCService.SpawnNPC(realmId: number, data: any, position: Vector3)
	local realm = CultivationData.GetRealm(realmId)
	local realmColor = hexColor(realm and realm.color or "60A5FA")

	local model = Instance.new("Model")
	model.Name = data.name

	-- Unsichtbare Wurzel (Physik-Anker).
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CFrame = CFrame.new(position)
	root.Parent = model

	-- Sichtbarer Körper.
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 2, 2)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.Neon
	body.Color = data.boss and Color3.fromHex("F5C542") or realmColor
	body.CFrame = CFrame.new(position)
	body.Parent = model
	local bodyCorner = Instance.new("SpecialMesh")
	bodyCorner.MeshType = Enum.MeshType.Sphere
	bodyCorner.Parent = body

	-- Kopf (Adornee für den Info-Tag).
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1, 1, 1)
	head.Transparency = 1
	head.Anchored = true
	head.CanCollide = false
	head.CFrame = CFrame.new(position + Vector3.new(0, 1.5, 0))
	head.Parent = model

	local hum = Instance.new("Humanoid")
	hum.MaxHealth = data.hp
	hum.Health = data.hp
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.Parent = model

	model.PrimaryPart = root

	-- Stats als Attribute (CombatService liest diese generisch).
	model:SetAttribute("NPCName", data.name)
	model:SetAttribute("RealmId", realmId)
	model:SetAttribute("Damage", data.dmg)
	model:SetAttribute("Defense", data.def)
	model:SetAttribute("EXP", data.exp)
	model:SetAttribute("Stones", data.stones)
	model:SetAttribute("Boss", data.boss)

	local _, barFill = buildBillboard(head, data, realmColor)
	hum:GetPropertyChangedSignal("Health"):Connect(function()
		barFill.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)
		if hum.Health / hum.MaxHealth < 0.35 then
			barFill.BackgroundColor3 = Color3.fromHex("F87171")
		end
	end)

	-- Klick = Angriff (nur in Nahkampf-Reichweite).
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = Config.ATTACK_RANGE
	click.Parent = body
	click.MouseClick:Connect(function(player)
		CombatService.PlayerAttackNPC(player, model)
	end)

	-- Tod → Respawn nach Cooldown.
	hum.Died:Once(function()
		body.Transparency = 0.75
		click.MaxActivationDistance = 0
		task.delay(Config.NPC_RESPAWN_TIME, function()
			if model.Parent then
				model:Destroy()
			end
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
					(colIndex - 1) * spread,
					0,
					(rowIndex - 1) * spread
				)
				NPCService.SpawnNPC(realmId, data, pos)
			end
		end
	end
end

return NPCService
