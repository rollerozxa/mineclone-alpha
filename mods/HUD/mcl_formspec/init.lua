mcla_formspec = {}

function mcla_formspec.get_itemslot_bg(x, y, w, h)
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .."image["..x+i..","..y+j..";1,1;mcla_formspec_itemslot.png]"
		end
	end
	return out
end

minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend(mcla_vars.gui_nonbg .. mcla_vars.gui_bg_color .. mcla_vars.gui_bg_img)
end)

-- Simple formspec wrapper that does variable substitution.
function mcla_formspec.formspec_wrapper(formspec, variables)
	local retval = formspec

	for k,v in pairs(variables) do
		retval = retval:gsub("${"..k.."}", v)
	end

	return retval
end
