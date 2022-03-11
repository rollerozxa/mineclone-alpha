mcl_mapgen_core = {}
mcl_mapgen_core.registered_generators = {}

local lvm, nodes, param2 = 0, 0, 0

local generating = {} -- generating chunks
local chunks = {} -- intervals of chunks generated
local function add_chunk(pos)
	local n = mcl_vars.get_chunk_number(pos) -- unsigned int
	local prev
	for i, d in pairs(chunks) do
		if n <= d[2] then -- we've found it
			if (n == d[2]) or (n >= d[1]) then return end -- already here
			if n == d[1]-1 then -- right before:
				if prev and (prev[2] == n-1) then
					prev[2] = d[2]
					table.remove(chunks, i)
					return
				end
				d[1] = n
				return
			end
			if prev and (prev[2] == n-1) then --join to previous
				prev[2] = n
				return
			end
			table.insert(chunks, i, {n, n}) -- insert new interval before i
			return
		end
		prev = d
	end
	chunks[#chunks] = {n, n}
end
function mcl_mapgen_core.is_generated(pos)
	local n = mcl_vars.get_chunk_number(pos) -- unsigned int
	for i, d in pairs(chunks) do
		if n <= d[2] then
			return (n >= d[1])
		end
	end
	return false
end

--
-- Aliases for map generator outputs
--

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "mcl_core:stone")
minetest.register_alias("mapgen_tree", "mcl_core:tree")
minetest.register_alias("mapgen_leaves", "mcl_core:leaves")
minetest.register_alias("mapgen_jungletree", "mcl_core:jungletree")
minetest.register_alias("mapgen_jungleleaves", "mcl_core:jungleleaves")
minetest.register_alias("mapgen_pine_tree", "mcl_core:sprucetree")
minetest.register_alias("mapgen_pine_needles", "mcl_core:spruceleaves")

minetest.register_alias("mapgen_apple", "mcl_core:leaves")
minetest.register_alias("mapgen_water_source", "mcl_core:water_source")
minetest.register_alias("mapgen_dirt", "mcl_core:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "mcl_core:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "mcl_core:dirt_with_grass_snow")
minetest.register_alias("mapgen_sand", "mcl_core:sand")
minetest.register_alias("mapgen_gravel", "mcl_core:gravel")
minetest.register_alias("mapgen_clay", "mcl_core:clay")
minetest.register_alias("mapgen_lava_source", "air") -- Built-in lava generator is too unpredictable, we generate lava on our own
minetest.register_alias("mapgen_cobble", "mcl_core:cobble")
minetest.register_alias("mapgen_mossycobble", "mcl_core:mossycobble")
minetest.register_alias("mapgen_junglegrass", "mcl_flowers:fern")
minetest.register_alias("mapgen_stone_with_coal", "mcl_core:stone_with_coal")
minetest.register_alias("mapgen_stone_with_iron", "mcl_core:stone_with_iron")
minetest.register_alias("mapgen_desert_sand", "mcl_core:sand")
minetest.register_alias("mapgen_desert_stone", "mcl_core:sandstone")
minetest.register_alias("mapgen_sandstone", "mcl_core:sandstone")
if minetest.get_modpath("mclx_core") then
	minetest.register_alias("mapgen_river_water_source", "mclx_core:river_water_source")
else
	minetest.register_alias("mapgen_river_water_source", "mcl_core:water_source")
end
minetest.register_alias("mapgen_snow", "mcl_core:snow")
minetest.register_alias("mapgen_snowblock", "mcl_core:snowblock")
minetest.register_alias("mapgen_ice", "mcl_core:ice")

minetest.register_alias("mapgen_stair_cobble", "mcl_stairs:stair_cobble")

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

local WITCH_HUT_HEIGHT = 3 -- Exact Y level to spawn witch huts at. This height refers to the height of the floor

