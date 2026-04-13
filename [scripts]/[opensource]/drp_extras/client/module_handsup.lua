if not ExtrasConfig.Modules.HandsUp then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('HandsUp module loaded')

local handsUp = false

RegisterCommand('handsup', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- Check if player is in a vehicle and if it's a motorbike
    if vehicle ~= 0 then
        local vehicleClass = GetVehicleClass(vehicle)
        -- Vehicle class 8 is motorcycles, 13 is cycles
        if vehicleClass == 8 or vehicleClass == 13 then
            return -- Exit early if on a motorbike
        end
    end

    if not handsUp then
        handsUp = true
        RequestAnimDict("missminuteman_1ig_2")
        while not HasAnimDictLoaded("missminuteman_1ig_2") do Wait(0) end
        TaskPlayAnim(ped, "missminuteman_1ig_2", "handsup_base", 8.0, 8.0, -1, 49, 0, false, false, false)
    else
        handsUp = false
        ClearPedTasks(ped)
    end
end, false)

RegisterKeyMapping('handsup', 'Hands Up', 'keyboard', 'X')
