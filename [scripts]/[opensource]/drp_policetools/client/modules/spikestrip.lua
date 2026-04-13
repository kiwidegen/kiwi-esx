-- client/modules/spikestrip.lua
local SpikeStripModule = {}

local spikeStrips = {}
local placementMode = false
local controlMode = false
local poppedVehicles = {}
local cachedPed = PlayerPedId()

-- Update cached ped when it changes
AddEventHandler('esx:playerPedChanged', function(newPed)
  cachedPed = newPed
end)

--- Play animation
local function playAnimation()
  local ped = PlayerPedId()
  local animDict = "anim@mp_player_intmenu@key_fob@"
  local animName = "fob_click"

  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
    Wait(10)
  end

  TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 48, 0, false, false, false)
end

--- Get the closest spike strip to the player
---@return string|nil stripId The ID of the closest strip
---@return number distance The distance to the closest strip
local function getClosestSpikeStrip()
  local coords = GetEntityCoords(cachedPed)
  local closestId = nil
  local closestDist = Config.SpikeStrip.MaxControlDistance + 1.0

  for id, data in pairs(spikeStrips) do
    local distance = #(coords - data.coords)
    if distance <= Config.SpikeStrip.MaxControlDistance and distance < closestDist then
      closestDist = distance
      closestId = id
    end
  end

  return closestId, closestDist
end

--- Pop all tires on a vehicle
---@param vehicle number The vehicle entity
local function popTires(vehicle)
  if poppedVehicles[vehicle] then
    return
  end

  poppedVehicles[vehicle] = true

  -- Pop all wheels properly (0-7 covers all standard vehicle wheels)
  for i = 0, 7 do
    SetVehicleTyreBurst(vehicle, i, true, 1000.0)
  end

  -- Remove from cooldown table after timeout
  SetTimeout(Config.SpikeStrip.VehicleCooldown, function()
    poppedVehicles[vehicle] = nil
  end)
end

local monitoringActive = false

--- Monitor only nearby vehicles for spike strip collisions when strips are active
local function startVehicleMonitor()
  CreateThread(function()
    while true do
      Wait(1000) -- Only check if we need to start monitoring

      -- Count active strips
      local activeStrips = {}
      for id, data in pairs(spikeStrips) do
        if data.active then
          table.insert(activeStrips, data)
        end
      end

      -- No active strips = no monitoring
      if #activeStrips == 0 then
        monitoringActive = false
        goto continue
      end

      -- Only check when monitoring is needed
      if not monitoringActive then
        monitoringActive = true
      end

      -- Get player vehicle and nearby vehicles only
      local ped = PlayerPedId()
      local playerCoords = GetEntityCoords(ped)
      local vehicles = {}

      -- Only check player vehicle if in one
      if IsPedInAnyVehicle(ped, false) then
        table.insert(vehicles, GetVehiclePedIsIn(ped, false))
      end

      -- Get nearby vehicles within render distance (50m)
      local allVehicles = GetGamePool('CVehicle')
      for i = 1, #allVehicles do
        local veh = allVehicles[i]
        if DoesEntityExist(veh) and #(GetEntityCoords(veh) - playerCoords) < 50.0 then
          table.insert(vehicles, veh)
        end
      end

      -- Check vehicles against active strips
      for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehCoords = GetEntityCoords(vehicle)

        for j = 1, #activeStrips do
          local stripData = activeStrips[j]
          if #(vehCoords - stripData.coords) < Config.SpikeStrip.DetectionDistance then
            popTires(vehicle)
            break
          end
        end
      end

      ::continue::
    end
  end)
end

--- Enter control mode to toggle spike strips remotely
local function enterControlMode()
  if controlMode then
    return
  end

  controlMode = true

  lib.notify({
    title = 'Control Mode',
    description = 'Press E to toggle nearest spike strip. ESC to exit.',
    type = 'info'
  })

  CreateThread(function()
    while controlMode do
      Wait(0)

      local stripId, distance = getClosestSpikeStrip()

      if not stripId then
        lib.showTextUI('[No spike strips within 50m]', {
          position = "left-center",
        })
      else
        local strip = spikeStrips[stripId]
        local status = strip.active and "Active" or "Inactive"

        lib.showTextUI(('[E] %s %.1fm'):format(status, distance), {
          position = "left-center",
        })

        if IsControlJustPressed(0, Config.SpikeStrip.ToggleKey) then
          playAnimation()
          local newState = not strip.active
          TriggerServerEvent('drp_policetools:spikestrip:toggle', stripId, newState)
          Wait(200)
        end
      end

      if IsControlJustPressed(0, 177) or IsControlJustPressed(0, 322) then
        lib.hideTextUI()
        controlMode = false
        lib.notify({
          title = 'Control Mode',
          description = 'Exited control mode',
          type = 'info'
        })
      end
    end

    lib.hideTextUI()
  end)
