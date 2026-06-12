--!strict
-- QuestData.lua (generated from index.html)

local QuestData = {}

export type Quest = {
	id: number, name: string, qtype: string,
	desc: string,
	rewardExp: number, rewardStones: number,
	reqRealm: number, reqStage: number?,
	reqConfirmed: boolean,
}

QuestData.QUESTS = {
	{ id=1, name="Your Fate Awaits", qtype="TUTORIAL", desc="The System has chosen you. Roll all 4 attributes and confirm your Providence to begin your cultivation journey.", rewardExp=0, rewardStones=500, reqRealm=1, reqStage=nil, reqConfirmed=false },
	{ id=2, name="First Breath of Qi", qtype="TUTORIAL", desc="Your Providence is confirmed. Now begin cultivating. Reach Stage 3 of Qi Refinement through meditation.", rewardExp=0, rewardStones=200, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=3, name="Trial by Combat", qtype="TUTORIAL", desc="A cultivator who cannot fight is prey. Press [F] to engage an opponent and claim your first victory.", rewardExp=300, rewardStones=300, reqRealm=1, reqStage=3, reqConfirmed=true },
	{ id=4, name="The Path of Techniques", qtype="TUTORIAL", desc="Bare fists are not enough. Open your Technique panel [T] and equip a technique to enhance your combat ability.", rewardExp=500, rewardStones=200, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=5, name="Wealth of Heaven", qtype="TUTORIAL", desc="Spirit Stones are the lifeblood of cultivation. Accumulate your first 1,000 Spirit Stones through any means.", rewardExp=500, rewardStones=500, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=6, name="Beyond Mortality", qtype="TUTORIAL", desc="Complete all 9 stages of Qi Refinement. Then use the Breakthrough panel [B] to ascend to Foundation Establishment.", rewardExp=0, rewardStones=2000, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=7, name="The Journey Has Begun", qtype="TUTORIAL", desc="You have completed the tutorial. Your true cultivation path begins now. The heavens will test you — be ready.", rewardExp=2000, rewardStones=1000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=8, name="The Golden Core Beckons", qtype="STORY", desc="Foundation Establishment is just the beginning. The Golden Core represents true power. Break through to Golden Core Realm.", rewardExp=10000, rewardStones=3000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=9, name="Prove Your Worth", qtype="STORY", desc="The Foundation Realm is full of powerful cultivators. Defeat 10 of them to establish your reputation.", rewardExp=5000, rewardStones=1500, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=10, name="Touch the Dao", qtype="STORY", desc="At Golden Core, cultivators begin to comprehend the Dao. Unlock a Dao-type technique to begin your comprehension.", rewardExp=8000, rewardStones=2000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=11, name="Soul Beyond the Flesh", qtype="STORY", desc="The Nascent Soul represents the birth of your immortal spirit. This breakthrough changes everything.", rewardExp=50000, rewardStones=10000, reqRealm=4, reqStage=nil, reqConfirmed=true },
	{ id=12, name="Master of Arts", qtype="STORY", desc="A true cultivator masters many arts. Unlock 5 different techniques to expand your combat repertoire.", rewardExp=20000, rewardStones=5000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=13, name="Pillars of Prosperity", qtype="STORY", desc="Resources fuel cultivation. Accumulate 10,000 Spirit Stones to fund your path to immortality.", rewardExp=5000, rewardStones=0, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=14, name="Path of Blood", qtype="STORY", desc="50 victories to carve your name into the cultivation world. The weak exist to be surpassed.", rewardExp=30000, rewardStones=8000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=15, name="The Void Trial", qtype="STORY", desc="Enter the Void and emerge victorious. Breakthrough to Void Amalgamation and demonstrate mastery over space.", rewardExp=200000, rewardStones=50000, reqRealm=5, reqStage=nil, reqConfirmed=true },
	{ id=16, name="Daily Cultivation", qtype="DAILY", desc="Consistent daily cultivation is the foundation of all progress. Meditate for 10 minutes.", rewardExp=500, rewardStones=100, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=17, name="Daily Training", qtype="DAILY", desc="Train your combat arts every day. Win 3 fights to maintain your edge.", rewardExp=600, rewardStones=150, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=18, name="Resource Management", qtype="DAILY", desc="A cultivator must manage resources wisely. Purchase an item from the Spirit Shop today.", rewardExp=300, rewardStones=50, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=19, name="Daily Advancement", qtype="DAILY", desc="Every day should bring new advancement. Reach a new cultivation stage before the day ends.", rewardExp=800, rewardStones=200, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=20, name="Weekly Conquest", qtype="WEEKLY", desc="Dominate the cultivation world this week. 20 victories to cement your growing legend.", rewardExp=5000, rewardStones=1000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=21, name="Weekly Wealth", qtype="WEEKLY", desc="Manage your cultivation economy. Earn 2,000 Spirit Stones this week.", rewardExp=3000, rewardStones=500, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=22, name="Weekly Ascension", qtype="WEEKLY", desc="Growth requires courage. Attempt at least one realm breakthrough this week.", rewardExp=8000, rewardStones=2000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=23, name="Soul Formation", qtype="STORY", desc="The Soul Formation realm — where the soul takes permanent shape. Break through and solidify your spiritual existence.", rewardExp=100000, rewardStones=25000, reqRealm=5, reqStage=nil, reqConfirmed=true },
	{ id=24, name="Amalgamation with the Void", qtype="STORY", desc="Merge with the void itself. Void Amalgamation cultivators can manipulate space and time at will.", rewardExp=500000, rewardStones=100000, reqRealm=6, reqStage=nil, reqConfirmed=true },
	{ id=25, name="Body and Dao as One", qtype="STORY", desc="At Body Integration, the physical body and Dao become one. You are the weapon and the art.", rewardExp=2000000, rewardStones=500000, reqRealm=7, reqStage=nil, reqConfirmed=true },
	{ id=26, name="Heavenly Tribulation", qtype="STORY", desc="The heavens themselves test you. Survive the Tribulation Transcendence to near the gates of immortality.", rewardExp=10000000, rewardStones=2000000, reqRealm=8, reqStage=nil, reqConfirmed=true },
	{ id=27, name="The Final Mortal Realm", qtype="STORY", desc="Mahayana — the final mortal realm. Beyond lies true immortality. Prepare carefully before ascending.", rewardExp=50000000, rewardStones=10000000, reqRealm=9, reqStage=nil, reqConfirmed=true },
	{ id=28, name="Void Domain Training", qtype="DAILY", desc="Elite cultivators train in the unstable Void Domain for maximum growth. Win 5 fights there today.", rewardExp=50000, rewardStones=10000, reqRealm=5, reqStage=nil, reqConfirmed=true },
	{ id=29, name="Immortal Gate Training", qtype="DAILY", desc="Near the Immortal Gate, even daily training pushes your limits. Win 3 battles.", rewardExp=500000, rewardStones=100000, reqRealm=7, reqStage=nil, reqConfirmed=true },
	{ id=30, name="Centurion", qtype="ACHIEVEMENT", desc="A hundred victories mark you as a true combat cultivator. Keep fighting.", rewardExp=10000, rewardStones=2000, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=31, name="Arts Scholar", qtype="ACHIEVEMENT", desc="A scholar of techniques — unlock 10 different arts to broaden your combat repertoire.", rewardExp=25000, rewardStones=5000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=32, name="Spirit Merchant", qtype="ACHIEVEMENT", desc="Financial mastery is part of cultivation. Earn 100,000 Spirit Stones in total.", rewardExp=20000, rewardStones=0, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=33, name="The Burden of Fate", qtype="SECRET", desc="Your Lone Star fate has left a trail of calamity. 30 victories prove you have mastered your curse.", rewardExp=50000, rewardStones=15000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=34, name="Path of Six Paths", qtype="SECRET", desc="Your Six Paths physique responds to six mastered techniques. Unlock them all to awaken its full potential.", rewardExp=200000, rewardStones=50000, reqRealm=5, reqStage=nil, reqConfirmed=true },
	{ id=35, name="Patience of Han Jue", qtype="SECRET", desc="Han Jue spent 11 years rerolling. Use at least 50 rerolls before confirming to honor his patience.", rewardExp=0, rewardStones=1000, reqRealm=1, reqStage=nil, reqConfirmed=false },
	{ id=36, name="Forge the Golden Core", qtype="BREAKTHROUGH", desc="The Golden Core awaits. Break through from Foundation Establishment to forge your Core.", rewardExp=15000, rewardStones=5000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=37, name="Touch the Void", qtype="BREAKTHROUGH", desc="Beyond the Nascent Soul lies the void. Break through and discover what lies in empty space.", rewardExp=100000, rewardStones=25000, reqRealm=4, reqStage=nil, reqConfirmed=true },
	{ id=38, name="Approach the Immortal Gate", qtype="BREAKTHROUGH", desc="The Immortal Gate is within sight. Reach Mahayana — the final step before ascending.", rewardExp=5000000, rewardStones=1000000, reqRealm=8, reqStage=nil, reqConfirmed=true },
	{ id=39, name="Generous Cultivator", qtype="SOCIAL", desc="A generous spirit strengthens the cultivation community. Send Spirit Stones to a fellow cultivator.", rewardExp=1000, rewardStones=200, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=40, name="Spirit Rich", qtype="SOCIAL", desc="Wealth follows true cultivation power. Accumulate 50,000 Spirit Stones total.", rewardExp=20000, rewardStones=5000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=41, name="The Art of Combat", qtype="STORY", desc="Raw strength alone is not enough. Study a technique to begin mastering the arts of cultivation combat.", rewardExp=500, rewardStones=200, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=42, name="Rising from Defeat", qtype="STORY", desc="Every cultivator falls at some point. What matters is rising again. Win 3 more fights.", rewardExp=400, rewardStones=150, reqRealm=1, reqStage=2, reqConfirmed=true },
	{ id=43, name="The Spirit Market", qtype="STORY", desc="Resources are the foundation of cultivation. Visit the Spirit Shop and purchase your first item.", rewardExp=300, rewardStones=0, reqRealm=1, reqStage=3, reqConfirmed=true },
	{ id=44, name="The Price of Ambition", qtype="STORY", desc="Stage 9 has been reached. Now attempt the breakthrough. Success or failure — either teaches you something.", rewardExp=1000, rewardStones=500, reqRealm=1, reqStage=9, reqConfirmed=true },
	{ id=45, name="Curse of the Lone Star", qtype="SECRET", desc="The Lone Star brings misfortune to all who approach. Show the heavens you can turn this curse into power.", rewardExp=5000, rewardStones=1000, reqRealm=1, reqStage=nil, reqConfirmed=true },
	{ id=46, name="Six Paths Awakening", qtype="SECRET", desc="The Spiritual Physique of Six Paths allows mastery of all cultivation paths. Unlock 6 techniques to begin the awakening.", rewardExp=20000, rewardStones=5000, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=47, name="Chaos Transcendence", qtype="SECRET", desc="Chaos Dao transcends all elements. Defeat 100 opponents to fully awaken your Chaos Dao power.", rewardExp=500000, rewardStones=100000, reqRealm=5, reqStage=nil, reqConfirmed=true },
	{ id=48, name="Foundation Mastery", qtype="STORY", desc="Foundation Establishment is more than a title. Prove your mastery of this realm through 20 decisive victories.", rewardExp=8000, rewardStones=2000, reqRealm=2, reqStage=5, reqConfirmed=true },
	{ id=49, name="Comprehending the Golden Core Dao", qtype="STORY", desc="The Golden Core resonates with the Dao. At this realm, technique comprehension opens new paths. Unlock 3 techniques.", rewardExp=15000, rewardStones=4000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=50, name="Soul Projection Test", qtype="STORY", desc="The Nascent Soul can project beyond the body. Test your new power in 15 battles where your soul fights as much as your body.", rewardExp=30000, rewardStones=8000, reqRealm=4, reqStage=nil, reqConfirmed=true },
	{ id=51, name="Heaven's Survivor", qtype="ACHIEVEMENT", desc="The heavens test all cultivators through tribulations and breakthrough trials. Survive 5 breakthrough attempts.", rewardExp=50000, rewardStones=10000, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=52, name="Stone Millionaire", qtype="ACHIEVEMENT", desc="A million Spirit Stones is a significant milestone in the cultivation world. Achieve this wealth.", rewardExp=100000, rewardStones=0, reqRealm=3, reqStage=nil, reqConfirmed=true },
	{ id=53, name="Five Star Cultivator", qtype="ACHIEVEMENT", desc="Five different arts mastered. You are becoming a well-rounded cultivator.", rewardExp=10000, rewardStones=2500, reqRealm=2, reqStage=nil, reqConfirmed=true },
	{ id=54, name="Swift Ascension", qtype="ACHIEVEMENT", desc="Some cultivators take years to reach Foundation Establishment. Prove your efficiency.", rewardExp=5000, rewardStones=1000, reqRealm=1, reqStage=nil, reqConfirmed=true },
}

