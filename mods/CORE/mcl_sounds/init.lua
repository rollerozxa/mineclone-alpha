--
-- Sounds
--

mcla_sounds = {}

function mcla_sounds.node_sound(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="", gain=1.0}
	table.dug = table.dug or
			{name="default_dug_node", gain=0.25}
	table.dig = table.dig or
			{name="default_dig_oddly_breakable_by_hand", gain=1.0}
	table.place = table.place or
			{name="default_place_node_hard", gain=1.0}
	return table
end

function mcla_sounds.node_sound_stone()
	local table = {
		footstep = {name = "default_hard_footstep", gain = 0.5},
		dug = {name = "default_hard_footstep", gain = 1.0},
		dig = {name = "default_dig_cracky", gain = 1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_metal()
	local table = {
		footstep = {name="default_metal_footstep", gain=0.5},
		dug = {name="default_dug_metal", gain=1.0},
		dig = {name="default_dig_metal", gain=1.0},
		place = {name="default_place_node_metal", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_dirt()
	local table = {
		footstep = {name="default_dirt_footstep", gain=1.0},
		dug = {name="default_dirt_footstep", gain=1.5},
		dig = {name="default_dig_crumbly", gain=1.0},
		place = {name="default_place_node", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_grass()
	local table = {
		footstep = {name="default_grass_footstep", gain=0.1},
		dug = {name="default_dirt_footstep", gain=1.5},
		dig = {name="default_dig_crumbly", gain=1.0},
		place = {name="default_place_node", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_sand()
	local table = {
		footstep = {name="default_sand_footstep", gain=0.5},
		dug = {name="default_sand_footstep", gain=1.0},
		dig = {name="default_dig_crumbly", gain=1.0},
		place = {name="default_place_node", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_snow()
	local table = {
		footstep = {name="pedology_snow_soft_footstep", gain=0.5},
		dug = {name="pedology_snow_soft_footstep", gain=1.0},
		dig = {name="default_dig_crumbly", gain=1.0},
		place = {name="default_place_node", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_wood()
	local table = {
		footstep = {name="default_wood_footstep", gain=0.5},
		dug = {name="default_wood_footstep", gain=1.0},
		dig = {name="default_dig_choppy", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_wool()
	local table = {
		footstep = {name="mcl_sounds_cloth", gain=0.5},
		dug = {name="mcl_sounds_cloth", gain=1.0},
		dig = {name="mcl_sounds_cloth", gain=0.9},
		place = {name="mcl_sounds_cloth", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_leaves()
	local table = {
		footstep = {name="default_grass_footstep", gain=0.1325},
		dug = {name="default_grass_footstep", gain=0.425},
		dig = {name="default_dig_snappy", gain=0.4},
		place = {name="default_place_node", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_glass()
	local table = {
		footstep = {name="default_glass_footstep", gain=0.5},
		dug = {name="default_break_glass", gain=1.0},
		dig = {name="default_dig_cracky", gain=1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_water()
	local table = {
		footstep = {name = "default_water_footstep", gain = 0.2},
		place = {name = "mcl_sounds_place_node_water", gain = 1.0},
		dug = {name = "mcl_sounds_dug_water", gain = 1.0}
	}
	mcla_sounds.node_sound(table)
	return table
end

function mcla_sounds.node_sound_lava()
	local table = {
		place = {name = "default_place_node_lava", gain = 1.0},
		dug = {name = "default_place_node_lava", gain = 1.0}
	}
	-- TODO: Footstep
	-- TODO: Different dug sound
	mcla_sounds.node_sound(table)
	return table
end
