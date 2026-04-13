---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()
local inRange = false
local currentLocation = nil

--- Create blips for all car wash locations
CreateThread(function()
    for k, v in pairs(Config.Carwash.Locations) do
        local blip = AddBlipForCoord(v.coords)
        SetBlipSprite(blip, 100)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Car Wash')
        EndTextCommandSetBlipName(blip)
    end
end)

--- Main proximity check loop
CreateThread(function()
    local ped = 0
    local coords = vec3(0, 0, 0)
    local vehicle = 0
    local isDriver = false

    while true do
        local sleep = 1000
        ped = PlayerPedId()

        local wasInRange = inRange
        inRange = false
        currentLocation = nil

        if IsPedInAnyVehicle(ped, false) then
            vehicle = GetVehiclePedIsIn(ped, false)
            isDriver = GetPedInVehicleSeat(vehicle, -1) == ped

            if isDriver then
                coords = GetEntityCoords(ped)

                for k, v in pairs(Config.Carwash.Locations) do
                    local distance = #(coords - v.coords)

                    if distance <= 4.0 then
                        sleep = 0
                        inRange = true
                        currentLocation = k

                        if GetVehicleDirtLevel(vehicle) > 0.5 then
                            lib.showTextUI('[E] - Wash vehicle for $' .. v.price, {
                                position = "left-center"
                            })

                            if IsControlJustPressed(0, 38) then
                                lib.hideTextUI()

                                ESX.TriggerServerCallback('drp_carwash:checkMoney', function(hasMoney)
                                    if hasMoney then
                                        FreezeEntityPosition(vehicle, true)

                                        if lib.progressCircle({
                                            duration = Config.Carwash.WashDuration,
                                            position = 'bottom',
                                            label = 'Washing vehicle...',
                                            useWhileDead = false,
                                            canCancel = false,
                                            disable = {
                                                car = true,
                                                move = true,
                                                combat = true,
                                            }
                                        }) then
                                            FreezeEntityPosition(vehicle, false)
                                            SetVehicleDirtLevel(vehicle, 0.0)

                                            lib.notify({
                                                title = 'Car Wash',
                                                description = 'Your vehicle has been washed for $' .. v.price,
                                                type = 'success'
                                            })
                                        else
                                            FreezeEntityPosition(vehicle, false)
                                        end
                                    else
                                        lib.notify({
                                            title = 'Car Wash',
                                            description = 'You don\'t have enough money!',
                                            type = 'error'
                                        })
                                    end
                                end, v.price)
                            end
                        else
                            lib.showTextUI('Vehicle is already clean', {
                                position = "left-center"
                            })
                        end
                        break
                    end
                end
            end
        end

        if wasInRange and not inRange then
            lib.hideTextUI()
        end

        Wait(sleep)
    end
end)
