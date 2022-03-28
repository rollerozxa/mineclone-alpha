-- Tree nodes: Wood, Wooden Planks, Sapling, Leaves
local S = minetest.get_translator("mcl_core")

local mod_screwdriver = minetest.get_modpath("screwdriver") ~= nil
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

-- Register tree trunk (wood) and bark
local function register_tree_trunk(subname, description_trunk, description_bark, tile_inner, tile_bark, stripped_variant)
	minetest.register_node("mcl_core:"..subname, {
		description = description_trunk,
		tiles = {tile_inner, tile_inner, tile_bark},
		stack_max = 64,
		groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = stripped_variant,
	})
end

local function register_wooden_planks(subname, description, tiles)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		tiles = tiles,
		stack_max = 64,
		is_ground_content = false,
		groups = {handy=1, axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})
end

local register_leaves = function(subname, description, tiles, sapling, drop_apples, sapling_chances, leafdecay_distance)
	local drop
	if leafdecay_distance == nil then
		leafdecay_distance = 4
	end
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}

	local function get_drops(fortune_level)
		local drop = {
			max_items = 1,
			items = {
				{
					items = {sapling},
					rarity = sapling_chances[fortune_level + 1] or sapling_chances[fortune_level]
				}
			}
		}
		if drop_apples then
			table.insert(drop.items, {
				items = {"mcl_core:apple"},
				rarity = apple_chances[fortune_level + 1]
			})
		end
		return drop
	end

	minetest.register_node("mcl_core:"..subname, {
		description = description,
		drawtype = "allfaces_optional",
		waving = 2,
		place_param2 = 1, -- Prevent leafdecay for placed nodes
		tiles = tiles,
		paramtype = "light",
		stack_max = 64,
		groups = {handy=1, shearsy=1, swordy=1, leafdecay=leafdecay_distance, flammable=2, leaves=1, deco_block=1,  fire_encouragement=30, fire_flammability=60},
		drop = get_drops(0),
		_mcl_shears_drop = true,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		_mcl_silk_touch_drop = true
	})
end

local function register_sapling(subname, description, texture, selbox)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		drawtype = "plantlike",
		waving = 1,
		visual_scale = 1.0,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = selbox
		},
		stack_max = 64,
		groups = {dig_immediate=3, plant=1, sapling=1, attached_node=1, dig_by_water=1,  destroy_by_lava_flow=1, deco_block=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("stage", 0)
		end,
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_below then return false end
			local nn = node_below.name
			return ((minetest.get_item_group(nn, "grass_block") == 1) or nn=="mcl_core:dirt")
		end),
		node_placement_prediction = "",
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
	})
end

---------------------

register_tree_trunk("tree", S("Wood"), S("Bark"), "mcl_core_tree_top.png", "mcl_core_tree.png", "mcl_core:stripped_oak")

register_wooden_planks("wood", S("Wood Planks"), {"mcl_core_wood.png"})


register_sapling("sapling", S("Sapling"), "mcl_core_sapling.png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})


register_leaves("leaves", S("Leaves"), {"mcl_core_leaves.png"}, "mcl_core:sapling", true, {20, 16, 12, 10})
