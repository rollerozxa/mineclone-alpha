local mg_name = minetest.get_mapgen_setting("mg_name")
local mg_seed = minetest.get_mapgen_setting("seed")

-- Some mapgen settings
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

--
-- Register biomes
--

local OCEAN_MIN = -15
local DEEP_OCEAN_MAX = OCEAN_MIN - 1
local DEEP_OCEAN_MIN = -31

--[[ Special biome field: _mcl_biome_type:
Rough categorization of biomes: One of "snowy", "cold", "medium" and "hot"
Based off <https://minecraft.gamepedia.com/Biomes> ]]

local function register_classic_superflat_biome()
	-- Classic Superflat: bedrock (not part of biome), 2 dirt, 1 grass block
	minetest.register_biome({
		name = "flat",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_stone = "mcl_core:dirt",
		y_min = mcl_vars.mg_overworld_min - 512,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 50,
		heat_point = 50,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
	})
end

-- All mapgens except mgv6, flat and singlenode
local function register_biomes()
	-- List of Overworld biomes without modifiers.
	local overworld_biomes = {
		"Plains",
		"Forest",
	}

	-- Plains
	minetest.register_biome({
		name = "Plains",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
	})
	minetest.register_biome({
		name = "Plains_beach",
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -2,
		y_max = 4,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
	})
	minetest.register_biome({
		name = "Plains_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -2,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
	})

	-- Forest
	minetest.register_biome({
		name = "Forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
	})
	minetest.register_biome({
		name = "Forest_beach",
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -2,
		y_max = 4,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
	})
	minetest.register_biome({
		name = "Forest_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -2,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
	})

	-- Add deep ocean and underground biomes automatically.
	for i=1, #overworld_biomes do
		local biome = overworld_biomes[i]

		-- Deep Ocean
		minetest.register_biome({
			name = biome .. "_deep_ocean",
			heat_point = minetest.registered_biomes[biome].heat_point,
			humidity_point = minetest.registered_biomes[biome].humidity_point,
			y_min = DEEP_OCEAN_MIN,
			y_max = DEEP_OCEAN_MAX,
			node_top = minetest.registered_biomes[biome.."_ocean"].node_top,
			depth_top = 2,
			node_filler = minetest.registered_biomes[biome.."_ocean"].node_filler,
			depth_filler = 3,
			node_riverbed = minetest.registered_biomes[biome.."_ocean"].node_riverbed,
			depth_riverbed = 2,
			vertical_blend = 5,
			_mcl_biome_type = minetest.registered_biomes[biome]._mcl_biome_type,
			_mcl_palette_index = minetest.registered_biomes[biome]._mcl_palette_index,
		})

		-- Underground biomes are used to identify the underground and to prevent nodes from the surface
		-- (sand, dirt) from leaking into the underground.
		minetest.register_biome({
			name = biome .. "_underground",
			heat_point = minetest.registered_biomes[biome].heat_point,
			humidity_point = minetest.registered_biomes[biome].humidity_point,
			y_min = mcl_vars.mg_overworld_min,
			y_max = DEEP_OCEAN_MIN - 1,
			_mcl_biome_type = minetest.registered_biomes[biome]._mcl_biome_type,
			_mcl_palette_index = minetest.registered_biomes[biome]._mcl_palette_index,
		})

	end
end

-- Register ores which are limited by biomes. For all mapgens except flat and singlenode.
local function register_biome_ores()
	local stonelike = {"mcl_core:stone"}

end


-- All mapgens except mgv6

-- Template to register a grass or fern decoration


local function register_decorations()

	-- Oak
	-- Large oaks
	for i=1, 4 do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
			sidelen = 80,
			fill_ratio = 0.00005,
			biomes = {"Forest"},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_large_"..i..".mts",
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})

		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
			sidelen = 80,
			fill_ratio = 0.00001,
			biomes = {"Plains"},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_large_"..i..".mts",
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
	-- Small “classic” oak
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.025,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Small “classic” oak (Plains)
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		fill_ratio = 0.001,
		biomes = {"Plains", "Plains_shore"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Rare balloon oak
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.002083,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.6,
		},
		biomes = {"Forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_balloon.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Sugar canes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 200, y = 200, z = 200},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:reeds",
		height = 2,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})

	local function register_flower(name, biomes, seed)
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
			sidelen = 16,
			noise_params = {
				offset = 0.0008,
				scale = 0.006,
				spread = {x = 100, y = 100, z = 100},
				seed = seed,
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			biomes = biomes,
			decoration = "mcl_flowers:"..name,
		})
	end

	local flower_biomes1 = {"Plains", "Forest" }

	register_flower("yellow", flower_biomes1, 8)
	register_flower("red", flower_biomes1, 9439)
end

--
-- Detect mapgen to select functions
--
if mg_name ~= "singlenode" then
	if not superflat then
		if mg_name ~= "v6" then
			register_biomes()
		end
		register_biome_ores()
		if mg_name ~= "v6" then
			register_decorations()
		end
	else
		-- Implementation of Minecraft's Superflat mapgen, classic style:
		-- * Perfectly flat land, 1 grass biome, no decorations, no caves
		-- * 4 layers, from top to bottom: grass block, dirt, dirt, bedrock
		minetest.clear_registered_biomes()
		minetest.clear_registered_decorations()
		minetest.clear_registered_schematics()
		register_classic_superflat_biome()
	end

	-- Overworld decorations for v6 are handled in mcl_mapgen_core

end

