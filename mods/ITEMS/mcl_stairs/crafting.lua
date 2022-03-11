
-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_stairs",
	burntime = 15,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_slab",
	-- Original burn time: 7.5 (PC edition)
	burntime = 8,
})

