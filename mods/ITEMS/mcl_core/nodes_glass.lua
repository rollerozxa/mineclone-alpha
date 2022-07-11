-- Glass nodes
local S = minetest.get_translator("mcla_core")

minetest.register_node(":mcla:glass", {
	description = S("Glass"),
	drawtype = "glasslike",
	is_ground_content = false,
	tiles = {"mcl_core_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	stack_max = 64,
	groups = {handy=1, glass=1, building_block=1, material_glass=1},
	sounds = mcla_sounds.node_sound_glass_defaults(),
	drop = "",
	_mcla_blast_resistance = 0.3,
	_mcla_hardness = 0.3,
	_mcla_silk_touch_drop = true,
})
