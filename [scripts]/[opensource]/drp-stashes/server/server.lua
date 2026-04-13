local stashes = MySQL.query.await('SELECT * FROM drpstashes', {})

--- Check if player is admin
---@param src number Player source
---@return boolean isAdmin Whether player is admin
local function isAdmin(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return false end
  return xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
end

--- Check if player has required distance to location
---@param src number Player source
---@param location vector3 Location to check
---@param maxDistance number Maximum allowed distance
---@return boolean inRange Whether player is in range
local function checkDistance(src, location, maxDistance)
  local ped = GetPlayerPed(src)
  local pedCoords = GetEntityCoords(ped)
  return #(pedCoords - location) <= maxDistance
end

--- Get player name
---@param src number Player source
---@return string name Player name
local function getPlayerName(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  return xPlayer and xPlayer.getName() or 'Unknown'
end

-- Callbacks

lib.callback.register('drp-stashes:server:verifyKey', function(source)
  return isAdmin(source)
end)

lib.callback.register('drp-stashes:server:getStashes', function(source)
  return stashes
end)

lib.callback.register('drp-stashes:server:passwordCheck', function(source, pass, id)
  local src = source

  local passWord = MySQL.query.await('SELECT * FROM drpstashes WHERE id = ?', {id})
  if passWord and not passWord[1] then
    return false
  end
  passWord = passWord[1]
  local loc = json.decode(passWord.loc)
  local location = vector3(loc.x, loc.y, loc.z)

  if not checkDistance(src, location, 3) then
    lib.logger(src, 'drp-stashes:server:passwordCheck', ('Player %s was too far from stash'):format(getPlayerName(src)), 'type:warn')
    return false
  end

  local data = json.decode(passWord.data)
  local result = data.password == pass

  -- Send lb-phone message to stash owner(s)
  if data.identifier and type(data.identifier) == 'table' then
    for _, identifier in pairs(data.identifier) do
      local target = ESX.GetPlayerFromIdentifier(identifier)
      if target then
        local playerName = getPlayerName(src)
        local locationStr = string.format('%.1f, %.1f, %.1f', location.x, location.y, location.z)

        -- Get target's phone number using lb-phone export
        local targetPhone = exports['lb-phone']:GetEquippedPhoneNumber(identifier)

        if targetPhone then
          if result then
            -- Successful access - send message via lb-phone
            exports['lb-phone']:SendMessage('Demon Security', targetPhone, '🔓 STASH ALERT - ' .. playerName .. ' accessed your stash "' .. passWord.name .. '" at ' .. locationStr)
          else
            -- Wrong PIN security alert
            exports['lb-phone']:SendMessage('Demon Security', targetPhone, '⚠️ SECURITY ALERT - someone is trying to break in to your stash!')
          end
        end
      end
    end
  end

  return result
end)

lib.callback.register('drp-stashes:server:gotoLoc', function(source, data)
  local src = source
  if not isAdmin(src) then return false end
  local loc = json.decode(data.loc)
  local location = vector3(loc.x, loc.y, loc.z)

  SetEntityCoords(GetPlayerPed(src), location.x, location.y, location.z, false, false, false, false)
  return true
end)

-- Events

RegisterNetEvent('drp-stashes:server:createStash', function(data)
  local src = source
  if not isAdmin(src) then return false end

  MySQL.insert('INSERT INTO drpstashes SET loc = ?, name = ?, data = ?', {
    json.encode(data.coords),
    data.data.name,
    json.encode(data.data)
  })

  Wait(100)
  stashes = MySQL.query.await('SELECT * FROM drpstashes', {})
  TriggerClientEvent('drp-stashes:client:newstash', -1)
end)

RegisterNetEvent('drp-stashes:server:saveEdit', function(data)
  local src = source
  if not isAdmin(src) then return false end

  if not data or not data.form or not data.id then
    return
  end

  local formData = data.form
  local oldData = data.id

  if not oldData.data then
    return
  end

  -- Decode oldData.data if it's a string
  if type(oldData.data) == 'string' then
    oldData.data = json.decode(oldData.data)
  end

  -- Preserve the object if it exists
  if oldData.data and oldData.data.object then
    formData.object = oldData.data.object
  end

  MySQL.update('UPDATE drpstashes SET name = ?, data = ? WHERE id = ?', {
    formData.name,
    json.encode(formData),
    oldData.id
  })

  Wait(100)
  stashes = MySQL.query.await('SELECT * FROM drpstashes', {})
  TriggerClientEvent('drp-stashes:client:newstash', -1)
end)

RegisterNetEvent('drp-stashes:server:changeLocation', function(data)
  local src = source
  if not isAdmin(src) then return false end
  local id = data.id.id
  local loc = data.loc.coords

  MySQL.update('UPDATE drpstashes SET loc = ? WHERE id = ?', {json.encode(loc), id})

  Wait(100)
  stashes = MySQL.query.await('SELECT * FROM drpstashes', {})
  TriggerClientEvent('drp-stashes:client:newstash', -1)
end)

RegisterNetEvent('drp-stashes:server:deleteStash', function(data)
  local src = source
  if not isAdmin(src) then return false end
  local id = data.id

  MySQL.update('DELETE FROM drpstashes WHERE id = ?', {id})

  Wait(100)
  stashes = MySQL.query.await('SELECT * FROM drpstashes', {})
  TriggerClientEvent('drp-stashes:client:newstash', -1)
end)

--- Handle rcore_gangs integration for gang checks
---@param src number Player source
---@param gangName string Gang name to check
---@param gangRank number Minimum rank required
---@return boolean hasAccess Whether player has access
local function handleRCOREGangs(src, gangName, gangRank)
  local gangs = exports['rcore_gang']:GetPlayerGang()
  if not gangs then return false end
  if gangs.name ~= gangName then return false end
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return false end

  for k, v in pairs(gangs.members) do
    if v.identifier == xPlayer.identifier then
      if v.rankIndex >= gangRank then
        return true
      end
    end
  end
  return false
end

--- Check if player meets all allowance requirements
---@param src number Player source
---@param data table Stash data containing requirements
---@return boolean allowed Whether player is allowed
local function checkAllowance(src, data)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return false end

  local checks, has = 0, 0

  if not data.gang then
    checks += 1
    has += 1
  else
    checks += 1
    if GetResourceState('rcore_gangs') == 'started' then
      if handleRCOREGangs(src, data.gang, data.gangRank) then
        has += 1
      end
    else
      for _, gangName in pairs(data.gang) do
        if xPlayer.job2 and xPlayer.job2.name == gangName and xPlayer.job2.grade >= data.gangRank then
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
      if xPlayer.job.name == jobName and xPlayer.job.grade >= data.jobRank then
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
    local need, have = 0, 0
    for k, v in pairs(data.item) do
      need += 1
      if exports.ox_inventory:Search(src, 'count', v) > 0 then
        have += 1
      end
    end
    if need == have then
      has += 1
    end
  end

  if not data.identifier then
    checks += 1
    has += 1
  else
    checks += 1
    for _, identifier in pairs(data.identifier) do
      if xPlayer.identifier == identifier then
        has += 1
        break
      end
    end
  end

  return checks == has
end

RegisterNetEvent('drp-stashes:server:openStash', function(id)
  local src = source

  local stashData = stashes[id]
  if not stashData then
    return
  end

  local loc = json.decode(stashData.loc)
  local location = vector3(loc.x, loc.y, loc.z)

  if not checkDistance(src, location, 3) then
    lib.logger(src, 'drp-stashes:server:openStash', ('Player %s was too far from stash'):format(getPlayerName(src)), 'type:warn')
    return
  end

  local data = json.decode(stashData.data)

  if not checkAllowance(src, data) then
    lib.notify(src, {
      title = locale('Notify.noAccess'),
      type = 'error'
    })
    return
  end

  -- Send lb-phone message to stash owner(s) when accessed
  if data.identifier and type(data.identifier) == 'table' then
    for _, identifier in pairs(data.identifier) do
      local target = ESX.GetPlayerFromIdentifier(identifier)
      if target and target.source ~= src then  -- Don't notify if owner is accessing their own stash
        local playerName = getPlayerName(src)
        local locationStr = string.format('%.1f, %.1f, %.1f', location.x, location.y, location.z)

        -- Get target's phone number using lb-phone export
        local targetPhone = exports['lb-phone']:GetEquippedPhoneNumber(identifier)

        if targetPhone then
          exports['lb-phone']:SendMessage('Demon Security', targetPhone, '🔓 STASH ALERT - ' .. playerName .. ' accessed your stash "' .. stashData.name .. '" at ' .. locationStr)
        end
      end
    end
  end

  -- Register the stash with ox_inventory
  exports.ox_inventory:RegisterStash(stashData.name, stashData.name, data.slots or StashesConfig.Defaults.slots, data.maxWeight or StashesConfig.Defaults.maxWeight, false)

  exports.ox_inventory:forceOpenInventory(src, 'stash', stashData.name)
end)

-- Commands

if StashesConfig.OldData then
  lib.addCommand('ADjustStashes', {
    help = 'Adjust old stash data to new format',
    restricted = 'group.admin'
  }, function(source, args, raw)
    local src = source
    local originalData = MySQL.query.await('SELECT * FROM drpstashes', {})

    for i = 1, #originalData do
      local data = json.decode(originalData[i].data)
      local slots = tonumber(data.slots) or StashesConfig.Defaults.slots
      local weight = tonumber(data.weight) or StashesConfig.Defaults.maxWeight
      local job, gang, citizenid, item = {}, {}, {}, {}

      data.slots = slots
      data.maxWeight = weight

      if data.password == 0 or data.password == '0' or not data.password then
        data.password = false
      end

      if data.citizenid then
        if type(data.citizenid) == 'string' then
          citizenid[#citizenid + 1] = data.citizenid
          data.identifier = citizenid
          data.citizenid = nil
        end
      end

      if data.job then
        if type(data.job) == 'string' then
          job[#job + 1] = data.job
          data.job = job
          if data.rank then
            data.jobRank = data.rank
          else
            data.jobRank = 0
          end
        end
      end

      if data.gang then
        if type(data.gang) == 'string' then
          gang[#gang + 1] = data.gang
          data.gang = gang
          if data.rank then
            data.gangRank = data.rank
          else
            data.gangRank = 0
          end
        end
      end

      if data.item then
        if type(data.item) == 'string' then
          item[#item + 1] = data.item
          data.item = item
        end
      end

      data.targetlabel = nil
      data.rank = nil
      data.name = originalData[i].name

      MySQL.update('UPDATE drpstashes SET data = ? WHERE id = ?', {json.encode(data), originalData[i].id})
      Wait(10)
    end
  end)
end

lib.addCommand('newStash', {
  help = 'Create a new stash',
  restricted = 'group.admin'
}, function(source, args, raw)
  local src = source
  TriggerClientEvent('drp-stashes:client:startNew', src)
end)

lib.addCommand('editStash', {
  help = 'Edit an existing stash',
  restricted = 'group.admin'
}, function(source, args, raw)
  local src = source
  TriggerClientEvent('drp-stashes:client:editStash', src)
end)

lib.addCommand('testStashNotify', {
  help = 'Test stash notifications - Usage: /testStashNotify [stashId] [wrong]',
  restricted = 'group.admin',
  params = {
    {name = 'stashId', help = 'Stash ID to test', type = 'number'},
    {name = 'type', help = 'Type: "wrong" for wrong PIN, "success" for correct PIN', type = 'string', optional = true}
  }
}, function(source, args, raw)
  local src = source
  local stashId = args.stashId
  local testType = args.type or 'success'

  local stashData = MySQL.query.await('SELECT * FROM drpstashes WHERE id = ?', {stashId})
  if not stashData or not stashData[1] then
    lib.notify(src, {
      title = 'Error',
      description = 'Stash not found with ID: ' .. stashId,
      type = 'error'
    })
    return
  end

  local stash = stashData[1]
  local loc = json.decode(stash.loc)
  local locationStr = string.format('%.1f, %.1f, %.1f', loc.x, loc.y, loc.z)
  local playerName = getPlayerName(src)

  -- Get player's phone number using lb-phone export
  local myPhone = exports['lb-phone']:GetEquippedPhoneNumber(src)

  if not myPhone then
    lib.notify(src, {
      title = 'Error',
      description = 'Could not get your phone number. Make sure you have a phone equipped.',
      type = 'error'
    })
    return
  end

  if testType == 'wrong' then
    -- Test wrong PIN security alert
    exports['lb-phone']:SendMessage('Demon Security', myPhone, '⚠️ SECURITY ALERT - someone is trying to break in to your stash!')
    lib.notify(src, {
      title = 'Test Sent',
      description = 'Check your phone messages from Demon Security',
      type = 'success'
    })
  else
    -- Test successful access
    exports['lb-phone']:SendMessage('Demon Security', myPhone, '🔓 STASH ALERT - ' .. playerName .. ' accessed your stash "' .. stash.name .. '" at ' .. locationStr)
    lib.notify(src, {
      title = 'Test Sent',
      description = 'Check your phone messages from Demon Security',
      type = 'success'
    })
  end
end)
