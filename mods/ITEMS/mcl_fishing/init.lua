--Fishing Rod, Bobber, and Flying Bobber mechanics and Bobber artwork by Rootyjr.

local S = minetest.get_translator("mcl_fishing")

local entity_mapping = {
	["mcl_fishing:bobber"] = "mcl_fishing:bobber_entity",
}

local bobber_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_fishing_bobber.png"},
	visual_size = {x=0.5, y=0.5},
	collisionbox = {0.45,0.45,0.45,0.45,0.45,0.45},
	pointable = false,
	static_save = false,

	_lastpos={},
	_dive = false,
	_waittime = nil,
	_time = 0,
	player=nil,
	_oldy = nil,
	objtype="fishing",
}

local fish = function(itemstack, player, pointed_thing)
	if pointed_thing and pointed_thing.type == "node" then
		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		if player and not player:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
			end
		end
	end

		local pos = player:get_pos()

		local objs = minetest.get_objects_inside_radius(pos, 125)
		local num = 0
		local ent = nil
		local noent = true


		local durability = 65

		--Check for bobber if so handle.
		for n = 1, #objs do
			ent = objs[n]:get_luaentity()
			if ent then
				if ent.player and ent.objtype=="fishing" then
					if (player:get_player_name() == ent.player) then
						noent = false
						if ent._dive == true then
							local itemname
							local items
							local itemcount = 1
							local itemwear = 0
							local pr = PseudoRandom(os.time() * math.random(1, 100))
							local r = pr:next(1, 100)
							local fish_values = {85, 84.8, 84.7, 84.5}
							local junk_values = {10, 8.1, 6.1, 4.2}
							local luck_of_the_sea = 3
							local index = luck_of_the_sea + 1
							local fish_value = fish_values[index]
							local junk_value = junk_values[index] + fish_value
							if r <= fish_value then
								-- Fish
								items = mcl_loot.get_loot({
									items = {
										{ itemstring = "mcl_fishing:fish_raw", weight = 60 },
										{ itemstring = "mcl_fishing:salmon_raw", weight = 25 },
									}
								}, pr)
							elseif r <= junk_value then
								-- Junk
								items = mcl_loot.get_loot({
									items = {
										{ itemstring = "mcl_core:bowl", weight = 10 },
										{ itemstring = "mcl_fishing:fishing_rod", weight = 2, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
										{ itemstring = "mcl_mobitems:leather", weight = 10 },
										{ itemstring = "mcl_armor:boots_leather", weight = 10, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
										{ itemstring = "mcl_core:stick", weight = 5 },
										{ itemstring = "mcl_mobitems:string", weight = 5 },
										{ itemstring = "mcl_mobitems:bone", weight = 10 },
										{ itemstring = "mcl_mobitems:string", weight = 10 }, -- TODO: Tripwire Hook
									}
								}, pr)
							else
								-- Treasure
								items = mcl_loot.get_loot({
									items = {
										{ itemstring = "mcl_bows:bow", wear_min = 49144, wear_max = 65535 }, -- 75%-100% damage
										{ itemstring = "mcl_fishing:fishing_rod", wear_min = 49144, wear_max = 65535 }, -- 75%-100% damage
										{ itemstring = "mcl_mobitems:saddle", },
									}
								}, pr)
							end
							local item
							if #items >= 1 then
								item = ItemStack(items[1])
							else
								item = ItemStack()
							end
							local inv = player:get_inventory()
							if inv:room_for_item("main", item) then
								inv:add_item("main", item)
							else
								minetest.add_item(pos, item)
							end

							if not minetest.is_creative_enabled(player:get_player_name()) then
								local idef = itemstack:get_definition()
								itemstack:add_wear(65535/durability) -- 65 uses
								if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
									minetest.sound_play(idef.sound.breaks, {pos=player:get_pos(), gain=0.5}, true)
								end
							end
						end
						--Check if object is on land.
						local epos = ent.object:get_pos()
						epos.y = math.floor(epos.y)
						local node = minetest.get_node(epos)
						local def = minetest.registered_nodes[node.name]
						if def.walkable then
							if not minetest.is_creative_enabled(player:get_player_name()) then
								local idef = itemstack:get_definition()
								itemstack:add_wear((65535/durability)*2) -- if so and not creative then wear double like in MC.
								if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
									minetest.sound_play(idef.sound.breaks, {pos=player:get_pos(), gain=0.5}, true)
								end
							end
						end
						--Destroy bobber.
						ent.object:remove()
						return itemstack
					end
				end
			end
		end
		--Check for flying bobber.
		for n = 1, #objs do
			ent = objs[n]:get_luaentity()
			if ent then
				if ent._thrower and ent.objtype=="fishing" then
					if player:get_player_name() == ent._thrower then
						noent = false
						break
					end
				end
			end
		end
		--If no bobber or flying_bobber exists then throw bobber.
		if noent == true then
			local playerpos = player:get_pos()
			local dir = player:get_look_dir()
			local obj = mcl_throwing.throw("mcl_throwing:flying_bobber", {x=playerpos.x, y=playerpos.y+1.5, z=playerpos.z}, dir, 15, player:get_player_name())
		end
end

-- Movement function of bobber
local bobber_on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local epos = self.object:get_pos()
	epos.y = math.floor(epos.y)
	local node = minetest.get_node(epos)
	local def = minetest.registered_nodes[node.name]

	--If we have no player, remove self.
	if self.player == nil or self.player == "" then
		self.object:remove()
		return
	end
	local player = minetest.get_player_by_name(self.player)
	if not player then
		self.object:remove()
		return
	end
	local wield = player:get_wielded_item()
	--Check if player is nearby
	if self.player ~= nil and player ~= nil then
		--Destroy bobber if item not wielded.
		if ((not wield) or (minetest.get_item_group(wield:get_name(), "fishing_rod") <= 0)) then
			self.object:remove()
			return
		end

		--Destroy bobber if player is too far away.
		local objpos = self.object:get_pos()
		local playerpos = player:get_pos()
		if (((playerpos.y - objpos.y) >= 33) or ((playerpos.y - objpos.y) <= -33)) then
			self.object:remove()
			return
		elseif (((playerpos.x - objpos.x) >= 33) or ((playerpos.x - objpos.x) <= -33)) then
			self.object:remove()
			return
		elseif (((playerpos.z - objpos.z) >= 33) or ((playerpos.z - objpos.z) <= -33)) then
			self.object:remove()
			return
		elseif ((((playerpos.z + playerpos.x) - (objpos.z + objpos.x)) >= 33) or ((playerpos.z + playerpos.x) - (objpos.z + objpos.x)) <= -33) then
			self.object:remove()
			return
		elseif ((((playerpos.y + playerpos.x) - (objpos.y + objpos.x)) >= 33) or ((playerpos.y + playerpos.x) - (objpos.y + objpos.x)) <= -33) then
			self.object:remove()
			return
		elseif ((((playerpos.z + playerpos.y) - (objpos.z + objpos.y)) >= 33) or ((playerpos.z + playerpos.y) - (objpos.z + objpos.y)) <= -33) then
			self.object:remove()
			return
		end

	end
	-- If in water, then bob.
	if def.liquidtype == "source" and minetest.get_item_group(def.name, "water") ~= 0 then
		if self._oldy == nil then
			self.object:set_pos({x=self.object:get_pos().x,y=math.floor(self.object:get_pos().y)+.5,z=self.object:get_pos().z})
			self._oldy = self.object:get_pos().y
		end
		-- reset to original position after dive.
		if self.object:get_pos().y > self._oldy then
			self.object:set_pos({x=self.object:get_pos().x,y=self._oldy,z=self.object:get_pos().z})
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_acceleration({x=0,y=0,z=0})
		end
		if self._dive then
			for i=1,2 do
					-- Spray bubbles when there's a fish.
					minetest.add_particle({
						pos = {x=epos["x"]+math.random(-1,1)*math.random()/2,y=epos["y"]+0.1,z=epos["z"]+math.random(-1,1)*math.random()/2},
						velocity = {x=0, y=4, z=0},
						acceleration = {x=0, y=-5, z=0},
						expirationtime = math.random() * 0.5,
						size = math.random(),
						collisiondetection = true,
						vertical = false,
						texture = "mcl_particles_bubble.png",
					})
			end
			if self._time < self._waittime then
				self._time = self._time + dtime
			else
				self._waittime = 0
				self._time = 0
				self._dive = false
			end
		else if not self._waittime or self._waittime <= 0 then
			-- wait for random number of ticks.
			local lure_enchantment = wield or 0
			local reduced = lure_enchantment * 5
			self._waittime = math.random(math.max(0, 5 - reduced), 30 - reduced)
		else
			if self._time < self._waittime then
				self._time = self._time + dtime
			else
				-- wait time is over time to dive.
				self._dive = true
				self.object:set_velocity({x=0,y=-2,z=0})
				self.object:set_acceleration({x=0,y=5,z=0})
				self._waittime = 0.8
				self._time = 0
			end
		end
	end
end

	-- TODO: Destroy when hitting a solid node
	--if self._lastpos.x~=nil then
	--	if (def and def.walkable) or not def then
			--self.object:remove()
		--	return
	--	end
	--end
	--self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

bobber_ENTITY.on_step = bobber_on_step

minetest.register_entity("mcl_fishing:bobber_entity", bobber_ENTITY)

-- If player leaves area, remove bobber.
minetest.register_on_leaveplayer(function(player)
	local objs = minetest.get_objects_inside_radius(player:get_pos(), 250)
	local num = 0
	local ent = nil
	local noent = true

	for n = 1, #objs do
		ent = objs[n]:get_luaentity()
		if ent then
			if ent.player and ent.objtype=="fishing" then
				ent.object:remove()
			elseif ent._thrower and ent.objtype=="fishing" then
				ent.object:remove()
			end
		end
	end
end)

-- If player dies, remove bobber.
minetest.register_on_dieplayer(function(player)
	local objs = minetest.get_objects_inside_radius(player:get_pos(), 250)
	local num = 0
	local ent = nil
	local noent = true

	for n = 1, #objs do
		ent = objs[n]:get_luaentity()
		if ent then
			if ent.player and ent.objtype=="fishing" then
				ent.object:remove()
			elseif ent._thrower and ent.objtype=="fishing" then
				ent.object:remove()
			end
		end
	end
end)

-- Fishing Rod
minetest.register_tool("mcl_fishing:fishing_rod", {
	description = S("Fishing Rod"),
	groups = { tool=1, fishing_rod=1 },
	inventory_image = "mcl_fishing_fishing_rod.png",
	wield_image = "mcl_fishing_fishing_rod.png^[transformR270",
	wield_scale = { x = 1.5, y = 1.5, z = 1 },
	stack_max = 1,
	on_place = fish,
	on_secondary_use = fish,
	_mcl_uses = 65,
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'','','mcl_core:stick'},
		{'','mcl_core:stick','mcl_mobitems:string'},
		{'mcl_core:stick','','mcl_mobitems:string'},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'mcl_core:stick', '', ''},
		{'mcl_mobitems:string', 'mcl_core:stick', ''},
		{'mcl_mobitems:string','','mcl_core:stick'},
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:fishing_rod",
	burntime = 15,
})
