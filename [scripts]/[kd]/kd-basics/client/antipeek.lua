-- ╔══════════════════════════════╗
-- ║         Anti Peek            ║
-- ╚══════════════════════════════╝
if not Config.Modules.AntiPeek then return end

local cfg      = Config.AntiPeek
local playerId = PlayerId()

-- State bag tracks radio state so other scripts can read it
AddEventHandler('pma-voice:radioActive', function(state)
    LocalPlayer.state:set('onRadio', state, false)
    SetPlayerCanDoDriveBy(playerId, not state)
    if state and cfg.showNotification then
        lib.notify({ description = 'Combat disabled while using radio', type = 'inform', duration = 2000 })
    end
end)

-- Wait(0) justified — DisableControlAction must be called every frame to suppress inputs
CreateThread(function()
    while true do
        if LocalPlayer.state.onRadio then
            DisableControlAction(0, 24,  true)
            DisableControlAction(0, 25,  true)
            DisableControlAction(1, 24,  true)
            DisableControlAction(1, 25,  true)
            DisableControlAction(2, 24,  true)
            DisableControlAction(2, 25,  true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 45,  true)
            DisablePlayerFiring(cache.ped, true)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetPlayerCanDoDriveBy(playerId, true)
end)
