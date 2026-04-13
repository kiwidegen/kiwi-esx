---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()

local activeSessions = {}

--- Check if player has DJ permission for location
---@param source number Player source
---@param location table DJ location data
---@return boolean hasPermission Whether player can use DJ booth
local function hasDJPermission(source, location)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    -- Check if player's job is allowed
    if location.jobs then
        for _, job in pairs(location.jobs) do
            if job == xPlayer.job.name then
                return true
            end
        end
        return false
    end

    return true
end

--- Get DJ location from player coordinates
---@param coords vector3 Player coordinates
---@return string|nil locationId Location identifier
---@return table|nil location Location data
local function getDJLocation(coords)
    for locationId, locationData in pairs(Config.DJ) do
        if #(coords - locationData.coords) <= locationData.radius then
            return locationId, locationData
        end
    end
    return nil, nil
end

--- Extract YouTube video ID from URL
---@param url string YouTube URL
---@return string|nil videoId YouTube video identifier
local function getYouTubeId(url)
    local videoId = string.match(url, "v=([%w-_]+)")
    if not videoId then
        videoId = string.match(url, "youtu.be/([%w-_]+)")
    end
    return videoId
end

--- Play music at DJ location
RegisterNetEvent('drp_dj:playMusic', function(locationId, url, volume)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local location = Config.DJ[locationId]
    if not location then
        lib.notify(source, {
            description = 'Invalid DJ location',
            type = 'error'
        })
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if #(playerCoords - location.coords) > location.radius then
        lib.notify(source, {
            description = 'You are too far from the DJ booth',
            type = 'error'
        })
        return
    end

    if not hasDJPermission(source, location) then
        lib.notify(source, {
            description = 'You do not have permission to use this DJ booth',
            type = 'error'
        })
        return
    end

    -- Validate YouTube URL
    local videoId = getYouTubeId(url)
    if not videoId then
        lib.notify(source, {
            description = 'Invalid YouTube URL',
            type = 'error'
        })
        return
    end

    -- Default volume if not provided
    volume = volume or 0.5

    -- Update active session
    activeSessions[locationId] = {
        dj = source,
        videoId = videoId,
        url = url,
        volume = volume,
        isPlaying = true,
        startTime = os.time()
    }

    -- Broadcast to all players in range
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
        if #(targetCoords - location.coords) <= location.radius then
            TriggerClientEvent('xsound:stateSound', playerId, 'play', {
                soundId = 'dj_' .. locationId,
                url = url,
                volume = volume,
                position = location.coords,
                maxDistance = location.radius,
                loop = true
            })
            TriggerClientEvent('drp_dj:updatePlayState', playerId, locationId, true)
        end
    end

    lib.notify(source, {
        description = 'Now playing music',
        type = 'success'
    })
end)

