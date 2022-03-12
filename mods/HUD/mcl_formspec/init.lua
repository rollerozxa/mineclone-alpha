mcl_formspec = {}

function mcl_formspec.get_itemslot_bg(x, y, w, h)
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .."image["..x+i..","..y+j..";1,1;mcl_formspec_itemslot.png]"
		end
	end
	return out
end

minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend(mcl_vars.gui_nonbg .. mcl_vars.gui_bg_color .. mcl_vars.gui_bg_img)
end)
