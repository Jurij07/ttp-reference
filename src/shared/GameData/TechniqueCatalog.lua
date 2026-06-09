--!strict
-- TechniqueCatalog.lua (generated from index.html)

local TechniqueCatalog = {}

export type TechEntry = {
	id: string, name: string, ttype: string,
	realm: number, cost: number?, costStr: string,
	autoUnlock: boolean,
	reqProvidence: string?, reqPhysique: string?,
	desc: string,
}

TechniqueCatalog.ENTRIES = {
	{ id="basic_qi_refinement_art", name="Basic Qi Refinement Art", ttype="passive", realm=1, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="The most fundamental cultivation technique known to all cultivators. Slowly but steadily refines Qi." },
	{ id="basic_strike", name="Basic Strike", ttype="active", realm=1, cost=5, costStr="5", autoUnlock=true, reqProvidence=nil, reqPhysique=nil, desc="A simple strike using condensed Qi. Deals 120% base damage." },
	{ id="qi_guard", name="Qi Guard", ttype="passive", realm=1, cost=nil, costStr="Free", autoUnlock=true, reqProvidence=nil, reqPhysique=nil, desc="Surround yourself with a thin Qi barrier. Defense +10%." },
	{ id="iron_fist", name="Iron Fist", ttype="active", realm=1, cost=12, costStr="12", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Harden your fist with earth Qi. Deals 140% damage with knockback." },
	{ id="wind_step", name="Wind Step", ttype="movement", realm=1, cost=15, costStr="15", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Move with the wind. Speed +30% for 5 seconds." },
	{ id="qi_healing", name="Qi Healing", ttype="healing", realm=1, cost=20, costStr="20", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Channel Qi inward to heal wounds. Restores 20% HP." },
	{ id="flame_palm", name="Flame Palm", ttype="active", realm=1, cost=25, costStr="25", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Strike with fire Qi. 160% damage with burn effect (5% damage per second for 3s)." },
	{ id="stone_skin", name="Stone Skin", ttype="passive", realm=1, cost=300, costStr="300", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Harden your skin with earth Qi. Defense +25%, HP +10%." },
	{ id="thunder_fist", name="Thunder Fist", ttype="active", realm=1, cost=30, costStr="30", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Strike with thunder Qi. 180% damage, 10% chance to stun." },
	{ id="water_mirror_technique", name="Water Mirror Technique", ttype="passive", realm=1, cost=280, costStr="280", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Calm your mind like still water. 8% dodge chance bonus, EXP +15%." },
	{ id="sword_qi", name="Sword Qi", ttype="active", realm=2, cost=35, costStr="35", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Condense Qi into a sword beam. 180% damage, ignores 20% defense." },
	{ id="foundation_crushing_fist", name="Foundation Crushing Fist", ttype="active", realm=2, cost=40, costStr="40", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Strike with the full force of your Foundation. 200% damage." },
	{ id="cloud_step", name="Cloud Step", ttype="movement", realm=2, cost=35, costStr="35", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Move like a cloud. Speed ×2 for 8 seconds." },
	{ id="iron_body_art", name="Iron Body Art", ttype="physique", realm=2, cost=800, costStr="800", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Temper your body with Qi. Defense +35%, take 10% less damage." },
	{ id="spirit_restoration", name="Spirit Restoration", ttype="healing", realm=2, cost=60, costStr="60", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Restore both HP and Qi. Heals 35% HP and 40% Qi." },
	{ id="dao_heart_technique", name="Dao Heart Technique", ttype="dao", realm=2, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Comprehend the Dao. EXP +30%, immune to mental attacks." },
	{ id="flame_dao_burst", name="Flame Dao Burst", ttype="dao", realm=2, cost=80, costStr="80", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Release compressed fire Dao. 250% damage with area burn." },
	{ id="lightning_domain", name="Lightning Domain", ttype="dao", realm=2, cost=100, costStr="100", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Create a field of lightning Qi. All nearby enemies take 20% more damage." },
	{ id="shadow_step", name="Shadow Step", ttype="movement", realm=2, cost=60, costStr="60", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Step through shadows. Teleport up to 20 meters instantly." },
	{ id="golden_core_art", name="Golden Core Art", ttype="passive", realm=3, cost=nil, costStr="5,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Your Golden Core radiates power. All stats +20%." },
	{ id="sword_domain", name="Sword Domain", ttype="dao", realm=3, cost=120, costStr="120", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Create a domain of sword Qi. All attacks +50% damage for 12 seconds." },
	{ id="void_flash", name="Void Flash", ttype="movement", realm=3, cost=100, costStr="100", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Tear through space. Instantly teleport behind any target." },
	{ id="nascent_flame", name="Nascent Flame", ttype="active", realm=4, cost=200, costStr="200", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="The flame of the Nascent Soul. 400% damage, cannot be blocked." },
	{ id="soul_brand", name="Soul Brand", ttype="active", realm=4, cost=180, costStr="180", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Brand the target's soul. Deals 300% damage and reduces their defense by 40% for 20 seconds." },
	{ id="heaven_sealing_art", name="Heaven Sealing Art", ttype="special", realm=4, cost=150, costStr="150", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Seal the target's cultivation. Cannot use techniques for 15 seconds." },
	{ id="soul_formation_mastery", name="Soul Formation Mastery", ttype="passive", realm=5, cost=nil, costStr="50,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Your Soul Formation is complete. EXP +50%, all combat stats +30%." },
	{ id="void_shatter_palm", name="Void Shatter Palm", ttype="active", realm=5, cost=300, costStr="300", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Shatter space with your palm. 600% damage to a single target." },
	{ id="ten_thousand_swords_formation", name="Ten Thousand Swords Formation", ttype="active", realm=6, cost=400, costStr="400", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Summon ten thousand sword phantoms. 800% total damage, hits all enemies." },
	{ id="body_tribulation_art", name="Body Tribulation Art", ttype="physique", realm=1, cost=500, costStr="500", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Invite tribulation lightning to temper your body. HP +200%, immune to physical damage for 5s." },
	{ id="chaos_dao_manifestation", name="Chaos Dao Manifestation", ttype="dao", realm=9, cost=nil, costStr="1,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Manifest the Chaos Dao. 1000% damage. Cannot be blocked or dodged." },
	{ id="creation_will_fragment", name="Creation Will Fragment", ttype="special", realm=8, cost=800, costStr="800", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Channel a fragment of Creation Will. 500% damage, heal 50% HP, ignore all defenses." },
	{ id="lone_star_fate", name="Lone Star Fate", ttype="special", realm=3, cost=nil, costStr="15,000", autoUnlock=false, reqProvidence="Destined Lone Star", reqPhysique=nil, desc="Those who approach suffer misfortune. Enemies take 15% more damage from all sources." },
	{ id="water_spirit_healing_art", name="Water Spirit Healing Art", ttype="healing", realm=2, cost=80, costStr="80", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Channel water spirit Qi to heal. Restores 60% HP and cleanses debuffs." },
	{ id="six_paths_divine_body_art", name="Six Paths Divine Body Art", ttype="physique", realm=5, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Activate the Six Paths Physique. HP +200%, Defense +100%, take 30% less damage." },
	{ id="calamity_star_pulse", name="Calamity Star Pulse", ttype="active", realm=3, cost=70, costStr="70", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Release calamity energy. 220% damage, causes bad luck debuff (enemies miss 15% of attacks)." },
	{ id="earth_wood_harmony", name="Earth-Wood Harmony", ttype="passive", realm=2, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Channel dual element Qi. HP +30%, EXP +25%." },
	{ id="soul_formation_fist", name="Soul Formation Fist", ttype="active", realm=4, cost=180, costStr="180", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Your Nascent Soul empowers each strike. 350% damage, cannot miss." },
	{ id="void_rupture", name="Void Rupture", ttype="active", realm=5, cost=220, costStr="220", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Tear a hole in space. 400% damage to all enemies caught in the rift." },
	{ id="space_lock", name="Space Lock", ttype="active", realm=5, cost=160, costStr="160", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Lock the target in place for 8 seconds. They cannot move or use techniques." },
	{ id="body_rebirth_art", name="Body Rebirth Art", ttype="physique", realm=6, cost=nil, costStr="40,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Your body regenerates during combat. Restore 5% HP per round." },
	{ id="tribulation_armor", name="Tribulation Armor", ttype="physique", realm=7, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Clothe yourself in tribulation lightning. Defense +150%, attackers take 20% reflected damage." },
	{ id="immortal_eye", name="Immortal Eye", ttype="passive", realm=8, cost=nil, costStr="200,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="See through all illusions and deceptions. EXP +40%, cannot be affected by mind techniques." },
	{ id="mahayana_breaking_palm", name="Mahayana Breaking Palm", ttype="active", realm=9, cost=500, costStr="500", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="The pinnacle mortal technique. 700% damage, instantly kills opponents 2+ Realms below." },
	{ id="world_law_comprehension", name="World Law Comprehension", ttype="dao", realm=9, cost=nil, costStr="2.0M", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Comprehend the laws of the world itself. All techniques cost 50% less Qi and deal 50% more damage." },
	{ id="reincarnation_technique", name="Reincarnation Technique", ttype="special", realm=9, cost=nil, costStr="5.0M", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Cheat death once. If you would be defeated, instead restore to 30% HP." },
	{ id="qi_storage_method", name="Qi Storage Method", ttype="passive", realm=1, cost=120, costStr="120", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Store excess Qi for emergencies. Max Qi +15%." },
	{ id="bloodline_awakening", name="Bloodline Awakening", ttype="passive", realm=2, cost=600, costStr="600", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Awaken dormant bloodline potential. All stats +8%." },
	{ id="meridian_expansion_art", name="Meridian Expansion Art", ttype="passive", realm=2, cost=nil, costStr="1,200", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Widen your meridians. Qi regeneration +25%, max Qi +20%." },
	{ id="will_hardening", name="Will Hardening", ttype="passive", realm=3, cost=nil, costStr="4,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Harden your cultivation will. Immune to fear and intimidation effects, EXP +20%." },
	{ id="heaven_defying_will", name="Heaven-Defying Will", ttype="passive", realm=4, cost=nil, costStr="15,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Your will defies the heavens themselves. Breakthrough success +20%, all tribulations weakened." },
	{ id="perfect_dao_heart", name="Perfect Dao Heart", ttype="passive", realm=6, cost=nil, costStr="100,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Your Dao Heart is flawless. EXP +60%, immune to all debuffs." },
	{ id="forest_qi_step", name="Forest Qi Step", ttype="movement", realm=1, cost=10, costStr="10", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Navigate through dense Qi areas. Speed +20%, cannot be tracked." },
	{ id="ancient_ruin_sensing", name="Ancient Ruin Sensing", ttype="passive", realm=2, cost=400, costStr="400", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Sense ancient formations and traps. Loot quantity +30%." },
	{ id="sea_qi_breathing", name="Sea Qi Breathing", ttype="passive", realm=4, cost=nil, costStr="2,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Absorb Qi from the sea air. HP regeneration +10% in combat." },
	{ id="void_stabilization", name="Void Stabilization", ttype="passive", realm=5, cost=nil, costStr="8,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Stabilize your Qi in void spaces. All techniques work at full power in unstable areas." },
	{ id="immortal_gate_ward", name="Immortal Gate Ward", ttype="passive", realm=7, cost=nil, costStr="50,000", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="The Immortal Gate's energy protects you. Defense +40%, immune to instant death." },
	{ id="five_elements_formation", name="Five Elements Formation", ttype="formation", realm=1, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Creates a formation using all five elements. Reduces all incoming damage by 25% for 20 seconds." },
	{ id="sword_array_formation", name="Sword Array Formation", ttype="formation", realm=1, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="Summons a formation of sword Qi. Passive +30% damage for 30 seconds, enemies take damage entering the field." },
	{ id="heavenly_dao_formation", name="Heavenly Dao Formation", ttype="formation", realm=1, cost=nil, costStr="Free", autoUnlock=false, reqProvidence=nil, reqPhysique=nil, desc="The ultimate formation technique. All stats +50% and enemies take 20% more damage for 60 seconds." },
}

local _byId: {[string]: TechEntry} = {}
for _, t in ipairs(TechniqueCatalog.ENTRIES) do _byId[t.id] = t end

function TechniqueCatalog.Get(id: string): TechEntry?
	return _byId[id]
end

return TechniqueCatalog
