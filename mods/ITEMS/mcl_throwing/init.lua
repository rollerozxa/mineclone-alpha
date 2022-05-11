mcl_throwing = {}

local S = minetest.get_translator("mcl_throwing")

--
-- Snowballs and other throwable items
--

local GRAVITY = tonumber(minetest.settings:get("movement_gravity"))

local entity_mapping = {
	["mcl_throwing:snowball"] = "mcl_throwing:snowball_entity",
}

local velocities = {
	["mcl_throwing:snowball_entity"] = 22,
}

mcl_throwing.throw = function(throw_item, pos, dir, velocity, thrower)
	if velocity == nil then
		velocity = velocities[throw_item]
	end
	if velocity == nil then
		velocity = 22
	end
	minetest.sound_play("mcl_throwing_throw", {pos=pos, gain=0.4, max_hear_distance=16}, true)

	local itemstring = ItemStack(throw_item):get_name()
	local obj = minetest.add_entity(pos, entity_mapping[itemstring])
	obj:set_velocity({x=dir.x*velocity, y=dir.y*velocity, z=dir.z*velocity})
	obj:set_acceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
	if thrower then
		obj:get_luaentity()._thrower = thrower
	end
	return obj
end

-- Throw item
local player_throw_function = function(entity_name, velocity)
	local func = function(item, player, pointed_thing)
		local playerpos = player:get_pos()
		local dir = player:get_look_dir()
		local obj = mcl_throwing.throw(item, {x=playerpos.x, y=playerpos.y+1.5, z=playerpos.z}, dir, velocity, player:get_player_name())
		if not minetest.is_creative_enabled(player:get_player_name()) then
			item:take_item()
		end
		return item
	end
	return func
end

local dispense_function = function(stack, dispenserpos, droppos, dropnode, dropdir)
	-- Launch throwable item
	local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
	mcl_throwing.throw(stack:get_name(), shootpos, dropdir)
end

-- Staticdata handling because objects may want to be reloaded
local get_staticdata = function(self)
	local thrower
	-- Only save thrower if it's a player name
	if type(self._thrower) == "string" then
		thrower = self._thrower
	end
	local data = {
		_lastpos = self._lastpos,
		_thrower = thrower,
	}
	return minetest.serialize(data)
end

local on_activate = function(self, staticdata, dtime_s)
	local data = minetest.deserialize(staticdata)
	if data then
		self._lastpos = data._lastpos
		self._thrower = data._thrower
	end
end

-- The snowball entity
local snowball_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_throwing_snowball.png"},
	visual_size = {x=0.5, y=0.5},
	collisionbox = {0,0,0,0,0,0},
	pointable = false,

	get_staticdata = get_staticdata,
	on_activate = on_activate,
	_thrower = nil,

	_lastpos={},
}

local check_object_hit = function(self, pos, dmg)
	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do

		local entity = object:get_luaentity()

		if entity
		and entity.name ~= self.object:get_luaentity().name then

			if object:is_player() and self._thrower ~= object:get_player_name() then
				-- TODO: Deal knockback
				self.object:remove()
				return true
			elseif (entity._cmi_is_mob == true or entity._hittable_by_projectile) and (self._thrower ~= object) then
				-- FIXME: Knockback is broken
				object:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = dmg,
				}, nil)
				return true
			end
		end
	end
	return false
end

local snowball_particles = function(pos, vel)
	local vel = vector.normalize(vector.multiply(vel, -1))
	minetest.add_particlespawner({
		amount = 20,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.add({x=-2, y=3, z=-2}, vel),
		maxvel = vector.add({x=2, y=5, z=2}, vel),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 1,
		maxexptime = 3,
		minsize = 0.7,
		maxsize = 0.7,
		collisiondetection = true,
		collision_removal = true,
		object_collision = false,
		texture = "weather_pack_snow_snowflake"..math.random(1,2)..".png",
	})
end

-- Snowball on_step()--> called when snowball is moving.
local snowball_on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]


	-- Destroy when hitting a solid node
	if self._lastpos.x~=nil then
		if (def and def.walkable) or not def then
			snowball_particles(self._lastpos, vel)
			self.object:remove()
			return
		end
	end

	if check_object_hit(self, pos, {snowball_vulnerable = 3}) then
		snowball_particles(pos, vel)
		self.object:remove()
		return
	end

	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set _lastpos-->Node will be added at last pos outside the node
end

snowball_ENTITY.on_step = snowball_on_step

minetest.register_entity("mcl_throwing:snowball_entity", snowball_ENTITY)

-- Snowball
minetest.register_craftitem("mcl_throwing:snowball", {
	description = S("Snowball"),
	inventory_image = "mcl_throwing_snowball.png",
	stack_max = 16,
	groups = { weapon_ranged = 1 },
	on_use = player_throw_function("mcl_throwing:snowball_entity"),
	_on_dispense = dispense_function,
})

-- Egg
minetest.register_craftitem("mcl_throwing:egg", {
	description = S("Egg"),
	inventory_image = "mcl_throwing_egg.png",
	stack_max = 16,
	groups = { craftitem = 1 },
})