-- Content IDs
local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
local c_obsidian = minetest.get_content_id("mcl_core:obsidian")
local c_stone = minetest.get_content_id("mcl_core:stone")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_dirt_with_grass = minetest.get_content_id("mcl_core:dirt_with_grass")
local c_dirt_with_grass_snow = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
local c_sand = minetest.get_content_id("mcl_core:sand")
local c_void = minetest.get_content_id("mcl_core:void")
local c_lava = minetest.get_content_id("mcl_core:lava_source")
local c_water = minetest.get_content_id("mcl_core:water_source")
local c_top_snow = minetest.get_content_id("mcl_core:snow")
local c_snow_block = minetest.get_content_id("mcl_core:snowblock")
local c_clay = minetest.get_content_id("mcl_core:clay")
local c_leaves = minetest.get_content_id("mcl_core:leaves")
local c_air = minetest.CONTENT_AIR

--
-- Ore generation
--

local stonelike = {"mcl_core:stone"}

-- Dirt
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:dirt",
	wherein        = stonelike,
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_vars.mg_overworld_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:gravel",
	wherein        = stonelike,
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_worlds.layer_to_y(111),
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

if minetest.settings:get_bool("mcl_generate_ores", true) then
	--
	-- Coal
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 525*3,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 510*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 12,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})

	-- Medium-rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 550*3,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 525*3,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 600*3,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 550*3,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})

	--
	-- Iron
	--
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_iron",
		wherein         = stonelike,
		clust_scarcity = 830,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(39),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_iron",
		wherein         = stonelike,
		clust_scarcity = 1660,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(40),
		y_max          = mcl_worlds.layer_to_y(63),
	})

	--
	-- Gold
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 4775,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(30),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 6560,
		clust_num_ores = 7,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(30),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 13000,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(31),
		y_max          = mcl_worlds.layer_to_y(33),
	})

	--
	-- Diamond
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 5000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 20000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 20000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})

	--
	-- Redstone
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 500,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(13),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 800,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(13),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 1000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 1600,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})

end

if not superflat then
-- Water and lava springs (single blocks of lava/water source)
-- Water appears at nearly every height, but not near the bottom
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:water_source",
	wherein         = {"mcl_core:stone", "mcl_core:dirt"},
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(5),
	y_max          = mcl_worlds.layer_to_y(128),
})

-- Lava springs are rather common at -31 and below
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(1),
	y_max          = mcl_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(11),
	y_max          = mcl_worlds.layer_to_y(31),
})

-- Lava springs will become gradually rarer with increasing height
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 32000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(32),
	y_max          = mcl_worlds.layer_to_y(47),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 72000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(48),
	y_max          = mcl_worlds.layer_to_y(61),
})

-- Lava may even appear above surface, but this is very rare
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 96000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(62),
	y_max          = mcl_worlds.layer_to_y(127),
})
end

local function register_mgv6_decorations()

	-- Cacti
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.012,
			scale = 0.024,
			spread = {x = 100, y = 100, z = 100},
			seed = 257,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:cactus",
		height = 1,
		height_max = 3,
	})

	-- Sugar canes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			seed = 465,
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

	local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
	local mseeds = { 7133, 8244 }
	for m=1, #mushrooms do
		-- Mushrooms next to trees
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone"},
			sidelen = 16,
			noise_params = {
				offset = 0.04,
				scale = 0.04,
				spread = {x = 100, y = 100, z = 100},
				seed = mseeds[m],
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			spawn_by = { "mcl_core:tree" },
			num_spawn_by = 1,
		})
	end

	local function register_mgv6_flower(name, seed, offset, y_max)
		if offset == nil then
			offset = 0
		end
		if y_max == nil then
			y_max = mcl_vars.mg_overworld_max
		end
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow"},
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = 0.006,
				spread = {x = 100, y = 100, z = 100},
				seed = seed,
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = y_max,
			decoration = "mcl_flowers:"..name,
		})
	end

	register_mgv6_flower("dandelion", 8)

	register_mgv6_flower("poppy", 9439)

	-- Put top snow on snowy grass blocks. The v6 mapgen does not generate the top snow on its own.
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_snow"},
		sidelen = 16,
		fill_ratio = 11.0, -- complete coverage
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:snow",
	})

end

