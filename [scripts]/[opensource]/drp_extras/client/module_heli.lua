if not ExtrasConfig.Modules.HeliGuns then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('Heli module loaded')

-- Only passengers can aim/shoot from helicopter seats
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()

        if IsPedInAnyHeli(ped) then
            sleep = 1
            local veh = GetVehiclePedIsIn(ped, false)
            local seat = -1

            for i = -1, GetVehicleModelNumberOfSeats(GetEntityModel(veh)) - 2 do
                if GetPedInVehicleSeat(veh, i) == ped then
                    seat = i
                    break
                end
            end

            if seat > -1 then -- passenger only
                if IsPlayerFreeAiming(PlayerId()) then
                    DisableControlAction(0, 68, false)
                    SetFollowVehicleCamViewMode(3)
                    SetPedConfigFlag(ped, 184, true)
                else
                    SetFollowVehicleCamViewMode(0)
                    SetPedConfigFlag(ped, 184, false)
                end
            else
                DisablePlayerFiring(PlayerId(), true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
            end
        end

        Wait(sleep)
    end
end)
