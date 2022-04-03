mcl_worlds = {}

-- For a given position, returns a 2-tuple:
-- 1st return value: true if pos is in void
-- 2nd return value: true if it is in the deadly part of the void
function mcl_worlds.is_in_void(pos)
	local void =
		not (pos.y < mcl_vars.mg_overworld_max and pos.y > mcl_vars.mg_overworld_min)

	local void_deadly = false
	local deadly_tolerance = 64 -- the player must be this many nodes “deep” into the void to be damaged
	if void then
		-- Overworld → Void → End → Void → Nether → Void
		if pos.y < mcl_vars.mg_overworld_min then
			void_deadly = pos.y < mcl_vars.mg_overworld_min - deadly_tolerance
		end
	end
	return void, void_deadly
end

-- Takes an Y coordinate as input and returns:
-- 1) The corresponding Minecraft layer (can be nil if void)
-- 2) The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if it is in the void
-- If the Y coordinate is not located in any dimension, it will return:
--     nil, "void"
function mcl_worlds.y_to_layer(y)
	if y >= mcl_vars.mg_overworld_min then
		return y - mcl_vars.mg_overworld_min, "overworld"
	else
		return nil, "void"
	end
end

-- Takes a pos and returns the dimension it belongs to (same as above)
function mcl_worlds.pos_to_dimension(pos)
	local _, dim = mcl_worlds.y_to_layer(pos.y)
	return dim
end

-- Takes a Minecraft layer and a “dimension” name
-- and returns the corresponding Y coordinate for
-- MineClone 2.
-- mc_dimension is one of "overworld", "nether", "end" (default: "overworld").
function mcl_worlds.layer_to_y(layer, mc_dimension)
	if mc_dimension == "overworld" or mc_dimension == nil then
		return layer + mcl_vars.mg_overworld_min
	end
end

--------------- CALLBACKS ------------------
mcl_worlds.registered_on_dimension_change = {}

-- Register a callback function func(player, dimension).
-- It will be called whenever a player changes between dimensions.
-- The void counts as dimension.
-- * player: The player who changed the dimension
-- * dimension: The new dimension of the player ("overworld", "nether", "end", "void").
function mcl_worlds.register_on_dimension_change(func)
	table.insert(mcl_worlds.registered_on_dimension_change, func)
end

-- Playername-indexed table containig the name of the last known dimension the
-- player was in.
local last_dimension = {}

-- Notifies this mod about a dimension change of a player.
-- * player: Player who changed the dimension
-- * dimension: New dimension ("overworld", "nether", "end", "void")
function mcl_worlds.dimension_change(player, dimension)
	for i=1, #mcl_worlds.registered_on_dimension_change do
		mcl_worlds.registered_on_dimension_change[i](player, dimension)
		last_dimension[player:get_player_name()] = dimension
	end
end

----------------------- INTERNAL STUFF ----------------------

-- Update the dimension callbacks every DIM_UPDATE seconds
local DIM_UPDATE = 1
local dimtimer = 0

minetest.register_on_joinplayer(function(player)
	last_dimension[player:get_player_name()] = mcl_worlds.pos_to_dimension(player:get_pos())
end)

minetest.register_globalstep(function(dtime)
	-- regular updates based on iterval
	dimtimer = dimtimer + dtime;
	if dimtimer >= DIM_UPDATE then
		local players = minetest.get_connected_players()
		for p=1, #players do
			local dim = mcl_worlds.pos_to_dimension(players[p]:get_pos())
			local name = players[p]:get_player_name()
			if dim ~= last_dimension[name] then
				mcl_worlds.dimension_change(players[p], dim)
			end
		end
		dimtimer = 0
	end
end)

