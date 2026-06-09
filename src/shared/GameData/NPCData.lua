--!strict
-- NPCData.lua
-- Vollständige Gegner-Daten für Realm 1–9, nach Realm-Stärke skaliert.
-- Realm 10+ nutzen dieselbe Struktur; vorerst leer (nur Boss-Symbole).

local NPCData = {}

export type NPC = {
	name: string,
	icon: string,
	grade: string,
	hp: number,
	dmg: number,
	def: number,
	exp: number,
	stones: number,
	boss: boolean,
	mut: number,
}

-- ── Realm-Stat-Referenz (Spieler Stage 1) ─────────────────
-- R1: HP=120 DMG=12 DEF=3
-- R2: HP=192 DMG=18 DEF=4
-- R3: HP=307 DMG=27 DEF=6
-- R4: HP=491 DMG=41 DEF=8
-- R5: HP=787 DMG=61 DEF=12
-- R6: HP=1260 DMG=91 DEF=16
-- R7: HP=2015 DMG=137 DEF=23
-- R8: HP=3224 DMG=205 DEF=32
-- R9: HP=5160 DMG=307 DEF=44

NPCData.BY_REALM = {
	-- ══ REALM 1 — QI REFINEMENT ════════════════════════════
	[1] = {
		{ name="Qi Wolf",            icon="🐺", grade="F", hp=120,  dmg=8,  def=3,  exp=50,   stones=10, boss=false, mut=10 },
		{ name="Spirit Rabbit",      icon="🐰", grade="F", hp=80,   dmg=5,  def=2,  exp=35,   stones=7,  boss=false, mut=10 },
		{ name="Qi Fox",             icon="🦊", grade="F", hp=100,  dmg=10, def=2,  exp=55,   stones=12, boss=false, mut=12 },
		{ name="Iron Skin Boar",     icon="🐗", grade="F", hp=200,  dmg=12, def=8,  exp=70,   stones=15, boss=false, mut=10 },
		{ name="Poison Qi Snake",    icon="🐍", grade="F", hp=90,   dmg=9,  def=2,  exp=50,   stones=12, boss=false, mut=15 },
		{ name="Cave Qi Rat",        icon="🐀", grade="F", hp=60,   dmg=6,  def=1,  exp=25,   stones=5,  boss=false, mut=8  },
		{ name="Iron Beetle",        icon="🪲", grade="F", hp=150,  dmg=7,  def=12, exp=60,   stones=13, boss=false, mut=10 },
		{ name="Storm Sparrow",      icon="🐦", grade="F", hp=70,   dmg=11, def=1,  exp=45,   stones=10, boss=false, mut=12 },
		{ name="Spirit Bear",        icon="🐻", grade="E", hp=300,  dmg=15, def=6,  exp=90,   stones=20, boss=false, mut=15 },
		{ name="Realm Guardian Wolf",icon="👑", grade="E", hp=600,  dmg=20, def=10, exp=200,  stones=50, boss=true,  mut=30 },
	},
	-- ══ REALM 2 — FOUNDATION ESTABLISHMENT ═════════════════
	[2] = {
		{ name="Fire Tiger",         icon="🐯", grade="E", hp=400,  dmg=28, def=12, exp=180,  stones=40,  boss=false, mut=12 },
		{ name="Air Shark",          icon="🦈", grade="E", hp=350,  dmg=32, def=8,  exp=190,  stones=42,  boss=false, mut=12 },
		{ name="Qi Lion",            icon="🦁", grade="E", hp=500,  dmg=30, def=15, exp=220,  stones=50,  boss=false, mut=15 },
		{ name="Dark Crow",          icon="🦅", grade="E", hp=280,  dmg=35, def=5,  exp=170,  stones=38,  boss=false, mut=13 },
		{ name="Iron Shell Turtle",  icon="🐢", grade="E", hp=700,  dmg=18, def=40, exp=200,  stones=45,  boss=false, mut=10 },
		{ name="Venom Scorpion",     icon="🦂", grade="E", hp=320,  dmg=30, def=10, exp=185,  stones=42,  boss=false, mut=15 },
		{ name="Stone Gorilla",      icon="🦍", grade="E", hp=550,  dmg=35, def=18, exp=230,  stones=52,  boss=false, mut=12 },
		{ name="Water Serpent",      icon="🐍", grade="E", hp=400,  dmg=28, def=8,  exp=195,  stones=44,  boss=false, mut=12 },
		{ name="Thunder Hawk",       icon="🦅", grade="D", hp=450,  dmg=40, def=10, exp=260,  stones=60,  boss=false, mut=18 },
		{ name="Foundation Guardian",icon="👑", grade="D", hp=1500, dmg=50, def=25, exp=500,  stones=120, boss=true,  mut=35 },
	},
	-- ══ REALM 3 — GOLDEN CORE ══════════════════════════════
	[3] = {
		{ name="Flame Wolf",         icon="🔥", grade="D", hp=200,  dmg=20, def=5,  exp=350,  stones=80,  boss=false, mut=12 },
		{ name="Golden Eagle",       icon="🦅", grade="D", hp=160,  dmg=25, def=3,  exp=320,  stones=72,  boss=false, mut=13 },
		{ name="Jade Serpent",       icon="🐍", grade="D", hp=280,  dmg=18, def=8,  exp=380,  stones=88,  boss=false, mut=14 },
		{ name="Crimson Leopard",    icon="🐆", grade="D", hp=240,  dmg=28, def=6,  exp=400,  stones=90,  boss=false, mut=12 },
		{ name="Rock Golem",         icon="🪨", grade="D", hp=550,  dmg=16, def=22, exp=450,  stones=100, boss=false, mut=10 },
		{ name="Qi Crane",           icon="🦢", grade="D", hp=190,  dmg=22, def=4,  exp=340,  stones=78,  boss=false, mut=12 },
		{ name="Lava Spider",        icon="🕷️", grade="D", hp=340,  dmg=21, def=10, exp=420,  stones=95,  boss=false, mut=14 },
		{ name="Sky Horse",          icon="🐴", grade="D", hp=400,  dmg=26, def=7,  exp=440,  stones=98,  boss=false, mut=12 },
		{ name="Crystal Deer",       icon="🦌", grade="C", hp=500,  dmg=30, def=12, exp=520,  stones=120, boss=false, mut=16 },
		{ name="Golden Core Guardian",icon="👑",grade="C", hp=2200, dmg=55, def=28, exp=1400, stones=350, boss=true,  mut=35 },
	},
	-- ══ REALM 4 — NASCENT SOUL ═════════════════════════════
	[4] = {
		{ name="Ancient Wolf",       icon="🐺", grade="C", hp=350,  dmg=32, def=8,  exp=700,  stones=165, boss=false, mut=13 },
		{ name="Spectral Tiger",     icon="🐅", grade="C", hp=300,  dmg=38, def=6,  exp=750,  stones=175, boss=false, mut=14 },
		{ name="Void Bat",           icon="🦇", grade="C", hp=270,  dmg=36, def=5,  exp=720,  stones=168, boss=false, mut=16 },
		{ name="Iron Fist Ape",      icon="🦍", grade="C", hp=600,  dmg=30, def=20, exp=780,  stones=182, boss=false, mut=12 },
		{ name="Blood Phoenix",      icon="🔥", grade="C", hp=430,  dmg=42, def=10, exp=850,  stones=198, boss=false, mut=18 },
		{ name="Jade Turtle",        icon="🐢", grade="C", hp=900,  dmg=22, def=45, exp=820,  stones=190, boss=false, mut=10 },
		{ name="Thunder Condor",     icon="⚡", grade="C", hp=380,  dmg=44, def=8,  exp=880,  stones=205, boss=false, mut=17 },
		{ name="Dark Panther",       icon="🐈‍⬛", grade="C", hp=450, dmg=40, def=12, exp=830,  stones=193, boss=false, mut=15 },
		{ name="Soul Serpent",       icon="🐍", grade="B", hp=650,  dmg=48, def=16, exp=950,  stones=220, boss=false, mut=18 },
		{ name="Nascent Guardian",   icon="👑", grade="B", hp=3800, dmg=75, def=40, exp=2500, stones=600, boss=true,  mut=38 },
	},
	-- ══ REALM 5 — SOUL FORMATION ═══════════════════════════
	[5] = {
		{ name="Chaos Boar",         icon="🐗", grade="B", hp=600,  dmg=50, def=13, exp=1400,  stones=330, boss=false, mut=13 },
		{ name="Demon Fox",          icon="🦊", grade="B", hp=500,  dmg=58, def=10, exp=1500,  stones=350, boss=false, mut=16 },
		{ name="Soul Wraith",        icon="👻", grade="B", hp=450,  dmg=55, def=8,  exp=1450,  stones=340, boss=false, mut=18 },
		{ name="Crimson Dragon Whelp",icon="🐉",grade="B", hp=800,  dmg=62, def=18, exp=1650,  stones=385, boss=false, mut=20 },
		{ name="Void Shark",         icon="🦈", grade="B", hp=700,  dmg=55, def=15, exp=1550,  stones=362, boss=false, mut=15 },
		{ name="Bone Golem",         icon="💀", grade="B", hp=1200, dmg=40, def=50, exp=1700,  stones=395, boss=false, mut=10 },
		{ name="Infernal Hawk",      icon="🔥", grade="B", hp=560,  dmg=65, def=10, exp=1600,  stones=373, boss=false, mut=18 },
		{ name="Shadow Wolf",        icon="🐺", grade="B", hp=620,  dmg=58, def=14, exp=1520,  stones=355, boss=false, mut=15 },
		{ name="Ancient Carp",       icon="🐟", grade="A", hp=900,  dmg=70, def=20, exp=1800,  stones=420, boss=false, mut=20 },
		{ name="Soul Formation Guardian",icon="👑",grade="A", hp=6500,dmg=110,def=60,exp=4200, stones=1000,boss=true,  mut=40 },
	},
	-- ══ REALM 6 — VOID AMALGAMATION ════════════════════════
	[6] = {
		{ name="Void Phantom",       icon="👻", grade="A", hp=900,  dmg=75, def=15, exp=2800,  stones=650, boss=false, mut=16 },
		{ name="Amalgamated Beast",  icon="🦁", grade="A", hp=1100, dmg=80, def=20, exp=3000,  stones=700, boss=false, mut=14 },
		{ name="Chaos Tiger",        icon="🐅", grade="A", hp=950,  dmg=88, def=16, exp=3100,  stones=720, boss=false, mut=16 },
		{ name="Rift Serpent",       icon="🐍", grade="A", hp=800,  dmg=82, def=12, exp=2900,  stones=675, boss=false, mut=18 },
		{ name="Abyssal Squid",      icon="🦑", grade="A", hp=1300, dmg=70, def=28, exp=3200,  stones=745, boss=false, mut=14 },
		{ name="Spirit Giant",       icon="👾", grade="A", hp=1800, dmg=65, def=42, exp=3400,  stones=790, boss=false, mut=12 },
		{ name="Void Drake",         icon="🐲", grade="A", hp=1200, dmg=92, def=22, exp=3300,  stones=768, boss=false, mut=20 },
		{ name="Ancient Demon Bat",  icon="🦇", grade="A", hp=850,  dmg=86, def=14, exp=3050,  stones=710, boss=false, mut=18 },
		{ name="Void Leviathan",     icon="🌊", grade="S", hp=1600, dmg=98, def=30, exp=3600,  stones=840, boss=false, mut=22 },
		{ name="Void Guardian",      icon="👑", grade="S", hp=12000,dmg=160,def=90, exp=7500,  stones=1800,boss=true,  mut=45 },
	},
	-- ══ REALM 7 — BODY INTEGRATION ═════════════════════════
	[7] = {
		{ name="Demon Soldier",      icon="👹", grade="S",  hp=1500, dmg=115,def=25, exp=5500,  stones=1280, boss=false, mut=14 },
		{ name="Ancient Demon Ape",  icon="🦍", grade="S",  hp=2000, dmg=108,def=38, exp=5800,  stones=1350, boss=false, mut=13 },
		{ name="Fire Demon Knight",  icon="🔥", grade="S",  hp=1700, dmg=130,def=28, exp=6000,  stones=1400, boss=false, mut=16 },
		{ name="Ice Demon Warrior",  icon="❄️", grade="S",  hp=1600, dmg=120,def=32, exp=5700,  stones=1330, boss=false, mut=15 },
		{ name="Thunder Demon Guard",icon="⚡", grade="S",  hp=1550, dmg=135,def=24, exp=5900,  stones=1375, boss=false, mut=17 },
		{ name="Dark Spirit Marshal",icon="🌑", grade="S",  hp=1800, dmg=125,def=30, exp=5850,  stones=1365, boss=false, mut=16 },
		{ name="Blood Demon General",icon="🩸", grade="S",  hp=1650, dmg=140,def=22, exp=6100,  stones=1420, boss=false, mut=18 },
		{ name="Ancient Ox Demon",   icon="🐃", grade="S",  hp=2500, dmg=100,def=55, exp=6200,  stones=1445, boss=false, mut=12 },
		{ name="Sky Demon Drake",    icon="🐲", grade="SS", hp=2200, dmg=148,def=35, exp=6500,  stones=1515, boss=false, mut=22 },
		{ name="Body Integration Guardian",icon="👑",grade="SS",hp=20000,dmg=240,def=130,exp=13000,stones=3000,boss=true,mut=45 },
	},
	-- ══ REALM 8 — TRIBULATION TRANSCENDENCE ════════════════
	[8] = {
		{ name="Tribulation Wolf",   icon="⚡", grade="SS", hp=2500, dmg=180,def=35, exp=11000, stones=2550, boss=false, mut=15 },
		{ name="Heaven Dragon Whelp",icon="🐉", grade="SS", hp=3000, dmg=190,def=40, exp=11500, stones=2675, boss=false, mut=18 },
		{ name="Cloud Serpent",      icon="☁️", grade="SS", hp=2200, dmg=175,def=30, exp=10800, stones=2520, boss=false, mut=16 },
		{ name="Storm Eagle King",   icon="🦅", grade="SS", hp=2400, dmg=200,def=28, exp=11800, stones=2745, boss=false, mut=18 },
		{ name="Heaven Tiger",       icon="🐅", grade="SS", hp=2800, dmg=195,def=38, exp=11600, stones=2700, boss=false, mut=16 },
		{ name="Celestial Bear",     icon="🐻", grade="SS", hp=4000, dmg=160,def=70, exp=12000, stones=2790, boss=false, mut=12 },
		{ name="Lightning Phoenix",  icon="🔥", grade="SS", hp=2600, dmg=210,def=32, exp=12200, stones=2840, boss=false, mut=20 },
		{ name="Jade Dragon",        icon="🐲", grade="SSS",hp=3500, dmg=215,def=45, exp=12800, stones=2980, boss=false, mut=22 },
		{ name="Thunder Qilin",      icon="⚡", grade="SSS",hp=3200, dmg=220,def=42, exp=13000, stones=3025, boss=false, mut=22 },
		{ name="Tribulation Guardian",icon="👑",grade="SSS",hp=35000,dmg=360,def=200,exp=25000, stones=6000, boss=true,  mut=50 },
	},
	-- ══ REALM 9 — MAHAYANA ═════════════════════════════════
	[9] = {
		{ name="Spirit King Wolf",   icon="🐺", grade="SSS",hp=4000, dmg=270,def=50, exp=22000, stones=5100, boss=false, mut=16 },
		{ name="Immortal Serpent",   icon="🐍", grade="SSS",hp=3500, dmg=280,def=45, exp=22500, stones=5250, boss=false, mut=17 },
		{ name="Void Spirit King",   icon="👻", grade="SSS",hp=3200, dmg=290,def=42, exp=23000, stones=5350, boss=false, mut=18 },
		{ name="Ancient Soul Dragon",icon="🐉", grade="SSS",hp=5000, dmg=295,def=55, exp=24000, stones=5600, boss=false, mut=20 },
		{ name="Mahayana Tiger King",icon="🐅", grade="SSS",hp=4500, dmg=300,def=52, exp=24500, stones=5700, boss=false, mut=20 },
		{ name="Spirit Phoenix",     icon="🔥", grade="SSS",hp=3800, dmg=305,def=48, exp=23500, stones=5475, boss=false, mut=20 },
		{ name="Celestial Lion",     icon="🦁", grade="SSS",hp=4200, dmg=308,def=50, exp=24000, stones=5600, boss=false, mut=20 },
		{ name="Ancient Qilin",      icon="⚡", grade="SSS",hp=4800, dmg=310,def=55, exp=25000, stones=5825, boss=false, mut=22 },
		{ name="Primordial Bear King",icon="🐻",grade="SSS+",hp=6000, dmg=315,def=62, exp=26000, stones=6050, boss=false, mut=25 },
		{ name="Mahayana Guardian",  icon="👑", grade="SSS+",hp=60000,dmg=500,def=320,exp=50000, stones=12000,boss=true,  mut=55 },
	},
} :: { [number]: { NPC } }

function NPCData.GetImplementedRealms(): { number }
	local ids = {}
	for realmId in pairs(NPCData.BY_REALM) do
		table.insert(ids, realmId)
	end
	table.sort(ids)
	return ids
end

function NPCData.GetRealmNPCs(realmId: number): { NPC }?
	return NPCData.BY_REALM[realmId]
end

return NPCData
