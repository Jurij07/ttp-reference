#!/usr/bin/env python3
"""Generate NPC rosters for realms 10-26 and splice them into NPCData.lua.

Stat design: mobs are tuned against the PLAYER combat-stat curve from
CultivationData.GetCombatStats (hp=120*1.6^(r-1), dmg=12*1.5^(r-1),
def=3*1.4^(r-1)) so the idle auto-hunt stays winnable with realistic
equipment/providence multipliers (~1.5-2.5x) at every realm.

EXP rewards scale with each realm's expStage1 so hunting stays meaningful
next to the passive idle tick (existing R1-9 data left untouched).
"""

EXP_STAGE1 = {  # from CultivationData.REALMS
    10: 10e9, 11: 20e9, 12: 30e9, 13: 40e9, 14: 50e9, 15: 60e9,
    16: 70e9, 17: 80e9, 18: 90e9, 19: 100e9, 20: 110e9, 21: 120e9,
    22: 130e9, 23: 140e9, 24: 150e9, 25: 160e9, 26: 170e9,
}

# 9 mobs + 1 boss per realm. Icons drive the NPCService body archetype.
ROSTERS = {
    10: ("Loose Immortal", [
        ("Cloud Serpent", "🐍"), ("Sky Lotus Sprite", "✨"), ("Drifting Sword Phantom", "👤"),
        ("Mist Hart", "🦌"), ("Gale Roc", "🦅"), ("Jade Cloud Tortoise", "🐢"),
        ("Loose Immortal Wanderer", "🧙"), ("Thunderhead Elemental", "🌀"), ("Heaven Gate Sentinel", "🗿"),
    ], ("Loose Immortal Sovereign 👑", "👑")),
    11: ("Earth Immortal", [
        ("Earthvein Pangolin", "🦔"), ("Stone Lotus Guardian", "🗿"), ("Quake Boar", "🐗"),
        ("Terracotta Soldier", "💀"), ("Mountain Root Dragon", "🐲"), ("Geode Beetle", "🪲"),
        ("Earth Immortal Hermit", "👴"), ("Ley-Line Wraith", "👻"), ("Granite Colossus", "🗿"),
    ], ("Earthheart Immortal King 👑", "👑")),
    12: ("Heaven Immortal", [
        ("Star Falcon", "🦅"), ("Moonlit Fox Spirit", "🦊"), ("Comet Carp", "🐟"),
        ("Heavenly Pillar Guard", "🗿"), ("Aurora Serpent", "🐍"), ("Nebula Jellyfish", "🪼"),
        ("Heaven Immortal Adjudicator", "🧙"), ("Stellar Chimera", "🔀"), ("Galaxy Whale", "🐋"),
    ], ("Heavenly Court Marshal 👑", "👑")),
    13: ("True Immortal", [
        ("True Flame Phoenix", "🦅"), ("Immortal Script Golem", "🗿"), ("Dao Pattern Tiger", "🐯"),
        ("White Jade Dragon", "🐉"), ("Karmic Thread Weaver", "🕷️"), ("Immortal Blade Servant", "👤"),
        ("Five Element Lion", "🦁"), ("Eternal Spring Turtle", "🐢"), ("Immortal Tribunal Judge", "🧙"),
    ], ("True Immortal Exemplar 👑", "👑")),
    14: ("Mystic Immortal", [
        ("Mystic Rune Moth", "🦋"), ("Abyssal Koi", "🐟"), ("Veiled Sphinx", "🐯"),
        ("Mirror Image Doppel", "👤"), ("Aurora Stag", "🦌"), ("Enigma Serpent", "🐍"),
        ("Riddle Keeper Sage", "👴"), ("Twilight Kirin", "🐲"), ("Arcane Locus Spirit", "🌀"),
    ], ("Mystic Veil Empress 👑", "👑")),
    15: ("Golden Immortal", [
        ("Gilded War Hound", "🐺"), ("Sunfire Vulture", "🦅"), ("Golden Scale Leviathan", "🐉"),
        ("Radiant Halberd Guard", "👤"), ("Molten Gold Elemental", "🌀"), ("Daybreak Rooster", "🐦"),
        ("Golden Immortal Champion", "🧙"), ("Solar Chariot Steed", "🐴"), ("Treasury Guardian Statue", "🗿"),
    ], ("Golden Immortal Warlord 👑", "👑")),
    16: ("Immortal Emperor", [
        ("Imperial Edict Crane", "🐦"), ("Dragon Throne Wyrm", "🐲"), ("Jade Seal Golem", "🗿"),
        ("Courtier Shade", "👻"), ("Imperial Guard Captain", "👤"), ("Nine-Tail Court Fox", "🦊"),
        ("Edict Flame Qilin", "🐯"), ("Censorate Inquisitor", "🧙"), ("Crown Prince Phantom", "💀"),
    ], ("Immortal Emperor's Regent 👑", "👑")),
    17: ("Mystic Divine Origin", [
        ("Origin Light Moth", "✨"), ("Divine Origin Acolyte", "👤"), ("Primal Mist Drake", "🐲"),
        ("Genesis Bloom Treant", "🌳"), ("Divine Spark Phoenix", "🦅"), ("Origin Pool Naga", "🐍"),
        ("First Dawn Sage", "👴"), ("Hallowed Chime Spirit", "🌀"), ("Origin Pillar Warden", "🗿"),
    ], ("Voice of the Divine Origin 👑", "👑")),
    18: ("Zenith Heaven", [
        ("Zenith Sky Lancer", "👤"), ("Apex Storm Roc", "🦅"), ("Heavenpeak Yeti", "🦍"),
        ("Zenith Halo Serpent", "🐍"), ("Summit Flame Lion", "🦁"), ("Skyreach Pagoda Spirit", "🌀"),
        ("Zenith Heaven Marshal", "🧙"), ("Empyrean Tortoise", "🐢"), ("Crowned Star Dragon", "🐉"),
    ], ("Zenith Heaven Paragon 👑", "👑")),
    19: ("Quasi-Sage", [
        ("Half-Step Sage Shade", "👻"), ("Pseudo Primordial Ape", "🦍"), ("Quasi-Dao Serpent", "🐍"),
        ("Incomplete Truth Golem", "🗿"), ("Sage Echo Phantom", "👤"), ("Threshold Qilin", "🐲"),
        ("Almost-Enlightened Monk", "🧙"), ("Fractured Halo Spirit", "✨"), ("Boundary Stone Titan", "🗿"),
    ], ("Quasi-Sage Pretender 👑", "👑")),
    20: ("Perfect Sage", [
        ("Sage Lecture Crane", "🐦"), ("Scripture Spirit", "✨"), ("Perfected Lotus Guardian", "🌀"),
        ("Sage Hall Sentinel", "🗿"), ("Enlightened Beast King", "🦁"), ("Dao Debate Phantom", "👤"),
        ("Sage Fire Phoenix", "🦅"), ("Wisdom Pool Serpent", "🐍"), ("Perfect Sage Disciple", "🧙"),
    ], ("Perfect Sage Ancestor 👑", "👑")),
    21: ("Freedom Primordial Chaos", [
        ("Unbound Chaos Moth", "🌀"), ("Freedom Wing Roc", "🦅"), ("Chaos Tide Serpent", "🐍"),
        ("Lawless Void Ape", "🦍"), ("Untethered Sword Saint", "👤"), ("Primordial Mist Drake", "🐲"),
        ("Freedom Seeker Sage", "🧙"), ("Chaos Bloom Spirit", "✨"), ("Horizon Breaker Titan", "🗿"),
    ], ("Freedom Chaos Monarch 👑", "👑")),
    22: ("Great Dao Primordial Chaos", [
        ("Dao Thread Weaver", "🕷️"), ("Great Dao Manifestation", "🌀"), ("Chaos Scripture Golem", "🗿"),
        ("Primordial Dao Serpent", "🐍"), ("Law Fragment Phantom", "👤"), ("Dao Sea Leviathan", "🐉"),
        ("Great Dao Arbiter", "🧙"), ("Principle Flame Bird", "🦅"), ("Axiom Guardian", "🗿"),
    ], ("Great Dao Incarnate 👑", "👑")),
    23: ("Great Dao Supreme", [
        ("Supreme Edict Wraith", "👻"), ("Dao Crown Drake", "🐲"), ("Supremacy Trial Golem", "🗿"),
        ("Peerless Sword Phantom", "👤"), ("Great Dao Warbeast", "🦁"), ("Throne of Laws Spirit", "🌀"),
        ("Supreme Dao Herald", "🧙"), ("Infinity Coil Serpent", "🐍"), ("Apex Mandate Titan", "🗿"),
    ], ("Great Dao Supreme Echo 👑", "👑")),
    24: ("Dao Creator", [
        ("Worldseed Sprite", "✨"), ("Creation Loom Weaver", "🕷️"), ("Genesis Forge Golem", "🗿"),
        ("Newborn Universe Drake", "🐉"), ("Concept Painter Phantom", "👤"), ("Reality Draft Chimera", "🔀"),
        ("Dao Creator's Apprentice", "🧙"), ("Cosmos Shell Tortoise", "🐢"), ("Primordial Canvas Spirit", "🌀"),
    ], ("Dao Creation Avatar 👑", "👑")),
    25: ("Creator Lord", [
        ("Lord's Herald Seraph", "😇"), ("Omniverse Watcher", "👁️"), ("Creation Tide Leviathan", "🐉"),
        ("Star Forger Colossus", "🗿"), ("Genesis Storm Elemental", "🌀"), ("Infinite Library Keeper", "🧙"),
        ("Creator's Hand Phantom", "👤"), ("Multiverse Strider", "🦌"), ("Throneworld Guardian", "🗿"),
    ], ("Creator Lord's Shadow 👑", "👑")),
    26: ("Ultimate Origin Supreme", [
        ("Origin Spark", "✨"), ("First Cause Phantom", "👤"), ("Ultimate Truth Serpent", "🐍"),
        ("Omega Dragon God", "🐉"), ("Beginning-and-End Golem", "🗿"), ("Supreme Origin Seraph", "😇"),
        ("Last Question Sage", "🧙"), ("Eternity Coil Leviathan", "🐉"), ("The Unwritten One", "👁️"),
    ], ("Avatar of the Ultimate Origin 👑", "👑")),
}

