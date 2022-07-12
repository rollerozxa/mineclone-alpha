-- Global namespace for functions

mcla_fire = {}

local S = minetest.get_translator("mcla_fire")
local N = function(s) return s end

local spawn_smoke = function(pos)
	mcla_particles.add_node_particlespawner(pos, {
		amount = 0.1,
		time = 0,
		minpos = vector.add(pos, { x = -0.45, y = -0.45, z = -0.45 }),
		maxpos = vector.add(pos, { x = 0.45, y = 0.45, z = 0.45 }),
		minvel = { x = 0, y = 0.5, z = 0 },
		maxvel = { x = 0, y = 0.6, z = 0 },
		minexptime = 2.0,
		maxexptime = 2.0,
		minsize = 3.0,
		maxsize = 4.0,
		texture = "mcla_particles_smoke_anim.png^[colorize:#000000:127",
		animation = {
			type = "vertical_frames",
			aspect_w = 8,
			aspect_h = 8,
			length = 2.1,
		},
	}, "high")
end

local adjacents = {
	{ x =-1, y = 0, z = 0 },
	{ x = 1, y = 0, z = 0 },
	{ x = 0, y = 1, z = 0 },
	{ x = 0, y =-1, z = 0 },
	{ x = 0, y = 0, z =-1 },
	{ x = 0, y = 0, z = 1 },
}

math.randomseed(os.time())
local function shuffle_table(t)
	for i = #t, 1, -1 do
		local r = math.random(i)
		t[i], t[r] = t[r], t[i]
	end
end
shuffle_table(adjacents)

local function has_flammable(pos)
	for k,v in pairs(adjacents) do
		local p=vector.add(pos,v)
		local n=minetest.get_node_or_nil(p)
		if n and minetest.get_item_group(n.name, "flammable") ~= 0 then
			return p
		end
	end
end

--
-- Items
--

-- Flame nodes

-- Fire settings

-- When enabled, fire destroys other blocks.
local fire_enabled = minetest.settings:get_bool("enable_fire", true)

local fire_death_messages = {
	N("@1 has been cooked crisp."),
	N("@1 felt the burn."),
	N("@1 died in the flames."),
	N("@1 died in a fire."),
}

local spawn_fire = function(pos, age)
	minetest.set_node(pos, {name="mcla:fire", param2 = age})
	minetest.check_single_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
end

minetest.register_node(":mcla:fire", {
	description = S("Fire"),
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	_mcla_node_death_message = fire_death_messages,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1,  destroys_items=1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	drop = "",
	sounds = {},
	on_construct = function(pos)
		local bpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local under = minetest.get_node(bpos).name

		spawn_smoke(pos)
	end,
	on_destruct = function(pos)
		mcla_particles.delete_node_particlespawners(pos)
	end,
	_mcla_blast_resistance = 0,
})

--
-- Sound
--

local handles = {}
local timer = 0

-- Parameters

local radius = 8 -- Flame node search radius around player
local cycle = 3 -- Cycle time for sound updates

-- Update sound for player

function mcla_fire.update_player_sound(player)
	local player_name = player:get_player_name()
	-- Search for flame nodes in radius around player
	local ppos = player:get_pos()
	local areamin = vector.subtract(ppos, radius)
	local areamax = vector.add(ppos, radius)
	local fpos, num = minetest.find_nodes_in_area(
		areamin,
		areamax,
		{"mcla:fire"}
	)
	-- Total number of flames in radius
	local flames = (num["mcla:fire"] or 0)
	-- Stop previous sound
	if handles[player_name] then
		minetest.sound_fade(handles[player_name], -0.4, 0.0)
		handles[player_name] = nil
	end
	-- If flames
	if flames > 0 then
		-- Find centre of flame positions
		local fposmid = fpos[1]
		-- If more than 1 flame
		if #fpos > 1 then
			local fposmin = areamax
			local fposmax = areamin
			for i = 1, #fpos do
				local fposi = fpos[i]
				if fposi.x > fposmax.x then
					fposmax.x = fposi.x
				end
				if fposi.y > fposmax.y then
					fposmax.y = fposi.y
				end
				if fposi.z > fposmax.z then
					fposmax.z = fposi.z
				end
				if fposi.x < fposmin.x then
					fposmin.x = fposi.x
				end
				if fposi.y < fposmin.y then
					fposmin.y = fposi.y
				end
				if fposi.z < fposmin.z then
					fposmin.z = fposi.z
				end
			end
			fposmid = vector.divide(vector.add(fposmin, fposmax), 2)
		end
		-- Play sound
		local handle = minetest.sound_play(
			"fire_fire",
			{
				pos = fposmid,
				to_player = player_name,
				gain = math.min(0.06 * (1 + flames * 0.125), 0.18),
				max_hear_distance = 32,
				loop = true, -- In case of lag
			}
		)
		-- Store sound handle for this player
		if handle then
			handles[player_name] = handle
		end
	end
end

-- Cycle for updating players sounds

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < cycle then
		return
	end

	timer = 0
	local players = minetest.get_connected_players()
	for n = 1, #players do
		mcla_fire.update_player_sound(players[n])
	end
