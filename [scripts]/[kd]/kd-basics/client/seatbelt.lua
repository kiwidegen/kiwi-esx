-- ╔══════════════════════════════╗
-- ║         Seatbelt             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Seatbelt then return end

local cfg = Config.Seatbelt

local seatbeltOn      = false
local lastVehicle     = nil
local handbrake       = 0
local damageDone      = false
local tick            = 0

local lastFrameSpeed  = 0
local lastFrameSpeed2 = 0
local currentBodyHealth = 0
local newBodyHealth   = 0
local frameBodyChange = 0
local velocity        = vector3(0.0, 0.0, 0.0)

local function PlaySeatbeltSound(buckle)
    SendNUIMessage({
        action = 'play',
        sound  = buckle and cfg.BuckleSound or cfg.UnbuckleSound,
        volume = cfg.SoundVolume,
    })
end

local function ToggleSeatbelt()
    local ped = cache.ped
    if not IsPedInAnyVehicle(ped, false) then return end

    local veh   = GetVehiclePedIsIn(ped, false)
    local class = GetVehicleClass(veh)
    if cfg.ExcludedClasses[class] then return end

    seatbeltOn = not seatbeltOn
    PlaySeatbeltSound(seatbeltOn)

    lib.notify({
        title       = 'Seatbelt',
        description = seatbeltOn and 'Seatbelt fastened' or 'Seatbelt unfastened',
        type        = 'inform',
        duration    = 2000,
    })
end

local function EjectFromVehicle(ped, speed)
    local veh    = GetVehiclePedIsIn(ped, false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)

    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(1)

    SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(ped, velocity.x * 4, velocity.y * 4, velocity.z * 4)

    local dmg           = math.ceil(speed * cfg.EjectDamageMultiplier)
    local currentHealth = GetEntityHealth(ped)

    if currentHealth - dmg > 0 then
        SetEntityHealth(ped, currentHealth - dmg)
    elseif currentHealth ~= 0 then
        SetEntityHealth(ped, 0)
    end
end

local function ShouldEject(veh, thisFrameSpeed)
    if seatbeltOn then return false end
    if IsThisModelABike(GetEntityModel(veh)) then return false end
    if frameBodyChange <= 0 then return false end

    if lastFrameSpeed > 110 and thisFrameSpeed < (lastFrameSpeed * 0.75) then
        if frameBodyChange > cfg.MinDamageForEjection then
            return math.random(math.ceil(lastFrameSpeed)) > cfg.MinSpeedForEjection
        else
            return math.random(math.ceil(lastFrameSpeed)) > cfg.MinSpeedForEjection
        end
    end

    if currentBodyHealth < 350.0 then return true end
    return false
end

-- Disable exit while belted
CreateThread(function()
    while true do
        local sleep = 500
        if seatbeltOn then
            sleep = 0
            DisableControlAction(0,  75, true)
            DisableControlAction(27, 75, true)
        end
        Wait(sleep)
    end
end)

-- Crash detection & ejection
CreateThread(function()
    while true do
        local sleep = 1000
        local ped   = cache.ped
        local veh   = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 then
            sleep       = 100
            lastVehicle = veh

            if GetVehicleEngineHealth(veh) < 0.0 then
                SetVehicleEngineHealth(veh, 0.0)
            end

            if GetVehicleHandbrake(veh) or math.abs(GetVehicleSteeringAngle(veh)) > 25.0 then
                handbrake = 100
            elseif handbrake > 0 then
                handbrake = handbrake - 1
            end

            local thisFrameSpeed = GetEntitySpeed(veh) * 3.6
            currentBodyHealth    = GetVehicleBodyHealth(veh)

            if currentBodyHealth == 1000 and frameBodyChange ~= 0 then
                frameBodyChange = 0
            end

            if frameBodyChange ~= 0 and not damageDone then
                if ShouldEject(veh, thisFrameSpeed) then
                    EjectFromVehicle(ped, thisFrameSpeed)
                end
                damageDone = true
            end

            if currentBodyHealth < 350.0 and not damageDone then
                damageDone = true
                sleep      = 1000
            end

            if lastFrameSpeed < 100 then tick = 0 end

            frameBodyChange = newBodyHealth - currentBodyHealth

            if tick > 0 then
                tick = tick - 1
                if tick == 1 then lastFrameSpeed = GetEntitySpeed(veh) * 3.6 end
            else
                if damageDone then
                    damageDone      = false
                    frameBodyChange = 0
                    lastFrameSpeed  = GetEntitySpeed(veh) * 3.6
                end

                lastFrameSpeed2 = GetEntitySpeed(veh) * 3.6

                if lastFrameSpeed2 > lastFrameSpeed then
                    lastFrameSpeed = GetEntitySpeed(veh) * 3.6
                end

                if lastFrameSpeed2 < lastFrameSpeed then tick = 25 end
            end

            velocity     = GetEntityVelocity(veh)
            if tick < 0 then tick = 0 end
            newBodyHealth = GetVehicleBodyHealth(veh)

        else
            if lastVehicle ~= nil then
                if not damageDone and newBodyHealth < currentBodyHealth then
                    damageDone = true
                end
                lastVehicle = nil
                seatbeltOn  = false
            end

            lastFrameSpeed  = 0
            lastFrameSpeed2 = 0
            newBodyHealth   = 0
            currentBodyHealth = 0
            frameBodyChange = 0
        end

        Wait(sleep)
    end
end)

RegisterCommand('seatbelt', ToggleSeatbelt, false)
RegisterKeyMapping('seatbelt', 'Toggle Seatbelt', 'keyboard', cfg.ToggleKey)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    seatbeltOn = false
end)
