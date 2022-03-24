-- Register all Minecraft stairs and slabs
-- Note about hardness: For some reason, the hardness of slabs and stairs don't always match nicely, so that some
-- slabs actually take slightly longer to be dug than their stair counterparts.
-- Note sure if it is a good idea to preserve this oddity.

local S = minetest.get_translator("mcl_stairs")

local woods = {
	{ "wood", "mcl_core_wood.png", S("Wood Stairs"), S("Wood Slab"), S("Double Wood Slab") }
}

for w=1, #woods do
	local wood = woods[w]
	mcl_stairs.register_stair(wood[1], "mcl_core:"..wood[1],
			{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
			{wood[2]},
			wood[3],
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			"woodlike")
	mcl_stairs.register_slab(wood[1], "mcl_core:"..wood[1],
			{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
			{wood[2]},
			wood[4],
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			wood[5])
end

mcl_stairs.register_slab("stone", "mcl_core:stone_smooth",
		{pickaxey=1, material_stone=1},
		{"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
		S("Polished Stone Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Polished Stone Slab"))

mcl_stairs.register_stair_and_slab_simple("cobble", "mcl_core:cobble", S("Cobblestone Stairs"), S("Cobblestone Slab"), S("Double Cobblestone Slab"))
