--!strict
-- FateEventData.lua (from index.html — Book of Fortune & Misfortune)
-- Han Jue's signature system: roughly every 30s the Book turns a page and a
-- fate event befalls you. GOOD events need positive karma; BAD events strike
-- when your karma is low. Weight = relative roll chance.

local FateEventData = {}

export type FateEvent = {
	id: string,
	icon: string,
	name: string,
	kind: string,        -- "GOOD" | "NEUTRAL" | "BAD"
	karmaReq: number,    -- only eligible if player karma >= this
	weight: number,
	desc: string,
	effect: string,      -- effect tag handled by FateService
}

FateEventData.EVENTS = {
	{ id="spirit_vein",   icon="💎", name="Spirit Vein Discovered", kind="GOOD",    karmaReq=0,    weight=30, effect="exp_small",   desc="You stumbled upon a hidden spirit vein!" },
	{ id="ancient_ruin",  icon="🏛️", name="Ancient Ruin Found",     kind="GOOD",    karmaReq=0,    weight=20, effect="stones_small",desc="An ancient ruin reveals its secrets to you." },
	{ id="dao_stone",     icon="☯️", name="Dao Stone Appears",      kind="GOOD",    karmaReq=50,   weight=15, effect="exp_med",     desc="A floating Dao stone descends before you." },
	{ id="celestial_dew", icon="💧", name="Celestial Dew Falls",    kind="GOOD",    karmaReq=100,  weight=12, effect="heal_full",   desc="Celestial dew purifies your meridians." },
	{ id="elder_blessing",icon="🧙", name="Elder's Blessing",       kind="GOOD",    karmaReq=200,  weight=8,  effect="exp_big",     desc="A passing immortal elder blesses your cultivation." },
	{ id="heaven_gift",   icon="🌟", name="Heaven Bestows a Gift",  kind="GOOD",    karmaReq=500,  weight=4,  effect="exp_buff",    desc="Heaven itself gifts you for your virtue." },
	{ id="wander_beast",  icon="🐺", name="Wandering Beast Appears",kind="NEUTRAL", karmaReq=-999, weight=25, effect="stones_tiny", desc="A wandering beast challenges you." },
	{ id="qi_fluctuation",icon="🌀", name="Qi Fluctuation",         kind="NEUTRAL", karmaReq=-999, weight=20, effect="nothing",     desc="The surrounding Qi fluctuates wildly." },
	{ id="lost_technique",icon="📜", name="Lost Technique Fragment",kind="NEUTRAL", karmaReq=-100, weight=10, effect="exp_small",   desc="You find a fragment of a lost technique." },
	{ id="karma_backlash",icon="⚠️", name="Karma Backlash",         kind="BAD",     karmaReq=-100, weight=30, effect="dmg_small",   desc="Your dark karma strikes back!" },
	{ id="heaven_punish", icon="⚡", name="Heaven Sends Punishment", kind="BAD",     karmaReq=-200, weight=20, effect="dmg_big",     desc="Heaven punishes you with a lightning bolt." },
	{ id="deviation",     icon="💀", name="Cultivation Deviation",  kind="BAD",     karmaReq=-100, weight=15, effect="exp_loss",    desc="Your dark energy causes a cultivation deviation!" },
	{ id="demon_ambush",  icon="😈", name="Demon Ambush",           kind="BAD",     karmaReq=-300, weight=10, effect="dmg_big",     desc="Your dark karma attracts a demon hunter." },
}

-- Weighted roll among events the player's karma qualifies for.
-- GOOD events only fire when karma >= karmaReq; BAD events only when karma <= karmaReq
-- (the more negative your karma, the more BAD events you unlock).
function FateEventData.Roll(karma: number): FateEvent
	local pool = {}
	local total = 0
	for _, e in ipairs(FateEventData.EVENTS) do
		local eligible
		if e.kind == "GOOD" then
			eligible = karma >= e.karmaReq
		elseif e.kind == "BAD" then
			eligible = karma <= e.karmaReq
		else
			eligible = true
		end
		if eligible then
			total += e.weight
			table.insert(pool, { e = e, cum = total })
		end
	end
	if total == 0 then return FateEventData.EVENTS[8] end  -- Qi Fluctuation fallback
	local r = math.random() * total
	for _, entry in ipairs(pool) do
		if r <= entry.cum then return entry.e end
	end
	return pool[#pool].e
end

return FateEventData
