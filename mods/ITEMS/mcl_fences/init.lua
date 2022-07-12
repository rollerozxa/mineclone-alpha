local S = minetest.get_translator("mcla_fences")

-- Node box
local p = {-2/16, -0.5, -2/16, 2/16, 0.5, 2/16}
local x1 = {-0.5, 4/16, -1/16, -2/16, 7/16, 1/16}   --oben(quer) -x
local x12 = {-0.5, -2/16, -1/16, -2/16, 1/16, 1/16} --unten(quer) -x
local x2 = {2/16, 4/16, -1/16, 0.5, 7/16, 1/16}   --oben(quer) x
local x22 = {2/16, -2/16, -1/16, 0.5, 1/16, 1/16} --unten(quer) x
local z1 = {-1/16, 4/16, -0.5, 1/16, 7/16, -2/16}   --oben(quer) -z
local z12 = {-1/16, -2/16, -0.5, 1/16, 1/16, -2/16} --unten(quer) -z
local z2 = {-1/16, 4/16, 2/16, 1/16, 7/16, 0.5}   --oben(quer) z
local z22 = {-1/16, -2/16, 2/16, 1/16, 1/16, 0.5} --unten(quer) z

-- Collision box
local cp = {-2/16, -0.5, -2/16, 2/16, 1.01, 2/16}
local cx1 = {-0.5, -0.5, -2/16, -2/16, 1.01, 2/16} --unten(quer) -x
local cx2 = {2/16, -0.5, -2/16, 0.5, 1.01, 2/16} --unten(quer) x
local cz1 = {-2/16, -0.5, -0.5, 2/16, 1.01, -2/16} --unten(quer) -z
local cz2 = {-2/16, -0.5, 2/16, 2/16, 1.01, 0.5} --unten(quer) z

mcla_fences = {}

mcla_fences.register_fence = function(id, fence_name, texture, groups, hardness, blast_resistance, connects_to, sounds)
	local cgroups = table.copy(groups)
	if cgroups == nil then cgroups = {} end
	cgroups.fence = 1
	cgroups.deco_block = 1
	if connects_to == nil then
		connects_to = {}
	else
		connects_to = table.copy(connects_to)
	end
	local fence_id = "mcla:"..id
	table.insert(connects_to, "group:solid")
	table.insert(connects_to, fence_id)
	minetest.register_node(":"..fence_id, {
		description = fence_name,
		tiles = {texture},
		inventory_image = "mcla_fences_fence_mask.png^" .. texture .. "^mcla_fences_fence_mask.png^[makealpha:255,126,126",
		wield_image = "mcla_fences_fence_mask.png^" .. texture .. "^mcla_fences_fence_mask.png^[makealpha:255,126,126",
		paramtype = "light",
		is_ground_content = false,
		groups = cgroups,
		stack_max = 64,
		sunlight_propagates = true,
		drawtype = "nodebox",
		connect_sides = { "front", "back", "left", "right" },
		connects_to = connects_to,
		node_box = {
			type = "connected",
			fixed = {p},
			connect_front = {z1,z12},
			connect_back = {z2,z22,},
			connect_left = {x1,x12},
			connect_right = {x2,x22},
		},
		collision_box = {
			type = "connected",
			fixed = {cp},
			connect_front = {cz1},
			connect_back = {cz2,},
			connect_left = {cx1},
			connect_right = {cx2},
		},
		sounds = sounds,
		_mcla_blast_resistance = blast_resistance,
		_mcla_hardness = hardness,
	})

	return fence_id
end

local wood_groups = {handy=1,axey=1, flammable=2,fence_wood=1, fire_encouragement=5, fire_flammability=20}
local wood_connect = {"group:fence_wood"}
local wood_sounds = mcla_sounds.node_sound_wood_defaults()

local woods = {
	{"", S("Fence"), "mcla_core_wood.png", "mcla:wood"},
}

for w=1, #woods do
	local wood = woods[w]
	local id
	if wood[1] == "" then
		id = "fence"
	else
		id = wood[1].."_fence"
	end
	mcla_fences.register_fence(id, wood[2], wood[3], wood_groups, 2, 15, wood_connect, wood_sounds)

	minetest.register_craft({
		output = 'mcla:'..id..' 3',
		recipe = {
			{wood[4], 'mcla:stick', wood[4]},
			{wood[4], 'mcla:stick', wood[4]},
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})
