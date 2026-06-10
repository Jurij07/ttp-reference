--!strict
-- SageSeatService.lua
-- The Mystic Divine Palace has exactly 12 Sage seats. Reaching Realm 17 claims
-- a free seat if one is open. When all 12 are taken, a challenger (R17+) may
-- contest the weakest current holder for their seat. The Sage Seats board in
-- World 3 shows live availability.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local SageSeatService = {}

local notifyEvent     = Net.Event("Notify")
local seatGranted     = Net.Event("SageSeatGranted")
local seatsSync       = Net.Event("SageSeats")
local seatChallenge   = Net.Event("SageSeatChallenge")

local TOTAL_SEATS = 12
local STORE_NAME = "SageSeats_v1"
local KEY = "seats"

type Seat = { name: string, userId: number, realm: number }
local store: DataStore? = nil
local seats: { [number]: Seat } = {}

local function countTaken(): number
	local n = 0
	for _ in pairs(seats) do n += 1 end
	return n
end

local function firstFreeSeat(): number?
	for i = 1, TOTAL_SEATS do
		if not seats[i] then return i end
	end
	return nil
end

local function seatOfPlayer(userId: number): number?
	for i, s in pairs(seats) do
		if s.userId == userId then return i end
	end
	return nil
end

local function weakestSeat(): (number?, Seat?)
	local bestI, bestS = nil, nil
	for i, s in pairs(seats) do
		if not bestS or s.realm < (bestS :: Seat).realm then bestI = i; bestS = s end
	end
	return bestI, bestS
end

local function save()
	if not (store and Config.USE_DATASTORE) then return end
	pcall(function() store:SetAsync(KEY, seats) end)
end

local function load()
	if not (store and Config.USE_DATASTORE) then return end
	local ok, result = pcall(function() return store:GetAsync(KEY) end)
	if ok and typeof(result) == "table" then seats = result :: any end
end

local function nameList(): { string }
	local n = {}
	for i = 1, TOTAL_SEATS do n[i] = seats[i] and seats[i].name or "—" end
	return n
end

local function updateBoard()
	local available = TOTAL_SEATS - countTaken()
	for _, board in ipairs(CollectionService:GetTagged("SageSeatsBoard")) do
		local sg = board:FindFirstChildOfClass("SurfaceGui")
		local lbl = sg and sg:FindFirstChild("Status")
		if lbl and lbl:IsA("TextLabel") then
			lbl.Text = ("Sage Seats Available: %d/%d"):format(available, TOTAL_SEATS)
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		seatsSync:FireClient(p, { available = available, total = TOTAL_SEATS, seats = nameList() })
	end
end

local function grantSeat(player: Player, seatNum: number)
	local profile = DataManager.Get(player)
	seats[seatNum] = { name = player.Name, userId = player.UserId, realm = (player:GetAttribute("Realm") or 17) :: number }
	if profile then profile.sageSeatNumber = seatNum end
	player:SetAttribute("SageSeat", seatNum)
	seatGranted:FireClient(player, seatNum)
	notifyEvent:FireClient(player, ("✨ You claimed Sage Seat #%d!"):format(seatNum), "gold")
	save(); updateBoard()
end

local function tryClaim(player: Player)
	local realm = (player:GetAttribute("Realm") or 1) :: number
	if realm < 17 then return end
	if seatOfPlayer(player.UserId) then return end
	local free = firstFreeSeat()
	if free then
		grantSeat(player, free)
	else
		notifyEvent:FireClient(player, "⚔️ All 12 Sage seats are taken — challenge a Sage to take one.", "warn")
	end
end

local function challenge(player: Player)
	local realm = (player:GetAttribute("Realm") or 1) :: number
	if realm < 17 then
		notifyEvent:FireClient(player, "You must reach Realm 17 to challenge for a Sage seat.", "warn")
		return
	end
	if seatOfPlayer(player.UserId) then
		notifyEvent:FireClient(player, "You already hold a Sage seat.", "info")
		return
	end
	local free = firstFreeSeat()
	if free then grantSeat(player, free); return end

	local i, s = weakestSeat()
	if i and s and realm > s.realm then
		notifyEvent:FireClient(player, ("⚔️ You unseated %s and took Sage Seat #%d!"):format(s.name, i), "gold")
		local prev = Players:GetPlayerByUserId(s.userId)
		if prev then
			prev:SetAttribute("SageSeat", nil)
			notifyEvent:FireClient(prev, ("💀 %s has taken your Sage seat!"):format(player.Name), "warn")
			local pp = DataManager.Get(prev); if pp then pp.sageSeatNumber = 0 end
		end
		grantSeat(player, i)
	else
		notifyEvent:FireClient(player, "Your cultivation is not yet deep enough to unseat any Sage.", "warn")
	end
end

function SageSeatService.Start()
	seatGranted; seatsSync

	if Config.USE_DATASTORE then
		local ok, result = pcall(function() return DataStoreService:GetDataStore(STORE_NAME) end)
		if ok then store = result end
	end
	load()

	task.spawn(function()
		workspace:WaitForChild("World", 30)
		updateBoard()
	end)

	seatChallenge.OnServerEvent:Connect(challenge)

	DataManager.ProfileLoaded:Connect(function(player: Player)
		task.wait(1.0)
		local existing = seatOfPlayer(player.UserId)
		if existing then player:SetAttribute("SageSeat", existing) end
		tryClaim(player)
		player:GetAttributeChangedSignal("Realm"):Connect(function() tryClaim(player) end)
		seatsSync:FireClient(player, { available = TOTAL_SEATS - countTaken(), total = TOTAL_SEATS, seats = nameList() })
	end)
end

return SageSeatService
