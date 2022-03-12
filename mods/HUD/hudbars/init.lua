local S = minetest.get_translator("hudbars")
local N = function(s) return s end

hb = {}

hb.hudtables = {}

-- number of registered HUD bars
hb.hudbars_count = 0

-- table which records which HUD bar slots have been “registered” so far; used for automatic positioning
hb.registered_slots = {}

hb.settings = {}

function hb.load_setting(sname, stype, defaultval, valid_values)
	local sval
	if stype == "string" then
		sval = minetest.settings:get(sname)
	elseif stype == "bool" then
		sval = minetest.settings:get_bool(sname)
	elseif stype == "number" then
		sval = tonumber(minetest.settings:get(sname))
	end
	if sval ~= nil then
		if valid_values ~= nil then
			local valid = false
			for i=1,#valid_values do
				if sval == valid_values[i] then
					valid = true
				end
			end
			if not valid then
				minetest.log("error", "[hudbars] Invalid value for "..sname.."! Using default value ("..tostring(defaultval)..").")
				return defaultval
			else
				return sval
			end
		else
			return sval
		end
	else
		return defaultval
	end
end

hb.settings.sorting = { ["health"] = 0, ["breath"] = 1, ["armor"] = 2 }
hb.settings.sorting_reverse = {}
for k,v in pairs(hb.settings.sorting) do
	hb.settings.sorting_reverse[tonumber(v)] = k
end

local function player_exists(player)
	return player ~= nil and player:is_player()
end

local function make_label(format_string, format_string_config, label, start_value, max_value)
	local params = {}
	local order = format_string_config.order
	for o=1, #order do
		if order[o] == "label" then
			table.insert(params, label)
		elseif order[o] == "value" then
			if format_string_config.format_value then
				table.insert(params, string.format(format_string_config.format_value, start_value))
			else
				table.insert(params, start_value)
			end
		elseif order[o] == "max_value" then
			if format_string_config.format_max_value then
				table.insert(params, string.format(format_string_config.format_max_value, max_value))
			else
				table.insert(params, max_value)
			end
		end
	end
	local ret
	if format_string_config.textdomain then
		ret = minetest.translate(format_string_config.textdomain, format_string, unpack(params))
	else
		ret = S(format_string, unpack(params))
	end
	return ret
end

-- Table which contains all players with active default HUD bars (only for internal use)
hb.players = {}

function hb.value_to_barlength(value, max)
	if max == 0 then
		return 0
	else
		local x
		if value < 0 then x=-0.5 else x = 0.5 end
		local ret = math.modf((value/max) * 20 + x)
		return ret
	end
end

function hb.get_hudtable(identifier)
	return hb.hudtables[identifier]
end

function hb.get_hudbar_position_index(identifier)
	if hb.settings.sorting[identifier] ~= nil then
		return hb.settings.sorting[identifier]
	else
		local i = 0
		while true do
			if hb.registered_slots[i] ~= true and hb.settings.sorting_reverse[i] == nil then
				return i
			end
			i = i + 1
		end
	end
end

