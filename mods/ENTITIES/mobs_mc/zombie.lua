--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### ZOMBIE
--###################

local drops_common = {
	{name = "mcl_mobitems:feather",
	chance = 1,
	min = 0,
	max = 2,
	looting = "common",}
}

local drops_zombie = table.copy(drops_common)

local zombie = {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	breath_max = -1,
	armor = {undead = 90, fleshy = 90},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	textures = {
		{"mobs_mc_zombie.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_zombie_growl",
		war_cry = "mobs_mc_zombie_growl",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 3,
	reach = 2,
	fear_height = 4,
	pathfinding = 1,
	jump = true,
	jump_height = 4,
	group_attack = { "mobs_mc:zombie", "mobs_mc:baby_zombie" },
	drops = drops_zombie,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	ignited_by_sunlight = true,
	sunlight_damage = 2,
	view_range = 16,
	attack_type = "dogfight",
	harmed_by_heal = true,
}

mobs:register_mob("mobs_mc:zombie", zombie)

-- Spawning

mobs:spawn_specific("mobs_mc:zombie", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 6000, 4, mcl_vars.mg_overworld_min, mcl_vars.mg_overworld_max)

-- Spawn eggs
mobs:register_egg("mobs_mc:zombie", S("Zombie"), "mobs_mc_spawn_icon_zombie.png", 0)
