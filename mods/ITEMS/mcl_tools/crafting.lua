minetest.register_craft({
	output = 'mcl_tools:wood_pickaxe',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:stone_pickaxe',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:cobble', 'mcl_core:cobble'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:iron_pickaxe',
	recipe = {
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:gold_pickaxe',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:diamond_pickaxe',
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:wood_shovel',
	recipe = {
		{'group:wood'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:stone_shovel',
	recipe = {
		{'mcl_core:cobble'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:iron_shovel',
	recipe = {
		{'mcl_core:iron_ingot'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:gold_shovel',
	recipe = {
		{'mcl_core:gold_ingot'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:diamond_shovel',
	recipe = {
		{'mcl_core:diamond'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:wood_axe',
	recipe = {
		{'group:wood', 'group:wood'},
		{'group:wood', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_tools:wood_axe',
	recipe = {
		{'group:wood', 'group:wood'},
		{'mcl_core:stick', 'group:wood'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:stone_axe',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:cobble'},
		{'mcl_core:cobble', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_tools:stone_axe',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:cobble'},
		{'mcl_core:stick', 'mcl_core:cobble'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:iron_axe',
	recipe = {
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_tools:iron_axe',
	recipe = {
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'mcl_core:stick', 'mcl_core:iron_ingot'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:gold_axe',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_tools:gold_axe',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:stick', 'mcl_core:gold_ingot'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:diamond_axe',
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:diamond', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_tools:diamond_axe',
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:stick', 'mcl_core:diamond'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_tools:wood_sword',
	recipe = {
		{'group:wood'},
		{'group:wood'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:stone_sword',
	recipe = {
		{'mcl_core:cobble'},
		{'mcl_core:cobble'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:iron_sword',
	recipe = {
		{'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:gold_sword',
	recipe = {
		{'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_tools:diamond_sword',
	recipe = {
		{'mcl_core:diamond'},
		{'mcl_core:diamond'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_pickaxe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_shovel",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_sword",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_axe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_pickaxe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_shovel",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_sword",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:wood_axe",
	burntime = 10,
})
