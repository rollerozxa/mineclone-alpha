mcla_spawn = {}

local S = minetest.get_translator("mcla_spawn")
local mg_name = minetest.get_mapgen_setting("mg_name")
local storage = minetest.get_mod_storage()

-- Parameters
-------------

local respawn_search_interval = 30 -- seconds
local respawn_search_initial_delay = 30 -- seconds
local trees_distance_max = 30 -- nodes
local attempts_to_find_pos = 50
local attempts_to_find_trees = 50
local node_groups_white_list = {"group:soil"}
local biomes_white_list = {
	"Plains",
	"Forest",
}

-- Resolution of search grid in nodes.
local res = 64
local half_res = 32 -- for emerge areas around the position
local alt_min = -10
local alt_max = 200
-- Number of points checked in the square search grid (edge * edge).
local checks = 128 * 128
-- Starting point for biome checks. This also sets the y co-ordinate for all
-- points checked, so the suitable biomes must be active at this y.
local start_pos = minetest.setting_get_pos("static_spawnpoint") or {x = 0, y = 8, z = 0}
-- Table of suitable biomes
local biome_ids = {}

local no_trees_area_counter = 0

-- Bed spawning offsets
local node_search_list =
	{
	--[[1]]	{x =  0, y = 0, z = -1},	--
	--[[2]]	{x = -1, y = 0, z =  0},	--
	--[[3]]	{x = -1, y = 0, z =  1},	--
	--[[4]]	{x =  0, y = 0, z =  2},	-- z^ 8 4 9
	--[[5]]	{x =  1, y = 0, z =  1},	--  | 3   5
	--[[6]]	{x =  1, y = 0, z =  0},	--  | 2 * 6
	--[[7]]	{x = -1, y = 0, z = -1},	--  | 7 1 A
	--[[8]]	{x = -1, y = 0, z =  2},	--  +----->
	--[[9]]	{x =  1, y = 0, z =  2},	--	x
	--[[A]]	{x =  1, y = 0, z = -1},	--
	--[[B]]	{x =  0, y = 1, z =  0},	--
	--[[C]]	{x =  0, y = 1, z =  1},	--
	}

-- End of parameters
--------------------


-- Initial variables

local success = storage:get_int("mcla_spawn_success")==1
local searched = (storage:get_int("mcla_spawn_searched")==1) or mg_name == "v6" or mg_name == "singlenode" or minetest.settings:get("static_spawnpoint")
local wsp = minetest.string_to_pos(storage:get_string("mcla_spawn_world_spawn_point")) or {} -- world spawn position
local check = storage:get_int("mcla_spawn_check") or 0
local cp = minetest.string_to_pos(storage:get_string("mcla_spawn_cp")) or {x=start_pos.x, y=start_pos.y, z=start_pos.z}
local edge_len = storage:get_int("mcla_spawn_edge_len") or 1
local edge_dist = storage:get_int("mcla_spawn_edge_dist") or 0
local dir_step = storage:get_int("mcla_spawn_dir_step") or 0
local dir_ind = storage:get_int("mcla_spawn_dir_ind") or 1
local emerge_pos1, emerge_pos2

-- Get world 'mapgen_limit' and 'chunksize' to calculate 'spawn_limit'.
-- This accounts for how mapchunks are not generated if they or their shell exceed
-- 'mapgen_limit'.

local mapgen_limit = tonumber(minetest.get_mapgen_setting("mapgen_limit"))
local chunksize = tonumber(minetest.get_mapgen_setting("chunksize"))
local spawn_limit = math.max(mapgen_limit - (chunksize + 1) * 16, 0)


--Functions
-----------

local function get_far_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end
	minetest.get_voxel_manip():read_from_map(pos, pos)
	return minetest.get_node(pos)
end

