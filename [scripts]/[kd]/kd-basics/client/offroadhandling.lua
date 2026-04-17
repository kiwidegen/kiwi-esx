-- ╔══════════════════════════════╗
-- ║      Offroad Handling        ║
-- ╚══════════════════════════════╝
if not Config.Modules.OffRoadHandling then return end

local cfg = Config.OffRoadHandling

local immuneClasses = { [8]=true, [9]=true, [13]=true, [14]=true, [15]=true, [16]=true }

local offRoadMaterials = {
    [0]=true,  [1]=true,  [2]=true,  [3]=true,  [4]=true,
    [5]=true,  [7]=true,  [8]=true,  [9]=true,  [12]=true,
    [13]=true, [14]=true, [24]=true, [25]=true, [27]=true,
}

local originalHandling = {}

local function storeHandling(vehicle)
    local id = VehToNet(vehicle)
    if not originalHandling[id] then
        originalHandling[id] = {
            tractionCurveMax = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax'),
            tractionCurveMin = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin'),
            tractionLossMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult'),
        }
    end
end

local function applyOffRoad(vehicle)
    storeHandling(vehicle)
    SetVehicleReduceGrip(vehicle, true)
    local h = originalHandling[VehToNet(vehicle)]
    if not h then return end
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax',          h.tractionCurveMax * cfg.tractionMultiplier)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin',          h.tractionCurveMin * cfg.tractionMultiplier)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult',  h.tractionLossMult * cfg.tractionLossMultiplier)
end

local function restoreHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end
    SetVehicleReduceGrip(vehicle, false)
    local h = originalHandling[VehToNet(vehicle)]
    if not h then return end
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax',         h.tractionCurveMax)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin',         h.tractionCurveMin)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', h.tractionLossMult)
end

-- Thread spawns only while in a vehicle. Exits via lib.onCache when vehicle changes.
lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    if immuneClasses[GetVehicleClass(vehicle)] then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return end

    local isOffRoad = false

    CreateThread(function()
        while cache.vehicle == vehicle do
            Wait(cfg.checkInterval)

            local coords = GetEntityCoords(vehicle)
            local _, hit, _, _, material = GetShapeTestResult(StartShapeTestRay(
                coords.x, coords.y, coords.z,
                coords.x, coords.y, coords.z - 3.0,
                1, vehicle, 7
            ))

            if hit and offRoadMaterials[material] then
                if not isOffRoad then
                    isOffRoad = true
                    applyOffRoad(vehicle)
                    if cfg.showNotification then
                        lib.notify({ description = 'Traction reduced off-road', type = 'inform', duration = 3000 })
                    end
                end
            else
                if isOffRoad then
                    isOffRoad = false
                    restoreHandling(vehicle)
                    if cfg.showNotification then
                        lib.notify({ description = 'Traction restored', type = 'success', duration = 2000 })
                    end
                end
            end
        end

        if isOffRoad then restoreHandling(vehicle) end
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local vehicle = cache.vehicle
    if vehicle then restoreHandling(vehicle) end
end)
