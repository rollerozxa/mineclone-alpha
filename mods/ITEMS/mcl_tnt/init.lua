local S = minetest.get_translator("mcla_tnt")

local function spawn_tnt(pos, entname)
	minetest.sound_play("tnt_ignite", {pos = pos,gain = 1.0,max_hear_distance = 15,}, true)
	local tnt = minetest.add_entity(pos, entname)
	tnt:set_armor_groups({immortal=1})
	return tnt
end

mcla_tnt = {}
mcla_tnt.ignite = function(pos)
	minetest.remove_node(pos)
	local e = spawn_tnt(pos, "mcla_tnt:tnt")
	minetest.check_for_falling(pos)
	return e
end

-- Add smoke particle of entity at pos.
-- Intended to be called every step
mcla_tnt.smoke_step = function(pos)
	minetest.add_particle({
		pos = {x=pos.x,y=pos.y+0.5,z=pos.z},
		velocity = vector.new(math.random() * 0.2 - 0.1, 1.0 + math.random(), math.random() * 0.2 - 0.1),
		acceleration = vector.new(0, -0.1, 0),
		expirationtime = 0.15 + math.random() * 0.25,
		size = 1.0 + math.random(),
		collisiondetection = false,
		texture = "mcla_particles_smoke.png"
	})
end

mcla_tnt.BOOMTIMER = 4
mcla_tnt.BLINKTIMER = 0.25

local TNT_RANGE = 3

local sounds = mcla_sounds.node_sound_wood()
local tnt_mesecons = {effector = {
		action_on = mcla_tnt.ignite,
		rules = mesecon.rules.alldirs,
	}}

minetest.register_node(":mcla:tnt", {
	tiles = {"mcla_tnt_top.png", "mcla_tnt_bottom.png",
			"mcla_tnt_side.png", "mcla_tnt_side.png",
			"mcla_tnt_side.png", "mcla_tnt_side.png"},
	is_ground_content = false,
	stack_max = 64,
	description = S("TNT"),
	paramtype = "light",
	sunlight_propagates = true,
	groups = { dig_immediate = 3, tnt = 1, flammable=-1 },
	mesecons = tnt_mesecons,
	drop = '',
	after_destruct = function(pos)
		mcla_tnt.ignite(pos)
	end,
	on_blast = function(pos)
	        local e = mcla_tnt.ignite(pos)
		e:get_luaentity().timer = mcla_tnt.BOOMTIMER - (0.5 + math.random())
	end,
	_on_ignite = function(player, pointed_thing)
		mcla_tnt.ignite(pointed_thing.under)
		return true
	end,
	_on_burn = function(pos)
		mcla_tnt.ignite(pos)
		return true
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Place and ignite TNT
		if minetest.registered_nodes[dropnode.name].buildable_to then
			minetest.set_node(droppos, {name = stack:get_name()})
			mcla_tnt.ignite(droppos)
		end
	end,
	sounds = sounds,
})

local TNT = {
	-- Static definition
	physical = true, -- Collides with things
	 --weight = -100,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"mcla_tnt_top.png", "mcla_tnt_bottom.png",
			"mcla_tnt_side.png", "mcla_tnt_side.png",
			"mcla_tnt_side.png", "mcla_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	blinktimer = 0,
	tnt_knockback = true,
	blinkstatus = true,}

function TNT:on_activate(staticdata)
	local phi = math.random(0, 65535) / 65535 * 2*math.pi
	local hdir_x = math.cos(phi) * 0.02
	local hdir_z = math.sin(phi) * 0.02
	self.object:set_velocity({x=hdir_x, y=2, z=hdir_z})
	self.object:set_acceleration({x=0, y=-10, z=0})
	self.object:set_texture_mod("^mcla_tnt_blink.png")
end

local function add_effects(pos, radius, drops)
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 1,
		maxsize = radius * 3,
		texture = "mcla_particles_smoke.png",
	})

	-- we just dropped some items. Look at the items entities and pick
	-- one of them to use as texture
	local texture = "mcla_particles_smoke.png" --fallback texture
	local most = 0
	for name, stack in pairs(drops) do
		local count = stack:get_count()
		if count > most then
			most = count
			local def = minetest.registered_nodes[name]
			if def and def.tiles and def.tiles[1] then
				texture = def.tiles[1]
			end
		end
	end

	minetest.add_particlespawner({
		amount = 32,
		time = 0.1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -3, y = 0, z = -3},
		maxvel = {x = 3, y = 5,  z = 3},
		minacc = {x = 0, y = -10, z = 0},
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = radius * 0.66,
		maxsize = radius * 2,
		texture = texture,
		collisiondetection = true,
	})
end

function TNT:on_step(dtime)
	local pos = self.object:get_pos()
	mcla_tnt.smoke_step(pos)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
	if self.blinktimer > mcla_tnt.BLINKTIMER then
		self.blinktimer = self.blinktimer - mcla_tnt.BLINKTIMER
		if self.blinkstatus then
			self.object:set_texture_mod("")
		else
			self.object:set_texture_mod("^mcla_tnt_blink.png")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > mcla_tnt.BOOMTIMER then
		mcla_explosions.explode(self.object:get_pos(), 4, {}, self.object)
		self.object:remove()
	end
end

minetest.register_entity("mcla_tnt:tnt", TNT)

minetest.register_craft({
	output = "mcla:tnt",
	recipe = {
		{'mcla:gunpowder','group:sand','mcla:gunpowder'},
		{'group:sand','mcla:gunpowder','group:sand'},
		{'mcla:gunpowder','group:sand','mcla:gunpowder'}
	}
})
