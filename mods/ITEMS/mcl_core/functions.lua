--
-- Lava vs water interactions
--

local mg_name = minetest.get_mapgen_setting("mg_name")

local OAK_TREE_ID = 1
local DARK_OAK_TREE_ID = 2
local SPRUCE_TREE_ID = 3
local ACACIA_TREE_ID = 4
local JUNGLE_TREE_ID = 5

minetest.register_abm({
	label = "Lava cooling",
	nodenames = {"group:lava"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "group:water")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			-- Lava on top of water: Water turns into stone
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcla:stone"})
				minetest.sound_play("fire_extinguish_flame", {pos = water[w], gain = 0.25, max_hear_distance = 16}, true)
			-- Flowing lava vs water on same level: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcla:cobble"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			-- Lava source vs flowing water above or horizontally neighbored: Lava turns into obsidian
			elseif lavatype == "source" and
					((water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z) or
					(water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z))) then
				minetest.set_node(pos, {name="mcla:obsidian"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			-- water above flowing lava: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcla:cobble"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			end
		end
	end,
})

--
-- Papyrus and cactus growing
--

-- Functions
mcl_core.grow_cactus = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "sand") ~= 0 then
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "mcla:cactus" and height < 4 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="mcla:cactus"})
			end
		end
	end
end

mcl_core.grow_reeds = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "soil_sugarcane") ~= 0 then
		if minetest.find_node_near(pos, 1, {"group:water"}) == nil and minetest.find_node_near(pos, 1, {"group:frosted_ice"}) == nil then
			return
		end
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "mcla:reeds" and height < 3 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="mcla:reeds"})
			end
		end
	end
end

-- ABMs


local function drop_attached_node(p)
	local nn = minetest.get_node(p).name
	if nn == "air" or nn == "ignore" then
		return
	end
	minetest.remove_node(p)
	for _, item in pairs(minetest.get_node_drops(nn, "")) do
		local pos = {
			x = p.x + math.random()/2 - 0.25,
			y = p.y + math.random()/2 - 0.25,
			z = p.z + math.random()/2 - 0.25,
		}
		if item ~= "" then
			minetest.add_item(pos, item)
		end
	end
end

-- Helper function for node actions for liquid flow
local liquid_flow_action = function(pos, group, action)
	local check_detach = function(pos, xp, yp, zp)
		local p = {x=pos.x+xp, y=pos.y+yp, z=pos.z+zp}
		local n = minetest.get_node_or_nil(p)
		if not n then
			return false
		end
		local d = minetest.registered_nodes[n.name]
		if not d then
			return false
		end
		--[[ Check if we want to perform the liquid action.
		* 1: Item must be in liquid group
		* 2a: If target node is below liquid, always succeed
		* 2b: If target node is horizontal to liquid: succeed if source, otherwise check param2 for horizontal flow direction ]]
		local range = d.liquid_range or 8
		if (minetest.get_item_group(n.name, group) ~= 0) and
				((yp > 0) or
				(yp == 0 and ((d.liquidtype == "source") or (n.param2 > (8-range) and n.param2 < 9)))) then
			action(pos)
		end
	end
	local posses = {
		{ x=-1, y=0, z=0 },
		{ x=1, y=0, z=0 },
		{ x=0, y=0, z=-1 },
		{ x=0, y=0, z=1 },
		{ x=0, y=1, z=0 },
	}
	for p=1,#posses do
		check_detach(pos, posses[p].x, posses[p].y, posses[p].z)
	end
end

