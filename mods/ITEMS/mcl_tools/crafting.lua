minetest.register_craft({
	output = 'mcla:wood_pickaxe',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'mcla:stick', ''},
		{'', 'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:stone_pickaxe',
	recipe = {
		{'mcla:cobble', 'mcla:cobble', 'mcla:cobble'},
		{'', 'mcla:stick', ''},
		{'', 'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:iron_pickaxe',
	recipe = {
		{'mcla:iron_ingot', 'mcla:iron_ingot', 'mcla:iron_ingot'},
		{'', 'mcla:stick', ''},
		{'', 'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:gold_pickaxe',
	recipe = {
		{'mcla:gold_ingot', 'mcla:gold_ingot', 'mcla:gold_ingot'},
		{'', 'mcla:stick', ''},
		{'', 'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:diamond_pickaxe',
	recipe = {
		{'mcla:diamond', 'mcla:diamond', 'mcla:diamond'},
		{'', 'mcla:stick', ''},
		{'', 'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:wood_shovel',
	recipe = {
		{'group:wood'},
		{'mcla:stick'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:stone_shovel',
	recipe = {
		{'mcla:cobble'},
		{'mcla:stick'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:iron_shovel',
	recipe = {
		{'mcla:iron_ingot'},
		{'mcla:stick'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:gold_shovel',
	recipe = {
		{'mcla:gold_ingot'},
		{'mcla:stick'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:diamond_shovel',
	recipe = {
		{'mcla:diamond'},
		{'mcla:stick'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:wood_axe',
	recipe = {
		{'group:wood', 'group:wood'},
		{'group:wood', 'mcla:stick'},
		{'', 'mcla:stick'},
	}
})
minetest.register_craft({
	output = 'mcla:wood_axe',
	recipe = {
		{'group:wood', 'group:wood'},
		{'mcla:stick', 'group:wood'},
		{'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:stone_axe',
	recipe = {
		{'mcla:cobble', 'mcla:cobble'},
		{'mcla:cobble', 'mcla:stick'},
		{'', 'mcla:stick'},
	}
})
minetest.register_craft({
	output = 'mcla:stone_axe',
	recipe = {
		{'mcla:cobble', 'mcla:cobble'},
		{'mcla:stick', 'mcla:cobble'},
		{'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:iron_axe',
	recipe = {
		{'mcla:iron_ingot', 'mcla:iron_ingot'},
		{'mcla:iron_ingot', 'mcla:stick'},
		{'', 'mcla:stick'},
	}
})
minetest.register_craft({
	output = 'mcla:iron_axe',
	recipe = {
		{'mcla:iron_ingot', 'mcla:iron_ingot'},
		{'mcla:stick', 'mcla:iron_ingot'},
		{'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:gold_axe',
	recipe = {
		{'mcla:gold_ingot', 'mcla:gold_ingot'},
		{'mcla:gold_ingot', 'mcla:stick'},
		{'', 'mcla:stick'},
	}
})
minetest.register_craft({
	output = 'mcla:gold_axe',
	recipe = {
		{'mcla:gold_ingot', 'mcla:gold_ingot'},
		{'mcla:stick', 'mcla:gold_ingot'},
		{'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:diamond_axe',
	recipe = {
		{'mcla:diamond', 'mcla:diamond'},
		{'mcla:diamond', 'mcla:stick'},
		{'', 'mcla:stick'},
	}
})
minetest.register_craft({
	output = 'mcla:diamond_axe',
	recipe = {
		{'mcla:diamond', 'mcla:diamond'},
		{'mcla:stick', 'mcla:diamond'},
		{'mcla:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcla:wood_sword',
	recipe = {
		{'group:wood'},
		{'group:wood'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:stone_sword',
	recipe = {
		{'mcla:cobble'},
		{'mcla:cobble'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:iron_sword',
	recipe = {
		{'mcla:iron_ingot'},
		{'mcla:iron_ingot'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:gold_sword',
	recipe = {
		{'mcla:gold_ingot'},
		{'mcla:gold_ingot'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:diamond_sword',
	recipe = {
		{'mcla:diamond'},
		{'mcla:diamond'},
		{'mcla:stick'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_pickaxe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_shovel",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_sword",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_axe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_pickaxe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_shovel",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_sword",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_axe",
	burntime = 10,
})
