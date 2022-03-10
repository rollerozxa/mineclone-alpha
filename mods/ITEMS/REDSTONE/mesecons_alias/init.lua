-- This file registers aliases for the /give /giveme commands.

minetest.register_alias("mesecons:mesecon", "mesecons:wire_00000000_off")
minetest.register_alias("mesecons:object_detector", "mesecons_detector:object_detector_off")
minetest.register_alias("mesecons:switch", "mesecons_switch:mesecon_switch_off")
minetest.register_alias("mesecons:button", "mesecons_button:button_off")
minetest.register_alias("mesecons:mesecon_torch", "mesecons_torch:mesecon_torch_on")
minetest.register_alias("mesecons:torch", "mesecons_torch:mesecon_torch_on")
minetest.register_alias("mesecons:pressure_plate_stone", "mesecons_pressureplates:pressure_plate_stone_off")
minetest.register_alias("mesecons:pressure_plate_wood", "mesecons_pressureplates:pressure_plate_wood_off")
minetest.register_alias("mesecons:mesecon_socket", "mesecons_temperest:mesecon_socket_off")
minetest.register_alias("mesecons:mesecon_inverter", "mesecons_temperest:mesecon_inverter_on")
minetest.register_alias("mesecons:delayer", "mesecons_delayer:delayer_off_1")

--Backwards compatibility
minetest.register_alias("mesecons:mesecon_off", "mesecons:wire_00000000_off")
