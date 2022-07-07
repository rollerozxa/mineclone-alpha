
local S = minetest.get_translator("mcl_furnaces")

local LIGHT_ACTIVE_FURNACE = 13

--
-- Formspecs
--

local function active_formspec(fuel_percent, item_percent)
	return "size[9,8.75]"..
	"label[0,4;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"label[2.75,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Furnace"))).."]"..
	"list[current_name;src;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,2.5,1,1)..
	"list[current_name;dst;5.75,1.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(5.75,1.5,1,1)..
	"image[2.75,1.5;1,1;mcl_furnaces_fire_bg.png^[lowpart:"..
	(100-fuel_percent)..":mcl_furnaces_fire_fg.png]"..
	"image[4.1,1.5;1.5,1;mcl_furnaces_arrow_bg.png^[lowpart:"..
	(item_percent)..":mcl_furnaces_arrow_fg.png^[transformR270]"..
	-- Craft guide button temporarily removed due to Minetest bug.
	-- TODO: Add it back when the Minetest bug is fixed.
	--"image_button[8,0;1,1;craftguide_book.png;craftguide;]"..
	--"tooltip[craftguide;"..minetest.formspec_escape(S("Recipe book")).."]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"
end

local inactive_formspec = "size[9,8.75]"..
	"label[0,4;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"label[2.75,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Furnace"))).."]"..
	"list[current_name;src;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,2.5,1,1)..
	"list[current_name;dst;5.75,1.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(5.75,1.5,1,1)..
	"image[2.75,1.5;1,1;mcl_furnaces_fire_bg.png]"..
	"image[4.1,1.5;1.5,1;mcl_furnaces_arrow_bg.png^[transformR270]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"



--
-- Node callback functions that are the same for active and inactive furnace
--

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		-- Special case: empty bucket (not a fuel, but used for sponge drying)
		if stack:get_name() == "mcla:bucket_empty" then
			if inv:get_stack(listname, index):get_count() == 0 then
				return 1
			else
				return 0
			end
		end

		-- Test stack with size 1 because we burn one fuel at a time
		local teststack = ItemStack(stack)
		teststack:set_count(1)
		local output, decremented_input = minetest.get_craft_result({method="fuel", width=1, items={teststack}})
		if output.time ~= 0 then
			-- Only allow to place 1 item if fuel get replaced by recipe.
			-- This is the case for lava buckets.
			local replace_item = decremented_input.items[1]
			if replace_item:is_empty() then
				-- For most fuels, just allow to place everything
				return stack:get_count()
			else
				if inv:get_stack(listname, index):get_count() == 0 then
					return 1
				else
					return 0
				end
			end
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	return stack:get_count()
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)

end

local function spawn_flames(pos, param2)
	local minrelpos, maxrelpos
	local dir = minetest.facedir_to_dir(param2)
	if dir.x > 0 then
		minrelpos = { x = -0.6, y = -0.05, z = -0.25 }
		maxrelpos = { x = -0.55, y = -0.45, z = 0.25 }
	elseif dir.x < 0 then
		minrelpos = { x = 0.55, y = -0.05, z = -0.25 }
		maxrelpos = { x = 0.6, y = -0.45, z = 0.25 }
	elseif dir.z > 0 then
		minrelpos = { x = -0.25, y = -0.05, z = -0.6 }
		maxrelpos = { x = 0.25, y = -0.45, z = -0.55 }
	elseif dir.z < 0 then
		minrelpos = { x = -0.25, y = -0.05, z = 0.55 }
		maxrelpos = { x = 0.25, y = -0.45, z = 0.6 }
	else
		return
	end
	mcl_particles.add_node_particlespawner(pos, {
		amount = 4,
		time = 0,
		minpos = vector.add(pos, minrelpos),
		maxpos = vector.add(pos, maxrelpos),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.4,
		maxsize = 0.8,
		texture = "mcl_particles_flame.png",
		glow = LIGHT_ACTIVE_FURNACE,
	}, "low")
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
	if name == "mcla:furnace_active" then
		spawn_flames(pos, node.param2)
	else
		mcl_particles.delete_node_particlespawners(pos)
	end
end

