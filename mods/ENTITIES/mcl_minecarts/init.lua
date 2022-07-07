local S = minetest.get_translator("mcl_minecarts")

mcl_minecarts = {}
mcl_minecarts.modpath = minetest.get_modpath("mcla_minecarts")
mcl_minecarts.speed_max = 10
mcl_minecarts.check_float_time = 15

dofile(mcl_minecarts.modpath.."/functions.lua")
dofile(mcl_minecarts.modpath.."/rails.lua")

local function detach_driver(self)
	if not self._driver then
		return
	end
	mcl_player.player_attached[self._driver] = nil
	local player = minetest.get_player_by_name(self._driver)
	self._driver = nil
	self._start_pos = nil
	if player then
		player:set_detach()
		player:set_eye_offset({x=0, y=0, z=0},{x=0, y=0, z=0})
		mcl_player.player_set_animation(player, "stand" , 30)
	end
end

local function activate_tnt_minecart(self, timer)
	if self._boomtimer then
		return
	end
	self.object:set_armor_groups({immortal=1})
	if timer then
		self._boomtimer = timer
	else
		self._boomtimer = tnt.BOOMTIMER
	end
	self.object:set_properties({textures = {
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_minecarts_minecart.png",
	}})
	self._blinktimer = tnt.BLINKTIMER
	minetest.sound_play("tnt_ignite", {pos = self.object:get_pos(), gain = 1.0, max_hear_distance = 15}, true)
end

local activate_normal_minecart = detach_driver

-- Table for item-to-entity mapping. Keys: itemstring, Values: Corresponding entity ID
local entity_mapping = {}

