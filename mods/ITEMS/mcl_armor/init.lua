local S = minetest.get_translator("mcla_armor")

dofile(minetest.get_modpath(minetest.get_current_modname()).."/armor.lua")

-- Regisiter Head Armor

minetest.register_tool(":mcla:helmet_leather", {
	description = S("Leather Cap"),
	inventory_image = "mcl_armor_inv_helmet_leather.png",
	groups = { armor_head=1, mcla_armor_points=1, mcla_armor_uses=56 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:helmet_iron", {
	description = S("Iron Helmet"),
	inventory_image = "mcl_armor_inv_helmet_iron.png",
	groups = { armor_head=1, mcla_armor_points=2, mcla_armor_uses=166 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:helmet_gold", {
	description = S("Golden Helmet"),
	inventory_image = "mcl_armor_inv_helmet_gold.png",
	groups = { armor_head=1, mcla_armor_points=2, mcla_armor_uses=78 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:helmet_diamond",{
	description = S("Diamond Helmet"),
	inventory_image = "mcl_armor_inv_helmet_diamond.png",
	groups = { armor_head=1, mcla_armor_points=3, mcla_armor_uses=364, mcla_armor_toughness=2 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:helmet_chain", {
	description = S("Chain Helmet"),
	inventory_image = "mcl_armor_inv_helmet_chain.png",
	groups = { armor_head=1, mcla_armor_points=2, mcla_armor_uses=166 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

-- Regisiter Torso Armor

minetest.register_tool(":mcla:chestplate_leather", {
	description = S("Leather Tunic"),
	inventory_image = "mcl_armor_inv_chestplate_leather.png",
	groups = { armor_torso=1, mcla_armor_points=3, mcla_armor_uses=81 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:chestplate_iron", {
	description = S("Iron Chestplate"),
	inventory_image = "mcl_armor_inv_chestplate_iron.png",
	groups = { armor_torso=1, mcla_armor_points=6, mcla_armor_uses=241 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:chestplate_gold", {
	description = S("Golden Chestplate"),
	inventory_image = "mcl_armor_inv_chestplate_gold.png",
	groups = { armor_torso=1, mcla_armor_points=5, mcla_armor_uses=113 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:chestplate_diamond",{
	description = S("Diamond Chestplate"),
	inventory_image = "mcl_armor_inv_chestplate_diamond.png",
	groups = { armor_torso=1, mcla_armor_points=8, mcla_armor_uses=529, mcla_armor_toughness=2 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:chestplate_chain", {
	description = S("Chain Chestplate"),
	inventory_image = "mcl_armor_inv_chestplate_chain.png",
	groups = { armor_torso=1, mcla_armor_points=5, mcla_armor_uses=241 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

-- Regisiter Leg Armor

minetest.register_tool(":mcla:leggings_leather", {
	description = S("Leather Pants"),
	inventory_image = "mcl_armor_inv_leggings_leather.png",
	groups = { armor_legs=1, mcla_armor_points=2, mcla_armor_uses=76 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:leggings_iron", {
	description = S("Iron Leggings"),
	inventory_image = "mcl_armor_inv_leggings_iron.png",
	groups = { armor_legs=1, mcla_armor_points=5, mcla_armor_uses=226 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:leggings_gold", {
	description = S("Golden Leggings"),
	inventory_image = "mcl_armor_inv_leggings_gold.png",
	groups = { armor_legs=1, mcla_armor_points=3, mcla_armor_uses=106 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:leggings_diamond",{
	description = S("Diamond Leggings"),
	inventory_image = "mcl_armor_inv_leggings_diamond.png",
	groups = { armor_legs=1, mcla_armor_points=6, mcla_armor_uses=496, mcla_armor_toughness=2 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:leggings_chain", {
	description = S("Chain Leggings"),
	inventory_image = "mcl_armor_inv_leggings_chain.png",
	groups = {armor_legs=1, mcla_armor_points=4, mcla_armor_uses=226 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})
-- Regisiter Boots

minetest.register_tool(":mcla:boots_leather", {
	description = S("Leather Boots"),
	inventory_image = "mcl_armor_inv_boots_leather.png",
	groups = {armor_feet=1, mcla_armor_points=1, mcla_armor_uses=66 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:boots_iron", {
	description = S("Iron Boots"),
	inventory_image = "mcl_armor_inv_boots_iron.png",
	groups = {armor_feet=1, mcla_armor_points=2, mcla_armor_uses=196 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:boots_gold", {
	description = S("Golden Boots"),
	inventory_image = "mcl_armor_inv_boots_gold.png",
	groups = {armor_feet=1, mcla_armor_points=1, mcla_armor_uses=92 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:boots_diamond",{
	description = S("Diamond Boots"),
	inventory_image = "mcl_armor_inv_boots_diamond.png",
	groups = {armor_feet=1, mcla_armor_points=3, mcla_armor_uses=430, mcla_armor_toughness=2 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool(":mcla:boots_chain", {
	description = S("Chain Boots"),
	inventory_image = "mcl_armor_inv_boots_chain.png",
	groups = {armor_feet=1, mcla_armor_points=1, mcla_armor_uses=196 },

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

-- Register Craft Recipies

local craft_ingreds = {
	leather = "mcla:leather",
	iron = "mcla:iron_ingot",
	gold = "mcla:gold_ingot",
	diamond = "mcla:diamond",
}

for k, v in pairs(craft_ingreds) do
	-- material
	if v ~= nil then
		minetest.register_craft({
			output = "mcla:helmet_"..k,
			recipe = {
				{v, v, v},
				{v, "", v},
				{"", "", ""},
			},
		})
		minetest.register_craft({
			output = "mcla:chestplate_"..k,
			recipe = {
				{v, "", v},
				{v, v, v},
				{v, v, v},
			},
		})
		minetest.register_craft({
			output = "mcla:leggings_"..k,
			recipe = {
				{v, v, v},
				{v, "", v},
				{v, "", v},
			},
		})
		minetest.register_craft({
			output = "mcla:boots_"..k,
			recipe = {
				{v, "", v},
				{v, "", v},
			},
		})
	end
end

