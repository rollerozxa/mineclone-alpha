local S = minetest.get_translator("mcla_minecarts")

-- Template rail function
local register_rail = function(itemstring, tiles, def_extras, creative)
	local groups = {handy=1,pickaxey=1, attached_node=1,rail=1,connect_to_raillike=minetest.raillike_group("rail"),dig_by_water=1,destroy_by_lava_flow=1, transport=1}
	if creative == false then
		groups.not_in_creative_inventory = 1
	end
	local ndef = {
		drawtype = "raillike",
		tiles = tiles,
		is_ground_content = false,
		inventory_image = tiles[1],
		wield_image = tiles[1],
		paramtype = "light",
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		stack_max = 64,
		groups = groups,
		sounds = mcla_sounds.node_sound_metal_defaults(),
		_mcla_blast_resistance = 3.5,
		_mcla_hardness = 0.7,
		after_destruct = function(pos)
			-- Scan for minecarts in this pos and force them to execute their "floating" check.
			-- Normally, this will make them drop.
			local objs = minetest.get_objects_inside_radius(pos, 1)
			for o=1, #objs do
				local le = objs[o]:get_luaentity()
				if le then
					-- All entities in this mod are minecarts, so this works
					if string.sub(le.name, 1, 14) == "mcla:" then
						le._last_float_check = mcla_minecarts.check_float_time
					end
				end
			end
		end,
	}
	if def_extras then
		for k,v in pairs(def_extras) do
			ndef[k] = v
		end
	end
	minetest.register_node(itemstring, ndef)
end

-- Redstone rules
local rail_rules_long =
{{x=-1,  y= 0, z= 0, spread=true},
 {x= 1,  y= 0, z= 0, spread=true},
 {x= 0,  y=-1, z= 0, spread=true},
 {x= 0,  y= 1, z= 0, spread=true},
 {x= 0,  y= 0, z=-1, spread=true},
 {x= 0,  y= 0, z= 1, spread=true},

 {x= 1, y= 1, z= 0},
 {x= 1, y=-1, z= 0},
 {x=-1, y= 1, z= 0},
 {x=-1, y=-1, z= 0},
 {x= 0, y= 1, z= 1},
 {x= 0, y=-1, z= 1},
 {x= 0, y= 1, z=-1},
 {x= 0, y=-1, z=-1}}

local rail_rules_short = mesecon.rules.pplate

-- Normal rail
register_rail(":mcla:rail",
	{"mcla_minecarts_rail.png", "mcla_minecarts_rail_curved.png", "mcla_minecarts_rail_t_junction.png", "mcla_minecarts_rail_crossing.png"},
	{
		description = S("Rail"),
	}
)

-- Crafting
minetest.register_craft({
	output = 'mcla:rail 16',
	recipe = {
		{'mcla:iron_ingot', '', 'mcla:iron_ingot'},
		{'mcla:iron_ingot', 'mcla:stick', 'mcla:iron_ingot'},
		{'mcla:iron_ingot', '', 'mcla:iron_ingot'},
	}
})
