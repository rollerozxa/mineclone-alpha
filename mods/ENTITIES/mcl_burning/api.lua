local S = minetest.get_translator("mcla_burning")

function mcla_burning.get_default(datatype)
	local default_table = {string = "", float = 0.0, int = 0, bool = false}
	return default_table[datatype]
end

function mcla_burning.get(obj, datatype, name)
	local key
	if obj:is_player() then
		local meta = obj:get_meta()
		return meta["get_" .. datatype](meta, "mcla_burning:" .. name)
	else
		local luaentity = obj:get_luaentity()
		return luaentity and luaentity["mcla_burning_" .. name] or mcla_burning.get_default(datatype)
	end
end

function mcla_burning.set(obj, datatype, name, value)
	if obj:is_player() then
		local meta = obj:get_meta()
		meta["set_" .. datatype](meta, "mcla_burning:" .. name, value or mcla_burning.get_default(datatype))
	else
		local luaentity = obj:get_luaentity()
		if mcla_burning.get_default(datatype) == value then
			value = nil
		end
		luaentity["mcla_burning_" .. name] = value
	end
end

function mcla_burning.is_burning(obj)
	return mcla_burning.get(obj, "float", "burn_time") > 0
end

function mcla_burning.is_affected_by_rain(obj)
	--return mcla_weather.get_weather() == "rain" and mcla_weather.is_outdoor(obj:get_pos())
	return false
end

function mcla_burning.get_collisionbox(obj, smaller)
	local box = obj:get_properties().collisionbox
	local minp, maxp = vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
	if smaller then
		local s_vec = vector.new(0.1, 0.1, 0.1)
		minp = vector.add(minp, s_vec)
		maxp = vector.subtract(maxp, s_vec)
	end
	return minp, maxp
end

function mcla_burning.get_touching_nodes(obj, nodenames)
	local pos = obj:get_pos()
	local box = obj:get_properties().collisionbox
	local minp, maxp = mcla_burning.get_collisionbox(obj, true)
	local nodes = minetest.find_nodes_in_area(vector.add(pos, minp), vector.add(pos, maxp), nodenames)
	return nodes
end

function mcla_burning.get_highest_group_value(obj, groupname)
	local nodes = mcla_burning.get_touching_nodes(obj, "group:" .. groupname, true)
	local highest_group_value = 0

	for _, pos in pairs(nodes) do
		local node = minetest.get_node(pos)
		local group_value = minetest.get_item_group(node.name, groupname)
		if group_value > highest_group_value then
			highest_group_value = group_value
		end
	end

	return highest_group_value
end

function mcla_burning.damage(obj)
	local luaentity = obj:get_luaentity()
	local health

	if luaentity then
		health = luaentity.health
	end

	local hp = health or obj:get_hp()

	if hp <= 0 then
		return
	end

	local do_damage = true

	if obj:is_player() then
		local name = obj:get_player_name()
		armor.last_damage_types[name] = "fire"
		local deathmsg = S("@1 burned to death.", name)
		local reason = mcla_burning.get(obj, "string", "reason")
		if reason ~= "" then
			deathmsg = S("@1 was burned by @2.", name, reason)
		end
		mcla_death_messages.player_damage(obj, deathmsg)
	else
		if luaentity.fire_damage_resistant then
			do_damage = false
		end
	end

	if do_damage then
		local new_hp = hp - 1
		if health then
			luaentity.health = new_hp
		else
			obj:set_hp(new_hp)
		end
	end
end

function mcla_burning.set_on_fire(obj, burn_time, reason)
	local luaentity = obj:get_luaentity()
	if luaentity and luaentity.fire_resistant then
		return
	end

	local old_burn_time = mcla_burning.get(obj, "float", "burn_time")
	local max_fire_prot_lvl = 0

	if obj:is_player() then
		if minetest.is_creative_enabled(obj:get_player_name()) then
			burn_time = burn_time / 100
		end
	end

	if max_fire_prot_lvl > 0 then
		burn_time = burn_time - math.floor(burn_time * max_fire_prot_lvl * 0.15)
	end

	if old_burn_time <= burn_time then
		local sound_id = mcla_burning.get(obj, "int", "sound_id")
		if sound_id == 0 then
			sound_id = minetest.sound_play("fire_fire", {
				object = obj,
				gain = 0.18,
				max_hear_distance = 16,
				loop = true,
			}) + 1
		end

		local already_burning = mcla_burning.is_burning(obj)


		mcla_burning.set(obj, "float", "burn_time", burn_time)
		mcla_burning.set(obj, "string", "reason", reason)

		if already_burning then
			return
		end

		local hud_id
		if obj:is_player() then
			hud_id = mcla_burning.get(obj, "int", "hud_id")
			if hud_id == 0 then
				hud_id = obj:hud_add({
					hud_elem_type = "image",
					position = {x = 0.5, y = 0.5},
					scale = {x = -100, y = -100},
					text = "fire_basic_flame.png",
					z_index = 1000,
				}) + 1
			end
		end

		mcla_burning.set(obj, "int", "hud_id", hud_id)
		mcla_burning.set(obj, "int", "sound_id", sound_id)

		local fire_entity = minetest.add_entity(obj:get_pos(), "mcla:fire")
		local minp, maxp = mcla_burning.get_collisionbox(obj)
		local obj_size = obj:get_properties().visual_size

		local vertical_grow_factor = 1.2
		local horizontal_grow_factor = 1.1
		local grow_vector = vector.new(horizontal_grow_factor, vertical_grow_factor, horizontal_grow_factor)

		local size = vector.subtract(maxp, minp)
		size = vector.multiply(size, grow_vector)
		size = vector.divide(size, obj_size)
		local offset = vector.new(0, size.y * 10 / 2, 0)

		fire_entity:set_properties({visual_size = size})
		fire_entity:set_attach(obj, "", offset, {x = 0, y = 0, z = 0})
	end
