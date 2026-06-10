--!strict
-- TitleData.lua (from index.html — 25 Titles & Achievements)
-- Titles auto-unlock when their condition is met. The player may equip one
-- title for its passive bonus. Conditions reference tracked profile stats.

local TitleData = {}

export type Title = {
	id: string,
	icon: string,
	name: string,
	rarity: string,
	condType: string,    -- realm|kills|pvp_wins|sect|sect_level|dao_count|stones|tribulations|karma
	condValue: number,
	-- folded bonuses (1.0 = none unless noted)
	dmgMult: number, defMult: number, hpMult: number, expMult: number, stoneMult: number,
	breakBonus: number,  -- additive tribulation resist
	desc: string,
}

local function T(id,icon,name,rar,ct,cv,dmg,def,hp,exp,stone,brk,desc)
	return { id=id, icon=icon, name=name, rarity=rar, condType=ct, condValue=cv,
		dmgMult=dmg, defMult=def, hpMult=hp, expMult=exp, stoneMult=stone, breakBonus=brk, desc=desc }
end

TitleData.TITLES = {
	-- Realm titles
	T("lone_cultivator","🌙","Lone Cultivator","Common","realm",1, 1,1,1,1.03,1,0,"Reach Realm 1"),
	T("qi_seeker","💫","Qi Seeker","Common","realm",2, 1,1,1,1.05,1,0,"Reach Realm 2"),
	T("core_forger","🔶","Core Forger","Uncommon","realm",3, 1,1,1,1.08,1,0,"Reach Realm 3"),
	T("soul_cultivator","👻","Soul Cultivator","Uncommon","realm",4, 1,1,1,1.12,1,0,"Reach Realm 4"),
	T("void_walker","🌌","Void Walker","Rare","realm",5, 1,1,1,1.18,1,0,"Reach Realm 5"),
	T("body_saint","💪","Body Saint","Rare","realm",6, 1,1.10,1.10,1,1,0,"Reach Realm 6"),
	T("tribulation_saint","⚡","Tribulation Saint","Epic","realm",7, 1.08,1.08,1.08,1.08,1,0,"Reach Realm 7"),
	T("mahayana_master","🏯","Mahayana Master","Legendary","realm",8, 1.15,1.15,1.15,1.15,1,0,"Reach Realm 8"),
	T("immortal_title","✨","Immortal","Divine","realm",9, 1.25,1.25,1.25,1.30,1,0,"Reach Realm 9"),
	-- Kill titles
	T("first_kill","🩸","First Kill","Common","kills",1, 1.02,1,1,1,1,0,"Defeat 1 foe"),
	T("warrior","⚔️","Warrior","Uncommon","kills",50, 1.05,1,1,1,1,0,"Defeat 50 foes"),
	T("slayer","💀","Slayer","Rare","kills",500, 1.10,1,1,1,1,0,"Defeat 500 foes"),
	T("demon_slayer","😈","Demon Slayer","Epic","kills",5000, 1.18,1,1,1,1,0,"Defeat 5000 foes"),
	T("warlord","👑","Warlord","Legendary","kills",50000, 1.30,1,1,1,1,0,"Defeat 50000 foes"),
	-- PvP titles
	T("duelist","🥊","Duelist","Uncommon","pvp_wins",1, 1.03,1,1,1,1,0,"Win 1 PvP fight"),
	T("pvp_veteran","⚔️","PvP Veteran","Rare","pvp_wins",25, 1.08,1,1,1,1,0,"Win 25 PvP fights"),
	T("undefeated","🏆","Undefeated","Epic","pvp_wins",100, 1.12,1.12,1.12,1,1,0,"Win 100 PvP fights"),
	-- Sect / Dao titles
	T("sect_disciple","🏯","Sect Disciple","Common","sect",1, 1,1,1,1.05,1,0,"Join a sect"),
	T("sect_elder","☯️","Sect Elder","Rare","sect_level",5, 1.05,1.05,1.05,1.12,1,0,"Reach sect level 5"),
	T("dao_enlightened","☯️","Dao Enlightened","Epic","dao_count",3, 1,1,1,1.15,1,0,"Master 3 Daos"),
	T("dao_master","✨","Dao Master","Legendary","dao_count",7, 1.10,1.10,1.10,1.30,1,0,"Master 7 Daos"),
	-- Wealth / tribulation / karma
	T("rich_cultivator","💰","Rich Cultivator","Uncommon","stones",100000, 1,1,1,1,1.10,0,"Earn 100K stones"),
	T("stone_king","💎","Spirit Stone King","Rare","stones",10000000, 1,1,1,1,1.20,0,"Earn 10M stones"),
	T("tribulation_survivor","⚡","Tribulation Survivor","Epic","tribulations",1, 1,1,1,1,1,0.10,"Survive a tribulation"),
	T("immortal_virtue","💖","Immortal Virtue","Divine","karma",800, 1.08,1.08,1.08,1.20,1,0,"Reach 800 karma"),
}

local _byId: {[string]: Title} = {}
for _, t in ipairs(TitleData.TITLES) do _byId[t.id] = t end

function TitleData.Get(id: string): Title?
	return _byId[id]
end

-- Is this title's condition satisfied by the given tracked stats?
function TitleData.IsUnlocked(t: Title, stats: any): boolean
	local v = stats[t.condType] or 0
	return v >= t.condValue
end

return TitleData
