local modpath = minetest.get_modpath("mcla_burning")

mcla_burning = {
	animation_frames = 8,
	animation_fps = 30
}

dofile(modpath .. "/api.lua")

local fire_texture = "mcla_burning_entity_flame_animated.png^[opacity:180^[verticalframe:8:1"
minetest.register_entity("mcla_burning:fire", {
	initial_properties = {
		physical = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "cube",
		pointable = false,
		glow = -1,
		textures = {"blank.png", "blank.png", fire_texture, fire_texture, fire_texture, fire_texture}
	},

	animation_frame = 0,
	animation_timer = 0,
	on_step = mcla_burning.fire_entity_step,
})

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		mcla_burning.tick(player, dtime)
	end
end)

minetest.register_on_respawnplayer(function(player)
	mcla_burning.extinguish(player)
end)

minetest.register_on_leaveplayer(function(player)
	mcla_burning.set(player, "int", "hud_id")
end)
