-- Basic crafting recipes.

minetest.register_craft({
	output = 'mcla:wood 4',
	recipe = {
		{'mcla:tree'}
	}
})

minetest.register_craft({
	output = 'mcla:stick 4',
	recipe = {
		{'group:wood'},
		{'group:wood'},
	}
})

minetest.register_craft({
	output = 'mcla:coalblock',
	recipe = {
		{'mcla:coal_lump', 'mcla:coal_lump', 'mcla:coal_lump'},
		{'mcla:coal_lump', 'mcla:coal_lump', 'mcla:coal_lump'},
		{'mcla:coal_lump', 'mcla:coal_lump', 'mcla:coal_lump'},
	}
})

minetest.register_craft({
	output = 'mcla:coal_lump 9',
	recipe = {
		{'mcla:coalblock'},
	}
})

minetest.register_craft({
	output = 'mcla:ironblock',
	recipe = {
		{'mcla:iron_ingot', 'mcla:iron_ingot', 'mcla:iron_ingot'},
		{'mcla:iron_ingot', 'mcla:iron_ingot', 'mcla:iron_ingot'},
		{'mcla:iron_ingot', 'mcla:iron_ingot', 'mcla:iron_ingot'},
	}
})

minetest.register_craft({
	output = 'mcla:iron_ingot 9',
	recipe = {
		{'mcla:ironblock'},
	}
})

minetest.register_craft({
	output = 'mcla:goldblock',
	recipe = {
		{'mcla:gold_ingot', 'mcla:gold_ingot', 'mcla:gold_ingot'},
		{'mcla:gold_ingot', 'mcla:gold_ingot', 'mcla:gold_ingot'},
		{'mcla:gold_ingot', 'mcla:gold_ingot', 'mcla:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'mcla:gold_ingot 9',
	recipe = {
		{'mcla:goldblock'},
	}
})


minetest.register_craft({
	output = 'mcla:clay',
	recipe = {
		{'mcla:clay_lump', 'mcla:clay_lump'},
		{'mcla:clay_lump', 'mcla:clay_lump'},
	}
})

minetest.register_craft({
	output = 'mcla:brick_block',
	recipe = {
		{'mcla:brick', 'mcla:brick'},
		{'mcla:brick', 'mcla:brick'},
	}
})

minetest.register_craft({
	output = 'mcla:paper 3',
	recipe = {
		{'mcla:reeds', 'mcla:reeds', 'mcla:reeds'},
	}
})

minetest.register_craft({
	output = 'mcla:ladder 3',
	recipe = {
		{'mcla:stick', '', 'mcla:stick'},
		{'mcla:stick', 'mcla:stick', 'mcla:stick'},
		{'mcla:stick', '', 'mcla:stick'},
	}
})

minetest.register_craft({
	output = 'mcla:stonebrick 4',
	recipe = {
		{'mcla:stone', 'mcla:stone'},
		{'mcla:stone', 'mcla:stone'},
	}
})

minetest.register_craft({
	output = "mcla:diamondblock",
	recipe = {
		{'mcla:diamond', 'mcla:diamond', 'mcla:diamond'},
		{'mcla:diamond', 'mcla:diamond', 'mcla:diamond'},
		{'mcla:diamond', 'mcla:diamond', 'mcla:diamond'},
	}
})

minetest.register_craft({
	output = 'mcla:diamond 9',
	recipe = {
		{'mcla:diamondblock'},
	}
})

minetest.register_craft({
	output = "mcla:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = 'mcla:snowblock',
	recipe = {
		{'mcla:snowball', 'mcla:snowball'},
		{'mcla:snowball', 'mcla:snowball'},
	}
})

minetest.register_craft({
	output = 'mcla:snow 6',
	recipe = {
		{'mcla:snowblock', 'mcla:snowblock', 'mcla:snowblock'},
	}
})

minetest.register_craft({
	output = 'mcla:bookshelf',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'mcla:book', 'mcla:book', 'mcla:book'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcla:book',
	recipe = { 'mcla:paper', 'mcla:paper', 'mcla:paper', 'mcla:leather', }
})

--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -mcla_core.repair,
})

--
-- Cooking recipes
--

minetest.register_craft({
	type = "cooking",
	output = "mcla:glass",
	recipe = "group:sand",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcla:stone",
	recipe = "mcla:cobble",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcla:iron_ingot",
	recipe = "mcla:stone_with_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcla:gold_ingot",
	recipe = "mcla:stone_with_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcla:brick",
	recipe = "mcla:clay_lump",
	cooktime = 10,
})


minetest.register_craft({
	type = "cooking",
	output = "mcla:coal_lump",
	recipe = "mcla:stone_with_coal",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcla:diamond",
	recipe = "mcla:stone_with_diamond",
	cooktime = 10,
})

--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:coalblock",
	burntime = 800,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:coal_lump",
	burntime = 80,
})


minetest.register_craft({
	type = "fuel",
	recipe = "group:tree",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wood",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:bookshelf",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:stick",
	burntime = 5,
})
