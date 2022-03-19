local S = minetest.get_translator("mesecons_delayer")

local DELAYS = { 0.1, 0.2, 0.3, 0.4 }
local DEFAULT_DELAY = DELAYS[1]

-- Function that get the input/output rules of the delayer
local delayer_get_output_rules = function(node)
	local rules = {{x = -1, y = 0, z = 0, spread=true}}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local delayer_get_input_rules = function(node)
	local rules = {{x = 1, y = 0, z = 0}}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

-- Return the sides of a delayer.
-- Those are used to toggle the lock state.
local delayer_get_sides = function(node)
	local rules = {
		{x = 0, y = 0, z = -1},
		{x = 0, y = 0, z =  1},
	}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

-- Functions that are called after the delay time
local delayer_activate = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	local time = def.delayer_time
	minetest.set_node(pos, {name=def.delayer_onstate, param2=node.param2})
	mesecon.queue:add_action(pos, "receptor_on", {delayer_get_output_rules(node)}, time, nil)
end

local delayer_deactivate = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	local time = def.delayer_time
	minetest.set_node(pos, {name=def.delayer_offstate, param2=node.param2})
	mesecon.queue:add_action(pos, "receptor_off", {delayer_get_output_rules(node)}, time, nil)
end

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

-- Register the 2 (states) x 4 (delay times) delayers

for i = 1, 4 do
local groups = {}
if i == 1 then
	groups = {dig_immediate=3,dig_by_water=1,destroy_by_lava_flow=1,attached_node=1,redstone_repeater=i}
else
	groups = {dig_immediate=3,dig_by_water=1,destroy_by_lava_flow=1,attached_node=1,redstone_repeater=i,not_in_creative_inventory=1}
end

local delaytime = DELAYS[i]

local boxes
if i == 1 then
boxes = {
	{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
	{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
	{ -1/16, -6/16, 0/16, 1/16, -1/16, 2/16},     -- moved torch
}
elseif i == 2 then
boxes = {
	{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
	{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
	{ -1/16, -6/16, -2/16, 1/16, -1/16, 0/16},     -- moved torch
}
elseif i == 3 then
boxes = {
	{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
	{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
	{ -1/16, -6/16, -4/16, 1/16, -1/16, -2/16},     -- moved torch
}
elseif i == 4 then
boxes = {
	{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },		-- the main slab
	{ -1/16, -6/16, 6/16, 1/16, -1/16, 4/16},     -- still torch
	{ -1/16, -6/16, -6/16, 1/16, -1/16, -4/16},     -- moved torch
}
end

local icon
if i == 1 then
	icon = "mesecons_delayer_item.png"
end

local desc_off
if i == 1 then
	desc_off = S("Redstone Repeater")
else
	desc_off = S("Redstone Repeater (Delay @1)", i)
end

minetest.register_node("mesecons_delayer:delayer_off_"..tostring(i), {
	description = desc_off,
	inventory_image = icon,
	wield_image = icon,
	drawtype = "nodebox",
	tiles = {
		"mesecons_delayer_off.png",
		"mcl_stairs_stone_slab_top.png",
		"mesecons_delayer_sides_off.png",
		"mesecons_delayer_sides_off.png",
		"mesecons_delayer_ends_off.png",
		"mesecons_delayer_ends_off.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	wield_image = "mesecons_delayer_off.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = groups,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	is_ground_content = false,
	drop = 'mesecons_delayer:delayer_off_1',
	on_rightclick = function (pos, node, clicker)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		if node.name=="mesecons_delayer:delayer_off_1" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_off_2", param2=node.param2})
		elseif node.name=="mesecons_delayer:delayer_off_2" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_off_3", param2=node.param2})
		elseif node.name=="mesecons_delayer:delayer_off_3" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_off_4", param2=node.param2})
		elseif node.name=="mesecons_delayer:delayer_off_4" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_off_1", param2=node.param2})
		end
	end,
	delayer_time = delaytime,
	delayer_onstate = "mesecons_delayer:delayer_on_"..tostring(i),
	delayer_lockstate = "mesecons_delayer:delayer_off_locked",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		receptor =
		{
			state = mesecon.state.off,
			rules = delayer_get_output_rules
		},
		effector =
		{
			rules = delayer_get_input_rules,
			action_on = delayer_activate
		}
	},
	on_rotate = on_rotate,
})


minetest.register_node("mesecons_delayer:delayer_on_"..tostring(i), {
	description = S("Redstone Repeater (Delay @1, Powered)", i),
	drawtype = "nodebox",
	tiles = {
		"mesecons_delayer_on.png",
		"mcl_stairs_stone_slab_top.png",
		"mesecons_delayer_sides_on.png",
		"mesecons_delayer_sides_on.png",
		"mesecons_delayer_ends_on.png",
		"mesecons_delayer_ends_on.png",
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = {dig_immediate = 3, dig_by_water=1,destroy_by_lava_flow=1,  attached_node=1, redstone_repeater=i, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	is_ground_content = false,
	drop = 'mesecons_delayer:delayer_off_1',
	on_rightclick = function (pos, node, clicker)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		if node.name=="mesecons_delayer:delayer_on_1" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_on_2",param2=node.param2})
		elseif node.name=="mesecons_delayer:delayer_on_2" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_on_3",param2=node.param2})
		elseif node.name=="mesecons_delayer:delayer_on_3" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_on_4",param2=node.param2})
		elseif node.name=="mesecons_delayer:delayer_on_4" then
			minetest.set_node(pos, {name="mesecons_delayer:delayer_on_1",param2=node.param2})
		end
	end,
	delayer_time = delaytime,
	delayer_offstate = "mesecons_delayer:delayer_off_"..tostring(i),
	delayer_lockstate = "mesecons_delayer:delayer_on_locked",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		receptor =
		{
			state = mesecon.state.on,
			rules = delayer_get_output_rules
		},
		effector =
		{
			rules = delayer_get_input_rules,
			action_off = delayer_deactivate
		}
	},
	on_rotate = on_rotate,
})

end

minetest.register_craft({
	output = "mesecons_delayer:delayer_off_1",
	recipe = {
		{"mesecons_torch:mesecon_torch_on", "mesecons:redstone", "mesecons_torch:mesecon_torch_on"},
		{"mcl_core:stone","mcl_core:stone", "mcl_core:stone"},
	}
})
