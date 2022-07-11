unused_args = false
allow_defined_top = true
max_line_length = false
redefined = false

std = "min"

read_globals = {
	"ItemStack",
	"dump", "dump2",
	"vector",
	"VoxelArea",
	"minetest", "core",
	"PseudoRandom",
	"PerlinNoise",
	"PcgRandom",
	
	
	"mobs",
	
	"mcla_tnt", "mcla_burning", "mcla_playerinfo", "mcla_sprint", "mcla_worlds", "mcla_util", 
	"screwdriver",
	
	string = {fields = {"split", "trim"}},
	table  = {fields = {"copy", "getn", "indexof", "insert_all"}},
	math   = {fields = {"hypot", "round"}},
}

globals = {
	"armor",
	"mesecon",
	"mcla_vars", 
}

ignore = {"631"}

-- A config option to allow r/w access to mods which contain
-- this one. It only avoids a couple warnings, and may not be
-- the behavior we want, so it's disabled by default.
local allow_parents=false

local lfs = require "lfs"

-- Seed the queue with the mods/ directory
local queue={ {"mods"} }

local function check(dir)
	-- Get the string of the directory path
	local sdir=table.concat(dir, "/")
	-- Save the top-level directory name as a
	-- fallback in case there's no mod.conf,
	-- or no name= directive.
	local name=dir[#dir]

	-- Is there a mod.conf?
	if lfs.attributes(sdir.."/mod.conf", "mode") == "file" then
		local deps={}
		for line in io.lines(sdir.."/mod.conf") do
			-- Use name= if it's there
			name=string.match(line, "name *= *([a-zA-Z0-9_]+)") or name
			-- Get the dependency entries (if they're there)
			local ents=string.match(line, "depends *=(.*)$")
			if ents then
				-- Split them in to the comma-separated names
				for m in string.gmatch(ents, "([a-zA-Z0-9_]+),?") do
					table.insert(deps, m)
				end
			end
		end

		local glb={ name }
		if allow_parents then
			for _, v in pairs(dir) do
				-- Skip ALL-CAPS names since those tend
				-- to be collections of mods instead of
				-- mods themselves.
				if not string.match(v, "^[A-Z]+$") then
					table.insert(glb, v)
				end
			end
		end

		-- Tell Luacheck what the directory is allowed to do
		files[sdir]={
			globals = glb,
			read_globals = deps,
		}
	elseif lfs.attributes(sdir.."/init.lua", "mode") == "file" then
		-- No mod.conf, but there's an init.lua here.
		local glb={ name }
		if allow_parents then
			for _, v in pairs(dir) do
				-- Again, skip ALL-CAPS.
				if not string.match(v, "^[A-Z]+$") then
					table.insert(glb, v)
				end
			end
		end

		files[sdir]={ globals=glb }
	end

	-- Queue any child directories
	for d in lfs.dir(sdir) do
		-- Skip hidden directories and parent/current directories.
		if lfs.attributes(sdir.."/"..d, "mode") == "directory" and not string.match(d, "^%.") then
			-- Copy dir in to nd (New Dir)
			local nd={}
			for k, v in pairs(dir) do
				nd[k]=v
			end
			nd[#nd+1]=d
			table.insert(queue, nd)
		end
	end
end

while #queue > 0 do
	-- Pop an entry and process it.
	check(table.remove(queue, 1))
end
