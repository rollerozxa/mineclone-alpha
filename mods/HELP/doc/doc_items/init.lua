local S = minetest.get_translator("doc_items")
local N = function(s) return s end

-- Local stuff
local groupdefs = {}
local mininggroups = {}
local miscgroups = {}

--[[ Append a newline to text, unless it already ends with a newline. ]]
local newline = function(text)
	if string.sub(text, #text, #text) == "\n" or text == "" then
		return text
	else
		return text .. "\n"
	end
end

-- Collect information about all items
local function gather_descs()
	-- Internal help texts for default items
	local help = {
		longdesc = {},
		usagehelp = {},
	}

	-- 1st pass: Gather groups of interest
	for id, def in pairs(minetest.registered_items) do
		-- Gather all groups used for mining
		if def.tool_capabilities ~= nil then
			local groupcaps = def.tool_capabilities.groupcaps
			if groupcaps ~= nil then
				for k,v in pairs(groupcaps) do
					if mininggroups[k] ~= true then
						mininggroups[k] = true
					end
				end
			end
		end

		-- ... and gather all groups which appear in crafting recipes
		local crafts = minetest.get_all_craft_recipes(id)
		if crafts ~= nil then
			for c=1,#crafts do
				for k,v in pairs(crafts[c].items) do
					if string.sub(v,1,6) == "group:" then
						local groupstring = string.sub(v,7,-1)
						local groups = string.split(groupstring, ",")
						for g=1, #groups do
							miscgroups[groups[g]] = true
						end
					end
				end
			end
		end

		-- ... and gather all groups used in connects_to
		if def.connects_to ~= nil then
			for c=1, #def.connects_to do
				if string.sub(def.connects_to[c],1,6) == "group:" then
					local group = string.sub(def.connects_to[c],7,-1)
					miscgroups[group] = true
				end
			end
		end
	end
end

minetest.register_on_mods_loaded(gather_descs)
