local S = minetest.get_translator("mcla_bows")

mcla_bows = {}

-- local arrows = {
-- 	["mcla:arrow"] = "mcla:arrow_entity",
-- }

local GRAVITY = 9.81
local BOW_DURABILITY = 385

-- Charging time in microseconds
local BOW_CHARGE_TIME_HALF = 200000 -- bow level 1
local BOW_CHARGE_TIME_FULL = 500000 -- bow level 2 (full charge)

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_BOW_SPEED = tonumber(minetest.settings:get("movement_speed_crouch")) / tonumber(minetest.settings:get("movement_speed_walk"))

-- TODO: Use Minecraft speed (ca. 53 m/s)
-- Currently nerfed because at full speed the arrow would easily get out of the range of the loaded map.
local BOW_MAX_SPEED = 15

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from minetest.get_us_time
             in which the charging has started
]]
local bow_load = {}

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

mcla_bows.shoot_arrow = function(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrow_item:gsub("mcla", "mcla_bows").."_entity")
	if power == nil then
		power = BOW_MAX_SPEED --19
	end
	if damage == nil then
		damage = 3
	end
	local knockback
	if bow_stack then

	end
	obj:set_velocity({x=dir.x*power, y=dir.y*power, z=dir.z*power})
	obj:set_acceleration({x=0, y=-GRAVITY, z=0})
	obj:set_yaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._startpos = pos
	le._knockback = knockback
	le._collectable = collectable
	minetest.sound_play("mcl_bows_bow_shoot", {pos=pos, max_hear_distance=16}, true)
	if shooter ~= nil and shooter:is_player() then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = shooter
		end
		obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local get_arrow = function(player)
	local inv = player:get_inventory()
	local arrow_stack, arrow_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and minetest.get_item_group(it:get_name(), "ammo_bow") ~= 0 then
			arrow_stack = it
			arrow_stack_id = i
			break
		end
	end
	return arrow_stack, arrow_stack_id
end

local player_shoot_arrow = function(itemstack, player, power, damage, is_critical)
	local arrow_stack, arrow_stack_id = get_arrow(player)
	local arrow_itemstring
	local has_infinity_enchantment = false
	local infinity_used = false

	if minetest.is_creative_enabled(player:get_player_name()) then
		if arrow_stack then
			arrow_itemstring = arrow_stack:get_name()
		else
			arrow_itemstring = "mcla:arrow"
		end
	else
		if not arrow_stack then
			return false
		end
		arrow_itemstring = arrow_stack:get_name()
		if has_infinity_enchantment and minetest.get_item_group(arrow_itemstring, "ammo_bow_regular") > 0 then
			infinity_used = true
		else
			arrow_stack:take_item()
		end
		local inv = player:get_inventory()
		inv:set_stack("main", arrow_stack_id, arrow_stack)
	end
	if not arrow_itemstring then
		return false
	end
	local playerpos = player:get_pos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	mcla_bows.shoot_arrow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), not infinity_used)
	return true
end

-- Bow item, uncharged state
minetest.register_tool(":mcla:bow", {
	description = S("Bow"),
	inventory_image = "mcla_bows_bow.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	stack_max = 1,
	range = 4,
	on_place = function(itemstack, player, pointed_thing)
		if pointed_thing and pointed_thing.type == "node" then
			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if player and not player:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
				end
			end
		end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack)
		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	groups = {weapon=1,weapon_ranged=1,bow=1},
	_mcla_uses = 385,
})

controls.register_on_press(function(player, key, time)
	if key~="RMB" then return end
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if (wielditem:get_name()=="mcla:bow") then

		-- Calculate damage and speed
		-- Fully charged
		local is_critical = false
		speed = BOW_MAX_SPEED
		local r = math.random(1,4)
		if r == 1 then
			-- 25% chance for critical hit
			damage = 10
			is_critical = true
		else
			damage = 9
		end

		has_shot = player_shoot_arrow(wielditem, player, speed, damage, is_critical)

		wielditem:set_name("mcla:bow")

		if has_shot and not minetest.is_creative_enabled(player:get_player_name()) then
			local durability = BOW_DURABILITY
			wielditem:add_wear(65535/durability)
		end
		player:set_wielded_item(wielditem)
	end
end)

minetest.register_craft({
	output = 'mcla:bow',
	recipe = {
		{'', 'mcla:stick', 'mcla:string'},
		{'mcla:stick', '', 'mcla:string'},
		{'', 'mcla:stick', 'mcla:string'},
	}
})
minetest.register_craft({
	output = 'mcla:bow',
	recipe = {
		{'mcla:string', 'mcla:stick', ''},
		{'mcla:string', '', 'mcla:stick'},
		{'mcla:string', 'mcla:stick', ''},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bow",
	burntime = 15,
})
