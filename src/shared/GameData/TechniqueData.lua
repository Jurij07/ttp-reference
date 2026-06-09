--!strict
-- TechniqueData.lua
-- Signatur-Technik pro Dao Affinity (aktive Kampffähigkeit, Taste Q).
-- Wird vom TechniqueService genutzt: trifft den nächsten Gegner in Reichweite,
-- verursacht (dmgMult × ATK) Schaden, danach (cooldown) Sekunden Abklingzeit.
-- Manche Techniken haben Zusatzeffekte (healFrac = heilt % der MaxHP).

local TechniqueData = {}

export type Technique = {
	dao: string,
	name: string,
	icon: string,
	desc: string,
	dmgMult: number,
	cooldown: number,
	healFrac: number?,  -- optionaler Heileffekt (Anteil MaxHP)
	color: string,
}

-- Schlüssel = Dao-Name (passend zu ProvidenceData.DAO_DATA).
TechniqueData.BY_DAO = {
	Sword   = { dao="Sword",   name="Schwert-Qi-Schnitt", icon="⚔️", dmgMult=3.0, cooldown=6, color="F87171",
	            desc="Ein reiner Schwert-Qi-Hieb. 3× ATK." },
	Fire    = { dao="Fire",    name="Inferno-Ausbruch",   icon="🔥", dmgMult=2.6, cooldown=7, color="FB923C",
	            desc="Verbrennt den Feind in Flammen. 2.6× ATK." },
	Void    = { dao="Void",    name="Leere-Verschlingung", icon="🌀", dmgMult=3.2, cooldown=8, color="A78BFA",
	            desc="Reißt den Feind in die Leere. 3.2× ATK." },
	Life    = { dao="Life",    name="Vitalitäts-Welle",   icon="🌿", dmgMult=1.6, cooldown=8, healFrac=0.35, color="34D399",
	            desc="1.6× ATK Schaden + heilt 35% deiner MaxHP." },
	Thunder = { dao="Thunder", name="Donnerschlag",       icon="⚡", dmgMult=2.8, cooldown=5, color="FBBF24",
	            desc="Schneller Blitzschlag. 2.8× ATK, kurze Abklingzeit." },
	Ice     = { dao="Ice",     name="Frost-Lanze",        icon="❄️", dmgMult=2.4, cooldown=6, color="67E8F9",
	            desc="Durchbohrt mit Eis. 2.4× ATK." },
	Earth   = { dao="Earth",   name="Bergzermalmung",     icon="🏔️", dmgMult=2.5, cooldown=7, color="A3E635",
	            desc="Zermalmt mit der Wucht eines Berges. 2.5× ATK." },
	Space   = { dao="Space",   name="Raum-Riss",          icon="🌌", dmgMult=3.0, cooldown=7, color="818CF8",
	            desc="Zerschneidet den Raum selbst. 3.0× ATK." },
} :: { [string]: Technique }

function TechniqueData.GetForDao(dao: string): Technique?
	return TechniqueData.BY_DAO[dao]
end

return TechniqueData
