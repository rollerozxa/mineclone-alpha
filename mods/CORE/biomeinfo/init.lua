biomeinfo = {}

-- Copied from mapgen_v6.h
local MGV6_FREQ_HOT = 0.4
local MGV6_FREQ_SNOW = -0.4
local MGV6_FREQ_TAIGA = 0.5
local MGV6_FREQ_JUNGLE = 0.5

-- Biome types
local BT_NORMAL = "Normal"
local BT_TUNDRA = "Tundra"
local BT_TAIGA = "Taiga"
local BT_DESERT = "Desert"
local BT_JUNGLE = "Jungle"

-- Get mapgen settings

local seed = tonumber(minetest.get_mapgen_setting("seed")) or 0

local mgv6_perlin_biome, mgv6_perlin_humidity, mgv6_np_biome

-- v6 default noiseparams are hardcoded here because Minetest doesn't give us those
local mgv6_np_biome_default = {
	offset = 0,
	scale = 1,
	spread = { x = 500, y = 500, z = 500},
	seed = 9130,
	octaves = 3,
	persistence = 0.50,
	lacunarity = 2.0,
	flags = "eased",
}
local mgv6_np_humidity_default = {
	offset = 0.5,
	scale = 0.5,
	spread = { x = 500, y = 500, z = 500},
	seed = 72384,
	octaves = 3,
	persistence = 0.50,
	lacunarity = 2.0,
	flags = "eased",
}

local v6_flags_str = minetest.get_mapgen_setting("mgv6_spflags")
if v6_flags_str == nil then
	v6_flags_str = ""
end
local v6_flags = string.split(v6_flags_str)
local v6_use_snow_biomes = true
local v6_use_jungles = true
-- TODO: Implement biome blend.
-- Currently we pretend biome blend is disabled.
-- This just makes the calculations inaccurate near biome boundaries,
-- but should be fine otherwise.
local v6_use_biome_blend = false
for f=1, #v6_flags do
	local flag = v6_flags[f]:trim()
	if flag == "nosnowbiomes" then
		v6_use_snow_biomes = false
	end
	if flag == "snowbiomes" then
		v6_use_snow_biomes = true
	end
	if flag == "nojungles" then
		v6_use_jungles = false
	end
	if flag == "jungles" then
		v6_use_jungles = true
	end
	if flag == "nobiomeblend" then
		v6_use_biome_blend = false
	end
-- TODO
--	if flag == "biomeblend" then
--		v6_use_biome_blend = true
--	end
end
-- Force-enable jungles when snowbiomes flag is set
if v6_use_snow_biomes then
	v6_use_jungles = true
end
local v6_freq_desert = tonumber(minetest.get_mapgen_setting("mgv6_freq_desert") or 0.45)

local noise2d = function(x, y, seed)
	-- TODO: implement noise2d function for biome blend
	return 0
end

biomeinfo.all_v6_biomes = {
	BT_NORMAL,
	BT_DESERT,
	BT_JUNGLE,
	BT_TUNDRA,
	BT_TAIGA
}

local function init_perlins()
	if not mgv6_perlin_biome then
		mgv6_np_biome = minetest.get_mapgen_setting_noiseparams("mgv6_np_biome")
		if not mgv6_np_biome then
			mgv6_np_biome = mgv6_np_biome_default
			minetest.log("action", "[biomeinfo] Using hardcoded mgv6_np_biome default")
		end
		mgv6_perlin_biome = minetest.get_perlin(mgv6_np_biome)
	end
	if not mgv6_perlin_humidity then
		local np_humidity = minetest.get_mapgen_setting_noiseparams("mgv6_np_humidity")
		if not np_humidity then
			np_humidity = mgv6_np_humidity_default
			minetest.log("action", "[biomeinfo] Using hardcoded mgv6_np_humidity default")
		end
		mgv6_perlin_humidity = minetest.get_perlin(np_humidity)
	end
end

function biomeinfo.get_active_v6_biomes()
	local biomes = { BT_NORMAL, BT_DESERT }
	if v6_use_jungles then
		table.insert(biomes, BT_JUNGLE)
	end
	if v6_use_snow_biomes then
		table.insert(biomes, BT_TUNDRA)
		table.insert(biomes, BT_TAIGA)
	end
	return biomes
end

function biomeinfo.get_v6_heat(pos)
	init_perlins()
	if not mgv6_perlin_biome then
		return nil
	end
	local bpos = vector.floor(pos)
	-- The temperature noise needs a special offset (see calculateNoise in mapgen_v6.cpp)
	return mgv6_perlin_biome:get_2d({x=bpos.x + mgv6_np_biome.spread.x*0.6, y=bpos.z + mgv6_np_biome.spread.z*0.2})
end

function biomeinfo.get_v6_humidity(pos)
	init_perlins()
	if not mgv6_perlin_humidity then
		return nil
	end
	local bpos = vector.floor(pos)
	return mgv6_perlin_humidity:get_2d({x=bpos.x, y=bpos.z})
end

-- Returns the v6 biome at pos.
-- Returns a string representing the biome name.
function biomeinfo.get_v6_biome(pos)
	init_perlins()
	local bpos = vector.floor(pos)
	-- Based on the algorithm MapgenV6::getBiome in mapgen_v6.cpp

	local pos2d = {x=bpos.x, y=bpos.z}
	if not mgv6_perlin_biome or not mgv6_perlin_humidity then
		return "???"
	end
	local d = biomeinfo.get_v6_heat(bpos)
	local h = biomeinfo.get_v6_humidity(bpos)

	if (v6_use_snow_biomes) then
		local blend
		if v6_use_biome_blend then
			blend = noise2d(pos2d.x, pos2d.y, seed) / 40
		else
			blend = 0
		end

		if (d > MGV6_FREQ_HOT + blend) then
			if (h > MGV6_FREQ_JUNGLE + blend) then
				return BT_JUNGLE
			end
			return BT_DESERT
		end
		if (d < MGV6_FREQ_SNOW + blend) then
			if (h > MGV6_FREQ_TAIGA + blend) then
				return BT_TAIGA
			end
			return BT_TUNDRA
		end
		return BT_NORMAL
	end

	if (d > v6_freq_desert) then
		return BT_DESERT
	end

	if ((v6_use_biome_blend) and (d > v6_freq_desert - 0.10) and
			((noise2d(pos2d.x, pos2d.y, seed) + 1.0) > (v6_freq_desert - d) * 20.0)) then
		return BT_DESERT
	end

	if ((v6_use_jungles) and (h > 0.75)) then
		return BT_JUNGLE
	end

	return BT_NORMAL
end


