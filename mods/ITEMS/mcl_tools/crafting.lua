

--
-- Tool recipes.
--

local tool_data = {
	plank = "wood",
	cobble = "stone",
	iron_ingot = "iron",
	gold_ingot = "gold",
	diamond = "diamond"
}

local s = "mcla:stick"
local e = ""

for k, v in pairs(tool_data) do
	local i = "mcla:"..k
	local o = "mcla:"..v.."_"
	-- Pickaxes
	minetest.register_craft({
		output = o.."pickaxe",
		recipe = {
			{i, i, i},
			{e, s, e},
			{e, s, e},
		}
	})

	-- Shovels
	minetest.register_craft({
		output = o.."shovel",
		recipe = {
			{i},
			{s},
			{s},
		}
	})

	-- Axes
	minetest.register_craft({
		output = o.."axe",
		recipe = {
			{i, i},
			{s, i},
			{s, e},
		}
	})

	-- Axes (Mirrored)
	minetest.register_craft({
		output = o.."axe",
		recipe = {
			{i, i},
			{i, s},
			{e, s},
		}
	})

	-- Sword
	minetest.register_craft({
		output = o.."sword",
		recipe = {
			{i},
			{i},
			{s}
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_pickaxe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_shovel",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_sword",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_axe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_pickaxe",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_shovel",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_sword",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:wood_axe",
	burntime = 10,
})
