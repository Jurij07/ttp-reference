--!strict
-- NPCData.lua
-- Gegner-Daten, gruppiert nach Realm. Werte stammen aus der Spielreferenz.
-- Aktuell vollständig: Realm 1 & 2. Realm 3-9 sind aus der Referenz
-- (index.html, Section "NPCs") nach dem gleichen Schema zu ergänzen.
--
-- Felder: name, icon, grade, hp, dmg, def, exp, stones, boss, mut (Mutation-%)

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

-- Schlüssel = Realm-ID. Wert = Liste der NPCs dieses Realms.
NPCData.BY_REALM = {
	[1] = {
		{ name = "Qi Wolf",          icon = "🐺", grade = "F", hp = 120, dmg = 8,  def = 3,  exp = 50,  stones = 10, boss = false, mut = 10 },
		{ name = "Spirit Rabbit",    icon = "🐰", grade = "F", hp = 80,  dmg = 5,  def = 2,  exp = 35,  stones = 7,  boss = false, mut = 10 },
		{ name = "Qi Fox",           icon = "🦊", grade = "F", hp = 100, dmg = 10, def = 2,  exp = 55,  stones = 12, boss = false, mut = 12 },
		{ name = "Iron Skin Boar",   icon = "🐗", grade = "F", hp = 200, dmg = 12, def = 8,  exp = 70,  stones = 15, boss = false, mut = 10 },
		{ name = "Poison Qi Snake",  icon = "🐍", grade = "F", hp = 90,  dmg = 9,  def = 2,  exp = 50,  stones = 12, boss = false, mut = 15 },
		{ name = "Cave Qi Rat",      icon = "🐀", grade = "F", hp = 60,  dmg = 6,  def = 1,  exp = 25,  stones = 5,  boss = false, mut = 8 },
		{ name = "Iron Beetle",      icon = "🪲", grade = "F", hp = 150, dmg = 7,  def = 12, exp = 60,  stones = 13, boss = false, mut = 10 },
		{ name = "Storm Sparrow",    icon = "🐦", grade = "F", hp = 70,  dmg = 11, def = 1,  exp = 45,  stones = 10, boss = false, mut = 12 },
		{ name = "Spirit Bear",      icon = "🐻", grade = "E", hp = 300, dmg = 15, def = 6,  exp = 90,  stones = 20, boss = false, mut = 15 },
		{ name = "Realm Guardian Wolf", icon = "👑", grade = "E", hp = 600, dmg = 20, def = 10, exp = 200, stones = 50, boss = true, mut = 30 },
	},
	[2] = {
		{ name = "Fire Tiger",        icon = "🐯", grade = "E", hp = 400,  dmg = 28, def = 12, exp = 180, stones = 40,  boss = false, mut = 12 },
		{ name = "Air Shark",         icon = "🦈", grade = "E", hp = 350,  dmg = 32, def = 8,  exp = 190, stones = 42,  boss = false, mut = 12 },
		{ name = "Qi Lion",           icon = "🦁", grade = "E", hp = 500,  dmg = 30, def = 15, exp = 220, stones = 50,  boss = false, mut = 15 },
		{ name = "Dark Crow",         icon = "🦅", grade = "E", hp = 280,  dmg = 35, def = 5,  exp = 170, stones = 38,  boss = false, mut = 13 },
		{ name = "Iron Shell Turtle", icon = "🐢", grade = "E", hp = 700,  dmg = 18, def = 40, exp = 200, stones = 45,  boss = false, mut = 10 },
		{ name = "Venom Scorpion",    icon = "🦂", grade = "E", hp = 320,  dmg = 30, def = 10, exp = 185, stones = 42,  boss = false, mut = 15 },
		{ name = "Stone Gorilla",     icon = "🦍", grade = "E", hp = 550,  dmg = 35, def = 18, exp = 230, stones = 52,  boss = false, mut = 12 },
		{ name = "Water Serpent",     icon = "🐍", grade = "E", hp = 400,  dmg = 28, def = 8,  exp = 195, stones = 44,  boss = false, mut = 12 },
		{ name = "Thunder Hawk",      icon = "🦅", grade = "D", hp = 450,  dmg = 40, def = 10, exp = 260, stones = 60,  boss = false, mut = 18 },
		{ name = "Foundation Guardian", icon = "👑", grade = "D", hp = 1500, dmg = 50, def = 25, exp = 500, stones = 120, boss = true, mut = 35 },
	},
	-- TODO: Realm 3-9 aus index.html ergänzen (gleiche Struktur).
} :: { [number]: { NPC } }

-- Liste aller Realm-IDs, für die NPC-Daten existieren (aufsteigend sortiert).
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
