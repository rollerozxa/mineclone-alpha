local S = minetest.get_translator("mcla_core")

-- Simple solid cubic nodes, most of them are the ground materials and simple building blocks

minetest.register_node(":mcla:stone", {
	description = S("Stone"),
	tiles = {"mcla_core_stone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	drop = 'mcla:cobble',
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 1.5,
	_mcla_silk_touch_drop = true,
})

minetest.register_node(":mcla:stone_with_coal", {
	description = S("Coal Ore"),
	tiles = {"mcla_core_coal_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=1},
	drop = 'mcla:coal_lump',
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 3,
	_mcla_hardness = 3,
	_mcla_silk_touch_drop = true,
})

minetest.register_node(":mcla:stone_with_iron", {
	description = S("Iron Ore"),
	tiles = {"mcla_core_iron_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1, material_stone=1},
	drop = 'mcla:stone_with_iron',
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 3,
	_mcla_hardness = 3,
	_mcla_silk_touch_drop = true,
})


minetest.register_node(":mcla:stone_with_gold", {
	description = S("Gold Ore"),
	tiles = {"mcla_core_gold_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1},
	drop = "mcla:stone_with_gold",
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 3,
	_mcla_hardness = 3,
	_mcla_silk_touch_drop = true,
})

local redstone_timer = 68.28
local redstone_ore_activate = function(pos)
	minetest.swap_node(pos, {name="mcla:stone_with_redstone_lit"})
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
minetest.register_node(":mcla:stone_with_redstone", {
	description = S("Redstone Ore"),
	tiles = {"mcla_core_redstone_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=7},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	on_punch = redstone_ore_activate,
	on_walk_over = redstone_ore_activate, -- Uses walkover mod
	_mcla_blast_resistance = 3,
	_mcla_hardness = 3,
	_mcla_silk_touch_drop = true,
})

local redstone_ore_reactivate = function(pos)
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
-- Light the redstone ore up when it has been touched
minetest.register_node(":mcla:stone_with_redstone_lit", {
	description = S("Lit Redstone Ore"),
	tiles = {"mcla_core_redstone_ore.png"},
	paramtype = "light",
	light_source = 9,
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, not_in_creative_inventory=1, material_stone=1, xp=7},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	-- Reset timer after re-punching or stepping on
	on_punch = redstone_ore_reactivate,
	on_walk_over = redstone_ore_reactivate, -- Uses walkover mod
	-- Turn back to normal node after some time has passed
	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, {name="mcla:stone_with_redstone"})
	end,
	_mcla_blast_resistance = 3,
	_mcla_hardness = 3,
	_mcla_silk_touch_drop = {"mcla:stone_with_redstone"},
})

minetest.register_node(":mcla:stone_with_diamond", {
	description = S("Diamond Ore"),
	tiles = {"mcla_core_diamond_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=4},
	drop = "mcla:diamond",
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 3,
	_mcla_hardness = 3,
	_mcla_silk_touch_drop = true,
})

-- Grass Block
minetest.register_node(":mcla:dirt_with_grass", {
	description = S("Grass Block"),
	tiles = {"mcla_core_grass_block_top.png", { name="mcla_core_dirt.png", color="white" }},
	overlay_tiles = {"mcla_core_grass_block_top.png", "", {name="mcla_core_grass_block_side_overlay.png", tileable_vertical=false}},
	--color = "#91f56b",
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1,dirt=2,grass_block=1, grass_block_no_snow=1, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, spreading_dirt_type=1, building_block=1},
	drop = 'mcla:dirt',
	sounds = mcla_sounds.node_sound_dirt_defaults({
		footstep = {name="mcl_core_grass_footstep", gain=0.1},
	}),
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		if node.param2 == 0 then
			local new_node = mcla_core.get_grass_block_type(pos)
			if new_node.param2 ~= 0 or new_node.name ~= "mcla:dirt_with_grass" then
				minetest.set_node(pos, new_node)
			end
		end
		return mcla_core.on_snowable_construct(pos)
	end,
	_mcla_snowed = "mcla:dirt_with_grass_snow",
	_mcla_blast_resistance = 0.5,
	_mcla_hardness = 0.6,
	_mcla_silk_touch_drop = true,
})
mcla_core.register_snowed_node(":mcla:dirt_with_grass_snow", "mcla:dirt_with_grass", nil, nil, true, S("Dirt with Snow"))

minetest.register_node(":mcla:dirt", {
	description = S("Dirt"),
	tiles = {"mcla_core_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, dirt=1,soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, building_block=1},
	sounds = mcla_sounds.node_sound_dirt_defaults(),
	_mcla_blast_resistance = 0.5,
	_mcla_hardness = 0.5,
})

minetest.register_node(":mcla:gravel", {
	description = S("Gravel"),
	tiles = {"mcla_core_gravel.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, building_block=1, material_sand=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcla:flint'},rarity = 10},
			{items = {'mcla:gravel'}}
		}
	},
	sounds = mcla_sounds.node_sound_dirt_defaults({
		footstep = {name="mcl_core_gravel_footstep", gain=0.45},
	}),
	_mcla_blast_resistance = 0.6,
	_mcla_hardness = 0.6,
	_mcla_silk_touch_drop = true,
})

minetest.register_node(":mcla:sand", {
	description = S("Sand"),
	tiles = {"mcla_core_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, sand=1, soil_sugarcane=1, building_block=1, material_sand=1},
	sounds = mcla_sounds.node_sound_sand_defaults(),
	_mcla_blast_resistance = 0.5,
	_mcla_hardness = 0.5,
})

---

minetest.register_node(":mcla:clay", {
	description = S("Clay"),
	tiles = {"mcla_core_clay.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, building_block=1},
	drop = 'mcla:clay_lump 4',
	sounds = mcla_sounds.node_sound_dirt_defaults(),
	_mcla_blast_resistance = 0.6,
	_mcla_hardness = 0.6,
	_mcla_silk_touch_drop = true,
})

minetest.register_node(":mcla:brick_block", {
	-- Original name: “Bricks”
	description = S("Brick Block"),
	tiles = {"mcla_core_brick.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 2,
})


minetest.register_node(":mcla:bedrock", {
	description = S("Bedrock"),
	tiles = {"mcla_core_bedrock.png"},
	stack_max = 64,
	groups = {creative_breakable=1, building_block=1, material_stone=1},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	on_blast = function() end,
	drop = '',
	_mcla_blast_resistance = 3600000,
	_mcla_hardness = -1,
})

minetest.register_node(":mcla:cobble", {
	description = S("Cobblestone"),
	tiles = {"mcla_core_cobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 2,
})

minetest.register_node(":mcla:mossycobble", {
	description = S("Mossy Cobblestone"),
	tiles = {"mcla_core_mossycobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 2,
})

minetest.register_node(":mcla:ironblock", {
	description = S("Block of Iron"),
	tiles = {"mcla_core_steel_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=2, building_block=1},
	sounds = mcla_sounds.node_sound_metal_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 5,
})

minetest.register_node(":mcla:goldblock", {
	description = S("Block of Gold"),
	tiles = {"mcla_core_gold_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcla_sounds.node_sound_metal_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 5,
})

minetest.register_node(":mcla:diamondblock", {
	description = S("Block of Diamond"),
	tiles = {"mcla_core_diamond_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcla_sounds.node_sound_stone_defaults(),
	_mcla_blast_resistance = 6,
	_mcla_hardness = 5,
})

minetest.register_node(":mcla:obsidian", {
	description = S("Obsidian"),
	tiles = {"mcla_core_obsidian.png"},
	is_ground_content = true,
	sounds = mcla_sounds.node_sound_stone_defaults(),
	stack_max = 64,
	groups = {pickaxey=5, building_block=1, material_stone=1},
	_mcla_blast_resistance = 1200,
	_mcla_hardness = 50,
})

minetest.register_node(":mcla:ice", {
	description = S("Ice"),
	tiles = {"mcla_core_ice.png"},
	is_ground_content = true,
	paramtype = "light",
	stack_max = 64,
	groups = {handy=1,pickaxey=1, slippery=3, building_block=1, ice=1},
	drop = "",
	sounds = mcla_sounds.node_sound_glass_defaults(),
	node_dig_prediction = "mcla:water_source",
	after_dig_node = function(pos, oldnode)
		mcla_core.melt_ice(pos)
	end,
	_mcla_blast_resistance = 0.5,
	_mcla_hardness = 0.5,
	_mcla_silk_touch_drop = true,
})

for i=1,8 do
	local id, desc, walkable, drawtype, node_box
	if i == 1 then
		id = ":mcla:snow"
		desc = S("Top Snow")
		walkable = false
	else
		id = ":mcla:snow_"..i
		walkable = true
	end
	if i ~= 8 then
		drawtype = "nodebox"
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, -0.5 + (2*i)/16, 0.5 },
		}
	end
	local on_place = function(itemstack, placer, pointed_thing)
		-- Placement is only allowed on top of solid blocks
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end
		local def = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		local above = pointed_thing.above
		local under = pointed_thing.under
		local unode = minetest.get_node(under)

		-- Check special rightclick action of pointed node
		if def and def.on_rightclick then
			if not placer:get_player_control().sneak then
				return def.on_rightclick(under, unode, placer, itemstack,
					pointed_thing) or itemstack, false
			end
		end

		-- Get position where snow would be placed
		local target
		if minetest.registered_nodes[unode.name].buildable_to then
			target = under
		else
			target = above
		end
		local tnode = minetest.get_node(target)

		-- Stack snow
		local g = minetest.get_item_group(tnode.name, "top_snow")
		if g > 0 then
			local itemstring = itemstack:get_name()
			local itemcount = itemstack:get_count()
			local fakestack = ItemStack(itemstring.." "..itemcount)
			fakestack:set_name("mcla:snow_"..math.min(8, (i+g)))
			local success
			itemstack, success = minetest.item_place(fakestack, placer, pointed_thing)
			minetest.sound_play(mcla_sounds.node_sound_snow_defaults().place, {pos = below}, true)
			itemstack:set_name(itemstring)
			return itemstack
		end

		-- Place snow normally
		local below = {x=target.x, y=target.y-1, z=target.z}
		local bnode = minetest.get_node(below)

		if minetest.get_item_group(bnode.name, "solid") == 1 then
			minetest.sound_play(mcla_sounds.node_sound_snow_defaults().place, {pos = below}, true)
			return minetest.item_place_node(itemstack, placer, pointed_thing)
		else
			return itemstack
		end
	end

	minetest.register_node(id, {
		description = desc,
		tiles = {"mcla_core_snow.png"},
		wield_image = "mcla_core_snow.png",
		wield_scale = { x=1, y=1, z=i },
		is_ground_content = true,
		paramtype = "light",
		sunlight_propagates = true,
		buildable_to = true,
		node_placement_prediction = "", -- to prevent client flickering when stacking snow
		drawtype = drawtype,
		stack_max = 64,
		walkable = walkable,
		floodable = true,
		on_flood = function(pos, oldnode, newnode)
			local npos = {x=pos.x, y=pos.y-1, z=pos.z}
			local node = minetest.get_node(npos)
			mcla_core.clear_snow_dirt(npos, node)
		end,
		node_box = node_box,
		groups = {shovely=1, attached_node=1,deco_block=1,  snow_cover=1, top_snow=i},
		sounds = mcla_sounds.node_sound_snow_defaults(),
		on_construct = mcla_core.on_snow_construct,
		on_place = on_place,
		after_destruct = mcla_core.after_snow_destruct,
		drop = "mcla:snowball "..(i+1),
		_mcla_blast_resistance = 0.1,
		_mcla_hardness = 0.1,
		_mcla_silk_touch_drop = {"mcla:snow " .. i},
	})
end

minetest.register_node(":mcla:snowblock", {
	description = S("Snow"),
	tiles = {"mcla_core_snow.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {shovely=1, building_block=1, snow_cover=1},
	sounds = mcla_sounds.node_sound_snow_defaults(),
	on_construct = mcla_core.on_snow_construct,
	after_destruct = mcla_core.after_snow_destruct,
	drop = "mcla:snowball 4",
	_mcla_blast_resistance = 0.2,
	_mcla_hardness = 0.2,
	_mcla_silk_touch_drop = true,
})

minetest.register_node(":mcla:sponge", {
	description = S("Sponge"),
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcla_sponges_sponge.png"},
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	stack_max = 64,
	sounds = mcla_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, building_block=1},
	_mcla_blast_resistance = 0.6,
	_mcla_hardness = 0.6,
})

-- Bookshelf
minetest.register_node(":mcla:bookshelf", {
	description = S("Bookshelf"),
	tiles = {"mcla_core_wood.png", "mcla_core_wood.png", "mcla_core_bookshelf.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy=1,axey=1, flammable=3,building_block=1, material_wood=1, fire_encouragement=30, fire_flammability=20},
	drop = "mcla:book 3",
	sounds = mcla_sounds.node_sound_wood_defaults(),
	_mcla_blast_resistance = 1.5,
	_mcla_hardness = 1.5,
	_mcla_silk_touch_drop = true,
})