local mg_flags = minetest.settings:get_flags("mg_flags")

-- Inform other mods of dungeon setting for MCL2-style dungeons
mcl_vars.mg_dungeons = mg_flags.dungeons and not superflat

-- Disable builtin dungeons, we provide our own dungeons
mg_flags.dungeons = false

-- Apply mapgen-specific mapgen code
if mg_name == "v6" then
	register_mgv6_decorations()
elseif superflat then
	-- Enforce superflat-like mapgen: no caves, decor, lakes and hills
	mg_flags.caves = false
	mg_flags.decorations = false
	minetest.set_mapgen_setting("mgflat_spflags", "nolakes,nohills", true)
end

local mg_flags_str = ""
for k,v in pairs(mg_flags) do
	if v == false then
		k = "no" .. k
	end
	mg_flags_str = mg_flags_str .. k .. ","
end
if string.len(mg_flags_str) > 0 then
	mg_flags_str = string.sub(mg_flags_str, 1, string.len(mg_flags_str)-1)
end
minetest.set_mapgen_setting("mg_flags", mg_flags_str, true)

-- Helper function for converting a MC probability to MT, with
-- regards to MapBlocks.
-- Some MC generated structures are generated on per-chunk
-- probability.
-- The MC probability is 1/x per Minecraft chunk (16×16).

-- x: The MC probability is 1/x.
-- minp, maxp: MapBlock limits
-- returns: Probability (1/return_value) for a single MT mapblock
local function minecraft_chunk_probability(x, minp, maxp)
	-- 256 is the MC chunk height
	return x * (((maxp.x-minp.x+1)*(maxp.z-minp.z+1)) / 256)
end

-- Takes an index of a biomemap table (from minetest.get_mapgen_object),
-- minp and maxp (from an on_generated callback) and returns the real world coordinates
-- as X, Z.
-- Inverse function of xz_to_biomemap
local biomemap_to_xz = function(index, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local x = ((index-1) % xwidth) + minp.x
	local z = ((index-1) / zwidth) + minp.z
	return x, z
end

-- Takes x and z coordinates and minp and maxp of a generated chunk
-- (in on_generated callback) and returns a biomemap index)
-- Inverse function of biomemap_to_xz
local xz_to_biomemap_index = function(x, z, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local minix = x % xwidth
	local miniz = z % zwidth

	return (minix + miniz * zwidth) + 1
end

-- Perlin noise objects
local perlin_structures
local perlin_vines, perlin_vines_fine, perlin_vines_upwards, perlin_vines_length, perlin_vines_density
local perlin_clay

local function generate_clay(minp, maxp, blockseed, voxelmanip_data, voxelmanip_area, lvm_used)
	-- TODO: Make clay generation reproducible for same seed.
	if maxp.y < -5 or minp.y > 0 then
		return lvm_used
	end

	local pr = PseudoRandom(blockseed)

	perlin_clay = perlin_clay or minetest.get_perlin({
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = -316,
		octaves = 1,
		persist = 0.0
	})

	for y=math.max(minp.y, 0), math.min(maxp.y, -8), -1 do
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0+1,divs-2 do
		for divz=0+1,divs-2 do
			-- Get position and shift it a bit randomly so the clay do not obviously appear in a grid
			local cx = minp.x + math.floor((divx+0.5)*divlen) + pr:next(-1,1)
			local cz = minp.z + math.floor((divz+0.5)*divlen) + pr:next(-1,1)

			local water_pos = voxelmanip_area:index(cx, y+1, cz)
			local waternode = voxelmanip_data[water_pos]
			local surface_pos = voxelmanip_area:index(cx, y, cz)
			local surfacenode = voxelmanip_data[surface_pos]

			local genrnd = pr:next(1, 20)
			if genrnd == 1 and perlin_clay:get_3d({x=cx,y=y,z=cz}) > 0 and waternode == c_water and
					(surfacenode == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(surfacenode), "sand") == 1) then
				local diamondsize = pr:next(1, 3)
				for x1 = -diamondsize, diamondsize do
				for z1 = -(diamondsize - math.abs(x1)), diamondsize - math.abs(x1) do
					local ccpos = voxelmanip_area:index(cx+x1, y, cz+z1)
					local claycandidate = voxelmanip_data[ccpos]
					if voxelmanip_data[ccpos] == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(claycandidate), "sand") == 1 then
						voxelmanip_data[ccpos] = c_clay
						lvm_used = true
					end
				end
				end
			end
		end
		end
	end
	return lvm_used
