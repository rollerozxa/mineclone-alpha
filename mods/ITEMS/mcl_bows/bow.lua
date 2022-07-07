local S = minetest.get_translator("mcl_bows")

mcl_bows = {}

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
local BOW_MAX_SPEED = 40

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

mcl_bows.shoot_arrow = function(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrow_item.."_entity")
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

	mcl_bows.shoot_arrow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), not infinity_used)
	return true
end

-- Bow item, uncharged state
minetest.register_tool(":mcla:bow", {
	description = S("Bow"),
	inventory_image = "mcl_bows_bow.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() return end,
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
	_mcl_uses = 385,
})

-- Iterates through player inventory and resets all the bows in "charging" state back to their original stage
local reset_bows = function(player)
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if stack:get_name() == "mcla:bow" then
			stack:get_meta():set_string("active", "")
		elseif stack:get_name()=="mcla:bow_0" or stack:get_name()=="mcla:bow_1" or stack:get_name()=="mcla:bow_2" then
			stack:set_name("mcla:bow")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		end
	end
	inv:set_list("main", list)
end

-- Resets the bow charging state and player speed. To be used when the player is no longer charging the bow
local reset_bow_state = function(player, also_reset_bows)
	bow_load[player:get_player_name()] = nil
	bow_index[player:get_player_name()] = nil
	playerphysics.remove_physics_factor(player, "speed", "mcla:use_bow")
	if also_reset_bows then
		reset_bows(player)
	end
end

-- Bow in charging state
for level=0, 2 do
	minetest.register_tool(":mcla:bow_"..level, {
		description = S("Bow"),
		inventory_image = "mcl_bows_bow_"..level..".png",
		wield_scale = { x = 1.8, y = 1.8, z = 1 },
		stack_max = 1,
		range = 0, -- Pointing range to 0 to prevent punching with bow :D
		groups = {not_in_creative_inventory=1, not_in_craft_guide=1, bow=1},
		-- Trick to disable digging as well
		on_use = function() return end,
		on_drop = function(itemstack, dropper, pos)
			reset_bow_state(dropper)
			itemstack:get_meta():set_string("active", "")
			itemstack:set_name("mcla:bow")
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:take_item()
			return itemstack
		end,
		-- Prevent accidental interaction with itemframes and other nodes
		on_place = function(itemstack)
			return itemstack
		end,
		_mcl_uses = 385,
	})
end


controls.register_on_release(function(player, key, time)
	if key~="RMB" then return end
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if (wielditem:get_name()=="mcla:bow_0" or wielditem:get_name()=="mcla:bow_1" or wielditem:get_name()=="mcla:bow_2") then
		local has_shot = false

		local enchanted = false
		local speed, damage
		local p_load = bow_load[player:get_player_name()]
		local charge
		-- Type sanity check
		if type(p_load) == "number" then
			charge = minetest.get_us_time() - p_load
		else
			-- In case something goes wrong ...
			-- Just assume minimum charge.
			charge = 0
			minetest.log("warning", "[mcl_bows] Player "..player:get_player_name().." fires arrow with non-numeric bow_load!")
		end
		charge = math.max(math.min(charge, BOW_CHARGE_TIME_FULL), 0)

		local charge_ratio = charge / BOW_CHARGE_TIME_FULL
		charge_ratio = math.max(math.min(charge_ratio, 1), 0)

		-- Calculate damage and speed
		-- Fully charged
		local is_critical = false
		if charge >= BOW_CHARGE_TIME_FULL then
			speed = BOW_MAX_SPEED
			local r = math.random(1,4)
			if r == 1 then
				-- 25% chance for critical hit
				damage = 10
				is_critical = true
			else
				damage = 9
			end
		-- Partially charged
		else
			-- Linear speed and damage increase
			speed = math.max(4, BOW_MAX_SPEED * charge_ratio)
			damage = math.max(1, math.floor(9 * charge_ratio))
		end

		has_shot = player_shoot_arrow(wielditem, player, speed, damage, is_critical)

		wielditem:set_name("mcla:bow")

		if has_shot and not minetest.is_creative_enabled(player:get_player_name()) then
			local durability = BOW_DURABILITY
			wielditem:add_wear(65535/durability)
		end
		player:set_wielded_item(wielditem)
		reset_bow_state(player, true)
	end
end)

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = minetest.is_creative_enabled(name)
	if key ~= "RMB" or not (creative or get_arrow(player)) then
		return
	end
	local inv = minetest.get_inventory({type="player", name=name})
	local wielditem = player:get_wielded_item()
	if bow_load[name] == nil and (wielditem:get_name()=="mcla:bow") and wielditem:get_meta():get("active") and (creative or get_arrow(player)) then
		wielditem:set_name("mcla:bow_0")
		player:set_wielded_item(wielditem)
		-- Slow player down when using bow
		playerphysics.add_physics_factor(player, "speed", "mcla:use_bow", PLAYER_USE_BOW_SPEED)
		bow_load[name] = minetest.get_us_time()
		bow_index[name] = player:get_wield_index()
	else
		if player:get_wield_index() == bow_index[name] then
			if type(bow_load[name]) == "number" then
				if wielditem:get_name() == "mcla:bow_0" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("mcla:bow_1")
				elseif wielditem:get_name() == "mcla:bow_1" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("mcla:bow_2")
				end
			else
				if wielditem:get_name() == "mcla:bow_0" or wielditem:get_name() == "mcla:bow_1" or wielditem:get_name() == "mcla:bow_2" then
					wielditem:set_name("mcla:bow")
				end
			end
			player:set_wielded_item(wielditem)
		else
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		local controls = player:get_player_control()
		if type(bow_load[name]) == "number" and ((wielditem:get_name()~="mcla:bow_0" and wielditem:get_name()~="mcla:bow_1" and wielditem:get_name()~="mcla:bow_2") or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	reset_bows(player)
end)

minetest.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
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
