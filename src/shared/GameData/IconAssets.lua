--!strict
-- IconAssets.lua
-- Roblox asset ids for the generated icon set (assets/icons/*.png).
-- Upload each PNG as a Decal on create.roblox.com and paste the numeric
-- asset id here (see README_ASSETS.md). A value of 0 means "not uploaded
-- yet" — UI code falls back to the emoji glyphs in that case.

local IconAssets = {}

IconAssets.IDS = {
	game_icon        = 0,
	spirit_stone     = 0,
	immortal_jade    = 0,
	karma_scale      = 0,
	exp_orb          = 0,
	fortune_charm    = 0,
	stone_magnet     = 0,
	time_talisman    = 0,
	tribulation_ward = 0,
	world1_mortal    = 0,
	world2_sky       = 0,
	world3_sage      = 0,
	world4_chaos     = 0,
} :: { [string]: number }

-- "rbxassetid://N" for ImageLabel.Image / ImageButton.Image, or nil if the
-- asset hasn't been uploaded yet.
function IconAssets.Get(key: string): string?
	local id = IconAssets.IDS[key]
	if id and id > 0 then
		return "rbxassetid://" .. tostring(id)
	end
	return nil
end

return IconAssets