end

-- TODO: Try to use more efficient structure generating code
local function generate_structures(minp, maxp, blockseed, biomemap)
	local chunk_has_desert_well = false
	local chunk_has_desert_temple = false
	local chunk_has_igloo = false
	local struct_min, struct_max = -3, 111 --64

	if maxp.y >= struct_min and minp.y <= struct_max then
		-- Generate structures
		local pr = PcgRandom(blockseed)
		perlin_structures = perlin_structures or minetest.get_perlin(329, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 5
		for x0 = minp.x, maxp.x, divlen do for z0 = minp.z, maxp.z, divlen do
			-- Determine amount from perlin noise
			local amount = math.floor(perlin_structures:get_2d({x=x0, y=z0}) * 9)
			-- Find random positions based on this random
			local p, ground_y
			for i=0, amount do
				p = {x = pr:next(x0, x0+divlen-1), y = 0, z = pr:next(z0, z0+divlen-1)}
				-- Find ground level
				ground_y = nil
				local nn
				for y = struct_max, struct_min, -1 do
					p.y = y
					local checknode = minetest.get_node(p)
					if checknode then
						nn = checknode.name
						local def = minetest.registered_nodes[nn]
						if def and def.walkable then
							ground_y = y
							break
						end
					end
				end

				if ground_y then
					p.y = ground_y+1
					local nn0 = minetest.get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn0] and minetest.registered_nodes[nn0].buildable_to then

					end
				end

			end
		end end
	end
end

-- Buffers for LuaVoxelManip
-- local lvm_buffer = {}
-- local lvm_buffer_param2 = {}