local _byId: {[number]: Quest} = {}
for _, q in ipairs(QuestData.QUESTS) do _byId[q.id] = q end

function QuestData.GetQuest(id: number): Quest?
	return _byId[id]
end

-- ════════════════════════════════════════════════════════════
-- NPC QUEST CHAINS — sequential quests handed out by hub NPCs.
-- Each chain unlocks one quest at a time (complete ve_01 → ve_02
-- becomes available). Players can hold max 3 active NPC quests
-- (enforced in QuestService.MAX_NPC_ACTIVE).
-- ════════════════════════════════════════════════════════════

export type NpcObjective = {
	type: string,         -- "kill" | "kill_realm" | "reach_realm" | "earn_stones"
	target: string?,      -- NPC name for "kill" (plain substring match)
	realm: number?,       -- realm id for "kill_realm" / "reach_realm"
	count: number?,       -- kills / stones needed
	desc: string,
}

export type NpcRewards = { exp: number?, stones: number? }

export type NpcQuest = {
	id: string,
	chain: string,        -- chain key (one chain per NPC giver)
	step: number,         -- position in the chain (1 = starter)
	giver: string,        -- display name of the quest-giving NPC
	icon: string,
	title: string,
	desc: string,
	objectives: { NpcObjective },
	rewards: NpcRewards,
	next: string?,        -- id of the follow-up quest (nil = chain end)
}

