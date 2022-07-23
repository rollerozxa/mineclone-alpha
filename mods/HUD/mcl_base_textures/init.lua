-- This mod has no code and is only a collection of textures.

minetest.register_on_joinplayer(function(player)
	player:set_sun({
		scale = 4
	})

	player:set_moon({
		scale = 4
	})
end)
