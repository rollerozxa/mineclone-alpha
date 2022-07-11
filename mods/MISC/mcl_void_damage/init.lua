local S = minetest.get_translator("mcla_void_damage")
local enable_damage = minetest.settings:get_bool("enable_damage")

local voidtimer = 0
local VOID_DAMAGE_FREQ = 0.5
local VOID_DAMAGE = 4

-- Remove entities that fall too deep into the void
minetest.register_on_mods_loaded(function()
	-- We do this by overwriting on_step of all entities
	for entitystring, def in pairs(minetest.registered_entities) do
		local on_step_old = def.on_step
		if not on_step_old then
			on_step_old = function() end
		end
		local on_step = function(self, dtime, moveresult)
			on_step_old(self, dtime, moveresult)
			local obj = self.object
			local pos = obj:get_pos()
			-- Old on_step function might have deleted object,
			-- so we delete it
			if not pos then
				return
			end

			if not self._void_timer then
				self._void_timer = 0
			end
			self._void_timer = self._void_timer + dtime
			if self._void_timer <= VOID_DAMAGE_FREQ then
				return
			end
			self._void_timer = 0

			local pos = obj:get_pos()
			local void, void_deadly = mcla_worlds.is_in_void(pos)
			if void_deadly then
				local ent = obj:get_luaentity()
				obj:remove()
				return
			end
		end
		def.on_step = on_step
		minetest.register_entity(":"..entitystring, def)
	end
end)

-- Hurt players or teleport them back to spawn if they are too deep in the void
minetest.register_globalstep(function(dtime)
	voidtimer = voidtimer + dtime
	if voidtimer > VOID_DAMAGE_FREQ then
		voidtimer = 0
		local enable_damage = minetest.settings:get_bool("enable_damage")
		local players = minetest.get_connected_players()
		for p=1, #players do
			local player = players[p]
			local pos = player:get_pos()
			local void, void_deadly = mcla_worlds.is_in_void(pos)
			if void_deadly then
				local immortal_val = player:get_armor_groups().immortal
				local is_immortal = false
				if immortal_val and immortal_val > 0 then
					is_immortal = true
				end
				if is_immortal or not enable_damage then
					-- If damage is disabled, we can't kill players.
					-- So we just teleport the player back to spawn.
					local spawn = mcla_spawn.get_player_spawn_pos(player)
					player:set_pos(spawn)
					mcla_worlds.dimension_change(player, mcla_worlds.pos_to_dimension(spawn))
					minetest.chat_send_player(player:get_player_name(), S("The void is off-limits to you!"))
				elseif enable_damage and not is_immortal then
					-- Damage enabled, not immortal: Deal void damage (4 HP / 0.5 seconds)
					if player:get_hp() > 0 then
						mcla_death_messages.player_damage(player, S("@1 fell into the endless void.", player:get_player_name()))
						player:set_hp(player:get_hp() - VOID_DAMAGE)
					end
				end
			end
		end
	end
end)
