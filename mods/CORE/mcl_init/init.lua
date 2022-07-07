-- Some global variables (don't overwrite them!)
mcl_vars = {}

mcl_vars.redstone_tick = 0.1

--- GUI / inventory menu settings
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
-- nonbg is added as formspec prepend in mcl_formspec_prepend
mcl_vars.gui_nonbg = mcl_vars.gui_slots ..
	"style_type[image_button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[field;textcolor=#323232]"..
	"style_type[label;textcolor=#323232]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]"

-- Background stuff must be manually added by mods (no formspec prepend)
mcl_vars.gui_bg_color = "bgcolor[#00000000]"
mcl_vars.gui_bg_img = "background9[1,1;1,1;mcl_base_textures_background9.png;true;7]"

-- Legacy
mcl_vars.inventory_header = ""

-- Mapgen variables
local mg_name = minetest.get_mapgen_setting("mg_name")
local minecraft_height_limit = 256
local singlenode = mg_name == "singlenode"

-- Calculate mapgen_edge_min/mapgen_edge_max
mcl_vars.chunksize = math.max(1, tonumber(minetest.get_mapgen_setting("chunksize")) or 5)
mcl_vars.MAP_BLOCKSIZE = math.max(1, core.MAP_BLOCKSIZE or 16)
mcl_vars.mapgen_limit = math.max(1, tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000)
mcl_vars.MAX_MAP_GENERATION_LIMIT = math.max(1, core.MAX_MAP_GENERATION_LIMIT or 31000)
local central_chunk_offset = -math.floor(mcl_vars.chunksize / 2)
local chunk_size_in_nodes = mcl_vars.chunksize * mcl_vars.MAP_BLOCKSIZE
local central_chunk_min_pos = central_chunk_offset * mcl_vars.MAP_BLOCKSIZE
local central_chunk_max_pos = central_chunk_min_pos + chunk_size_in_nodes - 1
local ccfmin = central_chunk_min_pos - mcl_vars.MAP_BLOCKSIZE -- Fullminp/fullmaxp of central chunk, in nodes
local ccfmax = central_chunk_max_pos + mcl_vars.MAP_BLOCKSIZE
local mapgen_limit_b = math.floor(math.min(mcl_vars.mapgen_limit, mcl_vars.MAX_MAP_GENERATION_LIMIT) / mcl_vars.MAP_BLOCKSIZE)
local mapgen_limit_min = -mapgen_limit_b * mcl_vars.MAP_BLOCKSIZE
local mapgen_limit_max = (mapgen_limit_b + 1) * mcl_vars.MAP_BLOCKSIZE - 1
local numcmin = math.max(math.floor((ccfmin - mapgen_limit_min) / chunk_size_in_nodes), 0) -- Number of complete chunks from central chunk
local numcmax = math.max(math.floor((mapgen_limit_max - ccfmax) / chunk_size_in_nodes), 0) -- fullminp/fullmaxp to effective mapgen limits.
mcl_vars.mapgen_edge_min = central_chunk_min_pos - numcmin * chunk_size_in_nodes
mcl_vars.mapgen_edge_max = central_chunk_max_pos + numcmax * chunk_size_in_nodes

local function coordinate_to_block(x)
	return math.floor(x / mcl_vars.MAP_BLOCKSIZE)
end

local function coordinate_to_chunk(x)
	return math.floor((coordinate_to_block(x) + central_chunk_offset) / mcl_vars.chunksize)
end

function mcl_vars.pos_to_block(pos)
	return {
		x = coordinate_to_block(pos.x),
		y = coordinate_to_block(pos.y),
		z = coordinate_to_block(pos.z)
	}
end

function mcl_vars.pos_to_chunk(pos)
	return {
		x = coordinate_to_chunk(pos.x),
		y = coordinate_to_chunk(pos.y),
		z = coordinate_to_chunk(pos.z)
	}
end

local k_positive = math.ceil(mcl_vars.MAX_MAP_GENERATION_LIMIT / chunk_size_in_nodes)
local k_positive_z = k_positive * 2
local k_positive_y = k_positive_z * k_positive_z

function mcl_vars.get_chunk_number(pos) -- unsigned int
	local c = mcl_vars.pos_to_chunk(pos)
	return
		(c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		 c.x + k_positive
end

if not singlenode then
	-- Normal mode

	-- Overworld
	mcl_vars.mg_overworld_min = -62
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min + 4
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min + 10
	mcl_vars.mg_lava = true
	mcl_vars.mg_bedrock_is_rough = true

elseif singlenode then
	mcl_vars.mg_overworld_min = -66
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min
	mcl_vars.mg_lava = false
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_is_rough = false
end

mcl_vars.mg_overworld_max = mcl_vars.mapgen_edge_max

-- Use MineClone 2-style dungeons
mcl_vars.mg_dungeons = true

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())

