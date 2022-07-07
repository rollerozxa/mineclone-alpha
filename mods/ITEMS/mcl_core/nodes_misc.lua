-- Other nodes
local S = minetest.get_translator("mcl_core")

-- The void below the bedrock. Void damage is handled in mcl_playerplus.
-- The void does not exist as a block in Minecraft but we register it as a
-- block here to make things easier for us.
minetest.register_node(":mcla:void", {
	description = S("Void"),
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	walkable = false,
	floodable = false,
	buildable_to = false,
	inventory_image = "mcl_core_void.png",
	wield_image = "mcl_core_void.png",
	stack_max = 64,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = { not_in_creative_inventory = 1 },
	on_blast = function() end,
	-- Prevent placement to protect player from screwing up the world, because the node is not pointable and hard to get rid of.
	node_placement_prediction = "",
	on_place = function(pos, placer, itemstack, pointed_thing)
		minetest.chat_send_player(placer:get_player_name(), minetest.colorize("#FF0000", "You can't just place the void by hand!"))
		return
	end,
	drop = "",
	-- Infinite blast resistance; it should never be destroyed by explosions
	_mcl_blast_resistance = -1,
	_mcl_hardness = -1,
})
