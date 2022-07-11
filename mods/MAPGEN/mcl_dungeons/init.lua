-- FIXME: Chests may appear at openings

local mg_name = minetest.get_mapgen_setting("mg_name")

-- Are dungeons disabled?
if mcla_vars.mg_dungeons == false or mg_name == "singlenode" then
	return
end

local min_y = math.max(mcla_vars.mg_overworld_min, mcla_vars.mg_bedrock_overworld_max) + 1
local max_y = mcla_vars.mg_overworld_max - 1

local dungeonsizes = {
	{ x=5, y=4, z=5},
	{ x=5, y=4, z=7},
	{ x=7, y=4, z=5},
	{ x=7, y=4, z=7},
}

local dirs = {
	{ x= 1, y=0, z= 0 },
	{ x= 0, y=0, z= 1 },
	{ x=-1, y=0, z= 0 },
	{ x= 0, y=0, z=-1 },
}

local surround_vectors = {
	{ x=-1, y=0, z=0 },
	{ x=1, y=0, z=0 },
	{ x=0, y=0, z=-1 },
	{ x=0, y=0, z=1 },
}

local loottable =
{
	{
		stacks_min = 1,
		stacks_max = 3,
		items = {
			{ itemstring = "mcla:saddle", weight = 20 },
			{ itemstring = "mcla:record_1", weight = 15 },
			{ itemstring = "mcla:apple_gold", weight = 15 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			{ itemstring = "mcla:wheat_item", weight = 20, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcla:bread", weight = 20 },
			{ itemstring = "mcla:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mesecons:redstone", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcla:iron_ingot", weight = 10, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcla:bucket_empty", weight = 10 },
			{ itemstring = "mcla:gold_ingot", weight = 5, amount_min = 1, amount_max = 4 },
		},
	},
	{
		stacks_min = 3,
		stacks_max = 3,
		items = {
			{ itemstring = "mcla:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
			{ itemstring = "mcla:string", weight = 10, amount_min = 1, amount_max = 8 },
		},
	}
}


-- Calculate the number of dungeon spawn attempts
-- In Minecraft, there 8 dungeon spawn attempts Minecraft chunk (16*256*16 = 65536 blocks).
-- Minetest chunks don't have this size, so scale the number accordingly.
local attempts = math.ceil(((mcla_vars.chunksize * mcla_vars.MAP_BLOCKSIZE) ^ 3) / 8192) -- 63 = 80*80*80/8192

local function ecb_spawn_dungeon(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end

	local p1, p2, dim, pr = param.p1, param.p2, param.dim, param.pr
	local x, y, z = p1.x, p1.y, p1.z

	-- Check floor and ceiling: Must be *completely* solid
	local y_floor = y
	local y_ceiling = y + dim.y + 1
	for tx = x, x + dim.x do for tz = z, z + dim.z do
		if not minetest.registered_nodes[mcla_mapgen_core.get_node({x = tx, y = y_floor  , z = tz}).name].walkable
		or not minetest.registered_nodes[mcla_mapgen_core.get_node({x = tx, y = y_ceiling, z = tz}).name].walkable then return false end
	end end

	-- Check for air openings (2 stacked air at ground level) in wall positions
	local openings_counter = 0
	-- Store positions of openings; walls will not be generated here
	local openings = {}
	-- Corners are stored because a corner-only opening needs to be increased,
	-- so entities can get through.
	local corners = {}

	local walls = {
		-- walls along x axis (contain corners)
		{ x, x+dim.x+1, "x", "z", z },
		{ x, x+dim.x+1, "x", "z", z+dim.z+1 },
		-- walls along z axis (exclude corners)
		{ z+1, z+dim.z, "z", "x", x },
		{ z+1, z+dim.z, "z", "x", x+dim.x+1 },
	}

	for w=1, #walls do
		local wall = walls[w]
		for iter = wall[1], wall[2] do
			local pos = {}
			pos[wall[3]] = iter
			pos[wall[4]] = wall[5]
			pos.y = y+1

			if openings[pos.x] == nil then openings[pos.x] = {} end
			local doorname1 = mcla_mapgen_core.get_node(pos).name
			pos.y = y+2
			local doorname2 = mcla_mapgen_core.get_node(pos).name
			if doorname1 == "air" and doorname2 == "air" then
				openings_counter = openings_counter + 1
				openings[pos.x][pos.z] = true

				-- Record corners
				if wall[3] == "x" and (iter == wall[1] or iter == wall[2]) then
					table.insert(corners, {x=pos.x, z=pos.z})
				end
			end
		end
	end

	-- If all openings are only at corners, the dungeon can't be accessed yet.
	-- This code extends the openings of corners so they can be entered.
	if openings_counter >= 1 and openings_counter == #corners then
		for c=1, #corners do
			-- Prevent creating too many openings because this would lead to dungeon rejection
			if openings_counter >= 5 then
				break
			end
			-- A corner is widened by adding openings to both neighbors
			local cx, cz = corners[c].x, corners[c].z
			local cxn, czn = cx, cz
			if x == cx then
				cxn = cxn + 1
			else
				cxn = cxn - 1
			end
			if z == cz then
				czn = czn + 1
			else
				czn = czn - 1
			end
			openings[cx][czn] = true
			openings_counter = openings_counter + 1
			if openings_counter < 5 then
				openings[cxn][cz] = true
				openings_counter = openings_counter + 1
			end
		end
	end

	-- Check conditions. If okay, start generating
	if openings_counter < 1 or openings_counter > 5 then return end

	minetest.log("action","[mcla_dungeons] Placing new dungeon at "..minetest.pos_to_string({x=x,y=y,z=z}))
	-- Okay! Spawning starts!

	-- Remember spawner chest positions to set metadata later
	local chests = {}
	local spawner_posses = {}

	-- First prepare random chest positions.
	-- Chests spawn at wall

	-- We assign each position at the wall a number and each chest gets one of these numbers randomly
	local totalChests = 2 -- this code strongly relies on this number being 2
	local totalChestSlots = (dim.x-1) * (dim.z-1)
	local chestSlots = {}
	-- There is a small chance that both chests have the same slot.
	-- In that case, we give a 2nd chance for the 2nd chest to get spawned.
	-- If it failed again, tough luck! We stick with only 1 chest spawned.
	local lastRandom
	local secondChance = true -- second chance is still available
	for i=1, totalChests do
		local r = pr:next(1, totalChestSlots)
		if r == lastRandom and secondChance then
			-- Oops! Same slot selected. Try again.
			r = pr:next(1, totalChestSlots)
			secondChance = false
		end
		lastRandom = r
		table.insert(chestSlots, r)
	end
	table.sort(chestSlots)
	local currentChest = 1

	-- Calculate the mob spawner position, to be re-used for later
	local sp = {x = x + math.ceil(dim.x/2), y = y+1, z = z + math.ceil(dim.z/2)}
	local rn = minetest.registered_nodes[mcla_mapgen_core.get_node(sp).name]
	if rn and rn.is_ground_content then
		table.insert(spawner_posses, sp)
	end

	-- Generate walls and floor
	local maxx, maxy, maxz = x+dim.x+1, y+dim.y, z+dim.z+1
	local chestSlotCounter = 1
	for tx = x, maxx do
	for tz = z, maxz do
	for ty = y, maxy do
		local p = {x = tx, y=ty, z=tz}

		-- Do not overwrite nodes with is_ground_content == false (e.g. bedrock)
		-- Exceptions: cobblestone and mossy cobblestone so neighborings dungeons nicely connect to each other
		local name = mcla_mapgen_core.get_node(p).name
		if name == "mcla:cobble" or name == "mcla:mossycobble" or minetest.registered_nodes[name].is_ground_content then
			-- Floor
			if ty == y then
				if pr:next(1,4) == 1 then
					minetest.swap_node(p, {name = "mcla:cobble"})
				else
					minetest.swap_node(p, {name = "mcla:mossycobble"})
				end

				-- Generate walls
				--[[ Note: No additional cobblestone ceiling is generated. This is intentional.
				The solid blocks above the dungeon are considered as the “ceiling”.
				It is possible (but rare) for a dungeon to generate below sand or gravel. ]]

			elseif ty > y and (tx == x or tx == maxx or (tz == z or tz == maxz)) then
				-- Check if it's an opening first
				if (not openings[tx][tz]) or ty == maxy then
					-- Place wall or ceiling
					minetest.swap_node(p, {name = "mcla:cobble"})
				elseif ty < maxy - 1 then
					-- Normally the openings are already clear, but not if it is a corner
					-- widening. Make sure to clear at least the bottom 2 nodes of an opening.
					minetest.swap_node(p, {name = "air"})
				elseif ty == maxy - 1 and mcla_mapgen_core.get_node(p).name ~= "air" then
					-- This allows for variation between 2-node and 3-node high openings.
					minetest.swap_node(p, {name = "mcla:cobble"})
				end
				-- If it was an opening, the lower 3 blocks are not touched at all

			-- Room interiour
			else
				local forChest = ty==y+1 and (tx==x+1 or tx==maxx-1 or tz==z+1 or tz==maxz-1)

				-- Place next chest at the wall (if it was its chosen wall slot)
				if forChest and (currentChest < totalChests + 1) and (chestSlots[currentChest] == chestSlotCounter) then
					currentChest = currentChest + 1
					table.insert(chests, {x=tx, y=ty, z=tz})
				else
					minetest.swap_node(p, {name = "air"})
				end
				if forChest then
					chestSlotCounter = chestSlotCounter + 1
				end
			end
		end
	end end end

	for c=#chests, 1, -1 do
		local pos = chests[c]

		local surroundings = {}
		for s=1, #surround_vectors do
			-- Detect the 4 horizontal neighbors
			local spos = vector.add(pos, surround_vectors[s])
			local wpos = vector.subtract(pos, surround_vectors[s])
			local nodename = minetest.get_node(spos).name
			local nodename2 = minetest.get_node(wpos).name
			local nodedef = minetest.registered_nodes[nodename]
			local nodedef2 = minetest.registered_nodes[nodename2]
			-- The chest needs an open space in front of it and a walkable node (except chest) behind it
			if nodedef and nodedef.walkable == false and nodedef2 and nodedef2.walkable == true and nodename2 ~= "mcla:chest" then
				table.insert(surroundings, spos)
			end
		end
		-- Set param2 (=facedir) of this chest
		local facedir
		if #surroundings <= 0 then
			-- Fallback if chest ended up in the middle of a room for some reason
			facedir = pr:next(0, 0)
		else
			-- 1 or multiple possible open directions: Choose random facedir
			local face_to = surroundings[pr:next(1, #surroundings)]
			facedir = minetest.dir_to_facedir(vector.subtract(pos, face_to))
		end

		minetest.set_node(pos, {name="mcla:chest", param2=facedir})
		local meta = minetest.get_meta(pos)
		mcla_loot.fill_inventory(meta:get_inventory(), "main", mcla_loot.get_multi_loot(loottable, pr), pr)
	end

	-- Mob spawners are placed seperately, too
	-- We don't want to destroy non-ground nodes
	for s=#spawner_posses, 1, -1 do
		local sp = spawner_posses[s]
		-- ... and place it and select a random mob
		minetest.set_node(sp, {name = "mcla:spawner"})
		local mobs = {
			"mobs_mc:zombie",
			"mobs_mc:zombie",
			"mobs_mc:spider",
			"mobs_mc:skeleton",
		}
		local spawner_mob = mobs[pr:next(1, #mobs)]

		mcla_mobspawners.setup_spawner(sp, spawner_mob, 0, 7)
	end
end

local function dungeons_nodes(minp, maxp, blockseed)
	local ymin, ymax = math.max(min_y, minp.y),  math.min(max_y, maxp.y)
	if ymax < ymin then return false end
	local pr = PseudoRandom(blockseed)
	for a=1, attempts do
		local dim = dungeonsizes[pr:next(1, #dungeonsizes)]
		local x = pr:next(minp.x, maxp.x-dim.x-2)
		local y = pr:next(ymin  , ymax  -dim.y-2)
		local z = pr:next(minp.z, maxp.z-dim.z-2)
		local p1 = {x=x,y=y,z=z}
		local p2 = {x = x+dim.x+1, y = y+dim.y+1, z = z+dim.z+1}
		minetest.log("verbose","[mcla_dungeons] size=" ..minetest.pos_to_string(dim) .. ", emerge from "..minetest.pos_to_string(p1) .. " to " .. minetest.pos_to_string(p2))
		local param = {p1=p1, p2=p2, dim=dim, pr=pr}
		minetest.emerge_area(p1, p2, ecb_spawn_dungeon, param)
	end
end

mcla_mapgen_core.register_generator("dungeons", nil, dungeons_nodes, 999999)
