--- Event handler for opening revive radius dialog
RegisterNetEvent('drp_admin:reviveRadius:openDialog', function()
    OpenReviveRadiusDialog()
end)

--- Event handler for opening teleport group dialog
RegisterNetEvent('drp_admin:teleportGroup:openDialog', function()
    OpenTeleportGroupDialog()
end)

--- Event handler for setting job options
---@param options table[] Job options array
RegisterNetEvent('drp_admin:teleportGroup:setJobOptions', function(options)
    JobOptions = options
    Utils.Debug('Received ' .. #options .. ' job options for teleport group dialog')
end)

--- Event handler for opening delete cars dialog
RegisterNetEvent('drp_admin:deleteVehicles:openDialog', function()
    OpenDeleteCarsDialog()
end)

--- Event handler for opening spawn menu
RegisterNetEvent('drp_admin:openSpawnMenu', function()
    OpenSpawnMenu()
end)

--- Event handler for reviving player (using natives)
RegisterNetEvent('drp_admin:revive', function()
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) then
        local coords = GetEntityCoords(playerPed)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        ClearPedTasksImmediately(playerPed)
        SetPlayerInvincible(playerPed, false)
        Utils.Debug('Player ' .. GetPlayerServerId(PlayerId()) .. ' revived using natives')
    end
end)

--- Event handler for teleporting player
---@param coords vector3 Target coordinates
RegisterNetEvent('drp_admin:teleportGroup:teleport', function(coords)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
    Utils.Debug('Player ' .. GetPlayerServerId(PlayerId()) .. ' teleported to ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z)
end)

--- Event handler for deleting vehicles in radius
---@param centerCoords vector3 Center coordinates
---@param radius number Radius in meters
RegisterNetEvent('drp_admin:deleteVehicles:delete', function(centerCoords, radius)
    DeleteVehiclesInRadius(centerCoords, radius)
end)

--- Event handler for opening event cars dialog
RegisterNetEvent('drp_admin:eventCars:openDialog', function()
    OpenEventCarsDialog()
end)

--- Event handler for opening event guns dialog
RegisterNetEvent('drp_admin:eventGuns:openDialog', function()
    OpenEventGunsDialog()
end)

--- Event handler for opening remove guns dialog
RegisterNetEvent('drp_admin:removeGuns:openDialog', function()
    OpenRemoveGunsDialog()
end)

--- Event handler for maxing vehicle mods
RegisterNetEvent('drp_admin:maxMods', function()
    MaxModsVehicle()
end)

--- Event handler for opening fix vehicles dialog
RegisterNetEvent('drp_admin:fixVehicles:openDialog', function()
    OpenFixVehiclesDialog()
end)

--- Event handler for repairing vehicles in radius
---@param centerCoords vector3 Center coordinates
---@param radius number Radius in meters
RegisterNetEvent('drp_admin:fixVehicles:repair', function(centerCoords, radius)
    RepairVehiclesInRadius(centerCoords, radius)
end)

--- Event handler for applying max mods to a vehicle
---@param netId number Network ID of vehicle
RegisterNetEvent('drp_admin:applyMaxMods', function(netId)
    local vehicle = NetToVeh(netId)

    if vehicle and vehicle ~= 0 then
        -- Wait for vehicle to exist locally
        local timeout = 0
        while not DoesEntityExist(vehicle) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end

        if DoesEntityExist(vehicle) then
            Utils.Debug('[MODS-CLIENT] Applying max mods to vehicle netId: ' .. netId)

            -- Set max performance mods
            SetVehicleModKit(vehicle, 0)

            -- Engine (11), Brakes (12), Transmission (13), Suspension (15), Armor (16)
            SetVehicleMod(vehicle, 11, GetNumVehicleMods(vehicle, 11) - 1, false) -- Engine
            SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false) -- Brakes
            SetVehicleMod(vehicle, 13, GetNumVehicleMods(vehicle, 13) - 1, false) -- Transmission
            SetVehicleMod(vehicle, 15, GetNumVehicleMods(vehicle, 15) - 1, false) -- Suspension
            SetVehicleMod(vehicle, 16, GetNumVehicleMods(vehicle, 16) - 1, false) -- Armor

            -- Turbo (18)
            ToggleVehicleMod(vehicle, 18, true)

            Utils.Debug('[MODS-CLIENT] Max mods applied to vehicle netId: ' .. netId)
        else
            Utils.Debug('[MODS-CLIENT] ERROR: Vehicle does not exist after timeout')
        end
    else
        Utils.Debug('[MODS-CLIENT] ERROR: Invalid vehicle handle from NetToVeh')
    end
end)
