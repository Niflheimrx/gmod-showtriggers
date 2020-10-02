
local indexData = {}

-- Send a message to the client
function ShowTriggers.SendMessage( ply, message )
  if !ply or !IsValid( ply ) then
    ShowTriggers.Notify( 1, "Failed to send a message to a client because the entity doesn't exist" )
  return end

  if !message then
    ShowTriggers.Notify( 1, "Failed to send a message to a client because the message is empty" )
  return end

  net.Start "ShowTriggers_Chat"
    net.WriteString( message )
  net.Send( ply )
end

function ShowTriggers.SendIndex( ply )
  if !ply or !IsValid( ply ) then
    ShowTriggers.Notify( 1, "Failed to send index data to a client because the entity doesn't exist" )
  return end

  net.Start "ShowTriggers"
    net.WriteBool( true )
    net.WriteTable( indexData )
  net.Send( ply )
end

function ShowTriggers.SendTrace( ply )
  if !ply or !IsValid( ply ) then
    ShowTriggers.Notify( 1, "Failed to send trace data to a client because the entity doesn't exist" )
  return end

  ply.DebugTrace = !ply.DebugTrace
  ply.ShowTriggers = {
    ["trigger_teleport"]  = !ply.DebugTrace,
    ["trigger_multiple"]  = !ply.DebugTrace,
    ["trigger_push"]      = !ply.DebugTrace,
  }

  ply.ShowingAllTriggers = true

  ShowTriggers.Toggle( ply, { "trigger_teleport" } )
  ShowTriggers.Toggle( ply, { "trigger_multiple" } )
  ShowTriggers.Toggle( ply, { "trigger_push" } )

  ply.ShowingAllTriggers = false

  net.Start "ShowTriggers"
    net.WriteBool( false )
  net.Send( ply )
end

-- Toggle the visibility of a specific class
function ShowTriggers.Toggle( ply, class )
  -- Flow sends the class as a table rather than a string, lets fix that
  if istable( class ) then
    class = class[1]
  end

  -- Toggle trigger_teleport instead when we don't provide an argument
  if !class then class = "trigger_teleport" else class = string.lower( class ) end

  -- If we don't have a valid entity to toggle, don't do anything with it
  if !ShowTriggers.Entities[class] then
    ShowTriggers.SendMessage( ply, "You need to specify the correct class to use this" )
  return end

  -- Toggle the visibility of the class
  ply.ShowTriggers[class] = !ply.ShowTriggers[class]

  -- Start/Stop transmiting the entity
  for _,ent in ipairs( ents.FindByClass( class ) ) do
    ent:SetPreventTransmit( ply, !ply.ShowTriggers[class] )
  end

  -- Doing this for the tracer, it has to enable all entities in order to work properly
  if !ply.ShowingAllTriggers then
    local chatStatus = (ply.ShowTriggers[class] and "ON" or "OFF")
    ShowTriggers.SendMessage( ply, class .. " set to " .. chatStatus )
  end
end

local function HandleEntity()
  local count = 0
  indexData = {}

  for key,_ in pairs( ShowTriggers.Entities ) do
    for _,ent in ipairs( ents.FindByClass( key ) ) do
      ent:SetNoDraw( false )

      count = count + 1

      local index = ent:MapCreationID()
      indexData[index] = ent:GetPos()
    end
  end

  ShowTriggers.Notify( 3, "Made entities visible [Amount: " .. count .. "]" )
end
hook.Add( "InitPostEntity", "ShowTriggers.HandleEntity", HandleEntity )

-- Make entities invisible when a player joins
local function HandleSpawn( ply )
  -- No skynet
  if ply:IsBot() then return end

  -- Create a table that toggles the visibility state of trigger_* entities
  ply.ShowTriggers = {
    ["trigger_teleport"]  = false,
    ["trigger_multiple"]  = false,
    ["trigger_push"]      = false,
  }

  for key,_ in pairs( ply.ShowTriggers ) do
    for _,ent in ipairs( ents.FindByClass( key ) ) do
      ent:SetPreventTransmit( ply, true )
    end
  end

  ShowTriggers.SendIndex( ply )
  ShowTriggers.Notify( 3, "Made entities invisible for player [User: " .. ply:Name() .. "]" )
end
hook.Add( "PlayerInitialSpawn", "ShowTriggers.HandleSpawn", HandleSpawn )

local function HandleCommand( ply, text )
  local isCommand = string.StartWith( text, "!" )
  if !isCommand then return end

  local varArgs = string.Explode( " ", text )
  local class = varArgs and varArgs[2]

  local isShowingTrigger = varArgs and (varArgs[1] == "!showtrigger") or (text == "!showtrigger")
  local isShowingTracer  = varArgs and (varArgs[1] == "!debugtrace") or (text == "!debugtrace")

  if isShowingTrigger then
    ShowTriggers.Toggle( ply, class )
    return ""
  elseif isShowingTracer then
    ShowTriggers.SendTrace( ply )
    return ""
  end
end
hook.Add( "PlayerSay", "ShowTriggers.HandleCommand", HandleCommand )

-- If we are running a compatible gamemode, use those handlers instead
local function RegisterCommands()
  -- Are we running compatible gamemodes?
  ShowTriggers.RunsFlow = _C or Core
  if !ShowTriggers.RunsFlow then return end

  -- Since we are running Flow, we no longer need to use the built-in addon chat handler
  hook.Remove( "PlayerSay", "ShowTriggers.HandleCommand" )

  -- Both Flow v7.26 and v8.42 share the same command structure, determine what version we are running
  local isSL, isPG = Command and Command.Functions, Core and Core.AddCmd
  if !isSL and !isPG then
    ShowTriggers.Notify( 1, "Failed to add command due to invalid Flow gamemode version" )
  return end

  -- Have to do it this way because only pG's gamemode has an easy way to add commands
  if isSL then
    Command:Register( "showtrigger", ShowTriggers.Toggle )
    Command:Register( "debugtrace", ShowTriggers.SendTrace )
  elseif isPG then
    Core.AddCmd( "showtrigger", ShowTriggers.Toggle )
    Core.AddCmd( "debugtrace", ShowTriggers.SendTrace )
  end

  ShowTriggers.Notify( 3, "Registered commands for Flow Network" )
end
hook.Add( "InitPostEntity", "ShowTriggers.RegisterCommands", RegisterCommands )
