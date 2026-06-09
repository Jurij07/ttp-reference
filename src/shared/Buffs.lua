--!strict
-- Buffs.lua
-- Zeitbasierte Multiplikator-Buffs (z.B. von Pillen). Liegt in ReplicatedStorage,
-- damit Server (anwenden + lesen) und Client (Anzeige) ihn nutzen können.
-- Buffs werden als zwei Player-Attribute gespeichert:
--   <Kind>BuffMult  = Multiplikator (z.B. 2.0)
--   <Kind>BuffUntil = os.time()-Zeitstempel, bis wann der Buff aktiv ist
-- Kinds: "Exp", "Dmg"

local Buffs = {}

-- Liefert den aktuell aktiven Multiplikator (1.0 wenn kein/abgelaufener Buff).
function Buffs.GetMult(player: Player, kind: string): number
	local until_ = player:GetAttribute(kind .. "BuffUntil") or 0
	if os.time() < until_ then
		return player:GetAttribute(kind .. "BuffMult") or 1.0
	end
	return 1.0
end

-- Sekunden, die der Buff noch läuft (0 wenn inaktiv).
function Buffs.Remaining(player: Player, kind: string): number
	local until_ = player:GetAttribute(kind .. "BuffUntil") or 0
	return math.max(0, until_ - os.time())
end

-- Aktiviert (oder verlängert) einen Buff.
function Buffs.Apply(player: Player, kind: string, mult: number, duration: number)
	player:SetAttribute(kind .. "BuffMult", mult)
	player:SetAttribute(kind .. "BuffUntil", os.time() + duration)
end

return Buffs
