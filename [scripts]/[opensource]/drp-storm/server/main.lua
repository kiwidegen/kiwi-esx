local playerCooldowns = {}
local playerDeathCauses = {} -- Track death causes server-side
local playerNameCache = {} -- Cache player names to reduce native calls

-- Constants
local DEATH_CAUSE_EXPIRY <const> = 5 -- Seconds before death cause is considered stale
local CLEANUP_INTERVAL <const> = 60000 -- Clean stale data every 60 seconds

--- Get cached player name (optimization)
---@param source number Player source
---@return string name Player name
local function GetCachedPlayerName(source)
    if not playerNameCache[source] then
        playerNameCache[source] = GetCachedPlayerName(source)
    end
    return playerNameCache[source]
end

--- Get player cooldown remaining time
---@param source number Player source
---@return number remaining Remaining cooldown time in seconds
local function GetCooldownRemaining(source)
    local cooldownEnd = playerCooldowns[source]
    if not cooldownEnd then return 0 end

    local currentTime = os.time()
    local remaining = cooldownEnd - currentTime

    return remaining > 0 and remaining or 0
end

--- Clean up stale death cause data (memory optimization)
---@return nil
local function CleanupStaleDeathData()
    local currentTime = os.time()

    for source, deathData in pairs(playerDeathCauses) do
        if currentTime - deathData.timestamp > DEATH_CAUSE_EXPIRY then
            playerDeathCauses[source] = nil
        end
    end
end

-- Periodic cleanup thread for stale data
CreateThread(function()
    while true do
        Wait(CLEANUP_INTERVAL)
        CleanupStaleDeathData()
    end
end)

--- Set player cooldown
---@param source number Player source
---@param duration number Cooldown duration in seconds
local function SetPlayerCooldown(source, duration)
    local currentTime = os.time()
    playerCooldowns[source] = currentTime + duration

    TriggerClientEvent('drp-cooldown:client:startCooldown', source, duration)
end

--- Remove player cooldown
---@param source number Player source
local function RemovePlayerCooldown(source)
    playerCooldowns[source] = nil
    TriggerClientEvent('drp-cooldown:client:removeCooldown', source)
end

--- Handle player death (SERVER-SIDE VALIDATION ONLY)
---@param source number Player source
---@param weaponHash number Weapon that killed the player
local function HandlePlayerDeath(source, weaponHash)
    -- Validate weapon hash server-side
    if not weaponHash or weaponHash == 0 then return end

    -- Check if weapon is in the blocked list (server-side validation)
    if not Config.IsWeaponBlocked(weaponHash) then return end

    -- Check if player already has a cooldown
    local remaining = GetCooldownRemaining(source)
    if remaining > 0 then
        -- Extend cooldown
        SetPlayerCooldown(source, Config.CooldownDuration)
    else
        -- Start new cooldown
        SetPlayerCooldown(source, Config.CooldownDuration)
    end
end

-- SERVER-SIDE death detection via entity death event (optimized)
AddEventHandler('entityDying', function(victim, killer, weaponHash)
    -- Only process player deaths (1 = Ped entity type)
    if GetEntityType(victim) ~= 1 then return end

    -- Get player source from ped
    local source = NetworkGetEntityOwner(victim)
    if not source or source == 0 then return end

    -- Store death cause for validation (cached timestamp)
    local currentTime = os.time()
    playerDeathCauses[source] = {
        weaponHash = weaponHash,
        timestamp = currentTime
    }

    -- Handle the death with server-side validation
    HandlePlayerDeath(source, weaponHash)
end)

-- Alternative: Monitor state bag changes for death (redundant failsafe)
AddStateBagChangeHandler('isDead', nil, function(bagName, key, value, reserved, replicated)
    if not value then return end

    -- Extract player source from state bag name
    local netId = tonumber(bagName:gsub('player:', ''), 10)
    if not netId then return end

    local source = netId

    -- Use stored death cause if available (within expiry window)
    local deathData = playerDeathCauses[source]
    if deathData and (os.time() - deathData.timestamp) < DEATH_CAUSE_EXPIRY then
        HandlePlayerDeath(source, deathData.weaponHash)
        -- Clean up immediately after use (no need to keep it)
        playerDeathCauses[source] = nil
    end
end)

