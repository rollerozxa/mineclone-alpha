--MCmobs v0.5
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- NOTE: Strings intentionally not marked for translation, other mods already have these items.
-- TODO: Remove this file eventually, all items here are already outsourced in other mods.

local S = minetest.get_translator("mobs_mc")

--maikerumines throwing code
--arrow (weapon)

minetest.register_node("mobs_mc:arrow_box", {
	drawtype = "nodebox",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, -4.5/17, 1.5/17, 1.5/17},
			{-4.5/17, -0.5/17, -0.5/17, 5.5/17, 0.5/17, 0.5/17},
			{5.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			-- Tip
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			-- Fletching
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"mcl_bows_arrow.png^[transformFX", "mcl_bows_arrow.png^[transformFX", "mcl_bows_arrow_back.png", "mcl_bows_arrow_front.png", "mcl_bows_arrow.png", "mcl_bows_arrow.png^[transformFX"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1, dig_immediate=3},
	node_placement_prediction = "",
	on_construct = function(pos)
		minetest.log("error", "[mobs_mc] Trying to construct mobs_mc:arrow_box at "..minetest.pos_to_string(pos))
		minetest.remove_node(pos)
	end,
	drop = "",
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"mobs_mc:arrow_box"},
	velocity = 10,
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

--ARROW CODE
THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:get_pos()
	local node = minetest.get_node(pos)

	minetest.add_particle({
		pos = pos,
		velocity = {x=0, y=0, z=0},
		acceleration = {x=0, y=0, z=0},
		expirationtime = .3,
		size = 1,
		collisiondetection = false,
		vertical = false,
		texture = "mobs_mc_arrow_particle.png",
	})

	if self.timer>0.2 then
		local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "mobs_mc:arrow_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local damage = 3
					minetest.sound_play("damage", {pos = pos}, true)
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					self.object:remove()
				end
			else
				local damage = 3
				minetest.sound_play("damage", {pos = pos}, true)
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			minetest.sound_play("bowhit1", {pos = pos}, true)
			minetest.add_item(self.lastpos, 'mobs_mc:arrow')
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("mobs_mc:arrow_entity", THROWING_ARROW_ENTITY)

local arrows = {
	{"mobs_mc:arrow", "mobs_mc:arrow_entity" },
}

local throwing_shoot_arrow = function(itemstack, player)
	for _,arrow in ipairs(arrows) do
		if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow[1] then
			if not minetest.is_creative_enabled(player:get_player_name()) then
				player:get_inventory():remove_item("main", arrow[1])
			end
			local playerpos = player:get_pos()
			local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2])  --mc
			local dir = player:get_look_dir()
			obj:set_velocity({x=dir.x*22, y=dir.y*22, z=dir.z*22})
			obj:set_acceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
			obj:set_yaw(player:get_look_yaw()+math.pi)
			minetest.sound_play("throwing_sound", {pos=playerpos}, true)
			if obj:get_luaentity().player == "" then
				obj:get_luaentity().player = player
			end
			obj:get_luaentity().node = player:get_inventory():get_stack("main", 1):get_name()
			return true
		end
	end
	return false
end

--end maikerumine code
