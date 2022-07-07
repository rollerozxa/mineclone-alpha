-- Minetest 0.4 mod: mcl_stairs
-- See README.txt for licensing and other information.

-- Global namespace for functions

mcl_stairs = {}

-- Load other files

dofile(minetest.get_modpath("mcla_stairs").."/api.lua")
dofile(minetest.get_modpath("mcla_stairs").."/cornerstair.lua")
dofile(minetest.get_modpath("mcla_stairs").."/register.lua")
dofile(minetest.get_modpath("mcla_stairs").."/crafting.lua")
dofile(minetest.get_modpath("mcla_stairs").."/alias.lua")
