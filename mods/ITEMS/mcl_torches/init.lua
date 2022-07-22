local S = minetest.get_translator("mcla_torches")
local LIGHT_TORCH = minetest.LIGHT_MAX

local spawn_flames_floor = function(pos)
	-- Flames
	mcla_particles.add_node_particlespawner(pos, {
		amount = 8,
		time = 0,
		minpos = vector.add(pos, { x = -0.1, y = 0.05, z = -0.1 }),
		maxpos = vector.add(pos, { x = 0.1, y = 0.15, z = 0.1 }),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.7,
		maxsize = 2,
		texture = "mcla_particles_flame.png",
		glow = LIGHT_TORCH,
	}, "low")
	-- Smoke
	mcla_particles.add_node_particlespawner(pos, {
		amount = 0.5,
		time = 0,
		minpos = vector.add(pos, { x = -1/16, y = 0.04, z = -1/16 }),
		maxpos = vector.add(pos, { x = -1/16, y = 0.06, z = -1/16 }),
		minvel = { x = 0, y = 0.5, z = 0 },
		maxvel = { x = 0, y = 0.6, z = 0 },
		minexptime = 2.0,
		maxexptime = 2.0,
		minsize = 1.5,
		maxsize = 1.5,
		texture = "mcla_particles_smoke_anim.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 8,
			aspect_h = 8,
			length = 2.05,
		},
	}, "medium")
end

local spawn_flames_wall = function(pos, param2)
	local minrelpos, maxrelpos
	local dir = minetest.wallmounted_to_dir(param2)
	if dir.x < 0 then
		minrelpos = { x = -0.38, y = 0.04, z = -0.1 }
		maxrelpos = { x = -0.2, y = 0.14, z = 0.1 }
	elseif dir.x > 0 then
		minrelpos = { x = 0.2, y = 0.04, z = -0.1 }
		maxrelpos = { x = 0.38, y = 0.14, z = 0.1 }
	elseif dir.z < 0 then
		minrelpos = { x = -0.1, y = 0.04, z = -0.38 }
		maxrelpos = { x = 0.1, y = 0.14, z = -0.2 }
	elseif dir.z > 0 then
		minrelpos = { x = -0.1, y = 0.04, z = 0.2 }
		maxrelpos = { x = 0.1, y = 0.14, z = 0.38 }
	else
		return
	end
	-- Flames
	mcla_particles.add_node_particlespawner(pos, {
		amount = 8,
		time = 0,
		minpos = vector.add(pos, minrelpos),
		maxpos = vector.add(pos, maxrelpos),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.7,
		maxsize = 2,
		texture = "mcla_particles_flame.png",
		glow = LIGHT_TORCH,
	}, "low")
	-- Smoke
	mcla_particles.add_node_particlespawner(pos, {
		amount = 0.5,
		time = 0,
		minpos = vector.add(pos, minrelpos),
		maxpos = vector.add(pos, maxrelpos),
		minvel = { x = 0, y = 0.5, z = 0 },
		maxvel = { x = 0, y = 0.6, z = 0 },
		minexptime = 2.0,
		maxexptime = 2.0,
		minsize = 1.5,
		maxsize = 1.5,
		texture = "mcla_particles_smoke_anim.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 8,
			aspect_h = 8,
			length = 2.05,
		},
	}, "medium")
end

local remove_flames = function(pos)
	mcla_particles.delete_node_particlespawners(pos)
end

--
-- 3d torch part
--

-- Check if placement at given node is allowed
local function check_placement_allowed(node, wdir)
	-- Torch placement rules: Disallow placement on some nodes. General rule: Solid, opaque, full cube collision box nodes are allowed.
	-- Special allowed nodes:
	-- * mob spawner
	-- * glass, ice
	-- * Fence, wall: Only on top
	-- * Slab, stairs: Only on top if upside down

	-- Special forbidden nodes:
	-- * Piston, sticky piston
	local def = minetest.registered_nodes[node.name]
	if not def then
		return false
	-- No ceiling torches
	elseif wdir == 0 then
		return false
	elseif not def.buildable_to then
		if node.name ~= "mcla:ice" and node.name ~= "mcla:spawner" and (not def.groups.glass) and
				((not def.groups.solid) or (not def.groups.opaque)) then
			-- Only allow top placement on these nodes
			if def.groups.fence == 1 or def.groups.wall or def.groups.slab_top == 1 or def.groups.pane or (def.groups.stair == 1 and minetest.facedir_to_dir(node.param2).y ~= 0) then
				if wdir ~= 1 then
					return false
				end
			else
				return false
			end
		elseif minetest.get_item_group(node.name, "piston") >= 1 then
			return false
		end
	end
	return true