local function get_trees(pos, pos2)
	if emerge_pos1 and emerge_pos2 and pos then
		if not pos2 then
			local b1 = {x = math.max(pos.x-trees_distance_max, emerge_pos1.x), y = math.max(pos.y-trees_distance_max, emerge_pos1.y), z = math.max(pos.z-trees_distance_max, emerge_pos1.z)}
			local b2 = {x = math.min(pos.x+trees_distance_max, emerge_pos2.x), y = math.min(pos.y+trees_distance_max, emerge_pos2.y), z = math.min(pos.z+trees_distance_max, emerge_pos2.z)}
			return minetest.find_nodes_in_area(b1, b2, {"group:tree"}, false)
		else
			local b1 = {x = math.max(pos.x , emerge_pos1.x), y = math.max(pos.y , emerge_pos1.y), z = math.max(pos.z,  emerge_pos1.z)}
			local b2 = {x = math.min(pos2.x, emerge_pos2.x), y = math.min(pos2.y, emerge_pos2.y), z = math.min(pos2.z, emerge_pos2.z)}
			return minetest.find_nodes_in_area(b1, b2, {"group:tree"}, false)
		end
	end
	return nil
end

local function good_for_respawn(pos, player)
	local pos0 = {x = pos.x, y = pos.y - 1, z = pos.z}
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	local pos2 = {x = pos.x, y = pos.y + 1, z = pos.z}
	local node0 = get_far_node(pos0)
	local node1 = get_far_node(pos1)
	local node2 = get_far_node(pos2)

	local nn0, nn1, nn2 = node0.name, node1.name, node2.name
	if	   minetest.get_item_group(nn0, "destroys_items") ~=0
		or minetest.get_item_group(nn1, "destroys_items") ~=0
		or minetest.get_item_group(nn2, "destroys_items") ~=0
		or minetest.is_protected(pos0, player or "")
		or minetest.is_protected(pos1, player or "")
		or minetest.is_protected(pos2, player or "")
		or (not player and minetest.get_node_light(pos1, 0.5) < 8)
		or (not player and minetest.get_node_light(pos2, 0.5) < 8)
		or nn0 == "ignore"
		or nn1 == "ignore"
		or nn2 == "ignore"
		   then
			return false
	end

	local def0 = minetest.registered_nodes[nn0]
	local def1 = minetest.registered_nodes[nn1]
	local def2 = minetest.registered_nodes[nn2]
	return def0.walkable and (not def1.walkable) and (not def2.walkable) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0)
end

