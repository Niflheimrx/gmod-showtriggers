--[[
  Author: Niflheimrx
  Description: Make non-networked trigger entities visible
					 Adds DebugTrace as a bonus
--]]

ShowTriggers = {}

-- Should we print messages out in console?
ShowTriggers.Log = false

-- Should we throw debug messages?
ShowTriggers.Debug = false

-- What color should our console messages use?
ShowTriggers.ConsoleColor = { [0] = Color( 0, 255, 0 ), [1] = Color( 255, 0, 0 ), [2] = Color( 255, 255, 0 ), [3] = Color( 0, 255, 255 ) }

-- What color should our prefixes use?
ShowTriggers.PrefixColor = Color( 142, 235, 250 )

-- What kind of entities are we going to interact with
ShowTriggers.Entities = {
  ["trigger_teleport"] = true,
  ["trigger_multiple"] = true,
  ["trigger_push"]     = true,
  ["func_*"]           = true,
}

-- Print the addon messages to console
function ShowTriggers.Notify( type, message )
  if !ShowTriggers.Log then return end
  if (type == 3) and !ShowTriggers.Debug then return end

  local prefixColor = ShowTriggers.ConsoleColor[type]
  MsgC( prefixColor, "[ShowTriggers] ", message, "\n" )
end

-- Maps that are known to not work due to memory errors
local filteredMaps = {
  ["surf_chasm"] = true,
  ["surf_velocity"] = true,
}

-- Don't load the module if the map isn't supported
if filteredMaps[game.GetMap()] then
  ShowTriggers.Notify( 2, "Disabled module due to unsupported map" )
return end

-- Start including necessary files and start the network
if SERVER then
  AddCSLuaFile "strigger/cl_showtriggers.lua"
  include "strigger/sv_showtriggers.lua"

  util.AddNetworkString "ShowTriggers"
  util.AddNetworkString "ShowTriggers_Chat"
else
  include "strigger/cl_showtriggers.lua"
end

-- We have loaded the addon!
ShowTriggers.Notify( 0, "Loaded base" )