--- Stop music at DJ location
RegisterNetEvent('drp_dj:stopMusic', function(locationId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local location = Config.DJ[locationId]
    if not location then
        lib.notify(source, {
            description = 'Invalid DJ location',
            type = 'error'
        })
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if #(playerCoords - location.coords) > location.radius then
        lib.notify(source, {
            description = 'You are too far from the DJ booth',
            type = 'error'
        })
        return
    end

    if not hasDJPermission(source, location) then
        lib.notify(source, {
            description = 'You do not have permission to use this DJ booth',
            type = 'error'
        })
        return
    end

    local session = activeSessions[locationId]
    if not session then
        lib.notify(source, {
            description = 'No active music session',
            type = 'error'
        })
        return
    end

    -- Broadcast stop to all players
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        TriggerClientEvent('drp_dj:destroySound', playerId, locationId)
    end

    activeSessions[locationId] = nil

    lib.notify(source, {
        description = 'Music stopped',
        type = 'success'
    })
end)

--- Pause/Resume music at DJ location
RegisterNetEvent('drp_dj:pauseMusic', function(locationId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local location = Config.DJ[locationId]
    if not location then
        lib.notify(source, {
            description = 'Invalid DJ location',
            type = 'error'
        })
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if #(playerCoords - location.coords) > location.radius then
        lib.notify(source, {
            description = 'You are too far from the DJ booth',
            type = 'error'
        })
        return
    end

    if not hasDJPermission(source, location) then
        lib.notify(source, {
            description = 'You do not have permission to use this DJ booth',
            type = 'error'
        })
        return
    end

    local session = activeSessions[locationId]
    if not session then
        lib.notify(source, {
            description = 'No active music session',
            type = 'error'
        })
        return
    end

    -- Toggle play state
    local wasPaused = not session.isPlaying
    session.isPlaying = not session.isPlaying

    -- Update startTime when resuming to maintain sync
    if session.isPlaying and session.pausedAt then
        -- Adjust start time to account for pause duration
        local pauseDuration = os.time() - session.pausedAt
        session.startTime = session.startTime + pauseDuration
        session.pausedAt = nil
    elseif not session.isPlaying then
        -- Track when paused
        session.pausedAt = os.time()
    end

    -- Broadcast to all players in range
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
        if #(targetCoords - location.coords) <= location.radius then
            TriggerClientEvent('xsound:stateSound', playerId, session.isPlaying and 'resume' or 'pause', {
                soundId = 'dj_' .. locationId
            })
        end
    end

    lib.notify(source, {
        description = session.isPlaying and 'Music resumed' or 'Music paused',
        type = 'success'
    })
end)

--- Change music volume at DJ location
RegisterNetEvent('drp_dj:changeVolume', function(locationId, volume)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local location = Config.DJ[locationId]
    if not location then
        lib.notify(source, {
            description = 'Invalid DJ location',
            type = 'error'
        })
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if #(playerCoords - location.coords) > location.radius then
        lib.notify(source, {
            description = 'You are too far from the DJ booth',
            type = 'error'
        })
        return
    end

    if not hasDJPermission(source, location) then
        lib.notify(source, {
            description = 'You do not have permission to use this DJ booth',
            type = 'error'
        })
        return
    end

    local session = activeSessions[locationId]
    if not session then
        lib.notify(source, {
            description = 'No active music session',
            type = 'error'
        })
        return
    end

    -- Update volume
    session.volume = volume

    -- Broadcast to all players in range
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
        if #(targetCoords - location.coords) <= location.radius then
            TriggerClientEvent('xsound:stateSound', playerId, 'volume', {
                soundId = 'dj_' .. locationId,
                volume = volume
            })
        end
    end

    lib.notify(source, {
        description = ('Volume set to %d%%'):format(math.floor(volume * 100)),
        type = 'success'
    })
end)

--- Change music radius at DJ location
RegisterNetEvent('drp_dj:changeRadius', function(locationId, radius)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Enforce 50 meter maximum
    if radius > 50 then
        lib.notify(source, {
            description = 'Maximum radius is 50 meters',
            type = 'error'
        })
        return
    end

    if radius < 10 then
        lib.notify(source, {
            description = 'Minimum radius is 10 meters',
            type = 'error'
        })
        return
    end

    local location = Config.DJ[locationId]
    if not location then
        lib.notify(source, {
            description = 'Invalid DJ location',
            type = 'error'
        })
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if #(playerCoords - location.coords) > location.radius then
        lib.notify(source, {
            description = 'You are too far from the DJ booth',
            type = 'error'
        })
        return
    end

    if not hasDJPermission(source, location) then
        lib.notify(source, {
            description = 'You do not have permission to use this DJ booth',
            type = 'error'
        })
        return
    end

    local session = activeSessions[locationId]
    if not session then
        lib.notify(source, {
            description = 'No active music session',
            type = 'error'
        })
        return
    end

    -- Update radius in config and session
    Config.DJ[locationId].radius = radius
    session.radius = radius

    -- Broadcast radius update to all players
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        TriggerClientEvent('drp_dj:updateRadius', playerId, locationId, radius)
    end

    lib.notify(source, {
        description = ('Radius set to %dm'):format(math.floor(radius)),
        type = 'success'
    })
end)

--- Save song to player's collection
RegisterNetEvent('drp_dj:saveSong', function(name, link)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.insert('INSERT INTO dj_saved_songs (identifier, label, link) VALUES (?, ?, ?)',
        {xPlayer.identifier, name, link},
        function(id)
            if id then
                lib.notify(source, {
                    description = 'Song saved successfully',
                    type = 'success'
                })
            else
                lib.notify(source, {
                    description = 'Failed to save song',
                    type = 'error'
                })
            end
        end
    )
end)

--- Get player's saved songs
ESX.RegisterServerCallback('drp_dj:getSavedSongs', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    MySQL.query('SELECT label, link FROM dj_saved_songs WHERE identifier = ?',
        {xPlayer.identifier},
        function(result)
            if result and #result > 0 then
                local savedSongs = {}
                for i = 1, #result do
                    savedSongs[#savedSongs + 1] = {
                        label = result[i].label,
                        link = result[i].link
                    }
                end
                cb(savedSongs)
            else
                cb(nil)
            end
        end
    )
end)

--- Delete saved song
RegisterNetEvent('drp_dj:deleteSong', function(label, link)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.execute('DELETE FROM dj_saved_songs WHERE identifier = ? AND label = ? AND link = ?',
        {xPlayer.identifier, label, link},
        function(affectedRows)
            if affectedRows > 0 then
                lib.notify(source, {
                    description = 'Song deleted',
                    type = 'success'
                })
            else
                lib.notify(source, {
                    description = 'Failed to delete song',
                    type = 'error'
                })
            end
        end
    )
end)

--- Sync active music session to player entering range
RegisterNetEvent('drp_dj:requestSync', function(locationId)
    local source = source
    local session = activeSessions[locationId]

    if session then
        -- Calculate elapsed time since music started
        local timeStamp = 0
        if session.isPlaying and session.startTime then
            timeStamp = os.time() - session.startTime
        end

        -- Send active session data to player
        TriggerClientEvent('drp_dj:syncSession', source, locationId, {
            url = session.url,
            volume = session.volume,
            isPlaying = session.isPlaying,
            timeStamp = timeStamp
        })
    end
end)

--- Stop music when DJ disconnects
AddEventHandler('playerDropped', function()
    local source = source

    for locationId, session in pairs(activeSessions) do
        if session.dj == source then
            local location = Config.DJ[locationId]
            if location then
                -- Broadcast stop to all players
                local players = ESX.GetPlayers()
                for _, playerId in ipairs(players) do
                    TriggerClientEvent('drp_dj:destroySound', playerId, locationId)
                end
            end

            activeSessions[locationId] = nil
        end
    end
end)
