local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


if minetest.get_modpath("mobs_balrog") then
dofile(modpath.."/mobs_balrog_raid.lua")
end
dofile(modpath.."/default_raids.lua")
