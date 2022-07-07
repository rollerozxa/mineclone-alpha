local S = minetest.get_translator("mcl_crafting_table")

minetest.register_node(":mcla:crafting_table", {
	description = S("Crafting Table"),
	is_ground_content = false,
	tiles = {"mcl_crafting_table_top.png", "mcl_core_wood.png", "mcl_crafting_table_side.png",
		"mcl_crafting_table_side.png", "mcl_crafting_table_front.png", "mcl_crafting_table_front.png"},
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, deco_block=1, material_wood=1,flammable=-1},
	on_rightclick = function(pos, node, player, itemstack)
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)

		local form = [[
			size[10,9.4,true]
			no_prepend[]
			real_coordinates[true]
			bgcolor[blue;true]
			listcolors[#ffffff00;#ffffff80]
			style_type[list;spacing=0.07,0.07;size=0.95,0.95]
			image[0,0;10,9.4;mcl_crafting_table_gui.png]
			list[current_player;craft;1.7,0.95;3,3;0]
			list[current_player;craftpreview;7.05,1.97;1,1;0]
			list[current_player;main;0.46,8;9,1;0]
			list[current_player;main;0.46,4.72;9,3;9]
			listring[current_player;main]
			listring[current_player;craft]
		]]

		minetest.show_formspec(player:get_player_name(), "main", form)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcla:crafting_table",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:crafting_table",
	burntime = 15,
})
