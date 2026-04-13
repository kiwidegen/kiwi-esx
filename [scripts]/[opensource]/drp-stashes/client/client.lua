local props = {}

--- Handle rcore_gangs integration for gang checks
---@param gangName string Gang name to check
---@param gangRank number Minimum rank required
---@return boolean hasAccess Whether player has access
local function handleRCOREGangs(gangName, gangRank)
  local gangs = exports['rcore_gang']:GetPlayerGang()
  if not gangs then return false end
  if gangs.name ~= gangName then return false end
  for k, v in pairs(gangs.members) do
    if v.identifier == ESX.PlayerData.identifier then
      if v.rankIndex >= gangRank then
        return true
      end
    end
  end
  return false
end

--- Check if player has required items
---@param items table List of item names
---@return boolean hasItems Whether player has all items
local function hasRequiredItems(items)
  local need, have = 0, 0
  for k, v in pairs(items) do
    need += 1
    if exports.ox_inventory:Search('count', v) > 0 then
      have += 1
    end
  end
  return need == have
end

--- Check if player has required identifiers
---@param identifiers table List of identifiers
---@return boolean hasIdentifier Whether player has matching identifier
local function hasRequiredIdentifier(identifiers)
  for k, v in pairs(identifiers) do
    if v == ESX.PlayerData.identifier then
      return true
    end
  end
  return false
end

--- Check if player meets all requirements to access stash
---@param data table Stash data containing requirements
---@return boolean hasAccess Whether player has access
local function check(data)
  local checks, has = 0, 0

  if not data.gang then
    checks += 1
    has += 1
  else
    checks += 1
    if GetResourceState('rcore_gangs') == 'started' then
      if handleRCOREGangs(data.gang, data.gangRank) then
        has += 1
      end
    else
      for _, gangName in pairs(data.gang) do
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == gangName and ESX.PlayerData.job2.grade >= data.gangRank then
          has += 1
          break
        end
      end
    end
  end

  if not data.job then
    checks += 1
    has += 1
  else
    checks += 1
    for _, jobName in pairs(data.job) do
      if ESX.PlayerData.job.name == jobName and ESX.PlayerData.job.grade >= data.jobRank then
        has += 1
        break
      end
    end
  end

  if not data.item then
    checks += 1
    has += 1
  else
    checks += 1
    if hasRequiredItems(data.item) then
      has += 1
    end
  end

  if not data.identifier then
    checks += 1
    has += 1
  else
    checks += 1
    if hasRequiredIdentifier(data.identifier) then
      has += 1
    end
  end

  return checks == has
end

local targets = {}

--- Check password for stash access
---@param pass string|boolean Password to check
---@param id number Stash ID
---@return boolean valid Whether password is correct
local function checkPassword(pass, id)
  if not pass or pass == false or pass == '' then
    return true
  end

  local submitPass = lib.inputDialog(locale('Interact.inputTitle'), {
    {type = 'input', label = locale('Interact.inputHeader'), description = locale('Interact.inputDesc'), required = true}
  })

  if not submitPass then
    return false
  end

  local result = lib.callback.await('drp-stashes:server:passwordCheck', false, submitPass[1], id)

  if not result then
    lib.notify({
      title = locale('Notify.wrongPass'),
      type = 'error'
    })
  end

  return result
end

--- Initialize all stash targets
local function initTargets()
  local cb = lib.callback.await('drp-stashes:server:getStashes', false)
  for k, v in pairs(cb) do
    v.loc = json.decode(v.loc)
    v.data = json.decode(v.data)

    if v.data.object then
      lib.requestModel(v.data.object)
      props[#props + 1] = CreateObject(v.data.object, v.loc.x, v.loc.y, v.loc.z, false, false, false)
      SetEntityHeading(props[#props], v.loc.w or 180.0)
      FreezeEntityPosition(props[#props], true)

      exports.ox_target:addLocalEntity(props[#props], {
        {
          label = locale('Interact.targetLabel'),
          icon = locale('Interact.targetIcon'),
          distance = 3.0,
          onSelect = function()
            local passCheck = checkPassword(v.data.password, v.id)
            if not passCheck then
              return
            end
            TriggerServerEvent('drp-stashes:server:openStash', k)
          end,
          canInteract = function()
            return check(v.data)
          end
        }
      })
    else
      exports.ox_target:addBoxZone({
        coords = vector3(v.loc.x, v.loc.y, v.loc.z),
        size = vec3(1.0, 1.0, 1.0),
        rotation = 0,
        debug = false,
        options = {
          {
            label = locale('Interact.targetLabel'),
            icon = locale('Interact.targetIcon'),
            distance = 3.0,
            onSelect = function()
              local passCheck = checkPassword(v.data.password, v.id)
              if not passCheck then
                return
              end
              TriggerServerEvent('drp-stashes:server:openStash', k)
            end,
            canInteract = function()
              return check(v.data)
            end
          }
        }
      })
      targets[#targets + 1] = 'md_stashes'..k
    end
  end
end

initTargets()

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  for k, v in pairs(props) do
    DeleteEntity(v)
  end
end)

RegisterNetEvent('drp-stashes:client:newstash', function()
  for k, v in pairs(props) do
    DeleteEntity(v)
  end
  for k, v in pairs(targets) do
    exports.ox_target:removeZone(v)
  end
  initTargets()
end)
