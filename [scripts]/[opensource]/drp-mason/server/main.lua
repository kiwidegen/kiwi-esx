ESX = exports['es_extended']:getSharedObject()

local function hasRequiredJob(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    for _, job in ipairs(Config.AllowedJobs) do
        if xPlayer.job.name == job then
            return true
        end
    end
    return false
end

RegisterNetEvent('vehiclerepair:repairVehicle', function(netId)
    local src = source

    -- Anti-cheat: Verify player has required job
    if not hasRequiredJob(src) then
        print(('[WARNING] Player %s attempted to repair vehicle without permission'):format(src))
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if not DoesEntityExist(vehicle) then
        return
    end

    -- Repair the vehicle (client-side execution via event)
    TriggerClientEvent('vehiclerepair:doRepair', src, netId)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Success',
        description = 'Vehicle repaired',
        type = 'success'
    })
end)
