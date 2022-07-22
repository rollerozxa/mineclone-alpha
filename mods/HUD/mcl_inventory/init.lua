
mcla_inventory = {}

-- Returns a single itemstack in the given inventory to the main inventory, or drop it when there's no space left
function return_item(itemstack, dropper, pos, inv)
	if dropper:is_player() then
		-- Return to main inventory
		if inv:room_for_item("main", itemstack) then
			inv:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
			p.x = p.x+(math.random(1,3)*0.2)
			p.z = p.z+(math.random(1,3)*0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x*4
				v.y = v.y*4 + 2
				v.z = v.z*4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

-- Return items in the given inventory list (name) to the main inventory, or drop them if there is no space left
function return_fields(player, name)
	local inv = player:get_inventory()
	local list = inv:get_list(name)
	if not list then return end
	for i,stack in ipairs(list) do
		return_item(stack, player, player:get_pos(), inv)
		stack:clear()
		inv:set_stack(name, i, stack)
	end
end

local function set_inventory(player, armor_change_only)
	if minetest.is_creative_enabled(player:get_player_name()) and false then
		if armor_change_only then
			-- Stay on survival inventory plage if only the armor has been changed
			mcla_inventory.set_creative_formspec(player, 0, 0, nil, nil, "inv")
		else
			mcla_inventory.set_creative_formspec(player, 0, 1)
		end
		return
	end
	local inv = player:get_inventory()
	inv:set_width("craft", 2)
	inv:set_size("craft", 4)

	local player_name = player:get_player_name()

	-- Show armor and player image
	local armor_slots = {"helmet", "chestplate", "leggings", "boots"}
	local armor_slot_imgs = ""
	for a=1,4 do
		if inv:get_stack("armor", a+1):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[0.47,"..((a-0.5))..";0.9,0.9;mcla_inventory_empty_armor_slot_"..armor_slots[a]..".png]"
		end
	end

	local form = mcla_formspec.formspec_wrapper([[
		size[10,9.4,true]
		no_prepend[]
		real_coordinates[true]
		bgcolor[blue;true]
		listcolors[#0000ff00;#ffffff80]
		style_type[list;spacing=0.07,0.07;size=0.95,0.95]
		image[0,0;10,9.4;inventory.png]
		box[1.44,0.25;3,4.2;black]
		model[1.45,0.85;3,3.5;playermodel;character.b3d;character.png;0,180;false;false;0,79;30]
		${armor_slot_imgs}
		list[detached:${player_name}_armor;armor;0.46,0.46;1,1;1]
		list[detached:${player_name}_armor;armor;0.46,1.46;1,1;2]
		list[detached:${player_name}_armor;armor;0.46,2.46;1,1;3]
		list[detached:${player_name}_armor;armor;0.46,3.46;1,1;4]
		list[current_player;craft;4.989,1.45;2,2;0]
		list[current_player;craftpreview;8.18,2.03;1,1;0]
		list[current_player;main;0.46,8;9,1;0]
		list[current_player;main;0.46,4.72;9,3;9]

		listring[current_player;main]
		listring[current_player;craft]
		listring[current_player;main]
		listring[detached:${player_name}_armor;armor]
	]], {
		player_name = player_name,
		armor_slot_imgs = armor_slot_imgs
	})

	player:set_inventory_formspec(form)
end

-- Drop items in craft grid and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		return_fields(player,"craft")
		if (formname == "" or formname == "main") then --not minetest.is_creative_enabled(player:get_player_name()) and
			set_inventory(player)
		end
	end
end)

--if not minetest.is_creative_enabled("") then
	mcla_inventory.update_inventory_formspec = function(player)
		set_inventory(player)
	end
--end

-- Drop crafting grid items on leaving
minetest.register_on_leaveplayer(function(player)
	return_fields(player, "craft")
end)

minetest.register_on_joinplayer(function(player)
	--init inventory
	player:get_inventory():set_width("main", 9)
	player:get_inventory():set_size("main", 36)

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcla_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcla_inventory_hotbar_selected.png")

	local set_player_armor_original = armor.set_player_armor
	local update_inventory_original = armor.update_inventory
	armor.set_player_armor = function(self, player)
		set_player_armor_original(self, player)
	end
	armor.update_inventory = function(self, player)
		update_inventory_original(self, player)
		set_inventory(player, true)
	end
	armor:set_player_armor(player)
	armor:update_inventory(player)

	-- In Creative Mode, the initial inventory setup is handled in creative.lua
	--if not minetest.is_creative_enabled(player:get_player_name()) then
		set_inventory(player)
	--end

	--[[ Make sure the crafting grid is empty. Why? Because the player might have
	items remaining in the crafting grid from the previous join; this is likely
	when the server has been shutdown and the server didn't clean up the player
	inventories. ]]
	return_fields(player, "craft")
end)
