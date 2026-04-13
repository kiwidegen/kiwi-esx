---@diagnostic disable: undefined-global

-- Module guard
if not ExtrasConfig.Modules.AmbientAudio then return end

--============================================================
--  AMBIENT AUDIO CONTROL MODULE
--  Disables ambient sounds from houses, music, and scenarios
--============================================================

CreateThread(function()
    -- Ambient zone lists (Cayo Perico and other DLC zones)
    SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
    SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)

    -- Audio flags to disable flight music and police scanner
    SetAudioFlag("DisableFlightMusic", true)
    SetAudioFlag("PoliceScannerDisabled", true)

    -- Disable ocean sounds and random events
    SetDeepOceanScaler(0.0)
    SetRandomEventFlag(false)

    -- Disable vehicle scenarios that spawn ambient vehicles
    local vehicleScenarios = {
        "WORLD_VEHICLE_BIKE_OFF_ROAD_RACE",
        "WORLD_VEHICLE_BUSINESSMEN",
        "WORLD_VEHICLE_EMPTY",
        "WORLD_VEHICLE_MECHANIC",
        "WORLD_VEHICLE_MILITARY_PLANES_BIG",
        "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
        "WORLD_VEHICLE_POLICE_BIKE",
        "WORLD_VEHICLE_POLICE_CAR",
        "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
        "WORLD_VEHICLE_SALTON_DIRT_BIKE",
        "WORLD_VEHICLE_SALTON",
        "WORLD_VEHICLE_STREETRACE"
    }
    for _, scenario in ipairs(vehicleScenarios) do
        SetScenarioTypeEnabled(scenario, false)
    end

    -- Disable static audio emitters (clubs, arenas, etc.)
    local staticEmitters = {
        -- Vanilla Unicorn (strip club)
        "LOS_SANTOS_VANILLA_UNICORN_01_STAGE",
        "LOS_SANTOS_VANILLA_UNICORN_02_MAIN_ROOM",
        "LOS_SANTOS_VANILLA_UNICORN_03_BACK_ROOM",
        -- Arena War
        "se_dlc_aw_arena_construction_01",
        "se_dlc_aw_arena_crowd_background_main",
        "se_dlc_aw_arena_crowd_exterior_lobby",
        "se_dlc_aw_arena_crowd_interior_lobby",
        -- Additional ambient emitters
        "SE_DLC_AW_Arena_Crowd_Background_Main",
        "SE_DLC_AW_Crowd_Exterior_Grandstand_01_Amb",
        "SE_ba_dlc_int_01_ba_nightclub",
        "SE_ba_dlc_int_01_ba_nightclub_afar",
        "se_dlc_aw_arena_constructionyard_01",
        "se_dlc_aw_xs_arena_interior_02",
        "SE_DLC_AW_xs_int_mod_garage",
        "se_ba_dlc_int_02_ba_nightclub",
        "se_ba_dlc_int_02_ba_nightclub_afar"
    }
    for _, emitter in ipairs(staticEmitters) do
        SetStaticEmitterEnabled(emitter, false)
    end

    -- Start muting audio scenes (prevents ambient music and sounds)
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
    StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
    StartAudioScene("FBI_HEIST_H5_MUTE_AMBIENCE_SCENE")

    -- Disable cover mechanic (prevents accidental cover usage)
    SetPlayerCanUseCover(PlayerId(), false)

    if ExtrasConfig.Debug then
        Core.DebugPrint("Ambient audio disabled - houses, music, and scenarios muted")
    end
end)

-- Ensure audio stays disabled on player spawn
AddEventHandler('playerSpawned', function()
    Wait(500)

    -- Reapply audio scene muting
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
    StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
    StartAudioScene("FBI_HEIST_H5_MUTE_AMBIENCE_SCENE")

    -- Reapply player-specific settings
    SetPlayerCanUseCover(PlayerId(), false)

    if ExtrasConfig.Debug then
        Core.DebugPrint("Ambient audio reapplied on spawn")
    end
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Stop muting audio scenes
    StopAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
    StopAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
    StopAudioScene("FBI_HEIST_H5_MUTE_AMBIENCE_SCENE")

    -- Re-enable cover
    SetPlayerCanUseCover(PlayerId(), true)

    if ExtrasConfig.Debug then
        Core.DebugPrint("Ambient audio control disabled - audio restored")
    end
end)