-- Generate tree decorations in the bounding box. This adds:
-- * Cocoa at jungle trees
-- * Jungle tree vines
-- * Oak vines in swamplands
local function generate_tree_decorations(minp, maxp, seed, data, param2_data, area, biomemap, lvm_used, pr)
	if maxp.y < 0 then
		return lvm_used
	end

	local oaktree, oakleaves, jungletree, jungleleaves = {}, {}, {}, {}
	local swampland = minetest.get_biome_id("Swampland")
	local swampland_shore = minetest.get_biome_id("Swampland_shore")
	local jungle = minetest.get_biome_id("Jungle")
	local jungle_shore = minetest.get_biome_id("Jungle_shore")
	local jungle_m = minetest.get_biome_id("JungleM")
	local jungle_m_shore = minetest.get_biome_id("JungleM_shore")
	local jungle_edge = minetest.get_biome_id("JungleEdge")
	local jungle_edge_shore = minetest.get_biome_id("JungleEdge_shore")
	local jungle_edge_m = minetest.get_biome_id("JungleEdgeM")
	local jungle_edge_m_shore = minetest.get_biome_id("JungleEdgeM_shore")

	-- Modifier for Jungle M biome: More vines and cocoas
	local dense_vegetation = false

	if biomemap then
		-- Biome map available: Check if the required biome (jungle or swampland)
		-- is in this mapchunk. We are only interested in trees in the correct biome.
		-- The nodes are added if the correct biome is *anywhere* in the mapchunk.
		-- TODO: Strictly generate vines in the correct biomes only.
		local swamp_biome_found, jungle_biome_found = false, false
		for b=1, #biomemap do
			local id = biomemap[b]

			if not swamp_biome_found and (id == swampland or id == swampland_shore) then
				oaktree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:tree"})
				oakleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:leaves"})
				swamp_biome_found = true
			end
			if not jungle_biome_found and (id == jungle or id == jungle_shore or id == jungle_m or id == jungle_m_shore or id == jungle_edge or id == jungle_edge_shore or id == jungle_edge_m or id == jungle_edge_m_shore) then
				jungletree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
				jungleleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
				jungle_biome_found = true
			end
			if not dense_vegetation and (id == jungle_m or id == jungle_m_shore) then
				dense_vegetation = true
			end
			if swamp_biome_found and jungle_biome_found and dense_vegetation then
				break
			end
		end
	else
		-- If there is no biome map, we just count all jungle things we can find.
		-- Oak vines will not be generated.
		jungletree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
		jungleleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
	end

	local pos, treepos, dir


	-- Pass 2: Generate vines at jungle wood, jungle leaves in jungle and oak wood, oak leaves in swampland
	perlin_vines = perlin_vines or minetest.get_perlin(555, 4, 0.6, 500)
	perlin_vines_fine = perlin_vines_fine or minetest.get_perlin(43000, 3, 0.6, 1)
	perlin_vines_length = perlin_vines_length or minetest.get_perlin(435, 4, 0.6, 75)
	perlin_vines_upwards = perlin_vines_upwards or minetest.get_perlin(436, 3, 0.6, 10)
	perlin_vines_density = perlin_vines_density or minetest.get_perlin(436, 3, 0.6, 500)

	-- Extra long vines in Jungle M
	local maxvinelength = 7
	if dense_vegetation then
		maxvinelength = 14
	end
	local treething
	for i=1, 4 do
		if i==1 then
			treething = jungletree
		elseif i == 2 then
			treething = jungleleaves
		elseif i == 3 then
			treething = oaktree
		elseif i == 4 then
			treething = oakleaves
		end

		for n = 1, #treething do
			pos = treething[n]

			treepos = table.copy(pos)

			local dirs = {
				{x=1,y=0,z=0},
				{x=-1,y=0,z=0},
				{x=0,y=0,z=1},
				{x=0,y=0,z=-1},
			}

			for d = 1, #dirs do
			local pos = vector.add(pos, dirs[d])
			local p_pos = area:index(pos.x, pos.y, pos.z)

			local vine_threshold = math.max(0.33333, perlin_vines_density:get_2d(pos))
			if dense_vegetation then
				vine_threshold = vine_threshold * (2/3)
			end

			if perlin_vines:get_2d(pos) > -1.0 and perlin_vines_fine:get_3d(pos) > vine_threshold and data[p_pos] == c_air then

				local rdir = {}
				rdir.x = -dirs[d].x
				rdir.y = dirs[d].y
				rdir.z = -dirs[d].z
				local param2 = minetest.dir_to_wallmounted(rdir)

				-- Determine growth direction
				local grow_upwards = false
				-- Only possible on the wood, not on the leaves
				if i == 1 then
					grow_upwards = perlin_vines_upwards:get_3d(pos) > 0.8
				end
				if grow_upwards then
					-- Grow vines up 1-4 nodes, even through jungleleaves.
					-- This may give climbing access all the way to the top of the tree :-)
					-- But this will be fairly rare.
					local length = math.ceil(math.abs(perlin_vines_length:get_3d(pos)) * 4)
					for l=0, length-1 do
						local t_pos = area:index(treepos.x, treepos.y, treepos.z)

						if (data[p_pos] == c_air or data[p_pos] == c_jungleleaves or data[p_pos] == c_leaves) and mcl_core.supports_vines(minetest.get_name_from_content_id(data[t_pos])) then
							data[p_pos] = c_vine
							param2_data[p_pos] = param2
							lvm_used = true

						else
							break
						end
						pos.y = pos.y + 1
						p_pos = area:index(pos.x, pos.y, pos.z)
						treepos.y = treepos.y + 1
					end
				else
					-- Grow vines down, length between 1 and maxvinelength
					local length = math.ceil(math.abs(perlin_vines_length:get_3d(pos)) * maxvinelength)
					for l=0, length-1 do
						if data[p_pos] == c_air then
							data[p_pos] = c_vine
							param2_data[p_pos] = param2
							lvm_used = true

						else
							break
						end
						pos.y = pos.y - 1
						p_pos = area:index(pos.x, pos.y, pos.z)
					end
				end
			end
			end

		end
	end
	return lvm_used
