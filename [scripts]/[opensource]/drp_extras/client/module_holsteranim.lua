-- Module guard
if not ExtrasConfig.Modules.HolsterAnim then return end

--============================================================
--  WEAPON HOLSTER ANIMATION MODULE
--============================================================

local lastWeapon = GetHashKey("WEAPON_UNARMED")
local isSwitching = false

--- Play animation with wait option
---@param dict string Animation dictionary
---@param anim string Animation name
---@param flags number Animation flags
---@param waitForDone boolean Whether to wait for animation to finish
local function PlayAnimation(dict, anim, flags, waitForDone)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end

    TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 2.0, GetAnimDuration(dict, anim) * 1000, flags, 0.0, false, false, false)

    if (not waitForDone) then
        SetTimeout(GetAnimDuration(dict, anim) * 500, function()
            ClearPedTasks(PlayerPedId())
        end)
    else
        Wait(GetAnimDuration(dict, anim) * 500)
        ClearPedTasks(PlayerPedId())
    end
end

--- Weapon swap detection thread (optimized)
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        -- Only check when actually swapping
        if (IsPedSwappingWeapon(playerPed)) then
            local newWeapon = GetSelectedPedWeapon(playerPed)
            if (lastWeapon ~= newWeapon) then
                isSwitching = true

                -- Disable controls while switching
                CreateThread(function()
                    while isSwitching do
                        DisableControlAction(1, 25, true)
                        DisableControlAction(1, 140, true)
                        DisableControlAction(1, 141, true)
                        DisableControlAction(1, 142, true)
                        DisableControlAction(1, 23, true)
                        DisableControlAction(1, 37, true)
                        DisableControlAction(1, 182, true)
                        DisablePlayerFiring(playerPed, true)
                        Wait(0)
                    end
                end)

                ClearPedTasks(playerPed)
                SetCurrentPedWeapon(playerPed, lastWeapon or `WEAPON_UNARMED`, true)

                -- Holster animation
                if (lastWeapon ~= `WEAPON_UNARMED`) then
                    PlayAnimation("reaction@intimidation@1h", "outro", 51, true)
                end

                SetCurrentPedWeapon(playerPed, newWeapon, true)
                lastWeapon = newWeapon

                -- Draw animation
                if (newWeapon ~= `WEAPON_UNARMED`) then
                    PlayAnimation("reaction@intimidation@1h", "intro", 51, true)
                end

                isSwitching = false
            end
            Wait(0)
        else
            Wait(100)  -- Not swapping, check less frequently
        end
    end
end)
