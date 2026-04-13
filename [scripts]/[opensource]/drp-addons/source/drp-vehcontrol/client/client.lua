---@diagnostic disable: undefined-global
-- Emergency Vehicle Control System
-- Controls sirens, indicators, air horns, and powercall for emergency vehicles

local count_bcast_timer = 0
local delay_bcast_timer = 1200

local count_sndclean_timer = 0
local delay_sndclean_timer = 500

local actv_ind_timer = false
local count_ind_timer = 0
local delay_ind_timer = 180

local actv_lxsrnmute_temp = false
local srntone_temp = 0
local dsrn_mute = true

local state_indic = {}
local state_lxsiren = {}
local state_pwrcall = {}
local state_airmanu = {}

local ind_state_o = 0
local ind_state_l = 1
local ind_state_r = 2
local ind_state_h = 3

local snd_lxsiren = {}
local snd_pwrcall = {}
local snd_airmanu = {}

--- Check if vehicle uses fire truck siren sounds
---@param veh number Vehicle entity handle
---@return boolean useFireSiren Whether vehicle uses fire truck sirens
local function useFiretruckSiren(veh)
    local model = GetEntityModel(veh)
    for i = 1, #Config.VehControl.FiretruckSirenModels do
        if model == GetHashKey(Config.VehControl.FiretruckSirenModels[i]) then
            return true
        end
    end
    return false
end

--- Check if vehicle supports powercall auxiliary siren
---@param veh number Vehicle entity handle
---@return boolean hasPowercall Whether vehicle has powercall
local function usePowercallAuxSrn(veh)
    local model = GetEntityModel(veh)
    for i = 1, #Config.VehControl.PowercallModels do
        if model == GetHashKey(Config.VehControl.PowercallModels[i]) then
            return true
        end
    end
    return false
end

--- Clean up sounds for dead/non-existent vehicles
local function CleanupSounds()
    if count_sndclean_timer > delay_sndclean_timer then
        count_sndclean_timer = 0
        for k, v in pairs(state_lxsiren) do
            if v > 0 then
                if not DoesEntityExist(k) or IsEntityDead(k) then
                    if snd_lxsiren[k] ~= nil then
                        StopSound(snd_lxsiren[k])
                        ReleaseSoundId(snd_lxsiren[k])
                        snd_lxsiren[k] = nil
                        state_lxsiren[k] = nil
                    end
                end
            end
        end
        for k, v in pairs(state_pwrcall) do
            if v == true then
                if not DoesEntityExist(k) or IsEntityDead(k) then
                    if snd_pwrcall[k] ~= nil then
                        StopSound(snd_pwrcall[k])
                        ReleaseSoundId(snd_pwrcall[k])
                        snd_pwrcall[k] = nil
                        state_pwrcall[k] = nil
                    end
                end
            end
        end
        for k, v in pairs(state_airmanu) do
            if v == true then
                if not DoesEntityExist(k) or IsEntityDead(k) or IsVehicleSeatFree(k, -1) then
                    if snd_airmanu[k] ~= nil then
                        StopSound(snd_airmanu[k])
                        ReleaseSoundId(snd_airmanu[k])
                        snd_airmanu[k] = nil
                        state_airmanu[k] = nil
                    end
                end
            end
        end
    else
        count_sndclean_timer += 1
    end
end

--- Toggle turn signal state for vehicle
---@param veh number Vehicle entity handle
---@param newstate number Indicator state (0=off, 1=left, 2=right, 3=hazard)
local function TogIndicStateForVeh(veh, newstate)
    if not DoesEntityExist(veh) or IsEntityDead(veh) then
        return
    end
    local right_indicator = false
    local left_indicator = false
    if newstate == ind_state_l or newstate == ind_state_h then
        left_indicator = true
    end
    if newstate == ind_state_r or newstate == ind_state_h then
        right_indicator = true
    end
    SetVehicleIndicatorLights(veh, 0, right_indicator)
    SetVehicleIndicatorLights(veh, 1, left_indicator)
    state_indic[veh] = newstate
end

--- Mute or unmute default siren
---@param veh number Vehicle entity handle
---@param toggle boolean Whether to mute siren
local function TogMuteDfltSrnForVeh(veh, toggle)
    if DoesEntityExist(veh) and not IsEntityDead(veh) then
        DisableVehicleImpactExplosionActivation(veh, toggle)
    end
