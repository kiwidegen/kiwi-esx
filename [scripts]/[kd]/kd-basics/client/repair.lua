-- ╔══════════════════════════════╗
-- ║           Repair             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Repair then return end

local ESX = exports['es_extended']:getSharedObject()
local cfg = Config.Repair

-- ─── State ───────────────────────────────────────────────────────────────────

local pedInSameVehicleLast = false
local lastVehicle          = nil

local healthEngineLast     = 1000.0
local healthEngineNew      = 1000.0
local healthBodyLast       = 1000.0
local healthBodyNew        = 1000.0
local healthPetrolTankLast = 1000.0
local healthPetrolTankNew  = 1000.0

local fCollisionDamageMult  = 0.0
local fDeformationDamageMult = 0.0
local fEngineDamageMult     = 0.0
local fBrakeForce           = 1.0

local wasAirborne           = false
local airborneVelZ          = 0.0

local tireBurstMaxNumber    = cfg.randomTireBurstInterval * 1200
local tireBurstLuckyNumber  = nil
if cfg.randomTireBurstInterval ~= 0 then
    math.randomseed(GetGameTimer())
    tireBurstLuckyNumber = math.random(tireBurstMaxNumber)
end

local function tireBurstLottery(vehicle)
    if not tireBurstLuckyNumber then return end
    local roll = math.random(tireBurstMaxNumber)
    if roll ~= tireBurstLuckyNumber then return end
    if not GetVehicleTyresCanBurst(vehicle) then return end

    local numWheels = GetVehicleNumberOfWheels(vehicle)
    local tire
    if numWheels == 2 then
        tire = (math.random(2) - 1) * 4
    elseif numWheels == 4 then
        tire = math.random(4) - 1
        if tire > 1 then tire = tire + 2 end
    elseif numWheels == 6 then
        tire = math.random(6) - 1
    else
        tire = 0
    end

    SetVehicleTyreBurst(vehicle, tire, false, 1000.0)
    tireBurstLuckyNumber = math.random(tireBurstMaxNumber)
end

-- ─── Prevent wheel-spin righting ─────────────────────────────────────────────
-- Blocks GTA's default mechanic of spinning wheels to right a rolled vehicle.
-- Wait(0) justified — DisableControlAction must fire every frame to suppress input.

lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    CreateThread(function()
        while cache.vehicle == vehicle do
            local roll = GetEntityRoll(vehicle)
            if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
                DisableControlAction(2, 59, true)
                DisableControlAction(2, 60, true)
                Wait(0)
            else
                Wait(200)
            end
        end
    end)
end)

-- ─── Reset health tracking (called after any repair) ─────────────────────────

AddEventHandler('kd-basics:resetRepairState', function(engine, petrol, body)
    healthEngineLast     = engine or 1000.0
    healthEngineNew      = engine or 1000.0
    healthPetrolTankLast = petrol or 1000.0
    healthPetrolTankNew  = petrol or 1000.0
    healthBodyLast       = body   or 1000.0
    healthBodyNew        = body   or 1000.0
end)

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function isDriverSeat()
    local ped = cache.ped
    if not IsPedInAnyVehicle(ped, false) then return false end
    local veh = GetVehiclePedIsIn(ped, false)
    local class = GetVehicleClass(veh)
    return GetPedInVehicleSeat(veh, -1) == ped and class ~= 21 and class ~= 13
end

-- ─── Damage simulation loop ───────────────────────────────────────────────────