local function register_entity(entity_id, mesh, textures, drop, on_rightclick, on_activate_by_rail)
	local cart = {
		physical = false,
		collisionbox = {-10/16., -0.5, -10/16, 10/16, 0.25, 10/16},
		visual = "mesh",
		mesh = mesh,
		visual_size = {x=1, y=1},
		textures = textures,

		on_rightclick = on_rightclick,

		_driver = nil, -- player who sits in and controls the minecart (only for minecart!)
		_punched = false, -- used to re-send _velocity and position
		_velocity = {x=0, y=0, z=0}, -- only used on punch
		_start_pos = nil, -- Used to calculate distance for “On A Rail” achievement
		_last_float_check = nil, -- timestamp of last time the cart was checked to be still on a rail
		_fueltime = nil, -- how many seconds worth of fuel is left. Only used by minecart with furnace
		_boomtimer = nil, -- how many seconds are left before exploding
		_blinktimer = nil, -- how many seconds are left before TNT blinking
		_blink = false, -- is TNT blink texture active?
		_old_dir = {x=0, y=0, z=0},
		_old_pos = nil,
		_old_vel = {x=0, y=0, z=0},
		_old_switch = 0,
		_railtype = nil,
	}

	function cart:on_activate(staticdata, dtime_s)
		-- Initialize
		local data = minetest.deserialize(staticdata)
		if type(data) == "table" then
			self._railtype = data._railtype
		end
		self.object:set_armor_groups({immortal=1})

		-- Activate cart if on activator rail
		if self.on_activate_by_rail then
			local pos = self.object:get_pos()
			local node = minetest.get_node(vector.floor(pos))
			if node.name == "mcla:activator_rail_on" then
				self:on_activate_by_rail()
			end
		end
	end

	function cart:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
		local pos = self.object:get_pos()
		if not self._railtype then
			local node = minetest.get_node(vector.floor(pos)).name
			self._railtype = minetest.get_item_group(node, "connect_to_raillike")
		end

		if not puncher or not puncher:is_player() then
			local cart_dir = mcla:get_rail_direction(pos, {x=1, y=0, z=0}, nil, nil, self._railtype)
			if vector.equals(cart_dir, {x=0, y=0, z=0}) then
				return
			end
			self._velocity = vector.multiply(cart_dir, 3)
			self._old_pos = nil
			self._punched = true
			return
		end

		-- Punch+sneak: Pick up minecart (unless TNT was ignited)
		if puncher:get_player_control().sneak and not self._boomtimer then
			if self._driver then
				if self._old_pos then
					self.object:set_pos(self._old_pos)
				end
				detach_driver(self)
			end

			-- Disable detector rail
			local rou_pos = vector.round(pos)
			local node = minetest.get_node(rou_pos)
			if node.name == "mcla:detector_rail_on" then
				local newnode = {name="mcla:detector_rail", param2 = node.param2}
				minetest.swap_node(rou_pos, newnode)
				mesecon.receptor_off(rou_pos)
			end

			-- Drop items and remove cart entity
			if not minetest.is_creative_enabled(puncher:get_player_name()) then
				for d=1, #drop do
					minetest.add_item(self.object:get_pos(), drop[d])
				end
			elseif puncher and puncher:is_player() then
				local inv = puncher:get_inventory()
				for d=1, #drop do
					if not inv:contains_item("main", drop[d]) then
						inv:add_item("main", drop[d])
					end
				end
			end

			self.object:remove()
			return
		end

		local vel = self.object:get_velocity()
		if puncher:get_player_name() == self._driver then
			if math.abs(vel.x + vel.z) > 7 then
				return
			end
		end

		local punch_dir = mcla:velocity_to_dir(puncher:get_look_dir())
		punch_dir.y = 0
		local cart_dir = mcla:get_rail_direction(pos, punch_dir, nil, nil, self._railtype)
		if vector.equals(cart_dir, {x=0, y=0, z=0}) then
			return
		end

		time_from_last_punch = math.min(time_from_last_punch, tool_capabilities.full_punch_interval)
		local f = 3 * (time_from_last_punch / tool_capabilities.full_punch_interval)

		self._velocity = vector.multiply(cart_dir, f)
		self._old_pos = nil
		self._punched = true
	end

	cart.on_activate_by_rail = on_activate_by_rail

	function cart:on_step(dtime)
		local ctrl, player = nil, nil
		if self._driver then
			player = minetest.get_player_by_name(self._driver)
			if player then
				ctrl = player:get_player_control()
				-- player detach
				if ctrl.sneak then
					detach_driver(self)
					return
				end
			end
		end

		local vel = self.object:get_velocity()
		local update = {}
		if self._last_float_check == nil then
			self._last_float_check = 0
		else
			self._last_float_check = self._last_float_check + dtime
		end
		local pos, rou_pos, node
		-- Drop minecart if it isn't on a rail anymore
		if self._last_float_check >= mcl_minecarts.check_float_time then
			pos = self.object:get_pos()
			rou_pos = vector.round(pos)
			node = minetest.get_node(rou_pos)
			local g = minetest.get_item_group(node.name, "connect_to_raillike")
			if g ~= self._railtype and self._railtype ~= nil then
				-- Detach driver
				if player then
					if self._old_pos then
						self.object:set_pos(self._old_pos)
					end
					mcl_player.player_attached[self._driver] = nil
					player:set_detach()
					player:set_eye_offset({x=0, y=0, z=0},{x=0, y=0, z=0})
				end

				-- Explode if already ignited
				if self._boomtimer then
					self.object:remove()
					mcl_explosions.explode(pos, 4, { drop_chance = 1.0 })
					return
				end

				-- Drop items and remove cart entity
				local pname = ""
				if player then
					pname = player:get_player_name()
				end
				if not minetest.is_creative_enabled(pname) then
					for d=1, #drop do
						minetest.add_item(self.object:get_pos(), drop[d])
					end
				end

				self.object:remove()
				return
			end
			self._last_float_check = 0
		end

		-- Update furnace stuff
		if self._fueltime and self._fueltime > 0 then
			self._fueltime = self._fueltime - dtime
			if self._fueltime <= 0 then
				self.object:set_properties({textures =
					{
					"mcl_furnaces_top.png",
					"mcl_furnaces_top.png",
					"mcl_furnaces_front.png",
					"mcl_furnaces_side.png",
					"mcl_furnaces_side.png",
					"mcl_furnaces_side.png",
					"mcl_minecarts_minecart.png",
				}})
				self._fueltime = 0
			end
		end
		local has_fuel = self._fueltime and self._fueltime > 0

		-- Update TNT stuff
		if self._boomtimer then
			-- Explode
			self._boomtimer = self._boomtimer - dtime
			local pos = self.object:get_pos()
			if self._boomtimer <= 0 then
				self.object:remove()
				mcl_explosions.explode(pos, 4, { drop_chance = 1.0 })
				return
			else
				tnt.smoke_step(pos)
			end
		end
		if self._blinktimer then
			self._blinktimer = self._blinktimer - dtime
			if self._blinktimer <= 0 then
				self._blink = not self._blink
				if self._blink then
					self.object:set_properties({textures =
					{
					"mcl_tnt_top.png",
					"mcl_tnt_bottom.png",
					"mcl_tnt_side.png",
					"mcl_tnt_side.png",
					"mcl_tnt_side.png",
					"mcl_tnt_side.png",
					"mcl_minecarts_minecart.png",
					}})
				else
					self.object:set_properties({textures =
					{
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_minecarts_minecart.png",
					}})
				end
				self._blinktimer = tnt.BLINKTIMER
			end
		end

		if self._punched then
			vel = vector.add(vel, self._velocity)
			self.object:set_velocity(vel)
			self._old_dir.y = 0
		elseif vector.equals(vel, {x=0, y=0, z=0}) and (not has_fuel) then
			return
		end

		local dir, last_switch = nil, nil
		if not pos then
			pos = self.object:get_pos()
		end
		if self._old_pos and not self._punched then
			local flo_pos = vector.floor(pos)
			local flo_old = vector.floor(self._old_pos)
			if vector.equals(flo_pos, flo_old) and (not has_fuel) then
				return
				-- Prevent querying the same node over and over again
			end

			if not rou_pos then
				rou_pos = vector.round(pos)
			end
			local rou_old = vector.round(self._old_pos)
			if not node then
				node = minetest.get_node(rou_pos)
			end
			local node_old = minetest.get_node(rou_old)

			-- Update detector rails
			if node.name == "mcla:detector_rail" then
				local newnode = {name="mcla:detector_rail_on", param2 = node.param2}
				minetest.swap_node(rou_pos, newnode)
				mesecon.receptor_on(rou_pos)
			end
			if node_old.name == "mcla:detector_rail_on" then
				local newnode = {name="mcla:detector_rail", param2 = node_old.param2}
				minetest.swap_node(rou_old, newnode)
				mesecon.receptor_off(rou_old)
			end
			-- Activate minecart if on activator rail
			if node_old.name == "mcla:activator_rail_on" and self.on_activate_by_rail then
				self:on_activate_by_rail()
			end
		end

		-- Stop cart if velocity vector flips
		if self._old_vel and self._old_vel.y == 0 and
				(self._old_vel.x * vel.x < 0 or self._old_vel.z * vel.z < 0) then
			self._old_vel = {x = 0, y = 0, z = 0}
			self._old_pos = pos
			self.object:set_velocity(vector.new())
			self.object:set_acceleration(vector.new())
			return
		end
		self._old_vel = vector.new(vel)

		if self._old_pos then
			local diff = vector.subtract(self._old_pos, pos)
			for _,v in ipairs({"x","y","z"}) do
				if math.abs(diff[v]) > 1.1 then
					local expected_pos = vector.add(self._old_pos, self._old_dir)
					dir, last_switch = mcla:get_rail_direction(pos, self._old_dir, ctrl, self._old_switch, self._railtype)
					if vector.equals(dir, {x=0, y=0, z=0}) then
						dir = false
						pos = vector.new(expected_pos)
						update.pos = true
					end
					break
				end
			end
		end

		if vel.y == 0 then
			for _,v in ipairs({"x", "z"}) do
				if vel[v] ~= 0 and math.abs(vel[v]) < 0.9 then
					vel[v] = 0
					update.vel = true
				end
			end
		end

		local cart_dir = mcla:velocity_to_dir(vel)
		local max_vel = mcl_minecarts.speed_max
		if not dir then
			dir, last_switch = mcla:get_rail_direction(pos, cart_dir, ctrl, self._old_switch, self._railtype)
		end

		local new_acc = {x=0, y=0, z=0}
		if vector.equals(dir, {x=0, y=0, z=0}) and not has_fuel then
			vel = {x=0, y=0, z=0}
			update.vel = true
		else
			-- If the direction changed
			if dir.x ~= 0 and self._old_dir.z ~= 0 then
				vel.x = dir.x * math.abs(vel.z)
				vel.z = 0
				pos.z = math.floor(pos.z + 0.5)
				update.pos = true
			end
			if dir.z ~= 0 and self._old_dir.x ~= 0 then
				vel.z = dir.z * math.abs(vel.x)
				vel.x = 0
				pos.x = math.floor(pos.x + 0.5)
				update.pos = true
			end
			-- Up, down?
			if dir.y ~= self._old_dir.y then
				vel.y = dir.y * math.abs(vel.x + vel.z)
				pos = vector.round(pos)
				update.pos = true
			end

			-- Slow down or speed up
			local acc = dir.y * -1.8
			local friction = 0.4
			local speed_mod = minetest.registered_nodes[minetest.get_node(pos).name]._rail_acceleration

			acc = acc - friction

			if has_fuel then
				acc = acc + 0.6
			end

			if speed_mod and speed_mod ~= 0 then
				acc = acc + speed_mod + friction
			end

			new_acc = vector.multiply(dir, acc)
		end

		self.object:set_acceleration(new_acc)
		self._old_pos = vector.new(pos)
		self._old_dir = vector.new(dir)
		self._old_switch = last_switch

		-- Limits
		for _,v in ipairs({"x","y","z"}) do
			if math.abs(vel[v]) > max_vel then
				vel[v] = mcla:get_sign(vel[v]) * max_vel
				new_acc[v] = 0
				update.vel = true
			end
		end

		if update.pos or self._punched then
			local yaw = 0
			if dir.x < 0 then
				yaw = 0.5
			elseif dir.x > 0 then
				yaw = 1.5
			elseif dir.z < 0 then
				yaw = 1
			end
			self.object:set_yaw(yaw * math.pi)
		end

		if self._punched then
			self._punched = false
		end

		if not (update.vel or update.pos) then
			return
		end


		local anim = {x=0, y=0}
		if dir.y == -1 then
			anim = {x=1, y=1}
		elseif dir.y == 1 then
			anim = {x=2, y=2}
		end
		self.object:set_animation(anim, 1, 0)

		self.object:set_velocity(vel)
		if update.pos then
			self.object:set_pos(pos)
		end
		update = nil
	end

	function cart:get_staticdata()
		return minetest.serialize({_railtype = self._railtype})
	end

	minetest.register_entity(entity_id, cart)
