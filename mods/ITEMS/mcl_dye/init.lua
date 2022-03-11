
local S = minetest.get_translator("mcl_dye")

minetest.register_craftitem("mcl_dye:white", {
	inventory_image = "mcl_dye_white.png",
	description = S("Bone Meal"),
	stack_max = 64,
	groups = {dye=1, craftitem=1, basecolor_white=1,   excolor_white=1,     unicolor_white=1},
})

minetest.register_craft({
	output = "mcl_dye:white 3",
	recipe = {{"mcl_mobitems:bone"}},
})
