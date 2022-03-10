local S = minetest.get_translator("mcl_fences")

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

mcl_fences = {}

mcl_fences.register_fence = function(id, fence_name, texture, groups, hardness, blast_resistance, connects_to, sounds)
	local cgroups = table.copy(groups)
	if cgroups == nil then cgroups = {} end
	cgroups.fence = 1
	cgroups.deco_block = 1
	if connects_to == nil then
		connects_to = {}
	else
		connects_to = table.copy(connects_to)
	end
	local fence_id = minetest.get_current_modname()..":"..id
	table.insert(connects_to, "group:solid")
	table.insert(connects_to, "group:fence_gate")
	table.insert(connects_to, fence_id)
	minetest.register_node(fence_id, {
		description = fence_name,
		tiles = {texture},
		inventory_image = "mcl_fences_fence_mask.png^" .. texture .. "^mcl_fences_fence_mask.png^[makealpha:255,126,126",
		wield_image = "mcl_fences_fence_mask.png^" .. texture .. "^mcl_fences_fence_mask.png^[makealpha:255,126,126",
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
		_mcl_blast_resistance = blast_resistance,
		_mcl_hardness = hardness,
	})

	return fence_id
end

mcl_fences.register_fence_and_fence_gate = function(id, fence_name, fence_gate_name, texture_fence, groups, hardness, blast_resistance, connects_to, sounds, sound_open, sound_close, sound_gain_open, sound_gain_close, texture_fence_gate)
	if texture_fence_gate == nil then
		texture_fence_gate = texture_fence
	end
	local fence_id = mcl_fences.register_fence(id, fence_name, texture_fence, groups, hardness, blast_resistance, connects_to, sounds)
	return fence_id, gate_id, open_gate_id
end

local wood_groups = {handy=1,axey=1, flammable=2,fence_wood=1, fire_encouragement=5, fire_flammability=20}
local wood_connect = {"group:fence_wood"}
local wood_sounds = mcl_sounds.node_sound_wood_defaults()

local woods = {
	{"", S("Fence"), S("Fence Gate"), "mcl_fences_fence_oak.png", "mcl_fences_fence_gate_oak.png", "mcl_core:wood"},
}

for w=1, #woods do
	local wood = woods[w]
	local id, id_gate
	if wood[1] == "" then
		id = "fence"
		id_gate = "fence_gate"
	else
		id = wood[1].."_fence"
		id_gate = wood[1].."_fence_gate"
	end
	mcl_fences.register_fence_and_fence_gate(id, wood[2], wood[3], wood[4], wood_groups, 2, 15, wood_connect, wood_sounds)

	minetest.register_craft({
		output = 'mcl_fences:'..id..' 3',
		recipe = {
			{wood[6], 'mcl_core:stick', wood[6]},
			{wood[6], 'mcl_core:stick', wood[6]},
		}
	})
end


minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})
