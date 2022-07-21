local S = minetest.get_translator("mcla_chests")

local no_rotate, simple_rotate
if minetest.get_modpath("screwdriver") then
	no_rotate = screwdriver.disallow
	simple_rotate = function(pos, node, user, mode, new_param2)
		if screwdriver.rotate_simple(pos, node, user, mode, new_param2) ~= false then
			local nodename = node.name
		else
			return false
		end
	end
end

--[[ List of open chests.
Key: Player name
Value:
    If player is using a chest: { pos = <chest node position> }
    Otherwise: nil ]]
local open_chests = {}

-- Simple protection checking functions
local protection_check_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end
local protection_check_put_take = function(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end

-- To be called if a player closed a chest
local player_chest_close = function(player)
	local name = player:get_player_name()
	local open_chest = open_chests[name]
	if open_chest == nil then
		return
	end

	open_chests[name] = nil
end

-- This is a helper function to register both chests and trapped chests. Trapped chests will make use of the additional parameters
local register_chest = function(basename, desc, tiles_table)
-- START OF register_chest FUNCTION BODY
local drop = "mcla:"..basename

local double_chest_add_item = function(top_inv, bottom_inv, listname, stack)
	if not stack or stack:is_empty() then
		return
	end

	local name = stack:get_name()

	local top_off = function(inv, stack)
		for c, chest_stack in ipairs(inv:get_list(listname)) do
			if stack:is_empty() then
				break
			end

			if chest_stack:get_name() == name and chest_stack:get_free_space() > 0 then
				stack = chest_stack:add_item(stack)
				inv:set_stack(listname, c, chest_stack)
			end
		end

		return stack
	end

	stack = top_off(top_inv, stack)
	stack = top_off(bottom_inv, stack)

	if not stack:is_empty() then
		stack = top_inv:add_item(listname, stack)
		if not stack:is_empty() then
			bottom_inv:add_item(listname, stack)
		end
	end
end

local drop_items_chest = function(pos, oldnode, oldmetadata)
	local meta = minetest.get_meta(pos)
	local meta2 = meta
	if oldmetadata then
		meta:from_table(oldmetadata)
	end
	local inv = meta:get_inventory()
	for i=1,inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
	meta:from_table(meta2:to_table())
end

local on_chest_blast = function(pos)
	local node = minetest.get_node(pos)
	drop_items_chest(pos, node)
	minetest.remove_node(pos)
end

local function limit_put_list(stack, list)
	for _, other in ipairs(list) do
		stack = other:add_item(stack)
		if stack:is_empty() then
			break
		end
	end
	return stack
end

local function limit_put(stack, inv1, inv2)
	local leftover = ItemStack(stack)
	leftover = limit_put_list(leftover, inv1:get_list("main"))
	leftover = limit_put_list(leftover, inv2:get_list("main"))
	return stack:get_count() - leftover:get_count()
end

local small_name = "mcla:"..basename.."_small"
local left_name = "mcla:"..basename.."_left"

minetest.register_node(":mcla:"..basename, {
	description = desc,
	tiles = tiles_table.inv,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype2 = "facedir",
	stack_max = 64,
	sounds = mcla_sounds.node_sound_wood_defaults(),
	groups = {deco_block=1},
	on_construct = function(pos, node)
		local node = minetest.get_node(pos)
		node.name = small_name
		minetest.set_node(pos, node)
	end,
})

local function close_forms(basename, pos)
	local players = minetest.get_connected_players()
	for p=1, #players do
		if vector.distance(players[p]:get_pos(), pos) <= 30 then
			minetest.close_formspec(players[p]:get_player_name(), "mcla_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z)
		end
	end
end

minetest.register_node(":"..small_name, {
	description = desc,
	tiles = tiles_table.inv,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	paramtype2 = "facedir",
	stack_max = 64,
	drop = drop,
	groups = {handy=1,axey=1, container=2, deco_block=1, material_wood=1,flammable=-1,chest_entity=1, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = mcla_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local param2 = minetest.get_node(pos).param2
		local meta = minetest.get_meta(pos)
		--[[ This is a workaround for Minetest issue 5894
		<https://github.com/minetest/minetest/issues/5894>.
		Apparently if we don't do this, large chests initially don't work when
		placed at chunk borders, and some chests randomly don't work after
		placing. ]]
		-- FIXME: Remove this workaround when the bug has been fixed.
		-- BEGIN OF WORKAROUND --
		meta:set_string("workaround", "ignore_me")
		meta:set_string("workaround", nil) -- Done to keep metadata clean
		-- END OF WORKAROUND --
		local inv = meta:get_inventory()
		inv:set_size("main", 9*3)
		--[[ The "input" list is *another* workaround (hahahaha!) around the fact that Minetest
		does not support listrings to put items into an alternative list if the first one
		happens to be full. See <https://github.com/minetest/minetest/issues/5343>.
		This list is a hidden input-only list and immediately puts items into the appropriate chest.
		It is only used for listrings and hoppers. This workaround is not that bad because it only
		requires a simple “inventory allows” check for large chests.]]
		-- FIXME: Refactor the listrings as soon Minetest supports alternative listrings
		-- BEGIN OF LISTRING WORKAROUND
		inv:set_size("input", 1)
		-- END OF LISTRING WORKAROUND
		if minetest.get_node(mcla_util.get_double_container_neighbor_pos(pos, param2, "right")).name == "mcla:"..basename.."_small" then
			minetest.swap_node(pos, {name="mcla:"..basename.."_right",param2=param2})
			local p = mcla_util.get_double_container_neighbor_pos(pos, param2, "right")
			minetest.swap_node(p, { name = "mcla:"..basename.."_left", param2 = param2 })
		elseif minetest.get_node(mcla_util.get_double_container_neighbor_pos(pos, param2, "left")).name == "mcla:"..basename.."_small" then
			minetest.swap_node(pos, {name="mcla:"..basename.."_left",param2=param2})
			local p = mcla_util.get_double_container_neighbor_pos(pos, param2, "left")
			minetest.swap_node(p, { name = "mcla:"..basename.."_right", param2 = param2 })
		else
			minetest.swap_node(pos, { name = "mcla:"..basename.."_small", param2 = param2 })
		end
	end,
	after_dig_node = drop_items_chest,
	on_blast = on_chest_blast,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		if listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			inv:add_item("main", stack)
		end
		-- END OF LISTRING WORKAROUND
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
	_mcla_blast_resistance = 2.5,
	_mcla_hardness = 2.5,

	on_rightclick = function(pos, node, clicker)
		if minetest.registered_nodes[minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name].groups.opaque == 1 then
			-- won't open if there is no space from the top
			return false
		end

		local chest_formspec = mcla_formspec.formspec_wrapper([[
			size[10,9.4,true]
			no_prepend[]
			real_coordinates[true]
			bgcolor[blue;true]
			listcolors[#0000ff00;#ffffff80]
			style_type[list;spacing=0.07,0.07;size=0.95,0.95]
			image[0,0;10,9.4;mcla_chests_gui.png]
			list[nodemeta:${chestpos};main;0.46,0.95;9,3;0]
			list[current_player;main;0.46,8;9,1;0]
			list[current_player;main;0.46,4.72;9,3;9]
			listring[nodemeta:${chestpos};main]
			listring[current_player;main]
		]], {
			chestpos = pos.x..","..pos.y..","..pos.z
		})

		minetest.show_formspec(clicker:get_player_name(), "mcla_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z, chest_formspec)
	end,

	on_destruct = function(pos)
		close_forms(basename, pos)
	end,
	on_rotate = simple_rotate,
})

minetest.register_node(":"..left_name, {
	drawtype = "nodebox",
	tiles = tiles_table.left,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, container=5,not_in_creative_inventory=1, material_wood=1,flammable=-1,chest_entity=1,double_chest=1},
	drop = drop,
	is_ground_content = false,
	sounds = mcla_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local n = minetest.get_node(pos)
		local param2 = n.param2
		local p = mcla_util.get_double_container_neighbor_pos(pos, param2, "left")
		if not p or minetest.get_node(p).name ~= "mcla:"..basename.."_right" then
			n.name = "mcla:"..basename.."_small"
			minetest.swap_node(pos, n)
		end
	end,
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == small_name then
			return
		end

		close_forms(basename, pos)

		local param2 = n.param2
		local p = mcla_util.get_double_container_neighbor_pos(pos, param2, "left")
		if not p or minetest.get_node(p).name ~= "mcla:"..basename.."_right" then
			return
		end
		close_forms(basename, p)

		minetest.swap_node(p, { name = small_name, param2 = param2 })
	end,
	after_dig_node = drop_items_chest,
	on_blast = on_chest_blast,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		-- BEGIN OF LISTRING WORKAROUND
		elseif listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			local other_pos = mcla_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "left")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})
			return limit_put(stack, inv, other_inv)
			--[[if inv:room_for_item("main", stack) then
				return -1
			else

				if other_inv:room_for_item("main", stack) then
					return -1
				else
					return 0
				end
			end]]--
		-- END OF LISTRING WORKAROUND
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		if listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			local other_pos = mcla_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "left")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})

			inv:set_stack("input", 1, nil)

			double_chest_add_item(inv, other_inv, "main", stack)
		end
		-- END OF LISTRING WORKAROUND
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
	_mcla_blast_resistance = 2.5,
	_mcla_hardness = 2.5,

	on_rightclick = function(pos, node, clicker)
		local pos_other = mcla_util.get_double_container_neighbor_pos(pos, node.param2, "left")
		if minetest.registered_nodes[minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name].groups.opaque == 1
			or minetest.registered_nodes[minetest.get_node({x = pos_other.x, y = pos_other.y + 1, z = pos_other.z}).name].groups.opaque == 1 then
				-- won't open if there is no space from the top
				return false
		end

		minetest.show_formspec(clicker:get_player_name(),
		"mcla_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,
		"size[9,11.5]"..
		"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Large Chest"))).."]"..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]"..
		mcla_formspec.get_itemslot_bg(0,0.5,9,3)..
		"list[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main;0,3.5;9,3;]"..
		mcla_formspec.get_itemslot_bg(0,3.5,9,3)..
		"label[0,7;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
		"list[current_player;main;0,7.5;9,3;9]"..
		mcla_formspec.get_itemslot_bg(0,7.5,9,3)..
		"list[current_player;main;0,10.75;9,1;]"..
		mcla_formspec.get_itemslot_bg(0,10.75,9,1)..
		-- BEGIN OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";input]"..
		-- END OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]"..
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main]")
	end,
	on_rotate = no_rotate,
})

