local S = minetest.get_translator("mcl_tools")

-- mods/default/tools.lua

--
-- Tool definition
--

--[[
dig_speed_class group:
- 1: Painfully slow
- 2: Very slow
- 3: Slow
- 4: Fast
- 5: Very fast
- 6: Extremely fast
- 7: Instantaneous
]]

-- The hand
local groupcaps, hand_range, hand_groups

if minetest.is_creative_enabled("") then
	-- Instant breaking in creative mode
	groupcaps = { creative_breakable = { times = {0}, uses = 0 } }
	hand_range = 10
	hand_groups = { dig_speed_class = 7 }
else
	groupcaps = {}
	hand_range = 4
	hand_groups = { dig_speed_class = 1 }
end
minetest.register_tool(":", {
	type = "none",
	wield_image = "blank.png",
	wield_scale = {x=1.0,y=1.0,z=2.0},
	-- According to Minecraft Wiki, the exact range is 3.975.
	-- Minetest seems to only support whole numbers, so we use 4.
	range = hand_range,
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level = 0,
		groupcaps = groupcaps,
		damage_groups = {fleshy=1},
	},
	groups = hand_groups,
	_mcl_diggroups = {
		handy = { speed = 1, level = 1, uses = 0 },
		axey = { speed = 1, level = 1, uses = 0 },
		shovely = { speed = 1, level = 1, uses = 0 },
		pickaxey = { speed = 1, level = 0, uses = 0 },
		swordy = { speed = 1, level = 0, uses = 0 },
		swordy_cobweb = { speed = 1, level = 0, uses = 0 },
		shearsy = { speed = 1, level = 0, uses = 0 },
		shearsy_wool = { speed = 1, level = 0, uses = 0 },
		shearsy_cobweb = { speed = 1, level = 0, uses = 0 },
	}
})

local wield_scale = { x = 1.5, y = 1.5, z = 1 }

-- Picks
minetest.register_tool(":mcla:wood_pickaxe", {
	description = S("Wooden Pickaxe"),
	inventory_image = "mcl_tools_wood_pickaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=2 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 30,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool(":mcla:stone_pickaxe", {
	description = S("Stone Pickaxe"),
	inventory_image = "mcl_tools_stone_pickaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=3 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		damage_groups = {fleshy=3},
		punch_attack_uses = 66,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool(":mcla:iron_pickaxe", {
	description = S("Iron Pickaxe"),
	inventory_image = "mcl_tools_iron_pickaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=4 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=4,
		damage_groups = {fleshy=4},
		punch_attack_uses = 126,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool(":mcla:gold_pickaxe", {
	description = S("Golden Pickaxe"),
	inventory_image = "mcl_tools_gold_pickaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=6 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=2,
		damage_groups = {fleshy=2},
		punch_attack_uses = 17,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool(":mcla:diamond_pickaxe", {
	description = S("Diamond Pickaxe"),
	inventory_image = "mcl_tools_diamond_pickaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=5 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 781,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 8, level = 5, uses = 1562 }
	},
})

-- Shovels
minetest.register_tool(":mcla:wood_shovel", {
	description = S("Wooden Shovel"),
	inventory_image = "mcl_tools_wood_shovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=2 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 30,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool(":mcla:stone_shovel", {
	description = S("Stone Shovel"),
	inventory_image = "mcl_tools_stone_shovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=3 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=3,
		damage_groups = {fleshy=3},
		punch_attack_uses = 66,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool(":mcla:iron_shovel", {
	description = S("Iron Shovel"),
	inventory_image = "mcl_tools_iron_shovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=4 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=4,
		damage_groups = {fleshy=4},
		punch_attack_uses = 126,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool(":mcla:gold_shovel", {
	description = S("Golden Shovel"),
	inventory_image = "mcl_tools_gold_shovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=6 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=2,
		damage_groups = {fleshy=2},
		punch_attack_uses = 17,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool(":mcla:diamond_shovel", {
	description = S("Diamond Shovel"),
	inventory_image = "mcl_tools_diamond_shovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=5 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 781,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 8, level = 5, uses = 1562 }
	},
})

-- Axes
minetest.register_tool(":mcla:wood_axe", {
	description = S("Wooden Axe"),
	inventory_image = "mcl_tools_wood_axe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=2 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=1,
		damage_groups = {fleshy=7},
		punch_attack_uses = 30,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool(":mcla:stone_axe", {
	description = S("Stone Axe"),
	inventory_image = "mcl_tools_stone_axe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=3 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=3,
		damage_groups = {fleshy=9},
		punch_attack_uses = 66,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool(":mcla:iron_axe", {
	description = S("Iron Axe"),
	inventory_image = "mcl_tools_iron_axe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=4 },
	tool_capabilities = {
		-- 1/0.9
		full_punch_interval = 1.11111111,
		max_drop_level=4,
		damage_groups = {fleshy=9},
		punch_attack_uses = 126,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool(":mcla:gold_axe", {
	description = S("Golden Axe"),
	inventory_image = "mcl_tools_gold_axe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=6 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		damage_groups = {fleshy=7},
		punch_attack_uses = 17,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool(":mcla:diamond_axe", {
	description = S("Diamond Axe"),
	inventory_image = "mcl_tools_diamond_axe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=5 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 781,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 8, level = 5, uses = 1562 }
	},
})

-- Swords
minetest.register_tool(":mcla:wood_sword", {
	description = S("Wooden Sword"),
	inventory_image = "mcl_tools_wood_sword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=2 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 60 },
		swordy_cobweb = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool(":mcla:stone_sword", {
	description = S("Stone Sword"),
	inventory_image = "mcl_tools_stone_sword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=3 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 4, level = 3, uses = 132 },
		swordy_cobweb = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool(":mcla:iron_sword", {
	description = S("Iron Sword"),
	inventory_image = "mcl_tools_iron_sword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=4 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 6, level = 4, uses = 251 },
		swordy_cobweb = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool(":mcla:gold_sword", {
	description = S("Golden Sword"),
	inventory_image = "mcl_tools_gold_sword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=6 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		damage_groups = {fleshy=4},
		punch_attack_uses = 33,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 12, level = 2, uses = 33 },
		swordy_cobweb = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool(":mcla:diamond_sword", {
	description = S("Diamond Sword"),
	inventory_image = "mcl_tools_diamond_sword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 1562 },
		swordy_cobweb = { speed = 8, level = 5, uses = 1562 }
	},
})


dofile(minetest.get_modpath("mcla_tools").."/crafting.lua")