local function furnace_reset_delta_time(pos)
	local meta = minetest.get_meta(pos)
	local time_speed = tonumber(minetest.settings:get('time_speed') or 72)
	if (time_speed < 0.1) then
		return
	end
	local time_multiplier = 86400 / time_speed
	local current_game_time = .0 + ((minetest.get_day_count() + minetest.get_timeofday()) * time_multiplier)

	-- TODO: Change meta:get/set_string() to get/set_float() for 'last_gametime'.
	-- In Windows *_float() works OK but under Linux it returns rounded unusable values like 449540.000000000
	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 or math.abs(last_game_time - current_game_time) <= 1.5 then
		return
	end

	meta:set_string("last_gametime", tostring(current_game_time))
end

local function furnace_get_delta_time(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local time_speed = tonumber(minetest.settings:get('time_speed') or 72)
	local current_game_time
	if (time_speed < 0.1) then
		return meta, elapsed
	else
		local time_multiplier = 86400 / time_speed
		current_game_time = .0 + ((minetest.get_day_count() + minetest.get_timeofday()) * time_multiplier)
	end

	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 then
		last_game_time = current_game_time - 0.1
	elseif last_game_time == current_game_time then
		current_game_time = current_game_time + 1.0
	end

	local elapsed_game_time = .0 + current_game_time - last_game_time

	meta:set_string("last_gametime", tostring(current_game_time))

	return meta, elapsed_game_time
end

local function furnace_node_timer(pos, elapsed)
	--
	-- Inizialize metadata
	--
	local meta, elapsed_game_time = furnace_get_delta_time(pos, elapsed)

	local fuel_time = meta:get_float("fuel_time") or 0
	local src_time = meta:get_float("src_time") or 0
	local src_item = meta:get_string("src_item") or ""
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local srclist, fuellist

	local cookable, cooked
	local active = true
	local fuel

	srclist = inv:get_list("src")
	fuellist = inv:get_list("fuel")

	-- Check if src item has been changed
	if srclist[1]:get_name() ~= src_item then
		-- Reset cooking progress in this case
		src_time = 0
		src_item = srclist[1]:get_name()
	end

	local update = true
	while elapsed_game_time > 0.00001 and update do
		--
		-- Cooking
		--

		local el = elapsed_game_time

		-- Check if we have cookable content: cookable
		local aftercooked
		cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		cookable = cooked.time ~= 0
		if cookable then
			-- Successful cooking requires space in dst slot and time
			if not inv:room_for_item("dst", cooked.item) then
				cookable = false
			end
		end

		if cookable then -- fuel lasts long enough, adjust el to cooking duration
			el = math.min(el, cooked.time - src_time)
		end

		-- Check if we have enough fuel to burn
		active = fuel_time < fuel_totaltime
		if cookable and not active then
			-- We need to get new fuel
			local afterfuel
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

			if fuel.time == 0 then
				-- No valid fuel in fuel list -- stop
				fuel_totaltime = 0
				src_time = 0
				update = false
			else
				-- Take fuel from fuel list
				inv:set_stack("fuel", 1, afterfuel.items[1])
				fuel_time = 0
				fuel_totaltime = fuel.time
				el = math.min(el, fuel_totaltime)
				active = true
				fuellist = inv:get_list("fuel")
			end
		elseif active then
			el = math.min(el, fuel_totaltime - fuel_time)
			-- The furnace is currently active and has enough fuel
			fuel_time = fuel_time + el
		end

		-- If there is a cookable item then check if it is ready yet
		if cookable and active then
			src_time = src_time + el
			-- Place result in dst list if done
			if src_time >= cooked.time then
				inv:add_item("dst", cooked.item)
				inv:set_stack("src", 1, aftercooked.items[1])

				-- Unique recipe: Pour water into empty bucket after cooking wet sponge successfully
				if inv:get_stack("fuel", 1):get_name() == "mcla:bucket_empty" then
					if srclist[1]:get_name() == "mcla:sponge_wet" then
						inv:set_stack("fuel", 1, "mcla:bucket_water")
						fuellist = inv:get_list("fuel")
					-- Also for river water
					elseif srclist[1]:get_name() == "mcla:sponge_wet_river_water" then
						inv:set_stack("fuel", 1, "mcla:bucket_river_water")
						fuellist = inv:get_list("fuel")
					end
				end

				srclist = inv:get_list("src")
				src_time = 0

				meta:set_int("xp", meta:get_int("xp") + 1)		-- ToDo give each recipe an idividial XP count
			end
		end

		elapsed_game_time = elapsed_game_time - el
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end
	if srclist and srclist[1]:is_empty() then
		src_time = 0
	end

	--
	-- Update formspec and node
	--
	local formspec = inactive_formspec
	local item_state
	local item_percent = 0
	if cookable then
		item_percent = math.floor(src_time / cooked.time * 100)
	end

	local result = false

	if active then
		local fuel_percent = 0
		if fuel_totaltime > 0 then
			fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
		end
		formspec = active_formspec(fuel_percent, item_percent)
		swap_node(pos, "mcla:furnace_active")
		-- make sure timer restarts automatically
		result = true
	else
		swap_node(pos, "mcla:furnace")
		-- stop timer on the inactive furnace
		minetest.get_node_timer(pos):stop()
	end

	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("src_time", src_time)
	if srclist then
		 meta:set_string("src_item", srclist[1]:get_name())
	else
		 meta:set_string("src_item", "")
	end
	meta:set_string("formspec", formspec)

	return result
end

local on_rotate, after_rotate_active
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
	after_rotate_active = function(pos)
		local node = minetest.get_node(pos)
		mcl_particles.delete_node_particlespawners(pos)
		if node.name == "mcla:furnace" then
			return
		end
		spawn_flames(pos, node.param2)
	end
end

minetest.register_node(":mcla:furnace", {
	description = S("Furnace"),
	tiles = {
		"mcl_core_stone.png", "mcl_core_stone.png",
		"mcl_furnaces_side.png", "mcl_furnaces_side.png",
		"mcl_furnaces_side.png", "mcl_furnaces_front.png"
	},
	paramtype2 = "facedir",
	groups = {pickaxey=1, container=4, deco_block=1, material_stone=1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),

	on_timer = furnace_node_timer,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			local stack = inv:get_stack(listname, 1)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('fuel', 1)
		inv:set_size('dst', 1)
	end,
	on_destruct = function(pos)
		mcl_particles.delete_node_particlespawners(pos)
	end,

	on_metadata_inventory_move = function(pos)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		-- start timer function, it will helpful if player clears dst slot
		minetest.get_node_timer(pos):start(1.0)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	on_rotate = on_rotate,
})

minetest.register_node(":mcla:furnace_active", {
	description = S("Burning Furnace"),
	tiles = {
		"mcl_core_stone.png", "mcl_core_stone.png",
		"mcl_furnaces_side.png", "mcl_furnaces_side.png",
		"mcl_furnaces_side.png", "mcl_furnaces_front_active.png",
	},
	paramtype2 = "facedir",
	paramtype = "light",
	light_source = LIGHT_ACTIVE_FURNACE,
	drop = "mcla:furnace",
	groups = {pickaxey=1, container=4, deco_block=1, not_in_creative_inventory=1, material_stone=1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_timer = furnace_node_timer,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			local stack = inv:get_stack(listname, 1)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,

	on_construct = function(pos)
		local node = minetest.get_node(pos)
		spawn_flames(pos, node.param2)
	end,
	on_destruct = function(pos)
		mcl_particles.delete_node_particlespawners(pos)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_take = on_metadata_inventory_take,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	on_rotate = on_rotate,
	after_rotate = after_rotate_active,
})

minetest.register_craft({
	output = "mcla:furnace",
	recipe = {
		{ "mcla:cobble", "mcla:cobble", "mcla:cobble" },
		{ "mcla:cobble", "", "mcla:cobble" },
		{ "mcla:cobble", "mcla:cobble", "mcla:cobble" },
	}
})


minetest.register_lbm({
	label = "Active furnace flame particles",
	name = "mcla_furnaces:flames",
	nodenames = {"mcla:furnace_active"},
	run_at_every_load = true,
	action = function(pos, node)
		spawn_flames(pos, node.param2)
	end,
})
