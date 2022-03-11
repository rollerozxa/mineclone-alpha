--[[ This table contains the concrete itemstrings to be used by this mod.
All mobs in this mod must use variables in this table, instead
of hardcoding the itemstring.
This way, external mods are enabled to replace the itemstrings to provide
their own items and game integration is made much simpler.

An item IDs is supposed to be overwritten by adding
mobs_mc.override.items["example:item"] in a game mod
with name "mobs_mc_gameconfig". ]]


-- Standard items

-- Tables for attracting, feeding and breeding mobs
mobs_mc.follow = {
	chicken = { "mcl_farming:wheat_seeds", "mcl_farming:pumpkin_seeds" },
	sheep = { "mcl_farming:wheat_item" },
	cow = { "mcl_farming:wheat_item" },
}

-- Contents for replace_what
mobs_mc.replace = {
	-- Sheep eat grass
	sheep = {
		{ "mcl_core:dirt_with_grass", "mcl_core:dirt", -1 },
		{ "mcl_flowers:tallgrass", "air", 0 },
	},
}

-- List of nodes on which mobs can spawn
mobs_mc.spawn = {
	solid = { "group:solid", }, -- spawn on "solid" nodes
	grassland = { "mcl_core:dirt_with_grass" },
	savanna = { "mcl_core:dirt_with_grass" },
	grassland_savanna = { "mcl_core:dirt_with_grass" },
	desert = { "mcl_core:sand" },
	snow = { "mcl_core:snow", "mcl_core:snowblock", "mcl_core:dirt_with_grass_snow" },
	water = { "mcl_core:water_source", "mcl_core:water_source", "default:water_source" },
}

-- This table contains important spawn height references for the mob spawn height.
-- Please base your mob spawn height on these numbers to keep things clean.
mobs_mc.spawn_height = {
	water = tonumber(minetest.settings:get("water_level")) or 0, -- Water level in the Overworld

	-- Overworld boundaries (inclusive)
	overworld_min = mcl_vars.mg_overworld_min,
	overworld_max = mcl_vars.mg_overworld_max,
}

mobs_mc.misc = {
	shears_wear = 276, -- Wear to add per shears usage (238 uses)
}

-- Item name overrides from mobs_mc_gameconfig (if present)
if minetest.get_modpath("mobs_mc_gameconfig") and mobs_mc.override then
	local tables = {"items", "follow", "replace", "spawn", "spawn_height", "misc"}
	for t=1, #tables do
		local tbl = tables[t]
		if mobs_mc.override[tbl] then
			for k, v in pairs(mobs_mc.override[tbl]) do
				mobs_mc[tbl][k] = v
			end
		end
	end
end

