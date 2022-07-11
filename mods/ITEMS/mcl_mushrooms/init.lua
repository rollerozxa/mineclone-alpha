local S = minetest.get_translator("mcla_mushrooms")

local on_place = mcla_util.generate_on_place_plant_function(function(place_pos, place_node)
	local soil_node = minetest.get_node_or_nil({x=place_pos.x, y=place_pos.y-1, z=place_pos.z})
	if not soil_node then return false end
	local snn = soil_node.name -- soil node name
	local sd = minetest.registered_nodes[snn] -- soil definition

	-- Placement rules:
	-- * Always allowed on podzol or mycelimu
	-- * Otherwise, must be solid, opaque and have daylight light level <= 12
	local light = minetest.get_node_light(place_pos, 0.5)
	local light_ok = false
	if light and light <= 12 then
		light_ok = true
	end
	return ((light_ok and minetest.get_item_group(snn, "solid") == 1 and minetest.get_item_group(snn, "opaque") == 1))
end)

minetest.register_node(":mcla:mushroom_brown", {
	description = S("Brown Mushroom"),
	drawtype = "plantlike",
	tiles = { "mcl_mushrooms_brown.png" },
	inventory_image = "mcl_mushrooms_brown.png",
	wield_image = "mcl_mushrooms_brown.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,deco_block=1},
	sounds = mcla_sounds.node_sound_leaves_defaults(),
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = on_place,
	_mcla_blast_resistance = 0,
})

minetest.register_node(":mcla:mushroom_red", {
	description = S("Red Mushroom"),
	drawtype = "plantlike",
	tiles = { "mcl_mushrooms_red.png" },
	inventory_image = "mcl_mushrooms_red.png",
	wield_image = "mcl_mushrooms_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,deco_block=1},
	sounds = mcla_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = on_place,
	_mcla_blast_resistance = 0,
})

minetest.register_craftitem(":mcla:mushroom_stew", {
	description = S("Mushroom Stew"),
	inventory_image = "mcl_mushrooms_stew.png",
	on_place = minetest.item_eat(6, "mcla:bowl"),
	on_secondary_use = minetest.item_eat(6, "mcla:bowl"),
	groups = { food = 3 },
	stack_max = 1,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcla:mushroom_stew",
	recipe = {'mcla:bowl', 'mcla:mushroom_brown', 'mcla:mushroom_red'}
})

--[[ Mushroom spread and death
Code based on information gathered from Minecraft Wiki
<http://minecraft.gamepedia.com/Tutorials/Mushroom_farming#Videos>
]]
minetest.register_abm({
	label = "Mushroom spread and death",
	nodenames = {"mcla:mushroom_brown", "mcla:mushroom_red"},
	interval = 11,
	chance = 50,
	action = function(pos, node)
		local node_soil = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		-- Mushrooms uproot in light
		if minetest.get_node_light(pos, nil) > 12 then
			minetest.dig_node(pos)
			return
		end

		local pos0 = vector.add(pos, {x=-4, y=-1, z=-4})
		local pos1 = vector.add(pos, {x=4, y=1, z=4})

		-- Stop mushroom spread if a 9×3×9 box is too crowded
		if #minetest.find_nodes_in_area(pos0, pos1, node.name) >= 5 then
			return
		end

		local selected_pos = table.copy(pos)

		-- Do two random selections which may place the new mushroom in a 5×5×5 cube
		local random = {
			x = selected_pos.x + math.random(-1, 1),
			y = selected_pos.y + math.random(0, 1) - math.random(0, 1),
			z = selected_pos.z + math.random(-1, 1)
		}
		local random_node = minetest.get_node_or_nil(random)
		if not random_node or random_node.name ~= "air" then
			return
		end
		local node_under = minetest.get_node_or_nil({x = random.x, y = random.y - 1, z = random.z})
		if not node_under then
			return
		end

		if minetest.get_node_light(random, 0.5) > 12 or (minetest.get_item_group(node_under.name, "opaque") == 0) then
			return
		end
		local random2 = {
			x = random.x + math.random(-1, 1),
			y = random.y,
			z = random.z + math.random(-1, 1)
		}
		random_node = minetest.get_node_or_nil(random2)
		if not random_node or random_node.name ~= "air" then
			return
		end
		node_under = minetest.get_node_or_nil({x = random2.x, y = random2.y - 1, z = random2.z})
		if not node_under then
			return
		end
		if minetest.get_node_light(random2, 0.5) > 12 or (minetest.get_item_group(node_under.name, "opaque") == 0) or (minetest.get_item_group(node_under.name, "solid") == 0) then
			return
		end

		minetest.set_node(random2, {name = node.name})
	end
})
