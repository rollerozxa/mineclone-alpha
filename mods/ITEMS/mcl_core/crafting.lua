-- mods/default/crafting.lua

--
-- Crafting definition
--

local function craft_planks(output, input)
	minetest.register_craft({
		output = "mcl_core:"..output.."wood 4",
		recipe = {
			{"mcl_core:"..input},
		}
	})
end

local planks = {
	{"", "oak"}
}

for _, p in pairs(planks) do
	craft_planks(p[1], p[1].."tree")
	craft_planks(p[1], p[1].."tree_bark")
	craft_planks(p[1], "stripped_"..p[2])
	craft_planks(p[1], "stripped_"..p[2].."_bark")
end

minetest.register_craft({
	output = 'mcl_core:stick 4',
	recipe = {
		{'group:wood'},
		{'group:wood'},
	}
})



minetest.register_craft({
	output = 'mcl_core:coalblock',
	recipe = {
		{'mcl_core:coal_lump', 'mcl_core:coal_lump', 'mcl_core:coal_lump'},
		{'mcl_core:coal_lump', 'mcl_core:coal_lump', 'mcl_core:coal_lump'},
		{'mcl_core:coal_lump', 'mcl_core:coal_lump', 'mcl_core:coal_lump'},
	}
})

minetest.register_craft({
	output = 'mcl_core:coal_lump 9',
	recipe = {
		{'mcl_core:coalblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:ironblock',
	recipe = {
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
	}
})

minetest.register_craft({
	output = 'mcl_core:iron_ingot 9',
	recipe = {
		{'mcl_core:ironblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:goldblock',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'mcl_core:gold_ingot 9',
	recipe = {
		{'mcl_core:goldblock'},
	}
})


minetest.register_craft({
	output = 'mcl_core:clay',
	recipe = {
		{'mcl_core:clay_lump', 'mcl_core:clay_lump'},
		{'mcl_core:clay_lump', 'mcl_core:clay_lump'},
	}
})

minetest.register_craft({
	output = 'mcl_core:brick_block',
	recipe = {
		{'mcl_core:brick', 'mcl_core:brick'},
		{'mcl_core:brick', 'mcl_core:brick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:paper 3',
	recipe = {
		{'mcl_core:reeds', 'mcl_core:reeds', 'mcl_core:reeds'},
	}
})

minetest.register_craft({
	output = 'mcl_core:ladder 3',
	recipe = {
		{'mcl_core:stick', '', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
		{'mcl_core:stick', '', 'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:stonebrick 4',
	recipe = {
		{'mcl_core:stone', 'mcl_core:stone'},
		{'mcl_core:stone', 'mcl_core:stone'},
	}
})

minetest.register_craft({
	output = "mcl_core:diamondblock",
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
	}
})

minetest.register_craft({
	output = 'mcl_core:diamond 9',
	recipe = {
		{'mcl_core:diamondblock'},
	}
})

minetest.register_craft({
	output = "mcl_core:apple_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", 'mcl_core:apple', "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "mcl_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = 'mcl_core:snowblock',
	recipe = {
		{'mcl_throwing:snowball', 'mcl_throwing:snowball'},
		{'mcl_throwing:snowball', 'mcl_throwing:snowball'},
	}
})

minetest.register_craft({
	output = 'mcl_core:snow 6',
	recipe = {
		{'mcl_core:snowblock', 'mcl_core:snowblock', 'mcl_core:snowblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:bookshelf',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'mcl_core:book', 'mcl_core:book', 'mcl_core:book'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_core:book',
	recipe = { 'mcl_core:paper', 'mcl_core:paper', 'mcl_core:paper', 'mcl_core:leather', }
})

--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -mcl_core.repair,
})

--
-- Cooking recipes
--

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:glass",
	recipe = "group:sand",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:stone",
	recipe = "mcl_core:cobble",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_ingot",
	recipe = "mcl_core:stone_with_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_ingot",
	recipe = "mcl_core:stone_with_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:brick",
	recipe = "mcl_core:clay_lump",
	cooktime = 10,
})


minetest.register_craft({
	type = "cooking",
	output = "mcl_core:coal_lump",
	recipe = "mcl_core:stone_with_coal",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:diamond",
	recipe = "mcl_core:stone_with_diamond",
	cooktime = 10,
})

--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:coalblock",
	burntime = 800,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:coal_lump",
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
	recipe = "mcl_core:ladder",
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
	recipe = "mcl_books:bookshelf",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:stick",
	burntime = 5,
})
