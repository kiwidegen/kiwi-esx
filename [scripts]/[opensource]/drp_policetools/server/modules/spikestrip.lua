-- server/modules/spikestrip.lua
local SpikeStripModule = {}

local spikeStrips = {}
local stripIdCounter = 0

--- Generate a unique ID for a spike strip
---@return string id The generated ID
local function generateId()
  stripIdCounter = stripIdCounter + 1
  return ('strip_%d'):format(stripIdCounter)
end

--- Handle spike strip placement
RegisterNetEvent('drp_policetools:spikestrip:place', function(coords, heading, rotation)
  local source = source

  if not IsPolice(source) then
    return
  end

  local id = generateId()

  spikeStrips[id] = {
    coords = coords,
    heading = heading,
    rotation = rotation,
    active = true,
    owner = source
  }

  TriggerClientEvent('drp_policetools:spikestrip:add', -1, id, coords, heading, rotation, true)

  TriggerClientEvent('ox_lib:notify', source, {
    title = 'Spike Strip',
    description = 'Spike strip deployed',
    type = 'success'
  })
end)

--- Handle spike strip toggle
RegisterNetEvent('drp_policetools:spikestrip:toggle', function(id, newState)
  local source = source

  if not IsPolice(source) then
    return
  end

  if not spikeStrips[id] then
    return
  end

  spikeStrips[id].active = newState

  TriggerClientEvent('drp_policetools:spikestrip:updateState', -1, id, newState)

  local stateText = newState and 'activated' or 'deactivated'
  TriggerClientEvent('ox_lib:notify', source, {
    title = 'Spike Strip',
    description = ('Spike strip %s'):format(stateText),
    type = 'info'
  })
end)

--- Handle spike strip removal
RegisterNetEvent('drp_policetools:spikestrip:removeStrip', function(id)
  local source = source

  if not IsPolice(source) then
    return
  end

  if not spikeStrips[id] then
    return
  end

  spikeStrips[id] = nil
  TriggerClientEvent('drp_policetools:spikestrip:remove', -1, id)

  TriggerClientEvent('ox_lib:notify', source, {
    title = 'Spike Strip',
    description = 'Spike strip removed',
    type = 'success'
  })
end)

--- Sync all spike strips to a player
RegisterNetEvent('drp_policetools:spikestrip:getSync', function()
  local source = source

  TriggerClientEvent('drp_policetools:spikestrip:requestSync', source, spikeStrips)
end)

--- Clean up spike strips when player disconnects
AddEventHandler('playerDropped', function()
  local source = source

  for id, data in pairs(spikeStrips) do
    if data.owner == source then
      spikeStrips[id] = nil
      TriggerClientEvent('drp_policetools:spikestrip:remove', -1, id)
    end
  end
end)

--- Module initialization
function SpikeStripModule.Init()
end

-- Register the module
RegisterPoliceModule('spikestrip', SpikeStripModule)

-- Initialize
SpikeStripModule.Init()