-- Drop some nodes next to flowing water, if it would flow into the node
minetest.register_abm({
	label = "Wash away dig_by_water nodes by water flow",
	nodenames = {"group:dig_by_water"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		liquid_flow_action(pos, "water", function(pos)
			drop_attached_node(pos)
			minetest.dig_node(pos)
		end)
	end,
})

-- Destroy some nodes next to flowing lava, if it would flow into the node
minetest.register_abm({
	label = "Destroy destroy_by_lava_flow nodes by lava flow",
	nodenames = {"group:destroy_by_lava_flow"},
	neighbors = {"group:lava"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		liquid_flow_action(pos, "lava", function(pos)
			minetest.remove_node(pos)
			minetest.sound_play("builtin_item_lava", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			core.check_for_falling(pos)
		end)
	end,
})

minetest.register_abm({
	label = "Cactus growth",
	nodenames = {"mcla:cactus"},
	neighbors = {"group:sand"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_cactus(pos)
	end,
})

minetest.register_abm({
	label = "Sugar canes growth",
	nodenames = {"mcla:reeds"},
	neighbors = {"group:soil_sugarcane"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_reeds(pos)
	end,
})

--
-- Sugar canes drop
--

local timber_nodenames={"mcla:reeds"}

minetest.register_on_dignode(function(pos, node)
	local i=1
	while timber_nodenames[i]~=nil do
		local np={x=pos.x, y=pos.y+1, z=pos.z}
		while minetest.get_node(np).name==timber_nodenames[i] do
			minetest.remove_node(np)
			minetest.add_item(np, timber_nodenames[i])
			np={x=np.x, y=np.y+1, z=np.z}
		end
		i=i+1
	end
end)

local function air_leaf(leaftype)
	if math.random(0, 50) == 3 then
		return {name = "air"}
	else
		return {name = leaftype}
	end
end

-- Check if a node stops a tree from growing.  Torches, plants, wood, tree,
-- leaves and dirt does not affect tree growth.
local function node_stops_growth(node)
	if node.name == 'air' then
		return false
	end

	local def = minetest.registered_nodes[node.name]
	if not def then
		return true
	end

	local groups = def.groups
	if not groups then
		return true
	end
	if groups.plant or groups.torch or groups.dirt or groups.tree
		or groups.bark or groups.leaves or groups.wood then
		return false
	end

	return true
end

-- Check if a tree can grow at position. The width is the width to check
-- around the tree. A width of 3 and height of 5 will check a 3x3 area, 5
-- nodes above the sapling. If any walkable node other than dirt, wood or
-- leaves occurs in those blocks the tree cannot grow.
local function check_growth_width(pos, width, height)
	-- Huge tree (with even width to check) will check one more node in
	-- positive x and y directions.
	local neg_space = math.min((width - 1) / 2)
	local pos_space = math.max((width - 1) / 2)
	for x = -neg_space, pos_space do
		for z = -neg_space, pos_space do
			for y = 1, height do
				local np = vector.new(
					pos.x + x,
					pos.y + y,
					pos.z + z)
				if node_stops_growth(minetest.get_node(np)) then
					return false
				end
			end
		end
	end
	return true
end

-- Check if a tree with id can grow at a position. Options is a table of flags
-- for varieties of trees. The 'two_by_two' option is used to check if there is
-- room to generate huge trees for spruce and jungle. The 'balloon' option is
-- used to check if there is room to generate a balloon tree for oak.
local function check_tree_growth(pos, tree_id, options)
	local two_by_two = options and options.two_by_two
	local balloon = options and options.balloon

	if tree_id == OAK_TREE_ID then
		if balloon then
			return check_growth_width(pos, 7, 11)
		else
			return check_growth_width(pos, 3, 5)
		end
	end

	return false
end

-- Generates a tree with a type. Options is a table of flags for varieties of
-- trees. The 'two_by_two' option is used by jungle and spruce trees to
-- generate huge trees. The 'balloon' option is used by oak to generate a balloon
-- oak tree.
function mcl_core.generate_tree(pos, tree_type, options)
	pos.y = pos.y-1
	local nodename = minetest.get_node(pos).name

	pos.y = pos.y+1
	if not minetest.get_node_light(pos) then
		return
	end
	local node

	local two_by_two = options and options.two_by_two
	local balloon = options and options.balloon

	if tree_type == nil or tree_type == OAK_TREE_ID then
		if mg_name == "v6" then
			mcl_core.generate_v6_oak_tree(pos)
		else
			if balloon then
				mcl_core.generate_balloon_oak_tree(pos)
			else
				mcl_core.generate_oak_tree(pos)
			end
		end
	end
end

-- Classic oak in v6 style
function mcl_core.generate_v6_oak_tree(pos)
	local trunk = "mcla:tree"
	local leaves = "mcla:leaves"
	local node = {name = ""}
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	node = {name = trunk}
	for dy=0,4 do
		pos.y = pos.y+dy
		if minetest.get_node(pos).name == "air" then
			minetest.add_node(pos, node)
		end
		pos.y = pos.y-dy
	end

	node = {name = leaves}
	pos.y = pos.y+3
	local rarity = 0
	if math.random(0, 10) == 3 then
		rarity = 1
	end
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz

				if dx == 0 and dz == 0 and dy==3 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.add_node(pos, node)
						minetest.add_node(pos, air_leaf(leaves))
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.add_node(pos, node)
						minetest.add_node(pos, air_leaf(leaves))
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, node)
						minetest.add_node(pos, air_leaf(leaves))
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.add_node(pos, node)
							minetest.add_node(pos, air_leaf(leaves))
						end
					end
				end
				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end

-- Ballon Oak
function mcl_core.generate_balloon_oak_tree(pos)
	local path
	local offset
	local s = math.random(1, 12)
	if s == 1 then
		-- Small balloon oak
		path = minetest.get_modpath("mcla_core") .. "/schematics/mcl_core_oak_balloon.mts"
		offset = { x = -2, y = -1, z = -2 }
	else
		-- Large balloon oak
		local t = math.random(1, 4)
		path = minetest.get_modpath("mcla_core") .. "/schematics/mcl_core_oak_large_"..t..".mts"
		if t == 1 or t == 3 then
			offset = { x = -3, y = -1, z = -3 }
		elseif t == 2 or t == 4 then
			offset = { x = -4, y = -1, z = -4 }
		end
	end
	minetest.place_schematic(vector.add(pos, offset), path, "random", nil, false)
end

-- Oak
function mcl_core.generate_oak_tree(pos)
	local path = minetest.get_modpath("mcla_core") .. "/schematics/mcl_core_oak_classic.mts"
	local offset = { x = -2, y = -1, z = -2 }

	minetest.place_schematic(vector.add(pos, offset), path, "random", nil, false)
end

-- Helper function for jungle tree, form Minetest Game 0.4.15
local function add_trunk_and_leaves(data, a, pos, tree_cid, leaves_cid,
		height, size, iters)
	local x, y, z = pos.x, pos.y, pos.z
	local c_air = minetest.CONTENT_AIR
	local c_ignore = minetest.CONTENT_IGNORE

	-- Trunk
	data[a:index(x, y, z)] = tree_cid -- Force-place lowest trunk node to replace sapling
	for yy = y + 1, y + height - 1 do
		local vi = a:index(x, yy, z)
		local node_id = data[vi]
		if node_id == c_air or node_id == c_ignore or node_id == leaves_cid then
			data[vi] = tree_cid
		end
	end

	-- Force leaves near the trunk
	for z_dist = -1, 1 do
	for y_dist = -size, 1 do
		local vi = a:index(x - 1, y + height + y_dist, z + z_dist)
		for x_dist = -1, 1 do
			if data[vi] == c_air or data[vi] == c_ignore then
				data[vi] = leaves_cid
			end
			vi = vi + 1
		end
	end
	end

	-- Randomly add leaves in 2x2x2 clusters.
	for i = 1, iters do
		local clust_x = x + math.random(-size, size - 1)
		local clust_y = y + height + math.random(-size, 0)
		local clust_z = z + math.random(-size, size - 1)

		for xi = 0, 1 do
		for yi = 0, 1 do
		for zi = 0, 1 do
			local vi = a:index(clust_x + xi, clust_y + yi, clust_z + zi)
			if data[vi] == c_air or data[vi] == c_ignore then
				data[vi] = leaves_cid
			end
		end
		end
		end
	end
end


local grass_spread_randomizer = PseudoRandom(minetest.get_mapgen_setting("seed"))

-- Return appropriate grass block node for pos
function mcl_core.get_grass_block_type(pos)
	local biome_data = minetest.get_biome_data(pos)
	local index = 0
	if biome_data then
		local biome = biome_data.biome
		local biome_name = minetest.get_biome_name(biome)
		local reg_biome = minetest.registered_biomes[biome_name]
		if reg_biome then
			index = reg_biome._mcl_palette_index
		end
	end
	return {name="mcla:dirt_with_grass", param2=index}
end

------------------------------
-- Spread grass blocks on neighbor dirt
------------------------------
minetest.register_abm({
	label = "Grass Block spread",
	nodenames = {"mcla:dirt"},
	neighbors = {"air", "group:grass_block_no_snow"},
	interval = 30,
	chance = 20,
	catch_up = false,
	action = function(pos)
		if pos == nil then
			return
		end
		local can_change = false
		local above = {x=pos.x, y=pos.y+1, z=pos.z}
		local abovenode = minetest.get_node(above)
		if minetest.get_item_group(abovenode.name, "liquid") ~= 0 or minetest.get_item_group(abovenode.name, "opaque") == 1 then
			-- Never grow directly below liquids or opaque blocks
			return
		end
		local light_self = minetest.get_node_light(above)
		if not light_self then return end
		--[[ Try to find a spreading dirt-type block (e.g. grass block)
		within a 3×5×3 area, with the source block being on the 2nd-topmost layer. ]]
		local nodes = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+3, z=pos.z+1}, "group:spreading_dirt_type")
		local p2
		-- Nothing found ? Bail out!
		if #nodes <= 0 then
			return
		else
			p2 = nodes[grass_spread_randomizer:next(1, #nodes)]
		end

		-- Found it! Now check light levels!
		local source_above = {x=p2.x, y=p2.y+1, z=p2.z}
		local light_source = minetest.get_node_light(source_above)
		if not light_source then return end

		if light_self >= 4 and light_source >= 9 then
			-- All checks passed! Let's spread the grass!
			local n2 = minetest.get_node(p2)
			if minetest.get_item_group(n2.name, "grass_block") ~= 0 then
				n2 = mcl_core.get_grass_block_type(pos)
			end
			minetest.set_node(pos, {name=n2.name})
		end
	end
})

-- Grass death in darkness
minetest.register_abm({
	label = "Grass Block in darkness",
	nodenames = {"group:spreading_dirt_type"},
	interval = 8,
	chance = 50,
	catch_up = false,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		-- Kill grass when below opaque block or liquid
		if name ~= "ignore" and (minetest.get_item_group(name, "opaque") == 1 or minetest.get_item_group(name, "liquid") ~= 0) then
			minetest.set_node(pos, {name = "mcla:dirt"})
		end
	end
})

-- Turn Grass Path and similar nodes to Dirt if a solid node is placed above it
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if minetest.get_item_group(newnode.name, "solid") ~= 0 or
			minetest.get_item_group(newnode.name, "dirtifier") ~= 0 then
		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local belownode = minetest.get_node(below)
		if minetest.get_item_group(belownode.name, "dirtifies_below_solid") == 1 then
			minetest.set_node(below, {name="mcla:dirt"})
		end
	end
end)

minetest.register_abm({
	label = "Turn Grass Path below solid block into Dirt",
	nodenames = {"mcla:grass_path"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name ~= "ignore" and nodedef and (nodedef.groups and nodedef.groups.solid) then
			minetest.set_node(pos, {name = "mcla:dirt"})
		end
	end,
})

--------------------------
-- Try generate tree   ---
--------------------------
local treelight = 9

local sapling_grow_action = function(tree_id, soil_needed, one_by_one, two_by_two, sapling)
	return function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get("grown") then return end
		-- Checks if the sapling at pos has enough light and the correct soil
		local light = minetest.get_node_light(pos)
		if not light then return end
		local low_light = (light < treelight)

		local delta = 1
		local current_game_time = minetest.get_day_count() + minetest.get_timeofday()

		local last_game_time = tonumber(meta:get_string("last_gametime"))
		meta:set_string("last_gametime", tostring(current_game_time))

		if last_game_time then
			delta = current_game_time - last_game_time
		elseif low_light then
			return
		end

		if low_light then
			if delta < 1.2 then return end
			if minetest.get_node_light(pos, 0.5) < treelight then return end
		end

		-- TODO: delta is [days] missed in inactive area. Currently we just add it to stage, which is far from a perfect calculation...

		local soilnode = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local soiltype = minetest.get_item_group(soilnode.name, "soil_sapling")
		if soiltype < soil_needed then return end

		-- Increase and check growth stage
		local meta = minetest.get_meta(pos)
		local stage = meta:get_int("stage")
		if stage == nil then stage = 0 end
		stage = stage + math.max(1, math.floor(delta))
		if stage >= 3 then
			meta:set_string("grown", "true")
			-- This sapling grows in a special way when there are 4 saplings in a 2×2 pattern
			if two_by_two then
				-- Check 8 surrounding saplings and try to find a 2×2 pattern
				local is_sapling = function(pos, sapling)
					return minetest.get_node(pos).name == sapling
				end
				local p2 = {x=pos.x+1, y=pos.y, z=pos.z}
				local p3 = {x=pos.x, y=pos.y, z=pos.z-1}
				local p4 = {x=pos.x+1, y=pos.y, z=pos.z-1}
				local p5 = {x=pos.x-1, y=pos.y, z=pos.z-1}
				local p6 = {x=pos.x-1, y=pos.y, z=pos.z}
				local p7 = {x=pos.x-1, y=pos.y, z=pos.z+1}
				local p8 = {x=pos.x, y=pos.y, z=pos.z+1}
				local p9 = {x=pos.x+1, y=pos.y, z=pos.z+1}
				local s2 = is_sapling(p2, sapling)
				local s3 = is_sapling(p3, sapling)
				local s4 = is_sapling(p4, sapling)
				local s5 = is_sapling(p5, sapling)
				local s6 = is_sapling(p6, sapling)
				local s7 = is_sapling(p7, sapling)
				local s8 = is_sapling(p8, sapling)
				local s9 = is_sapling(p9, sapling)
				-- In a 9×9 field there are 4 possible 2×2 squares. We check them all.
				if s2 and s3 and s4 and check_tree_growth(pos, tree_id, { two_by_two = true }) then
					-- Success: Remove saplings and place tree
					minetest.remove_node(pos)
					minetest.remove_node(p2)
					minetest.remove_node(p3)
					minetest.remove_node(p4)
					mcl_core.generate_tree(pos, tree_id, { two_by_two = true })
					return
				elseif s3 and s5 and s6 and check_tree_growth(p6, tree_id, { two_by_two = true }) then
					minetest.remove_node(pos)
					minetest.remove_node(p3)
					minetest.remove_node(p5)
					minetest.remove_node(p6)
					mcl_core.generate_tree(p6, tree_id, { two_by_two = true })
					return
				elseif s6 and s7 and s8 and check_tree_growth(p7, tree_id, { two_by_two = true }) then
					minetest.remove_node(pos)
					minetest.remove_node(p6)
					minetest.remove_node(p7)
					minetest.remove_node(p8)
					mcl_core.generate_tree(p7, tree_id, { two_by_two = true })
					return
				elseif s2 and s8 and s9 and check_tree_growth(p8, tree_id, { two_by_two = true }) then
					minetest.remove_node(pos)
					minetest.remove_node(p2)
					minetest.remove_node(p8)
					minetest.remove_node(p9)
					mcl_core.generate_tree(p8, tree_id, { two_by_two = true })
					return
				end
			end
				if one_by_one and tree_id == OAK_TREE_ID then
				-- There is a chance that this tree wants to grow as a balloon oak
				if math.random(1, 12) == 1 then
					-- Check if there is room for that
					if check_tree_growth(pos, tree_id, { balloon = true }) then
						minetest.set_node(pos, {name="air"})
						mcl_core.generate_tree(pos, tree_id, { balloon = true })
						return
					end
				end
			end
				-- If this sapling can grow alone
			if one_by_one and check_tree_growth(pos, tree_id) then
				-- Single sapling
				minetest.set_node(pos, {name="air"})
				local r = math.random(1, 12)
				mcl_core.generate_tree(pos, tree_id)
				return
			end
		else
			meta:set_int("stage", stage)
		end
	end
end

local grow_oak = sapling_grow_action(OAK_TREE_ID, 1, true, false)

-- Attempts to grow the sapling at the specified position
-- pos: Position
-- node: Node table of the node at this position, from minetest.get_node
-- Returns true on success and false on failure
mcl_core.grow_sapling = function(pos, node)
	local grow
	if node.name == "mcla:sapling" then
		grow = grow_oak
	end
	if grow then
		grow(pos)
		return true
	else
		return false
	end
end

-- TODO: Use better tree models for everything
-- TODO: Support 2×2 saplings

-- Oak tree
minetest.register_abm({
	label = "Oak tree growth",
	nodenames = {"mcla:sapling"},
	neighbors = {"group:soil_sapling"},
	interval = 25,
	chance = 2,
	action = grow_oak
})
minetest.register_lbm({
	label = "Add growth for unloaded oak tree",
	name = "mcla_core:lbm_oak",
	nodenames = {"mcla:sapling"},
	run_at_every_load = true,
	action = grow_oak
})

local function leafdecay_particles(pos, node)
	minetest.add_particlespawner({
		amount = math.random(10, 20),
		time = 0.1,
		minpos = vector.add(pos, {x=-0.4, y=-0.4, z=-0.4}),
		maxpos = vector.add(pos, {x=0.4, y=0.4, z=0.4}),
		minvel = {x=-0.2, y=-0.2, z=-0.2},
		maxvel = {x=0.2, y=0.1, z=0.2},
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.5,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

-- Leaf Decay

-- To enable leaf decay for a node, add it to the "leafdecay" group.
--
-- The rating of the group determines how far from a node in the group "tree"
-- the node can be without decaying.
--
-- If param2 of the node is ~= 0, the node will always be preserved. Thus, if
-- the player places a node of that kind, you will want to set param2=1 or so.
--

mcl_core.leafdecay_trunk_cache = {}
mcl_core.leafdecay_enable_cache = true
-- Spread the load of finding trunks
mcl_core.leafdecay_trunk_find_allow_accumulator = 0

minetest.register_globalstep(function(dtime)
	local finds_per_second = 5000
	mcl_core.leafdecay_trunk_find_allow_accumulator =
			math.floor(dtime * finds_per_second)
end)

minetest.register_abm({
	label = "Leaf decay",
	nodenames = {"group:leafdecay"},
	neighbors = {"air", "group:liquid"},
	-- A low interval and a high inverse chance spreads the load
	interval = 2,
	chance = 5,

	action = function(p0, node, _, _)
		local do_preserve = false
		local d = minetest.registered_nodes[node.name].groups.leafdecay
		if not d or d == 0 then
			return
		end
		local n0 = minetest.get_node(p0)
		if n0.param2 ~= 0 then
			-- Prevent leafdecay for player-placed leaves.
			-- param2 is set to 1 after it was placed by the player
			return
		end
		local p0_hash = nil
		if mcl_core.leafdecay_enable_cache then
			p0_hash = minetest.hash_node_position(p0)
			local trunkp = mcl_core.leafdecay_trunk_cache[p0_hash]
			if trunkp then
				local n = minetest.get_node(trunkp)
				local reg = minetest.registered_nodes[n.name]
				-- Assume ignore is a trunk, to make the thing work at the border of the active area
				if n.name == "ignore" or (reg and reg.groups.tree and reg.groups.tree ~= 0) then
					return
				end
				-- Cache is invalid
				table.remove(mcl_core.leafdecay_trunk_cache, p0_hash)
			end
		end
		if mcl_core.leafdecay_trunk_find_allow_accumulator <= 0 then
			return
		end
		mcl_core.leafdecay_trunk_find_allow_accumulator =
				mcl_core.leafdecay_trunk_find_allow_accumulator - 1
		-- Assume ignore is a trunk, to make the thing work at the border of the active area
		local p1 = minetest.find_node_near(p0, d, {"ignore", "group:tree"})
		if p1 then
			do_preserve = true
			if mcl_core.leafdecay_enable_cache then
				-- Cache the trunk
				mcl_core.leafdecay_trunk_cache[p0_hash] = p1
			end
		end
		if not do_preserve then
			-- Drop stuff other than the node itself
			local itemstacks = minetest.get_node_drops(n0.name)
			for _, itemname in ipairs(itemstacks) do
				local p_drop = {
					x = p0.x - 0.5 + math.random(),
					y = p0.y - 0.5 + math.random(),
					z = p0.z - 0.5 + math.random(),
				}
				minetest.add_item(p_drop, itemname)
			end
			-- Remove node
			minetest.remove_node(p0)
			leafdecay_particles(p0, n0)
			core.check_for_falling(p0)
		end
	end
})

-- Melt snow
minetest.register_abm({
	label = "Top snow and ice melting",
	nodenames = {"mcla:snow", "mcla:ice"},
	interval = 16,
	chance = 8,
	action = function(pos, node)
		if minetest.get_node_light(pos, 0) >= 12 then
			if node.name == "mcla:ice" then
				mcl_core.melt_ice(pos)
			else
				minetest.remove_node(pos)
			end
		end
	end
})

-- Melt ice at pos. mcla:ice MUST be at pos if you call this!
function mcl_core.melt_ice(pos)
	-- Create a water source if ice is destroyed and there was something below it
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local belownode = minetest.get_node(below)
	local dim = mcl_worlds.pos_to_dimension(below)
	if belownode.name ~= "air" and belownode.name ~= "ignore" and belownode.name ~= "mcla:void" then
		minetest.set_node(pos, {name="mcla:water_source"})
	else
		minetest.remove_node(pos)
	end
	local neighbors = {
		{x=-1, y=0, z=0},
		{x=1, y=0, z=0},
		{x=0, y=-1, z=0},
		{x=0, y=1, z=0},
		{x=0, y=0, z=-1},
		{x=0, y=0, z=1},
	}
	for n=1, #neighbors do
		minetest.check_single_for_falling(vector.add(pos, neighbors[n]))
	end
end

---- FUNCTIONS FOR SNOWED NODES ----
-- These are nodes which change their appearence when they are below a snow cover
-- and turn back into “normal” when the snow cover is removed.

-- Registers a snowed variant of a node (e.g. grass block, podzol, mycelium).
-- * itemstring_snowed: Itemstring of the snowed node to add
-- * itemstring_clear: Itemstring of the original “clear” node without snow
-- * tiles: Optional custom tiles
-- * sounds: Optional custom sounds
-- * clear_colorization: Optional. If true, will clear all paramtype2="color" related node def. fields
-- * desc: Item description
--
-- The snowable nodes also MUST have _mcl_snowed defined to contain the name
-- of the snowed node.
mcl_core.register_snowed_node = function(itemstring_snowed, itemstring_clear, tiles, sounds, clear_colorization, desc)
	local def = table.copy(minetest.registered_nodes[itemstring_clear])
	local create_doc_alias
	if def.description then
		create_doc_alias = true
	else
		create_doc_alias = false
	end
	-- Just some group clearing
	def.description = desc
	def.groups.not_in_creative_inventory = 1
	if def.groups.grass_block == 1 then
		def.groups.grass_block_no_snow = nil
		def.groups.grass_block_snow = 1
	end

	-- Snowed blocks never spread
	def.groups.spreading_dirt_type = nil

	-- Add the clear node to the item definition for easy lookup
	def._mcl_snowless = itemstring_clear

	-- Note: _mcl_snowed must be added to the clear node manually!

	if not tiles then
		def.tiles = {"mcl_core_snow.png", "mcl_core_dirt.png", {name="mcl_core_grass_side_snowed.png", tileable_vertical=false}}
	else
		def.tiles = tiles
	end
	if clear_colorization then
		def.paramtype2 = nil
		def.palette = nil
		def.palette_index = nil
		def.color = nil
		def.overlay_tiles = nil
	end
	if not sounds then
		def.sounds = mcl_sounds.node_sound_dirt_defaults({
			footstep = { name = "pedology_snow_soft_footstep", gain = 0.5 }
		})
	else
		def.sounds = sounds
	end

	def._mcl_silk_touch_drop = {itemstring_clear}

	-- Register stuff
	minetest.register_node(itemstring_snowed, def)
end

-- Reverts a snowed dirtlike node at pos to its original snow-less form.
-- This function assumes there is no snow cover node above. This function
-- MUST NOT be called if there is a snow cover node above pos.
mcl_core.clear_snow_dirt = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	if def._mcl_snowless then
		minetest.swap_node(pos, {name = def._mcl_snowless, param2=node.param2})
	end
end

---- [[[[[ Functions for snowable nodes (nodes that can become snowed). ]]]]] ----
-- Always add these for snowable nodes.

-- on_construct
-- Makes constructed snowable node snowed if placed below a snow cover node.
mcl_core.on_snowable_construct = function(pos)
	-- Myself
	local node = minetest.get_node(pos)

	-- Above
	local apos = {x=pos.x, y=pos.y+1, z=pos.z}
	local anode = minetest.get_node(apos)

	-- Make snowed if needed
	if minetest.get_item_group(anode.name, "snow_cover") == 1 then
		local def = minetest.registered_nodes[node.name]
		if def._mcl_snowed then
			minetest.swap_node(pos, {name = def._mcl_snowed, param2=node.param2})
		end
	end
end


---- [[[[[ Functions for snow cover nodes. ]]]]] ----

-- A snow cover node is a node which turns a snowed dirtlike --
-- node into its snowed form while it is placed above.
-- MCL2's snow cover nodes are Top Snow (mcla:snow) and Snow (mcla:snowblock).

-- Always add the following functions to snow cover nodes:

-- on_construct
-- Makes snowable node below snowed.
mcl_core.on_snow_construct = function(pos)
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	local def = minetest.registered_nodes[node.name]
	if def._mcl_snowed then
		minetest.swap_node(npos, {name = def._mcl_snowed, param2=node.param2})
	end
end
-- after_destruct
-- Clears snowed dirtlike node below.
mcl_core.after_snow_destruct = function(pos)
	local nn = minetest.get_node(pos).name
	-- No-op if snow was replaced with snow
	if minetest.get_item_group(nn, "snow_cover") == 1 then
		return
	end
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	mcl_core.clear_snow_dirt(npos, node)
end

