local has_mcl_skins = minetest.get_modpath("mcl_skins") ~= nil

local def = minetest.registered_items[""]

-- This is a fake node that should never be placed in the world
minetest.register_node("mcl_meshhand:hand", {
	description = "",
	tiles = {"character.png"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	visual_scale = 1,
	wield_scale = {x=1,y=1,z=1},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "mcl_meshhand.b3d",
	-- Prevent construction
	node_placement_prediction = "",
	on_construct = function(pos)
		minetest.log("error", "[mcl_meshhand] Trying to construct mcl_meshhand:hand at "..minetest.pos_to_string(pos))
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function()
		return ""
	end,
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	range = def.range,
	})

minetest.register_on_joinplayer(function(player)
	player:get_inventory():set_stack("hand", 1, "mcl_meshhand:hand")
end)
