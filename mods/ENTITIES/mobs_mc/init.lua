--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local path = minetest.get_modpath("mobs_mc")

mobs_mc = {}

-- For utility functions
mobs_mc.tools = {}

--MOB ITEMS SELECTOR SWITCH
dofile(path .. "/0_gameconfig.lua")

-- Bow, arrow and throwables
dofile(path .. "/2_throwing.lua")

-- Shared functions
dofile(path .. "/3_shared.lua")

dofile(path .. "/5_spawn_abm_check.lua")

-- Animals
dofile(path .. "/chicken.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/cow.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/pig.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/sheep.lua") -- Mesh and animation by Pavel_S

--Monsters
dofile(path .. "/creeper.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/skeleton.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/zombie.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/slime.lua") -- Wuzzy
dofile(path .. "/spider.lua") -- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)
--NOTES:
--
--[[
COLISIONBOX in minetest press f5 to see where you are looking at then put these wool collor nodes on the ground in direction of north/east/west... to make colisionbox editing easier
#1west-pink/#2down/#3south-blue/#4east-red/#5up/#6north-yelow
{-1, -0.5, -1, 1, 3, 1}, Right, Bottom, Back, Left, Top, Front
--]]
--
--
