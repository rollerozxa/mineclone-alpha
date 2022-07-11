-- Cactus and Sugar Cane

local S = minetest.get_translator("mcla_core")

minetest.register_node(":mcla:cactus", {
	description = S("Cactus"),
	drawtype = "nodebox",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	tiles = {"mcl_core_cactus_top.png", "mcl_core_cactus_bottom.png", "mcl_core_cactus_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1, attached_node=1, plant=1, deco_block=1, },
	sounds = mcla_sounds.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {-7/16, -8/16, -7/16,  7/16, 7/16,  7/16}, -- Main body. slightly lower than node box
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, 7/16, 8/16, 7/16},
		},
	},
	-- Only allow to place cactus on sand or cactus
	on_place = mcla_util.generate_on_place_plant_function(function(pos, node)
		local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
		if not node_below then return false end
		return (node_below.name == "mcla:cactus" or minetest.get_item_group(node_below.name, "sand") == 1)
	end),
	_mcla_blast_resistance = 0.4,
	_mcla_hardness = 0.4,
})

minetest.register_node(":mcla:reeds", {
	description = S("Sugar Canes"),
	drawtype = "plantlike",
	tiles = {"mcl_core_papyrus.png"},
	inventory_image = "mcl_core_reeds.png",
	wield_image = "mcl_core_reeds.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main Body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -6/16, 6/16, 8/16, 6/16},
		},
	},
	stack_max = 64,
	groups = {dig_immediate=3, craftitem=1, deco_block=1, plant=1 },
	sounds = mcla_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	on_place = mcla_util.generate_on_place_plant_function(function(place_pos, place_node)
		local soil_pos = {x=place_pos.x, y=place_pos.y-1, z=place_pos.z}
		local soil_node = minetest.get_node_or_nil(soil_pos)
		if not soil_node then return false end
		local snn = soil_node.name -- soil node name

		-- Placement rules:
		-- * On top of group:soil_sugarcane AND next to water or frosted ice. OR
		-- * On top of sugar canes
		-- * Not inside liquid
		if snn == "mcla:reeds" then
			return true
		elseif minetest.get_item_group(snn, "soil_sugarcane") == 0 then
			return false
		end
		local place_node = minetest.get_node(place_pos)
		local pdef = minetest.registered_nodes[place_node.name]
		if pdef and pdef.liquidtype ~= "none" then
			return false
		end

		-- Legal water position rules are the same as for decoration spawn_by rules.
		-- This differs from MC, which does not allow diagonal neighbors
		-- and neighbors 1 layer above.
		local np1 = {x=soil_pos.x-1, y=soil_pos.y, z=soil_pos.z-1}
		local np2 = {x=soil_pos.x+1, y=soil_pos.y+1, z=soil_pos.z+1}
		if #minetest.find_nodes_in_area(np1, np2, {"group:water", "group:frosted_ice"}) > 0 then
			-- Water found! Sugar canes are happy! :-)
			return true
		end

		-- No water found! Sugar canes are not amuzed and refuses to be placed. :-(
		return false

	end),
	_mcla_blast_resistance = 0,
	_mcla_hardness = 0,
})