end)

-- Stop sound and clear handle on player leave

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	if handles[player_name] then
		minetest.sound_stop(handles[player_name])
		handles[player_name] = nil
	end
end)



-- Set pointed_thing on (normal) fire.
-- * pointed_thing: Pointed thing to ignite
-- * player: Player who sets fire or nil if nobody
-- * allow_on_fire: If false, can't ignite fire on fire (default: true)
mcla_fire.set_fire = function(pointed_thing, player, allow_on_fire)
	local pname
	if player == nil then
		pname = ""
	else
		pname = player:get_player_name()
	end
	local n = minetest.get_node(pointed_thing.above)
	local nu = minetest.get_node(pointed_thing.under)
	if allow_on_fire == false and minetest.get_item_group(nu.name, "fire") ~= 0 then
		return
	end
	if minetest.is_protected(pointed_thing.above, pname) then
		minetest.record_protection_violation(pointed_thing.above, pname)
		return
	end
	if n.name == "air" then
		minetest.add_node(pointed_thing.above, {name="mcla:fire"})
	end
end

--
-- ABMs
--

-- Extinguish all flames quickly with water and such

minetest.register_abm({
	label = "Extinguish fire",
	nodenames = {"mcla:fire"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
		minetest.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.15}, true)
	end,
})


-- Enable the following ABMs according to 'enable fire' setting

-- [...]a fire that is not adjacent to any flammable block does not spread, even to another flammable block within the normal range.
-- https://minecraft.fandom.com/wiki/Fire#Spread

local function check_aircube(p1,p2)
	local nds=minetest.find_nodes_in_area(p1,p2,{"air"})
	shuffle_table(nds)
	for k,v in pairs(nds) do
		if has_flammable(v) then return v end
	end
end


-- [...] a fire block can turn any air block that is adjacent to a flammable block into a fire block. This can happen at a distance of up to one block downward, one block sideways (including diagonals), and four blocks upward of the original fire block (not the block the fire is on/next to).
local function get_ignitable(pos)
	return check_aircube(vector.add(pos,vector.new(-1,-1,-1)),vector.add(pos,vector.new(1,4,1)))
end
-- Fire spreads from a still lava block similarly: any air block one above and up to one block sideways (including diagonals) or two above and two blocks sideways (including diagonals) that is adjacent to a flammable block may be turned into a fire block.
local function get_ignitable_by_lava(pos)
	return check_aircube(vector.add(pos,vector.new(-1,1,-1)),vector.add(pos,vector.new(1,1,1))) or check_aircube(vector.add(pos,vector.new(-2,2,-2)),vector.add(pos,vector.new(2,2,2))) or nil
end

if not fire_enabled then

	-- Occasionally remove fire if fire disabled
	-- NOTE: Fire is normally extinguished in timer function
	minetest.register_abm({
		label = "Remove disabled fire",
		nodenames = {"mcla:fire"},
		interval = 10,
		chance = 10,
		catch_up = false,
		action = minetest.remove_node,
	})

else -- Fire enabled

	-- Fire Spread
	minetest.register_abm({
		label = "Ignite flame",
		nodenames ={"mcla:fire"},
		interval = 7,
		chance = 12,
		catch_up = false,
		action = function(pos)
			local p = get_ignitable(pos)
			if p then
				spawn_fire(p)
				shuffle_table(adjacents)
			end
		end
	})

	--lava fire spread
	minetest.register_abm({
		label = "Ignite fire by lava",
		nodenames = {"mcla:lava_source"},
		neighbors = {"air","group:flammable"},
		interval = 7,
		chance = 3,
		catch_up = false,
		action = function(pos)
			local p=get_ignitable_by_lava(pos)
			if p then
				spawn_fire(p)
			end
		end,
	})

	minetest.register_abm({
		label = "Remove fires",
		nodenames = {"mcla:fire"},
		interval = 7,
		chance = 3,
		catch_up = false,
		action = function(pos)
			local p=has_flammable(pos)
			if p then
				local n=minetest.get_node_or_nil(p)
				if n and minetest.get_item_group(n.name, "flammable") < 1 then
					minetest.remove_node(pos)
				end
			else
				minetest.remove_node(pos)
			end
		end,
	})

	-- Remove flammable nodes around basic flame
	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"mcla:fire"},
		neighbors = {"group:flammable"},
		interval = 5,
		chance = 18,
		catch_up = false,
		action = function(pos)
			local p = has_flammable(pos)
			if not p then
				return
			end

			local nn = minetest.get_node(p).name
			local def = minetest.registered_nodes[nn]
			local fgroup = minetest.get_item_group(nn, "flammable")

			if def and def._on_burn then
				def._on_burn(p)
			elseif fgroup ~= -1 then
				spawn_fire(p)
				minetest.check_for_falling(p)
			end
		end
	})
end

minetest.register_lbm({
	label = "Smoke particles from fire",
	name = "mcla_fire:smoke",
	nodenames = {"group:fire"},
	run_at_every_load = true,
	action = function(pos, node)
		spawn_smoke(pos)
	end,
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/flint_and_steel.lua")