QuestData.NPC_CHAINS = {
	-- ── World 1 · Village Elder — early-game beast culling ──────
	village_elder = {
		{ id="ve_01", chain="village_elder", step=1, giver="Village Elder", icon="👴",
		  title="Wolves at the Gates",
		  desc="Qi Wolves have been prowling near the village. Cull 5 of them in the Qi Meadow.",
		  objectives={ { type="kill", target="Qi Wolf", count=5, desc="Defeat 5 Qi Wolves" } },
		  rewards={ exp=400, stones=150 }, next="ve_02" },
		{ id="ve_02", chain="village_elder", step=2, giver="Village Elder", icon="👴",
		  title="Pest Control",
		  desc="The Spirit Rabbits are eating our herb gardens bare. Thin their numbers.",
		  objectives={ { type="kill", target="Spirit Rabbit", count=3, desc="Defeat 3 Spirit Rabbits" } },
		  rewards={ exp=500, stones=200 }, next="ve_03" },
		{ id="ve_03", chain="village_elder", step=3, giver="Village Elder", icon="👴",
		  title="The Alpha",
		  desc="A crowned beast leads the pack — the Realm Guardian Wolf. Slay it and the meadow will know peace.",
		  objectives={ { type="kill", target="Realm Guardian Wolf", count=1, desc="Defeat the Realm Guardian Wolf" } },
		  rewards={ exp=1500, stones=600 }, next="ve_04" },
		{ id="ve_04", chain="village_elder", step=4, giver="Village Elder", icon="👴",
		  title="Sly Tails",
		  desc="Qi Foxes have been stealing offerings from the shrine. Teach them a lesson.",
		  objectives={ { type="kill", target="Qi Fox", count=8, desc="Defeat 8 Qi Foxes" } },
		  rewards={ exp=700, stones=250 }, next="ve_05" },
		{ id="ve_05", chain="village_elder", step=5, giver="Village Elder", icon="👴",
		  title="Meadow Warden",
		  desc="Patrol the whole Qi Meadow. Drive back twenty-five beasts so the farmers can work in peace.",
		  objectives={ { type="kill_realm", realm=1, count=25, desc="Defeat 25 beasts in the Qi Meadow" } },
		  rewards={ exp=1200, stones=400 }, next="ve_06" },
		{ id="ve_06", chain="village_elder", step=6, giver="Village Elder", icon="👴",
		  title="The Old Bear of the Hills",
		  desc="Spirit Bears have grown bold. Fell three of them and the village will sing your name.",
		  objectives={ { type="kill", target="Spirit Bear", count=3, desc="Defeat 3 Spirit Bears" } },
		  rewards={ exp=2500, stones=900 }, next=nil },
	},
	-- ── World 1 · Cultivation Master — the realm-ascension arc ──
	cultivation_master = {
		{ id="cm_01", chain="cultivation_master", step=1, giver="Cultivation Master", icon="🧙",
		  title="Beyond Qi Refinement",
		  desc="Your foundation must be solid. Break through to the Foundation Establishment realm.",
		  objectives={ { type="reach_realm", realm=2, desc="Reach Foundation Establishment (Realm 2)" } },
		  rewards={ exp=800, stones=300 }, next="cm_02" },
		{ id="cm_02", chain="cultivation_master", step=2, giver="Cultivation Master", icon="🧙",
		  title="Test of the Cliffs",
		  desc="Strength is proven in battle. Defeat 10 beasts in the Foundation Cliffs.",
		  objectives={ { type="kill_realm", realm=2, count=10, desc="Defeat 10 beasts in the Realm-2 zone" } },
		  rewards={ exp=2000, stones=700 }, next="cm_03" },
		{ id="cm_03", chain="cultivation_master", step=3, giver="Cultivation Master", icon="🧙",
		  title="Forge the Golden Core",
		  desc="You are ready. Condense your Golden Core and step into true cultivation.",
		  objectives={ { type="reach_realm", realm=3, desc="Reach Golden Core (Realm 3)" } },
		  rewards={ exp=6000, stones=2000 }, next="cm_04" },
		{ id="cm_04", chain="cultivation_master", step=4, giver="Cultivation Master", icon="🧙",
		  title="Birth of the Nascent Soul",
		  desc="The core cracks; the soul emerges. Ascend to the Nascent Soul realm.",
		  objectives={ { type="reach_realm", realm=4, desc="Reach Nascent Soul (Realm 4)" } },
		  rewards={ exp=80000, stones=20000 }, next="cm_05" },
		{ id="cm_05", chain="cultivation_master", step=5, giver="Cultivation Master", icon="🧙",
		  title="Soul Tempering",
		  desc="A young Nascent Soul must be tempered in battle. Hunt fifteen foes in the Nascent Soul Vale.",
		  objectives={ { type="kill_realm", realm=4, count=15, desc="Defeat 15 beasts in the Realm-4 zone" } },
		  rewards={ exp=150000, stones=30000 }, next="cm_06" },
		{ id="cm_06", chain="cultivation_master", step=6, giver="Cultivation Master", icon="🧙",
		  title="Merge with the Void",
		  desc="Beyond the soul lies empty space itself. Reach Void Amalgamation.",
		  objectives={ { type="reach_realm", realm=6, desc="Reach Void Amalgamation (Realm 6)" } },
		  rewards={ exp=3000000, stones=200000 }, next="cm_07" },
		{ id="cm_07", chain="cultivation_master", step=7, giver="Cultivation Master", icon="🧙",
		  title="Body and Dao as One",
		  desc="Prove your integrated body in the Body Forge. Twenty victories.",
		  objectives={ { type="kill_realm", realm=7, count=20, desc="Defeat 20 beasts in the Realm-7 zone" } },
		  rewards={ exp=30000000, stones=1000000 }, next="cm_08" },
		{ id="cm_08", chain="cultivation_master", step=8, giver="Cultivation Master", icon="🧙",
		  title="The Final Mortal Step",
		  desc="Mahayana — the last realm before true immortality. I have nothing more to teach you.",
		  objectives={ { type="reach_realm", realm=9, desc="Reach Mahayana (Realm 9)" } },
		  rewards={ exp=400000000, stones=5000000 }, next=nil },
	},
	-- ── World 1 · Merchant — the wealth arc ─────────────────────
	merchant = {
		{ id="mer_01", chain="merchant", step=1, giver="Merchant", icon="💰",
		  title="Seed Capital",
		  desc="Coin makes the world turn, cultivator. Earn 2,000 Spirit Stones in total and I'll know you're serious.",
		  objectives={ { type="earn_stones", count=2000, desc="Earn 2,000 lifetime Spirit Stones" } },
		  rewards={ exp=600, stones=400 }, next="mer_02" },
		{ id="mer_02", chain="merchant", step=2, giver="Merchant", icon="💰",
		  title="Shell Shortage",
		  desc="Iron Beetle shells fetch a fine price. Bring down 5 of them for my caravan.",
		  objectives={ { type="kill", target="Iron Beetle", count=5, desc="Defeat 5 Iron Beetles" } },
		  rewards={ exp=900, stones=500 }, next="mer_03" },
		{ id="mer_03", chain="merchant", step=3, giver="Merchant", icon="💰",
		  title="Growing Portfolio",
		  desc="Ten thousand lifetime stones. That's when the guilds start to take notice of a cultivator.",
		  objectives={ { type="earn_stones", count=10000, desc="Earn 10,000 lifetime Spirit Stones" } },
		  rewards={ exp=2000, stones=1500 }, next="mer_04" },
		{ id="mer_04", chain="merchant", step=4, giver="Merchant", icon="💰",
		  title="Turtle Shell Armor",
		  desc="Iron Shell Turtle plates sell to every smith on the continent. Six shells, if you please.",
		  objectives={ { type="kill", target="Iron Shell Turtle", count=6, desc="Defeat 6 Iron Shell Turtles" } },
		  rewards={ exp=4000, stones=2000 }, next="mer_05" },
		{ id="mer_05", chain="merchant", step=5, giver="Merchant", icon="💰",
		  title="Spirit Magnate",
		  desc="A hundred thousand lifetime stones! Keep this up and you could buy the village.",
		  objectives={ { type="earn_stones", count=100000, desc="Earn 100,000 lifetime Spirit Stones" } },
		  rewards={ exp=60000, stones=10000 }, next="mer_06" },
		{ id="mer_06", chain="merchant", step=6, giver="Merchant", icon="💰",
		  title="The Million-Stone Cultivator",
		  desc="One million lifetime Spirit Stones. At that point, my friend, YOU are the economy.",
		  objectives={ { type="earn_stones", count=1000000, desc="Earn 1,000,000 lifetime Spirit Stones" } },
		  rewards={ exp=1000000, stones=100000 }, next=nil },
	},
	-- ── World 1 · Beast Hunter Lin — the boss-trophy ladder ─────
	beast_hunter = {
		{ id="bh_01", chain="beast_hunter", step=1, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Foundation Guardian",
		  desc="Every realm zone is ruled by a crowned beast. Bring me proof you felled the Foundation Guardian.",
		  objectives={ { type="kill", target="Foundation Guardian", count=1, desc="Defeat the Foundation Guardian (R2 boss)" } },
		  rewards={ exp=1500, stones=500 }, next="bh_02" },
		{ id="bh_02", chain="beast_hunter", step=2, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Golden Core Sovereign",
		  desc="The Sovereign of the Pagoda Grounds has bested every hunter so far. Be the first.",
		  objectives={ { type="kill", target="Golden Core Sovereign", count=1, desc="Defeat the Golden Core Sovereign (R3 boss)" } },
		  rewards={ exp=4000, stones=1200 }, next="bh_03" },
		{ id="bh_03", chain="beast_hunter", step=3, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Demon King",
		  desc="The Nascent Soul Demon King haunts the Vale. End its reign.",
		  objectives={ { type="kill", target="Nascent Soul Demon King", count=1, desc="Defeat the Nascent Soul Demon King (R4 boss)" } },
		  rewards={ exp=30000, stones=8000 }, next="bh_04" },
		{ id="bh_04", chain="beast_hunter", step=4, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Creation Dao Sovereign",
		  desc="They say the Soul Spring's ruler commands creation itself. Prove them wrong.",
		  objectives={ { type="kill", target="Creation Dao Sovereign", count=1, desc="Defeat the Creation Dao Sovereign (R5 boss)" } },
		  rewards={ exp=150000, stones=40000 }, next="bh_05" },
		{ id="bh_05", chain="beast_hunter", step=5, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Body Integration Sovereign",
		  desc="Fifty thousand cultivators have tried. The Void Reaches' Sovereign still stands. For now.",
		  objectives={ { type="kill", target="Body Integration Sovereign", count=1, desc="Defeat the Body Integration Sovereign (R6 boss)" } },
		  rewards={ exp=3000000, stones=600000 }, next="bh_06" },
		{ id="bh_06", chain="beast_hunter", step=6, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Heaven's Wrath",
		  desc="The storm above the Body Forge has a heart — and it beats. Stop it.",
		  objectives={ { type="kill", target="Heaven's Wrath", count=1, desc="Defeat Heaven's Wrath (R7 boss)" } },
		  rewards={ exp=40000000, stones=8000000 }, next="bh_07" },
		{ id="bh_07", chain="beast_hunter", step=7, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: Creation Will",
		  desc="On the Tribulation Plateau an ancient will refuses every challenger. Refuse it back.",
		  objectives={ { type="kill", target="Creation Will", count=1, desc="Defeat the Creation Will (R8 boss)" } },
		  rewards={ exp=500000000, stones=80000000 }, next="bh_08" },
		{ id="bh_08", chain="beast_hunter", step=8, giver="Beast Hunter Lin", icon="🏹",
		  title="Trophy: The Overseer",
		  desc="The Simulation's Overseer watches the Mahayana Summit. Tear down the watcher, hunter.",
		  objectives={ { type="kill", target="The Simulation's Overseer", count=1, desc="Defeat The Simulation's Overseer (R9 boss)" } },
		  rewards={ exp=3000000000, stones=300000000 }, next=nil },
	},
	-- ── World 2 · Immortal Envoy — the Immortal Sky arc ─────────
	immortal_envoy = {
		{ id="ie_01", chain="immortal_envoy", step=1, giver="Immortal Envoy", icon="🏮",
		  title="Welcome, Immortal",
		  desc="You stand in the Immortal Sky. Shed the last of your mortality — reach the Loose Immortal realm.",
		  objectives={ { type="reach_realm", realm=10, desc="Reach Loose Immortal (Realm 10)" } },
		  rewards={ exp=1000000000, stones=100000 }, next="ie_02" },
		{ id="ie_02", chain="immortal_envoy", step=2, giver="Immortal Envoy", icon="🏮",
		  title="Trial of the Drifting Clouds",
		  desc="The Drifting Cloud Isle teems with wild immortal beasts. Defeat 10 of them.",
		  objectives={ { type="kill_realm", realm=10, count=10, desc="Defeat 10 foes on the Drifting Cloud Isle" } },
		  rewards={ exp=2000000000, stones=200000 }, next="ie_03" },
		{ id="ie_03", chain="immortal_envoy", step=3, giver="Immortal Envoy", icon="🏮",
		  title="The Sovereign of Loose Immortals",
		  desc="A renegade sovereign claims the isle. The Heavenly Court requests their removal.",
		  objectives={ { type="kill", target="Loose Immortal Sovereign", count=1, desc="Defeat the Loose Immortal Sovereign (R10 boss)" } },
		  rewards={ exp=3000000000, stones=300000 }, next="ie_04" },
		{ id="ie_04", chain="immortal_envoy", step=4, giver="Immortal Envoy", icon="🏮",
		  title="Ascend the Star Bridge",
		  desc="The Heaven Immortal realm awaits those who cross the Star Bridge. Cross it.",
		  objectives={ { type="reach_realm", realm=12, desc="Reach Heaven Immortal (Realm 12)" } },
		  rewards={ exp=6000000000, stones=500000 }, next="ie_05" },
		{ id="ie_05", chain="immortal_envoy", step=5, giver="Immortal Envoy", icon="🏮",
		  title="Gardens of the True",
		  desc="The True Immortal Gardens must be cleansed of intruders. Fifteen victories.",
		  objectives={ { type="kill_realm", realm=13, count=15, desc="Defeat 15 foes in the True Immortal Gardens" } },
		  rewards={ exp=8000000000, stones=800000 }, next="ie_06" },
		{ id="ie_06", chain="immortal_envoy", step=6, giver="Immortal Envoy", icon="🏮",
		  title="Golden Radiance",
		  desc="Golden Immortal — the summit of this sky. Reach it, and the Sage Heaven will open its gates.",
		  objectives={ { type="reach_realm", realm=15, desc="Reach Golden Immortal (Realm 15)" } },
		  rewards={ exp=15000000000, stones=1500000 }, next=nil },
	},
	-- ── World 3 · Sage Oracle — the Sage Heaven arc ─────────────
	sage_oracle = {
		{ id="so_01", chain="sage_oracle", step=1, giver="Sage Oracle", icon="🔮",
		  title="The Emperor's Mandate",
		  desc="Only an Immortal Emperor may walk the Sage Heaven freely. Claim that mandate.",
		  objectives={ { type="reach_realm", realm=16, desc="Reach Immortal Emperor (Realm 16)" } },
		  rewards={ exp=14000000000, stones=2000000 }, next="so_02" },
		{ id="so_02", chain="sage_oracle", step=2, giver="Sage Oracle", icon="🔮",
		  title="Ruins of the Old Court",
		  desc="The Imperial Court Ruins crawl with usurper spirits. Scatter a dozen of them.",
		  objectives={ { type="kill_realm", realm=16, count=12, desc="Defeat 12 foes in the Imperial Court Ruins" } },
		  rewards={ exp=16000000000, stones=2500000 }, next="so_03" },
		{ id="so_03", chain="sage_oracle", step=3, giver="Sage Oracle", icon="🔮",
		  title="Depose the Regent",
		  desc="A false regent sits the ruined throne. The Oracle has foreseen your victory — make it true.",
		  objectives={ { type="kill", target="Immortal Emperor's Regent", count=1, desc="Defeat the Immortal Emperor's Regent (R16 boss)" } },
		  rewards={ exp=20000000000, stones=3000000 }, next="so_04" },
		{ id="so_04", chain="sage_oracle", step=4, giver="Sage Oracle", icon="🔮",
		  title="Zenith of Heaven",
		  desc="Climb past the Divine Origin to the Zenith Heaven itself.",
		  objectives={ { type="reach_realm", realm=18, desc="Reach Zenith Heaven Golden Immortal (Realm 18)" } },
		  rewards={ exp=22000000000, stones=4000000 }, next="so_05" },
		{ id="so_05", chain="sage_oracle", step=5, giver="Sage Oracle", icon="🔮",
		  title="The Half-Step Plateau",
		  desc="Quasi-Sages gather at the threshold, testing all who pass. Best fifteen of them.",
		  objectives={ { type="kill_realm", realm=19, count=15, desc="Defeat 15 foes on the Half-Step Plateau" } },
		  rewards={ exp=25000000000, stones=5000000 }, next="so_06" },
		{ id="so_06", chain="sage_oracle", step=6, giver="Sage Oracle", icon="🔮",
		  title="Lesson for an Ancestor",
		  desc="The Perfect Sage Ancestor lectures eternally in the Halls. End the lecture.",
		  objectives={ { type="kill", target="Perfect Sage Ancestor", count=1, desc="Defeat the Perfect Sage Ancestor (R20 boss)" } },
		  rewards={ exp=28000000000, stones=6000000 }, next="so_07" },
		{ id="so_07", chain="sage_oracle", step=7, giver="Sage Oracle", icon="🔮",
		  title="Sea of the Great Dao",
		  desc="Cross the Dao Sea and stand at the brink of the Primal Chaos. Reach the Great Dao Primordial Chaos realm.",
		  objectives={ { type="reach_realm", realm=22, desc="Reach Great Dao Primordial Chaos (Realm 22)" } },
		  rewards={ exp=32000000000, stones=8000000 }, next=nil },
	},
	-- ── World 4 · Chaos Warden — the endgame arc ────────────────
	chaos_warden = {
		{ id="cw_01", chain="chaos_warden", step=1, giver="Chaos Warden", icon="🌑",
		  title="Supreme Mandate",
		  desc="The Primal Chaos consumes the unworthy. Become Great Dao Supreme, or be consumed.",
		  objectives={ { type="reach_realm", realm=23, desc="Reach Great Dao Supreme (Realm 23)" } },
		  rewards={ exp=35000000000, stones=10000000 }, next="cw_02" },
		{ id="cw_02", chain="chaos_warden", step=2, giver="Chaos Warden", icon="🌑",
		  title="Hold the Spire",
		  desc="The Supreme Mandate Spire is under siege by chaos-born horrors. Hold the line — ten victories.",
		  objectives={ { type="kill_realm", realm=23, count=10, desc="Defeat 10 foes at the Supreme Mandate Spire" } },
		  rewards={ exp=38000000000, stones=12000000 }, next="cw_03" },
		{ id="cw_03", chain="chaos_warden", step=3, giver="Chaos Warden", icon="🌑",
		  title="Unmake the Maker",
		  desc="A rogue avatar of creation seeds false universes in the Nursery. Unmake it.",
		  objectives={ { type="kill", target="Dao Creation Avatar", count=1, desc="Defeat the Dao Creation Avatar (R24 boss)" } },
		  rewards={ exp=45000000000, stones=15000000 }, next="cw_04" },
		{ id="cw_04", chain="chaos_warden", step=4, giver="Chaos Warden", icon="🌑",
		  title="Lord of Creation",
		  desc="Few in any era have stood where you now reach. Become a Creator Lord.",
		  objectives={ { type="reach_realm", realm=25, desc="Reach Creator Lord (Realm 25)" } },
		  rewards={ exp=50000000000, stones=20000000 }, next="cw_05" },
		{ id="cw_05", chain="chaos_warden", step=5, giver="Chaos Warden", icon="🌑",
		  title="The Origin Point",
		  desc="At the Origin Point waits the final avatar. Beyond it lies nothing — and everything. This is the last quest I have for you.",
		  objectives={ { type="kill", target="Avatar of the Ultimate Origin", count=1, desc="Defeat the Avatar of the Ultimate Origin (R26 boss)" } },
		  rewards={ exp=80000000000, stones=40000000 }, next=nil },
	},
}

-- Flat lookup by quest id.
QuestData.NPC_ALL = {} :: { [string]: NpcQuest }
for _, chain in pairs(QuestData.NPC_CHAINS) do
	for _, q in ipairs(chain) do
		QuestData.NPC_ALL[q.id] = q
	end
end

-- The quest that unlocks after `completedId` (nil if chain ends there).
function QuestData.GetNextNpcQuest(completedId: string): NpcQuest?
	local q = QuestData.NPC_ALL[completedId]
	if q and q.next then return QuestData.NPC_ALL[q.next] end
	return nil
end

-- First quest of every chain (what a fresh player can accept).
function QuestData.GetNpcStarterQuests(): { NpcQuest }
	local out: { NpcQuest } = {}
	for _, chain in pairs(QuestData.NPC_CHAINS) do
		if chain[1] then table.insert(out, chain[1]) end
	end
	table.sort(out, function(a, b) return a.id < b.id end)
	return out
end

return QuestData
