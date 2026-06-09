--!strict
-- ShopData.lua
-- Pillen & Elixiere (mit Spirit Stones kaufbar). Effekt-Typen:
--   exp_instant : sofort EXP = (param × aktuelle Stage-EXP)
--   exp_fill    : füllt aktuelle Stage sofort auf (Durchbruch-Hilfe)
--   buff_exp    : EXP-Multiplikator (mult) für (duration) Sekunden
--   buff_dmg    : Schadens-Multiplikator (mult) für (duration) Sekunden
--   heal        : sofortige Vollheilung
--   age_reduce  : Alter um (param) Jahre verringern (Langlebigkeit)

local ShopData = {}

export type Item = {
	id: string,
	name: string,
	icon: string,
	desc: string,
	price: number,        -- Spirit Stones
	rarity: string,       -- für UI-Farbe
	effect: string,       -- siehe oben
	param: number?,       -- generischer Parameter (EXP-Faktor / Jahre)
	mult: number?,        -- Buff-Multiplikator
	duration: number?,    -- Buff-Dauer in Sekunden
}

ShopData.ITEMS = {
	{ id="qi_pill",        name="Qi-Sammelpille",       icon="🟢", rarity="Common",
	  desc="Sofort EXP gleich 1× der aktuellen Stage.",          price=50,    effect="exp_instant", param=1 },
	{ id="foundation_pill",name="Fundament-Pille",      icon="🔵", rarity="Uncommon",
	  desc="Sofort EXP gleich 5× der aktuellen Stage.",          price=250,   effect="exp_instant", param=5 },
	{ id="nascent_pill",   name="Nascent-Elixier",      icon="🟣", rarity="Rare",
	  desc="Sofort EXP gleich 20× der aktuellen Stage.",         price=1200,  effect="exp_instant", param=20 },
	{ id="breakthrough_pill",name="Durchbruch-Pille",   icon="⚡", rarity="Epic",
	  desc="Füllt die aktuelle Stage sofort komplett auf.",      price=500,   effect="exp_fill" },
	{ id="spirit_concentration",name="Geist-Konzentrat",icon="🌀", rarity="Rare",
	  desc="EXP-Gewinn ×2 für 5 Minuten.",                       price=400,   effect="buff_exp", mult=2.0, duration=300 },
	{ id="heaven_dao_pill",name="Himmels-Dao-Pille",    icon="✨", rarity="Legendary",
	  desc="EXP-Gewinn ×3 für 10 Minuten.",                      price=2000,  effect="buff_exp", mult=3.0, duration=600 },
	{ id="berserk_pill",   name="Berserker-Pille",      icon="🔴", rarity="Uncommon",
	  desc="Schaden ×2 für 3 Minuten.",                          price=300,   effect="buff_dmg", mult=2.0, duration=180 },
	{ id="war_god_pill",   name="Kriegsgott-Pille",     icon="⚔️", rarity="Epic",
	  desc="Schaden ×3 für 4 Minuten.",                          price=1500,  effect="buff_dmg", mult=3.0, duration=240 },
	{ id="healing_pill",   name="Heilpille",            icon="💊", rarity="Common",
	  desc="Heilt sofort vollständig.",                          price=80,    effect="heal" },
	{ id="longevity_pill", name="Langlebigkeits-Pille", icon="🍃", rarity="Epic",
	  desc="Verringert dein Alter um 20 Jahre.",                 price=600,   effect="age_reduce", param=20 },
	{ id="immortal_peach", name="Unsterblicher Pfirsich",icon="🍑", rarity="Divine",
	  desc="Verringert dein Alter um 100 Jahre.",                price=5000,  effect="age_reduce", param=100 },
} :: { Item }

function ShopData.GetItem(id: string): Item?
	for _, it in ipairs(ShopData.ITEMS) do
		if it.id == id then return it end
	end
	return nil
end

return ShopData
