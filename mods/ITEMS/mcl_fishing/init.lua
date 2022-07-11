--Fishing Rod, Bobber, and Flying Bobber mechanics and Bobber artwork by Rootyjr.

local S = minetest.get_translator("mcla_fishing")

-- Fishing Rod
minetest.register_tool(":mcla:fishing_rod", {
	description = S("Fishing Rod"),
	groups = { tool=1, fishing_rod=1 },
	inventory_image = "mcl_fishing_fishing_rod.png",
	wield_image = "mcl_fishing_fishing_rod.png^[transformR270",
	wield_scale = { x = 1.5, y = 1.5, z = 1 },
	stack_max = 1,
	_mcla_uses = 65,
	_mcla_toollike_wield = true,
})

minetest.register_craft({
	output = "mcla:fishing_rod",
	recipe = {
		{'','','mcla:stick'},
		{'','mcla:stick','mcla:string'},
		{'mcla:stick','','mcla:string'},
	}
})
minetest.register_craft({
	output = "mcla:fishing_rod",
	recipe = {
		{'mcla:stick', '', ''},
		{'mcla:string', 'mcla:stick', ''},
		{'mcla:string','','mcla:stick'},
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:fishing_rod",
	burntime = 15,
})
