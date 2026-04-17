-- ╔══════════════════════════════╗
-- ║           Basics             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Basics then return end

-- ─── Init ────────────────────────────────────────────────────────────────────

NetworkSetLocalPlayerSyncLookAt(true)

for _, name in ipairs(Config.Basics.stealthKills) do
    RemoveStealthKill(GetHashKey(name), false)
end

SetScenarioTypeEnabled('WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_PARK_PARALLEL', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN_LOW', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_DRIVE_SOLO', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_DRIVE_PASSENGERS', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_DRIVE_PARKED', false)

-- ─── Pistol whip / accidental punch ──────────────────────────────────────────

CreateThread(function()
    while true do
        local ped      = cache.ped
        local playerId = cache.playerId

        if IsPedArmed(ped, 6) or (not IsPlayerTargettingAnything(playerId) and IsPedStopped(ped)) then
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
        end

        Wait(200)
    end
end)

-- ─── Drive-by ────────────────────────────────────────────────────────────────
-- event-driven via ox_lib cache, no polling loop

lib.onCache('vehicle', function(vehicle)
    if vehicle then
        SetPlayerCanDoDriveBy(cache.playerId, Config.Basics.drivebyAllowed[GetEntityModel(vehicle)] or false)
    else
        SetPlayerCanDoDriveBy(cache.playerId, false)
    end
end)

-- ─── Idle cam ────────────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        InvalidateIdleCam()
        InvalidateVehicleIdleCam()
        Wait(15000)
    end
end)

-- ─── /resetvoice ─────────────────────────────────────────────────────────────

local resetting = false

local function lockPushToTalk()
    resetting = true
    CreateThread(function()
        -- Wait(0) required here — DisableControlAction must run every frame to suppress input.
        -- This thread is short-lived (~1s) and only spawned during /resetvoice.
        while resetting do
            DisableControlAction(0, 249, true)
            Wait(0)
        end
    end)
end

RegisterCommand('resetvoice', function()
    lockPushToTalk()
    NetworkClearVoiceChannel()
    NetworkSessionVoiceLeave()
    Wait(50)
    NetworkSetVoiceActive(false)
    MumbleClearVoiceTarget(2)
    Wait(1000)
    MumbleSetVoiceTarget(2)
    NetworkSetVoiceActive(true)
    resetting = false

    lib.notify({
        title       = 'Voice Reset',
        description = 'Your voice channel has been reset.',
        type        = 'success',
    })
end, false)
