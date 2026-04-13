-- client/elevator.lua
local ESX = exports['es_extended']:getSharedObject()
local textVisible = false
local currentElevatorMenu = nil

---@return table|nil elevator The nearby elevator or nil
local function getNearbyElevator()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if not RadialConfig or not RadialConfig.Elevators then return nil end

    for _, elevator in ipairs(RadialConfig.Elevators) do
        for _, dest in ipairs(elevator.destinations) do
            local destCoords = vector3(dest.coords.x, dest.coords.y, dest.coords.z)
            local dist = #(playerCoords - destCoords)
            if dist < RadialConfig.InteractDistance then return elevator, dest end
            if dest.extraCoords then
                local extraDist = #(playerCoords - dest.extraCoords)
                if extraDist < RadialConfig.InteractDistance then return elevator, dest end
            end
        end
    end
    return nil
end

--- Draw marker at elevator locations
---@param coords vector3 Marker coordinates
local function drawElevatorMarker(coords)
    DrawMarker(27, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 66, 135, 245, 200, false, true, 2, nil, nil, false)
end

CreateThread(function()
    while not lib do
        Wait(100)
    end

    local wasInRange = false

    while true do
        local elevator, nearDest = getNearbyElevator()
        local inRange = elevator ~= nil
        local sleep = 500

        if inRange then
            sleep = 0
            local markerCoords = nearDest.coords and vector3(nearDest.coords.x, nearDest.coords.y, nearDest.coords.z) or nil
            if markerCoords then
                drawElevatorMarker(markerCoords)
            end
        end

        if inRange and not textVisible then
            lib.showTextUI('Z - Use Elevator', {
                position = 'right-center',
                icon = 'elevator',
                iconColor = '#FFFFFF'
            })
            textVisible = true
        elseif not inRange and textVisible then
            lib.hideTextUI()
            textVisible = false
            lib.removeRadialItem('elevator_access')
        end

        if inRange and not wasInRange then
            if currentElevatorMenu ~= elevator.name then
                lib.registerRadial({
                    id = 'elevator_menu_' .. elevator.name,
                    items = (function()
                        local items = {}
                        for _, dest in ipairs(elevator.destinations) do
                            items[#items + 1] = {
                                label = dest.label,
                                icon = 'building',
                                onSelect = function()
                                    local nearbyPlayers = {}
                                    local myCoords = GetEntityCoords(PlayerPedId())
                                    for _, playerId in ipairs(GetActivePlayers()) do
                                        local ped = GetPlayerPed(playerId)
                                        local pedCoords = GetEntityCoords(ped)
                                        local dist = #(myCoords - pedCoords)
                                        if dist < RadialConfig.InteractDistance then
                                            nearbyPlayers[#nearbyPlayers + 1] = GetPlayerServerId(playerId)
                                        end
                                    end
                                    TriggerServerEvent('elevator:teleportGroup', nearbyPlayers, dest.coords)
                                    lib.notify({
                                        title = 'Elevator',
                                        description = 'You have arrived at ' .. dest.label,
                                        type = 'success',
                                        position = 'top-right'
                                    })
                                end
                            }
                        end
                        return items
                    end)()
                })
                currentElevatorMenu = elevator.name
            end

            lib.addRadialItem({
                id = 'elevator_access',
                label = 'Elevator',
                icon = 'elevator',
                menu = 'elevator_menu_' .. elevator.name
            })
        elseif not inRange and wasInRange then
            lib.removeRadialItem('elevator_access')
        end

        wasInRange = inRange
        Wait(sleep)
    end
end)

RegisterNetEvent('elevator:teleportClient')
AddEventHandler('elevator:teleportClient', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w)
end)