---@type table<number, EventBubble>
local activeBubbles = {}

---@type number
local bubbleIdCounter = 0

---@class EventBubble
---@field id number Unique bubble identifier
---@field position vector3 Bubble center position
---@field radius number Bubble radius in units
---@field createdBy number Source ID of creator
---@field createdAt number Unix timestamp of creation
---@field allowedJobs table<number, string> List of job names allowed to enter (empty or contains 'all' = everyone)

--- Debug print helper
---@param message string Debug message
local function debugPrint(message)
    if EventsConfig.Debug then
        print(string.format('^3[DRP-Events DEBUG]^0 %s', message))
    end
end

--- Check if player has permission to manage events
---@param source number Player source ID
---@return boolean hasPermission Whether the player has event management permissions
local function hasEventPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        debugPrint(string.format('Permission check failed - xPlayer is nil for source %d', source))
        return false
    end

    local playerGroup = xPlayer.getGroup()
    debugPrint(string.format('Checking permissions for %s (group: %s)', xPlayer.getName(), playerGroup))

    for _, group in ipairs(EventsConfig.AllowedGroups) do
        if playerGroup == group then
            debugPrint(string.format('Permission granted - %s has group %s', xPlayer.getName(), group))
            return true
        end
    end

    debugPrint(string.format('Permission denied - %s does not have required group', xPlayer.getName()))
    return false
end

--- Send notification to player
---@param source number Player source ID
---@param title string Notification title
---@param description string Notification message
---@param notifType 'inform'|'error'|'success' Notification type
local function notifyPlayer(source, title, description, notifType)
    debugPrint(string.format('Sending notification to %d: [%s] %s - %s', source, notifType, title, description))
    TriggerClientEvent('drp-events:notify', source, {
        title = title,
        description = description,
        type = notifType
    })
end