local function can_find_tree(pos1, trees)
	if not emerge_pos1 or not emerge_pos2 then return false end
	local trees = trees or get_trees(pos1)
	if not trees then return false end

	if (attempts_to_find_trees * 3 < #trees) then
		-- random search
		for i = 1, attempts_to_find_trees do
			local pos2 = trees[math.random(1,#trees)]
			if not minetest.is_protected(pos2, "") then
				if pos2.x < pos1.x then
					pos2.x = pos2.x + 1
				elseif pos2.x > pos1.x then
					pos2.x = pos2.x - 1
				end
				if pos2.z < pos1.z then
					pos2.z = pos2.z + 1
				elseif pos2.z > pos1.z then
					pos2.z = pos2.z - 1
				end
				local way = minetest.find_path(pos1, pos2, res, 1, 3, "A*_noprefetch")
				if way then
					return true
				end
			end
		end
		return false
	end

	for i, pos2 in ipairs(trees) do
		-- full search
		if not minetest.is_protected(pos2, "") then
			if pos2.x < pos1.x then
				pos2.x = pos2.x + 1
			elseif pos2.x > pos1.x then
				pos2.x = pos2.x - 1
			end
			if pos2.z < pos1.z then
				pos2.z = pos2.z + 1
			elseif pos2.z > pos1.z then
				pos2.z = pos2.z - 1
			end
			local way = minetest.find_path(pos1, pos2, res, 1, 3, "A*_noprefetch")
			if way then
				return true
			end
		end
		if i > attempts_to_find_trees then return false end
	end
	return false
end

local function next_pos()
	if edge_dist >= edge_len then
		edge_dist = 1
		dir_ind = (dir_ind % 4) + 1
		dir_step = dir_step + 1
		edge_len = math.floor(dir_step / 2) + 1
	else
		edge_dist = edge_dist + 1
	end
	if dir_ind==1 then
		cp.z = cp.z + res
	elseif dir_ind==2 then
		cp.x = cp.x - res
	elseif dir_ind==3 then
		cp.z = cp.z - res
	else
		cp.x = cp.x + res
	end
end

-- Spawn position search

local function next_biome()
	if #biome_ids < 1 then
		for _, biome_name in pairs(biomes_white_list) do
			local biome_id = minetest.get_biome_id(biome_name)
			if biome_id then
				table.insert(biome_ids, biome_id)
			end
		end
		if #biome_ids < 1 then
			next_pos()
			if math.abs(cp.x) > spawn_limit or math.abs(cp.z) > spawn_limit then
				check = checks + 1
				minetest.log("warning", "[mcla_spawn] No white-listed biomes found - search stopped by overlimit")
				return false
			end
			check = check + 1
			cp.y = minetest.get_spawn_level(cp.x, cp.z) or start_pos.y
			if cp.y then
				wsp = {x = cp.x, y = cp.y, z = cp.z}
				minetest.log("warning", "[mcla_spawn] No white-listed biomes found - using current")
				return true
			else
				minetest.log("warning", "[mcla_spawn] No white-listed biomes found and spawn level is nil - please define start_pos to continue")
				return false
			end
		end
		minetest.log("action", "[mcla_spawn] Suitable biomes found: "..tostring(#biome_ids))
	end
	while check <= checks do
		local biome_data = minetest.get_biome_data(cp)
		-- Sometimes biome_data is nil
		local biome = biome_data and biome_data.biome
		if biome then
			minetest.log("verbose", "[mcla_spawn] Search white-listed biome at "..minetest.pos_to_string(cp)..": "..minetest.get_biome_name(biome))
			for _, biome_id in ipairs(biome_ids) do
				if biome == biome_id then
					cp.y = minetest.get_spawn_level(cp.x, cp.z) or start_pos.y
					if cp.y then
						wsp = {x = cp.x, y = cp.y, z = cp.z}
						return true
					end
					break
				end
			end
		end

		next_pos()

		-- Check for position being outside world edge
		if math.abs(cp.x) > spawn_limit or math.abs(cp.z) > spawn_limit then
			check = checks + 1
			return false
		end

		check = check + 1
	end

	return false
end

local function ecb_search_continue(blockpos, action, calls_remaining, param)
	if calls_remaining <= 0 then
		emerge_pos1 = {x = wsp.x-half_res, y = alt_min, z = wsp.z-half_res}
		emerge_pos2 = {x = wsp.x+half_res, y = alt_max, z = wsp.z+half_res}
		local nodes = minetest.find_nodes_in_area_under_air(emerge_pos1, emerge_pos2, node_groups_white_list)
		minetest.log("verbose", "[mcla_spawn] Data emerge callback: "..minetest.pos_to_string(wsp).." - "..tostring(nodes and #nodes) .. " node(s) found under air")
		if nodes then
			if no_trees_area_counter >= 0 then
				local trees = get_trees(emerge_pos1, emerge_pos2)
				if trees and #trees > 0 then
					no_trees_area_counter = 0
					if attempts_to_find_pos * 3 < #nodes then
						-- random
						for i=1, attempts_to_find_pos do
							wsp = nodes[math.random(1,#nodes)]
							if wsp then
								wsp.y = wsp.y + 1
								if good_for_respawn(wsp) and can_find_tree(wsp, trees) then
									minetest.log("action", "[mcla_spawn] Dynamic world spawn randomly determined to be "..minetest.pos_to_string(wsp))
									searched = true
									success = true
									return
								end
							end
						end
					else
						-- in a sequence
						for i=1, math.min(#nodes, attempts_to_find_pos) do
							wsp = nodes[i]
							if wsp then
								wsp.y = wsp.y + 1
								if good_for_respawn(wsp) and can_find_tree(wsp, trees) then
									minetest.log("action", "[mcla_spawn] Dynamic world spawn determined to be "..minetest.pos_to_string(wsp))
									searched = true
									success = true
									return
								end
							end
						end
					end
				else
					no_trees_area_counter = no_trees_area_counter + 1
					if no_trees_area_counter > 10 then
						minetest.log("verbose", "[mcla_spawn] More than 10 times no trees at all! Won't search trees next 200 calls")
						no_trees_area_counter = -200
					end
				end
			else -- seems there are no trees but we'll check it later, after next 200 calls
				no_trees_area_counter = no_trees_area_counter + 1
				if attempts_to_find_pos * 3 < #nodes then
					-- random
					for i=1, attempts_to_find_pos do
						wsp = nodes[math.random(1,#nodes)]
						if wsp then
							wsp.y = wsp.y + 1
							if good_for_respawn(wsp) then
								minetest.log("action", "[mcla_spawn] Dynamic world spawn randomly determined to be "..minetest.pos_to_string(wsp) .. " (no trees)")
								searched = true
								success = true
								return
							end
						end
					end
				else
					-- in a sequence
					for i=1, math.min(#nodes, attempts_to_find_pos) do
						wsp = nodes[i]
						if wsp then
							wsp.y = wsp.y + 1
							if good_for_respawn(wsp) then
								minetest.log("action", "[mcla_spawn] Dynamic world spawn determined to be "..minetest.pos_to_string(wsp) .. " (no trees)")
								searched = true
								success = true
								return
							end
						end
					end
				end
			end
		end
		next_pos()
		mcla_spawn.search()
	end
end

function mcla_spawn.search()
	if not next_biome() or check > checks then
		return false
	end
	check = check + 1
	if not wsp.y then
		wsp.y = 8
	end
	local pos1 = {x = wsp.x-half_res, y = alt_min, z = wsp.z-half_res}
	local pos2 = {x = wsp.x+half_res, y = alt_max, z = wsp.z+half_res}
	minetest.emerge_area(pos1, pos2, ecb_search_continue)
end


mcla_spawn.get_world_spawn_pos = function()
	local ssp = minetest.setting_get_pos("static_spawnpoint")
	if ssp then
		return ssp
	end
	if success then
		return wsp
	end
	minetest.log("action", "[mcla_spawn] Failed to determine dynamic world spawn!")
	return start_pos
end

-- Returns a spawn position of player.
-- If player is nil or not a player, a world spawn point is returned.
-- The second return value is true if returned spawn point is player-chosen,
-- false otherwise.
mcla_spawn.get_bed_spawn_pos = function(player)
	local spawn, custom_spawn = nil, false
	if player ~= nil and player:is_player() then
		local attr = player:get_meta():get_string("mcla:spawn")
		if attr ~= nil and attr ~= "" then
			spawn = minetest.string_to_pos(attr)
			custom_spawn = true
		end
	end
	if not spawn or spawn == "" then
		spawn = mcla_spawn.get_world_spawn_pos()
		custom_spawn = false
	end
	return spawn, custom_spawn
end

-- Sets the player's spawn position to pos.
-- Set pos to nil to clear the spawn position.
-- If message is set, informs the player with a chat message when the spawn position
-- changed.
mcla_spawn.set_spawn_pos = function(player, pos, message)
	local spawn_changed = false
	local meta = player:get_meta()
	if pos == nil then
		if meta:get_string("mcla:spawn") ~= "" then
			spawn_changed = true
			if message then
				minetest.chat_send_player(player:get_player_name(), S("Respawn position cleared!"))
			end
		end
		meta:set_string("mcla:spawn", "")
	else
		local oldpos = minetest.string_to_pos(meta:get_string("mcla:spawn"))
		meta:set_string("mcla:spawn", minetest.pos_to_string(pos))
		if oldpos then
			-- We don't bother sending a message if the new spawn pos is basically the same
			spawn_changed = vector.distance(pos, oldpos) > 0.1
		else
			-- If it wasn't set and now it will be set, it means it is changed
			spawn_changed = true
		end
		if spawn_changed and message then
			minetest.chat_send_player(player:get_player_name(), S("New respawn position set!"))
		end
	end
	return spawn_changed
end

mcla_spawn.get_player_spawn_pos = function(player)
	local pos, custom_spawn = mcla_spawn.get_bed_spawn_pos(player)
	if pos and custom_spawn then
		-- Check if bed is still there
		local node_bed = get_far_node(pos)
		local bgroup = minetest.get_item_group(node_bed.name, "bed")
		if bgroup ~= 1 and bgroup ~= 2 then
			-- Bed is destroyed:
			if player ~= nil and player:is_player() then
				player:get_meta():set_string("mcla:spawn", "")
			end
			minetest.chat_send_player(player:get_player_name(), S("Your spawn bed was missing or blocked."))
			return mcla_spawn.get_world_spawn_pos(), false
		end

		-- Find spawning position on/near the bed free of solid or damaging blocks iterating a square spiral 15x15:

		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local offset
		for _, o in ipairs(node_search_list) do
			if dir.z == -1 then
				offset = {x =  o.x, y = o.y,  z =  o.z}
			elseif dir.z == 1 then
				offset = {x = -o.x, y = o.y,  z = -o.z}
			elseif dir.x == -1 then
				offset = {x =  o.z, y = o.y,  z = -o.x}
			else -- dir.x == 1
				offset = {x = -o.z, y = o.y,  z =  o.x}
			end
			local player_spawn_pos = vector.add(pos, offset)
			if good_for_respawn(player_spawn_pos, player:get_player_name()) then
				return player_spawn_pos, true
			end
		end
		-- We here if we didn't find suitable place for respawn
	end
	return mcla_spawn.get_world_spawn_pos(), false
end

mcla_spawn.spawn = function(player)
	local pos, in_bed = mcla_spawn.get_player_spawn_pos(player)
	player:set_pos(pos)
	return in_bed or success
end

-- Respawn player at specified respawn position
minetest.register_on_respawnplayer(mcla_spawn.spawn)

function mcla_spawn.shadow_worker()
	if not searched then
		searched = true
		mcla_spawn.search()
		minetest.log("action", "[mcla_spawn] Started world spawn point search")
	end
	if success and ((not good_for_respawn(wsp)) or (not can_find_tree(wsp))) then
		success = false
		minetest.log("action", "[mcla_spawn] World spawn position isn't safe anymore: "..minetest.pos_to_string(wsp))
		mcla_spawn.search()
	end

	minetest.after(respawn_search_interval, mcla_spawn.shadow_worker)
end

minetest.after(respawn_search_initial_delay, function()
	mcla_spawn.shadow_worker()

	minetest.register_on_shutdown(function()
		storage:set_int("mcla_spawn_success", success and 1 or 0)
		if wsp and wsp.x then
			storage:set_string("mcla_spawn_world_spawn_point", minetest.pos_to_string(wsp))
		end
		storage:set_int("mcla_spawn_searched", searched and 1 or 0)
		storage:set_int("mcla_spawn_check", check)
		storage:set_string("mcla_spawn_cp", minetest.pos_to_string(cp))
		storage:set_int("mcla_spawn_edge_len", edge_len)
		storage:set_int("mcla_spawn_edge_dist", edge_dist)
		storage:set_int("mcla_spawn_dir_step", dir_step)
		storage:set_int("mcla_spawn_dir_ind", dir_ind)
	end)
end)
