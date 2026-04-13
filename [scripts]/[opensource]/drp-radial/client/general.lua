-- client/general.lua
local ox_lib = exports.ox_lib
local ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    while not ox_lib or not ox_lib.registerRadial do
        Wait(100)
    end

    ox_lib:registerRadial({
        id = 'general_menu',
        items = {
            { 
                label = "Share Contact", 
                icon = 'address-card', 
                onSelect = function()
                    local senderPed = PlayerPedId()
                    local senderCoords = GetEntityCoords(senderPed)
                    local senderId = GetPlayerServerId(PlayerId())
                    local closestPlayer, closestDistance = nil, 5.0
                    for _, playerId in ipairs(GetActivePlayers()) do
                        local targetPed = GetPlayerPed(playerId)
                        if targetPed ~= senderPed then
                            local targetCoords = GetEntityCoords(targetPed)
                            local distance = #(senderCoords - targetCoords)
                            if distance < closestDistance then
                                closestPlayer = GetPlayerServerId(playerId)
                                closestDistance = distance
                            end
                        end
                    end
                    if closestPlayer then
                        local senderName = GetPlayerName(PlayerId())
                        local phoneNumber = exports["lb-phone"]:GetPhoneNumber() or "Unknown-" .. senderId
                        local shareData = {
                            number = phoneNumber,
                            firstname = senderName,
                            lastname = "", -- Optional
                            email = "",    -- Optional
                            address = "",  -- Optional
                            avatar = ""    -- Optional
                        }
                        -- Use AirShare and ensure target receives it
                        exports["lb-phone"]:AirShare(senderId, closestPlayer, "contact", shareData)
                        -- Force client-side contact add on target
                        TriggerServerEvent('drp-radial:shareContact', closestPlayer, shareData)
                        ox_lib:notify({ title = "General", description = "Contact shared with nearby player!", type = 'success', position = 'top-right' })
                    else
                        ox_lib:notify({ title = "General", description = "No players nearby to share contact with!", type = 'error', position = 'top-right', icon = 'ban' })
                    end
                end 
            },
            {
                label = "Give Keys",
                icon = 'key',
                onSelect = function()
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if vehicle == 0 then
                        vehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
                    end
                    if vehicle ~= 0 then
                        local plate = GetVehicleNumberPlateText(vehicle)
                        local closestPlayer, closestDistance = nil, 5.0
                        local coords = GetEntityCoords(ped)
                        for _, playerId in ipairs(GetActivePlayers()) do
                            local targetPed = GetPlayerPed(playerId)
                            if targetPed ~= ped then
                                local targetCoords = GetEntityCoords(targetPed)
                                local distance = #(coords - targetCoords)
                                if distance < closestDistance then
                                    closestPlayer = GetPlayerServerId(playerId)
                                    closestDistance = distance
                                end
                            end
                        end
                        if closestPlayer then
                            exports.wasabi_carlock:GiveKey(closestPlayer, plate)
                            ox_lib:notify({ title = "General", description = "Gave vehicle keys to nearby player!", type = 'success', position = 'top-right' })
                        else
                            ox_lib:notify({ title = "General", description = "No players nearby to give keys to!", type = 'error', position = 'top-right', icon = 'ban' })
                        end
                    else
                        ox_lib:notify({ title = "General", description = "No vehicle nearby to give keys for!", type = 'error', position = 'top-right', icon = 'ban' })
                    end
                end
            },
            {
                id = 'corner_sell',
                label = 'Corner Sell',
                icon = 'cannabis',
                onSelect = function()
                    TriggerEvent('drp-drugs:client:toggleSelling')
                end
            }
        }
    })

    -- Force General into the radial menu with 'tools' icon
    ox_lib:addRadialItem({
        id = 'general',
        label = "General",
        icon = 'tools',
        menu = 'general_menu'
    })
end)