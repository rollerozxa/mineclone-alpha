local S = minetest.get_translator("mcla_structures")
mcla_structures ={}
local rotations = {
	"0",
	"90",
	"180",
	"270"
}

local function ecb_place(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	minetest.place_schematic(param.pos, param.schematic, param.rotation, param.replacements, param.force_placement, param.flags)
	if param.after_placement_callback and param.p1 and param.p2 then
		param.after_placement_callback(param.p1, param.p2, param.size, param.rotation, param.pr)
	end
end
mcla_structures.place_schematic = function(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr)
	local s = loadstring(minetest.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return(schematic)")()
	if s and s.size then
		local x, z = s.size.x, s.size.z
		if rotation then
			if rotation == "random" and pr then
				rotation = rotations[pr:next(1,#rotations)]
			end
			if rotation == "random" then
				x = math.max(x, z)
				z = x
			elseif rotation == "90" or rotation == "270" then
				x, z = z, x
			end
		end
		local p1 = {x=pos.x    , y=pos.y           , z=pos.z    }
		local p2 = {x=pos.x+x-1, y=pos.y+s.size.y-1, z=pos.z+z-1}
		minetest.log("verbose","[mcla_structures] size=" ..minetest.pos_to_string(s.size) .. ", rotation=" .. tostring(rotation) .. ", emerge from "..minetest.pos_to_string(p1) .. " to " .. minetest.pos_to_string(p2))
		local param = {pos=vector.new(pos), schematic=s, rotation=rotation, replacements=replacements, force_placement=force_placement, flags=flags, p1=p1, p2=p2, after_placement_callback = after_placement_callback, size=vector.new(s.size), pr=pr}
		minetest.emerge_area(p1, p2, ecb_place, param)
	end
end

mcla_structures.get_struct = function(file)
	local localfile = minetest.get_modpath("mcla_structures").."/schematics/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload ~= nil then
		minetest.log("error", '[mcla_structures] Could not open this struct: ' .. localfile)
		return nil
	end

	local allnode = file:read("*a")
	file:close()

	return allnode
end

-- Call on_construct on pos.
-- Useful to init chests from formspec.
local init_node_construct = function(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.on_construct then
		def.on_construct(pos)
		return true
	end
	return false
end

-- The call of Struct
mcla_structures.call_struct = function(pos, struct_style, rotation, pr)
	minetest.log("action","[mcla_structures] call_struct " .. struct_style.." at "..minetest.pos_to_string(pos))
	if not rotation then
		rotation = "random"
	end
	--if struct_style == "desert_temple" then
	--	return mcla_structures.generate_desert_temple(pos, rotation, pr)
	--end
end

local registered_structures = {}

--[[ Returns a table of structure of the specified type.
Currently the only valid parameter is "stronghold".
Format of return value:
{
	{ pos = <position>, generated=<true/false> }, -- first structure
	{ pos = <position>, generated=<true/false> }, -- second structure
	-- and so on
}

TODO: Implement this function for all other structure types as well.
]]
mcla_structures.get_registered_structures = function(structure_type)
	if registered_structures[structure_type] then
		return table.copy(registered_structures[structure_type])
	else
		return {}
	end
end

-- Register a structures table for the given type. The table format is the same as for
-- mcla_structures.get_registered_structures.
mcla_structures.register_structures = function(structure_type, structures)
	registered_structures[structure_type] = structures
end

local function dir_to_rotation(dir)
	local ax, az = math.abs(dir.x), math.abs(dir.z)
	if ax > az then
		if dir.x < 0 then
			return "270"
		end
		return "90"
	end
	if dir.z < 0 then
		return "180"
	end
	return "0"
end

mcla_structures.generate_test_structure_fireproof = function(pos, rotation, pr)
	local path = minetest.get_modpath("mcla_structures").."/schematics/mcla_structures_test_structure_fireproof.mts"
	mcla_structures.place_schematic(pos, path, rotation, nil, true, nil, nil, pr)
end

-- Debug command
minetest.register_chatcommand("spawnstruct", {
	params = "test_structure_fireproof",
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(player:get_look_horizontal())
		local rot = dir_to_rotation(dir)
		local pr = PseudoRandom(pos.x+pos.y+pos.z)
		local errord = false
		local message = S("Structure placed.")
		if param == "test_structure_fireproof" then
			mcla_structures.generate_test_structure_fireproof(pos, rot, pr)
		elseif param == "" then
			message = S("Error: No structure type given. Please use “/spawnstruct <type>”.")
			errord = true
		else
			message = S("Error: Unknown structure type. Please use “/spawnstruct <type>”.")
			errord = true
		end
		minetest.chat_send_player(name, message)
		if errord then
			minetest.chat_send_player(name, S("Use /help spawnstruct to see a list of avaiable types."))
		end
	end
})
