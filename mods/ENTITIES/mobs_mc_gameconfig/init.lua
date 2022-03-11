mobs_mc = {}

mobs_mc.override = {}

mobs_mc.override.items = {
	chicken_raw = "mcl_mobitems:chicken",
	chicken_cooked = "mcl_mobitems:cooked_chicken",
	feather = "mcl_mobitems:feather",
	bowl = "mcl_core:bowl",
	mushroom_stew = "mcl_mushrooms:mushroom_stew",
	milk = "mcl_mobitems:milk_bucket",
	egg = "mcl_throwing:egg",
	saddle = "mcl_mobitems:saddle",
	porkchop_raw = "mcl_mobitems:porkchop",
	porkchop_cooked = "mcl_mobitems:cooked_porkchop",
	rotten_flesh = "mcl_mobitems:rotten_flesh",
	snowball = "mcl_throwing:snowball",
	top_snow = "mcl_core:snow",
	snow_block = "mcl_core:snowblock",
	arrow = "mcl_bows:arrow",
	bow = "mcl_bows:bow",

	leather = "mcl_mobitems:leather",
	shears = "mcl_tools:shears",

	mushroom_red = "mcl_mushrooms:mushroom_red",
	mushroom_brown = "mcl_mushrooms:mushroom_brown",
	bucket = "mcl_buckets:bucket_empty",
	grass_block = "mcl_core:dirt_with_grass",
	string = "mcl_mobitems:string",
	stick = "mcl_core:stick",
	flint = "mcl_core:flint",
	iron_ingot = "mcl_core:iron_ingot",
	iron_block = "mcl_core:ironblock",
	fire = "mcl_fire:fire",
	gunpowder = "mcl_mobitems:gunpowder",
	flint_and_steel = "mcl_fire:flint_and_steel",
	water_source = "mcl_core:water_source",
	river_water_source = "mclx_core:river_water_source",
	poppy = "mcl_flowers:poppy",
	dandelion = "mcl_flowers:dandelion",
	coal = "mcl_core:coal_lump",
	iron_axe = "mcl_tools:axe_iron",
	gold_sword = "mcl_tools:sword_gold",
	gold_ingot = "mcl_core:gold_ingot",
	glowstone_dust = "mcl_nether:glowstone_dust",
	redstone = "mesecons:redstone",
	glass_bottle = "mcl_potions:glass_bottle",
	sugar = "mcl_core:sugar",
	wheat = "mcl_farming:wheat_item",
	cookie = "mcl_farming:cookie",
	potato = "mcl_farming:potato_item",
	hay_bale = "mcl_farming:hay_block",
	apple = "mcl_core:apple",
	golden_apple = "mcl_core:apple_gold",

	-- Other
	fishing_rod = "mcl_fishing:fishing_rod",
	fish_raw = "mcl_fishing:fish_raw",
	salmon_raw = "mcl_fishing:salmon_raw",
	bone = "mcl_mobitems:bone",
	slimeball = "mcl_mobitems:slimeball",

	wool_white = "mcl_wool:white",
	wool_light_grey = "mcl_wool:silver",
	wool_grey = "mcl_wool:grey",
	wool_blue = "mcl_wool:blue",
	wool_lime = "mcl_wool:lime",
	wool_green = "mcl_wool:green",
	wool_purple = "mcl_wool:purple",
	wool_pink = "mcl_wool:pink",
	wool_yellow = "mcl_wool:yellow",
	wool_orange = "mcl_wool:orange",
	wool_brown = "mcl_wool:brown",
	wool_red = "mcl_wool:red",
	wool_cyan = "mcl_wool:cyan",
	wool_magenta = "mcl_wool:magenta",
	wool_black = "mcl_wool:black",
	wool_light_blue = "mcl_wool:light_blue",

	music_discs = {
		"mcl_jukebox:record_1",
		"mcl_jukebox:record_2",
		"mcl_jukebox:record_3",
		"mcl_jukebox:record_4",
		"mcl_jukebox:record_5",
		"mcl_jukebox:record_6",
		"mcl_jukebox:record_7",
		"mcl_jukebox:record_8",
		"mcl_jukebox:record_9",
	},
}

--Horses, Llamas, and Wolves shouldn't follow, but leaving this alone until leads are implemented.
mobs_mc.override.follow = {
	chicken = { "mcl_farming:wheat_seeds", "mcl_farming:pumpkin_seeds" },
	sheep = { mobs_mc.override.items.wheat },
	cow = { mobs_mc.override.items.wheat },
}

mobs_mc.override.replace = {
	-- Sheep eat grass
	sheep = {
		{ "mcl_core:dirt_with_grass", "mcl_core:dirt", -1 },
		{ "mcl_flowers:tallgrass", "air", 0 },
	},
}

-- List of nodes which endermen can take
mobs_mc.override.enderman_takable = {
	-- Generic handling, useful for entensions
	"group:enderman_takable",
}
mobs_mc.override.enderman_replace_on_take = {
}
mobs_mc.override.misc = {
	totem_fail_nodes = { "mcl_core:void", "mcl_core:realm_barrier" },
}

-- Texuture overrides for enderman block. Required for cactus because it's original is a nodebox
-- and the textures have tranparent pixels.
local cbackground = "mobs_mc_gameconfig_enderman_cactus_background.png"
local ctiles = minetest.registered_nodes["mcl_core:cactus"].tiles

local ctable = {}
local last
for i=1, 6 do
	if ctiles[i] then
		last = ctiles[i]
	end
	table.insert(ctable, cbackground .. "^" .. last)
end

mobs_mc.override.enderman_block_texture_overrides = {
	["mcl_core:cactus"] = ctable,
	-- FIXME: replace colorize colors with colors from palette
	["mcl_core:dirt_with_grass"] =
	{
	"mcl_core_grass_block_top.png^[colorize:green:90",
	"default_dirt.png",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)"}
}

-- List of nodes on which mobs can spawn
mobs_mc.override.spawn = {
	solid = { "group:solid", }, -- spawn on "solid" nodes
	grassland = { "mcl_core:dirt_with_grass" },
	savanna = { "mcl_core:dirt_with_grass" },
	grassland_savanna = { "mcl_core:dirt_with_grass" },
	desert = { "mcl_core:sand", "mcl_core:sandstone" },
	jungle = { "mcl_core:jungletree", "mcl_core:jungleleaves", "mcl_flowers:fern", "mcl_core:vine" },
	snow = { "mcl_core:snow", "mcl_core:snowblock", "mcl_core:dirt_with_grass_snow" },
	-- End stone added for shulkers because End cities don't generate yet
	end_city = { "mcl_end:end_stone", "mcl_end:purpur_block" },
	nether_portal = { mobs_mc.override.items.nether_portal },
	wolf = { mobs_mc.override.items.grass_block, "mcl_core:dirt", "mcl_core:dirt_with_grass_snow", "mcl_core:snow", "mcl_core:snowblock", "mcl_core:podzol" },
	village = { "mcl_villages:stonebrickcarved", "mcl_core:grass_path", "mcl_core:sandstonesmooth2" },
}

-- This table contains important spawn height references for the mob spawn height.
mobs_mc.override.spawn_height = {
	water = tonumber(minetest.settings:get("water_level")) or 0, -- Water level in the Overworld

	-- Overworld boundaries (inclusive)
	overworld_min = mcl_vars.mg_overworld_min,
	overworld_max = mcl_vars.mg_overworld_max,
}

