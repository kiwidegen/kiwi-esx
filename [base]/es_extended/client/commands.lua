RegisterNetEvent('esx:maxmodVehicle')
AddEventHandler('esx:maxmodVehicle', function()
    local ped     = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        lib.notify({ description = 'You must be in a vehicle', type = 'error' })
        return
    end

    SetVehicleModKit(vehicle, 0)

    -- Toggle mods
    ToggleVehicleMod(vehicle, 18, true)  -- Turbo
    ToggleVehicleMod(vehicle, 20, true)  -- Tyre Smoke
    ToggleVehicleMod(vehicle, 22, true)  -- Xenon Lights

    -- Indexed mods — skip 23 (front tyres) and 24 (rear tyres)
    local skipTypes = { [23] = true, [24] = true }

    for modType = 0, 48 do
        if not skipTypes[modType] then
            local count = GetNumVehicleMods(vehicle, modType)
            if count > 0 then
                SetVehicleMod(vehicle, modType, count - 1, false)
            end
        end
    end

    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    lib.notify({ description = 'Vehicle maxed', type = 'success' })
end)

RegisterNetEvent('esx:fixVehiclesRadius')
AddEventHandler('esx:fixVehiclesRadius', function(radius)
    local coords   = GetEntityCoords(PlayerPedId())
    local vehicles = GetGamePool('CVehicle')
    local count    = 0
    for _, vehicle in ipairs(vehicles) do
        if #(coords - GetEntityCoords(vehicle)) <= radius then
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
            count += 1
        end
    end
    lib.notify({ description = ('Repaired %s vehicle(s) within %sm'):format(count, radius), type = 'success' })
end)

RegisterNetEvent('esx:fixVehicle')
AddEventHandler('esx:fixVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        lib.notify({ description = 'You must be in a vehicle', type = 'error' })
        return
    end
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    lib.notify({ description = 'Vehicle repaired', type = 'success' })
end)

RegisterNetEvent('esx:spawnCar')
AddEventHandler('esx:spawnCar', function(model)
    local modelHash = joaat(model)

    if not IsModelValid(modelHash) then
        lib.notify({ description = 'Invalid model: ' .. model, type = 'error' })
        return
    end

    RequestModel(modelHash)
    local timer = GetGameTimer()
    while not HasModelLoaded(modelHash) and (GetGameTimer() - timer) < 5000 do
        Wait(0)
    end

    if not HasModelLoaded(modelHash) then
        lib.notify({ description = 'Failed to load model: ' .. model, type = 'error' })
        return
    end

    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local current = GetVehiclePedIsIn(ped, false)
    if current ~= 0 then DeleteEntity(current) end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(modelHash)

    lib.notify({ description = 'Spawned ' .. model, type = 'success' })
end)

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function()
    local ped     = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
    end

    if vehicle ~= 0 then
        DeleteEntity(vehicle)
        lib.notify({ description = 'Vehicle deleted', type = 'success' })
    else
        lib.notify({ description = 'No vehicle nearby', type = 'error' })
    end
end)
