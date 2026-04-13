-- Module guard
if not ExtrasConfig.Modules.MaxSpeed then return end

--============================================================
--  VEHICLE MAX SPEED LIMITER
--============================================================

--- Set max speed when entering vehicle
AddEventHandler("gameEventTriggered", function(event, args)
    if (event ~= "CEventNetworkPlayerEnteredVehicle") then
        return
    end

    local playerPed = PlayerPedId()

    if (GetPlayerPed(args[1]) ~= playerPed) then
        return
    end

    if (GetEntityType(args[2]) ~= 2) then
        return
    end

    local vehicle = args[2]

    -- Convert km/h to m/s for SetVehicleMaxSpeed
    SetVehicleMaxSpeed(vehicle, ExtrasConfig.MaxKMH / 3.6)
end)
