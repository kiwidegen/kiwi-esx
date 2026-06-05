Adjustments = {}

function Adjustments:RemoveHudComponents()
    for i = 1, #Config.RemoveHudComponents do
        if Config.RemoveHudComponents[i] then
            SetHudComponentSize(i, 0.0, 0.0)
            SetHudComponentPosition(i, 900.0, 900.0)
        end
    end
end

function Adjustments:DisableAimAssist()
    if Config.DisableAimAssist then
        SetPlayerTargetingMode(3)
    end
end

function Adjustments:DisableNPCDrops()
    if Config.DisableNPCDrops then
        local weaponPickups = {
            `PICKUP_WEAPON_CARBINERIFLE`,
            `PICKUP_WEAPON_PISTOL`,
            `PICKUP_WEAPON_PUMPSHOTGUN`,
        }
        for i = 1, #weaponPickups do
            ToggleUsePickupsForPlayer(ESX.playerId, weaponPickups[i], false)
        end
    end
end

function Adjustments:SeatShuffle()
    if Config.DisableVehicleSeatShuff then
        AddEventHandler('esx:enteredVehicle', function(vehicle, _, seat)
            if seat > -1 then
                local ped = PlayerPedId()
                SetPedIntoVehicle(ped, vehicle, seat)
                SetPedConfigFlag(ped, 184, true)
            end
        end)
    end
end

function Adjustments:HealthRegeneration()
    if Config.DisableHealthRegeneration then
        SetPlayerHealthRechargeMultiplier(ESX.playerId, 0.0)
    end
end

function Adjustments:AmmoAndVehicleRewards()
    CreateThread(function()
        while true do
            if Config.DisableDisplayAmmo then
                DisplayAmmoThisFrame(false)
            end
            if Config.DisableVehicleRewards then
                DisablePlayerVehicleRewards(ESX.playerId)
            end
            Wait(0)
        end
    end)
end

function Adjustments:EnablePvP()
    if Config.EnablePVP then
        local ped = PlayerPedId()
        SetCanAttackFriendly(ped, true, false)
        NetworkSetFriendlyFireOption(true)
    end
end

function Adjustments:DispatchServices()
    if Config.DisableDispatchServices then
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end
        SetAudioFlag('PoliceScannerDisabled', true)
    end
end

function Adjustments:NPCScenarios()
    if Config.DisableScenarios then
        local scenarios = {
            'WORLD_VEHICLE_ATTRACTOR',      'WORLD_VEHICLE_AMBULANCE',
            'WORLD_VEHICLE_BICYCLE_BMX',    'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
            'WORLD_VEHICLE_BICYCLE_ROAD',   'WORLD_VEHICLE_BIKER',
            'WORLD_VEHICLE_BOAT_IDLE',      'WORLD_VEHICLE_BROKEN_DOWN',
            'WORLD_VEHICLE_BUSINESSMEN',    'WORLD_VEHICLE_CONSTRUCTION_SOLO',
            'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
            'WORLD_VEHICLE_DRIVE_PASSENGERS',
            'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
            'WORLD_VEHICLE_DRIVE_SOLO',     'WORLD_VEHICLE_FIRE_TRUCK',
            'WORLD_VEHICLE_EMPTY',          'WORLD_VEHICLE_MARIACHI',
            'WORLD_VEHICLE_MECHANIC',       'WORLD_VEHICLE_PARK_PARALLEL',
            'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
            'WORLD_VEHICLE_POLICE_BIKE',    'WORLD_VEHICLE_POLICE_CAR',
            'WORLD_VEHICLE_POLICE',         'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
            'WORLD_VEHICLE_SECURITY_CAR',   'WORLD_VEHICLE_STREETRACE',
            'WORLD_VEHICLE_TOURBUS',        'WORLD_VEHICLE_TOURIST',
            'WORLD_VEHICLE_TRACTOR',        'WORLD_VEHICLE_TRUCK_LOGS',
            'WORLD_VEHICLE_TRUCKS_TRAILERS','WORLD_HUMAN_PAPARAZZI',
        }
        for i = 1, #scenarios do
            SetScenarioTypeEnabled(scenarios[i], false)
        end
    end
end

function Adjustments:LicensePlates()
    SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomAIPlates)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Discord rich presence with placeholder substitution
-- ─────────────────────────────────────────────────────────────────────────────

local placeholders = {
    server_name       = function() return GetConvar('sv_projectName', 'ESX') end,
    server_endpoint   = function() return GetCurrentServerEndpoint() or 'localhost:30120' end,
    server_players    = function() return tostring(GlobalState.playerCount or 0) end,
    server_maxplayers = function() return tostring(GetConvarInt('sv_maxClients', 48)) end,
    player_name       = function() return GetPlayerName(ESX.playerId) end,
    player_rp_name    = function() return ESX.PlayerData.name or 'John Doe' end,
    player_id         = function() return tostring(ESX.serverId) end,
    player_street     = function()
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then return 'Unknown' end
        local coords = GetEntityCoords(ped)
        return GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)) or 'Unknown'
    end,
}

local function replacePlaceholders(text)
    for key, fn in pairs(placeholders) do
        local ok, val = pcall(fn)
        text = text:gsub(('{%s}'):format(key), ok and tostring(val) or 'Unknown')
    end
    return text
end

function Adjustments:DiscordPresence()
    if Config.DiscordActivity.appId ~= 0 then
        CreateThread(function()
            while true do
                SetDiscordAppId(Config.DiscordActivity.appId)
                SetRichPresence(replacePlaceholders(Config.DiscordActivity.presence))
                SetDiscordRichPresenceAsset(Config.DiscordActivity.assetName)
                SetDiscordRichPresenceAssetText(replacePlaceholders(Config.DiscordActivity.assetText))

                for i = 1, #Config.DiscordActivity.buttons do
                    local btn = Config.DiscordActivity.buttons[i]
                    SetDiscordRichPresenceAction(i - 1, btn.label, replacePlaceholders(btn.url))
                end

                Wait(Config.DiscordActivity.refresh)
            end
        end)
    end
end

function Adjustments:WantedLevel()
    if not Config.EnableWantedLevel then
        ClearPlayerWantedLevel(ESX.playerId)
        SetMaxWantedLevel(0)
    end
end

function Adjustments:DisableRadio()
    if Config.RemoveHudComponents[16] then
        AddEventHandler('esx:enteredVehicle', function(vehicle)
            SetVehRadioStation(vehicle, 'OFF')
            SetUserRadioControlEnabled(false)
        end)
    end
end


function Adjustments:Load()
    self:RemoveHudComponents()
    self:DisableAimAssist()
    self:DisableNPCDrops()
    self:SeatShuffle()
    self:HealthRegeneration()
    self:AmmoAndVehicleRewards()
    self:EnablePvP()
    self:DispatchServices()
    self:NPCScenarios()
    self:LicensePlates()
    self:DiscordPresence()
    self:WantedLevel()
    self:DisableRadio()
end
