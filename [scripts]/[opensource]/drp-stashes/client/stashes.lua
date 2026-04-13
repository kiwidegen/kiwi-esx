local create = {}

--- Round number to specified decimal places
---@param num number Number to round
---@param decimals number Number of decimal places
---@return number rounded Rounded number
local function decimalRound(num, decimals)
  local mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

--- Convert rotation to direction vector
---@param rotation vector3 Rotation vector
---@return vector3 direction Direction vector
local function RotationToDirection(rotation)
  local adjustedRotation = {
    x = (math.pi / 180) * rotation.x,
    y = (math.pi / 180) * rotation.y,
    z = (math.pi / 180) * rotation.z
  }
  local direction = {
    x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
    y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
    z = math.sin(adjustedRotation.x)
  }
  return vector3(direction.x, direction.y, direction.z)
end

--- Perform raycast from camera
---@return boolean hit Whether raycast hit something
---@return vector3 endCoords Coordinates of hit point
---@return vector3 surfaceNormal Surface normal at hit point
---@return number matHash Material hash
local function raycast()
  local camCoord = GetGameplayCamCoord()
  local camRot = GetGameplayCamRot(0)
  local camForward = RotationToDirection(camRot)
  local destination = camCoord + (camForward * 100.0)
  local handle = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0)
  local _, hit, endCoords, surfaceNormal, matHash = GetShapeTestResult(handle)
  return hit == 1, endCoords, surfaceNormal, matHash
end

--- Start raycast placement mode
---@param data table Placement data
---@return table|nil coords Placement coordinates or nil if cancelled
local function StartRay(data)
  local run = true
  if data.type == 'object' then
    local heading = 180.0
    local created = false
    local obj = data.object
    local coord = GetEntityCoords(PlayerPedId())
    lib.requestModel(obj)
    local entity = CreateObject(obj, coord.x, coord.y, coord.z, false, false)

    repeat
      local hit, endCoords, surfaceNormal, matHash = raycast()
      if not created then
        created = true
        lib.showTextUI(locale('Interact.drawTextobj'))
      else
        SetEntityCoords(entity, endCoords.x, endCoords.y, endCoords.z)
        SetEntityHeading(entity, heading)
        SetEntityCollision(entity, false, false)
        SetEntityAlpha(entity, 100)
      end

      if IsControlPressed(0, 174) then
        heading -= 2
      end

      if IsControlPressed(0, 175) then
        heading += 2
      end

      if IsControlPressed(0, 38) then
        lib.hideTextUI()
        run = false
        DeleteEntity(entity)
        return {
          coords = {
            x = decimalRound(endCoords.x, 2),
            y = decimalRound(endCoords.y, 2),
            z = decimalRound(endCoords.z, 2),
            w = decimalRound(heading, 2)
          },
          object = obj
        }
      end

      if IsControlPressed(0, 178) then
        lib.hideTextUI()
        run = false
        DeleteEntity(entity)
        return nil
      end

      Wait(1)
    until run == false
  else
    repeat
      local wait = 1
      local hit, endCoords, surfaceNormal, matHash = raycast()
      lib.showTextUI(locale('Interact.drawTextCoords', decimalRound(endCoords.x, 2), decimalRound(endCoords.y, 2), decimalRound(endCoords.z, 2)))
      DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255, 255, 255, false, true, 2, nil, nil, false, false)

      if IsControlPressed(0, 38) then
        lib.hideTextUI()
        run = false
        return {
          coords = {
            x = decimalRound(endCoords.x, 2),
            y = decimalRound(endCoords.y, 2),
            z = decimalRound(endCoords.z, 2)
          },
          object = false
        }
      end

      if IsControlPressed(0, 178) then
        lib.hideTextUI()
        run = false
        return nil
      end

      Wait(wait)
    until run == false
  end
end

-- NUI Callbacks

RegisterNUICallback('hideUI', function(_, cb)
  cb({})
  SetNuiFocus(false, false)
end)

RegisterNUICallback('createStash', function(data, cb)
  cb('ok')
  if not create.coords then
    return
  end
  for k, v in pairs(data) do
    create.data[k] = v
  end
  TriggerServerEvent('drp-stashes:server:createStash', {data = create.data, coords = create.coords})
  SetNuiFocus(false, false)
  create = {}
end)

RegisterNUICallback('submitSelection', function(data, cb)
  cb('ok')
  SetNuiFocus(false, false)
  local coords = StartRay(data)
  if not coords then
    return
  end
  create.coords = coords.coords
  create.data = {}
  create.data.object = coords.object
  SendNUIMessage({
    action = 'setVisible',
    data = true
  })
  SetNuiFocus(true, true)
end)

RegisterNUICallback('initUi', function(_, cb)
  cb({
    Config = StashesConfig.Objects,
    lang = Lang,
    defaults = StashesConfig.Defaults
  })
end)

RegisterNetEvent('drp-stashes:client:startNew', function()
  local check = lib.callback.await('drp-stashes:server:verifyKey', false)
  if not check then return end
  SendNUIMessage({action = 'firstMenu'})
  SetNuiFocus(true, true)
end)

-- Delete and Goto Stash

RegisterNUICallback('deleteStash', function(data, cb)
  TriggerServerEvent('drp-stashes:server:deleteStash', data)
  SetNuiFocus(false, false)
  cb('ok')
end)

RegisterNUICallback('gotoLoc', function(data, cb)
  SetNuiFocus(false, false)
  local check = lib.callback.await('drp-stashes:server:gotoLoc', false, data)
  if not check then return end
  cb('ok')
end)

-- Edit

RegisterNUICallback('editStash', function(data, cb)
  SendNUIMessage({
    action = 'setEditable',
    data = data
  })
  cb('ok')
end)

RegisterNUICallback('changeLocation', function(data, cb)
  cb('ok')
  SetNuiFocus(false, false)
  local handle = {}
  local objCheck = json.decode(data.data)
  if not objCheck.object then
    handle = {type = 'coords'}
  else
    handle = {type = 'object', object = objCheck.object}
  end
  local coords = StartRay(handle)
  if not coords then
    return
  end
  TriggerServerEvent('drp-stashes:server:changeLocation', {id = data, loc = coords})
end)

RegisterNUICallback('saveEdit', function(data, cb)
  TriggerServerEvent('drp-stashes:server:saveEdit', data)
  SetNuiFocus(false, false)
  cb('ok')
end)

RegisterNetEvent('drp-stashes:client:editStash', function()
  local check = lib.callback.await('drp-stashes:server:verifyKey', false)
  if not check then return end
  local stashData = lib.callback.await('drp-stashes:server:getStashes', false)
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = 'editMenu',
    data = stashData
  })
end)