end

-- Generate mushrooms in caves manually.
-- Minetest's API does not support decorations in caves yet. :-(
local generate_underground_mushrooms = function(minp, maxp, seed)
	-- Generate rare underground mushrooms
	-- TODO: Make them appear in groups, use Perlin noise
	local min, max = mcl_vars.mg_lava_overworld_max + 4, 0
	if minp.y > max or maxp.y < min then
		return
	end

	local pr_shroom = PseudoRandom(seed)
	local bpos
	local stone = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_core:stone", "mcl_core:dirt", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:stone_with_coal", "mcl_core:stone_with_iron", "mcl_core:stone_with_gold"})

	for n = 1, #stone do
		bpos = {x = stone[n].x, y = stone[n].y + 1, z = stone[n].z }

		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y >= min and bpos.y <= max and l ~= nil and l <= 12 and pr_shroom:next(1,1000) < 4 then
			if pr_shroom:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	add_chunk(minp)
	local p1, p2 = {x=minp.x, y=minp.y, z=minp.z}, {x=maxp.x, y=maxp.y, z=maxp.z}
	if lvm > 0 then
		local lvm_used, shadow = false, false
		local lb = {} -- buffer
		local lb2 = {} -- param2
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local e1, e2 = {x=emin.x, y=emin.y, z=emin.z}, {x=emax.x, y=emax.y, z=emax.z}
		local data2
		local data = vm:get_data(lb)
		if param2 > 0 then
			data2 = vm:get_param2_data(lb2)
		end
		local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})

		for _, rec in pairs(mcl_mapgen_core.registered_generators) do
			if rec.vf then
				local lvm_used0, shadow0 = rec.vf(vm, data, data2, e1, e2, area, p1, p2, blockseed)
				if lvm_used0 then
					lvm_used = true
				end
				if shadow0 then
					shadow = true
				end
			end
		end

		if lvm_used then
			-- Write stuff
			vm:set_data(data)
			if param2 > 0 then
				vm:set_param2_data(data2)
			end
			vm:calc_lighting(p1, p2, shadow)
			vm:write_to_map()
			vm:update_liquids()
		end
	end

	if nodes > 0 then
		for _, rec in pairs(mcl_mapgen_core.registered_generators) do
			if rec.nf then
				rec.nf(p1, p2, blockseed)
			end
		end
	end

--	add_chunk(minp)
end)