end

function mcla_burning.extinguish(obj)
	if mcla_burning.is_burning(obj) then
		local sound_id = mcla_burning.get(obj, "int", "sound_id") - 1
		minetest.sound_stop(sound_id)

		if obj:is_player() then
			local hud_id = mcla_burning.get(obj, "int", "hud_id") - 1
			obj:hud_remove(hud_id)
		end

		mcla_burning.set(obj, "string", "reason")
		mcla_burning.set(obj, "float", "burn_time")
		mcla_burning.set(obj, "float", "damage_timer")
		mcla_burning.set(obj, "int", "hud_id")
		mcla_burning.set(obj, "int", "sound_id")
	end
end

function mcla_burning.catch_fire_tick(obj, dtime)
	if mcla_burning.is_affected_by_rain(obj) or #mcla_burning.get_touching_nodes(obj, "group:puts_out_fire") > 0 then
		mcla_burning.extinguish(obj)
	else
		local set_on_fire_value = mcla_burning.get_highest_group_value(obj, "set_on_fire")

		if set_on_fire_value > 0 then
			mcla_burning.set_on_fire(obj, set_on_fire_value)
		end
	end
end

function mcla_burning.tick(obj, dtime)
	local burn_time = mcla_burning.get(obj, "float", "burn_time") - dtime

	if burn_time <= 0 then
		mcla_burning.extinguish(obj)
	else
		mcla_burning.set(obj, "float", "burn_time", burn_time)

		local damage_timer = mcla_burning.get(obj, "float", "damage_timer") + dtime

		if damage_timer >= 1 then
			damage_timer = 0
			mcla_burning.damage(obj)
		end

		mcla_burning.set(obj, "float", "damage_timer", damage_timer)
	end

	mcla_burning.catch_fire_tick(obj, dtime)
end

function mcla_burning.fire_entity_step(self, dtime)
	if self.removed then
		return
	end

	local obj = self.object
	local parent = obj:get_attach()
	local do_remove

	self.doing_step = true

	if not parent or not mcla_burning.is_burning(parent) then
		do_remove = true
	else
		for _, other in ipairs(minetest.get_objects_inside_radius(obj:get_pos(), 0)) do
			local luaentity = obj:get_luaentity()
			if luaentity and luaentity.name == "mcla:fire" and not luaentity.doing_step and not luaentity.removed then
				do_remove = true
				break
			end
		end
	end

	self.doing_step = false

	if do_remove then
		self.removed = true
		obj:remove()
		return
	end
end

minetest.register_chatcommand("burn", {
	params = S("<playername> <duration> <reason>"),
	description = S("Sets a player on fire for the given amount of seconds with the given reason."),
	privs = { debug = true },
	func = function(name, params)
		local playername, duration, reason = params:match("^(.+) (.+) (.+)$")
		if not (playername and duration and reason) then
			return false, S("Error: Parameter missing.")
		end
		local player = minetest.get_player_by_name(playername)
		if not player then
			return false, S(
				"Error: Player “@1” not found.",
				playername
			)
		end
		local duration_number = tonumber(duration)
		-- Lua numbers are truthy
		-- NaN is not equal to NaN
		if not duration_number or (duration_number ~= duration_number) then
			return false, S(
				"Error: Duration “@1” is not a number.",
				duration
			)
		end
		if duration_number < 0 then
			return false, S(
				"Error: Duration “@1” is negative.",
				duration
			)
		end
		mcla_burning.set_on_fire(
			player,
			duration_number,
			reason
		)
		return true, S(
			"Set @1 on fire for @2s for the following reason: @3",
			playername,
			duration,
			reason
		)
	end,
})
