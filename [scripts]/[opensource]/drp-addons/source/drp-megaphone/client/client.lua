---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}
local cache = cache or {}

---@param job table Job data
RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    PlayerData = ESX.GetPlayerData()
end)

--- Audio submix configuration for megaphone effect
---@type table<string|number, number>
local SubmixData = {
    [`default`] = 1,
    [`freq_low`] = 200.0,
    [`freq_hi`] = 6000.0,
    [`rm_mod_freq`] = 0.0,
    [`rm_mix`] = 0.2,
    [`fudge`] = 0.0,
    [`o_freq_lo`] = 550.0,
    [`o_freq_hi`] = 0.0,
}

local submix = CreateAudioSubmix("Megaphone")

CreateThread(function()
    SetAudioSubmixEffectRadioFx(submix, 0)
    for paramIndex, paramValue in pairs(SubmixData) do
        SetAudioSubmixEffectParamInt(submix, 0, paramIndex --[[@as number]], paramValue)
    end
    AddAudioSubmixOutput(submix, 0)
end)

--- Activates megaphone when key is pressed
RegisterCommand("+megaphone", function()
    -- Check if player is in a vehicle
    if not cache.vehicle or GetVehicleClass(cache.vehicle) ~= Config.Megaphone.VehicleClass then
        return
    end

    -- Check if player has required job
    if not Config.Megaphone.AllowedJobs[PlayerData.job?.name] then
        return
    end

    LocalPlayer.state:set("using_megaphone", true, true)
end)

--- Deactivates megaphone when key is released
RegisterCommand("-megaphone", function()
    LocalPlayer.state:set("using_megaphone", false, true)
end)

--- Handles megaphone state changes for all players
---@param bagName string State bag name
---@param key string State key
---@param value boolean Whether megaphone is active
AddStateBagChangeHandler("using_megaphone", nil, function(bagName, key, value)
    local playerId = GetPlayerFromStateBagName(bagName)
    if playerId == 0 then return end

    local serverId = GetPlayerServerId(playerId)

    -- Adjust voice volume and apply audio submix
    MumbleSetVolumeOverrideByServerId(serverId, value and 3.0 or -1.0)
    MumbleSetSubmixForServerId(serverId, value and submix or -1)
    exports["pma-voice"]:setVoiceProperty("voiceFeedback", value or false)
end)

-- Register keybinding
RegisterKeyMapping("+megaphone", "Use Megaphone", "keyboard", "b")