end

--- Set siren state for vehicle
---@param veh number Vehicle entity handle
---@param newstate number Siren tone (0=off, 1=tone1, 2=tone2, 3=yelp)
local function SetLxSirenStateForVeh(veh, newstate)
    if not DoesEntityExist(veh) or IsEntityDead(veh) then
        return
    end

    if newstate ~= state_lxsiren[veh] then
        if snd_lxsiren[veh] ~= nil then
            StopSound(snd_lxsiren[veh])
            ReleaseSoundId(snd_lxsiren[veh])
            snd_lxsiren[veh] = nil
        end

        if newstate == 1 then
            if useFiretruckSiren(veh) then
                TogMuteDfltSrnForVeh(veh, false)
            else
                snd_lxsiren[veh] = GetSoundId()
                PlaySoundFromEntity(snd_lxsiren[veh], "VEHICLES_HORNS_SIREN_1", veh, 0, 0, 0)
                TogMuteDfltSrnForVeh(veh, true)
            end
        elseif newstate == 2 then
            snd_lxsiren[veh] = GetSoundId()
            PlaySoundFromEntity(snd_lxsiren[veh], "VEHICLES_HORNS_SIREN_2", veh, 0, 0, 0)
            TogMuteDfltSrnForVeh(veh, true)
        elseif newstate == 3 then
            snd_lxsiren[veh] = GetSoundId()
            local sound = useFiretruckSiren(veh) and "VEHICLES_HORNS_AMBULANCE_WARNING" or "VEHICLES_HORNS_POLICE_WARNING"
            PlaySoundFromEntity(snd_lxsiren[veh], sound, veh, 0, 0, 0)
            TogMuteDfltSrnForVeh(veh, true)
        else
            TogMuteDfltSrnForVeh(veh, true)
        end

        state_lxsiren[veh] = newstate
    end
end

--- Toggle powercall (auxiliary siren) state
---@param veh number Vehicle entity handle
---@param toggle boolean Whether powercall is active
local function TogPowercallStateForVeh(veh, toggle)
    if DoesEntityExist(veh) and not IsEntityDead(veh) then
        if toggle == true then
            if snd_pwrcall[veh] == nil then
                snd_pwrcall[veh] = GetSoundId()
                if usePowercallAuxSrn(veh) then
                    PlaySoundFromEntity(snd_pwrcall[veh], "VEHICLES_HORNS_AMBULANCE_WARNING", veh, 0, 0, 0)
                else
                    PlaySoundFromEntity(snd_pwrcall[veh], "VEHICLES_HORNS_SIREN_1", veh, 0, 0, 0)
                end
            end
        else
            if snd_pwrcall[veh] ~= nil then
                StopSound(snd_pwrcall[veh])
                ReleaseSoundId(snd_pwrcall[veh])
                snd_pwrcall[veh] = nil
            end
        end
        state_pwrcall[veh] = toggle
    end
end

--- Set air horn/manual control state
---@param veh number Vehicle entity handle
---@param newstate number State (0=off, 1=horn, 2=manu1, 3=manu2)
local function SetAirManuStateForVeh(veh, newstate)
    if not DoesEntityExist(veh) or IsEntityDead(veh) then
        return
    end

    if newstate ~= state_airmanu[veh] then
        if snd_airmanu[veh] ~= nil then
            StopSound(snd_airmanu[veh])
            ReleaseSoundId(snd_airmanu[veh])
            snd_airmanu[veh] = nil
        end

        if newstate == 1 then
            snd_airmanu[veh] = GetSoundId()
            local sound = useFiretruckSiren(veh) and "VEHICLES_HORNS_FIRETRUCK_WARNING" or "SIRENS_AIRHORN"
            PlaySoundFromEntity(snd_airmanu[veh], sound, veh, 0, 0, 0)
        elseif newstate == 2 then
            snd_airmanu[veh] = GetSoundId()
            PlaySoundFromEntity(snd_airmanu[veh], "VEHICLES_HORNS_SIREN_1", veh, 0, 0, 0)
        elseif newstate == 3 then
            snd_airmanu[veh] = GetSoundId()
            PlaySoundFromEntity(snd_airmanu[veh], "VEHICLES_HORNS_SIREN_2", veh, 0, 0, 0)
        end

        state_airmanu[veh] = newstate
    end
