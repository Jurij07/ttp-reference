--!strict
-- HanJueShrineService.lua
-- The Book of Misfortune shrine in the Spawn Village. Praying once per day
-- grants +100 Karma and a random lore line from Han Jue's story.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local DataManager = require(script.Parent.DataManager)

local HanJueShrineService = {}

local notifyEvent    = Net.Event("Notify")
local shrineBlessing = Net.Event("ShrineBlessing")

local DAY_SECONDS = 24 * 60 * 60
local KARMA_REWARD = 100

local LORE = {
	"Han Jue cultivated in silence for ten thousand years, asking nothing of the heavens.",
	"The Book of Misfortune records the karma of all who would do him harm.",
	"To walk the Lone Path is to need neither master nor sect.",
	"Patience is the deepest Dao; the impatient perish before their time.",
	"He who fears the tribulation will never cross Heaven's Gate.",
	"The solitary immortal watched empires rise and crumble like morning frost.",
	"Karma is a debt — the heavens always collect.",
	"Even the Great Dao bends before one who refuses to be hurried.",
	"Secretly cultivate; let the world forget your name until it cannot.",
	"A single thought of the Origin can unmake a thousand worlds.",
	"The Ninth Chaos feared only the one who never sought power.",
	"Misfortune visited his enemies; fortune kept its distance, as he wished.",
	"In stillness he heard the Dao; in haste, others heard only their own deaths.",
	"The Samsara wheel turns, yet he stepped off it long ago.",
	"True freedom is owing nothing to fate.",
	"He wrote his own ending, beyond the Blank Realm, beyond all stories.",
	"Spirit stones buy comfort; only time buys transcendence.",
	"The strongest sword is the one never drawn.",
	"Heaven envies the cultivator who needs nothing from it.",
	"When all paths end, the Origin remains — and so does he.",
}

local function pray(player: Player)
	local profile = DataManager.Get(player)
	if not profile then return end
	local now = os.time()
	local last = (profile.hanJueShrineLastPrayed or 0) :: number
	if now - last < DAY_SECONDS then
		local hrs = math.ceil((DAY_SECONDS - (now - last)) / 3600)
		notifyEvent:FireClient(player, ("📿 Already prayed today — return in ~%dh."):format(hrs), "info")
		return
	end
	profile.hanJueShrineLastPrayed = now
	profile.karma = (profile.karma or 0) + KARMA_REWARD
	player:SetAttribute("Karma", profile.karma)
	local lore = LORE[math.random(1, #LORE)]
	shrineBlessing:FireClient(player, KARMA_REWARD, lore)
	notifyEvent:FireClient(player, ("📖 You pray at the shrine. +%d Karma."):format(KARMA_REWARD), "gold")
end

function HanJueShrineService.Start()
	task.spawn(function()
		workspace:WaitForChild("World", 30)
		for _, shrine in ipairs(CollectionService:GetTagged("Shrine")) do
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Pray"
			prompt.ObjectText = "Book of Misfortune"
			prompt.HoldDuration = 1
			prompt.MaxActivationDistance = 14
			prompt.RequiresLineOfSight = false
			prompt.Parent = shrine
			prompt.Triggered:Connect(function(player) pray(player) end)
		end
	end)
end

return HanJueShrineService
