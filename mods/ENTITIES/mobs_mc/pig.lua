--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

mobs:register_mob("mobs_mc:pig", {
	type = "animal",
	spawn_class = "passive",
	runaway = true,
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 0.865, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_pig.b3d",
	textures = {{
		"blank.png", -- baby
		"mobs_mc_pig.png", -- base
		"blank.png", -- saddle
	}},
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 3,
	follow_velocity = 3.4,
	drops = {
		{name = "mcla:porkchop",
		chance = 1,
		min = 1,
		max = 3,
		looting = "common",},
	},
	fear_height = 4,
	sounds = {
		random = "mobs_pig",
		death = "mobs_pig_angry",
		damage = "mobs_pig",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_speed = 40,
		walk_speed = 40,
		run_speed = 90,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
	},
	view_range = 8,
	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 4
			self.max_speed_reverse = 2
			self.accel = 4
			self.terrain_type = 3
			self.driver_attach_at = {x = 0.0, y = 2.75, z = -1.5}
			self.driver_eye_offset = {x = 0, y = 3, z = 0}
			self.driver_scale = {x = 1/self.visual_size.x, y = 1/self.visual_size.y}
		end

		-- if driver present allow control of horse
		if self.driver then

			mobs.drive(self, "walk", "stand", false, dtime)

			return false -- skip rest of mob functions
		end

		return true
	end,

	on_die = function(self, pos)

		-- drop saddle when horse is killed while riding
		-- also detach from horse properly
		if self.driver then
			mobs.detach(self.driver, {x = 1, y = 0, z = 1})
		end
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

		local wielditem = clicker:get_wielded_item()

		if mobs:protect(self, clicker) then return end

		if self.child then
			return
		end

		-- Put saddle on pig
		local item = clicker:get_wielded_item()
		if item:get_name() == "mcla:saddle" and self.saddle ~= "yes" then
			self.base_texture = {
				"blank.png", -- baby
				"mobs_mc_pig.png", -- base
				"mobs_mc_pig_saddle.png", -- saddle
			}
			self.object:set_properties({
				textures = self.base_texture
			})
			self.saddle = "yes"
			self.tamed = true
			self.drops = {
				{name = "mcla:porkchop",
				chance = 1,
				min = 1,
				max = 3,},
				{name = "mcla:saddle",
				chance = 1,
				min = 1,
				max = 1,},
			}
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				local inv = clicker:get_inventory()
				local stack = inv:get_stack("main", clicker:get_wield_index())
				stack:take_item()
				inv:set_stack("main", clicker:get_wield_index(), stack)
			end
			minetest.sound_play({name = "mcl_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
			return
		end

		-- Mount or detach player
		local name = clicker:get_player_name()
		if self.driver and clicker == self.driver then
			-- Detach if already attached
			mobs.detach(clicker, {x=1, y=0, z=0})
			return

		elseif not self.driver and self.saddle == "yes" then
			-- Ride pig if it has a saddle and player uses a carrot on a stick

			mobs.attach(self, clicker)
			return

		-- Capture pig
		elseif not self.driver and clicker:get_wielded_item():get_name() ~= "" then
			mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
		end
	end,

	on_breed = function(parent1, parent2)
		local pos = parent1.object:get_pos()
		local child = mobs:spawn_child(pos, parent1.name)
		if child then
			local ent_c = child:get_luaentity()
			ent_c.tamed = true
			ent_c.owner = parent1.owner
			return false
		end
	end,
})

mobs:spawn_specific("mobs_mc:pig", mobs_mc.spawn.grassland, {"air"}, 9, minetest.LIGHT_MAX+1, 30, 15000, 8, mcl_vars.mg_overworld_min, mcl_vars.mg_overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:pig", S("Pig"), "mobs_mc_spawn_icon_pig.png", 0)
