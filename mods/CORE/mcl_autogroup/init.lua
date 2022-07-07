--[[
This is one part of a mod to replicate the digging times from Minecraft.  This
part only exposes a function to register digging groups.  The rest of the mod is
implemented and documented in the _mcla_autogroup.

The mod is split up into two parts, mcla_autogroup and _mcla_autogroup.
mcl_autogroup contains the API functions used to register custom digging groups.
_mcla_autogroup contains most of the code.  The leading underscore in the name
"_mcla_autogroup" is used to force Minetest to load that part of the mod as late
as possible.  Minetest loads mods in reverse alphabetical order.
--]]
mcl_autogroup = {}
mcl_autogroup.registered_diggroups = {}

assert(minetest.get_modpath("_mcla_autogroup"), "This mod requires the mod _mcla_autogroup to function")

-- Register a group as a digging group.
--
-- Parameters:
-- group - Name of the group to register as a digging group
-- def - Table with information about the diggroup (defaults to {} if unspecified)
--
-- Values in def:
-- level - If specified it is an array containing the names of the different
--         digging levels the digging group supports.
function mcl_autogroup.register_diggroup(group, def)
	mcl_autogroup.registered_diggroups[group] = def or {}
end