end

-- Network event handlers for syncing across clients
RegisterNetEvent("drp_vehcontrol:TogIndicState")
AddEventHandler("drp_vehcontrol:TogIndicState", function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= PlayerPedId() then
            if IsPedInAnyVehicle(ped_s, false) then
                local veh = GetVehiclePedIsUsing(ped_s)
                TogIndicStateForVeh(veh, newstate)
            end
        end
    end
end)

RegisterNetEvent("drp_vehcontrol:TogDfltSrnMuted")
AddEventHandler("drp_vehcontrol:TogDfltSrnMuted", function(sender, toggle)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= PlayerPedId() then
            if IsPedInAnyVehicle(ped_s, false) then
                local veh = GetVehiclePedIsUsing(ped_s)
                TogMuteDfltSrnForVeh(veh, toggle)
            end
        end
    end
end)

RegisterNetEvent("drp_vehcontrol:SetLxSirenState")
AddEventHandler("drp_vehcontrol:SetLxSirenState", function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= PlayerPedId() then
            if IsPedInAnyVehicle(ped_s, false) then
                local veh = GetVehiclePedIsUsing(ped_s)
                SetLxSirenStateForVeh(veh, newstate)
            end
        end
    end
end)

RegisterNetEvent("drp_vehcontrol:TogPwrcallState")
AddEventHandler("drp_vehcontrol:TogPwrcallState", function(sender, toggle)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= PlayerPedId() then
            if IsPedInAnyVehicle(ped_s, false) then
                local veh = GetVehiclePedIsUsing(ped_s)
                TogPowercallStateForVeh(veh, toggle)
            end
        end
    end
end)

RegisterNetEvent("drp_vehcontrol:SetAirManuState")
AddEventHandler("drp_vehcontrol:SetAirManuState", function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= PlayerPedId() then
            if IsPedInAnyVehicle(ped_s, false) then
                local veh = GetVehiclePedIsUsing(ped_s)
                SetAirManuStateForVeh(veh, newstate)
            end
        end
    end
end)

-- Cleanup sounds in separate thread
CreateThread(function()
    while true do
        Wait(500)
        CleanupSounds()
    end
end)

-- Cache for current vehicle data
local cache = {
    ped = 0,
    veh = 0,
    vehClass = -1,
    isDriver = false,
    isEmergency = false
}

local function updateCache()
    cache.ped = PlayerPedId()
    if IsPedInAnyVehicle(cache.ped, false) then
        cache.veh = GetVehiclePedIsUsing(cache.ped)
        cache.isDriver = GetPedInVehicleSeat(cache.veh, -1) == cache.ped
        cache.vehClass = GetVehicleClass(cache.veh)
        cache.isEmergency = cache.vehClass == 18
    else
        cache.veh = 0
        cache.isDriver = false
        cache.vehClass = -1
        cache.isEmergency = false
    end
end

-- Update cache on vehicle enter/exit
AddEventHandler("gameEventTriggered", function(name, args)
    if name == "CEventNetworkPlayerEnteredVehicle" or name == "CEventNetworkPlayerLeftVehicle" then
        updateCache()
    end
end)

