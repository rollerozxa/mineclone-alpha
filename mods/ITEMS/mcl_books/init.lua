local S = minetest.get_translator("mcl_books")

-- Book
minetest.register_craftitem("mcl_books:book", {
	description = S("Book"),
	inventory_image = "default_book.png",
	stack_max = 64,
	groups = { book=1, craftitem = 1, enchantability = 1 },
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_books:book',
	recipe = { 'mcl_core:paper', 'mcl_core:paper', 'mcl_core:paper', 'mcl_mobitems:leather', }
})

-- Bookshelf
minetest.register_node("mcl_books:bookshelf", {
	description = S("Bookshelf"),
	tiles = {"mcl_books_bookshelf_top.png", "mcl_books_bookshelf_top.png", "default_bookshelf.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy=1,axey=1, flammable=3,building_block=1, material_wood=1, fire_encouragement=30, fire_flammability=20},
	drop = "mcl_books:book 3",
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
})

minetest.register_craft({
	output = 'mcl_books:bookshelf',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'mcl_books:book', 'mcl_books:book', 'mcl_books:book'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_books:bookshelf",
	burntime = 15,
})