CreateThread(function()
    while true do
        if not isDriverSeat() then
            if pedInSameVehicleLast then
                -- restore handling on exit
                local lv = lastVehicle
                if DoesEntityExist(lv) then
                    if cfg.deformationMultiplier ~= -1 then
                        SetVehicleHandlingFloat(lv, 'CHandlingData', 'fDeformationDamageMult', fDeformationDamageMult)
                    end
                    SetVehicleHandlingFloat(lv, 'CHandlingData', 'fBrakeForce', fBrakeForce)
                    if cfg.weaponsDamageMultiplier ~= -1 then
                        SetVehicleHandlingFloat(lv, 'CHandlingData', 'fWeaponDamageMult', cfg.weaponsDamageMultiplier)
                    end
                    SetVehicleHandlingFloat(lv, 'CHandlingData', 'fCollisionDamageMult', fCollisionDamageMult)
                    SetVehicleHandlingFloat(lv, 'CHandlingData', 'fEngineDamageMult', fEngineDamageMult)
                end
            end
            pedInSameVehicleLast = false
            Wait(1000)
        else
            local ped     = cache.ped
            local vehicle = GetVehiclePedIsIn(ped, false)
            local class   = GetVehicleClass(vehicle)

            local engineCurrent    = GetVehicleEngineHealth(vehicle)
            local bodyCurrent      = GetVehicleBodyHealth(vehicle)
            local petrolCurrent    = GetVehiclePetrolTankHealth(vehicle)

            if engineCurrent == 1000.0 then healthEngineLast     = 1000.0 end
            if bodyCurrent   == 1000.0 then healthBodyLast       = 1000.0 end
            if petrolCurrent == 1000.0 then healthPetrolTankLast = 1000.0 end

            if engineCurrent > cfg.engineSafeGuard + 1 then
                SetVehicleUndriveable(vehicle, false)
            end
            if engineCurrent <= cfg.engineSafeGuard + 1 and not cfg.limpMode then
                SetVehicleUndriveable(vehicle, true)
            end

            if vehicle ~= lastVehicle then
                pedInSameVehicleLast = false
                wasAirborne          = false
                airborneVelZ         = 0.0
                healthEngineLast     = GetVehicleEngineHealth(vehicle)
                healthEngineNew      = healthEngineLast
                healthBodyLast       = GetVehicleBodyHealth(vehicle)
                healthBodyNew        = healthBodyLast
                healthPetrolTankLast = GetVehiclePetrolTankHealth(vehicle)
                healthPetrolTankNew  = healthPetrolTankLast
            end

            if not pedInSameVehicleLast then
                -- first tick in this vehicle — store and modify handling
                fDeformationDamageMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDeformationDamageMult')
                fBrakeForce            = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce')
                fCollisionDamageMult   = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCollisionDamageMult')
                fEngineDamageMult      = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fEngineDamageMult')

                if cfg.deformationMultiplier ~= -1 then
                    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDeformationDamageMult', (fDeformationDamageMult ^ cfg.deformationExponent) * cfg.deformationMultiplier)
                end
                if cfg.weaponsDamageMultiplier ~= -1 then
                    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fWeaponDamageMult', cfg.weaponsDamageMultiplier / cfg.damageFactorBody)
                end
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCollisionDamageMult', fCollisionDamageMult ^ cfg.collisionDamageExponent)
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fEngineDamageMult',    fEngineDamageMult    ^ cfg.engineDamageExponent)

                if bodyCurrent < cfg.cascadingFailureThreshold then
                    healthBodyNew = cfg.cascadingFailureThreshold
                end

                pedInSameVehicleLast = true
            else
                -- ongoing damage tracking
                if engineCurrent ~= 1000.0 or bodyCurrent ~= 1000.0 or petrolCurrent ~= 1000.0 then
                    local mult = cfg.classDamageMultiplier[class] or 0.2

                    local engineDelta    = (healthEngineLast    - engineCurrent)  * cfg.damageFactorEngine    * mult
                    local bodyDelta      = (healthBodyLast      - bodyCurrent)    * cfg.damageFactorBody      * mult
                    local petrolDelta    = (healthPetrolTankLast - petrolCurrent) * cfg.damageFactorPetrolTank * mult

                    local combinedDelta = math.max(engineDelta, bodyDelta, petrolDelta)

                    if combinedDelta > (engineCurrent - cfg.engineSafeGuard) then
                        combinedDelta = combinedDelta * 0.7
                    end
                    if combinedDelta > engineCurrent then
                        combinedDelta = engineCurrent - (cfg.cascadingFailureThreshold / 5)
                    end

                    healthEngineNew = healthEngineLast - combinedDelta

                    if healthEngineNew > cfg.cascadingFailureThreshold + 5 and healthEngineNew < cfg.degradingFailureThreshold then
                        healthEngineNew = healthEngineNew - (0.038 * cfg.degradingHealthSpeedFactor)
                    end
                    if healthEngineNew < cfg.cascadingFailureThreshold then
                        healthEngineNew = healthEngineNew - (0.1 * cfg.cascadingFailureSpeedFactor)
                    end
                    if healthEngineNew < cfg.engineSafeGuard then
                        healthEngineNew = cfg.engineSafeGuard
                    end

                    if not cfg.compatibilityMode and petrolCurrent < 750 then
                        healthPetrolTankNew = 750.0
                    end
                    if healthBodyNew < 0 then healthBodyNew = 0.0 end
                end

                -- torque multiplier
                if cfg.torqueMultiplierEnabled or cfg.limpMode then
                    local factor = 1.0
                    if cfg.torqueMultiplierEnabled and healthEngineNew < 900 then
                        factor = (healthEngineNew + 200.0) / 1100
                    end
                    if cfg.limpMode and healthEngineNew < cfg.engineSafeGuard + 5 then
                        factor = cfg.limpModeMultiplier
                    end
                    SetVehicleEngineTorqueMultiplier(vehicle, factor)
                end

                if healthEngineNew    ~= engineCurrent  then SetVehicleEngineHealth(vehicle, healthEngineNew) end
                if healthBodyNew      ~= bodyCurrent     then SetVehicleBodyHealth(vehicle, healthBodyNew) end
                if healthPetrolTankNew ~= petrolCurrent  then SetVehiclePetrolTankHealth(vehicle, healthPetrolTankNew) end

                -- ─── Jump / impact tyre damage ───────────────────────────────
                local onGround = GetEntityHeightAboveGround(vehicle) < 2.2
                if not onGround then
                    wasAirborne  = true
                    airborneVelZ = GetEntityVelocity(vehicle).z
                elseif wasAirborne then
                    wasAirborne  = false
                    local impact = math.abs(airborneVelZ)
                    if impact >= cfg.jumpDamageThreshold and GetVehicleTyresCanBurst(vehicle) then
                        local numWheels = GetVehicleNumberOfWheels(vehicle)
                        local function randTyre()
                            local t = math.random(numWheels) - 1
                            if numWheels == 4 and t > 1 then t = t + 2 end
                            return t
                        end
                        SetVehicleTyreBurst(vehicle, randTyre(), false, 1000.0)
                        if impact >= cfg.jumpSevereThreshold then
                            SetVehicleTyreBurst(vehicle, randTyre(), false, 1000.0)
                        end
                    end
                end

                if cfg.randomTireBurstInterval ~= 0 and GetEntitySpeed(vehicle) > 10 then
                    tireBurstLottery(vehicle)
                end
            end

            healthEngineLast     = healthEngineNew
            healthBodyLast       = healthBodyNew
            healthPetrolTankLast = healthPetrolTankNew
            lastVehicle          = vehicle

            Wait(200)
        end
    end
end)

