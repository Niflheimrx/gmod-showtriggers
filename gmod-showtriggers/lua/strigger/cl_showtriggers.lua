-- Handle Debug Trace
ShowTriggers.DebugTrace = false

-- Font Setup, using a font from Flow's Gamemode
surface.CreateFont( "ShowTriggersFont", { size = 22, weight = 800, font = "Tahoma" } )

-- Handle what we receive from net
local function NetHandler()
  local wantsIndex = net.ReadBool()
  if wantsIndex then
    local data = net.ReadTable()
    if !data then
      ShowTriggers.Notify( 1, "Failed to read data from ShowTriggers" )
    return end

    ShowTriggers.ReceiveIndex( data )
  else
    ShowTriggers.ToggleDebugTrace()
  end
end
net.Receive( "ShowTriggers", NetHandler )

local function PrintChat( message )
  chat.AddText( ShowTriggers.PrefixColor, "[ShowTriggers] - ", color_white, message )
end

-- Handle net messages
local function NetMessage()
  local message = net.ReadString()
  if !message then
    ShowTriggers.Notify( 1, "Failed to read message from ShowTriggers" )
  end

  PrintChat( message )
end
net.Receive( "ShowTriggers_Chat", NetMessage )

-- Setup variables and filter
local traceData = ""
local tracePos = Vector( 0, 0, 0 )
local traceIndex = {}
local currentIndex = 0

local varFilter = {
  ["worldspawn"]       = true,
  ["trigger_teleport"] = true,
  ["trigger_multiple"] = true,
  ["trigger_push"]     = true,
  ["func_rotating"]    = true,
  ["func_lod"]         = true,
  ["func_breakable"]   = true,
  ["func_door"]        = true,
}

local ts, tal, tac = tostring, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER

-- Find entities when using DebugTrace
local function DebugTrace()
  if !ShowTriggers.DebugTrace then traceData = "" traceInfo = "" return end

  local tr        = LocalPlayer():GetEyeTrace()
  local startPos  = tr.StartPos
  local ray       = tr.HitPos - startPos

  for _,ent in pairs( ents.GetAll() ) do
    if !varFilter[ent:GetClass()] then continue end

    local mins, maxs = ent:GetModelBounds()
    local angle = ent:GetAngles()
    local hitPos  = util.IntersectRayWithOBB( startPos, ray, ent:GetPos(), angle, mins, maxs )
    if hitPos then
      traceData = ent
      tracePos = ent:GetPos() or Vector( 0, 0, 0 )
      currentIndex = 0

      for index, reference in pairs( traceIndex ) do
        if (tracePos == reference) then
          currentIndex = index
        end
      end
    end
  end
end

-- Show info when using DebugTrace
local function DebugTracePaint()
  if !ShowTriggers.DebugTrace then return end

  local formattedPos = util.TypeToString( tracePos )

  local traceString = "debug trace: " .. ts( traceData )
  local tracePosString = "stats: [pos: " .. ts(formattedPos) .. "] [index: " .. currentIndex .. "]"

  local xPos = ScrW() / 6
  local yPos = ScrH() / 3

  draw.SimpleText( traceString, "ShowTriggersFont", xPos, yPos, Color(255, 255, 255), tal, tac )
  draw.SimpleText( tracePosString, "ShowTriggersFont", xPos, yPos + 32, Color(255, 255, 255), tal, tac )
end

-- Toggle DebugTrace
function ShowTriggers.ToggleDebugTrace()
  ShowTriggers.DebugTrace = !ShowTriggers.DebugTrace

  local debugStatus = ShowTriggers.DebugTrace and "enabled" or "disabled"
  if (debugStatus == "enabled") then
    hook.Add( "Think", "ShowTriggers.DebugTrace", DebugTrace )
    hook.Add( "HUDPaint", "ShowTriggers.PaintDebugTrace", DebugTracePaint )
  else
    hook.Remove( "HUDPaint", "ShowTriggers.PaintDebugTrace" )
    hook.Remove( "Think", "ShowTriggers.DebugTrace" )
  end

  PrintChat( "The debug tracer has been " .. debugStatus )
end

-- Receive hammerids from entities
function ShowTriggers.ReceiveIndex( indexes )
  if !indexes then return end

  traceIndex = indexes
  ShowTriggers.Notify( 3, "Received entity index references for ShowTriggers" )
end
