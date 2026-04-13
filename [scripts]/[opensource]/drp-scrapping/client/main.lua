---@class ScrappableProps
---@field car_wreck string[] Car wreck prop models
---@field bus_wreck string[] Bus wreck prop models

---@class BinModels
---@field dumpster string[] Dumpster models
---@field skip string[] Skip models

-- List of props that can be scrapped (only car wrecks and bus wrecks)
---@type ScrappableProps
local scrappableProps = {
  car_wreck = {
    "prop_rub_carwreck_2", "prop_rub_carwreck_3", "prop_rub_carwreck_5", "prop_rub_carwreck_7",
    "prop_rub_carwreck_8", "prop_rub_carwreck_9", "prop_rub_carwreck_10", "prop_rub_carwreck_11",
    "prop_rub_carwreck_12", "prop_rub_carwreck_13", "prop_rub_carwreck_14", "prop_rub_carwreck_15",
    "prop_rub_carwreck_16", "prop_rub_carwreck_17"
  },
  bus_wreck = {
    "prop_rub_buswreck_01", "prop_rub_buswreck_03", "prop_rub_buswreck_06"
  }
}

-- List of bin models
---@type BinModels
local binModels = {
  dumpster = {
    "prop_dumpster_01a",
    "prop_dumpster_02a",
    "prop_dumpster_02b",
    "prop_dumpster_3a",
    "prop_dumpster_4a",
    "prop_dumpster_4b",
    "p_dumpster_t"
  },
  skip = {
    "prop_skip_01a",
    "prop_skip_02a",
    "prop_skip_03",
    "prop_skip_04",
    "prop_skip_05a",
    "prop_skip_05b",
    "prop_skip_06a",
    "prop_skip_08a",
    "prop_skip_08b",
    "prop_skip_10a"
  }
}

-- Cache to track scrapped entities and their cooldowns
---@type table<number, number>
local scrappedEntities = {}

-- Cache to track searched bins and their cooldowns
---@type table<number, number>
local searchedBins = {}

--- Get cached player ped
---@type number
local cache = {
  ped = PlayerPedId()
}

-- Update ped cache when it changes
AddEventHandler('onClientResourceStart', function(resource)
  if GetCurrentResourceName() ~= resource then return end
  cache.ped = PlayerPedId()
end)

--- Send a notification to the player
---@param description string Notification message
---@param type 'inform'|'error'|'success' Notification type
local function notify(description, type)
  lib.notify({
    description = description,
    type = type or 'inform',
    duration = 5000,
    position = 'top-right'
  })
end

--- Function to start the scrapping process for vehicles
---@param entity number Entity handle
local function startScrappingVehicle(entity)
  -- Check if the player is in a vehicle
  if IsPedInAnyVehicle(cache.ped, false) then
    notify('You cannot scrap while in a vehicle.', 'error')
    return
  end

  -- Check if the entity is on cooldown
  if scrappedEntities[entity] then
    local currentTime = GetGameTimer() / 1000
    local timeSinceLastScrap = currentTime - scrappedEntities[entity]
    local cooldown = 10 -- Cooldown is fetched from server config

    if timeSinceLastScrap < cooldown then
      notify('This vehicle is still on cooldown.', 'error')
      return
    else
      scrappedEntities[entity] = nil
    end
  end

  -- Check if the player has a blow torch
  lib.callback('drp-scrapping:hasBlowTorch', false, function(hasBlowTorch)
    if not hasBlowTorch then
      notify('You need a blow torch to scrap this vehicle.', 'error')
      return
    end

    -- Start the progress circle with welding scenario
    local success = lib.progressCircle({
      duration = 10000,
      label = 'Scrapping vehicle...',
      position = 'bottom',
      useWhileDead = false,
      canCancel = true,
      disable = {
        car = true,
        move = true,
        combat = true,
      },
      anim = {
        scenario = 'WORLD_HUMAN_WELDING',
      }
    })

    -- Store the heading and position after animation
    local finalHeading = GetEntityHeading(cache.ped)
    local finalCoords = GetEntityCoords(cache.ped)

    -- Gently clear the scenario task without snapping
    ClearPedTasks(cache.ped)

    -- Wait a frame for the clear to process
    Wait(0)

    -- Lock the player's heading to prevent snap-back
    SetEntityHeading(cache.ped, finalHeading)
    SetEntityCoordsNoOffset(cache.ped, finalCoords.x, finalCoords.y, finalCoords.z, false, false, false)

    -- Wait a tiny bit for the prop to spawn fully before deleting
    Wait(100)

    -- Delete any welding torch props near the player
    local coords = GetEntityCoords(cache.ped)
    local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0, GetHashKey('prop_weld_torch'), false, false, false)
    if object ~= 0 then
      SetEntityAsMissionEntity(object, true, true)
      DeleteObject(object)
      DeleteEntity(object)
    end

    if success then
      -- Success: Trigger server event to reward the player
      TriggerServerEvent('drp-scrapping:reward')

      -- Mark the entity as scrapped and set its cooldown
      scrappedEntities[entity] = GetGameTimer() / 1000
    else
      notify('Scrapping cancelled.', 'error')
    end
  end)
