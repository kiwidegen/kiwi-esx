-- client/vehicle.lua
local ox_lib = exports.ox_lib
local windows = { true, true, true, true }
local vehicleRadialAdded = false

Citizen.CreateThread(function()
    while not ox_lib or not ox_lib.registerRadial do
        Wait(100)
    end

    -- Register car doors submenu
    ox_lib:registerRadial({
        id = 'car_doors',
        items = {
            { label = "Back Right", icon = 'car-side', keepOpen = true, onSelect = function() doorToggle(3) end },
            { label = "Trunk", icon = 'trunk', keepOpen = true, onSelect = function() doorToggle(5) end },
            { label = "Front Right", icon = 'car-side', keepOpen = true, onSelect = function() doorToggle(1) end },
            { label = "Front Left", icon = 'car-side', keepOpen = true, onSelect = function() doorToggle(0) end },
            { label = "Hood", icon = 'car-hood', keepOpen = true, onSelect = function() doorToggle(4) end },
            { label = "Back Left", icon = 'car-side', keepOpen = true, onSelect = function() doorToggle(2) end },
        }
    })

    -- Register car windows submenu
    ox_lib:registerRadial({
        id = 'car_windows',
        items = {
            { label = "Back Right", icon = 'caret-right', keepOpen = true, onSelect = function() windowToggle(2, 3) end },
            { label = "Passenger", icon = 'caret-up', keepOpen = true, onSelect = function() windowToggle(1, 1) end },
            { label = "Driver", icon = 'caret-up', keepOpen = true, onSelect = function() windowToggle(0, 0) end },
            { label = "Back Left", icon = 'caret-left', keepOpen = true, onSelect = function() windowToggle(3, 2) end },
        }
    })

    -- Register car seats submenu
    ox_lib:registerRadial({
        id = 'car_seats',
        items = {
            { label = "Back Right", icon = 'caret-right', onSelect = function() changeSeat(2) end },
            { label = "Passenger", icon = 'caret-up', onSelect = function() changeSeat(0) end },
            { label = "Driver", icon = 'caret-up', onSelect = function() changeSeat(-1) end },
            { label = "Back Left", icon = 'caret-left', onSelect = function() changeSeat(1) end },
        }
    })

    -- Register vehicle menu (used when inside a vehicle)
    ox_lib:registerRadial({
        id = 'vehicle_menu',
        items = {
            { 
                label = "Flip Vehicle", 
                icon = 'car-crash', 
                onSelect = function()
                    local ped = PlayerPedId()
                    local inVehicle = GetVehiclePedIsIn(ped, false)
                    if inVehicle ~= 0 then
                        ox_lib:notify({ 
                            title = "Vehicle", 
                            description = "Get out of the vehicle to flip it!", 
                            type = 'error', 
                            position = 'top-right', 
                            icon = 'ban' 
                        })
                        return
                    end

                    local coords = GetEntityCoords(ped)
                    local vehicle = GetClosestVehicle(coords, 5.0, 0, 70)
                    if vehicle ~= 0 then
                        local success = lib.progressCircle({
                            duration = 5000,
                            position = 'bottom',
                            label = 'Flipping Vehicle...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, combat = true, car = true },
                            anim = { dict = 'mini@repair', clip = 'fixing_a_ped' }
                        })
                        if success then
                            TriggerServerEvent('drp-radial:forceFlip', NetworkGetNetworkIdFromEntity(vehicle))
                            ox_lib:notify({ title = "Vehicle", description = "Vehicle flipped upright!", type = 'success', position = 'top-right' })
                        else
                            ox_lib:notify({ title = "Vehicle", description = "Flipping cancelled!", type = 'error', position = 'top-right', icon = 'ban' })
                        end
                    else
                        ox_lib:notify({ title = "Vehicle", description = "No vehicle nearby to flip!", type = 'error', position = 'top-right', icon = 'ban' })
                    end
                end 
            },
            { label = "Motor", icon = 'power-off', onSelect = function()
                if cache.vehicle then
                    local engineRunning = GetIsVehicleEngineRunning(cache.vehicle)
                    SetVehicleEngineOn(cache.vehicle, not engineRunning, true, true)
                end
            end },
            { label = "Doors", icon = 'car-side', menu = 'car_doors' },
            { label = "Windows", icon = 'car-side', menu = 'car_windows' },
            { label = "Seats", icon = 'car-side', menu = 'car_seats' },
        }
    })

    -- Register flip-only menu (used when next to a flipped vehicle)
    ox_lib:registerRadial({
        id = 'vehicle_flip_menu',
        items = {
            { 
                label = "Flip Vehicle", 
                icon = 'car-crash', 
                onSelect = function()
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    local vehicle = GetClosestVehicle(coords, 5.0, 0, 70)
                    if vehicle ~= 0 then
                        local success = lib.progressCircle({
                            duration = 5000,
                            position = 'bottom',
                            label = 'Flipping Vehicle...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, combat = true, car = true },
                            anim = { dict = 'mini@repair', clip = 'fixing_a_ped' }
                        })
                        if success then
                            TriggerServerEvent('drp-radial:forceFlip', NetworkGetNetworkIdFromEntity(vehicle))
                            ox_lib:notify({ title = "Vehicle", description = "Vehicle flipped upright!", type = 'success', position = 'top-right' })
                        else
                            ox_lib:notify({ title = "Vehicle", description = "Flipping cancelled!", type = 'error', position = 'top-right', icon = 'ban' })
                        end
                    else
                        ox_lib:notify({ title = "Vehicle", description = "No vehicle nearby to flip!", type = 'error', position = 'top-right', icon = 'ban' })
                    end
                end 
            }
        }
    })

    -- Function to check if a vehicle is flipped
    local function isVehicleFlipped(vehicle)
        if not vehicle or not DoesEntityExist(vehicle) then return false end
        local roll = GetEntityRoll(vehicle)
        return roll > 75.0 or roll < -75.0
    end

    while true do
        local ped = PlayerPedId()
        local inVehicle = cache.vehicle
        local coords = GetEntityCoords(ped)
        local nearbyVehicle = GetClosestVehicle(coords, 5.0, 0, 70)
        local isFlipped = nearbyVehicle ~= 0 and isVehicleFlipped(nearbyVehicle)

        if inVehicle and not vehicleRadialAdded then
            -- Player is in a vehicle, show full vehicle menu
            ox_lib:addRadialItem({
                id = 'vehicle',
                label = "Vehicle",
                icon = 'car',
                menu = 'vehicle_menu'
            })
            vehicleRadialAdded = true
        elseif not inVehicle and isFlipped and not vehicleRadialAdded then
            -- Player is next to a flipped vehicle, show only flip option
            ox_lib:addRadialItem({
                id = 'vehicle',
                label = "Vehicle",
                icon = 'car',
                menu = 'vehicle_flip_menu'
            })
            vehicleRadialAdded = true
        elseif not inVehicle and not isFlipped and vehicleRadialAdded then
            -- Player is not in a vehicle and no flipped vehicle nearby, remove vehicle radial
            ox_lib:removeRadialItem('vehicle')
            vehicleRadialAdded = false
        elseif inVehicle and isFlipped and vehicleRadialAdded then
            -- Ensure the full menu is shown when in a vehicle, even if it's flipped
            ox_lib:removeRadialItem('vehicle')
            ox_lib:addRadialItem({
                id = 'vehicle',
                label = "Vehicle",
                icon = 'car',
                menu = 'vehicle_menu'
            })
            vehicleRadialAdded = true
        end

        Wait(500)
    end
end)

