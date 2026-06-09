--!strict
-- QuestData.lua
-- Fortschritts-Quests. Typen:
--   kills     : besiege (target) Gegner insgesamt
--   boss      : besiege (target) Realm-Wächter (Bosse)
--   realm     : erreiche Realm-ID (target)
--   seclusion : schließe (target) Klausuren ab
-- Belohnung: stones (Spirit Stones) und/oder rewardItem (Pillen-ID) und/oder
--   expFactor (EXP = expFactor × aktuelle Stage-EXP).

local QuestData = {}

export type Quest = {
	id: string,
	name: string,
	desc: string,
	qtype: string,
	target: number,
	stones: number,
	expFactor: number?,
	rewardItem: string?,
}

-- Reihenfolge = Anzeige-Reihenfolge im Quest-Log.
QuestData.QUESTS = {
	{ id="q_first_blood", name="Erster Kampf",     qtype="kills",     target=1,
	  desc="Besiege deinen ersten Gegner.",                stones=50,   expFactor=1 },
	{ id="q_hunter",      name="Jäger",            qtype="kills",     target=25,
	  desc="Besiege 25 Gegner.",                           stones=200,  expFactor=2 },
	{ id="q_slayer",      name="Schlächter",       qtype="kills",     target=100,
	  desc="Besiege 100 Gegner.",                          stones=800,  expFactor=3 },
	{ id="q_butcher",     name="Massaker",         qtype="kills",     target=500,
	  desc="Besiege 500 Gegner.",                          stones=4000, expFactor=4 },
	{ id="q_first_boss",  name="Wächter-Töter",    qtype="boss",      target=1,
	  desc="Besiege deinen ersten Realm-Wächter.",         stones=500,  rewardItem="breakthrough_pill" },
	{ id="q_boss_hunter", name="Wächter-Jäger",    qtype="boss",      target=5,
	  desc="Besiege 5 Realm-Wächter.",                     stones=3000, rewardItem="nascent_pill" },
	{ id="q_foundation",  name="Fundament legen",  qtype="realm",     target=2,
	  desc="Erreiche das Foundation-Establishment-Realm.", stones=300,  expFactor=1 },
	{ id="q_golden_core", name="Goldener Kern",    qtype="realm",     target=3,
	  desc="Erreiche das Golden-Core-Realm.",              stones=1000, rewardItem="spirit_concentration" },
	{ id="q_nascent",     name="Aufstrebende Seele",qtype="realm",    target=4,
	  desc="Erreiche das Nascent-Soul-Realm.",             stones=2500 },
	{ id="q_mahayana",    name="Mahayana",         qtype="realm",     target=9,
	  desc="Erreiche das Mahayana-Realm.",                 stones=50000, rewardItem="immortal_peach" },
	{ id="q_first_secl",  name="Erste Klausur",    qtype="seclusion", target=1,
	  desc="Schließe eine Klausur (geschlossene Kultivierung) ab.", stones=150, rewardItem="qi_pill" },
	{ id="q_recluse",     name="Einsiedler",       qtype="seclusion", target=10,
	  desc="Schließe 10 Klausuren ab.",                    stones=2000, rewardItem="spirit_concentration" },
} :: { Quest }

function QuestData.GetQuest(id: string): Quest?
	for _, q in ipairs(QuestData.QUESTS) do
		if q.id == id then return q end
	end
	return nil
end

return QuestData