end

-- Place a minecart at pointed_thing
mcl_minecarts.place_minecart = function(itemstack, pointed_thing, placer)
	if not pointed_thing.type == "node" then
		return
	end

	local railpos, node
	if mcla:is_rail(pointed_thing.under) then
		railpos = pointed_thing.under
		node = minetest.get_node(pointed_thing.under)
	elseif mcla:is_rail(pointed_thing.above) then
		railpos = pointed_thing.above
		node = minetest.get_node(pointed_thing.above)
	else
		return
	end

	-- Activate detector rail
	if node.name == "mcla:detector_rail" then
		local newnode = {name="mcla:detector_rail_on", param2 = node.param2}
		minetest.swap_node(railpos, newnode)
		mesecon.receptor_on(railpos)
	end

	local entity_id = entity_mapping[itemstack:get_name()]
	local cart = minetest.add_entity(railpos, entity_id)
	local railtype = minetest.get_item_group(node.name, "connect_to_raillike")
	local le = cart:get_luaentity()
	if le ~= nil then
		le._railtype = railtype
	end
	local cart_dir = mcla:get_rail_direction(railpos, {x=1, y=0, z=0}, nil, nil, railtype)
	cart:set_yaw(minetest.dir_to_yaw(cart_dir))

	local pname = ""
	if placer then
		pname = placer:get_player_name()
	end
	if not minetest.is_creative_enabled(pname) then
		itemstack:take_item()
	end
	return itemstack
