--!strict
-- NPCData.lua (generated from index.html)

local NPCData = {}

export type NPC = {
	name: string, icon: string, grade: string,
	hp: number, dmg: number, def: number,
	exp: number, stones: number,
	boss: boolean, mut: number,
}

NPCData.BY_REALM = {
	[1] = {
		{ name="Qi Wolf", icon="🐺", grade="F", hp=120, dmg=8, def=3, exp=50, stones=10, boss=false, mut=10 },
		{ name="Spirit Rabbit", icon="🐰", grade="F", hp=80, dmg=5, def=2, exp=35, stones=7, boss=false, mut=10 },
		{ name="Qi Fox", icon="🦊", grade="F", hp=100, dmg=10, def=2, exp=55, stones=12, boss=false, mut=12 },
		{ name="Iron Skin Boar", icon="🐗", grade="F", hp=200, dmg=12, def=8, exp=70, stones=15, boss=false, mut=10 },
		{ name="Poison Qi Snake", icon="🐍", grade="F", hp=90, dmg=9, def=2, exp=50, stones=12, boss=false, mut=15 },
		{ name="Cave Qi Rat", icon="🐀", grade="F", hp=60, dmg=6, def=1, exp=25, stones=5, boss=false, mut=8 },
		{ name="Iron Beetle", icon="🪲", grade="F", hp=150, dmg=7, def=12, exp=60, stones=13, boss=false, mut=10 },
		{ name="Storm Sparrow", icon="🐦", grade="F", hp=70, dmg=11, def=1, exp=45, stones=10, boss=false, mut=12 },
		{ name="Spirit Bear", icon="🐻", grade="E", hp=300, dmg=15, def=6, exp=90, stones=20, boss=false, mut=15 },
		{ name="Realm Guardian Wolf 👑", icon="👑", grade="E", hp=600, dmg=20, def=10, exp=200, stones=50, boss=true, mut=30 },
	},
	[2] = {
		{ name="Fire Tiger", icon="🐯", grade="E", hp=400, dmg=28, def=12, exp=180, stones=40, boss=false, mut=12 },
		{ name="Air Shark", icon="🦈", grade="E", hp=350, dmg=32, def=8, exp=190, stones=42, boss=false, mut=12 },
		{ name="Qi Lion", icon="🦁", grade="E", hp=500, dmg=30, def=15, exp=220, stones=50, boss=false, mut=15 },
		{ name="Dark Crow", icon="🦅", grade="E", hp=280, dmg=35, def=5, exp=170, stones=38, boss=false, mut=13 },
		{ name="Iron Shell Turtle", icon="🐢", grade="E", hp=700, dmg=18, def=40, exp=200, stones=45, boss=false, mut=10 },
		{ name="Venom Scorpion", icon="🦂", grade="E", hp=320, dmg=30, def=10, exp=185, stones=42, boss=false, mut=15 },
		{ name="Stone Gorilla", icon="🦍", grade="E", hp=550, dmg=35, def=18, exp=230, stones=52, boss=false, mut=12 },
		{ name="Water Serpent", icon="🐍", grade="E", hp=400, dmg=28, def=8, exp=195, stones=44, boss=false, mut=12 },
		{ name="Thunder Hawk", icon="🦅", grade="D", hp=450, dmg=40, def=10, exp=260, stones=60, boss=false, mut=18 },
		{ name="Foundation Guardian 👑", icon="👑", grade="D", hp=1500, dmg=50, def=25, exp=500, stones=120, boss=true, mut=35 },
	},
	[3] = {
		{ name="Lesser Earth Dragon", icon="🐲", grade="D", hp=800, dmg=60, def=30, exp=350, stones=80, boss=false, mut=15 },
		{ name="Qi Demon", icon="😈", grade="D", hp=700, dmg=70, def=20, exp=380, stones=85, boss=false, mut=15 },
		{ name="Infant Phoenix", icon="🦅", grade="D", hp=600, dmg=75, def=15, exp=400, stones=90, boss=false, mut=15 },
		{ name="Undead Cultivator", icon="💀", grade="D", hp=650, dmg=65, def=25, exp=360, stones=82, boss=false, mut=18 },
		{ name="Spirit Stone Golem", icon="🗿", grade="D", hp=1200, dmg=50, def=60, exp=400, stones=90, boss=false, mut=10 },
		{ name="Blood Qi Vampire", icon="🧛", grade="D", hp=700, dmg=68, def=20, exp=370, stones=84, boss=false, mut=15 },
		{ name="Sky Ram", icon="🐏", grade="D", hp=750, dmg=65, def=28, exp=355, stones=80, boss=false, mut=12 },
		{ name="Void Jellyfish", icon="🪼", grade="D", hp=550, dmg=80, def=10, exp=390, stones=88, boss=false, mut=15 },
		{ name="Corrupted Elder", icon="👴", grade="C", hp=1000, dmg=85, def=35, exp=500, stones=110, boss=false, mut=25 },
		{ name="Golden Core Sovereign 👑", icon="👑", grade="C", hp=3000, dmg=100, def=50, exp=1000, stones=250, boss=true, mut=40 },
	},
	[4] = {
		{ name="Soul Wraith", icon="👻", grade="C", hp=1200, dmg=120, def=40, exp=600, stones=140, boss=false, mut=15 },
		{ name="Stone Titan", icon="🗿", grade="C", hp=2500, dmg=90, def=80, exp=650, stones=150, boss=false, mut=12 },
		{ name="Void Wyvern", icon="🐉", grade="C", hp=1500, dmg=130, def=45, exp=700, stones=160, boss=false, mut=18 },
		{ name="Ancient Specter", icon="👤", grade="C", hp=1000, dmg=140, def=30, exp=680, stones=155, boss=false, mut=18 },
		{ name="Qi Chimera", icon="🔀", grade="C", hp=1800, dmg=110, def=55, exp=720, stones=165, boss=false, mut=20 },
		{ name="Soul Banshee", icon="😱", grade="C", hp=1100, dmg=135, def=35, exp=690, stones=158, boss=false, mut=15 },
		{ name="Qi Behemoth", icon="🦏", grade="B", hp=3500, dmg=100, def=90, exp=800, stones=180, boss=false, mut=15 },
		{ name="Nascent Soul Lich", icon="💀", grade="B", hp=2000, dmg=150, def=50, exp=850, stones=190, boss=false, mut=20 },
		{ name="Dark Dao Elder", icon="🧙", grade="B", hp=2200, dmg=160, def=60, exp=900, stones=200, boss=false, mut=25 },
		{ name="Nascent Soul Demon King 👑", icon="👑", grade="B", hp=8000, dmg=200, def=80, exp=2000, stones=500, boss=true, mut=50 },
	},
	[5] = {
		{ name="Lesser Deity", icon="😇", grade="B", hp=3000, dmg=220, def=90, exp=1200, stones=280, boss=false, mut=18 },
		{ name="Death Incarnate", icon="💀", grade="B", hp=2500, dmg=250, def=70, exp=1300, stones=300, boss=false, mut=18 },
		{ name="Void Sovereign", icon="🌑", grade="B", hp=3500, dmg=230, def=85, exp=1250, stones=290, boss=false, mut=20 },
		{ name="Fallen Immortal", icon="🌟", grade="A", hp=5000, dmg=280, def=100, exp=1500, stones=350, boss=false, mut=25 },
		{ name="Chaos Entity", icon="🌀", grade="A", hp=4000, dmg=300, def=80, exp=1600, stones=370, boss=false, mut=25 },
		{ name="Dao Avatar", icon="☯️", grade="A", hp=6000, dmg=260, def=110, exp=1800, stones=400, boss=false, mut=25 },
		{ name="Ancient Heavenly Beast", icon="🐉", grade="A", hp=8000, dmg=240, def=130, exp=2000, stones=450, boss=false, mut=20 },
		{ name="Nightmare Fiend", icon="😱", grade="A", hp=3500, dmg=320, def=70, exp=1700, stones=380, boss=false, mut=30 },
		{ name="Immortal Stage Elder", icon="🧙", grade="S", hp=10000, dmg=350, def=120, exp=3000, stones=700, boss=false, mut=35 },
		{ name="Creation Dao Sovereign 👑", icon="👑", grade="S", hp=25000, dmg=500, def=200, exp=6000, stones=1500, boss=true, mut=60 },
	},
	[6] = {
		{ name="Celestial Knight", icon="⚔️", grade="A", hp=5000, dmg=350, def=120, exp=2000, stones=500, boss=false, mut=20 },
		{ name="Divine Godkin", icon="😇", grade="A", hp=6000, dmg=320, def=140, exp=2200, stones=550, boss=false, mut=20 },
		{ name="Archfiend", icon="👿", grade="A", hp=5500, dmg=380, def=100, exp=2100, stones=520, boss=false, mut=25 },
		{ name="Dao Titan", icon="🗿", grade="A", hp=10000, dmg=280, def=200, exp=2300, stones=580, boss=false, mut=15 },
		{ name="Immortal Specter", icon="👤", grade="A", hp=4500, dmg=420, def=90, exp=2200, stones=540, boss=false, mut=25 },
		{ name="Reborn Phoenix", icon="🦅", grade="A", hp=6500, dmg=360, def=110, exp=2400, stones=600, boss=false, mut=20 },
		{ name="Demon Ancestor", icon="😈", grade="S", hp=8000, dmg=400, def=130, exp=2600, stones=650, boss=false, mut=25 },
		{ name="Celestial Golem", icon="🗿", grade="S", hp=15000, dmg=300, def=250, exp=2700, stones=680, boss=false, mut=15 },
		{ name="Heaven Sealing Elder", icon="🧙", grade="S", hp=12000, dmg=450, def=160, exp=3500, stones=800, boss=false, mut=35 },
		{ name="Body Integration Sovereign 👑", icon="👑", grade="SS", hp=50000, dmg=600, def=300, exp=8000, stones=2000, boss=true, mut=60 },
	},
	[7] = {
		{ name="Heaven Thunder Beast", icon="⚡", grade="S", hp=8000, dmg=500, def=180, exp=3000, stones=750, boss=false, mut=20 },
		{ name="True Immortal", icon="🌟", grade="S", hp=10000, dmg=550, def=200, exp=3500, stones=850, boss=false, mut=22 },
		{ name="Chaos Wraith", icon="🌀", grade="S", hp=7000, dmg=600, def=150, exp=3200, stones=800, boss=false, mut=28 },
		{ name="Dao God Fragment", icon="☯️", grade="S", hp=12000, dmg=520, def=220, exp=3800, stones=900, boss=false, mut=20 },
		{ name="True Dragon", icon="🐉", grade="S", hp=20000, dmg=480, def=260, exp=4000, stones=950, boss=false, mut=18 },
		{ name="Fallen God", icon="💀", grade="S", hp=9000, dmg=580, def=170, exp=3600, stones=880, boss=false, mut=25 },
		{ name="Tribulation Demon", icon="⚡", grade="S", hp=11000, dmg=560, def=190, exp=3900, stones=920, boss=false, mut=25 },
		{ name="Primordial Ancient", icon="👴", grade="SS", hp=25000, dmg=520, def=240, exp=4500, stones=1000, boss=false, mut=30 },
		{ name="Tribulation Transcended", icon="🧙", grade="SS", hp=30000, dmg=620, def=280, exp=6000, stones=1400, boss=false, mut=40 },
		{ name="Heaven's Wrath 👑", icon="👑", grade="SSS", hp=100000, dmg=800, def=400, exp=15000, stones=4000, boss=true, mut=70 },
	},
	[8] = {
		{ name="Celestial Emperor", icon="👑", grade="SS", hp=20000, dmg=700, def=350, exp=6000, stones=1500, boss=false, mut=25 },
		{ name="True Dao Avatar", icon="☯️", grade="SS", hp=25000, dmg=750, def=320, exp=7000, stones=1700, boss=false, mut=22 },
		{ name="Void Emperor", icon="🌑", grade="SS", hp=18000, dmg=800, def=280, exp=6500, stones=1600, boss=false, mut=28 },
		{ name="Undying Phoenix", icon="🦅", grade="SS", hp=22000, dmg=720, def=300, exp=6800, stones=1650, boss=false, mut=22 },
		{ name="World Titan", icon="🗿", grade="SS", hp=50000, dmg=600, def=500, exp=7500, stones=1800, boss=false, mut=15 },
		{ name="Demon God", icon="😈", grade="SS", hp=28000, dmg=780, def=310, exp=7200, stones=1750, boss=false, mut=30 },
		{ name="Chaos God", icon="🌀", grade="SS", hp=23000, dmg=820, def=290, exp=7000, stones=1700, boss=false, mut=32 },
		{ name="Ancient God Fragment", icon="👁️", grade="SSS", hp=40000, dmg=850, def=360, exp=9000, stones=2200, boss=false, mut=35 },
		{ name="Mahayana Ancestor", icon="🧙", grade="SSS", hp=60000, dmg=900, def=400, exp=12000, stones=3000, boss=false, mut=45 },
		{ name="Creation Will 👑", icon="✨", grade="SSS", hp=200000, dmg=1200, def=600, exp=25000, stones=6000, boss=true, mut=80 },
	},
	[9] = {
		{ name="Immortal Being", icon="🌟", grade="SSS", hp=50000, dmg=1000, def=500, exp=10000, stones=2500, boss=false, mut=30 },
		{ name="Lesser God", icon="😇", grade="SSS", hp=70000, dmg=1100, def=550, exp=12000, stones=3000, boss=false, mut=28 },
		{ name="Chaos Deity", icon="🌀", grade="SSS", hp=60000, dmg=1150, def=520, exp=11000, stones=2800, boss=false, mut=35 },
		{ name="True Dao God", icon="☯️", grade="SSS", hp=80000, dmg=1050, def=560, exp=13000, stones=3200, boss=false, mut=25 },
		{ name="Primordial Dragon God", icon="🐉", grade="SSS", hp=100000, dmg=1000, def=600, exp=15000, stones=3500, boss=false, mut=20 },
		{ name="Fallen Celestial God", icon="💀", grade="SSS", hp=75000, dmg=1100, def=530, exp=14000, stones=3300, boss=false, mut=30 },
		{ name="Universe Titan", icon="🗿", grade="SSS", hp=200000, dmg=900, def=700, exp=18000, stones=4000, boss=false, mut=15 },
		{ name="Han Jue Avatar", icon="📔", grade="MYTHIC", hp=500000, dmg=1500, def=800, exp=50000, stones=10000, boss=false, mut=90 },
		{ name="Creation Fragment", icon="✨", grade="MYTHIC", hp=300000, dmg=2000, def=900, exp=40000, stones=8000, boss=false, mut=85 },
		{ name="The Simulation's Overseer 👑", icon="👁️", grade="BEYOND", hp=10000000, dmg=9999, def=9999, exp=100000, stones=25000, boss=true, mut=100 },
	},
}

function NPCData.GetRealmNPCs(realmId: number): {NPC}?
	return NPCData.BY_REALM[realmId]
end

function NPCData.GetImplementedRealms(): {number}
	local out = {}
	for k in pairs(NPCData.BY_REALM) do table.insert(out, k) end
	table.sort(out)
	return out
end

return NPCData