minetest.register_on_generated=function(node_function)
	mcl_mapgen_core.register_generator("mod_"..tostring(#mcl_mapgen_core.registered_generators+1), nil, node_function)
end

function mcl_mapgen_core.register_generator(id, lvm_function, node_function, priority, needs_param2)
	if not id then return end

	local priority = priority or 5000

	if lvm_function then lvm = lvm + 1 end
	if lvm_function then nodes = nodes + 1 end
	if needs_param2 then param2 = param2 + 1 end

	local new_record = {
		i = priority,
		vf = lvm_function,
		nf = node_function,
		needs_param2 = needs_param2,
	}

	mcl_mapgen_core.registered_generators[id] = new_record
	table.sort(
		mcl_mapgen_core.registered_generators,
		function(a, b)
			return (a.i < b.i) or ((a.i == b.i) and (a.vf ~= nil) and (b.vf == nil))
		end)
end

function mcl_mapgen_core.unregister_generator(id)
	if not mcl_mapgen_core.registered_generators[id] then return end
	local rec = mcl_mapgen_core.registered_generators[id]
	mcl_mapgen_core.registered_generators[id] = nil
	if rec.vf then lvm = lvm - 1 end
	if rev.nf then nodes = nodes - 1 end
	if rec.needs_param2 then param2 = param2 - 1 end
	if rec.needs_level0 then level0 = level0 - 1 end
end

-- Generate basic layer-based nodes: void, bedrock, realm barrier, lava seas, etc.
-- Also perform some basic node replacements.

local bedrock_check
if mcl_vars.mg_bedrock_is_rough then
	bedrock_check = function(pos, _, pr)
		local y = pos.y
		-- Bedrock layers with increasing levels of roughness, until a perfecly flat bedrock later at the bottom layer
		-- This code assumes a bedrock height of 5 layers.

		local diff = mcl_vars.mg_bedrock_overworld_max - y -- Overworld bedrock

		local top
		if diff == 0 then
			-- 50% bedrock chance
			top = 2
		elseif diff == 1 then
			-- 66.666...%
			top = 3
		elseif diff == 2 then
			-- 75%
			top = 4
		elseif diff == 3 then
			-- 90%
			top = 10
		elseif diff == 4 then
			-- 100%
			return true
		else
			-- Not in bedrock layer
			return false
		end

		return pr:next(1, top) <= top-1
	end
end


-- Helper function to set all nodes in the layers between min and max.
-- content_id: Node to set
-- check: optional.
--	If content_id, node will be set only if it is equal to check.
--	If function(pos_to_check, content_id_at_this_pos), will set node only if returns true.
-- min, max: Minimum and maximum Y levels of the layers to set
-- minp, maxp: minp, maxp of the on_generated
-- lvm_used: Set to true if any node in this on_generated has been set before.
--
-- returns true if any node was set and lvm_used otherwise
local function set_layers(data, area, content_id, check, min, max, minp, maxp, lvm_used, pr)
	if (maxp.y >= min and minp.y <= max) then
		for y = math.max(min, minp.y), math.min(max, maxp.y) do
			for x = minp.x, maxp.x do
				for z = minp.z, maxp.z do
					local p_pos = area:index(x, y, z)
					if check then
						if type(check) == "function" and check({x=x,y=y,z=z}, data[p_pos], pr) then
							data[p_pos] = content_id
							lvm_used = true
						elseif check == data[p_pos] then
							data[p_pos] = content_id
							lvm_used = true
						end
					else
						data[p_pos] = content_id
						lvm_used = true
					end
				end
			end
		end
	end
	return lvm_used
end

-- Below the bedrock, generate air/void
local function basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local biomemap, ymin, ymax
	local lvm_used = false
	local pr = PseudoRandom(blockseed)

	if mg_name ~= "singlenode" then
		-- Bedrock
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_overworld_min, mcl_vars.mg_bedrock_overworld_max, minp, maxp, lvm_used, pr)

		-- Big lava seas by replacing air below a certain height
		if mcl_vars.mg_lava then
			--lvm_used = set_layers(data, area, c_lava, c_air, mcl_vars.mg_overworld_min, mcl_vars.mg_lava_overworld_max, emin, emax, lvm_used, pr)
		end

		-- Clay, vines, cocoas
		lvm_used = generate_clay(minp, maxp, blockseed, data, area, lvm_used)

		biomemap = minetest.get_mapgen_object("biomemap")
		lvm_used = generate_tree_decorations(minp, maxp, blockseed, data, data2, area, biomemap, lvm_used, pr)

		----- Interactive block fixing section -----
		----- The section to perform basic block overrides of the core mapgen generated world. -----

		-- Snow and sand fixes. This code implements snow consistency
		-- and fixes floating sand and cut plants.
		-- A snowy grass block must be below a top snow or snow block at all times.
		if emin.y <= mcl_vars.mg_overworld_max and emax.y >= mcl_vars.mg_overworld_min then
			-- v6 mapgen:
			if mg_name == "v6" then

				--[[ Remove broken double plants caused by v6 weirdness.
				v6 might break the bottom part of double plants because of how it works.
				There are 3 possibilities:
				1) Jungle: Top part is placed on top of a jungle tree or fern (=v6 jungle grass).
					This is because the schematic might be placed even if some nodes of it
					could not be placed because the destination was already occupied.
					TODO: A better fix for this would be if schematics could abort placement
					altogether if ANY of their nodes could not be placed.
				2) Cavegen: Removes the bottom part, the upper part floats
				3) Mudflow: Same as 2) ]]
				local plants = minetest.find_nodes_in_area(emin, emax, "group:double_plant")
				for n = 1, #plants do
					local node = vm:get_node_at(plants[n])
					local is_top = minetest.get_item_group(node.name, "double_plant") == 2
					if is_top then
						local p_pos = area:index(plants[n].x, plants[n].y-1, plants[n].z)
						if p_pos then
							node = vm:get_node_at({x=plants[n].x, y=plants[n].y-1, z=plants[n].z})
							local is_bottom = minetest.get_item_group(node.name, "double_plant") == 1
							if not is_bottom then
								p_pos = area:index(plants[n].x, plants[n].y, plants[n].z)
								data[p_pos] = c_air
								lvm_used = true
							end
						end
					end
				end


			-- Non-v6 mapgens:
			else
				-- Set param2 (=color) of grass blocks.
				-- Clear snowy grass blocks without snow above to ensure consistency.
				local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"})

				-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
				local aream = VoxelArea:new({MinEdge={x=minp.x, y=0, z=minp.z}, MaxEdge={x=maxp.x, y=0, z=maxp.z}})
				for n=1, #nodes do
					local n = nodes[n]
					local p_pos = area:index(n.x, n.y, n.z)
					local p_pos_above = area:index(n.x, n.y+1, n.z)
					local p_pos_below = area:index(n.x, n.y-1, n.z)
					local b_pos = aream:index(n.x, 0, n.z)
					local bn = minetest.get_biome_name(biomemap[b_pos])
					if bn then
						local biome = minetest.registered_biomes[bn]
						if biome and biome._mcl_biome_type then
							data2[p_pos] = biome._mcl_palette_index
							lvm_used = true
						end
					end
					if data[p_pos] == c_dirt_with_grass_snow and p_pos_above and data[p_pos_above] ~= c_top_snow and data[p_pos_above] ~= c_snow_block then
						data[p_pos] = c_dirt_with_grass
						lvm_used = true
					end
				end

			end
		end
	end

	local shadow = true

	return lvm_used, shadow
