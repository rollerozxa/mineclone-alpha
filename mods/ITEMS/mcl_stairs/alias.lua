-- Aliases for backwards-compability with 0.21.0

local materials = {
	"wood","cobble"
}

for m=1, #materials do
	local mat = materials[m]
	minetest.register_alias("stairs:slab_"..mat, "mcla:slab_"..mat)
	minetest.register_alias("stairs:stair_"..mat, "mcla:stair_"..mat)

	-- corner stairs
	minetest.register_alias("stairs:stair_"..mat.."_inner", "mcla:stair_"..mat.."_inner")
	minetest.register_alias("stairs:stair_"..mat.."_outer", "mcla:stair_"..mat.."_outer")
end

minetest.register_alias("stairs:slab_stone", "mcla:slab_stone")
minetest.register_alias("stairs:slab_stone_double", "mcla:slab_stone_double")
