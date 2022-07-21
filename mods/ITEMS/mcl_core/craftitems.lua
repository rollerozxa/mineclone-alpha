-- mods/default/craftitems.lua

local S = minetest.get_translator("mcla_core")

--
-- Crafting items
--

minetest.register_craftitem(":mcla:stick", {
	description = S("Stick"),
	inventory_image = "mcla_core_stick.png",
	stack_max = 64,
	groups = { craftitem=1, stick=1 },
	_mcla_toollike_wield = true,
})

minetest.register_craftitem(":mcla:paper", {
	description = S("Paper"),
	inventory_image = "mcla_core_paper.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:coal_lump", {
	description = S("Coal"),
	inventory_image = "mcla_core_coal_lump.png",
	stack_max = 64,
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem(":mcla:diamond", {
	description = S("Diamond"),
	inventory_image = "mcla_core_diamond.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:clay_lump", {
	description = S("Clay Ball"),
	inventory_image = "mcla_core_clay_lump.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:iron_ingot", {
	description = S("Iron Ingot"),
	inventory_image = "mcla_core_steel_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:gold_ingot", {
	description = S("Gold Ingot"),
	inventory_image = "mcla_core_gold_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:brick", {
	description = S("Brick"),
	inventory_image = "mcla_core_clay_brick.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:flint", {
	description = S("Flint"),
	inventory_image = "mcla_core_flint.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem(":mcla:bowl",{
	description = S("Bowl"),
	inventory_image = "mcla_core_bowl.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem(":mcla:apple", {
	description = S("Apple"),
	wield_image = "mcla_core_apple.png",
	inventory_image = "mcla_core_apple.png",
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

minetest.register_craftitem(":mcla:apple_gold", {
	description = S("Golden Apple"),
	wield_image = "mcla_core_apple_golden.png",
	inventory_image = "mcla_core_apple_golden.png",
	stack_max = 64,
	on_place = eat_gapple,
	on_secondary_use = eat_gapple,
	groups = { food = 2, can_eat_when_full = 1 }
})

-- Book
minetest.register_craftitem(":mcla:book", {
	description = S("Book"),
	inventory_image = "mcla_core_book.png",
	stack_max = 64,
	groups = { book=1, craftitem = 1 },
})

-- from mcla_mobiterms

minetest.register_craftitem(":mcla:porkchop", {
	description = S("Raw Porkchop"),
	inventory_image = "mcla_core_porkchop_raw.png",
	wield_image = "mcla_core_porkchop_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2 },
	stack_max = 64,
})

minetest.register_craftitem(":mcla:cooked_porkchop", {
	description = S("Cooked Porkchop"),
	inventory_image = "mcla_core_porkchop_cooked.png",
	wield_image = "mcla_core_porkchop_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2 },
	stack_max = 64,
})

minetest.register_craftitem(":mcla:milk_bucket", {
	description = S("Milk"),
	inventory_image = "mcla_core_bucket_milk.png",
	wield_image = "mcla_core_bucket_milk.png",
	stack_max = 1,
	groups = { food = 3, can_eat_when_full = 1 },
})

minetest.register_craftitem(":mcla:string",{
	description = S("String"),
	inventory_image = "mcla_core_string.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem(":mcla:leather", {
	description = S("Leather"),
	wield_image = "mcla_core_leather.png",
	inventory_image = "mcla_core_leather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem(":mcla:feather", {
	description = S("Feather"),
	wield_image = "mcla_core_feather.png",
	inventory_image = "mcla_core_feather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem(":mcla:saddle", {
	description = S("Saddle"),
	wield_image = "mcla_core_saddle.png",
	inventory_image = "mcla_core_saddle.png",
	groups = { transport = 1 },
	stack_max = 1,
})

minetest.register_craftitem(":mcla:slimeball", {
	description = S("Slimeball"),
	inventory_image = "mcla_core_slimeball.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem(":mcla:gunpowder", {
	description = S("Gunpowder"),
	inventory_image = "mcla_core_gunpowder.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

-----------
-- Crafting
-----------

minetest.register_craft({
	type = "cooking",
	output = "mcla:cooked_porkchop",
	recipe = "mcla:porkchop",
	cooktime = 10,
})

