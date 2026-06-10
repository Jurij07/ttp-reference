--!strict
-- KarmaData.lua (from index.html — Karma System)
-- Karma ranges from -1500 to +1500 and shapes tribulation difficulty, fate
-- events and which NPCs attack you.

local KarmaData = {}

export type KarmaTier = {
	name: string, icon: string, min: number, max: number, tribMult: number,
}

KarmaData.TIERS = {
	{ name="Demon Lord",      icon="👿", min=-math.huge, max=-800, tribMult=2.0 },
	{ name="Evil Cultivator", icon="😈", min=-799,       max=-400, tribMult=1.5 },
	{ name="Dark Path",       icon="🌑", min=-399,       max=-100, tribMult=1.2 },
	{ name="Neutral",         icon="⚖️", min=-99,        max=99,   tribMult=1.0 },
	{ name="Righteous",       icon="☀️", min=100,        max=399,  tribMult=0.85 },
	{ name="Virtuous",        icon="🌟", min=400,        max=799,  tribMult=0.7 },
	{ name="Immortal Virtue", icon="✨", min=800,        max=math.huge, tribMult=0.5 },
}

KarmaData.MIN = -1500
KarmaData.MAX = 1500

function KarmaData.GetTier(karma: number): KarmaTier
	for _, t in ipairs(KarmaData.TIERS) do
		if karma >= t.min and karma <= t.max then return t end
	end
	return KarmaData.TIERS[4]
end

return KarmaData
