--[[ This table contains the concrete itemstrings to be used by this mod.
All mobs in this mod must use variables in this table, instead
of hardcoding the itemstring.
This way, external mods are enabled to replace the itemstrings to provide
their own items and game integration is made much simpler.

An item IDs is supposed to be overwritten by adding
mobs_mc.override.items["example:item"] in a game mod
with name "mobs_mc_gameconfig". ]]


-- Standard items

-- If true, mobs_mc adds the monster egg nodes (needs default mod).
-- Set to false in your gameconfig mod if you create your own monster egg nodes.
mobs_mc.create_monster_egg_nodes = true

mobs_mc.items = {}

mobs_mc.items = {
	-- Items defined in mobs_mc
	chicken_raw = "mobs_mc:chicken_raw",
	chicken_cooked = "mobs_mc:chicken_cooked",
	feather = "mobs_mc:feather",
	bowl = "mobs_mc:bowl",
	mushroom_stew = "mobs_mc:mushroom_stew",
	milk = "mobs_mc:milk_bucket",
	egg = "mobs_mc:egg",
	saddle = "mobs:saddle",
	porkchop_raw = "mobs_mc:porkchop_raw",
	porkchop_cooked = "mobs_mc:porkchop_cooked",
	snowball = "mobs_mc:snowball",
	totem = "mobs_mc:totem",
	rotten_flesh = "mobs_mc:rotten_flesh",
	nether_star = "mobs_mc:nether_star",
	bone = "mobs_mc:bone",
	slimeball = "mobs_mc:slimeball",
	arrow = "mobs_mc:arrow",
	bow = "mobs_mc:bow_wood",

	-- External items
	-- Mobs Redo
	leather = "mobs:leather",
	shears = "mobs:shears",

	-- Minetest Game
	top_snow = "default:snow",
	snow_block = "default:snowblock",
	mushroom_red = "flowers:mushroom_red",
	bucket = "bucket:bucket_empty",
	grass_block = "default:dirt_with_grass",
	string = "farming:string",
	stick = "default:stick",
	flint = "default:flint",
	iron_ingot = "default:steel_ingot",
	iron_block = "default:steelblock",
	fire = "fire:basic_flame",
	gunpowder = "tnt:gunpowder",
	flint_and_steel = "fire:flint_and_steel",
	water_source = "default:water_source",
	river_water_source = "default:river_water_source",
	black_dye = "dye:black",
	poppy = "flowers:rose",
	dandelion = "flowers:dandelion_yellow",
	coal = "default:coal_lump",
	iron_axe = "default:axe_steel",
	gold_sword = "default:sword_mese",
	gold_ingot = "default:gold_ingot",
	glowstone_dust = "default:mese_crystal_fragment",
	redstone = "default:mese_crystal_fragment",
	glass_bottle = "vessels:glass_bottle",
	sugar = "default:papyrus",
	wheat = "farming:wheat",
	hay_bale = "farming:straw",
	apple = "default:apple",
	golden_apple = "default:apple",

	-- Boss items
	wet_sponge = "default:gold_block", -- only dropped by elder guardian; there is no equivalent block in Minetest Game

	-- Other
	fishing_rod = "fishing:pole_wood",
	fish_raw = "fishing:fish_raw",
	salmon_raw = "fishing:carp_raw",
	clownfish_raw = "fishing:clownfish_raw",
	pufferfish_raw = "fishing:pike_raw",

	cookie = "farming:cookie",

	-- Wool (Minecraft color scheme)
	wool_white = "wool:white",
	wool_light_grey = "wool:grey",
	wool_grey = "wool:dark_grey",
	wool_blue = "wool:blue",
	wool_lime = "wool:green",
	wool_green = "wool:dark_green",
	wool_purple = "wool:violet",
	wool_pink = "wool:pink",
	wool_yellow = "wool:yellow",
	wool_orange = "wool:orange",
	wool_brown = "wool:brown",
	wool_red = "wool:red",
	wool_cyan = "wool:cyan",
	wool_magenta = "wool:magenta",
	wool_black = "wool:black",
	-- Light blue intentionally missing

	-- Special items
	music_discs = {}, -- No music discs by default; used by creeper. Override this if your game has music discs.
}

