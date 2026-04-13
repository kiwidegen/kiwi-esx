if not ExtrasConfig.Modules.Clothing then return end
---@diagnostic disable: undefined-global
Core.DebugPrint('Clothing module loaded (permanent no-helmet)')

CreateThread(function()
    local ped = PlayerPedId()
    local nextPedCheck = GetGameTimer() + 1500

    while true do
        local wait = 500
        local now = GetGameTimer()

        if now >= nextPedCheck then
            ped = PlayerPedId()
            nextPedCheck = now + 1500
        end

        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            -- always lock clothing on damage
            SetPedCanLosePropsOnDamage(ped, false, 0)

            if ExtrasConfig.NoHelmet then
                -- run every frame while on bike or heli
                if IsPedOnAnyBike(ped) or IsPedInAnyHeli(ped) then
                    wait = 0
                    ClearPedProp(ped, 0)                   -- remove helmet prop
                    SetPedHelmet(ped, false)               -- block auto helmets
                    SetPedConfigFlag(ped, 35, false)       -- disable helmet prompt
                    RemovePedHelmet(ped, true)             -- remove if forced
                else
                    -- ensure it's still disabled even off bike
                    SetPedHelmet(ped, false)
                    SetPedConfigFlag(ped, 35, false)
                end
            end
        end

        Wait(wait)
    end
end)
