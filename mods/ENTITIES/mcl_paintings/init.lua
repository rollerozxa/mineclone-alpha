mcl_paintings = {}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/paintings.lua")

local S = minetest.get_translator("mcl_paintings")

local wood = "[combine:16x16:-192,0=mcl_paintings_paintings.png"

local is_protected = function(pos, name)
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

-- Check if there's a painting for provided painting size.
-- If yes, returns the arguments.
-- If not, returns the next smaller available painting.
local shrink_painting = function(x, y)
	if x > 4 or y > 4 then
		return nil
	end
	local xstart = x
	local painting
	while not painting do
		painting = mcl_paintings.paintings[y] and mcl_paintings.paintings[y][x]
		if type(painting) == "table" then
			break
		elseif type(painting) == "number" then
			x = painting
			painting = nil
		else
			x = xstart
			y = y - 1
		end
		if y < 1 then
			return nil
		end
	end
	if type(painting) == "table" then
		return x, y
	end
end

local get_painting = function(x, y, motive)
	local painting = mcl_paintings.paintings[y] and mcl_paintings.paintings[y][x] and mcl_paintings.paintings[y][x][motive]
	if not painting then
		return nil
	end
	local px, py = -painting.cx, -painting.cy
	local sx, sy = 16*x, 16*y
	return "[combine:"..sx.."x"..sy..":"..px..","..py.."=mcl_paintings_paintings.png"
end

local get_random_painting = function(x, y)
	if not mcl_paintings.paintings[y] or not mcl_paintings.paintings[y][x] then
		return nil
	end
	local max = #mcl_paintings.paintings[y][x]
	if max < 1 then
		return nil
	end
	local r = math.random(1, max)
	return get_painting(x, y, r), r
end

local size_to_minmax = function(size)
	local min, max
	if size == 2 then
		min = -0.5
		max = 1.5
	elseif size == 3 then
		min = -1.5
		max = 1.5
	elseif size == 4 then
		min = -1.5
		max = 2.5
	else
		min = -0.5
		max = 0.5
	end
	return min, max
end

local size_to_minmax_entity = function(size)
	return -size/2, size/2
end

local set_entity = function(object)
	local ent = object:get_luaentity()
	local wallm = ent._facing
	local xsize = ent._xsize
	local ysize = ent._ysize
	local exmin, exmax = size_to_minmax_entity(xsize)
	local eymin, eymax = size_to_minmax_entity(ysize)
	local visual_size = { x=xsize-0.0001, y=ysize-0.0001, z=1/32 }
	if not ent._xsize or not ent._ysize or not ent._motive then
		minetest.log("error", "[mcl_paintings] Painting loaded with missing painting values!")
		return
	end
	local painting = get_painting(xsize, ysize, ent._motive)
	if not painting then
		minetest.log("error", "[mcl_paintings] No painting found for size "
				..xsize..","..ysize..", motive number "..ent._motive.."!")
		return
	end
	local box
	if wallm == 2 then
		box = { -3/128, eymin, exmin, 1/64, eymax, exmax }
	elseif wallm == 3 then
		box = { -1/64, eymin, exmin, 3/128, eymax, exmax }
	elseif wallm == 4 then
		box = { exmin, eymin, -3/128, exmax, eymax, 1/64 }
	elseif wallm == 5 then
		box = { exmin, eymin, -1/64, exmax, eymax, 3/128 }
	end
	object:set_properties({
		selectionbox = box,
		visual_size = visual_size,
		textures = { wood, wood, wood, wood, painting, wood },
	})

	local dir = minetest.wallmounted_to_dir(wallm)
	if not dir then
		return
	end
	object:set_yaw(minetest.dir_to_yaw(dir))
end

