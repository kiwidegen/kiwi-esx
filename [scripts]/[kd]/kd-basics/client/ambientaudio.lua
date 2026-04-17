-- ╔══════════════════════════════╗
-- ║       Ambient Audio          ║
-- ╚══════════════════════════════╝
if not Config.Modules.AmbientAudio then return end

SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)

SetAudioFlag('DisableFlightMusic', true)
SetAudioFlag('PoliceScannerDisabled', true)

SetDeepOceanScaler(0.0)
SetRandomEventFlag(false)

local vehicleScenarios = {
    'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE', 'WORLD_VEHICLE_BUSINESSMEN',
    'WORLD_VEHICLE_EMPTY',              'WORLD_VEHICLE_MECHANIC',
    'WORLD_VEHICLE_MILITARY_PLANES_BIG','WORLD_VEHICLE_MILITARY_PLANES_SMALL',
    'WORLD_VEHICLE_POLICE_BIKE',        'WORLD_VEHICLE_POLICE_CAR',
    'WORLD_VEHICLE_POLICE_NEXT_TO_CAR', 'WORLD_VEHICLE_SALTON_DIRT_BIKE',
    'WORLD_VEHICLE_SALTON',             'WORLD_VEHICLE_STREETRACE',
}
for _, s in ipairs(vehicleScenarios) do SetScenarioTypeEnabled(s, false) end

local staticEmitters = {
    'LOS_SANTOS_VANILLA_UNICORN_01_STAGE',  'LOS_SANTOS_VANILLA_UNICORN_02_MAIN_ROOM',
    'LOS_SANTOS_VANILLA_UNICORN_03_BACK_ROOM', 'se_dlc_aw_arena_construction_01',
    'se_dlc_aw_arena_crowd_background_main', 'se_dlc_aw_arena_crowd_exterior_lobby',
    'se_dlc_aw_arena_crowd_interior_lobby',  'SE_DLC_AW_Arena_Crowd_Background_Main',
    'SE_DLC_AW_Crowd_Exterior_Grandstand_01_Amb', 'SE_ba_dlc_int_01_ba_nightclub',
    'SE_ba_dlc_int_01_ba_nightclub_afar',    'se_dlc_aw_arena_constructionyard_01',
    'se_dlc_aw_xs_arena_interior_02',        'SE_DLC_AW_xs_int_mod_garage',
    'se_ba_dlc_int_02_ba_nightclub',         'se_ba_dlc_int_02_ba_nightclub_afar',
}
for _, e in ipairs(staticEmitters) do SetStaticEmitterEnabled(e, false) end

local function startScenes()
    StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    StartAudioScene('DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE')
    StartAudioScene('FBI_HEIST_H5_MUTE_AMBIENCE_SCENE')
end

startScenes()
SetPlayerCanUseCover(PlayerId(), false)

AddEventHandler('playerSpawned', function()
    Wait(500)
    startScenes()
    SetPlayerCanUseCover(PlayerId(), false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    StopAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    StopAudioScene('DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE')
    StopAudioScene('FBI_HEIST_H5_MUTE_AMBIENCE_SCENE')
    SetPlayerCanUseCover(PlayerId(), true)
end)
