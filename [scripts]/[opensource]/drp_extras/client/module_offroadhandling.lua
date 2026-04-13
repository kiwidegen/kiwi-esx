-- Module guard
if not ExtrasConfig.Modules.OffRoadHandling then return end

--============================================================
--  OFF-ROAD HANDLING MODIFIER
--  Reduces car performance off-road while keeping bikes/4x4s unaffected
--============================================================

local isOffRoad = false
local lastVehicle = 0
local checkThread = nil
local originalHandling = {}

--- Vehicle classes that are immune to off-road penalties
---@type table<number, boolean>
local immuneClasses = {
    [8] = true,   -- Motorcycles
    [13] = true,  -- Cycles
    [9] = true,   -- SUVs/Off-road vehicles
    [15] = true,  -- Helicopters
    [16] = true,  -- Planes
    [14] = true   -- Boats
}

--- Check if surface material is considered off-road
---@param material number Surface material ID
---@return boolean isOffRoad Whether surface is off-road
local function isOffRoadSurface(material)
    -- Common off-road materials in GTA V
    local offRoadMaterials = {
        [0] = true,   -- Default/Dirt
        [1] = true,   -- Grass
        [2] = true,   -- Gravel
        [3] = true,   -- Mud
        [4] = true,   -- Sand
        [5] = true,   -- Wood
        [7] = true,   -- Dirt
        [8] = true,   -- Grass short
        [9] = true,   -- Grass long
        [12] = true,  -- Grass dried
        [13] = true,  -- Sand wet
        [14] = true,  -- Sand dry
        [24] = true,  -- Dirt/Gravel
        [25] = true,  -- Gravel deep
        [27] = true,  -- Grass/Dirt mix
    }

    return offRoadMaterials[material] == true
end

--- Store original handling values for a vehicle
---@param vehicle number Vehicle entity
local function storeOriginalHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local vehId = VehToNet(vehicle)
    if not originalHandling[vehId] then
        originalHandling[vehId] = {
            tractionCurveMax = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax'),
            tractionCurveMin = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin'),
            tractionLossMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult')
        }
    end
end

--- Apply off-road handling modifiers to vehicle
---@param vehicle number Vehicle entity
local function applyOffRoadHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end

    -- Store original values first
    storeOriginalHandling(vehicle)

    -- Reduce traction moderately
    SetVehicleReduceGrip(vehicle, true)

    -- Apply handling modifiers (multiply by the config values)
    local vehId = VehToNet(vehicle)
    if originalHandling[vehId] then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax',
            originalHandling[vehId].tractionCurveMax * ExtrasConfig.OffRoadHandling.TractionMultiplier)
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin',
            originalHandling[vehId].tractionCurveMin * ExtrasConfig.OffRoadHandling.TractionMultiplier)
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult',
            originalHandling[vehId].tractionLossMult * ExtrasConfig.OffRoadHandling.TractionLossMultiplier)
    end
end

--- Restore normal handling to vehicle
---@param vehicle number Vehicle entity
local function restoreNormalHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end

    SetVehicleReduceGrip(vehicle, false)

    -- Restore original handling values
    local vehId = VehToNet(vehicle)
    if originalHandling[vehId] then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax',
            originalHandling[vehId].tractionCurveMax)
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin',
            originalHandling[vehId].tractionCurveMin)
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult',
            originalHandling[vehId].tractionLossMult)
    end
end

--- Main off-road check thread
local function startOffRoadThread()
    if checkThread then return end

    checkThread = true
    CreateThread(function()
        while checkThread do
            Wait(ExtrasConfig.OffRoadHandling.CheckInterval)

            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local driver = GetPedInVehicleSeat(vehicle, -1)

                -- Only affect if player is driver
                if driver == ped then
                    local vehClass = GetVehicleClass(vehicle)

                    -- Check if vehicle is immune to off-road penalties
                    if not immuneClasses[vehClass] then
                        -- Get vehicle position and check surface below
                        local coords = GetEntityCoords(vehicle)
                        local rayHandle = StartShapeTestRay(
                            coords.x, coords.y, coords.z,
                            coords.x, coords.y, coords.z - 3.0,
                            1, -- Hit geometry
                            vehicle,
                            7
                        )

                        local _, hit, _, _, material = GetShapeTestResult(rayHandle)

                        if hit and isOffRoadSurface(material) then
                            if not isOffRoad then
                                isOffRoad = true
                                lastVehicle = vehicle
                                applyOffRoadHandling(vehicle)

                                if ExtrasConfig.OffRoadHandling.ShowNotification and lib then
                                    lib.notify({
                                        description = 'Vehicle traction reduced off-road',
                                        type = 'inform',
                                        duration = 3000
                                    })
                                end
                            end
                        else
                            if isOffRoad then
                                isOffRoad = false
                                restoreNormalHandling(vehicle)

                                if ExtrasConfig.OffRoadHandling.ShowNotification and lib then
                                    lib.notify({
                                        description = 'Vehicle traction restored',
                                        type = 'success',
                                        duration = 2000
                                    })
                                end
                            end
                        end
                    end
                end
            else
                -- Player exited vehicle
                if isOffRoad and DoesEntityExist(lastVehicle) then
                    restoreNormalHandling(lastVehicle)
                    isOffRoad = false
                    lastVehicle = 0
                end
            end
        end

        checkThread = nil
    end)
end

--- Stop off-road check thread
local function stopOffRoadThread()
    checkThread = nil

    if isOffRoad and DoesEntityExist(lastVehicle) then
        restoreNormalHandling(lastVehicle)
        isOffRoad = false
        lastVehicle = 0
    end
end

-- Start thread when resource starts
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    startOffRoadThread()
end)

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    stopOffRoadThread()
end)

-- Start thread immediately
startOffRoadThread()
