--Fishing Rod, Bobber, and Flying Bobber mechanics and Bobber artwork by Rootyjr.

local S = minetest.get_translator("mcl_fishing")

-- Fishing Rod
minetest.register_tool("mcl_fishing:fishing_rod", {
	description = S("Fishing Rod"),
	groups = { tool=1, fishing_rod=1 },
	inventory_image = "mcl_fishing_fishing_rod.png",
	wield_image = "mcl_fishing_fishing_rod.png^[transformR270",
	wield_scale = { x = 1.5, y = 1.5, z = 1 },
	stack_max = 1,
	_mcl_uses = 65,
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'','','mcl_core:stick'},
		{'','mcl_core:stick','mcl_core:string'},
		{'mcl_core:stick','','mcl_core:string'},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'mcl_core:stick', '', ''},
		{'mcl_core:string', 'mcl_core:stick', ''},
		{'mcl_core:string','','mcl_core:stick'},
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:fishing_rod",
	burntime = 15,
})
