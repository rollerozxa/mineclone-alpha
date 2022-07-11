local S = minetest.get_translator("mcla_hbarmor")

if (not armor) or (not armor.def) then
	minetest.log("error", "[mcla_hbarmor] Outdated mcla_armor version. Please update your version of mcla_armor!")
end

local mcla_hbarmor = {}

-- HUD statbar values
mcla_hbarmor.armor = {}

-- Stores if player's HUD bar has been initialized so far.
mcla_hbarmor.player_active = {}

local arm_printable = function(arm)
	return math.ceil(math.floor(arm+0.5))
end

local function custom_hud(player)
	local name = player:get_player_name()

	if minetest.settings:get_bool("enable_damage") then
		local ret = mcla_hbarmor.get_armor(player)
		if ret == false then
			minetest.log("error", "[mcla_hbarmor] Call to mcla_hbarmor.get_armor in custom_hud returned with false!")
			return
		end
		local arm = tonumber(mcla_hbarmor.armor[name])
		if not arm then
			arm = 0
		end
		hb.init_hudbar(player, "armor", arm_printable(arm), nil, arm == 0)
	end
end

--register and define armor HUD bar
hb.register_hudbar("armor", 0xFFFFFF, S("Armor"), { icon = "hbarmor_icon.png", bgicon = "hbarmor_bgicon.png" }, 0, 20, true)

function mcla_hbarmor.get_armor(player)
	if not player or not armor.def then
		return false
	end
	local name = player:get_player_name()
	local pts = armor:get_armor_points(player)
	if not pts then
		return false
	else
		mcla_hbarmor.set_armor(name, pts)
	end
	return true
end

function mcla_hbarmor.set_armor(player_name, pts)
	mcla_hbarmor.armor[player_name] = math.max(0, math.min(20, pts))
end

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
	--armor
	local arm = tonumber(mcla_hbarmor.armor[name])
	if not arm then
		arm = 0
		mcla_hbarmor.armor[name] = 0
	end
	if mcla_hbarmor.autohide then
		-- hide armor bar completely when there is none
		if arm == 0 then
			hb.hide_hudbar(player, "armor")
		else
			hb.change_hudbar(player, "armor", arm_printable(arm))
			hb.unhide_hudbar(player, "armor")
		end
	else
		hb.change_hudbar(player, "armor", arm_printable(arm))
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	custom_hud(player)
	mcla_hbarmor.player_active[name] = true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mcla_hbarmor.player_active[name] = false
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > 0.2 or timer > 4 then
		if minetest.settings:get_bool("enable_damage") then
			if main_timer > 0.2 then main_timer = 0 end
			for _,player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
				if mcla_hbarmor.player_active[name] == true then
					local ret = mcla_hbarmor.get_armor(player)
					if ret == false then
						minetest.log("error", "[mcla_hbarmor] Call to mcla_hbarmor.get_armor in globalstep returned with false!")
					end
					-- update all hud elements
					update_hud(player)
				end
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
