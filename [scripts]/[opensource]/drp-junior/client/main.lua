local isProtected = false
local timeRemaining = 0
local currentVehicle = nil
local protectionThread = nil
local vehicleThread = nil

-- Cache frequently used values
local cache = {
    ped = PlayerPedId(),
    vehicle = 0,
    coords = vector3(0, 0, 0)
}

-- Update cache periodically instead of every frame
CreateThread(function()
    while true do
        cache.ped = PlayerPedId()
        cache.coords = GetEntityCoords(cache.ped)
        cache.vehicle = GetVehiclePedIsIn(cache.ped, false)
        Wait(500)
    end
end)

--- Show welcome and protection messages
---@param remaining number Time remaining in seconds
local function showWelcomeMessages(remaining)
    -- Welcome message
    lib.notify({
        title = Config.WELCOME_TITLE,
        type = 'success',
        duration = 5000
    })

    -- Protection countdown message
    Wait(500)
    lib.notify({
        id = 'junior_protection',
        title = 'New Player Protection',
        description = Config.PROTECTION_MESSAGE,
        type = 'inform',
        countdown = remaining,
        duration = remaining * 1000,
        icon = 'shield'
    })
end

--- Handle combat restrictions
local function startProtectionThread()
    if protectionThread then return end

    protectionThread = true
    CreateThread(function()
        local sleep = 0
        while protectionThread and isProtected do
            sleep = 100 -- Default sleep

            -- Disable melee combat
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate

            -- Disable weapon firing
            DisablePlayerFiring(cache.ped, true)

            -- Remove weapons if they somehow get one (check less frequently)
            if IsPedArmed(cache.ped, 7) then
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
                sleep = 0 -- Check faster if they're armed
            end

            Wait(sleep)
        end
        protectionThread = nil
    end)
end

--- Stop protection thread
local function stopProtectionThread()
    protectionThread = nil
end

--- Handle vehicle transparency and collision
local function startVehicleThread()
    if vehicleThread then return end

    vehicleThread = true
    CreateThread(function()
        local entityCache = {peds = {}, vehicles = {}, lastUpdate = 0}

        while vehicleThread and isProtected do
            if cache.vehicle ~= 0 and GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped then
                -- Player is driving a vehicle
                if currentVehicle ~= cache.vehicle then
                    currentVehicle = cache.vehicle
                    SetEntityAlpha(currentVehicle, Config.VEHICLE_ALPHA, false)
                    SetVehicleCanBeUsedByFleeingPeds(currentVehicle, false)
                end

                -- Disable vehicle damage dealing
                SetVehicleCanBreak(currentVehicle, false)
                SetVehicleStrong(currentVehicle, true)
                SetVehicleCanDeformWheels(currentVehicle, false)

                -- Update entity cache every 500ms instead of every frame
                local currentTime = GetGameTimer()
                if currentTime - entityCache.lastUpdate > 500 then
                    entityCache.peds = GetGamePool('CPed')
                    entityCache.vehicles = GetGamePool('CVehicle')
                    entityCache.lastUpdate = currentTime
                end

                -- Set no collision with nearby peds
                for i = 1, #entityCache.peds do
                    local ped = entityCache.peds[i]
                    if ped ~= cache.ped and #(GetEntityCoords(ped) - cache.coords) < 20.0 then
                        SetEntityNoCollisionEntity(currentVehicle, ped, true)
                    end
                end

                -- Set no collision with nearby vehicles
                for i = 1, #entityCache.vehicles do
                    local veh = entityCache.vehicles[i]
                    if veh ~= currentVehicle and #(GetEntityCoords(veh) - cache.coords) < 20.0 then
                        SetEntityNoCollisionEntity(currentVehicle, veh, true)
                    end
                end
            elseif currentVehicle then
                -- Player exited vehicle - restore normal alpha
                if DoesEntityExist(currentVehicle) then
                    ResetEntityAlpha(currentVehicle)
                end
                currentVehicle = nil
            end

            Wait(250)
        end

        -- Cleanup when protection ends
        if currentVehicle and DoesEntityExist(currentVehicle) then
            ResetEntityAlpha(currentVehicle)
        end

        vehicleThread = nil
        currentVehicle = nil
    end)
end

--- Stop vehicle thread
local function stopVehicleThread()
    vehicleThread = nil

    if currentVehicle and DoesEntityExist(currentVehicle) then
        ResetEntityAlpha(currentVehicle)
    end

    currentVehicle = nil
end

--- Update protection status from server
---@param protected boolean Is player protected
---@param remaining number Time remaining in seconds
RegisterNetEvent('drp-junior:client:updateProtection', function(protected, remaining)
    local wasProtected = isProtected
    isProtected = protected
    timeRemaining = remaining

    if isProtected and not wasProtected then
        -- Protection started
        showWelcomeMessages(remaining)
        startProtectionThread()
        startVehicleThread()
    elseif not isProtected and wasProtected then
        -- Protection ended
        stopProtectionThread()
        stopVehicleThread()

        -- Dismiss the countdown notification by updating it with short duration
        lib.notify({
            id = 'junior_protection',
            title = 'Protection Complete',
            description = 'Welcome to the full Demon RP experience!',
            type = 'success',
            duration = 7000
        })
    end
end)

--- Player loaded - server will automatically send protection status
AddEventHandler('esx:playerLoaded', function(playerData)
    -- Server handles sending protection status automatically
end)

--- Resource started - server will automatically send protection status
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    -- Server handles sending protection status automatically
end)

--- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end

    stopProtectionThread()
    stopVehicleThread()
end)