-- Main control thread
CreateThread(function()
    while true do
        local sleep = 1500
        updateCache()

        if cache.veh ~= 0 and cache.isDriver then
            sleep = 5
            local veh = cache.veh

            DisableControlAction(0, 84, true)  -- Left signal
            DisableControlAction(0, 83, true)  -- Right signal

            if state_indic[veh] ~= ind_state_o and state_indic[veh] ~= ind_state_l and state_indic[veh] ~= ind_state_r and state_indic[veh] ~= ind_state_h then
                state_indic[veh] = ind_state_o
            end

            -- Auto-cancel turn signals
            if actv_ind_timer == true then
                if state_indic[veh] == ind_state_l or state_indic[veh] == ind_state_r then
                    if GetEntitySpeed(veh) < 6 then
                        count_ind_timer = 0
                    else
                        if count_ind_timer > delay_ind_timer then
                            count_ind_timer = 0
                            actv_ind_timer = false
                            state_indic[veh] = ind_state_o
                            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            TogIndicStateForVeh(veh, state_indic[veh])
                            count_bcast_timer = delay_bcast_timer
                        else
                            count_ind_timer += 1
                        end
                    end
                end
            end

            -- Emergency vehicle controls
            if cache.isEmergency then
                local actv_manu = false
                local actv_horn = false
                DisableControlAction(0, 86, true)   -- Horn
                DisableControlAction(0, 172, true)  -- Arrow up
                DisableControlAction(0, 81, true)   -- R
                DisableControlAction(0, 82, true)   -- ,
                DisableControlAction(0, 19, true)   -- Alt
                DisableControlAction(0, 85, true)   -- Q
                DisableControlAction(0, 80, true)   -- E
                SetVehRadioStation(veh, "OFF")
                SetVehicleRadioEnabled(veh, false)

                if state_lxsiren[veh] ~= 1 and state_lxsiren[veh] ~= 2 and state_lxsiren[veh] ~= 3 then
                    state_lxsiren[veh] = 0
                end
                if state_pwrcall[veh] ~= true then
                    state_pwrcall[veh] = false
                end
                if state_airmanu[veh] ~= 1 and state_airmanu[veh] ~= 2 and state_airmanu[veh] ~= 3 then
                    state_airmanu[veh] = 0
                end

                if useFiretruckSiren(veh) and state_lxsiren[veh] == 1 then
                    TogMuteDfltSrnForVeh(veh, false)
                    dsrn_mute = false
                else
                    TogMuteDfltSrnForVeh(veh, true)
                    dsrn_mute = true
                end

                -- Turn off siren if lights are off
                if not IsVehicleSirenOn(veh) and state_lxsiren[veh] > 0 then
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                    SetLxSirenStateForVeh(veh, 0)
                    count_bcast_timer = delay_bcast_timer
                end
                if not IsVehicleSirenOn(veh) and state_pwrcall[veh] == true then
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                    TogPowercallStateForVeh(veh, false)
                    count_bcast_timer = delay_bcast_timer
                end

                if not IsPauseMenuActive() then
                    -- Q or NUMPAD7 - Toggle emergency lights
                    if IsDisabledControlJustReleased(0, 85) or IsDisabledControlJustReleased(0, 246) then
                        if IsVehicleSirenOn(veh) then
                            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            SetVehicleSiren(veh, false)
                        else
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            SetVehicleSiren(veh, true)
                            count_bcast_timer = delay_bcast_timer
                        end
                    -- ALT or , - Toggle main siren
                    elseif IsDisabledControlJustReleased(0, 19) or IsDisabledControlJustReleased(0, 82) then
                        local cstate = state_lxsiren[veh]
                        if cstate == 0 then
                            if IsVehicleSirenOn(veh) then
                                PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                SetLxSirenStateForVeh(veh, 1)
                                count_bcast_timer = delay_bcast_timer
                            end
                        else
                            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            SetLxSirenStateForVeh(veh, 0)
                            count_bcast_timer = delay_bcast_timer
                        end
                    -- Arrow Up - Toggle powercall
                    elseif IsDisabledControlJustReleased(0, 172) then
                        if state_pwrcall[veh] == true then
                            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            TogPowercallStateForVeh(veh, false)
                            count_bcast_timer = delay_bcast_timer
                        else
                            if IsVehicleSirenOn(veh) then
                                PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                TogPowercallStateForVeh(veh, true)
                                count_bcast_timer = delay_bcast_timer
                            end
                        end
                    end

                    -- E or R - Change siren tone
                    if state_lxsiren[veh] > 0 then
                        if IsDisabledControlJustReleased(0, 80) or IsDisabledControlJustReleased(0, 81) then
                            if IsVehicleSirenOn(veh) then
                                local cstate = state_lxsiren[veh]
                                local nstate = 1
                                PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if cstate == 1 then
                                    nstate = 2
                                elseif cstate == 2 then
                                    nstate = 3
                                else
                                    nstate = 1
                                end
                                SetLxSirenStateForVeh(veh, nstate)
                                count_bcast_timer = delay_bcast_timer
                            end
                        end
                    end

                    -- Manual siren control (E or R held)
                    if state_lxsiren[veh] < 1 then
                        if IsDisabledControlPressed(0, 80) or IsDisabledControlPressed(0, 81) then
                            actv_manu = true
                        else
                            actv_manu = false
                        end
                    else
                        actv_manu = false
                    end

                    -- Horn
                    if IsDisabledControlPressed(0, 86) then
                        actv_horn = true
                    else
                        actv_horn = false
                    end
                end

                -- Air horn / manual control states
                local hmanu_state_new = 0
                if actv_horn == true and actv_manu == false then
                    hmanu_state_new = 1
                elseif actv_horn == false and actv_manu == true then
                    hmanu_state_new = 2
                elseif actv_horn == true and actv_manu == true then
                    hmanu_state_new = 3
                end

                -- Mute siren when using air horn
                if hmanu_state_new == 1 then
                    if not useFiretruckSiren(veh) then
                        if state_lxsiren[veh] > 0 and actv_lxsrnmute_temp == false then
                            srntone_temp = state_lxsiren[veh]
                            SetLxSirenStateForVeh(veh, 0)
                            actv_lxsrnmute_temp = true
                        end
                    end
                else
                    if not useFiretruckSiren(veh) then
                        if actv_lxsrnmute_temp == true then
                            SetLxSirenStateForVeh(veh, srntone_temp)
                            actv_lxsrnmute_temp = false
                        end
                    end
                end

                if state_airmanu[veh] ~= hmanu_state_new then
                    SetAirManuStateForVeh(veh, hmanu_state_new)
                    count_bcast_timer = delay_bcast_timer
                end
            end

            -- Turn signal controls (all vehicles except boats/aircraft)
            if cache.vehClass ~= 14 and cache.vehClass ~= 15 and cache.vehClass ~= 16 and cache.vehClass ~= 21 then
                if not IsPauseMenuActive() then
                    -- = key - Left signal
                    if IsDisabledControlJustReleased(0, 84) then
                        local cstate = state_indic[veh]
                        if cstate == ind_state_l then
                            state_indic[veh] = ind_state_o
                            actv_ind_timer = false
                            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                        else
                            state_indic[veh] = ind_state_l
                            actv_ind_timer = true
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                        end
                        TogIndicStateForVeh(veh, state_indic[veh])
                        count_ind_timer = 0
                        count_bcast_timer = delay_bcast_timer
                    -- - key - Right signal
                    elseif IsDisabledControlJustReleased(0, 83) then
                        local cstate = state_indic[veh]
                        if cstate == ind_state_r then
                            state_indic[veh] = ind_state_o
                            actv_ind_timer = false
                            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                        else
                            state_indic[veh] = ind_state_r
                            actv_ind_timer = true
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                        end
                        TogIndicStateForVeh(veh, state_indic[veh])
                        count_ind_timer = 0
                        count_bcast_timer = delay_bcast_timer
                    -- Backspace - Hazard lights
                    elseif IsControlJustReleased(0, 202) then
                        if GetLastInputMethod(0) then
                            local cstate = state_indic[veh]
                            if cstate == ind_state_h then
                                state_indic[veh] = ind_state_o
                                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            else
                                state_indic[veh] = ind_state_h
                                PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            end
                            TogIndicStateForVeh(veh, state_indic[veh])
                            actv_ind_timer = false
                            count_ind_timer = 0
                            count_bcast_timer = delay_bcast_timer
                        end
                    end
                end

                -- Broadcast state to server for syncing
                if count_bcast_timer > delay_bcast_timer then
                    count_bcast_timer = 0
                    TriggerServerEvent("drp_vehcontrol:TogIndicState", state_indic[veh])
                    if cache.isEmergency then
                        TriggerServerEvent("drp_vehcontrol:TogDfltSrnMuted", dsrn_mute)
                        TriggerServerEvent("drp_vehcontrol:SetLxSirenState", state_lxsiren[veh])
                        TriggerServerEvent("drp_vehcontrol:TogPwrcallState", state_pwrcall[veh])
                        TriggerServerEvent("drp_vehcontrol:SetAirManuState", state_airmanu[veh])
                    end
                else
                    count_bcast_timer += 1
                end
            end
        end
        Wait(sleep)
    end
end)
