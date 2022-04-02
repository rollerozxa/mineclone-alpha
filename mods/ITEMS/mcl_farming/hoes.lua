local S = minetest.get_translator("mcl_farming")

local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
			return true
		end
	end
	return false
end

local hoe_on_place_function = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535/wear_divisor)
			end
			return itemstack
		end
	end
end

local uses = {
	wood = 60,
	stone = 132,
	iron = 251,
	gold = 33,
	diamond = 1562,
}

minetest.register_tool("mcl_farming:wood_hoe", {
	description = S("Wood Hoe"),
	inventory_image = "mcl_farming_wood_hoe.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	on_place = hoe_on_place_function(uses.wood),
	groups = { tool=1, hoe=1, },
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.wood,
	},
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_farming:wood_hoe",
	recipe = {
		{"group:wood", "group:wood"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:wood_hoe",
	recipe = {
		{"group:wood", "group:wood"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_farming:wood_hoe",
	burntime = 10,
})

minetest.register_tool("mcl_farming:stone_hoe", {
	description = S("Stone Hoe"),
	inventory_image = "mcl_farming_stone_hoe.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	on_place = hoe_on_place_function(uses.stone),
	groups = { tool=1, hoe=1 },
	tool_capabilities = {
		full_punch_interval = 0.5,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.stone,
	},
	_repair_material = "mcl_core:cobble",
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_farming:stone_hoe",
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:stone_hoe",
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_tool("mcl_farming:iron_hoe", {
	description = S("Iron Hoe"),
	inventory_image = "mcl_farming_iron_hoe.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	on_place = hoe_on_place_function(uses.iron),
	groups = { tool=1, hoe=1 },
	tool_capabilities = {
		-- 1/3
		full_punch_interval = 0.33333333,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.iron,
	},
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_farming:iron_hoe",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:iron_hoe",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_tool("mcl_farming:gold_hoe", {
	description = S("Golden Hoe"),
	inventory_image = "mcl_farming_gold_hoe.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	on_place = hoe_on_place_function(uses.gold),
	groups = { tool=1, hoe=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.gold,
	},
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_farming:gold_hoe",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:gold_hoe",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})



minetest.register_tool("mcl_farming:diamond_hoe", {
	description = S("Diamond Hoe"),
	inventory_image = "mcl_farming_diamond_hoe.png",
	wield_scale = { x = 1.8, y = 1.8, z = 1 },
	on_place = hoe_on_place_function(uses.diamond),
	groups = { tool=1, hoe=1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1, },
		punch_attack_uses = uses.diamond,
	},
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_farming:diamond_hoe",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:diamond_hoe",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})