end


local register_craftitem = function(itemstring, entity_id, description, icon, creative)
	entity_mapping[itemstring] = entity_id

	local groups = { minecart = 1, transport = 1 }
	if creative == false then
		groups.not_in_creative_inventory = 1
	end
	local def = {
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return
			end

			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			return mcl_minecarts.place_minecart(itemstack, pointed_thing, placer)
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			-- Place minecart as entity on rail. If there's no rail, just drop it.
			local placed
			if minetest.get_item_group(dropnode.name, "rail") ~= 0 then
				-- FIXME: This places minecarts even if the spot is already occupied
				local pointed_thing = { under = droppos, above = { x=droppos.x, y=droppos.y+1, z=droppos.z } }
				placed = mcl_minecarts.place_minecart(stack, pointed_thing)
			end
			if placed == nil then
				-- Drop item
				minetest.add_item(droppos, stack)
			end
		end,
		groups = groups,
	}
	def.description = description
	def.inventory_image = icon
	def.wield_image = icon
	minetest.register_craftitem(itemstring, def)
end

--[[
Register a minecart
* itemstring: Itemstring of minecart item
* entity_id: ID of minecart entity
* description: Item name / description
* mesh: Minecart mesh
* textures: Minecart textures table
* icon: Item icon
* drop: Dropped items after destroying minecart
* on_rightclick: Called after rightclick
* on_activate_by_rail: Called when above activator rail
* creative: If false, don't show in Creative Inventory
]]
local function register_minecart(itemstring, entity_id, description, mesh, textures, icon, drop, on_rightclick, on_activate_by_rail, creative)
	register_entity(entity_id, mesh, textures, drop, on_rightclick, on_activate_by_rail)
	register_craftitem(":"..itemstring, entity_id, description, icon, creative)
