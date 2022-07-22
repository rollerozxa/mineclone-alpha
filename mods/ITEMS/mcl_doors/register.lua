local S = minetest.get_translator("mcla_doors")

--[[ Doors ]]

--- Oak Door ---
mcla_doors:register_door("mcla:wooden_door", {
	description = S("Door"),
	inventory_image = "mcla_doors_item_wood.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcla_hardness = 3,
	_mcla_blast_resistance = 3,
	tiles_bottom = {"mcla_doors_door_wood_lower.png", "mcla_doors_door_wood_side_lower.png"},
	tiles_top = {"mcla_doors_door_wood_upper.png", "mcla_doors_door_wood_side_upper.png"},
	sounds = mcla_sounds.node_sound_wood(),
})

minetest.register_craft({
	output = "mcla:wooden_door 3",
	recipe = {
		{"mcla:wood", "mcla:wood"},
		{"mcla:wood", "mcla:wood"},
		{"mcla:wood", "mcla:wood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wooden_door",
	burntime = 10,
})

--- Iron Door ---
mcla_doors:register_door("mcla:iron_door", {
	description = S("Iron Door"),
	inventory_image = "mcla_doors_item_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcla_hardness = 5,
	_mcla_blast_resistance = 5,
	tiles_bottom = {"mcla_doors_door_iron_lower.png^[transformFX", "mcla_doors_door_iron_side_lower.png"},
	tiles_top = {"mcla_doors_door_iron_upper.png^[transformFX", "mcla_doors_door_iron_side_upper.png"},
	sounds = mcla_sounds.node_sound_metal(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcla:iron_door 3",
	recipe = {
		{"mcla:iron_ingot", "mcla:iron_ingot"},
		{"mcla:iron_ingot", "mcla:iron_ingot"},
		{"mcla:iron_ingot", "mcla:iron_ingot"}
	}
})
