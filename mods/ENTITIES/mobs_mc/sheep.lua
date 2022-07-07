--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SHEEP
--###################

local colors = {
	-- group = { wool, textures }
	unicolor_white = { "mcla:white", "#FFFFFF00" },
}

local sheep_texture = function(color_group)
	color_group = "unicolor_white"
	return {
		"mobs_mc_sheep_fur.png^[colorize:"..colors[color_group][2],
		"mobs_mc_sheep.png",
	}
end

local gotten_texture = { "blank.png", "mobs_mc_sheep.png" }

--mcsheep
mobs:register_mob("mobs_mc:sheep", {
	type = "animal",
	spawn_class = "passive",
	hp_min = 8,
	hp_max = 8,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.29, 0.45},

	visual = "mesh",
	visual_size = {x=3, y=3},
	mesh = "mobs_mc_sheepfur.b3d",
	textures = { sheep_texture("unicolor_white") },
	gotten_texture = gotten_texture,
	color = "unicolor_white",
	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = colors["unicolor_white"][1],
		chance = 1,
		min = 1,
		max = 1,
		looting = "common",},
	},
	fear_height = 4,
	sounds = {
		random = "mobs_sheep",
		death = "mobs_sheep",
		damage = "mobs_sheep",
		sounds = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		speed_normal = 25,	run_speed = 65,
		stand_start = 40,	stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	view_range = 12,

	-- Eat grass
	replace_rate = 20,
	replace_what = {
		{ "mcla:dirt_with_grass", "mcla:dirt", -1 }
	},
	-- Properly regrow wool after eating grass
	on_replace = function(self, pos, oldnode, newnode)
		if not self.color or not colors[self.color] then
			self.color = "unicolor_white"
		end
		self.gotten = false
		self.base_texture = sheep_texture(self.color)
		self.object:set_properties({ textures = self.base_texture })
		self.drops = {
			{name = colors[self.color][1],
			chance = 1,
			min = 1,
			max = 1,},
		}
	end,

	-- Set random color on spawn
	do_custom = function(self)

	end,

	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()

		if mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mobs:protect(self, clicker) then return end

		if mobs:capture_mob(self, clicker, 0, 5, 70, false, nil) then return end
	end,
	on_breed = function(parent1, parent2)
		-- Breed sheep and choose a fur color for the child.
		local pos = parent1.object:get_pos()
		local child = mobs:spawn_child(pos, parent1.name)
	end,
})
mobs:spawn_specific("mobs_mc:sheep", mobs_mc.spawn.grassland, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 3, mcl_vars.mg_overworld_min, mcl_vars.mg_overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:sheep", S("Sheep"), "mobs_mc_spawn_icon_sheep.png", 0)
