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

return QuestData
