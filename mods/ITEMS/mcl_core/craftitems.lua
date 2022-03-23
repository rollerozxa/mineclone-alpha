-- mods/default/craftitems.lua

local S = minetest.get_translator("mcl_core")

--
-- Crafting items
--

minetest.register_craftitem("mcl_core:stick", {
	description = S("Stick"),
	inventory_image = "default_stick.png",
	stack_max = 64,
	groups = { craftitem=1, stick=1 },
	_mcl_toollike_wield = true,
})

minetest.register_craftitem("mcl_core:paper", {
	description = S("Paper"),
	inventory_image = "default_paper.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:coal_lump", {
	description = S("Coal"),
	groups = { coal=1 },
	inventory_image = "default_coal_lump.png",
	stack_max = 64,
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem("mcl_core:diamond", {
	description = S("Diamond"),
	inventory_image = "default_diamond.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:clay_lump", {
	description = S("Clay Ball"),
	inventory_image = "default_clay_lump.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:iron_ingot", {
	description = S("Iron Ingot"),
	inventory_image = "default_steel_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:gold_ingot", {
	description = S("Gold Ingot"),
	inventory_image = "default_gold_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:brick", {
	description = S("Brick"),
	inventory_image = "default_clay_brick.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:flint", {
	description = S("Flint"),
	inventory_image = "default_flint.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:sugar", {
	description = S("Sugar"),
	inventory_image = "mcl_core_sugar.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:bowl",{
	description = S("Bowl"),
	inventory_image = "mcl_core_bowl.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:apple", {
	description = S("Apple"),
	wield_image = "default_apple.png",
	inventory_image = "default_apple.png",
	stack_max = 64,
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2 }
})

local gapple_hunger_restore = minetest.item_eat(4)

local function eat_gapple(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end
	elseif pointed_thing.type == "object" then
		return itemstack
	end

	return gapple_hunger_restore(itemstack, placer, pointed_thing)
end

minetest.register_craftitem("mcl_core:apple_gold", {
	description = S("Golden Apple"),
	wield_image = "mcl_core_apple_golden.png",
	inventory_image = "mcl_core_apple_golden.png",
	stack_max = 64,
	on_place = eat_gapple,
	on_secondary_use = eat_gapple,
	groups = { food = 2, can_eat_when_full = 1 }
})

-- Book
minetest.register_craftitem("mcl_core:book", {
	description = S("Book"),
	inventory_image = "default_book.png",
	stack_max = 64,
	groups = { book=1, craftitem = 1 },
})