function hb.register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, default_start_hidden, format_string, format_string_config)
	minetest.log("action", "hb.register_hudbar: "..tostring(identifier))
	local hudtable = {}
	local pos, offset
	local index = math.floor(hb.get_hudbar_position_index(identifier))
	hb.registered_slots[index] = true

	if index % 2 == 0 then
		pos = {
			x = 0.5,
			y = 1
		}
		offset = {
			x = -265,
			y = -90 - 28 * (index/2)
		}
	else
		pos = {
			x = 0.5,
			y = 1
		}
		offset = {
			x = 25,
			y = -90 - 28 * ((index-1)/2)
		}
	end

	if format_string == nil then
		format_string = N("@1: @2/@3")
	end
	if format_string_config == nil then
		format_string_config = {}
	end
	if format_string_config.order == nil then
		format_string_config.order = { "label", "value", "max_value" }
	end
	if format_string_config.format_value == nil then
		format_string_config.format_value = "%d"
	end
	if format_string_config.format_max_value == nil then
		format_string_config.format_max_value = "%d"
	end

	hudtable.add_all = function(player, hudtable, start_value, start_max, start_hidden)
		if start_value == nil then start_value = hudtable.default_start_value end
		if start_max == nil then start_max = hudtable.default_start_max end
		if start_hidden == nil then start_hidden = hudtable.default_start_hidden end
		local ids = {}
		local state = {}
		local name = player:get_player_name()
		local bgscale, iconscale, text, barnumber, bgiconnumber
		if start_max == 0 or start_hidden then
			bgscale = { x=0, y=0 }
		else
			bgscale = { x=1, y=1 }
		end
		if start_hidden then
			iconscale = { x=0, y=0 }
			barnumber = 0
			bgiconnumber = 0
			text = ""
		else
			iconscale = { x=1, y=1 }
			barnumber = hb.value_to_barlength(start_value, start_max)
			bgiconnumber = 20
			text = make_label(format_string, format_string_config, label, start_value, start_max)
		end

		local bar_image = textures.icon
		local bgicon = textures.bgicon
		local bar_size = {x=24, y=24}
		local text2 = bgicon
		ids.bar = player:hud_add({
			hud_elem_type = "statbar",
			position = pos,
			text = bar_image,
			text2 = text2,
			number = barnumber,
			item = bgiconnumber,
			alignment = {x=-1,y=-1},
			offset = offset,
			direction = 0,
			size = bar_size,
			z_index = 1,
		})

		-- Do not forget to update hb.get_hudbar_state if you add new fields to the state table
		state.hidden = start_hidden
		state.value = start_value
		state.max = start_max
		state.text = text
		state.barlength = hb.value_to_barlength(start_value, start_max)

		local main_error_text =
			"[hudbars] Bad initial values of HUD bar identifier “"..tostring(identifier).."” for player "..name..". "

		if start_max < start_value then
			minetest.log("error", main_error_text.."start_max ("..start_max..") is smaller than start_value ("..start_value..")!")
		end
		if start_max < 0 then
			minetest.log("error", main_error_text.."start_max ("..start_max..") is smaller than 0!")
		end
		if start_value < 0 then
			minetest.log("error", main_error_text.."start_value ("..start_value..") is smaller than 0!")
		end

		hb.hudtables[identifier].hudids[name] = ids
		hb.hudtables[identifier].hudstate[name] = state
	end

	hudtable.identifier = identifier
	hudtable.format_string = format_string
	hudtable.format_string_config = format_string_config
	hudtable.label = label
	hudtable.hudids = {}
	hudtable.hudstate = {}
	hudtable.default_start_hidden = default_start_hidden
	hudtable.default_start_value = default_start_value
	hudtable.default_start_max = default_start_max

	hb.hudbars_count= hb.hudbars_count + 1

	hb.hudtables[identifier] = hudtable
end

function hb.init_hudbar(player, identifier, start_value, start_max, start_hidden)
	if not player_exists(player) then return false end
	local hudtable = hb.get_hudtable(identifier)
	hb.hudtables[identifier].add_all(player, hudtable, start_value, start_max, start_hidden)
	return true
end

function hb.change_hudbar(player, identifier, new_value, new_max_value, new_icon, new_bgicon, new_bar, new_label, new_text_color)
	if new_value == nil and new_max_value == nil and new_icon == nil and new_bgicon == nil and new_bar == nil and new_label == nil and new_text_color == nil then
		return true
	end
	if not player_exists(player) then
		return false
	end

	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if not hudtable.hudstate[name] then
		return false
	end
	local value_changed, max_changed = false, false

	if new_value ~= nil then
		if new_value ~= hudtable.hudstate[name].value then
			hudtable.hudstate[name].value = new_value
			value_changed = true
		end
	else
		new_value = hudtable.hudstate[name].value
	end
	if new_max_value ~= nil then
		if new_max_value ~= hudtable.hudstate[name].max then
			hudtable.hudstate[name].max = new_max_value
			max_changed = true
		end
	else
		new_max_value = hudtable.hudstate[name].max
	end

	if new_icon ~= nil and hudtable.hudids[name].bar ~= nil then
		player:hud_change(hudtable.hudids[name].bar, "text", new_icon)
	end
	if new_bgicon ~= nil and hudtable.hudids[name].bg ~= nil then
		player:hud_change(hudtable.hudids[name].bg, "text", new_bgicon)
	end

	local main_error_text =
		"[hudbars] Bad call to hb.change_hudbar, identifier: “"..tostring(identifier).."”, player name: “"..name.."”. "
	if new_max_value < new_value then
		minetest.log("error", main_error_text.."new_max_value ("..new_max_value..") is smaller than new_value ("..new_value..")!")
	end
	if new_max_value < 0 then
		minetest.log("error", main_error_text.."new_max_value ("..new_max_value..") is smaller than 0!")
	end
	if new_value < 0 then
		minetest.log("error", main_error_text.."new_value ("..new_value..") is smaller than 0!")
	end

	if hudtable.hudstate[name].hidden == false then
		if value_changed or max_changed then
			local new_barlength = hb.value_to_barlength(new_value, new_max_value)
			if new_barlength ~= hudtable.hudstate[name].barlength then
				player:hud_change(hudtable.hudids[name].bar, "number", hb.value_to_barlength(new_value, new_max_value))
				hudtable.hudstate[name].barlength = new_barlength
			end
		end
	end
	return true
