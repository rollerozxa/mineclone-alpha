--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SKELETON
--###################



local skeleton = {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	breath_max = -1,
	armor = {undead = 100, fleshy = 100},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	pathfinding = 1,
	group_attack = true,
	visual = "mesh",
	mesh = "mobs_mc_skeleton.b3d",
	textures = { {
		"mcla_bows_bow_0.png", -- bow
		"mobs_mc_skeleton.png", -- skeleton
	} },
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 2,
	reach = 2,
	drops = {
		{name = "mcla:arrow",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = "mcla:bow",
		chance = 100 / 8.5,
		min = 1,
		max = 1,
		looting = "rare",}
	},
	animation = {
		stand_speed = 15,
		stand_start = 0,
		stand_end = 0,
		walk_speed = 15,
		walk_start = 40,
		walk_end = 60,
		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		die_start = 160,
		die_end = 170,
		die_speed = 15,
		die_loop = false,
	},
	ignited_by_sunlight = true,
	view_range = 16,
	fear_height = 4,
	attack_type = "dogshoot",
	arrow = "mcla:arrow_entity",
	shoot_arrow = function(self, pos, dir)
		-- 2-4 damage per arrow
		local dmg = math.max(4, math.random(2, 8))
		mcla_bows.shoot_arrow("mcla:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	harmed_by_heal = true,
}

mobs:register_mob("mobs_mc:skeleton", skeleton)


-- Overworld spawn
mobs:spawn_specific("mobs_mc:skeleton", mobs_mc.spawn.solid, {"air"}, 0, 7, 20, 17000, 2, mcla_vars.mg_overworld_min, mcla_vars.mg_overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:skeleton", S("Skeleton"), "mobs_mc_spawn_icon_skeleton.png", 0)
