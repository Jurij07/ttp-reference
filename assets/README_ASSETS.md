# Game Assets

`icons/` contains the generated icon set (1024×1024 PNG, transparent
background, badge style). `contact_sheet.png` is an overview of all of them.

Regenerate any time with:

```
python3 tools/gen_icons.py
```

## How to use the icons in Roblox

1. **Game icon / thumbnail** — upload `game_icon.png` under
   *Creator Dashboard → your experience → Settings → Basic Info*
   (Game Icon, and optionally as a thumbnail).

2. **In-game icons (Decals)** — for every other PNG:
   1. Go to [create.roblox.com](https://create.roblox.com) →
      *Development Items → Decals → Upload Asset*.
   2. Upload the PNG and wait for moderation.
   3. Copy the numeric **asset id** of the *image* (open the decal page —
      the image id is shown in the URL / asset details).
   4. Paste the id into `src/shared/GameData/IconAssets.lua`, e.g.
      ```lua
      spirit_stone = 1234567890,
      ```

3. **Using them in UI** — anywhere in the client you can do:
   ```lua
   local IconAssets = require(GameData:WaitForChild("IconAssets"))
   local img = IconAssets.Get("spirit_stone")
   if img then
       someImageLabel.Image = img   -- otherwise keep the emoji fallback
   end
   ```

| File | Intended use |
|---|---|
| `game_icon.png` | Experience icon / thumbnail |
| `spirit_stone.png` | 💰 Spirit Stone currency |
| `immortal_jade.png` | 💎 Immortal Jade currency |
| `karma_scale.png` | ⚖️ Karma |
| `exp_orb.png` | ☯️ Cultivation EXP |
| `fortune_charm.png` | Jade Bazaar: Fortune Charm |
| `stone_magnet.png` | Jade Bazaar: Stone Magnet |
| `time_talisman.png` | Jade Bazaar: Time Talisman |
| `tribulation_ward.png` | Jade Bazaar: Tribulation Ward |
| `world1_mortal.png` … `world4_chaos.png` | World emblems (teleport UI, loading screens) |
