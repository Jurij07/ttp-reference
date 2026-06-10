--!strict
-- StatusEffectData.lua (from index.html — 14 status effects)
-- Real-time adaptation: "turns" become seconds; per-turn → per-tick (1s).

local StatusEffectData = {}

export type StatusEffect = {
	id: string,
	name: string,
	kind: string,        -- "BUFF" | "DEBUFF"
	maxStacks: number,
	desc: string,
	duration: number,    -- seconds (adapted from turns)
}

StatusEffectData.EFFECTS = {
	-- Debuffs
	{ id="stun",        name="Stun",         kind="DEBUFF", maxStacks=1, duration=1.5, desc="Ziel kann 1 Runde nicht handeln. Kein Ausweichen/Angriff." },
	{ id="burn",        name="Burn",         kind="DEBUFF", maxStacks=3, duration=4,   desc="4% max HP Feuerschaden pro Tick. Bis zu 3 Stacks." },
	{ id="freeze",      name="Freeze",       kind="DEBUFF", maxStacks=1, duration=3,   desc="−30% Ausweichchance. Bewegung eingeschränkt." },
	{ id="poison",      name="Poison",       kind="DEBUFF", maxStacks=5, duration=5,   desc="3% HP Schaden pro Tick, ignoriert Defense. Bis zu 5 Stacks." },
	{ id="bleed",       name="Bleed",        kind="DEBUFF", maxStacks=3, duration=4,   desc="2.5% HP/Tick + Ziel erleidet +20% Schaden." },
	{ id="weakened",    name="Weakened",     kind="DEBUFF", maxStacks=1, duration=3,   desc="−25% Ziel-Defense für 2 Runden." },
	{ id="silence",     name="Silence",      kind="DEBUFF", maxStacks=1, duration=2,   desc="Kann 1 Runde keine Techniken nutzen." },
	-- Buffs
	{ id="empowered",   name="Empowered",    kind="BUFF",   maxStacks=1, duration=4,   desc="+50% Schaden für 2 Runden." },
	{ id="shielded",    name="Shielded",     kind="BUFF",   maxStacks=1, duration=4,   desc="Nächster Treffer −50% Schaden." },
	{ id="haste",       name="Haste",        kind="BUFF",   maxStacks=1, duration=4,   desc="+40% Ausweichen für 2 Runden." },
	{ id="regenerating",name="Regenerating", kind="BUFF",   maxStacks=1, duration=5,   desc="+8% max HP Heilung pro Tick." },
	{ id="qi_surge",    name="Qi Surge",     kind="BUFF",   maxStacks=1, duration=5,   desc="−50% Qi-Kosten für alle Techniken." },
	{ id="dao_insight", name="Dao Insight",  kind="BUFF",   maxStacks=1, duration=6,   desc="+30% Crit, ×2.5 Crit-Schaden für 3 Runden." },
	{ id="charged",     name="Charged",      kind="BUFF",   maxStacks=1, duration=4,   desc="Nächster Angriff ×2 Schaden." },
}

local _byId: {[string]: StatusEffect} = {}
for _, e in ipairs(StatusEffectData.EFFECTS) do _byId[e.id] = e end

function StatusEffectData.Get(id: string): StatusEffect?
	return _byId[id]
end

return StatusEffectData
