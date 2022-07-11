local S = minetest.get_translator("mcla_wool")

-- minetest/wool/init.lua


local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	-- name,       texture,               wool desc.,           color_group
	{"white",      "wool_white",          S("White Wool"),      "unicolor_white"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local texture = row[2]
	local desc_wool = row[3]
	local color_group = row[4]

	-- Node Definition
	minetest.register_node(":mcla:"..name, {
		description = desc_wool,
					stack_max = 64,
		is_ground_content = false,
		tiles = {texture..".png"},
		groups = {handy=1,shearsy_wool=1, flammable=1,fire_encouragement=30, fire_flammability=60, wool=1,building_block=1,[color_group]=1},
		sounds = mcla_sounds.node_sound_wool_defaults(),
		_mcla_hardness = 0.8,
		_mcla_blast_resistance = 0.8,
	})
end

minetest.register_craft({
	output = "mcla:white",
	recipe = {
		{ "mcla:string", "mcla:string" },
		{ "mcla:string", "mcla:string" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wool",
	burntime = 5,
})
