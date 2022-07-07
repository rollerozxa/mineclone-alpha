local S = minetest.get_translator("mclx_core")

-- Liquids: River Water

local source = table.copy(minetest.registered_nodes["mcla:water_source"])
source.description = S("River Water Source")
source.liquid_range = 2
source.liquid_alternative_flowing = "mclx_core:river_water_flowing"
source.liquid_alternative_source = "mclx_core:river_water_source"
source.liquid_renewable = false
source.post_effect_color = {a=192, r=0x2c, g=0x88, b=0x8c}
source.tiles = {
	{name="mclx_core_river_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
}
source.special_tiles = {
	-- New-style water source material (mostly unused)
	{
		name="mclx_core_river_water_source_animated.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
		backface_culling = false,
	}
}

local flowing = table.copy(minetest.registered_nodes["mcla:water_flowing"])
flowing.description = S("Flowing River Water")
flowing.liquid_range = 2
flowing.liquid_alternative_flowing = "mclx_core:river_water_flowing"
flowing.liquid_alternative_source = "mclx_core:river_water_source"
flowing.liquid_renewable = false
flowing.tiles = {"mclx_core_river_water_flowing_animated.png^[verticalframe:64:0"}
flowing.post_effect_color = {a=192, r=0x2c, g=0x88, b=0x8c}
flowing.special_tiles = {
	{
		image="mclx_core_river_water_flowing_animated.png",
		backface_culling=false,
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
	},
	{
		image="mclx_core_river_water_flowing_animated.png",
		backface_culling=false,
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
	},
}

minetest.register_node("mclx_core:river_water_source", source)
minetest.register_node("mclx_core:river_water_flowing", flowing)
