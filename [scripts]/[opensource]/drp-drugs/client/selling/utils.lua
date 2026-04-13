--- Shared utility functions for drug selling

--- Debug print helper
---@param message string Debug message
function debugPrint(message)
  if Config and Config.Debug then
    print('^3[DRP-DRUGS DEBUG]^7 ' .. message)
  end
end

--- Debug notification helper
---@param message string Debug notification message
function debugNotify(message)
  if Config and Config.Debug then
    lib.notify({
      title = 'DEBUG',
      description = message,
      type = 'inform',
      duration = 3000
    })
  end
end

--- Draw 3D text at coordinates
---@param coords vector3 World coordinates
---@param text string Text to display
function draw3DText(coords, text)
  local onScreen, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z)

  if onScreen then
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(screenX, screenY)
  end
end

--- Enumerate all peds in the world
---@return function iterator Ped iterator
function EnumeratePeds()
  return coroutine.wrap(function()
    local handle, ped = FindFirstPed()
    local success

    repeat
      coroutine.yield(ped)
      success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)
  end)
end

--- Check if table contains value
---@param tbl table Table to search
---@param val any Value to find
---@return boolean contains Whether value is in table
function table.contains(tbl, val)
  for _, v in ipairs(tbl) do
    if v == val then
      return true
    end
  end
  return false
end
