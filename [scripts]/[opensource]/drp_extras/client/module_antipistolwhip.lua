-- Module guard
if not ExtrasConfig.Modules.AntiPistolWhip then return end

--============================================================
--  ANTI PISTOL WHIP MODULE
--  Disables melee attacks when holding a weapon
--============================================================

CreateThread(function()
    local lastWeapon = `WEAPON_UNARMED`
    local isArmed = false

    while true do
        local playerPed = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(playerPed)

        -- Only update when weapon changes
        if currentWeapon ~= lastWeapon then
            lastWeapon = currentWeapon
            isArmed = currentWeapon ~= `WEAPON_UNARMED`
        end

        -- Disable melee if holding a weapon
        if isArmed then
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            Wait(0)
        else
            Wait(200)  -- Not armed, check less frequently
        end
    end
end)
