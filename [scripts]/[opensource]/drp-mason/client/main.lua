local function hasRequiredJob()
    if not ESX then
        ESX = exports['es_extended']:getSharedObject()
    end

    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.job then
        return false
    end

    for _, job in ipairs(Config.AllowedJobs) do
        if playerData.job.name == job then
            return true
        end
    end
    return false
end

local function repairVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        lib.notify({
            title = 'Error',
            description = 'You must be in a vehicle',
            type = 'error'
        })
        return
    end

    if not hasRequiredJob() then
        lib.notify({
            title = 'Error',
            description = 'You do not have permission to repair vehicles here',
            type = 'error'
        })
        return
    end

    if lib.progressCircle({
        duration = Config.RepairTime,
        position = 'bottom',
        label = 'Repairing vehicle...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        }
    }) then
        TriggerServerEvent('vehiclerepair:repairVehicle', NetworkGetNetworkIdFromEntity(vehicle))
    else
        lib.notify({
            title = 'Cancelled',
            description = 'Repair cancelled',
            type = 'error'
        })
    end
end

for i, spot in ipairs(Config.RepairSpots) do
    local point = lib.points.new({
        coords = vec3(spot.x, spot.y, spot.z),
        distance = Config.MarkerSettings.distance
    })

    function point:onEnter()
        lib.showTextUI('[E] Repair Vehicle', {
            position = "left-center"
        })
    end

    function point:onExit()
        lib.hideTextUI()
    end

    function point:nearby()
        if self.currentDistance < Config.MarkerSettings.interactDistance then
            DrawMarker(
                Config.MarkerSettings.type,
                spot.x, spot.y, spot.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                Config.MarkerSettings.size.x,
                Config.MarkerSettings.size.y,
                Config.MarkerSettings.size.z,
                Config.MarkerSettings.color.r,
                Config.MarkerSettings.color.g,
                Config.MarkerSettings.color.b,
                Config.MarkerSettings.color.a,
                false, true, 2, false, nil, nil, false
            )

            if IsControlJustReleased(0, 38) then -- E key
                repairVehicle()
            end
        end
    end
end

RegisterNetEvent('vehiclerepair:doRepair', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(vehicle) then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
    end
end)
