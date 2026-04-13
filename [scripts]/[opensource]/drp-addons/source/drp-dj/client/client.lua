---@diagnostic disable: undefined-global
-- DJ System - Club and venue music control
ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    PlayerData = ESX.GetPlayerData()
end)

--- Check if player's job is allowed for this DJ booth
---@param location table DJ location data
---@return boolean allowed Whether player can use this booth
local function isJobAllowed(location)
    if not location.jobs then
        return true
    end

    for _, job in pairs(location.jobs) do
        if job == PlayerData.job?.name then
            return true
        end
    end

    return false
end

--- Get saved songs menu
---@param locationId string Location identifier
local function showSavedSongsMenu(locationId)
    ESX.TriggerServerCallback('drp_dj:getSavedSongs', function(savedSongs)
        local options = {
            {
                title = 'Save Current Song',
                description = 'Save a song to play later',
                icon = 'save',
                onSelect = function()
                    local input = lib.inputDialog('Save Song', {
                        {
                            type = 'input',
                            label = 'Song Name',
                            description = 'Enter a name for this song',
                            required = true,
                            min = 1,
                            max = 30
                        },
                        {
                            type = 'input',
                            label = 'YouTube URL',
                            description = 'Enter the YouTube video URL',
                            required = true,
                            min = 10,
                            max = 200
                        }
                    })

                    if input then
                        TriggerServerEvent('drp_dj:saveSong', input[1], input[2])
                        lib.notify({
                            description = 'Song saved successfully',
                            type = 'success'
                        })
                    end
                end
            }
        }

        if savedSongs then
            for _, song in pairs(savedSongs) do
                options[#options + 1] = {
                    title = song.label,
                    description = 'Play this saved song',
                    icon = 'music',
                    onSelect = function()
                        TriggerServerEvent('drp_dj:playMusic', locationId, song.link)
                    end,
                    metadata = {
                        {label = 'Actions', value = 'Right click to delete'}
                    }
                }
            end
        end

        lib.registerContext({
            id = 'dj_saved_songs',
            title = 'Saved Songs',
            menu = 'dj_main_menu',
            options = options
        })

        lib.showContext('dj_saved_songs')
    end)
end

--- Open DJ control menu
---@param locationId string Location identifier
---@param locationData table Location configuration
---@param isPlaying boolean Whether music is currently playing
local function openDJMenu(locationId, locationData, isPlaying)
    local options = {}

    if not isPlaying then
        options[#options + 1] = {
            title = 'Play Song',
            description = 'Enter YouTube URL to play',
            icon = 'play',
            onSelect = function()
                local input = lib.inputDialog('Play Music', {
                    {
                        type = 'input',
                        label = 'YouTube URL',
                        description = 'Enter the YouTube video URL',
                        required = true,
                        min = 10,
                        max = 200
                    },
                    {
                        type = 'number',
                        label = 'Volume',
                        description = 'Music volume (1-100)',
                        required = true,
                        min = 1,
                        max = 100,
                        default = 50
                    }
                })

                if input then
                    TriggerServerEvent('drp_dj:playMusic', locationId, input[1], input[2] / 100)
                end
            end
        }
    else
        options[#options + 1] = {
            title = 'Change Song',
            description = 'Play a different song',
            icon = 'forward',
            onSelect = function()
                local input = lib.inputDialog('Change Music', {
                    {
                        type = 'input',
                        label = 'YouTube URL',
                        description = 'Enter the YouTube video URL',
                        required = true,
                        min = 10,
                        max = 200
                    },
                    {
                        type = 'number',
                        label = 'Volume',
                        description = 'Music volume (1-100)',
                        required = true,
                        min = 1,
                        max = 100,
                        default = 50
                    }
                })

                if input then
                    TriggerServerEvent('drp_dj:playMusic', locationId, input[1], input[2] / 100)
                end
            end
        }

        options[#options + 1] = {
            title = 'Stop Music',
            description = 'Stop current playback',
            icon = 'stop',
            onSelect = function()
                TriggerServerEvent('drp_dj:stopMusic', locationId)
            end
        }

        options[#options + 1] = {
            title = 'Pause/Resume',
            description = 'Toggle music playback',
            icon = 'pause',
            onSelect = function()
                TriggerServerEvent('drp_dj:pauseMusic', locationId)
            end
        }

        options[#options + 1] = {
            title = 'Change Volume',
            description = 'Adjust music volume',
            icon = 'volume-high',
            onSelect = function()
                local input = lib.inputDialog('Change Volume', {
                    {
                        type = 'number',
                        label = 'Volume',
                        description = 'Enter volume level (1-100)',
                        required = true,
                        min = 1,
                        max = 100,
                        default = 50
                    }
                })

                if input then
                    TriggerServerEvent('drp_dj:changeVolume', locationId, input[1] / 100)
                end
            end
        }

        options[#options + 1] = {
            title = 'Change Radius',
            description = 'Adjust music hearing distance',
            icon = 'bullseye',
            onSelect = function()
                local input = lib.inputDialog('Change Radius', {
                    {
                        type = 'number',
                        label = 'Radius',
                        description = 'Enter hearing distance in meters (10-50)',
                        required = true,
                        min = 10,
                        max = 50,
                        default = math.min(locationData.radius or 50, 50)
                    }
                })

                if input then
                    TriggerServerEvent('drp_dj:changeRadius', locationId, input[1])
                end
            end
        }
    end

    options[#options + 1] = {
        title = 'Saved Songs',
        description = 'Browse your saved songs',
        icon = 'list',
        onSelect = function()
            showSavedSongsMenu(locationId)
        end
    }

    -- Add preset playlist if available
    if locationData.playlist and #locationData.playlist > 0 then
        options[#options + 1] = {
            title = 'Preset Playlist',
            description = 'Choose from preset songs',
            icon = 'music',
            onSelect = function()
                local playlistOptions = {}
                for _, song in pairs(locationData.playlist) do
                    playlistOptions[#playlistOptions + 1] = {
                        title = song.name,
                        description = song.producer,
                        icon = 'music',
                        onSelect = function()
                            TriggerServerEvent('drp_dj:playMusic', locationId, song.link)
                        end
                    }
                end

                lib.registerContext({
                    id = 'dj_playlist_menu',
                    title = 'Preset Playlist',
                    menu = 'dj_main_menu',
                    options = playlistOptions
                })

                lib.showContext('dj_playlist_menu')
            end
        }
    end

    lib.registerContext({
        id = 'dj_main_menu',
        title = 'DJ Booth',
        options = options
    })

    lib.showContext('dj_main_menu')
