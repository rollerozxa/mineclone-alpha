local S = minetest.get_translator("mcla_mobspawners")

mcla_mobspawners = {}

local default_mob = "mobs_mc:pig"

-- Mob spawner
local spawner_default = default_mob.." 0 15 4 15"

local function get_mob_textures(mob)
	local list = minetest.registered_entities[mob].texture_list
	if type(list[1]) == "table" then
		return list[1]
	else
		return list
	end
end

local function find_doll(pos)
	for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if not obj:is_player() then
			if obj ~= nil and obj:get_luaentity().name == "mcla_mobspawners:doll" then
				return obj
			end
		end
	end
	return nil
end

local function spawn_doll(pos)
	return minetest.add_entity({x=pos.x, y=pos.y-0.3, z=pos.z}, "mcla_mobspawners:doll")
end

-- Manually set the doll sizes for large mobs
local doll_size_overrides = {}
local spawn_count_overrides = {}

local function set_doll_properties(doll, mob)
	local mobinfo = minetest.registered_entities[mob]
	local xs, ys
	if doll_size_overrides[mob] then
		xs = doll_size_overrides[mob].x
		ys = doll_size_overrides[mob].y
	else
		xs = mobinfo.visual_size.x * 0.33333
		ys = mobinfo.visual_size.y * 0.33333
	end
	local prop = {
		mesh = mobinfo.mesh,
		textures = get_mob_textures(mob),
		visual_size = {
			x = xs,
			y = ys,
		}
	}
	doll:set_properties(prop)
	doll:get_luaentity()._mob = mob
end

local function respawn_doll(pos)
	local meta = minetest.get_meta(pos)
	local mob = meta:get_string("Mob")
	local doll
	if mob and mob ~= "" then
		doll = find_doll(pos)
		if not doll then
			doll = spawn_doll(pos)
			set_doll_properties(doll, mob)
		end
	end
	return doll
end

--[[ Public function: Setup the spawner at pos.
This function blindly assumes there's actually a spawner at pos.
If not, then the results are undefined.
All the arguments are optional!

* Mob: ID of mob to spawn (default: mobs_mc:pig)
* MinLight: Minimum light to spawn (default: 0)
* MaxLight: Maximum light to spawn (default: 15)
* MaxMobsInArea: How many mobs are allowed in the area around the spawner (default: 4)
* PlayerDistance: Spawn mobs only if a player is within this distance; 0 to disable (default: 15)
* YOffset: Y offset to spawn mobs; 0 to disable (default: 0)
]]

function mcla_mobspawners.setup_spawner(pos, Mob, MinLight, MaxLight, MaxMobsInArea, PlayerDistance, YOffset)
	-- Activate mob spawner and disable editing functionality
	if Mob == nil then Mob = default_mob end
	if MinLight == nil then MinLight = 0 end
	if MaxLight == nil then MaxLight = 15 end
	if MaxMobsInArea == nil then MaxMobsInArea = 4  end
	if PlayerDistance == nil then PlayerDistance = 15 end
	if YOffset == nil then YOffset = 0 end
	local meta = minetest.get_meta(pos)
	meta:set_string("Mob", Mob)
	meta:set_int("MinLight", MinLight)
	meta:set_int("MaxLight", MaxLight)
	meta:set_int("MaxMobsInArea", MaxMobsInArea)
	meta:set_int("PlayerDistance", PlayerDistance)
	meta:set_int("YOffset", YOffset)

	-- Create doll or replace existing doll
	local doll = find_doll(pos)
	if not doll then
		doll = spawn_doll(pos)
	end
	set_doll_properties(doll, Mob)


	-- Start spawning very soon
	local t = minetest.get_node_timer(pos)
	t:start(2)
end

