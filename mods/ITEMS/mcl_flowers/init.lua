local S = minetest.get_translator("mcla_flowers")

local mod_screwdriver = minetest.get_modpath("screwdriver") ~= nil

-- Simple flower template

local get_palette_color_from_pos = function(pos)
	local biome_data = minetest.get_biome_data(pos)
	local index = 0
	if biome_data then
		local biome = biome_data.biome
		local biome_name = minetest.get_biome_name(biome)
		local reg_biome = minetest.registered_biomes[biome_name]
		if reg_biome then
			index = reg_biome._mcla_palette_index
		end
	end
	return index
end

-- on_place function for flowers
local on_place_flower = mcla_util.generate_on_place_plant_function(function(pos, node, itemstack)
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local soil_node = minetest.get_node_or_nil(below)
	if not soil_node then return false end

	local has_palette = minetest.registered_nodes[itemstack:get_name()].palette ~= nil
	local colorize
	if has_palette then
		colorize = get_palette_color_from_pos(pos)
	end
	if not colorize then
		colorize = 0
	end

--[[	Placement requirements:
	* Dirt or grass block
	* If not flower, also allowed on podzol and coarse dirt
	* Light level >= 8 at any time or exposed to sunlight at day
]]
	local light_night = minetest.get_node_light(pos, 0.0)
	local light_day = minetest.get_node_light(pos, 0.5)
	local light_ok = false
	if (light_night and light_night >= 8) or (light_day and light_day >= minetest.LIGHT_MAX) then
		light_ok = true
	end
	local is_flower = minetest.get_item_group(itemstack:get_name(), "flower") == 1
	local ok = (soil_node.name == "mcla:dirt" or minetest.get_item_group(soil_node.name, "grass_block") == 1 or (not is_flower and (soil_node.name == "mcla:coarse_dirt" or soil_node.name == "mcla:podzol" or soil_node.name == "mcla:podzol_snow"))) and light_ok
	return ok, colorize
end)

local function add_simple_flower(name, desc, image, simple_selection_box)
	minetest.register_node(":mcla:"..name, {
		description = desc,
		drawtype = "plantlike",
		waving = 1,
		tiles = { image..".png" },
		inventory_image = image..".png",
		wield_image = image..".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		stack_max = 64,
		groups = {dig_immediate=3,flammable=2,fire_encouragement=60,fire_flammability=100,plant=1,flower=1,place_flowerlike=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,deco_block=1},
		sounds = mcla_sounds.node_sound_leaves_defaults(),
		node_placement_prediction = "",
		on_place = on_place_flower,
		selection_box = {
			type = "fixed",
			fixed = simple_selection_box,
		},
	})
end

add_simple_flower("red", S("Red flower"), "mcl_flowers_red", { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 })
add_simple_flower("yellow", S("Yellow flower"), "mcl_flowers_yellow", { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 })

local wheat_seed_drop = {
	max_items = 1,
	items = {
		{
			items = {'mcla:wheat_seeds'},
			rarity = 8,
		},
	}
}

minetest.register_abm({
	label = "Pop out flowers",
	nodenames = {"group:flower"},
	interval = 12,
	chance = 2,
	action = function(pos, node)
		local below = minetest.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})
		if not below then
			return
		end
		-- Pop out flower if not on dirt, grass block or too low brightness
		if (below.name ~= "mcla:dirt" and minetest.get_item_group(below.name, "grass_block") ~= 1) or (minetest.get_node_light(pos, 0.5) < 8) then
			minetest.dig_node(pos)
			return
		end
	end,
})

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_simple
end