GRADE = {
    10: "SSS", 11: "SSS", 12: "SSS", 13: "MYTHIC", 14: "MYTHIC", 15: "MYTHIC",
    16: "MYTHIC", 17: "MYTHIC", 18: "BEYOND", 19: "BEYOND", 20: "BEYOND",
    21: "BEYOND", 22: "BEYOND", 23: "BEYOND", 24: "BEYOND", 25: "BEYOND", 26: "BEYOND",
}
BOSS_GRADE = {r: ("MYTHIC" if r <= 12 else "BEYOND") for r in range(10, 27)}


def fnum(x: float) -> str:
    """Format a number as Lua: integers below 1e15, scientific above."""
    if x < 1e15:
        return str(int(round(x)))
    return f"{x:.4g}"


def gen_realm(r: int) -> str:
    p_hp = 120 * 1.6 ** (r - 1)
    p_dmg = 12 * 1.5 ** (r - 1)
    p_def = 3 * 1.4 ** (r - 1)
    exp1 = EXP_STAGE1[r]
    stone_base = 2500 * 1.5 ** (r - 9)

    _theme, mobs, (boss_name, boss_icon) = ROSTERS[r]
    lines = [f"\t[{r}] = {{"]
    for i, (name, icon) in enumerate(mobs, start=1):
        hp = p_hp * (2.0 + 0.55 * i)
        dmg = p_dmg * (0.45 + 0.06 * i)
        df = p_def * (0.5 + 0.12 * i)
        exp = exp1 * (0.004 + 0.0014 * i)
        stones = stone_base * (0.6 + 0.12 * i)
        mut = min(10 + 2 * i, 40)
        lines.append(
            f'\t\t{{ name="{name}", icon="{icon}", grade="{GRADE[r]}", '
            f"hp={fnum(hp)}, dmg={fnum(dmg)}, def={fnum(df)}, "
            f"exp={fnum(exp)}, stones={fnum(stones)}, boss=false, mut={mut} }},"
        )
    boss_hp = p_hp * 22
    boss_dmg = p_dmg * 1.3
    boss_def = p_def * 2.2
    boss_exp = exp1 * 0.06
    boss_stones = stone_base * 4
    lines.append(
        f'\t\t{{ name="{boss_name}", icon="{boss_icon}", grade="{BOSS_GRADE[r]}", '
        f"hp={fnum(boss_hp)}, dmg={fnum(boss_dmg)}, def={fnum(boss_def)}, "
        f"exp={fnum(boss_exp)}, stones={fnum(boss_stones)}, boss=true, mut={min(60 + r, 100)} }},"
    )
    lines.append("\t},")
    return "\n".join(lines)


def main() -> None:
    path = "/home/user/ttp-reference/src/shared/GameData/NPCData.lua"
    src = open(path, encoding="utf-8").read()
    anchor = "\n}\n\nfunction NPCData.GetRealmNPCs"
    assert anchor in src, "anchor not found"
    block = "\n".join(gen_realm(r) for r in range(10, 27))
    src = src.replace(anchor, "\n" + block + "\n}\n\nfunction NPCData.GetRealmNPCs")
    src = src.replace(
        "-- NPCData.lua (generated from index.html)",
        "-- NPCData.lua (R1-9 from the index.html reference; R10-26 generated\n"
        "-- against the player combat-stat curve so idle hunts stay winnable)",
    )
    open(path, "w", encoding="utf-8").write(src)
    print("NPCData.lua updated:", src.count("boss=true"), "bosses total")


if __name__ == "__main__":
    main()