minetest.register_node(":mcla:"..basename.."_right", {
	drawtype = "nodebox",
	paramtype2 = "facedir",
	tiles = tiles_table.right,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	groups = {handy=1,axey=1, container=6,not_in_creative_inventory=1, material_wood=1,flammable=-1,double_chest=2},
	drop = drop,
	is_ground_content = false,
	sounds = mcla_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local n = minetest.get_node(pos)
		local param2 = n.param2
		local p = mcla_util.get_double_container_neighbor_pos(pos, param2, "right")
		if not p or minetest.get_node(p).name ~= "mcla:"..basename.."_left" then
			n.name = "mcla:"..basename.."_small"
			minetest.swap_node(pos, n)
		end
	end,
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == small_name then
			return
		end

		close_forms(basename, pos)

		local param2 = n.param2
		local p = mcla_util.get_double_container_neighbor_pos(pos, param2, "right")
		if not p or minetest.get_node(p).name ~= "mcla:"..basename.."_left" then
			return
		end
		close_forms(basename, p)

		minetest.swap_node(p, { name = small_name, param2 = param2 })
		--local meta = minetest.get_meta(pos)
	end,
	after_dig_node = drop_items_chest,
	on_blast = on_chest_blast,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		-- BEGIN OF LISTRING WORKAROUND
		elseif listname == "input" then
			local other_pos = mcla_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "right")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})
			local inv = minetest.get_inventory({type="node", pos=pos})
			--[[if other_inv:room_for_item("main", stack) then
				return -1
			else
				if inv:room_for_item("main", stack) then
					return -1
				else
					return 0
				end
			end--]]
			return limit_put(stack, other_inv, inv)
		-- END OF LISTRING WORKAROUND
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		if listname == "input" then
			local other_pos = mcla_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "right")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})
			local inv = minetest.get_inventory({type="node", pos=pos})

			inv:set_stack("input", 1, nil)

			double_chest_add_item(other_inv, inv, "main", stack)
		end
		-- END OF LISTRING WORKAROUND
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
	_mcla_blast_resistance = 2.5,
	_mcla_hardness = 2.5,

	on_rightclick = function(pos, node, clicker)
		local pos_other = mcla_util.get_double_container_neighbor_pos(pos, node.param2, "right")
		if minetest.registered_nodes[minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name].groups.opaque == 1
			or minetest.registered_nodes[minetest.get_node({x = pos_other.x, y = pos_other.y + 1, z = pos_other.z}).name].groups.opaque == 1 then
				-- won't open if there is no space from the top
				return false
		end

		minetest.show_formspec(clicker:get_player_name(),
		"mcla_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,

		"size[9,11.5]"..
		"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Large Chest"))).."]"..
		"list[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main;0,0.5;9,3;]"..
		mcla_formspec.get_itemslot_bg(0,0.5,9,3)..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,3.5;9,3;]"..
		mcla_formspec.get_itemslot_bg(0,3.5,9,3)..
		"label[0,7;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
		"list[current_player;main;0,7.5;9,3;9]"..
		mcla_formspec.get_itemslot_bg(0,7.5,9,3)..
		"list[current_player;main;0,10.75;9,1;]"..
		mcla_formspec.get_itemslot_bg(0,10.75,9,1)..
		-- BEGIN OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";input]"..
		-- END OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main]"..
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]")
	end,
	on_rotate = no_rotate,
})

-- END OF register_chest FUNCTION BODY
end

register_chest("chest",
	S("Chest"),
	{
		inv = {
			"mcla_chests_top.png", "mcla_chests_top.png",
			"mcla_chests_side.png", "mcla_chests_side.png",
			"mcla_chests_side.png", "mcla_chests_front.png"},
		left = {
			"mcla_chests_top.png", "mcla_chests_top.png",
			"mcla_chests_side.png", "mcla_chests_side.png",
			"mcla_chests_back_big.png^[transformFX", "mcla_chests_front_big.png"},
		right = {
			"mcla_chests_top.png", "mcla_chests_top.png",
			"mcla_chests_side.png", "mcla_chests_side.png",
			"mcla_chests_back_big.png", "mcla_chests_front_big.png^[transformFX"},
	}
)

-- Disable chest when it has been closed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcla_chests:") == 1 then
		if fields.quit then
			player_chest_close(player)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	player_chest_close(player)
end)

minetest.register_craft({
	output = 'mcla:chest',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', '', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = 'fuel',
	recipe = 'mcla:chest',
	burntime = 15
})