end

mcla_torches = {}

mcla_torches.register_torch = function(substring, description, icon, mesh_floor, mesh_wall, tiles, light, groups, sounds, moredef, moredef_floor, moredef_wall)
	local itemstring = "mcla:"..substring
	local itemstring_wall = "mcla:"..substring.."_wall"

	if light == nil then light = minetest.LIGHT_MAX end
	if mesh_floor == nil then mesh_floor = "mcl_torches_torch_floor.obj" end
	if mesh_wall == nil then mesh_wall = "mcl_torches_torch_wall.obj" end
	if groups == nil then groups = {} end

	groups.attached_node = 1
	groups.torch = 1
	groups.dig_by_water = 1
	groups.destroy_by_lava_flow = 1

	local floordef = {
		description = description,
		drawtype = "mesh",
		mesh = mesh_floor,
		inventory_image = icon,
		wield_image = icon,
		tiles = tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		liquids_pointable = false,
		light_source = light,
		groups = groups,
		drop = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_top = {-1/16, -1/16, -1/16, 1/16, 0.5, 1/16},
			wall_bottom = {-1/16, -0.5, -1/16, 1/16, 1/16, 1/16},
		},
		sounds = sounds,
		node_placement_prediction = "",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				-- no interaction possible with entities, for now.
				return itemstack
			end

			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local def = minetest.registered_nodes[node.name]
			if not def then return itemstack end

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(under, node, placer, itemstack) or itemstack
				end
			end

			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})

			if check_placement_allowed(node, wdir) == false then
				return itemstack
			end

			local itemstring = itemstack:get_name()
			local fakestack = ItemStack(itemstack)
			local idef = fakestack:get_definition()
			local retval

			if wdir == 1 then
				retval = fakestack:set_name(itemstring)
			else
				retval = fakestack:set_name(itemstring_wall)
			end
			if not retval then
				return itemstack
			end

			local success
			itemstack, success = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring)

			if success and idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=under, gain=1}, true)
			end
			return itemstack
		end,
		on_rotate = false,
	}
	if moredef ~= nil then
		for k,v in pairs(moredef) do
			floordef[k] = v
		end
	end
	if moredef_floor ~= nil then
		for k,v in pairs(moredef_floor) do
			floordef[k] = v
		end
	end
	minetest.register_node(":"..itemstring, floordef)

	local groups_wall = table.copy(groups)
	groups_wall.torch = 2

	local walldef = {
		drawtype = "mesh",
		mesh = mesh_wall,
		tiles = tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		light_source = light,
		groups = groups_wall,
		drop = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
			wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
			wall_side = {-0.5, -0.5, -0.1, -0.2, 0.1, 0.1},
		},
		sounds = sounds,
		on_rotate = false,
	}
	if moredef ~= nil then
		for k,v in pairs(moredef) do
			walldef[k] = v
		end
	end
	if moredef_wall ~= nil then
		for k,v in pairs(moredef_wall) do
			walldef[k] = v
		end
	end
	minetest.register_node(":"..itemstring_wall, walldef)

end

mcla_torches.register_torch("torch",
	S("Torch"),
	"mcla_torches_on_floor.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{{
		name = "mcla_torches_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	LIGHT_TORCH,
	{dig_immediate=3, torch=1, deco_block=1},
	mcla_sounds.node_sound_wood(),
	{
	on_destruct = function(pos)
		remove_flames(pos)
	end},
	{on_construct = function(pos)
		spawn_flames_floor(pos)
	end},
	{on_construct = function(pos)
		local node = minetest.get_node(pos)
		spawn_flames_wall(pos, node.param2)
	end})

minetest.register_craft({
	output = "mcla:torch 4",
	recipe = {
		{ "group:coal" },
		{ "mcla:stick" },
	}
})

minetest.register_lbm({
	label = "Torch flame particles",
	name = "mcla_torches:flames",
	nodenames = {"mcla:torch", "mcla:torch_wall"},
	run_at_every_load = true,
	action = function(pos, node)
		if node.name == "mcla:torch" then
			spawn_flames_floor(pos)
		elseif node.name == "mcla:torch_wall" then
			spawn_flames_wall(pos, node.param2)
		end
	end,
})

