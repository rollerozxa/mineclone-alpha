local S = minetest.get_translator("mcl_playerplus")

-- Internal player state
local mcl_playerplus_internal = {}

local def = {}
local time = 0

-- converts yaw to degrees
local function degrees(rad)
	return rad * 180.0 / math.pi
end

local dir_to_pitch = function(dir)
	local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local pitch, name, node_stand, node_stand_below, node_head, node_feet, pos

local function roundN(n, d)
	if type(n) ~= "number" then return n end
    local m = 10^d
    return math.floor(n * m + 0.5) / m
end

local function close_enough(a,b)
	local rt=true
	if type(a) == "table" and type(b) == "table" then
		for k,v in pairs(a) do
			if roundN(v,2) ~= roundN(b[k],2) then
				rt=false
				break
			end
		end
	else
		rt = roundN(a,2) == roundN(b,2)
	end
	return rt
end



local function props_changed(props,oldprops)
	local changed=false
	local p={}
	for k,v in pairs(props) do
		if not close_enough(v,oldprops[k]) then
			p[k]=v
			changed=true
		end
	end
	return changed,p
end

--test if assert works
assert(true)
assert(not false)

--test data for == and ~=
local test_equal1=42
local test_equal2=42.0
local test_equal3=42.1

assert(test_equal1==test_equal1)
assert(test_equal1==test_equal2)
assert(test_equal1~=test_equal3)

--testdata for roundN
local test_round1=15
local test_round2=15.00199999999
local test_round3=15.00111111
local test_round4=15.00999999

assert(roundN(test_round1,2)==roundN(test_round1,2)) --test again if basic equality works because wth not
assert(roundN(test_round1,2)==roundN(test_round2,2))
assert(roundN(test_round1,2)==roundN(test_round3,2))
assert(roundN(test_round1,2)~=roundN(test_round4,2))


-- tests for close_enough
local test_cb = {-0.35,0,-0.35,0.35,0.8,0.35} --collisionboxes
local test_cb_close = {-0.351213,0,-0.35,0.35,0.8,0.351212}
local test_cb_diff = {-0.35,0,-1.35,0.35,0.8,0.35}

local test_eh = 1.65 --eye height
local test_eh_close = 1.65123123
local test_eh_diff = 1.35

local test_nt = { r = 225, b = 225, a = 225, g = 225 } --nametag
local test_nt_diff = { r = 225, b = 225, a = 0, g = 225 }

assert(close_enough(test_cb,test_cb_close))
assert(not close_enough(test_cb,test_cb_diff))

assert(close_enough(test_eh,test_eh_close))
assert(not close_enough(test_eh,test_eh_diff))

assert(not close_enough(test_nt,test_nt_diff)) --no floats involved here

--tests for props_changed
local test_properties_set1={collisionbox = {-0.35,0,-0.35,0.35,0.8,0.35}, eye_height = 0.65, nametag_color = { r = 225, b = 225, a = 225, g = 225 }}
local test_properties_set2={collisionbox = {-0.35,0,-0.35,0.35,0.8,0.35}, eye_height = 1.35, nametag_color = { r = 225, b = 225, a = 225, g = 225 }}

local test_p1,p=props_changed(test_properties_set1,test_properties_set1)
local test_p2,p=props_changed(test_properties_set1,test_properties_set2)

assert(not test_p1)
assert(test_p2)

-- we still don't really know if lua is lying to us! but at least everything *seems* to be ok

local function set_properties_conditional(player,props)
	local changed,p=props_changed(props,player:get_properties())
	if changed then
		player:set_properties(p)
	end
end

local function set_bone_position_conditional(player,b,p,r) --bone,position,rotation
	local oldp,oldr=player:get_bone_position(b)
	if vector.equals(vector.round(oldp),vector.round(p)) and vector.equals(vector.round(oldr),vector.round(r)) then
		return
	end
	player:set_bone_position(b,p,r)
end