end

-- Minecart
register_minecart(
	"mcla:minecart",
	"mcla_minecarts:minecart",
	S("Minecart"),
	"mcl_minecarts_minecart.b3d",
	{"mcl_minecarts_minecart.png"},
	"mcl_minecarts_minecart_normal.png",
	{"mcla:minecart"},
	function(self, clicker)
		local name = clicker:get_player_name()
		if not clicker or not clicker:is_player() then
			return
		end
		local player_name = clicker:get_player_name()
		if self._driver and player_name == self._driver then
			detach_driver(self)
		elseif not self._driver then
			self._driver = player_name
			self._start_pos = self.object:get_pos()
			mcl_player.player_attached[player_name] = true
			clicker:set_attach(self.object, "", {x=0, y=-1.75, z=-2}, {x=0, y=0, z=0})
			mcl_player.player_attached[name] = true
			minetest.after(0.2, function(name)
				local player = minetest.get_player_by_name(name)
				if player then
					mcl_player.player_set_animation(player, "sit" , 30)
					player:set_eye_offset({x=0, y=-5.5, z=0},{x=0, y=-4, z=0})
					mcl_tmp_message.message(clicker, S("Sneak to dismount"))
				end
			end, name)
		end
	end, activate_normal_minecart
)

-- Minecart with Chest
register_minecart(
	"mcla:chest_minecart",
	"mcla_minecarts:chest_minecart",
	S("Minecart with Chest"),
	"mcl_minecarts_minecart_chest.b3d",
	{ "mcl_chests_normal.png", "mcl_minecarts_minecart.png" },
	"mcl_minecarts_minecart_chest.png",
	{"mcla:minecart", "mcla:chest"},
	nil, nil, false)

-- Minecart with Furnace
register_minecart(
	"mcla:furnace_minecart",
	"mcla_minecarts:furnace_minecart",
	S("Minecart with Furnace"),
	"mcl_minecarts_minecart_block.b3d",
	{
		"mcl_furnaces_top.png",
		"mcl_furnaces_top.png",
		"mcl_furnaces_front.png",
		"mcl_furnaces_side.png",
		"mcl_furnaces_side.png",
		"mcl_furnaces_side.png",
		"mcl_minecarts_minecart.png",
	},
	"mcl_minecarts_minecart_furnace.png",
	{"mcla:minecart", "mcla:furnace"},
	-- Feed furnace with coal
	function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end
		if not self._fueltime then
			self._fueltime = 0
		end
		local held = clicker:get_wielded_item()
		if minetest.get_item_group(held:get_name(), "coal") == 1 then
			self._fueltime = self._fueltime + 180

			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				held:take_item()
				local index = clicker:get_wield_index()
				local inv = clicker:get_inventory()
				inv:set_stack("main", index, held)
			end
			self.object:set_properties({textures =
			{
				"mcl_furnaces_top.png",
				"mcl_furnaces_top.png",
				"mcl_furnaces_front_active.png",
				"mcl_furnaces_side.png",
				"mcl_furnaces_side.png",
				"mcl_furnaces_side.png",
				"mcl_minecarts_minecart.png",
			}})
		end
	end, nil, false
)

minetest.register_craft({
	output = "mcla:minecart",
	recipe = {
		{"mcla:iron_ingot", "", "mcla:iron_ingot"},
		{"mcla:iron_ingot", "mcla:iron_ingot", "mcla:iron_ingot"},
	},
})