minetest.register_entity("mcla_paintings:painting", {
	visual = "cube",
	visual_size = { x=0.999, y=0.999, z=1/32 },
	selectionbox = { -1/64, -0.5, -0.5, 1/64, 0.5, 0.5 },
	physical = false,
	collide_with_objects = false,
	textures = { wood, wood, wood, wood, wood, wood },
	hp_max = 1,

	_motive = 0,
	_pos = nil,
	_facing = 2,
	_xsize = 1,
	_ysize = 1,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		if staticdata and staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			if data then
				self._facing = data._facing
				self._pos = data._pos
				self._motive = data._motive
				self._xsize = data._xsize
				self._ysize = data._ysize
			end
		end
		set_entity(self.object)
	end,
	get_staticdata = function(self)
		local data = {
			_facing = self._facing,
			_pos = self._pos,
			_motive = self._motive,
			_xsize = self._xsize,
			_ysize = self._ysize,
		}
		return minetest.serialize(data)
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
		-- Drop as item on punch
		if puncher and puncher:is_player() then
			kname = puncher:get_player_name()
			local pos = self._pos
			if not pos then
				pos = self.object:get_pos()
			end
			if not minetest.is_protected(pos, kname) then
				self.object:remove()
				if not minetest.is_creative_enabled(kname) then
					minetest.add_item(pos, "mcla:painting")
				end
			end
		end
	end,
})

minetest.register_craftitem(":mcla:painting", {
	description = S("Painting"),
	inventory_image = "mcl_paintings_painting.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		dir = vector.normalize(dir)
		if dir.y ~= 0 then
			-- Ceiling/floor paintings are not supported
			return itemstack
		end
		local wallm = minetest.dir_to_wallmounted(dir)
		if wallm then
			local ppos = pointed_thing.above
			local xmax
			local ymax = 4
			local xmaxes = {}
			local ymaxed = false
			local negative = dir.x < 0 or dir.z > 0
			-- Check maximum possible painting size
			local t
			for y=0,3 do
			for x=0,3 do
				local k = x
				if negative then
					k = -k
				end
				if dir.z ~= 0 then
					t = {x=k,y=y,z=0}
				else
					t = {x=0,y=y,z=k}
				end
				local unode = minetest.get_node(vector.add(pointed_thing.under, t))
				local anode = minetest.get_node(vector.add(ppos, t))
				local udef = minetest.registered_nodes[unode.name]
				local adef = minetest.registered_nodes[anode.name]
				if (not (udef and udef.walkable)) or (not adef or adef.walkable) then
					xmaxes[y+1] = x
					if x == 0 and not ymaxed then
						ymax = y
						ymaxed = true
					end
					break
				end
			end
			if not xmaxes[y] then
				xmaxes[y] = 4
			end
			end
			xmax = math.max(unpack(xmaxes))

			local xsize, ysize = xmax, ymax
			xsize, ysize = shrink_painting(xsize, ysize)
			if not xsize then
				return itemstack
			end

			local _, exmax = size_to_minmax_entity(xsize)
			local _, eymax = size_to_minmax_entity(ysize)
			local pposa = vector.subtract(ppos, vector.multiply(dir, 0.5-5/256))
			local name = placer:get_player_name()
			local pexmax
			local peymax = eymax - 0.5
			local n
			if negative then
				pexmax = -exmax + 0.5
				n = -1
			else
				pexmax = exmax - 0.5
				n = 1
			end
			if is_protected(ppos, name) then return itemstack end
			local ppos2
			if dir.z ~= 0 then
				pposa = vector.add(pposa, {x=pexmax, y=peymax, z=0})
				ppos2 = vector.add(ppos, {x = (xsize-1)*n, y = ysize-1, z = 0})
			else
				pposa = vector.add(pposa, {x=0, y=peymax, z=pexmax})
				ppos2 = vector.add(ppos, {x = 0, y = ysize-1, z = (xsize-1)*n})
			end
			if is_protected(ppos2, name) then return itemstack end
			local painting, pid = get_random_painting(xsize, ysize)
			if not painting then
				minetest.log("error", "[mcl_paintings] No painting found for size "..xsize..","..ysize.."!")
				return itemstack
			end
			local staticdata = {
				_facing = wallm,
				_pos = ppos,
				_motive = pid,
				_xsize = xsize,
				_ysize = ysize,
			}
			local obj = minetest.add_entity(pposa, "mcla:painting", minetest.serialize(staticdata))
			if not obj then
				return itemstack
			end
		else
			return itemstack
		end
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = "mcla:painting",
	recipe = {
		{ "mcla:stick", "mcla:stick", "mcla:stick" },
		{ "mcla:stick", "group:wool", "mcla:stick" },
		{ "mcla:stick", "mcla:stick", "mcla:stick" },
	}
})