end

function hb.hide_hudbar(player, identifier)
	if not player_exists(player) then return false end
	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if hudtable == nil then return false end
	if hudtable.hudstate[name].hidden == true then return true end
	player:hud_change(hudtable.hudids[name].bar, "number", 0)
	player:hud_change(hudtable.hudids[name].bar, "item", 0)
	hudtable.hudstate[name].hidden = true
	return true
end

function hb.unhide_hudbar(player, identifier)
	if not player_exists(player) then return false end
	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if hudtable == nil then return false end
	if hudtable.hudstate[name].hidden == false then return true end
	local value = hudtable.hudstate[name].value
	local max = hudtable.hudstate[name].max
	player:hud_change(hudtable.hudids[name].bar, "scale", {x=1,y=1})
	player:hud_change(hudtable.hudids[name].bar, "number", hb.value_to_barlength(value, max))
	player:hud_change(hudtable.hudids[name].bar, "item", hb.value_to_barlength(max, max))
	hudtable.hudstate[name].hidden = false
	return true
end

function hb.get_hudbar_state(player, identifier)
	if not player_exists(player) then return nil end
	local ref = hb.get_hudtable(identifier).hudstate[player:get_player_name()]
	-- Do not forget to update this chunk of code in case the state changes
	local copy = {
		hidden = ref.hidden,
		value = ref.value,
		max = ref.max,
		text = ref.text,
		barlength = ref.barlength,
	}
	return copy
end

function hb.get_hudbar_identifiers()
	local ids = {}
	for id, _ in pairs(hb.hudtables) do
		table.insert(ids, id)
	end
	return ids
end

--register built-in HUD bars
if minetest.settings:get_bool("enable_damage") then
	hb.register_hudbar("health", 0xFFFFFF, S("Health"), { icon = "hudbars_icon_health.png", bgicon = "hudbars_bgicon_health.png" }, 20, 20, false)
	hb.register_hudbar("breath", 0xFFFFFF, S("Breath"), { icon = "hudbars_icon_breath.png", bgicon = "hudbars_bgicon_breath.png" }, 10, 10, true)
end

local function hide_builtin(player)
	local flags = player:hud_get_flags()
	flags.healthbar = false
	flags.breathbar = false
	player:hud_set_flags(flags)
end


local function custom_hud(player)
	local hide
	if minetest.settings:get_bool("enable_damage") then
		hide = false
	else
		hide = true
	end
	local hp = player:get_hp()
	local hp_max = player:get_properties().hp_max
	hb.init_hudbar(player, "health", math.min(hp, hp_max), hp_max, hide)
	local breath = player:get_breath()
	local breath_max = player:get_properties().breath_max
	local hide_breath
	if breath >= breath_max then
		hide_breath = true
	else
		hide_breath = false
	end
	hb.init_hudbar(player, "breath", math.min(breath, breath_max), breath_max, hide_breath or hide)
end

local function update_health(player)
	local hp_max = player:get_properties().hp_max
	hb.change_hudbar(player, "health", player:get_hp(), hp_max)
end

-- update built-in HUD bars
local function update_hud(player)
	if not player_exists(player) then return end
	if minetest.settings:get_bool("enable_damage") then
		hb.unhide_hudbar(player, "health")
		--air
		local breath_max = player:get_properties().breath_max
		local breath = player:get_breath()

		if breath >= breath_max then
			hb.hide_hudbar(player, "breath")
		else
			hb.unhide_hudbar(player, "breath")
			hb.change_hudbar(player, "breath", math.min(breath, breath_max), breath_max)
		end
		--health
		update_health(player)
	else
		hb.hide_hudbar(player, "health")
		hb.hide_hudbar(player, "breath")
	end
end

minetest.register_on_player_hpchange(function(player)
	if hb.players[player:get_player_name()] ~= nil then
		update_health(player)
	end
end)

minetest.register_on_respawnplayer(function(player)
	update_health(player)
	hb.hide_hudbar(player, "breath")
end)

minetest.register_on_joinplayer(function(player)
	hide_builtin(player)
	custom_hud(player)
	hb.players[player:get_player_name()] = player
end)

minetest.register_on_leaveplayer(function(player)
	hb.players[player:get_player_name()] = nil
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > 0.1 or timer > 4 then
		if main_timer > 0.1 then main_timer = 0 end
		-- only proceed if damage is enabled
		if minetest.settings:get_bool("enable_damage") then
			for _, player in pairs(hb.players) do
				-- update all hud elements
				update_hud(player)
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