end

local function basic_node(minp, maxp, blockseed)
	if mg_name ~= "singlenode" then
		-- Generate special decorations
		generate_underground_mushrooms(minp, maxp, blockseed)
		generate_structures(minp, maxp, blockseed, minetest.get_mapgen_object("biomemap"))
	end
end

mcl_mapgen_core.register_generator("main", basic, basic_node, 1, true)

-- "Trivial" (actually NOT) function to just read the node and some stuff to not just return "ignore", like 5.3.0 does.
-- p: Position, if it's wrong, {name="error"} node will return.
-- force: optional (default: false) - Do the maximum to still read the node within us_timeout.
-- us_timeout: optional (default: 244 = 0.000244 s = 1/80/80/80), set it at least to 3000000 to let mapgen to finish its job.
--
-- returns node definition, eg. {name="air"}. Unfortunately still can return {name="ignore"}.
function mcl_mapgen_core.get_node(p, force, us_timeout)
	-- check initial circumstances
	if not p or not p.x or not p.y or not p.z then return {name="error"} end

	-- try common way
	local node = minetest.get_node(p)
	if node.name ~= "ignore" then
		return node
	end

	-- copy table to get sure it won't changed by other threads
	local pos = {x=p.x,y=p.y,z=p.z}

	-- try LVM
	minetest.get_voxel_manip():read_from_map(pos, pos)
	node = minetest.get_node(pos)
	if node.name ~= "ignore" or not force then
		return node
	end

	-- all ways failed - need to emerge (or forceload if generated)
	local us_timeout = us_timeout or 244
	if mcl_mapgen_core.is_generated(pos) then
		minetest.forceload_block(pos)
	else
		minetest.emerge_area(pos, pos)
	end

	local t = minetest.get_us_time()

	node = minetest.get_node(pos)

	while (not node or node.name == "ignore") and (minetest.get_us_time() - t < us_timeout) do
		node = minetest.get_node(pos)
	end

	return node
	-- it still can return "ignore", LOL, even if force = true, but only after time out
end
