if not ExtrasConfig.Modules.Seatbelt then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('Seatbelt module loaded')

local cfg = ExtrasConfig.Seatbelt

-- State tracking
local seatbeltOn = false
local lastVehicle = nil
local handbrake = 0
local damageDone = false
local tick = 0

-- Speed and damage tracking
local lastFrameSpeed = 0
local lastFrameSpeed2 = 0
local currentBodyHealth = 0
local newBodyHealth = 0
local frameBodyChange = 0
local velocity = vector3(0.0, 0.0, 0.0)

--============================================================
--  HUD INTEGRATION
--============================================================
local function UpdateHUD(enabled)
    if not cfg.UseHUDExport then return end

    local success, err = pcall(function()
        exports[cfg.HUDResource]:SetSeatbelt(enabled)
    end)

    if not success then
        Core.DebugPrint('Failed to update HUD seatbelt status:', err)
    end
end

--============================================================
--  SOUND EFFECTS
--============================================================
local function PlaySeatbeltSound(buckle)
    local soundName = buckle and cfg.BuckleSound or cfg.UnbuckleSound

    -- Play sound via NUI
    SendNUIMessage({
        action = 'play',
        sound = soundName,
        volume = cfg.SoundVolume
    })

    Core.DebugPrint('Playing seatbelt sound: ' .. soundName)
end

--============================================================
--  SEATBELT TOGGLE
--============================================================
local function ToggleSeatbelt()
    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local class = GetVehicleClass(vehicle)

    -- Check if vehicle class is excluded
    if cfg.ExcludedClasses[class] then
        return
    end

    seatbeltOn = not seatbeltOn

    PlaySeatbeltSound(seatbeltOn)
    UpdateHUD(seatbeltOn)

    Core.DebugPrint('Seatbelt ' .. (seatbeltOn and 'fastened' or 'unfastened'))
end

--============================================================
--  EJECTION LOGIC
--============================================================
local function EjectFromVehicle(ped, speed)
    local veh = GetVehiclePedIsIn(ped, false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)

    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(1)

    SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(ped, velocity.x * 4, velocity.y * 4, velocity.z * 4)

    local ejectDamage = math.ceil(speed * cfg.EjectDamageMultiplier)
    local currentHealth = GetEntityHealth(ped)

    if currentHealth - ejectDamage > 0 then
        SetEntityHealth(ped, currentHealth - ejectDamage)
    elseif currentHealth ~= 0 then
        SetEntityHealth(ped, 0)
    end

    Core.DebugPrint('Player ejected at ' .. math.ceil(speed) .. ' km/h, damage: ' .. ejectDamage)
end

local function ShouldEjectPlayer(currentVehicle, thisFrameSpeed)
    -- Don't eject if seatbelt is on
    if seatbeltOn then
        return false
    end

    -- Don't eject from bikes
    if IsThisModelABike(currentVehicle) then
        return false
    end

    -- Check if we had significant damage
    if frameBodyChange <= 0 then
        return false
    end

    -- High speed collision check
    if lastFrameSpeed > 110 and thisFrameSpeed < (lastFrameSpeed * 0.75) then
        if frameBodyChange > cfg.MinDamageForEjection then
            return math.random(math.ceil(lastFrameSpeed)) > cfg.MinSpeedForEjection
        else
            return math.random(math.ceil(lastFrameSpeed)) > cfg.MinSpeedForEjection
        end
    end

    -- Very low body health check
    if currentBodyHealth < 350.0 then
        return true
    end

    return false
end

--============================================================
--  HANDBRAKE TRACKING
--============================================================
local function ResetHandBrake()
    if handbrake > 0 then
        handbrake = handbrake - 1
    end
end

--============================================================
--  MAIN SEATBELT CONTROL THREAD
--============================================================
CreateThread(function()
    while true do
        local sleep = 500

        if seatbeltOn then
            sleep = 0
            -- Disable vehicle exit if seatbelt is on
            DisableControlAction(0, 75, true)  -- Vehicle Exit
            DisableControlAction(27, 75, true) -- Vehicle Exit (alternative)
        else
            -- Check if we need to reset seatbelt when exiting vehicle
            local ped = PlayerPedId()
            if not IsPedInAnyVehicle(ped, false) and lastVehicle ~= nil then
                -- Player just exited vehicle, seatbelt already off
                sleep = 1000
            end
        end

        Wait(sleep)
    end
end)