end

--- Enter placement mode to deploy a spike strip
local function enterPlacementMode()
  if placementMode then
    return
  end

  placementMode = true

  if not LoadModel(Config.SpikeStrip.Model) then
    lib.notify({
      title = 'Spike Strip',
      description = 'Failed to load model',
      type = 'error'
    })
    placementMode = false
    return
  end

  CreateThread(function()
    local model = joaat(Config.SpikeStrip.Model)
    local previewObj = nil

    while placementMode do
      Wait(0)

      cachedPed = PlayerPedId()
      local coords = GetEntityCoords(cachedPed)
      local heading = GetEntityHeading(cachedPed)
      local forward = GetEntityForwardVector(cachedPed)
      local spawnCoords = coords + (forward * 2.0)

      if not previewObj or not DoesEntityExist(previewObj) then
        previewObj = CreateObject(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
        SetEntityAlpha(previewObj, 150, false)
        SetEntityCollision(previewObj, false, false)
      end

      SetEntityCoordsNoOffset(previewObj, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
      SetEntityHeading(previewObj, heading)
      PlaceObjectOnGroundProperly(previewObj)

      lib.showTextUI('[E] Place Spike Strip | [ESC] Cancel', {
        position = "left-center",
      })

      if IsControlJustPressed(0, Config.SpikeStrip.DeployKey) then
        lib.hideTextUI()

        local finalCoords = GetEntityCoords(previewObj)
        local finalHeading = GetEntityHeading(previewObj)
        local finalRotation = GetEntityRotation(previewObj, 2)

        DeleteEntity(previewObj)

        TriggerServerEvent('drp_policetools:spikestrip:place', finalCoords, finalHeading, finalRotation)
        placementMode = false

        Wait(500)
        enterControlMode()
      elseif IsControlJustPressed(0, 177) then
        lib.hideTextUI()
        DeleteEntity(previewObj)
        placementMode = false

        lib.notify({
          title = 'Spike Strip',
          description = 'Placement cancelled',
          type = 'info'
        })
      end
    end

    if previewObj and DoesEntityExist(previewObj) then
      DeleteEntity(previewObj)
    end
  end)
end

--- Add a spike strip to the world
RegisterNetEvent('drp_policetools:spikestrip:add', function(id, coords, heading, rotation, active)
  local model = joaat(Config.SpikeStrip.Model)

  if not HasModelLoaded(model) then
    LoadModel(Config.SpikeStrip.Model)
  end

  local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

  if not DoesEntityExist(obj) then
    Wait(100)
  end

  FreezeEntityPosition(obj, true)
  SetEntityHeading(obj, heading)
  SetEntityRotation(obj, rotation.x, rotation.y, rotation.z, 2, true)
  PlaceObjectOnGroundProperly(obj)

  local netId = NetworkGetNetworkIdFromEntity(obj)

  spikeStrips[id] = {
    entity = obj,
    netId = netId,
    coords = coords,
    heading = heading,
    rotation = rotation,
    active = active
  }

  if active then
    SetEntityCollision(obj, true, true)
    SetEntityAlpha(obj, 255, false)
    SetEntityVisible(obj, true, false)
  else
    SetEntityCollision(obj, false, false)
    SetEntityAlpha(obj, 0, false)
    SetEntityVisible(obj, false, false)
  end

  -- Add ox_target interactions
  exports.ox_target:addLocalEntity(obj, {
    {
      name = 'toggle_spikestrip',
      icon = 'fas fa-power-off',
      label = active and 'Deactivate Spike Strip' or 'Activate Spike Strip',
      onSelect = function()
        if not IsPolice() then
          lib.notify({
            title = 'Spike Strip',
            description = 'Only police can use this',
            type = 'error'
          })
          return
        end
        playAnimation()
        local newState = not spikeStrips[id].active
        TriggerServerEvent('drp_policetools:spikestrip:toggle', id, newState)
      end
    },
    {
      name = 'pickup_spikestrip',
      icon = 'fas fa-hand-paper',
      label = 'Pick Up Spike Strip',
      onSelect = function()
        if not IsPolice() then
          lib.notify({
            title = 'Spike Strip',
            description = 'Only police can pick this up',
            type = 'error'
          })
          return
        end
        TriggerServerEvent('drp_policetools:spikestrip:removeStrip', id)
      end
    }
  })
end)

--- Update spike strip state
RegisterNetEvent('drp_policetools:spikestrip:updateState', function(id, active)
  if not spikeStrips[id] then
    return
  end

  spikeStrips[id].active = active
  local obj = spikeStrips[id].entity

  if DoesEntityExist(obj) then
    if active then
      SetEntityCollision(obj, true, true)
      SetEntityAlpha(obj, 255, false)
      SetEntityVisible(obj, true, false)
    else
      SetEntityCollision(obj, false, false)
      SetEntityAlpha(obj, 0, false)
      SetEntityVisible(obj, false, false)
    end

    -- Update ox_target label
    exports.ox_target:removeLocalEntity(obj, { 'toggle_spikestrip', 'pickup_spikestrip' })

    exports.ox_target:addLocalEntity(obj, {
      {
        name = 'toggle_spikestrip',
        icon = 'fas fa-power-off',
        label = active and 'Deactivate Spike Strip' or 'Activate Spike Strip',
        onSelect = function()
          if not IsPolice() then
            lib.notify({
              title = 'Spike Strip',
              description = 'Only police can use this',
              type = 'error'
            })
            return
          end
          playAnimation()
          local newState = not spikeStrips[id].active
          TriggerServerEvent('drp_policetools:spikestrip:toggle', id, newState)
        end
      },
      {
        name = 'pickup_spikestrip',
        icon = 'fas fa-hand-paper',
        label = 'Pick Up Spike Strip',
        onSelect = function()
          if not IsPolice() then
            lib.notify({
              title = 'Spike Strip',
              description = 'Only police can pick this up',
              type = 'error'
            })
            return
          end
          TriggerServerEvent('drp_policetools:spikestrip:removeStrip', id)
        end
      }
    })
  end
end)

--- Remove a spike strip
RegisterNetEvent('drp_policetools:spikestrip:remove', function(id)
  if spikeStrips[id] then
    local obj = spikeStrips[id].entity
    if DoesEntityExist(obj) then
      exports.ox_target:removeLocalEntity(obj, { 'toggle_spikestrip', 'pickup_spikestrip' })

      -- Get all objects attached to this entity
      local coords = GetEntityCoords(obj)
      local allObjects = GetGamePool('CObject')

      -- Delete the main object
      DeleteEntity(obj)

      -- Find and delete any nearby objects (within 5 units) that are part of the spike strip
      for i = 1, #allObjects do
        local object = allObjects[i]
        if DoesEntityExist(object) and object ~= obj then
          local objCoords = GetEntityCoords(object)
          local distance = #(coords - objCoords)

          -- If it's very close and is the spike strip model, delete it
          if distance < 5.0 then
            local model = GetEntityModel(object)
            if model == joaat(Config.SpikeStrip.Model) or model == joaat('p_ld_stinger_s') then
              DeleteEntity(object)
            end
          end
        end
      end
    end
    spikeStrips[id] = nil
  end
end)

--- Sync all spike strips from server
RegisterNetEvent('drp_policetools:spikestrip:requestSync', function(allStrips)
  for id, data in pairs(allStrips) do
    TriggerEvent('drp_policetools:spikestrip:add', id, data.coords, data.heading, data.rotation, data.active)
  end
end)

--- Export for using spike strip remote (ox_inventory)
exports('useSpikeStripRemote', function(data, slot)
  local playerData = ESX.GetPlayerData()

  if not playerData.job or not Config.PoliceJobs[playerData.job.name] then
    lib.notify({
      title = 'Spike Strip',
      description = 'Only police can use this',
      type = 'error'
    })
    return
  end

  -- If already in control mode, exit it
  if controlMode then
    lib.hideTextUI()
    controlMode = false
    lib.notify({
      title = 'Control Mode',
      description = 'Exited control mode',
      type = 'info'
    })
    return
  end

  -- Show menu
  lib.registerContext({
    id = 'drp_spikestrip_menu',
    title = 'Spike Strip Remote',
    options = {
      {
        title = 'Deploy Spike Strip',
        description = 'Place a new spike strip',
        icon = 'road',
        onSelect = function()
          enterPlacementMode()
        end
      },
      {
        title = 'Control Mode',
        description = 'Toggle nearest spike strip (50m radius)',
        icon = 'tower-control',
        onSelect = function()
          enterControlMode()
        end
      }
    }
  })

  lib.showContext('drp_spikestrip_menu')
end)

--- Module callbacks
function SpikeStripModule.OnPlayerLoaded()
  TriggerServerEvent('drp_policetools:spikestrip:getSync')
end

function SpikeStripModule.OnResourceStart()
  TriggerServerEvent('drp_policetools:spikestrip:getSync')
  startVehicleMonitor()
end

function SpikeStripModule.OnResourceStop()
  for id, data in pairs(spikeStrips) do
    if DoesEntityExist(data.entity) then
      exports.ox_target:removeLocalEntity(data.entity, { 'toggle_spikestrip', 'pickup_spikestrip' })
      DeleteEntity(data.entity)
    end
  end
end

-- Register the module
RegisterPoliceModule('spikestrip', SpikeStripModule)
