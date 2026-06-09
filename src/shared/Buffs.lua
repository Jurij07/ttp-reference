--!strict
-- Buffs.lua
-- Timed EXP/DMG multiplier buffs stored as player Attributes.

local Buffs = {}

function Buffs.GetMult(player: Player, kind: string): number
	local attr = if kind == "Exp" then "ExpBuffUntil" else "DmgBuffUntil"
	local multAttr = if kind == "Exp" then "ExpBuffMult" else "DmgBuffMult"
	local until_ = (player:GetAttribute(attr) or 0) :: number
	if os.time() < until_ then
		return (player:GetAttribute(multAttr) or 1.0) :: number
	end
	return 1.0
end

function Buffs.Apply(player: Player, kind: string, mult: number, duration: number)
	local attr = if kind == "Exp" then "ExpBuffUntil" else "DmgBuffUntil"
	local multAttr = if kind == "Exp" then "ExpBuffMult" else "DmgBuffMult"
	local until_ = (player:GetAttribute(attr) or 0) :: number
	local newUntil = math.max(until_, os.time()) + duration
	player:SetAttribute(attr, newUntil)
	player:SetAttribute(multAttr, mult)
end

function Buffs.Remaining(player: Player, kind: string): number
	local attr = if kind == "Exp" then "ExpBuffUntil" else "DmgBuffUntil"
	local until_ = (player:GetAttribute(attr) or 0) :: number
	return math.max(0, until_ - os.time())
end

return Buffs