minetest.register_globalstep(function(dtime)
	time = time + dtime

	-- Update jump status immediately since we need this info in real time.
	-- WARNING: This section is HACKY as hell since it is all just based on heuristics.
	for _,player in ipairs(minetest.get_connected_players()) do
		local controls = player:get_player_control()
		name = player:get_player_name()

		local player_velocity = player:get_velocity() or player:get_player_velocity()

		-- controls head bone
		local pitch = degrees(player:get_look_vertical()) * -1
		local yaw = degrees(player:get_look_horizontal()) * -1

		local player_vel_yaw = 0

		if degrees(minetest.dir_to_yaw(player_velocity)) == 0 then
			yaw = 0
		else
			player_vel_yaw = degrees(minetest.dir_to_yaw(player_velocity))
		end

		-- controls right and left arms pitch when shooting a bow or punching
		if string.find(player:get_wielded_item():get_name(), "mcl_bows:bow") and controls.RMB and not controls.LMB and not controls.up and not controls.down and not controls.left and not controls.right then
			set_bone_position_conditional(player,"Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(pitch+90,-30,pitch * -1 * .35))
			set_bone_position_conditional(player,"Arm_Left_Pitch_Control", vector.new(3.5,5.785,0), vector.new(pitch+90,43,pitch * .35))
		elseif controls.LMB and player:get_attach() == nil then
			set_bone_position_conditional(player,"Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(pitch,0,0))
			set_bone_position_conditional(player,"Arm_Left_Pitch_Control", vector.new(3,5.785,0), vector.new(0,0,0))
		else
			set_bone_position_conditional(player,"Arm_Left_Pitch_Control", vector.new(3,5.785,0), vector.new(0,0,0))
			set_bone_position_conditional(player,"Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(0,0,0))
		end

		if controls.sneak and player:get_attach() == nil then
			-- controls head pitch when sneaking
			set_bone_position_conditional(player,"Head", vector.new(0,6.3,0), vector.new(pitch+36,0,0))
			-- sets eye height, and nametag color accordingly
			set_properties_conditional(player,{collisionbox = {-0.35,0,-0.35,0.35,1.8,0.35}, eye_height = 1.35, nametag_color = { r = 225, b = 225, a = 0, g = 225 }})
			-- sneaking body conrols
			set_bone_position_conditional(player,"Body_Control", vector.new(0,6.3,0), vector.new(0,0,0))
		elseif minetest.get_item_group(mcl_playerinfo[name].node_head, "water") ~= 0 and player:get_attach() == nil and mcl_sprint.is_sprinting(name) == true then
			-- set head pitch and yaw when swimming
			set_bone_position_conditional(player,"Head", vector.new(0,6.3,0), vector.new(pitch+90-degrees(dir_to_pitch(player_velocity)),yaw - player_vel_yaw * -1,0))
			-- sets eye height, and nametag color accordingly
			set_properties_conditional(player,{collisionbox = {-0.35,0,-0.35,0.35,0.8,0.35}, eye_height = 0.65, nametag_color = { r = 225, b = 225, a = 225, g = 225 }})
			-- control body bone when swimming
			set_bone_position_conditional(player,"Body_Control", vector.new(0,6.3,0), vector.new(degrees(dir_to_pitch(player_velocity)) - 90,player_vel_yaw * -1 - yaw + 180,0))

		elseif player:get_attach() == nil then
			-- sets eye height, and nametag color accordingly
			set_properties_conditional(player,{collisionbox = {-0.35,0,-0.35,0.35,1.8,0.35}, eye_height = 1.65, nametag_color = { r = 225, b = 225, a = 225, g = 225 }})

			if player_velocity.x > 0.35 or player_velocity.z > 0.35 or player_velocity.x < -0.35 or player_velocity.z < -0.35 then
				if player_vel_yaw * -1 - yaw < 90 or player_vel_yaw * -1 - yaw > 270 then
					-- controls head and Body_Control bones while moving backwards
					set_bone_position_conditional(player,"Head", vector.new(0,6.3,0), vector.new(pitch,yaw - player_vel_yaw * -1,0))
					set_bone_position_conditional(player,"Body_Control", vector.new(0,6.3,0), vector.new(0,player_vel_yaw * -1 - yaw,0))
				else
					-- controls head and Body_Control bones while moving forwards
					set_bone_position_conditional(player,"Head", vector.new(0,6.3,0), vector.new(pitch,yaw - player_vel_yaw * -1 + 180,0))
					set_bone_position_conditional(player,"Body_Control", vector.new(0,6.3,0), vector.new(0,player_vel_yaw * -1 - yaw + 180,0))
				end
			else
				set_bone_position_conditional(player,"Head", vector.new(0,6.3,0), vector.new(pitch,0,0))
				set_bone_position_conditional(player,"Body_Control", vector.new(0,6.3,0), vector.new(0,0,0))
			end
		else
			local attached = player:get_attach(parent)
			local attached_yaw = degrees(attached:get_yaw())
			set_properties_conditional(player,{collisionbox = {-0.35,0,-0.35,0.35,1.8,0.35}, eye_height = 1.65, nametag_color = { r = 225, b = 225, a = 225, g = 225 }})
			set_bone_position_conditional(player,"Head", vector.new(0,6.3,0), vector.new(pitch,degrees(player:get_look_horizontal()) * -1 + attached_yaw,0))
			set_bone_position_conditional(player,"Body_Control", vector.new(0,6.3,0), vector.new(0,0,0))
		end

		if mcl_playerplus_internal[name].jump_cooldown > 0 then
			mcl_playerplus_internal[name].jump_cooldown = mcl_playerplus_internal[name].jump_cooldown - dtime
		end
		if player:get_player_control().jump and mcl_playerplus_internal[name].jump_cooldown <= 0 then

			pos = player:get_pos()

			node_stand = mcl_playerinfo[name].node_stand
			node_stand_below = mcl_playerinfo[name].node_stand_below
			node_head = mcl_playerinfo[name].node_head
			node_feet = mcl_playerinfo[name].node_feet
			if not node_stand or not node_stand_below or not node_head or not node_feet then
				return
			end
			if not minetest.registered_nodes[node_stand] or not minetest.registered_nodes[node_stand_below] or not minetest.registered_nodes[node_head] or not minetest.registered_nodes[node_feet] then
				return
			end

			-- Cause buggy exhaustion for jumping

			--[[ Checklist we check to know the player *actually* jumped:
				* Not on or in liquid
				* Not on or at climbable
				* On walkable
				* Not on disable_jump
			FIXME: This code is pretty hacky and it is possible to miss some jumps or detect false
			jumps because of delays, rounding errors, etc.
			What this code *really* needs is some kind of jumping “callback” which this engine lacks
			as of 0.4.15.
			]]

			if minetest.get_item_group(node_feet, "liquid") == 0 and
					minetest.get_item_group(node_stand, "liquid") == 0 and
					not minetest.registered_nodes[node_feet].climbable and
					not minetest.registered_nodes[node_stand].climbable and
					(minetest.registered_nodes[node_stand].walkable or minetest.registered_nodes[node_stand_below].walkable)
					and minetest.get_item_group(node_stand, "disable_jump") == 0
					and minetest.get_item_group(node_stand_below, "disable_jump") == 0 then

			-- Reset cooldown timer
				mcl_playerplus_internal[name].jump_cooldown = 0.45
			end
		end
	end

	-- Run the rest of the code every 0.5 seconds
	if time < 0.5 then
		return
	end

	-- reset time for next check
	-- FIXME: Make sure a regular check interval applies
	time = 0

	-- check players
	for _,player in ipairs(minetest.get_connected_players()) do
		-- who am I?
		local name = player:get_player_name()

		-- where am I?
		local pos = player:get_pos()

		-- what is around me?
		local node_stand = mcl_playerinfo[name].node_stand
		local node_stand_below = mcl_playerinfo[name].node_stand_below
		local node_head = mcl_playerinfo[name].node_head
		local node_feet = mcl_playerinfo[name].node_feet
		if not node_stand or not node_stand_below or not node_head or not node_feet then
			return
		end

		-- set defaults
		def.speed = 1

		-- Reset speed decrease
		playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:surface")

		-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
		-- without group disable_suffocation=1)
		local ndef = minetest.registered_nodes[node_head]

		if (ndef.walkable == nil or ndef.walkable == true)
		and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
		and (ndef.node_box == nil or ndef.node_box.type == "regular")
		and (ndef.groups.disable_suffocation ~= 1)
		and (ndef.groups.opaque == 1)
		and (node_head ~= "ignore")
		-- Check privilege, too
		and (not minetest.check_player_privs(name, {noclip = true})) then
			if player:get_hp() > 0 then
				mcl_death_messages.player_damage(player, S("@1 suffocated to death.", name))
				player:set_hp(player:get_hp() - 1)
			end
		end

		-- Am I near a cactus?
		local near = minetest.find_node_near(pos, 1, "mcl_core:cactus")
		if not near then
			near = minetest.find_node_near({x=pos.x, y=pos.y-1, z=pos.z}, 1, "mcl_core:cactus")
		end
		if near then
			-- Am I touching the cactus? If so, it hurts
			local dist = vector.distance(pos, near)
			local dist_feet = vector.distance({x=pos.x, y=pos.y-1, z=pos.z}, near)
			if dist < 1.1 or dist_feet < 1.1 then
				if player:get_hp() > 0 then
					mcl_death_messages.player_damage(player, S("@1 was prickled to death by a cactus.", name))
					player:set_hp(player:get_hp() - 1, { type = "punch", from = "mod" })
				end
			end
		end

		--[[ Swimming: Cause exhaustion.
		NOTE: As of 0.4.15, it only counts as swimming when you are with the feet inside the liquid!
		Head alone does not count. We respect that for now. ]]
		if not player:get_attach() and (minetest.get_item_group(node_feet, "liquid") ~= 0 or
				minetest.get_item_group(node_stand, "liquid") ~= 0) then
			local lastPos = mcl_playerplus_internal[name].lastPos
			if lastPos then
				local dist = vector.distance(lastPos, pos)
				mcl_playerplus_internal[name].swimDistance = mcl_playerplus_internal[name].swimDistance + dist
				if mcl_playerplus_internal[name].swimDistance >= 1 then
					local superficial = math.floor(mcl_playerplus_internal[name].swimDistance)
					mcl_playerplus_internal[name].swimDistance = mcl_playerplus_internal[name].swimDistance - superficial
				end
			end

		end

		-- Underwater: Spawn bubble particles
		if minetest.get_item_group(node_head, "water") ~= 0 then

			minetest.add_particlespawner({
				amount = 10,
				time = 0.15,
				minpos = { x = -0.25, y = 0.3, z = -0.25 },
				maxpos = { x = 0.25, y = 0.7, z = 0.75 },
				attached = player,
				minvel = {x = -0.2, y = 0, z = -0.2},
				maxvel = {x = 0.5, y = 0, z = 0.5},
				minacc = {x = -0.4, y = 4, z = -0.4},
				maxacc = {x = 0.5, y = 1, z = 0.5},
				minexptime = 0.3,
				maxexptime = 0.8,
				minsize = 0.7,
				maxsize = 2.4,
				texture = "mcl_particles_bubble.png"
			})
		end

		-- Show positions of barriers when player is wielding a barrier
		local wi = player:get_wielded_item():get_name()
		if wi == "mcl_core:barrier" or wi == "mcl_core:realm_barrier" then
			local pos = vector.round(player:get_pos())
			local r = 8
			local vm = minetest.get_voxel_manip()
			local emin, emax = vm:read_from_map({x=pos.x-r, y=pos.y-r, z=pos.z-r}, {x=pos.x+r, y=pos.y+r, z=pos.z+r})
			local area = VoxelArea:new{
				MinEdge = emin,
				MaxEdge = emax,
			}
			local data = vm:get_data()
			for x=pos.x-r, pos.x+r do
			for y=pos.y-r, pos.y+r do
			for z=pos.z-r, pos.z+r do
				local vi = area:indexp({x=x, y=y, z=z})
				local nodename = minetest.get_name_from_content_id(data[vi])
				local tex
				if nodename == "mcl_core:barrier" then
					tex = "mcl_core_barrier.png"
				elseif nodename == "mcl_core:realm_barrier" then
					tex = "mcl_core_barrier.png^[colorize:#FF00FF:127^[transformFX"
				end
				if tex then
					minetest.add_particle({
						pos = {x=x, y=y, z=z},
						expirationtime = 1,
						size = 8,
						texture = tex,
						glow = 14,
						playername = name
					})
				end
			end
			end
			end
		end

		-- Update internal values
		mcl_playerplus_internal[name].lastPos = pos

	end

end)

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	mcl_playerplus_internal[name] = {
		lastPos = nil,
		swimDistance = 0,
		jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
	}
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	mcl_playerplus_internal[name] = nil
end)
