if not StashesConfig.UseBackpacks then return end

--- Vendor locations for backpack purchases
local vendorLocation = {
  {loc = vector4(2557.458, 382.282, 108.622, 356.09), ped = 'ig_priest'},
}

--- Available backpack items with their properties
local itemList = {
  small_backpack = {
    price = 1000,
    slots = 15,
    maxweight = 25000,
    allowStashInside = false,
  },
  medium_backpack = {
    price = 2500,
    slots = 30,
    maxweight = 50000,
    allowStashInside = false,
  },
  large_backpack = {
    price = 5000,
    slots = 55,
    maxweight = 120000,
    allowStashInside = false,
  },
}

--- Check if player has required distance to location
---@param src number Player source
---@param location vector4 Location to check
---@param maxDistance number Maximum allowed distance
---@return boolean inRange Whether player is in range
local function checkDistance(src, location, maxDistance)
  local ped = GetPlayerPed(src)
  local pedCoords = GetEntityCoords(ped)
  return #(pedCoords - vector3(location.x, location.y, location.z)) <= maxDistance
end

--- Get player name
---@param src number Player source
---@return string name Player name
local function getPlayerName(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  return xPlayer and xPlayer.getName() or 'Unknown'
end

lib.callback.register('drp-stashes:server:getVendors', function(source)
  return vendorLocation
end)

lib.callback.register('drp-stashes:server:getBackpacks', function(source, loc)
  local src = source
  if not checkDistance(src, vendorLocation[loc].loc, 3) then
    lib.logger(src, 'drp-stashes:server:getBackpacks', ('Player %s was too far from vendor'):format(getPlayerName(src)), 'type:warn')
    return {}
  end
  return itemList
end)

--- Generate unique ID for backpack
---@return string uniqueId Generated unique ID
local function generateUniqueId()
  local allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  local idLength = 16
  local uniqueId = ''
  math.randomseed(os.time())
  for i = 1, idLength do
    local randomIndex = math.random(1, #allowedChars)
    uniqueId = uniqueId .. allowedChars:sub(randomIndex, randomIndex)
  end
  return uniqueId
end

--- Create useable items for backpacks
for k, v in pairs(itemList) do
  ESX.RegisterUsableItem(k, function(source, item)
    local src = source
    if not item then return end

    local stashName = item.metadata?.stashName or item.info?.stashName
    if not stashName then return end

    exports.ox_inventory:forceOpenInventory(src, 'stash', stashName)
  end)
end

--- Get items that should not be allowed inside backpacks
---@return table refuseList Table of item names to refuse
local function refuse()
  local itemToRefuse = {}
  for k, v in pairs(itemList) do
    if not v.allowStashInside then
      itemToRefuse[k] = true
    end
  end
  return itemToRefuse
end

--- Filter inventory patterns for restricted items
---@return table filterList List of filter patterns
local function filterInv()
  local refuseString = {}
  for k, v in pairs(itemList) do
    if not v.allowStashInside then
      refuseString[#refuseString + 1] = '^' .. k .. '[%w]+'
    end
  end
  return refuseString
end

if GetResourceState('ox_inventory') == 'started' then
  local hookId = exports.ox_inventory:registerHook('swapItems', function(payload)
    return false
  end, {
    print = true,
    itemFilter = refuse(),
    inventoryFilter = filterInv()
  })
end

RegisterNetEvent('drp-stashes:server:buyBackpack', function(loc, itemName, type)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return end
  if not itemList[itemName] then return end

  if not checkDistance(src, vendorLocation[loc].loc, 3) then
    lib.logger(src, 'drp-stashes:server:buyBackpack', ('Player %s was too far from vendor'):format(getPlayerName(src)), 'type:warn')
    return
  end

  local price = itemList[itemName].price
  local account = type == 'bank' and 'bank' or 'money'

  if xPlayer.getAccount(account).money >= price then
    xPlayer.removeAccountMoney(account, price)
    local uniqueId = generateUniqueId()
    exports.ox_inventory:AddItem(src, itemName, 1, {stashName = itemName .. uniqueId})

    lib.notify(src, {
      title = locale('Vendor.success'),
      description = locale('Vendor.bought', itemName),
      type = 'success'
    })
  else
    lib.notify(src, {
      title = locale('Vendor.noMoney'),
      type = 'error'
    })
  end
end)

lib.addCommand('giveBag', {
  help = locale('giveBag.help'),
  restricted = 'group.admin',
  params = {
    {name = 'playerId', help = locale('giveBag.pidHelp'), type = 'number'},
    {name = 'itemName', help = locale('giveBag.itemHelp'), type = 'string'}
  }
}, function(source, args, rawCommand)
  local src = source
  local targetId = args.playerId
  local itemName = args.itemName
  local xTarget = ESX.GetPlayerFromId(targetId)

  if not xTarget then
    lib.notify(src, {
      title = locale('giveBag.invalidPlayer'),
      type = 'error'
    })
    return
  end

  if not itemList[itemName] then
    lib.notify(src, {
      title = locale('giveBag.invalidItem'),
      type = 'error'
    })
    return
  end

  local uniqueId = generateUniqueId()
  exports.ox_inventory:AddItem(targetId, itemName, 1, {stashName = itemName .. uniqueId})

  lib.notify(src, {
    title = locale('giveBag.given', getPlayerName(targetId), itemName),
    type = 'success'
  })

  lib.notify(targetId, {
    title = locale('giveBag.received', itemName, getPlayerName(src)),
    type = 'success'
  })
end)
