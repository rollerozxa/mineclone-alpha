local S = minetest.get_translator("mcl_wool")

-- minetest/wool/init.lua


local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	-- name,       texture,               wool desc.,           color_group
	{"white",      "wool_white",          S("White Wool"),      "unicolor_white"},
	{"grey",       "wool_dark_grey",      S("Grey Wool"),       "unicolor_darkgrey"},
	{"silver",     "wool_grey",           S("Light Grey Wool"), "unicolor_grey"},
	{"black",      "wool_black",          S("Black Wool"),      "unicolor_black"},
	{"red",        "wool_red",            S("Red Wool"),        "unicolor_red"},
	{"yellow",     "wool_yellow",         S("Yellow Wool"),     "unicolor_yellow"},
	{"green",      "wool_dark_green",     S("Green Wool"),      "unicolor_dark_green"},
	{"cyan",       "wool_cyan",           S("Cyan Wool"),       "unicolor_cyan"},
	{"blue",       "wool_blue",           S("Blue Wool"),       "unicolor_blue"},
	{"magenta",    "wool_magenta",        S("Magenta Wool"),    "unicolor_red_violet"},
	{"orange",     "wool_orange",         S("Orange Wool"),     "unicolor_orange"},
	{"purple",     "wool_violet",         S("Purple Wool"),     "unicolor_violet"},
	{"brown",      "wool_brown",          S("Brown Wool"),      "unicolor_dark_orange"},
	{"pink",       "wool_pink",           S("Pink Wool"),       "unicolor_light_red"},
	{"lime",       "mcl_wool_lime",       S("Lime Wool"),       "unicolor_green"},
	{"light_blue", "mcl_wool_light_blue", S("Light Blue Wool"), "unicolor_light_blue"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local texture = row[2]
	local desc_wool = row[3]
	local color_group = row[4]

	-- Node Definition
	minetest.register_node("mcl_wool:"..name, {
		description = desc_wool,
					stack_max = 64,
		is_ground_content = false,
		tiles = {texture..".png"},
		groups = {handy=1,shearsy_wool=1, flammable=1,fire_encouragement=30, fire_flammability=60, wool=1,building_block=1,[color_group]=1},
		sounds = mcl_sounds.node_sound_wool_defaults(),
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 0.8,
	})
end

minetest.register_craft({
	output = "mcl_wool:white",
	recipe = {
		{ "mcl_mobitems:string", "mcl_mobitems:string" },
		{ "mcl_mobitems:string", "mcl_mobitems:string" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wool",
	burntime = 5,
})