end

--- Function to start the bin searching process
---@param entity number Entity handle
local function startBinSearch(entity)
  -- Check if the player is in a vehicle
  if IsPedInAnyVehicle(cache.ped, false) then
    notify('You cannot search bins while in a vehicle.', 'error')
    return
  end

  -- Check if the bin is on cooldown
  if searchedBins[entity] then
    local currentTime = GetGameTimer() / 1000
    local timeSinceLastSearch = currentTime - searchedBins[entity]
    local cooldown = 15 -- Cooldown is fetched from server config

    if timeSinceLastSearch < cooldown then
      notify('This bin is still on cooldown.', 'error')
      return
    else
      searchedBins[entity] = nil
    end
  end

  -- Start the skill check (using WASD)
  local success = lib.skillCheck({ 'easy', { areaSize = 80, speedMultiplier = 1 } }, { 'w', 'a', 's', 'd' })

  if success then
    -- Start the progress circle with bin search animation
    local progressSuccess = lib.progressCircle({
      duration = 10000,
      label = 'Searching bin...',
      position = 'bottom',
      useWhileDead = false,
      canCancel = true,
      disable = {
        car = true,
        move = true,
        combat = true,
      },
      anim = {
        scenario = 'PROP_HUMAN_BUM_BIN',
      }
    })

    if progressSuccess then
      -- Success: Trigger server event to reward the player
      TriggerServerEvent('drp-scrapping:binReward', entity)

      -- Mark the bin as searched and set its cooldown
      searchedBins[entity] = GetGameTimer() / 1000
    else
      notify('Searching cancelled.', 'error')
    end
  else
    notify('You failed to search the bin properly.', 'error')
  end
end

-- Add ox_target options for scrappable props
CreateThread(function()
  for category, props in pairs(scrappableProps) do
    for _, model in ipairs(props) do
      exports.ox_target:addModel(GetHashKey(model), {
        {
          name = 'scrap_vehicle',
          label = 'Start Scrapping',
          icon = 'fa-solid fa-recycle',
          distance = 2.0,
          onSelect = function(data)
            startScrappingVehicle(data.entity)
          end
        }
      })
    end
  end
end)

-- Add ox_target options for bin models
CreateThread(function()
  for category, models in pairs(binModels) do
    for _, model in ipairs(models) do
      exports.ox_target:addModel(GetHashKey(model), {
        {
          name = 'search_bin',
          label = 'Search Bin',
          icon = 'fas fa-dumpster',
          distance = 2.0,
          onSelect = function(data)
            startBinSearch(data.entity)
          end
        }
      })
    end
  end
end)
