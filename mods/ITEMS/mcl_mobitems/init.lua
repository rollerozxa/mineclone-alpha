local S = minetest.get_translator("mcl_mobitems")

minetest.register_craftitem("mcl_mobitems:porkchop", {
	description = S("Raw Porkchop"),
	inventory_image = "mcl_mobitems_porkchop_raw.png",
	wield_image = "mcl_mobitems_porkchop_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_porkchop", {
	description = S("Cooked Porkchop"),
	inventory_image = "mcl_mobitems_porkchop_cooked.png",
	wield_image = "mcl_mobitems_porkchop_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:milk_bucket", {
	description = S("Milk"),
	inventory_image = "mcl_mobitems_bucket_milk.png",
	wield_image = "mcl_mobitems_bucket_milk.png",
	stack_max = 1,
	groups = { food = 3, can_eat_when_full = 1 },
})

minetest.register_craftitem("mcl_mobitems:bone", {
	description = S("Bone"),
	inventory_image = "mcl_mobitems_bone.png",
	stack_max = 64,
	groups = { craftitem=1 },
	_mcl_toollike_wield = true,
})

minetest.register_craftitem("mcl_mobitems:string",{
	description = S("String"),
	inventory_image = "mcl_mobitems_string.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:leather", {
	description = S("Leather"),
	wield_image = "mcl_mobitems_leather.png",
	inventory_image = "mcl_mobitems_leather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:feather", {
	description = S("Feather"),
	wield_image = "mcl_mobitems_feather.png",
	inventory_image = "mcl_mobitems_feather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:saddle", {
	description = S("Saddle"),
	wield_image = "mcl_mobitems_saddle.png",
	inventory_image = "mcl_mobitems_saddle.png",
	groups = { transport = 1 },
	stack_max = 1,
})

minetest.register_craftitem("mcl_mobitems:slimeball", {
	description = S("Slimeball"),
	inventory_image = "mcl_mobitems_slimeball.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:gunpowder", {
	description = S("Gunpowder"),
	inventory_image = "mcl_mobitems_gunpowder.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

-----------
-- Crafting
-----------

minetest.register_craft({
	type = "cooking",
	output = "mcl_mobitems:cooked_porkchop",
	recipe = "mcl_mobitems:porkchop",
	cooktime = 10,
})
