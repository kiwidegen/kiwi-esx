-- Module guard
if not ExtrasConfig.Modules.AntiPeek then return end

--============================================================
--  ANTI-PEEK MODULE
--  Prevents shooting/aiming while using radio
--============================================================

Core.DebugPrint('AntiPeek module loaded')

local cache = {
    playerId = PlayerId(),
    ped = PlayerPedId()
}

-- Update cache when ped changes
AddEventHandler('esx:playerPedChanged', function(newPed)
    cache.ped = newPed
end)

--- Check if player is using radio (optimized - called less frequently)
---@return boolean usingRadio Whether player is transmitting on radio
local function isUsingRadio()
    -- Check pma-voice radio state directly
    local radioChannel = LocalPlayer.state.radioChannel
    local isTalking = MumbleIsPlayerTalking(cache.playerId)

    -- Player is on radio if they have a channel AND are talking
    if radioChannel and radioChannel > 0 and isTalking then
        return true
    end

    return false
end

--============================================================
--  MAIN THREAD (Optimized)
--============================================================
local isOnRadio = false
local wasUsingRadio = false

-- State checker thread (runs less frequently)
CreateThread(function()
    Core.DebugPrint("Anti-peek state checker started")

    while true do
        isOnRadio = isUsingRadio()

        -- Show notification when first starting to use radio
        if isOnRadio and not wasUsingRadio then
            wasUsingRadio = true
            SetPlayerCanDoDriveBy(cache.playerId, false)

            Core.DebugPrint("Anti-peek: Combat disabled (radio active)")

            if ExtrasConfig.AntiPeek and ExtrasConfig.AntiPeek.ShowNotification then
                lib.notify({
                    description = 'Combat disabled while using radio',
                    type = 'inform',
                    duration = 2000
                })
            end
        elseif not isOnRadio and wasUsingRadio then
            wasUsingRadio = false
            SetPlayerCanDoDriveBy(cache.playerId, true)

            Core.DebugPrint("Anti-peek: Combat enabled (radio inactive)")
        end

        Wait(100)  -- Check state every 100ms instead of every frame
    end
end)

-- Control disabler thread (only runs when on radio)
CreateThread(function()
    Core.DebugPrint("Anti-peek control disabler started")

    while true do
        if isOnRadio then
            -- Disable all combat controls while on radio
            DisableControlAction(0, 24, true)   -- Attack
            DisableControlAction(0, 25, true)   -- Aim
            DisableControlAction(1, 24, true)
            DisableControlAction(1, 25, true)
            DisableControlAction(2, 24, true)
            DisableControlAction(2, 25, true)
            DisableControlAction(0, 257, true)  -- Attack 2
            DisableControlAction(0, 263, true)  -- Melee Attack 1
            DisableControlAction(0, 140, true)  -- Melee Attack Light
            DisableControlAction(0, 141, true)  -- Melee Attack Heavy
            DisableControlAction(0, 142, true)  -- Melee Attack Alternate
            DisableControlAction(0, 143, true)  -- Melee Block
            DisableControlAction(0, 45, true)   -- Reload

            DisablePlayerFiring(cache.ped, true)

            Wait(0)
        else
            Wait(500)  -- Not on radio, sleep longer
        end
    end
end)

--============================================================
--  CLEANUP
--============================================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Re-enable drive-by on resource stop
    SetPlayerCanDoDriveBy(cache.playerId, true)
    Core.DebugPrint('AntiPeek module stopped')
end)
