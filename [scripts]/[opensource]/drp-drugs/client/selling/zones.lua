--- Zone-based corner selling

--- Sell drugs to NPC in zone
---@param ped number NPC entity handle
local function sellDrugs(ped)
  currentTarget = ped

  -- Mark ped as used immediately to prevent re-selection
  Entity(currentTarget).state.bought_drugs = true

  -- Random fail chance
  local failChance = math.random(1, 20)
  if failChance <= DrugsConfig.SellDifficulty then
    Wait(1500)
    currentTarget = nil
    return
  end

  if not myDrugs or #myDrugs == 0 then
    currentTarget = nil
    return
  end

  -- Get current territory and its config
  local territory, zoneConfig = getCurrentTerritory()
  if not territory or not zoneConfig then
    currentTarget = nil
    return
  end

  -- Select random drug from inventory
  local drugIndex = math.random(1, #myDrugs)
  local currentDrug = myDrugs[drugIndex]

  -- Weighted random bag amount (1-4 bags, lower chance for higher amounts)
  local bagAmount = 1
  local roll = math.random(100)
  if roll <= 50 then
    bagAmount = 1     -- 50% chance
  elseif roll <= 80 then
    bagAmount = 2     -- 30% chance
  elseif roll <= 95 then
    bagAmount = 3     -- 15% chance
  else
    bagAmount = 4     -- 5% chance
  end

  -- Can't sell more than player has
  if bagAmount > currentDrug.amount then
    bagAmount = currentDrug.amount
  end

  -- Calculate price with zone modifier
  local priceData = DrugsConfig.Drugs[currentDrug.item].price
  local basePrice = math.random(priceData.min, priceData.max)
  local copBonus = math.random(60, 100) * copCount
  local price = math.floor((basePrice + copBonus) * bagAmount * zoneConfig.priceMod)

  -- Check if 2x bonus applies (must be in the active 2x zone AND selling the active 2x drug)
  local is2x = false
  if DrugsConfig.Active2xZone and DrugsConfig.Active2xDrug then
    if territory == DrugsConfig.Active2xZone and currentDrug.item == DrugsConfig.Active2xDrug then
      price = price * 2
      is2x = true
    end
  end

  -- Apply weekend bonus (Friday=5, Saturday=6, Sunday=0)
  local dayOfWeek = GetClockDayOfWeek()
  local isWeekend = (dayOfWeek == 5 or dayOfWeek == 6 or dayOfWeek == 0)
  if isWeekend and DrugsConfig.WeekendPriceBonus then
    price = math.floor(price * DrugsConfig.WeekendPriceBonus)
  end

  -- Check if NPC will steal instead
  local willSteal = false
  if zoneConfig.stealChance then
    local stealRoll = math.random()
    if stealRoll <= zoneConfig.stealChance then
      willSteal = true
    end
  end

  -- Debug transaction info
  debugPrint('=== Drug Sale Attempt ===')
  debugPrint('Drug: ' .. currentDrug.label .. ' x' .. bagAmount)
  debugPrint('Territory: ' .. territory .. ' (Modifier: ' .. zoneConfig.priceMod .. 'x)')
  debugPrint('Base Price: $' .. basePrice)
  debugPrint('Cop Bonus: $' .. copBonus)
  debugPrint('Final Price: $' .. price)
  debugPrint('2x Bonus Active: ' .. tostring(is2x))
  debugPrint('Weekend Bonus: ' .. tostring(isWeekend))
  debugPrint('Will Steal: ' .. tostring(willSteal))

  -- Don't mark as no longer needed yet - we may need to track them if they steal
  ClearPedTasks(ped)

  -- Make NPC walk to player
  local player_pos = GetEntityCoords(cache.ped, true)
  TaskGoStraightToCoord(ped, player_pos, 1.2, -1, 0.0, 0.0)

  local target_dist = #(player_pos - GetEntityCoords(ped))
  while target_dist > 1.5 and isSelling do
    Wait(100)
    player_pos = GetEntityCoords(cache.ped, true)
    local target_pos = GetEntityCoords(ped)
    target_dist = #(player_pos - target_pos)

    TaskGoStraightToCoord(ped, player_pos, 1.2, -1, 0.0, 0.0)
  end

  -- NPC reached player - make them stand impatient
  ClearPedTasks(ped)
  TaskLookAtEntity(ped, cache.ped, 5500.0, 2048, 3)
  TaskTurnPedToFaceEntity(ped, cache.ped, 5500)
  Wait(200)
  TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)

  -- Interaction loop
  while target_dist < 1.5 and isSelling and currentTarget do
    Wait(0) -- Must run every frame for text rendering and key detection
    local pedCoords = GetEntityCoords(ped)
    target_dist = #(cache.coords - pedCoords) -- Use cached coords

    -- Build display text
    local displayText = ''

    -- Add 2x indicator if this drug in this zone has 2x bonus (yellow color)
    if is2x then
      displayText = '~y~2x~w~ '
    end

    -- Price color: green on weekends, white normally
    local priceColor = isWeekend and '~g~' or '~w~'

    -- Add offer text
    displayText = displayText .. '~g~E~w~ ' .. bagAmount .. 'x ' .. currentDrug.label .. ' for ' .. priceColor .. '$' .. price .. '~w~ / ~g~G~w~ Decline'

    draw3DText(pedCoords, displayText)

    -- Accept offer (E key)
    if IsControlJustPressed(0, 38) then
      -- Check if ped will steal
      if willSteal then
        -- PED ROBS YOU - No progress bar, instant robbery
        debugPrint('[ROBBERY] Ped is stealing drugs!')

        -- Mark ped with stolen drugs for recovery
        local stolenData = {
          item = currentDrug.item,
          amount = bagAmount,
          time = GetGameTimer()
        }
        Entity(currentTarget).state.stole_drugs = stolenData

        -- Track thief for recovery
        stolenDrugPed = currentTarget
        thiefWasAlive = true -- Reset tracking state

        debugPrint('[ROBBERY] Thief entity ID: ' .. currentTarget)
        debugPrint('[ROBBERY] Marked entity state with stolen drugs')
        debugPrint('[ROBBERY] Recovery tracking activated')

        -- Add ox_target to thief ped
        exports.ox_target:addLocalEntity(currentTarget, {
          {
            name = 'recover_drugs_' .. currentTarget,
            icon = 'fas fa-hand-holding',
            label = 'Recover Drugs',
            onSelect = function(data)
              local ped = data.entity
              local stolenInfo = Entity(ped).state.stole_drugs
              if stolenInfo then
                TriggerServerEvent('drp-drugs:server:recoverDrugs', stolenInfo.item, stolenInfo.amount)
                Entity(ped).state.stole_drugs = nil

                lib.notify({
                  description = 'You recovered your drugs!',
                  type = 'success'
                })

                debugPrint('Recovered ' .. stolenInfo.amount .. 'x ' .. stolenInfo.item .. ' from thief')

                -- Remove ox_target
                exports.ox_target:removeLocalEntity(ped, 'recover_drugs_' .. ped)

                -- Clean up
                if not IsPedDeadOrDying(ped, true) then
                  ClearPedTasks(ped)
                  TaskSmartFleePed(ped, cache.ped, 100.0, -1, false, false)
                end
                SetPedAsNoLongerNeeded(ped)
                stolenDrugPed = nil
              end
            end,
            canInteract = function(entity)
              return Entity(entity).state.stole_drugs ~= nil
            end,
            distance = 3.0
          }
        })

        -- Keep ped alive for recovery - DO NOT call SetPedAsNoLongerNeeded
        SetPedKeepTask(currentTarget, true)

        -- Remove drugs from player
        TriggerServerEvent('drp-drugs:server:sell', currentDrug.item, bagAmount, 0, territory, true)

        -- Notify player
        lib.notify({
          description = 'You have been robbed!',
          type = 'error'
        })

        -- Ped runs away (slower so player can chase)
        ClearPedTasksImmediately(currentTarget)
        TaskSmartFleePed(currentTarget, cache.ped, 50.0, 15000, false, false) -- 50m flee range, 15 seconds

        lib.notify({
          title = 'Chase the thief!',
          description = 'You have 2 minutes to recover your drugs',
          type = 'inform',
          duration = 5000
        })

        debugPrint('[ROBBERY] Ped fleeing with drugs - chase them to recover!')
        currentTarget = nil
        break
      else
        -- NORMAL SALE - Both do pointing gesture
        TriggerServerEvent('drp-drugs:server:sell', currentDrug.item, bagAmount, price, territory, false)

        -- Check for police alert
        local snitchRoll = math.random()
        if snitchRoll <= zoneConfig.snitchChance then
          debugPrint('!!! POLICE ALERTED !!! (Snitch Roll: ' .. snitchRoll .. ' <= ' .. zoneConfig.snitchChance .. ')')
          debugNotify('Police have been alerted!')

          -- Get player data for dispatch
          local playerData = exports['rcore_dispatch']:GetPlayerData()

          -- Build alert text
          local alertText = string.format(
            'Suspicious drug activity reported. Suspect gender: %s. Last seen at %s',
            playerData.sex,
            playerData.street
          )

          -- Send rcore_dispatch alert
          local alertData = {
            code = '10-31',
            default_priority = 'medium',
            coords = playerData.coords,
            job = 'police',
            text = alertText,
            type = 'alerts',
            blip_time = 5,
            blip = {
              sprite = 514,
              colour = 1,
              scale = 1.0,
              text = 'Drug Sales',
              flashes = false,
              radius = 0
            }
          }

          TriggerServerEvent('rcore_dispatch:server:sendAlert', alertData)
        end

        -- Both player AND ped do pointing gesture
        RequestAnimDict("gestures@f@standing@casual")
        while not HasAnimDictLoaded("gestures@f@standing@casual") do Wait(0) end

        -- Player points
        TaskPlayAnim(cache.ped, "gestures@f@standing@casual", "gesture_point", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
        -- NPC points too
        TaskPlayAnim(currentTarget, "gestures@f@standing@casual", "gesture_point", 3.0, 3.0, -1, 49, 0, 0, 0, 0)

        Wait(650)
        ClearPedTasks(cache.ped)

        -- Release ped
        SetPedKeepTask(currentTarget, false)
        SetEntityAsNoLongerNeeded(currentTarget)
        ClearPedTasksImmediately(currentTarget)
        currentTarget = nil
        break
      end
    end

    -- Decline offer (G key)
    if IsControlJustPressed(0, 47) then
      lib.notify({
        description = 'Offer declined',
        type = 'error'
      })
      SetPedKeepTask(ped, false)
      SetEntityAsNoLongerNeeded(ped)
      ClearPedTasksImmediately(ped)
      currentTarget = nil
      break
    end
  end

  if currentTarget then
    SetPedKeepTask(ped, false)
    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasksImmediately(ped)
    currentTarget = nil
  end
end

--- Cached nearby peds for selling
local nearbyPeds = {}

--- Filter peds periodically (expensive operation)
local function pedFilterThread()
  CreateThread(function()
    while isSelling do
      -- Only scan when not in active transaction
      if not currentTarget then
        -- Check if still in zone
        local territory = getCurrentTerritory()
        if not territory then
          stopSelling()
          lib.notify({
            description = 'You left the selling zone',
            type = 'error'
          })
          break
        end

        -- Get list of player peds to ignore
        local ignorePeds = {}
        for _, player in ipairs(GetActivePlayers()) do
          ignorePeds[#ignorePeds + 1] = GetPlayerPed(player)
        end

        -- Find nearby valid NPCs (limit search)
        nearbyPeds = {}
        local scannedCount = 0
        for ped in EnumeratePeds() do
          scannedCount = scannedCount + 1

          -- Break early if we scanned too many peds (performance cap)
          if scannedCount > 50 then
            break
          end

          -- Filter: not player, exists, hasn't bought, not dead, NOT IN VEHICLE
          if not table.contains(ignorePeds, ped) and
             DoesEntityExist(ped) and
             not Entity(ped).state.bought_drugs and
             not IsPedDeadOrDying(ped, true) and
             not IsPedInAnyVehicle(ped, false) then -- Only pedestrians, no cars

            local pedCoords = GetEntityCoords(ped)
            local dist = #(cache.coords - pedCoords)

            if dist < 15.0 then -- Reduced from 20 to 15
              nearbyPeds[#nearbyPeds + 1] = {
                ped = ped,
                coords = pedCoords,
                distance = dist
              }

              -- Break if we found enough peds
              if #nearbyPeds >= 5 then
                break
              end
            end
          end
        end

        Wait(2000) -- Scan every 2 seconds when not in transaction
      else
        Wait(500) -- Faster wait during transaction
      end
    end

    -- Clear cache when thread stops
    nearbyPeds = {}
  end)
end

--- Main selling thread - uses cached peds
local function sellingThread()
  pedFilterThread() -- Start filter thread

  CreateThread(function()
    while isSelling do
      Wait(100) -- Check every 100ms

      -- Find closest cached ped
      if not currentTarget and #nearbyPeds > 0 then
        local closestPed = nil
        local closestDist = 20.0

        for i = 1, #nearbyPeds do
          local pedData = nearbyPeds[i]
          local dist = #(cache.coords - pedData.coords)

          -- Check ped exists, hasn't been used, isn't dead, and still on foot
          if dist < closestDist and
             DoesEntityExist(pedData.ped) and
             not Entity(pedData.ped).state.bought_drugs and
             not IsPedDeadOrDying(pedData.ped, true) and
             not IsPedInAnyVehicle(pedData.ped, false) then
            closestPed = pedData.ped
            closestDist = dist
          end
        end

        if closestPed then
          sellDrugs(closestPed)
        end
      end
    end
  end)
end

-- Event: Start/stop zone selling
RegisterNetEvent('drp-drugs:client:toggleSelling', function()
  -- Prevent police and EMS from selling drugs
  if PlayerData.job?.name == 'police' or PlayerData.job?.name == 'ambulance' then
    lib.notify({
      description = 'You cannot sell drugs with this job',
      type = 'error'
    })
    return
  end

  ESX.TriggerServerCallback('drp-drugs:server:getPoliceCount', function(policeCount)
    if policeCount < DrugsConfig.PoliceRequired then
      lib.notify({
        description = 'Not enough police on duty (' .. DrugsConfig.PoliceRequired .. ' required)',
        type = 'error'
      })
      return
    end

    copCount = policeCount

    ESX.TriggerServerCallback('drp-drugs:server:getAvailableDrugs', function(availableDrugs)
      if not availableDrugs then
        lib.notify({
          description = 'You have no drugs to sell',
          type = 'error'
        })
        LocalPlayer.state:set("inv_busy", false, true)
        return
      end

      myDrugs = availableDrugs

      if not isSelling then
        -- Check if in a valid territory
        local territory = getCurrentTerritory()
        if not territory then
          lib.notify({
            description = 'You need to be in a selling zone',
            type = 'error'
          })
          return
        end

        startSelling()
        sellingThread()
      else
        stopSelling()
      end
    end)
  end)
end)

-- Command: Toggle corner selling
RegisterCommand('cornersell', function()
  TriggerEvent('drp-drugs:client:toggleSelling')
end, false)

-- Command: Sell drugs (alias for testing)
RegisterCommand('sell', function()
  TriggerEvent('drp-drugs:client:toggleSelling')
end, false)

--- Track if we've been robbed (only run recovery when needed)
local stolenDrugPed = nil
local thiefWasAlive = true -- Track if thief was alive last frame

--- Simple recovery check - cleanup expired thieves
CreateThread(function()
  while true do
    Wait(5000) -- Check every 5 seconds

    if stolenDrugPed and DoesEntityExist(stolenDrugPed) then
      local stolenData = Entity(stolenDrugPed).state.stole_drugs

      if stolenData then
        local timeSinceSteal = GetGameTimer() - stolenData.time

        -- Expired - clean up ped (2 minutes)
        if timeSinceSteal > 120000 then
          debugPrint('[RECOVERY] Time expired - drugs lost')
          lib.notify({
            description = 'The thief got away with your drugs!',
            type = 'error'
          })
          Entity(stolenDrugPed).state.stole_drugs = nil
          exports.ox_target:removeLocalEntity(stolenDrugPed, 'recover_drugs_' .. stolenDrugPed)
          SetPedAsNoLongerNeeded(stolenDrugPed)
          stolenDrugPed = nil
        end
      else
        -- No stolen data anymore, clean up
        stolenDrugPed = nil
      end
    elseif stolenDrugPed then
      -- Entity no longer exists - clean up
      debugPrint('[RECOVERY] Thief ped deleted by game')
      stolenDrugPed = nil
    end
  end
end)
