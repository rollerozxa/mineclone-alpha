local mg_name = minetest.get_mapgen_setting("mg_name")
local mg_seed = minetest.get_mapgen_setting("seed")

-- Some mapgen settings
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

-- Jungle bush schematic. In PC/Java Edition it's Jungle Wood + Oak Leaves
local jungle_bush_schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_jungle_bush_oak_leaves.mts"

local deco_id_chorus_plant

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
	--[[ OVERWORLD ]]

	--[[ These biomes try to resemble MC as good as possible. This means especially the floor cover and
	the type of plants and structures (shapes might differ). The terrain itself will be of course different
	and depends on the mapgen.
	Important: MC also takes the terrain into account while MT biomes don't care about the terrain at all
	(except height).
	MC has many “M” and “Hills” variants, most of which only differ in terrain compared to their original
	counterpart.
	In MT, any biome can occour in any terrain, so these variants are implied and are therefore
	not explicitly implmented in MCL2. “M” variants are only included if they have another unique feature,
	such as a different land cover.
	In MCL2, the MC Overworld biomes are split in multiple more parts (stacked by height):
	* The main part, this represents the land. It begins at around sea level and usually goes all the way up
	* _ocean: For the area covered by ocean water. The y_max may vary for various beach effects.
	          Has sand or dirt as floor.
	* _deep_ocean: Like _ocean, but deeper and has gravel as floor
	* _underground:
	* Other modifiers: Some complex biomes require more layers to improve the landscape.

	The following naming conventions apply:
	* The land biome name is equal to the MC biome name, as of Minecraft 1.11 (in camel case)
	* Height modifiers and sub-biomes are appended with underscores and in lowercase. Example: “_ocean”
	* Non-MC biomes are written in lowercase
	* MC dimension biomes are named after their MC dimension

	]]

	-- List of Overworld biomes without modifiers.
	-- IMPORTANT: Don't forget to add new Overworld biomes to this list!
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
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
	})
	minetest.register_biome({
		name = "Plains_beach",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 0,
		y_max = 2,
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
		y_max = -1,
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
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
	})
	minetest.register_biome({
		name = "Forest_beach",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
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
			noise_params = {
				offset = 0.000545,
				scale = 0.0011,
				spread = {x = 250, y = 250, z = 250},
				seed = 3 + 5 * i,
				octaves = 3,
				persist = 0.66
			},
			biomes = {"Forest"},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_large_"..i..".mts",
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})

		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block", "mcl_core:dirt", },
			sidelen = 80,
			noise_params = {
				offset = -0.0007,
				scale = 0.001,
				spread = {x = 250, y = 250, z = 250},
				seed = 3,
				octaves = 3,
				persist = 0.6
			},
			biomes = {"ExtremeHills", "ExtremeHillsM", "ExtremeHills+", "ExtremeHills+_snowtop"},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_large_"..i..".mts",
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
	-- Small “classic” oak (many biomes)
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
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.01,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"FlowerForest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:dirt", },
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"ExtremeHills", "ExtremeHillsM", "ExtremeHills+", "ExtremeHills+_snowtop"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.006,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"ExtremeHills+", "ExtremeHills+_snowtop"},
		y_min = 50,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:dirt", },
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = 0.0002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"IcePlains"},
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
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})

	-- Mushrooms next to trees
	local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
	local mseeds = { 7133, 8244 }
	for m=1, #mushrooms do
		-- Mushrooms next to trees
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:stone"},
			sidelen = 16,
			noise_params = {
				offset = 0,
				scale = 0.003,
				spread = {x = 250, y = 250, z = 250},
				seed = mseeds[m],
				octaves = 3,
				persist = 0.66,
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			spawn_by = { "mcl_core:tree" },
			num_spawn_by = 1,
		})
	end
	local function register_flower(name, biomes, seed, is_in_flower_forest)
		if is_in_flower_forest == nil then
			is_in_flower_forest = true
		end
		if biomes then
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
		if is_in_flower_forest then
			minetest.register_decoration({
				deco_type = "simple",
				place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
				sidelen = 80,
				noise_params= {
					offset = 0.0008*40,
					scale = 0.003,
					spread = {x = 100, y = 100, z = 100},
					seed = seed,
					octaves = 3,
					persist = 0.6,
				},
				y_min = 1,
				y_max = mcl_vars.mg_overworld_max,
				biomes = {"FlowerForest"},
				decoration = "mcl_flowers:"..name,
			})
		end
	end

	local flower_biomes1 = {"Plains", "Forest" }

	register_flower("dandelion", flower_biomes1, 8)
	register_flower("poppy", flower_biomes1, 9439)

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

	if deco_id_chorus_plant then
		mcl_mapgen_core.register_generator("chorus_grow", nil, function(minp, maxp, blockseed)
			local gennotify = minetest.get_mapgen_object("gennotify")
			local poslist = {}
			for _, pos in ipairs(gennotify["decoration#"..deco_id_chorus_plant] or {}) do
				local realpos = { x = pos.x, y = pos.y + 1, z = pos.z }
				mcl_end.grow_chorus_plant(realpos)
			end
		end)
	end

end