-- Tables for attracting, feeding and breeding mobs
mobs_mc.follow = {
	sheep = { mobs_mc.items.wheat },
	cow = { mobs_mc.items.wheat },
	chicken = { "farming:seed_wheat", "farming:seed_cotton" }, -- seeds in general
}

-- Contents for replace_what
mobs_mc.replace = {
	-- Sheep eat grass
	sheep = {
		-- Grass Block
		{ "default:dirt_with_grass", "default:dirt", -1 },
		-- “Tall Grass”
		{ "default:grass_5", "air", 0 },
		{ "default:grass_4", "air", 0 },
		{ "default:grass_3", "air", 0 },
		{ "default:grass_2", "air", 0 },
		{ "default:grass_1", "air", 0 },
	},
}

--[[ Table of nodes to replace when an enderman takes it.
If the enderman takes an indexed node, it the enderman will get the item in the value.
Table indexes: Original node, taken by enderman.
Table values: The item which the enderman *actually* gets
Example:
	mobs_mc.enderman_node_replace = {
		["default:dirt_with_dry_grass"] = "default_dirt_with_grass",
	}
-- This means, if the enderman takes a dirt with dry grass, he will get a dirt with grass
-- on his hand instead.
]]
mobs_mc.enderman_replace_on_take = {} -- no replacements by default

-- A table which can be used to override block textures of blocks carried by endermen.
-- Only works for cube-shaped nodes and nodeboxes.
-- Key: itemstrings of the blocks to replace
-- Value: A table with the texture overrides (6 textures)
mobs_mc.enderman_block_texture_overrides = {
}

-- List of nodes on which mobs can spawn
mobs_mc.spawn = {
	solid = { "group:cracky", "group:crumbly", "group:shovely", "group:pickaxey" }, -- spawn on "solid" nodes (this is mostly just guessing)

	grassland = { mobs_mc.items.grass_block, "ethereal:prairie_dirt" },
	desert = { "default:desert_sand", "group:sand" },
	snow = { "default:snow", "default:snowblock", "default:dirt_with_snow" },

	-- These probably don't need overrides
	water = { mobs_mc.items.water_source, "mcl_core:water_source", "default:water_source" },
}

-- This table contains important spawn height references for the mob spawn height.
-- Please base your mob spawn height on these numbers to keep things clean.
mobs_mc.spawn_height = {
	water = tonumber(minetest.settings:get("water_level")) or 0, -- Water level in the Overworld

	-- Overworld boundaries (inclusive)
	overworld_min = -2999,
	overworld_max = 31000,
}

mobs_mc.misc = {
	shears_wear = 276, -- Wear to add per shears usage (238 uses)
	totem_fail_nodes = {} -- List of nodes in which the totem of undying fails
}

-- Item name overrides from mobs_mc_gameconfig (if present)
if minetest.get_modpath("mobs_mc_gameconfig") and mobs_mc.override then
	local tables = {"items", "follow", "replace", "spawn", "spawn_height", "misc"}
	for t=1, #tables do
		local tbl = tables[t]
		if mobs_mc.override[tbl] then
			for k, v in pairs(mobs_mc.override[tbl]) do
				mobs_mc[tbl][k] = v
			end
		end
	end

	if mobs_mc.override.enderman_takable then
		mobs_mc.enderman_takable = mobs_mc.override.enderman_takable
	end
	if mobs_mc.override.enderman_replace_on_take then
		mobs_mc.enderman_replace_on_take = mobs_mc.override.enderman_replace_on_take
	end
	if mobs_mc.enderman_block_texture_overrides then
		mobs_mc.enderman_block_texture_overrides = mobs_mc.override.enderman_block_texture_overrides
	end
end

