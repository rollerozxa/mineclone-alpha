local S = minetest.get_translator("mcl_jukebox")

mcl_jukebox = {}
mcl_jukebox.registered_records = {}

-- Player name-indexed table containing the currently heard track
local active_tracks = {}

-- Player name-indexed table containing the current used HUD ID for the “Now playing” message.
local active_huds = {}

-- Player name-indexed table for the “Now playing” message.
-- Used to make sure that minetest.after only applies to the latest HUD change event
local hud_sequence_numbers = {}

function mcl_jukebox.register_record(title, author, identifier, image, sound)
	mcl_jukebox.registered_records["mcla:record_"..identifier] = {title, author, identifier, image, sound}
	minetest.register_craftitem(":mcla:record_"..identifier, {
		description =
			core.colorize("#55FFFF", S("Music Disc")) .. "\n" ..
			core.colorize("#989898", S("@1—@2", author, title)),
		--inventory_image = "mcl_jukebox_record_"..recorddata[r][3]..".png",
		inventory_image = image,
		stack_max = 1,
		groups = { music_record = 1 },
	})
end

local function now_playing(player, name)
	local playername = player:get_player_name()
	local hud = active_huds[playername]
	local text = S("Now playing: @1—@2", mcl_jukebox.registered_records[name][2], mcl_jukebox.registered_records[name][1])

	if not hud_sequence_numbers[playername] then
		hud_sequence_numbers[playername] = 1
	else
		hud_sequence_numbers[playername] = hud_sequence_numbers[playername] + 1
	end

	local id
	if hud ~= nil then
		id = hud
		player:hud_change(id, "text", text)
	else
		id = player:hud_add({
			hud_elem_type = "text",
			position = { x=0.5, y=0.8 },
			offset = { x=0, y = 0 },
			number = 0x55FFFF,
			text = text,
			z_index = 100,
		})
		active_huds[playername] = id
	end
	minetest.after(5, function(tab)
		local playername = tab[1]
		local player = minetest.get_player_by_name(playername)
		local id = tab[2]
		local seq = tab[3]
		if not player or not player:is_player() or not active_huds[playername] or not hud_sequence_numbers[playername] or seq ~= hud_sequence_numbers[playername] then
			return
		end
		if id ~= nil and id == active_huds[playername] then
			player:hud_remove(active_huds[playername])
			active_huds[playername] = nil
		end
	end, {playername, id, hud_sequence_numbers[playername]})
	
end

minetest.register_on_leaveplayer(function(player)
	active_tracks[player:get_player_name()] = nil
	active_huds[player:get_player_name()] = nil
	hud_sequence_numbers[player:get_player_name()] = nil
end)

-- Jukebox crafting
minetest.register_craft({
	output = 'mcla:jukebox',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'mcla:diamond', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

local play_record = function(pos, itemstack, player)
	local item_name = itemstack:get_name()
	-- ensure the jukebox uses the new record names for old records
	local name = minetest.registered_aliases[item_name] or item_name
	if mcl_jukebox.registered_records[name] then
		local cname = player:get_player_name()
		if active_tracks[cname] ~= nil then
			minetest.sound_stop(active_tracks[cname])
			active_tracks[cname] = nil
		end
		active_tracks[cname] = minetest.sound_play(mcl_jukebox.registered_records[name][5], {
			to_player = cname,
			gain = 1,
		})
		now_playing(player, name)
		return true
	end
	return false
end

-- Jukebox
minetest.register_node(":mcla:jukebox", {
	description = S("Jukebox"),
	tiles = {"mcl_jukebox_top.png", "mcl_jukebox_side.png", "mcl_jukebox_side.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy=1,axey=1, container=7, deco_block=1, material_wood=1, flammable=-1},
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_rightclick= function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker then return end
		local cname = clicker:get_player_name()
		if minetest.is_protected(pos, cname) then
			minetest.record_protection_violation(pos, cname)
			return
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("main") then
			-- Jukebox contains a disc: Stop music and remove disc
			if active_tracks[cname] ~= nil then
				minetest.sound_stop(active_tracks[cname])
			end
			local lx = pos.x
			local ly = pos.y+1
			local lz = pos.z
			local record = inv:get_stack("main", 1)
			local dropped_item = minetest.add_item({x=lx, y=ly, z=lz}, record)
			-- Rotate record to match with “slot” texture
			dropped_item:set_yaw(math.pi/2)
			inv:set_stack("main", 1, "")
			if active_tracks[cname] ~= nil then
				minetest.sound_stop(active_tracks[cname])
				active_tracks[cname] = nil
			end
			if active_huds[cname] ~= nil then
				clicker:hud_remove(active_huds[cname])
				active_huds[cname] = nil
			end
		else
			-- Jukebox is empty: Play track if player holds music record
			local playing = play_record(pos, itemstack, clicker)
			if playing then
				local put_itemstack = ItemStack(itemstack)
				put_itemstack:set_count(1)
				inv:set_stack("main", 1, put_itemstack)
				itemstack:take_item()
			end
		end
		return itemstack
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("main", 1)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			local dropped_item = minetest.add_item(p, stack)
			-- Rotate record to match with “slot” texture
			dropped_item:set_yaw(math.pi/2)
			if active_tracks[name] ~= nil then
				minetest.sound_stop(active_tracks[name])
				active_tracks[name] = nil
			end
			if active_huds[name] ~= nil then
				digger:hud_remove(active_huds[name])
				active_huds[name] = nil
			end
		end
		meta:from_table(meta2:to_table())
	end,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcla:jukebox",
	burntime = 15,
})

mcl_jukebox.register_record("The Evil Sister (Jordach's Mix)", "SoundHelix", "13", "mcl_jukebox_record_13.png", "mcl_jukebox_track_1")
mcl_jukebox.register_record("The Energetic Rat (Jordach's Mix)", "SoundHelix", "cat", "mcl_jukebox_record_cat.png", "mcl_jukebox_track_2")

--add backward compatibility
minetest.register_alias("mcla:record_1", "mcla:record_13")
minetest.register_alias("mcla:record_2", "mcla:record_cat")