-- Spawn mobs around pos
-- NOTE: The node is timer-based, rather than ABM-based.
local spawn_mobs = function(pos, elapsed)

	-- get meta
	local meta = minetest.get_meta(pos)

	-- get settings
	local mob = meta:get_string("Mob")
	local mlig = meta:get_int("MinLight")
	local xlig = meta:get_int("MaxLight")
	local num = meta:get_int("MaxMobsInArea")
	local pla = meta:get_int("PlayerDistance")
	local yof = meta:get_int("YOffset")

	-- if amount is 0 then do nothing
	if num == 0 then
		return
	end

	-- are we spawning a registered mob?
	if not mobs.spawning_mobs[mob] then
		minetest.log("error", "[mcla_mobspawners] Mob Spawner: Mob doesn't exist: "..mob)
		return
	end

	-- check objects inside 8×8 area around spawner
	local objs = minetest.get_objects_inside_radius(pos, 8)
	local count = 0
	local ent = nil


	local timer = minetest.get_node_timer(pos)

	-- spawn mob if player detected and in range
	if pla > 0 then

		local in_range = 0
		local objs = minetest.get_objects_inside_radius(pos, pla)

		for _,oir in pairs(objs) do

			if oir:is_player() then

				in_range = 1

				break
			end
		end

		-- player not found
		if in_range == 0 then
			-- Try again quickly
			timer:start(2)
			return
		end
	end

	--[[ HACK!
	The doll may not stay spawned if the mob spawner is placed far away from
	players, so we will check for its existance periodically when a player is nearby.
	This would happen almost always when the mob spawner is placed by the mapgen.
	This is probably caused by a Minetest bug:
	https://github.com/minetest/minetest/issues/4759
	FIXME: Fix this horrible hack.
	]]
	local doll = find_doll(pos)
	if not doll then
		doll = spawn_doll(pos)
		set_doll_properties(doll, mob)
	end

	-- count mob objects of same type in area
	for k, obj in ipairs(objs) do

		ent = obj:get_luaentity()

		if ent and ent.name and ent.name == mob then
			count = count + 1
		end
	end

	-- Are there too many of same type? then fail
	if count >= num then
		timer:start(math.random(5, 20))
		return
	end

	-- find air blocks within 8×3×8 nodes of spawner
	local air = minetest.find_nodes_in_area(
		{x = pos.x - 4, y = pos.y - 1 + yof, z = pos.z - 4},
		{x = pos.x + 4, y = pos.y + 1 + yof, z = pos.z + 4},
		{"air"})

	-- spawn up to 4 mobs in random air blocks
	if air then
		local max = 4
		if spawn_count_overrides[mob] then
			max = spawn_count_overrides[mob]
		end
		for a=1, max do
			if #air <= 0 then
				-- We're out of space! Stop spawning
				break
			end
			local air_index = math.random(#air)
			local pos2 = air[air_index]
			local lig = minetest.get_node_light(pos2) or 0

			pos2.y = pos2.y + 0.5

			-- only if light levels are within range
			if lig >= mlig and lig <= xlig then
				minetest.add_entity(pos2, mob)
			end
			table.remove(air, air_index)
		end
	end

	-- Spawn attempt done. Next spawn attempt much later
	timer:start(math.random(10, 39.95))

end

-- The mob spawner node.
-- PLACEMENT INSTRUCTIONS:
-- If this node is placed by a player, minetest.item_place, etc. default settings are applied
-- automatially.
-- IF this node is placed by ANY other method (e.g. minetest.set_node, LuaVoxelManip), you
-- MUST call mcla_mobspawners.setup_spawner right after the spawner has been placed.
minetest.register_node(":mcla:spawner", {
	tiles = {"mob_spawner.png"},
	drawtype = "glasslike",
	paramtype = "light",
	walkable = true,
	description = S("Mob Spawner"),
	groups = {pickaxey=1, material_stone=1, deco_block=1},
	is_ground_content = false,
	drop = "",

	-- If placed by player, setup spawner with default settings
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		local node_under = minetest.get_node(pointed_thing.under)
		local new_itemstack, success = minetest.item_place(itemstack, placer, pointed_thing)
		if success then
			local placepos
			if minetest.registered_nodes[node_under.name].buildable_to then
				placepos = pointed_thing.under
			else
				placepos = pointed_thing.above
			end
			mcla_mobspawners.setup_spawner(placepos)
		end
		return new_itemstack
	end,

	on_destruct = function(pos)
		-- Remove doll (if any)
		local obj = find_doll(pos)
		if obj then
			obj:remove()
		end
	end,

	on_punch = function(pos)
		respawn_doll(pos)
	end,

	on_timer = spawn_mobs,

	sounds = mcla_sounds.node_sound_metal_defaults(),

	_mcla_blast_resistance = 5,
	_mcla_hardness = 5,
})

-- Mob spawner doll (rotating icon inside cage)

local doll_def = {
	hp_max = 1,
	physical = false,
	pointable = false,
	visual = "mesh",
	makes_footstep_sound = false,
	timer = 0,
	automatic_rotate = math.pi * 2.9,

	_mob = default_mob, -- name of the mob this doll represents
}

doll_def.get_staticdata = function(self)
	return self._mob
end

doll_def.on_activate = function(self, staticdata, dtime_s)
	local mob = staticdata
	if mob == "" or mob == nil then
		mob = default_mob
	end
	set_doll_properties(self.object, mob)
	self.object:set_velocity({x=0, y=0, z=0})
	self.object:set_acceleration({x=0, y=0, z=0})
	self.object:set_armor_groups({immortal=1})

end

doll_def.on_step = function(self, dtime)
	-- Check if spawner is still present. If not, delete the entity
	self.timer = self.timer + dtime
	local n = minetest.get_node_or_nil(self.object:get_pos())
	if self.timer > 1 then
		if n and n.name and n.name ~= "mcla_mobspawners:spawner" then
			self.object:remove()
		end
	end
end

doll_def.on_punch = function(self, hitter) end

minetest.register_entity("mcla_mobspawners:doll", doll_def)

-- FIXME: Doll can get destroyed by /clearobjects
minetest.register_lbm({
	label = "Respawn mob spawner dolls",
	name = "mcla_mobspawners:respawn_entities",
	nodenames = { "mcla:spawner" },
	run_at_every_load = true,
	action = function(pos, node)
		respawn_doll(pos)
	end,
})

