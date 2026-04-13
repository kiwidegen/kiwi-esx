local ESX = exports['es_extended']:getSharedObject()

-- Cache for first join times to reduce database queries
local firstJoinCache = {}

--- Get player's first join timestamp
---@param identifier string Player identifier
---@return number|nil firstJoin Unix timestamp or nil if new player
local function getFirstJoin(identifier)
    -- Check cache first
    if firstJoinCache[identifier] then
        return firstJoinCache[identifier]
    end

    -- Query database if not in cache
    local result = MySQL.single.await('SELECT firstjoin FROM player_firstjoin WHERE identifier = ?', {identifier})
    local firstJoin = result and result.firstjoin or nil

    -- Cache the result
    if firstJoin then
        firstJoinCache[identifier] = firstJoin
    end

    return firstJoin
end

--- Set player's first join timestamp
---@param identifier string Player identifier
---@param timestamp number Unix timestamp
local function setFirstJoin(identifier, timestamp)
    MySQL.insert.await('INSERT INTO player_firstjoin (identifier, firstjoin) VALUES (?, ?) ON DUPLICATE KEY UPDATE firstjoin = firstjoin',
        {identifier, timestamp})

    -- Update cache
    firstJoinCache[identifier] = timestamp
end

--- Check if player is still in protection period
---@param identifier string Player identifier
---@return boolean isProtected
---@return number timeRemaining Time remaining in seconds
local function isPlayerProtected(identifier)
    local firstJoin = getFirstJoin(identifier)

    if not firstJoin then
        return false, 0
    end

    local currentTime = os.time()
    local timeElapsed = currentTime - firstJoin
    local timeRemaining = Config.PROTECTION_DURATION - timeElapsed

    if timeRemaining > 0 then
        return true, timeRemaining
    else
        return false, 0
    end
end


--- Handle player connecting - track first join
AddEventHandler('playerConnecting', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local identifier = xPlayer.identifier
    local firstJoin = getFirstJoin(identifier)

    -- New player - set their first join time
    if not firstJoin then
        setFirstJoin(identifier, os.time())

        -- Log new player to Discord
        exports['drp-logs']:log('player', {
            source = source,
            title = '🆕 New Player Joined',
            description = 'A new player has joined the server and received new player protection',
            colorName = 'success',
            fields = {
                {
                    name = 'Identifier',
                    value = '||' .. identifier .. '||',
                    inline = true
                },
                {
                    name = 'Protection Duration',
                    value = math.floor(Config.PROTECTION_DURATION / 60) .. ' minutes',
                    inline = true
                }
            }
        })
    end
end)

--- Automatically send protection status when player loads (SERVER CONTROLLED - NO CLIENT TRIGGERS)
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    -- Wait a bit for client to be ready
    SetTimeout(2000, function()
        local isProtected, timeRemaining = isPlayerProtected(xPlayer.identifier)
        TriggerClientEvent('drp-junior:client:updateProtection', playerId, isProtected, timeRemaining)
    end)
end)

--- Command to test new player protection (for testing)
RegisterCommand('testnew', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    -- Clear cache first
    firstJoinCache[xPlayer.identifier] = nil

    -- Set their first join to current time (simulate new player)
    MySQL.update.await('DELETE FROM player_firstjoin WHERE identifier = ?', {xPlayer.identifier})
    setFirstJoin(xPlayer.identifier, os.time())

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Test Mode',
        description = 'You are now a new player (relogging recommended)',
        type = 'success'
    })

    -- Force update protection status
    TriggerClientEvent('drp-junior:client:updateProtection', source, true, Config.PROTECTION_DURATION)

    -- Log to Discord
    exports['drp-logs']:log('player', {
        source = source,
        title = '🧪 Test Mode Activated',
        description = 'A player activated junior test mode',
        colorName = 'warning',
        fields = {
            {
                name = 'Command',
                value = '/testnew',
                inline = true
            }
        }
    })
end, false)

--- Admin command to remove junior protection from a player
RegisterCommand('removejunior', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    -- Check if player is admin
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin' then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    local targetId = tonumber(args[1])

    if not targetId then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'Usage: /removejunior [player id]',
            type = 'error'
        })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xTarget then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    -- Set their first join to 1 hour ago (removes protection)
    local pastTime = os.time() - Config.PROTECTION_DURATION - 1
    MySQL.update.await('UPDATE player_firstjoin SET firstjoin = ? WHERE identifier = ?', {pastTime, xTarget.identifier})

    -- Update cache
    firstJoinCache[xTarget.identifier] = pastTime

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'New Player Protection Removed',
        description = 'Removed protection from ' .. GetPlayerName(targetId),
        type = 'success'
    })

    TriggerClientEvent('ox_lib:notify', targetId, {
        title = 'Protection Removed',
        description = 'Your new player protection has been removed by an admin',
        type = 'warning'
    })

    -- Force update protection status
    TriggerClientEvent('drp-junior:client:updateProtection', targetId, false, 0)

    -- Log to Discord
    exports['drp-logs']:log('player', {
        source = source,
        title = '🛡️ Protection Removed',
        description = 'An admin removed new player protection from a player',
        colorName = 'error',
        fields = {
            {
                name = 'Target Player',
                value = GetPlayerName(targetId) .. ' (ID: ' .. targetId .. ')',
                inline = true
            },
            {
                name = 'Target Identifier',
                value = '||' .. xTarget.identifier .. '||',
                inline = false
            }
        }
    })
end, false)

--- Handle resource start - send protection status to all online players
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Wait for server to be ready
    SetTimeout(2000, function()
        local xPlayers = ESX.GetExtendedPlayers()
        for _, xPlayer in pairs(xPlayers) do
            local isProtected, timeRemaining = isPlayerProtected(xPlayer.identifier)
            TriggerClientEvent('drp-junior:client:updateProtection', xPlayer.source, isProtected, timeRemaining)
        end
    end)
end)

--- SERVER-SIDE: Block weapon damage from protected players
AddEventHandler('weaponDamageEvent', function(sender, data)
    -- Early exit for invalid senders
    sender = tonumber(sender)
    if not sender or sender <= 0 then return end

    local xPlayer = ESX.GetPlayerFromId(sender)
    if not xPlayer then return end

    -- Check cache first, if protected cancel damage
    if isPlayerProtected(xPlayer.identifier) then
        CancelEvent()
    end
end)

--- SERVER-SIDE: Block entity damage from protected players
AddEventHandler('entityDamaged', function(victim, attacker, weaponHash, isMelee)
    -- Early exit for non-player attackers
    if not attacker or attacker == 0 then return end

    local attackerPlayer = NetworkGetPlayerIndexFromPed(attacker)
    if attackerPlayer == -1 then return end

    local attackerId = tonumber(GetPlayerServerId(attackerPlayer))
    if not attackerId or attackerId <= 0 then return end

    local xPlayer = ESX.GetPlayerFromId(attackerId)
    if not xPlayer then return end

    -- Check cache first, if protected cancel damage
    if isPlayerProtected(xPlayer.identifier) then
        CancelEvent()
    end
end)

--- Clean up cache when player disconnects (memory management)
AddEventHandler('playerDropped', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer and xPlayer.identifier then
        -- Keep cache but allow garbage collection if no longer needed
        -- We keep it because they might rejoin and we want to avoid DB queries
    end
end)

--- Export function for other scripts to check protection
exports('isPlayerProtected', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local isProtected, timeRemaining = isPlayerProtected(xPlayer.identifier)
    return isProtected
end)
