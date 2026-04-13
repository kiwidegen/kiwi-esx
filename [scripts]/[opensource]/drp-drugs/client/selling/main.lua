--- Drug Selling - Main initialization and state management

ESX = exports['es_extended']:getSharedObject()

---@class DrugItem
---@field item string Drug item name
---@field label string Display label
---@field amount number Quantity available

--- Shared state variables
PlayerData = {}
myDrugs = {} ---@type DrugItem[]
isSelling = false
startLocation = nil
copCount = 0
currentTarget = nil
currentZone = nil ---@type string|nil
zoneData = {} ---@type table<string, table>

--- Cache for performance
cache = {
  ped = PlayerPedId(),
  coords = GetEntityCoords(PlayerPedId())
}

--- Update cache periodically
CreateThread(function()
  while true do
    Wait(500)
    cache.ped = PlayerPedId()
    cache.coords = GetEntityCoords(cache.ped)
  end
end)

--- Update drug holdings periodically
CreateThread(function()
  -- Wait for ESX and Config to load
  while not ESX or not Config do
    Wait(1000)
  end

  while true do
    Wait(5000) -- Check every 5 seconds

    if not isSelling then
      ESX.TriggerServerCallback('drp-drugs:server:getAvailableDrugs', function(availableDrugs)
        myDrugs = availableDrugs or {}
      end)
    end
  end
end)

--- Load configuration from server
local function loadConfig()
  ESX.TriggerServerCallback('drp-drugs:server:getConfig', function(config)
    Config = config
    debugPrint('Config loaded from server')
    debugPrint('Debug mode: ' .. tostring(DrugsConfig.Debug))

    -- Initialize ox_lib zones
    for zoneName, zoneConfig in pairs(DrugsConfig.Zones) do
      -- Convert vector2 points to vector3 using minZ
      local points3d = {}
      for i, point in ipairs(zoneConfig.points) do
        points3d[i] = vector3(point.x, point.y, zoneConfig.options.minZ)
      end

      zoneData[zoneName] = lib.zones.poly({
        name = zoneName,
        points = points3d,
        thickness = zoneConfig.options.maxZ - zoneConfig.options.minZ,
        debug = DrugsConfig.Debug, -- Enable debug visualization when DrugsConfig.Debug is true
        onEnter = function()
          local coords = GetEntityCoords(PlayerPedId())
          currentZone = zoneName
          debugPrint('Entered zone: ' .. zoneName .. ' at coords: ' .. coords)
          debugNotify('Entered selling zone: ' .. zoneName)
        end,
        onExit = function()
          if currentZone == zoneName then
            local coords = GetEntityCoords(PlayerPedId())
            currentZone = nil
            debugPrint('Exited zone: ' .. zoneName .. ' at coords: ' .. coords)
            debugNotify('Exited selling zone: ' .. zoneName)
          end
        end
      })
    end

    -- Check if player is already inside a zone (fixes issue when script loads while player is in zone)
    Wait(500) -- Small delay to ensure zones are fully registered
    local playerCoords = GetEntityCoords(PlayerPedId())
    for zoneName, zone in pairs(zoneData) do
      if zone:contains(playerCoords) then
        currentZone = zoneName
        debugPrint('Already inside zone on load: ' .. zoneName)
        debugNotify('Already inside zone: ' .. zoneName)
        break -- Only set one zone if multiple overlap
      end
    end
  end)
end

--- Initialize player data
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer

  -- Initialize drug holdings (delayed)
  CreateThread(function()
    Wait(2000)
    if ESX then
      ESX.TriggerServerCallback('drp-drugs:server:getAvailableDrugs', function(availableDrugs)
        myDrugs = availableDrugs or {}
        debugPrint('Player loaded - drug holdings: ' .. #myDrugs .. ' types')
      end)
    end
  end)
end)

RegisterNetEvent('esx:setJob', function(job)
  PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  PlayerData = ESX.GetPlayerData()
  loadConfig()

  -- Initialize drug holdings (delayed)
  CreateThread(function()
    Wait(2000)
    if ESX then
      ESX.TriggerServerCallback('drp-drugs:server:getAvailableDrugs', function(availableDrugs)
        myDrugs = availableDrugs or {}
        debugPrint('Initialized drug holdings: ' .. #myDrugs .. ' types')
      end)
    end
  end)
end)

CreateThread(function()
  loadConfig()

  -- Initialize drug holdings (delayed)
  Wait(2000)
  if ESX then
    ESX.TriggerServerCallback('drp-drugs:server:getAvailableDrugs', function(availableDrugs)
      myDrugs = availableDrugs or {}
      debugPrint('Initialized drug holdings: ' .. #myDrugs .. ' types')
    end)
  end
end)

--- Get current territory player is in
---@return string|nil territory Territory name or nil
---@return table|nil zoneConfig Zone configuration
function getCurrentTerritory()
  if not currentZone then return nil, nil end
  return currentZone, DrugsConfig.Zones[currentZone]
end

--- Start selling drugs
function startSelling()
  LocalPlayer.state:set("inv_busy", true, true)
  lib.notify({
    description = 'Started selling drugs',
    type = 'success'
  })
  startLocation = cache.coords
  isSelling = true

  debugPrint('Started selling at: ' .. tostring(startLocation))
  debugPrint('Available drugs: ' .. #myDrugs)
  for _, drug in ipairs(myDrugs) do
    debugPrint('  - ' .. drug.label .. ' x' .. drug.amount)
  end
end

--- Stop selling drugs
function stopSelling()
  isSelling = false
  currentTarget = nil -- Clear any active target
  LocalPlayer.state:set("inv_busy", false, true)
  lib.notify({
    description = 'Stopped selling drugs',
    type = 'inform'
  })
  startLocation = nil

  debugPrint('Stopped selling drugs')
end

-- Event: Update player's drug holdings
RegisterNetEvent('drp-drugs:client:updateHoldings', function(updatedDrugs)
  myDrugs = updatedDrugs or {}

  -- Stop selling if no drugs left
  if #myDrugs == 0 and isSelling then
    stopSelling()
    lib.notify({
      description = 'You have no more drugs to sell',
      type = 'error'
    })
  end
end)