-- Client-side event to handle vehicle flipping
RegisterNetEvent('drp-radial:client:forceFlip')
AddEventHandler('drp-radial:client:forceFlip', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        SetVehicleDoorsLocked(vehicle, 1)
        local heading = GetEntityHeading(vehicle)
        SetEntityRotation(vehicle, 0.0, 0.0, heading, 2, true)
        SetVehicleOnGroundProperly(vehicle)
    end
end)

function doorToggle(door)
    if not cache.vehicle then return end
    if GetVehicleDoorAngleRatio(cache.vehicle, door) > 0.0 then
        SetVehicleDoorShut(cache.vehicle, door, false, false)
    else
        SetVehicleDoorOpen(cache.vehicle, door, false, false)
    end
end

function changeSeat(seat)
    if not cache.vehicle then return end
    if IsVehicleSeatFree(cache.vehicle, seat) then
        SetPedIntoVehicle(cache.ped, cache.vehicle, seat)
    end
end

function windowToggle(window, door)
    if not cache.vehicle then return end
    if GetIsDoorValid(cache.vehicle, door) and windows[window + 1] then
        RollDownWindow(cache.vehicle, window)
        windows[window + 1] = false
    else
        RollUpWindow(cache.vehicle, window)
        windows[window + 1] = true
    end
end