-- Check cooldown status
lib.callback.register('drp-cooldown:server:checkCooldown', function(source)
    local remaining = GetCooldownRemaining(source)
    return remaining
end)

-- Admin command: Place player on cooldown
lib.addCommand('cooldown', {
    help = 'Place a player on combat cooldown',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player ID',
        },
        {
            name = 'duration',
            type = 'number',
            help = 'Duration in seconds (optional, default: ' .. Config.CooldownDuration .. ')',
            optional = true
        }
    },
    restricted = Config.AdminPermission
}, function(source, args)
    local target = args.target
    local duration = args.duration or Config.CooldownDuration

    if not target then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Invalid player ID',
            type = 'error'
        })
        return
    end

    if duration < 1 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Duration must be at least 1 second',
            type = 'error'
        })
        return
    end

    -- Set cooldown
    SetPlayerCooldown(target, duration)

    -- Notify admin
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Cooldown Applied',
        description = ('Applied %d second cooldown to %s'):format(duration, GetPlayerName(target)),
        type = 'success'
    })

    -- Notify target with admin indicator
    local notification = Config.Notifications.adminPlacedCooldown
    TriggerClientEvent('ox_lib:notify', target, {
        id = 'combat_cooldown',
        title = notification.title,
        description = notification.description,
        type = notification.type,
        icon = notification.icon,
        iconColor = notification.iconColor,
        countdown = duration,
        duration = duration * 1000
    })
end)

-- Test command: Test cooldown (for solo testing)
lib.addCommand('testcooldown', {
    help = 'Test the cooldown system on yourself',
    params = {
        {
            name = 'duration',
            type = 'number',
            help = 'Duration in seconds (optional, default: 30)',
            optional = true
        }
    }
}, function(source, args)
    local duration = args.duration or 30

    if duration < 1 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Duration must be at least 1 second',
            type = 'error'
        })
        return
    end

    -- Set test cooldown
    SetPlayerCooldown(source, duration)

    -- Notify player
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Test Cooldown',
        description = ('Testing %d second cooldown'):format(duration),
        type = 'info'
    })
end)

-- Remove cooldown command
lib.addCommand('removecooldown', {
    help = 'Remove combat cooldown from a player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player ID',
        }
    },
    restricted = Config.AdminPermission
}, function(source, args)
    local target = args.target

    if not target then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Invalid player ID',
            type = 'error'
        })
        return
    end

    local remaining = GetCooldownRemaining(target)
    if remaining <= 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Info',
            description = 'Player does not have an active cooldown',
            type = 'info'
        })
        return
    end

    -- Remove cooldown
    RemovePlayerCooldown(target)

    -- Notify admin
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Cooldown Removed',
        description = ('Removed cooldown from %s'):format(GetPlayerName(target)),
        type = 'success'
    })

    -- Notify target
    TriggerClientEvent('ox_lib:notify', target, Config.Notifications.cooldownExpired)
end)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local source = source

    -- Cleanup all player data (memory optimization)
    playerCooldowns[source] = nil
    playerDeathCauses[source] = nil
    playerNameCache[source] = nil
end)

-- Debug command: Check weapon hash and group (useful for custom weapons)
lib.addCommand('checkweapon', {
    help = 'Check weapon hash and group for debugging custom weapons',
    restricted = Config.AdminPermission
}, function(source, args)
    TriggerClientEvent('drp-cooldown:client:checkCurrentWeapon', source)
end)

-- Debug: Validate weapon (server-side check)
RegisterNetEvent('drp-cooldown:server:validateWeapon', function(weaponHash)
    local source = source

    -- Only allow admins to use this
    if not IsPlayerAceAllowed(source, Config.AdminPermission) then return end

    local weaponGroup = GetWeapontypeGroup(weaponHash)
    local isBlocked = Config.IsWeaponBlocked(weaponHash)

    -- Send results back to client
    TriggerClientEvent('drp-cooldown:client:showWeaponInfo', source, weaponHash, weaponGroup, isBlocked)
end)

-- Export functions for other resources
exports('GetCooldownRemaining', GetCooldownRemaining)
exports('SetPlayerCooldown', SetPlayerCooldown)
exports('RemovePlayerCooldown', RemovePlayerCooldown)