end

--- Track playing state per location
local playingState = {}

RegisterNetEvent('drp_dj:updatePlayState', function(locationId, isPlaying)
    playingState[locationId] = isPlaying
end)

--- Track which locations player is currently in range of
local inRangeLocations = {}

--- Monitor active music playback and stop when out of range
CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        local coords = GetEntityCoords(PlayerPedId())

        for locationId, locationData in pairs(Config.DJ) do
            local distance = #(coords - locationData.coords)
            local wasInRange = inRangeLocations[locationId]
            local isInRange = distance <= locationData.radius

            -- Player entered range - request active session
            if isInRange and not wasInRange then
                inRangeLocations[locationId] = true
                TriggerServerEvent('drp_dj:requestSync', locationId)
            end

            -- Player left range - stop music
            if not isInRange and wasInRange then
                inRangeLocations[locationId] = false
                if playingState[locationId] then
                    -- Destroy the sound using xsound export
                    local soundId = 'dj_' .. locationId
                    exports.xsound:Destroy(soundId)
                    playingState[locationId] = false
                end
            end
        end
    end
end)

--- Receive synced music session from server
RegisterNetEvent('drp_dj:syncSession', function(locationId, sessionData)
    if sessionData then
        local location = Config.DJ[locationId]
        -- Start playing the active session from the correct timestamp
        TriggerEvent('xsound:stateSound', 'play', {
            soundId = 'dj_' .. locationId,
            url = sessionData.url,
            volume = sessionData.volume,
            position = location.coords,
            maxDistance = location.radius,
            loop = true,
            timeStamp = sessionData.timeStamp or 0
        })
        playingState[locationId] = true

        -- If paused, pause it locally
        if not sessionData.isPlaying then
            Wait(100) -- Small delay to ensure sound started before pausing
            TriggerEvent('xsound:stateSound', 'pause', {
                soundId = 'dj_' .. locationId
            })
        end
    end
end)

--- Update radius for a DJ location
RegisterNetEvent('drp_dj:updateRadius', function(locationId, radius)
    -- Update config
    Config.DJ[locationId].radius = radius

    -- If music is playing, update the sound's max distance
    if playingState[locationId] then
        exports.xsound:setMaxDistance('dj_' .. locationId, radius)
    end
end)

--- Destroy sound for a location
RegisterNetEvent('drp_dj:destroySound', function(locationId)
    local soundId = 'dj_' .. locationId
    exports.xsound:Destroy(soundId)
    playingState[locationId] = false
end)

--- Monitor DJ booth locations
CreateThread(function()
    local coords = vec3(0, 0, 0)

    while true do
        local sleep = 1500
        coords = GetEntityCoords(PlayerPedId())

        for locationId, locationData in pairs(Config.DJ) do
            local distance = #(coords - locationData.coords)

            if distance <= 30.0 then
                sleep = 10
                DrawMarker(1, locationData.coords.x, locationData.coords.y, locationData.coords.z - 1.0,
                    0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 195, 255, 100, false, false, 2, false, false, false, false)

                if distance <= 1.0 then
                    lib.showTextUI('[E] - Open DJ Booth')

                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()

                        if isJobAllowed(locationData) then
                            openDJMenu(locationId, locationData, playingState[locationId] or false)
                        else
                            lib.notify({
                                description = 'You cannot access this DJ booth',
                                type = 'error'
                            })
                        end
                    end
                elseif distance > 1.0 and distance <= 30.0 then
                    lib.hideTextUI()
                end
            end
        end

        Wait(sleep)
    end
end)