--- Create event bubble
---@param source number Player source
---@param position vector3 Bubble center position
---@param radius number Bubble radius
---@param allowedJobs? table<number, string> List of allowed job names (optional, defaults to 'all')
RegisterServerEvent('events:createBubble')
AddEventHandler('events:createBubble', function(position, radius, allowedJobs)
    local source = source
    debugPrint(string.format('Received createBubble request from source %d', source))

    -- Validate permission
    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung Events zu erstellen', 'error')
        return
    end

    -- Validate inputs
    if type(position) ~= 'vector3' then
        debugPrint(string.format('Invalid position type: %s', type(position)))
        notifyPlayer(source, 'Event System', 'Ungültige Position', 'error')
        return
    end

    if type(radius) ~= 'number' or radius <= 0 then
        debugPrint(string.format('Invalid radius: %s (type: %s)', tostring(radius), type(radius)))
        notifyPlayer(source, 'Event System', 'Ungültiger Radius', 'error')
        return
    end

    -- Default to all players if no jobs specified
    if not allowedJobs or #allowedJobs == 0 then
        allowedJobs = {'all'}
    end

    -- Create bubble
    bubbleIdCounter += 1
    local bubble = {
        id = bubbleIdCounter,
        position = position,
        radius = radius,
        createdBy = source,
        createdAt = os.time(),
        allowedJobs = allowedJobs
    }

    activeBubbles[#activeBubbles + 1] = bubble
    debugPrint(string.format('Created bubble #%d at %s with radius %.1fm, jobs: %s (Total bubbles: %d)',
        bubble.id, tostring(position), radius, json.encode(allowedJobs), #activeBubbles))

    -- Broadcast to all clients
    TriggerClientEvent('eventbubble:createBubble', -1, bubble)
    debugPrint(string.format('Broadcasted bubble #%d to all clients', bubble.id))

    local jobRestriction = table.concat(allowedJobs, ', ')
    if allowedJobs[1] == 'all' then
        jobRestriction = 'All Players'
    end
    notifyPlayer(source, 'Event System', string.format('Event Bubble #%d erstellt (Radius: %.1fm, Access: %s)', bubble.id, radius, jobRestriction), 'success')
end)

--- Remove event bubble
---@param source number Player source
---@param bubbleId number Bubble ID to remove
RegisterServerEvent('events:removeBubble')
AddEventHandler('events:removeBubble', function(bubbleId)
    local source = source
    debugPrint(string.format('Received removeBubble request from source %d for bubble #%d', source, bubbleId))

    -- Validate permission
    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung Events zu entfernen', 'error')
        return
    end

    -- Validate input
    if type(bubbleId) ~= 'number' then
        debugPrint(string.format('Invalid bubbleId type: %s', type(bubbleId)))
        notifyPlayer(source, 'Event System', 'Ungültige Bubble ID', 'error')
        return
    end

    -- Find and remove bubble
    local removed = false
    for i = #activeBubbles, 1, -1 do
        if activeBubbles[i].id == bubbleId then
            table.remove(activeBubbles, i)
            removed = true
            debugPrint(string.format('Removed bubble #%d (Remaining bubbles: %d)', bubbleId, #activeBubbles))

            -- Broadcast removal to all clients
            TriggerClientEvent('eventbubble:removeBubble', -1, bubbleId)
            debugPrint(string.format('Broadcasted removal of bubble #%d to all clients', bubbleId))

            notifyPlayer(source, 'Event System', string.format('Event Bubble #%d entfernt', bubbleId), 'success')
            break
        end
    end

    if not removed then
        debugPrint(string.format('Bubble #%d not found in active bubbles', bubbleId))
        notifyPlayer(source, 'Event System', string.format('Event Bubble #%d nicht gefunden', bubbleId), 'error')
    end
end)

--- Set player dimension when entering/exiting bubble
---@param source number Player source
---@param dimension number Target dimension/routing bucket
---@param bubbleId? number Bubble ID (for job validation when entering)
RegisterServerEvent('eventbubble:setDim')
AddEventHandler('eventbubble:setDim', function(dimension, bubbleId)
    local source = source

    -- Validate input
    if type(dimension) ~= 'number' or dimension < 0 then
        debugPrint(string.format('Invalid dimension from source %d: %s', source, tostring(dimension)))
        return
    end

    -- If entering event dimension (not 0), validate job access
    if dimension ~= EventsConfig.DefaultDimension and bubbleId then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            debugPrint(string.format('Player %d not found for job validation', source))
            return
        end

        -- Find the bubble
        local bubble = nil
        for _, b in ipairs(activeBubbles) do
            if b.id == bubbleId then
                bubble = b
                break
            end
        end

        if not bubble then
            debugPrint(string.format('Bubble #%d not found for job validation', bubbleId))
            return
        end

        -- Check if player's job is allowed
        local playerJob = xPlayer.job.name
        local isAllowed = false

        -- Check if 'all' is in allowed jobs
        for _, job in ipairs(bubble.allowedJobs) do
            if job == 'all' then
                isAllowed = true
                break
            end
        end

        -- Check if player's job is in allowed jobs
        if not isAllowed then
            for _, job in ipairs(bubble.allowedJobs) do
                if job == playerJob then
                    isAllowed = true
                    break
                end
            end
        end

        if not isAllowed then
            debugPrint(string.format('Player %s (job: %s) denied access to bubble #%d (allowed: %s)',
                xPlayer.getName(), playerJob, bubbleId, json.encode(bubble.allowedJobs)))
            notifyPlayer(source, 'Event System', 'You are not allowed to enter this event (Job Restricted)', 'error')
            return
        end

        debugPrint(string.format('Player %s (job: %s) granted access to bubble #%d',
            xPlayer.getName(), playerJob, bubbleId))
    end

    -- Set player's routing bucket (dimension)
    SetPlayerRoutingBucket(source, dimension)
    debugPrint(string.format('Set player %d to dimension/bucket %d', source, dimension))

    -- Check if player is in a vehicle and set vehicle's routing bucket too
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        SetEntityRoutingBucket(vehicle, dimension)
        debugPrint(string.format('Set vehicle %d to dimension/bucket %d (player was in vehicle)', vehicle, dimension))
    end

    -- Send appropriate notification
    if dimension == EventsConfig.EventDimension then
        -- Entering event
        notifyPlayer(source, EventsConfig.NotificationTitle, EventsConfig.EnterMessage, 'inform')
    elseif dimension == EventsConfig.DefaultDimension then
        -- Exiting event
        notifyPlayer(source, EventsConfig.NotificationTitle, EventsConfig.ExitMessage, 'inform')
    end
end)

--- Command to create event bubble at player position (legacy)
---@param source number Player source
---@param args string[] Command arguments
RegisterCommand('createevent', function(source, args)
    debugPrint(string.format('Command /createevent executed by source %d', source))

    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung für diesen Befehl', 'error')
        return
    end

    -- If no args, trigger dialog on client
    if not args[1] then
        debugPrint(string.format('No radius provided, triggering ox_lib dialog for source %d', source))
        TriggerClientEvent('drp-events:openCreateDialog', source)
        return
    end

    local radius = tonumber(args[1]) or EventsConfig.DefaultEventRadius

    -- Validate radius
    if radius <= 0 or radius > 500 then
        notifyPlayer(source, 'Event System', 'Radius muss zwischen 1 und 500 sein', 'error')
        return
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    debugPrint(string.format('Creating event at coords %s with radius %.1f', tostring(coords), radius))

    TriggerEvent('events:createBubble', vector3(coords.x, coords.y, coords.z), radius)
end, false)

--- Command to remove event bubble by ID (legacy)
---@param source number Player source
---@param args string[] Command arguments
RegisterCommand('removeevent', function(source, args)
    debugPrint(string.format('Command /removeevent executed by source %d', source))

    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung für diesen Befehl', 'error')
        return
    end

    -- If no args, trigger dialog on client
    if not args[1] then
        debugPrint(string.format('No bubble ID provided, triggering ox_lib dialog for source %d', source))
        TriggerClientEvent('drp-events:openRemoveDialog', source, activeBubbles)
        return
    end

    local bubbleId = tonumber(args[1])
    if not bubbleId then
        notifyPlayer(source, 'Event System', 'Verwendung: /removeevent <bubble_id>', 'error')
        return
    end

    TriggerEvent('events:removeBubble', bubbleId)
end, false)

--- Command to list all active event bubbles
---@param source number Player source
RegisterCommand('listevents', function(source)
    debugPrint(string.format('Command /listevents executed by source %d', source))

    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung für diesen Befehl', 'error')
        return
    end

    if #activeBubbles == 0 then
        notifyPlayer(source, 'Event System', 'Keine aktiven Event Bubbles', 'inform')
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    print(string.format('^3[Event System] Aktive Bubbles für %s:^0', xPlayer.getName()))
    for _, bubble in ipairs(activeBubbles) do
        local creatorPlayer = ESX.GetPlayerFromId(bubble.createdBy)
        local creatorName = creatorPlayer and creatorPlayer.getName() or 'Unknown'
        print(string.format('  ^2ID: %d^0 | Radius: %.1fm | Erstellt von: %s | Position: %s',
            bubble.id,
            bubble.radius,
            creatorName,
            json.encode(bubble.position)
        ))
    end

    notifyPlayer(source, 'Event System', string.format('%d aktive Event Bubble(s) - siehe F8 Console', #activeBubbles), 'inform')
end, false)

--- Event sound system command
---@param source number Player source
---@param args string[] Command arguments
RegisterCommand('eventsound', function(source, args)
    debugPrint(string.format('Command /eventsound executed by source %d with args: %s', source, json.encode(args)))

    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung für diesen Befehl', 'error')
        return
    end

    local action = args[1]
    if action == 'play' then
        GlobalState.eventsound = true
        debugPrint('GlobalState.eventsound set to true')
        notifyPlayer(source, 'Event System', 'Event Sound gestartet', 'success')
    elseif action == 'stop' then
        GlobalState.eventsound = false
        debugPrint('GlobalState.eventsound set to false')
        notifyPlayer(source, 'Event System', 'Event Sound gestoppt', 'success')
    else
        notifyPlayer(source, 'Event System', 'Verwendung: /eventsound <play|stop>', 'error')
    end
end, false)

--- Cleanup on resource stop - reset all players to default dimension
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    debugPrint('Resource stopping - cleaning up')

    -- Reset all players to default dimension
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        SetPlayerRoutingBucket(tonumber(playerId), EventsConfig.DefaultDimension)
    end

    print(string.format('^3[Event System] Resource stopped - Reset %d player(s) to default dimension^0', #players))
end)

--- Send current bubbles to players when they join
---@param playerId number Player source
---@param xPlayer table ESX player object
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    debugPrint(string.format('Player loaded: %s (ID: %d)', xPlayer.getName(), playerId))

    -- Sync all active bubbles to joining player
    for _, bubble in ipairs(activeBubbles) do
        TriggerClientEvent('eventbubble:createBubble', playerId, bubble)
    end

    if #activeBubbles > 0 then
        print(string.format('^3[Event System] Synced %d bubble(s) to %s^0', #activeBubbles, xPlayer.getName()))
    end
end)

--- Debug command to check current dimension
---@param source number Player source
RegisterCommand('checkdim', function(source)
    if not hasEventPermission(source) then
        notifyPlayer(source, 'Event System', 'Du hast keine Berechtigung für diesen Befehl', 'error')
        return
    end

    local bucket = GetPlayerRoutingBucket(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    print(string.format('^3[Event System] %s ist in Dimension/Bucket: %d^0', xPlayer.getName(), bucket))
    notifyPlayer(source, 'Event System', string.format('Du bist in Dimension: %d', bucket), 'inform')
end, false)

--- Get all available jobs from ESX
---@param source number Player source
RegisterServerEvent('drp-events:getAvailableJobs')
AddEventHandler('drp-events:getAvailableJobs', function()
    local source = source
    debugPrint(string.format('Fetching available jobs for source %d', source))

    local jobs = {{value = 'all', label = 'All Players (Public Event)'}}

    if EventsConfig.AutoDetectJobs then
        -- Fetch all jobs from ESX
        local esxJobs = ESX.GetJobs()

        for jobName, jobData in pairs(esxJobs) do
            jobs[#jobs + 1] = {
                value = jobName,
                label = jobData.label or jobName
            }
        end

        debugPrint(string.format('Auto-detected %d jobs from ESX', #jobs - 1))
    end

    TriggerClientEvent('drp-events:receiveAvailableJobs', source, jobs)
end)

--- Resource startup message
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    print('^2======================================^0')
    print('^2[DRP-Events]^0 Resource started successfully')
    print('^3Debug Mode:^0 ' .. (EventsConfig.Debug and '^2Enabled^0' or '^1Disabled^0'))
    print('^3Auto-Detect Jobs:^0 ' .. (EventsConfig.AutoDetectJobs and '^2Enabled^0' or '^1Disabled^0'))
    print('^3Allowed Groups:^0 ' .. json.encode(EventsConfig.AllowedGroups))
    print('^3Default Radius:^0 ' .. EventsConfig.DefaultEventRadius .. 'm')
    print('^2======================================^0')

    debugPrint('All systems initialized')
end)