--============================================================
--  CRASH DETECTION & EJECTION THREAD
--============================================================
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(ped, false)

        if currentVehicle ~= 0 then
            sleep = 100  -- Check every 100ms when in vehicle
            SetPedHelmet(ped, false)
            lastVehicle = currentVehicle

            -- Prevent negative engine health
            if GetVehicleEngineHealth(currentVehicle) < 0.0 then
                SetVehicleEngineHealth(currentVehicle, 0.0)
            end

            -- Handbrake tracking
            if GetVehicleHandbrake(currentVehicle) or
               math.abs(GetVehicleSteeringAngle(currentVehicle)) > 25.0 then
                if handbrake == 0 then
                    handbrake = 100
                    ResetHandBrake()
                else
                    handbrake = 100
                end
            end

            -- Speed and damage tracking
            local thisFrameSpeed = GetEntitySpeed(currentVehicle) * 3.6
            currentBodyHealth = GetVehicleBodyHealth(currentVehicle)

            -- Reset frame body change if vehicle is fully repaired
            if currentBodyHealth == 1000 and frameBodyChange ~= 0 then
                frameBodyChange = 0
            end

            -- Check for ejection conditions
            if frameBodyChange ~= 0 and not damageDone then
                if ShouldEjectPlayer(currentVehicle, thisFrameSpeed) then
                    EjectFromVehicle(ped, GetEntitySpeed(currentVehicle) * 3.6)
                end

                damageDone = true
                -- SetVehicleEngineOn(currentVehicle, false, true, true)  -- REMOVED: Was causing unwanted stalling
            end

            -- Damage calculation and cooldown
            if currentBodyHealth < 350.0 and not damageDone then
                damageDone = true
                -- SetVehicleEngineOn(currentVehicle, false, true, true)  -- REMOVED: Was causing unwanted stalling
                sleep = 1000
            end

            -- Speed buffer management (optimize tick reset)
            if lastFrameSpeed < 100 then
                tick = 0
            end

            frameBodyChange = newBodyHealth - currentBodyHealth

            if tick > 0 then
                tick = tick - 1
                if tick == 1 then
                    lastFrameSpeed = GetEntitySpeed(currentVehicle) * 3.6
                end
            else
                if damageDone then
                    damageDone = false
                    frameBodyChange = 0
                    lastFrameSpeed = GetEntitySpeed(currentVehicle) * 3.6
                end

                lastFrameSpeed2 = GetEntitySpeed(currentVehicle) * 3.6

                if lastFrameSpeed2 > lastFrameSpeed then
                    lastFrameSpeed = GetEntitySpeed(currentVehicle) * 3.6
                end

                if lastFrameSpeed2 < lastFrameSpeed then
                    tick = 25
                end
            end

            velocity = GetEntityVelocity(currentVehicle)

            if tick < 0 then
                tick = 0
            end

            newBodyHealth = GetVehicleBodyHealth(currentVehicle)

        else
            -- Player exited vehicle
            if lastVehicle ~= nil then
                SetPedHelmet(ped, true)
                newBodyHealth = GetVehicleBodyHealth(lastVehicle)

                if not damageDone and newBodyHealth < currentBodyHealth then
                    damageDone = true
                    -- SetVehicleEngineOn(lastVehicle, false, true, true)  -- REMOVED: Was causing unwanted stalling
                end

                lastVehicle = nil
            end

            -- Reset tracking variables
            lastFrameSpeed2 = 0
            lastFrameSpeed = 0
            newBodyHealth = 0
            currentBodyHealth = 0
            frameBodyChange = 0
        end

        Wait(sleep)
    end
end)

--============================================================
--  COMMANDS & KEYBINDS
--============================================================
RegisterCommand('toggleseatbelt', function()
    ToggleSeatbelt()
end, false)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', cfg.ToggleKey)

--============================================================
--  EVENTS
--============================================================
RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    ToggleSeatbelt()
end)

--============================================================
--  EXPORTS
--============================================================
exports('GetSeatbeltStatus', function()
    return seatbeltOn
end)

exports('SetSeatbelt', function(enabled)
    if type(enabled) ~= 'boolean' then return end

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local class = GetVehicleClass(vehicle)

    if cfg.ExcludedClasses[class] then return end

    if seatbeltOn ~= enabled then
        ToggleSeatbelt()
    end
end)

--============================================================
--  CLEANUP
--============================================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Reset state
    seatbeltOn = false
    UpdateHUD(false)

    Core.DebugPrint('Seatbelt module stopped')
end)
