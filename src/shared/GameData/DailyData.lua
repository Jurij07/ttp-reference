--!strict
-- DailyData.lua
-- Pool of daily-mission templates. Three are drawn each day from this pool.
-- "type" drives the server-side objective check:
--   exp_earn  – earn X EXP today
--   stones_earn – earn X spirit stones today
--   kills     – kill X enemies today (auto-hunt counts)
--   seclusion – complete one seclusion session
--   realm_hunt – run N auto-hunt ticks today

local DailyData = {}

export type DailyTask = {
	id: string, title: string, icon: string,
	type: string, target: number,
	rewardStones: number, rewardExp: number,
}

DailyData.POOL = {
	{ id="d_exp_sm",    title="Morning Cultivation",   icon="☯️",  type="exp_earn",   target=5000,    rewardStones=200,  rewardExp=0    },
	{ id="d_exp_md",    title="Dedicated Meditation",  icon="🧘",  type="exp_earn",   target=25000,   rewardStones=500,  rewardExp=0    },
	{ id="d_stones_sm", title="Mine the Veins",        icon="💰",  type="stones_earn", target=300,    rewardStones=0,    rewardExp=2000 },
	{ id="d_stones_md", title="Wealthy Cultivator",    icon="💎",  type="stones_earn", target=1500,   rewardStones=0,    rewardExp=8000 },
	{ id="d_kills_sm",  title="Daily Hunt",            icon="⚔️",  type="kills",      target=20,      rewardStones=300,  rewardExp=3000 },
	{ id="d_kills_md",  title="Beast Slayer",          icon="🐉",  type="kills",      target=80,      rewardStones=700,  rewardExp=7000 },
	{ id="d_kills_lg",  title="Relentless Cultivator", icon="👑",  type="kills",      target=200,     rewardStones=1500, rewardExp=15000},
	{ id="d_seclusion", title="Closed-Door Retreat",   icon="🚪",  type="seclusion",  target=1,       rewardStones=600,  rewardExp=5000 },
	{ id="d_hunt_ticks",title="Tireless Auto-Hunter",  icon="🏹",  type="realm_hunt", target=50,      rewardStones=400,  rewardExp=4000 },
	{ id="d_exp_lg",    title="Grand Dao Insight",     icon="✨",  type="exp_earn",   target=100000,  rewardStones=1200, rewardExp=0    },
} :: { DailyTask }

function DailyData.Get(id: string): DailyTask?
	for _, t in ipairs(DailyData.POOL) do
		if t.id == id then return t end
	end
	return nil
end

return DailyData
