mcla_core = {}

-- Repair percentage for toolrepair
mcla_core.repair = 0.05

mcla_autogroup.register_diggroup("handy")
mcla_autogroup.register_diggroup("pickaxey", {
	levels = { "wood", "gold", "stone", "iron", "diamond" }
})
mcla_autogroup.register_diggroup("axey")
mcla_autogroup.register_diggroup("shovely")
mcla_autogroup.register_diggroup("shearsy")
mcla_autogroup.register_diggroup("shearsy_wool")
mcla_autogroup.register_diggroup("shearsy_cobweb")
mcla_autogroup.register_diggroup("swordy")
mcla_autogroup.register_diggroup("swordy_cobweb")

-- Load files
local modpath = minetest.get_modpath("mcla_core")
dofile(modpath.."/functions.lua")
dofile(modpath.."/nodes_base.lua") -- Simple solid cubic nodes with simple definitions
dofile(modpath.."/nodes_liquid.lua") -- Liquids
dofile(modpath.."/nodes_cactuscane.lua") -- Cactus and sugar canes
dofile(modpath.."/nodes_trees.lua") -- Tree nodes: Wood, Planks, Sapling, Leaves
dofile(modpath.."/nodes_glass.lua") -- Glass
dofile(modpath.."/nodes_climb.lua") -- Climbable nodes
dofile(modpath.."/nodes_misc.lua") -- Other and special nodes
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/crafting.lua")
