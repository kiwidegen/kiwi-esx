---@class EventBubble
---@field id number Unique bubble identifier
---@field position vector3 Bubble center coordinates
---@field radius number Bubble radius in units

--- Active event bubbles in the world
---@type EventBubble[]
local activeBubbles = {}

--- Tracks which bubbles the player is currently inside
---@type table<number, boolean>
local inBubble = {}

--- Maps bubble IDs to their blip handles
---@type table<string|number, number>
local bubbleBlips = {}

--- Cached available jobs list
---@type table<number, {value: string, label: string}>|nil
local availableJobs = nil

--- Debug print helper
---@param message string Debug message
local function debugPrint(message)
    if EventsConfig.Debug then
        print(string.format('^3[DRP-Events DEBUG CLIENT]^0 %s', message))
    end
end

--- Receive available jobs from server
---@param jobs table<number, {value: string, label: string}> List of available jobs
RegisterNetEvent('drp-events:receiveAvailableJobs', function(jobs)
    availableJobs = jobs
    debugPrint(string.format('Received %d available jobs from server', #jobs))
end)

--- Handles notifications sent from server
---@param data table Notification data
RegisterNetEvent('drp-events:notify', function(data)
    debugPrint(string.format('Received notification: [%s] %s - %s', data.type, data.title, data.description))
    lib.notify(data)
end)

--- Opens ox_lib dialog for creating event
RegisterNetEvent('drp-events:openCreateDialog', function()
    debugPrint('Opening create event dialog')

    -- Request jobs from server if not cached
    if not availableJobs then
        debugPrint('Jobs not cached, requesting from server')
        TriggerServerEvent('drp-events:getAvailableJobs')

        -- Wait for jobs to be received (max 3 seconds)
        local timeout = 0
        while not availableJobs and timeout < 30 do
            Wait(100)
            timeout += 1
        end

        if not availableJobs then
            debugPrint('Failed to receive jobs from server, using fallback')
            lib.notify({
                title = 'Event System',
                description = 'Failed to load jobs list',
                type = 'error'
            })
            return
        end
    end

    local input = lib.inputDialog('Create Event Bubble', {
        {
            type = 'number',
            label = 'Radius (meters)',
            description = 'Size of the event bubble',
            required = true,
            min = 1,
            max = 500,
            default = EventsConfig.DefaultEventRadius
        },
        {
            type = 'multi-select',
            label = 'Allowed Jobs/Gangs',
            description = 'Select which jobs can enter (Select "All Players" for public event)',
            required = true,
            options = availableJobs,
            default = {'all'}
        },
        {
            type = 'checkbox',
            label = 'Use current position',
            description = 'Create bubble at your location',
            checked = true,
            disabled = true
        }
    })

    if not input then
        debugPrint('Create dialog cancelled by user')
        return
    end

    local radius = input[1]
    local allowedJobs = input[2]

    debugPrint(string.format('User entered radius: %.1f, jobs: %s', radius, json.encode(allowedJobs)))

    -- If 'all' is selected, only use 'all'
    if allowedJobs then
        for _, job in ipairs(allowedJobs) do
            if job == 'all' then
                allowedJobs = {'all'}
                break
            end
        end
    else
        allowedJobs = {'all'}
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    debugPrint(string.format('Creating bubble at coords: %s with jobs: %s', tostring(coords), json.encode(allowedJobs)))

    TriggerServerEvent('events:createBubble', vector3(coords.x, coords.y, coords.z), radius, allowedJobs)
end)

--- Opens ox_lib dialog for removing event
---@param bubbles EventBubble[] Active bubbles list
RegisterNetEvent('drp-events:openRemoveDialog', function(bubbles)
    debugPrint(string.format('Opening remove event dialog with %d bubbles', #bubbles))

    if #bubbles == 0 then
        lib.notify({
            title = 'Event System',
            description = 'No active event bubbles to remove',
            type = 'error'
        })
        return
    end

    -- Build options for selection
    local options = {}
    for _, bubble in ipairs(bubbles) do
        options[#options + 1] = {
            value = bubble.id,
            label = string.format('Bubble #%d (Radius: %.1fm)', bubble.id, bubble.radius)
        }
    end

    local input = lib.inputDialog('Remove Event Bubble', {
        {
            type = 'select',
            label = 'Select Bubble',
            description = 'Choose which bubble to remove',
            required = true,
            options = options
        }
    })

    if not input then
        debugPrint('Remove dialog cancelled by user')
        return
    end

    local bubbleId = input[1]
    debugPrint(string.format('User selected bubble #%d for removal', bubbleId))

    TriggerServerEvent('events:removeBubble', bubbleId)
end)

--- Creates a new event bubble with blips
---@param bubble EventBubble The bubble data to create
RegisterNetEvent('eventbubble:createBubble', function(bubble)
    debugPrint(string.format('Creating bubble #%d at %s with radius %.1f', bubble.id, tostring(bubble.position), bubble.radius))

    activeBubbles[#activeBubbles + 1] = bubble

    -- Create outer blip
    local outerBlip = AddBlipForCoord(bubble.position.x, bubble.position.y, bubble.position.z)
    SetBlipSprite(outerBlip, EventsConfig.OuterBlipSprite)
    SetBlipColour(outerBlip, EventsConfig.OuterBlipColor)
    SetBlipScale(outerBlip, EventsConfig.OuterBlipScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(EventsConfig.OuterBlipLabel)
    EndTextCommandSetBlipName(outerBlip)
    bubbleBlips[bubble.id] = outerBlip
    debugPrint(string.format('Created outer blip for bubble #%d', bubble.id))

    -- Create inner blip
    local innerBlip = AddBlipForCoord(bubble.position.x, bubble.position.y, bubble.position.z)
    SetBlipSprite(innerBlip, EventsConfig.InnerBlipSprite)
    SetBlipColour(innerBlip, EventsConfig.InnerBlipColor)
    SetBlipScale(innerBlip, EventsConfig.InnerBlipScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(EventsConfig.InnerBlipLabel)
    EndTextCommandSetBlipName(innerBlip)
    bubbleBlips["center_" .. bubble.id] = innerBlip
    debugPrint(string.format('Created inner blip for bubble #%d', bubble.id))

    debugPrint(string.format('Bubble #%d fully created (Total active: %d)', bubble.id, #activeBubbles))
end)

--- Removes an event bubble and its blips
---@param bubbleId number The bubble ID to remove
RegisterNetEvent('eventbubble:removeBubble', function(bubbleId)
    debugPrint(string.format('Removing bubble #%d', bubbleId))

    for index, bubble in ipairs(activeBubbles) do
        if bubble.id == bubbleId then
            activeBubbles[index] = nil

            if bubbleBlips[bubbleId] then
                RemoveBlip(bubbleBlips[bubbleId])
                bubbleBlips[bubbleId] = nil
                debugPrint(string.format('Removed outer blip for bubble #%d', bubbleId))
            end

            if bubbleBlips["center_" .. bubbleId] then
                RemoveBlip(bubbleBlips["center_" .. bubbleId])
                bubbleBlips["center_" .. bubbleId] = nil
                debugPrint(string.format('Removed inner blip for bubble #%d', bubbleId))
            end

            debugPrint(string.format('Bubble #%d fully removed', bubbleId))
            break
        end
    end
end)

--- Handles player entering an event bubble
---@param bubbleId number The bubble ID being entered
RegisterNetEvent('eventbubble:enterBubble', function(bubbleId)
    debugPrint(string.format('Entering event bubble #%d - switching to dimension %d', bubbleId, EventsConfig.EventDimension))
    TriggerServerEvent('eventbubble:setDim', EventsConfig.EventDimension, bubbleId)
end)

--- Handles player exiting an event bubble
RegisterNetEvent('eventbubble:exitBubble', function()
    debugPrint(string.format('Exiting event bubble - switching to dimension %d', EventsConfig.DefaultDimension))
    TriggerServerEvent('eventbubble:setDim', EventsConfig.DefaultDimension)
end)

--- Main proximity detection thread
--- Monitors player distance to event bubbles and triggers entry/exit events
CreateThread(function()
    debugPrint('Starting proximity detection thread')

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = EventsConfig.IdleSleep

        for _, bubble in ipairs(activeBubbles) do
            if bubble then -- Safety check for nil entries
                local distance = #(playerCoords - bubble.position)

                if distance <= bubble.radius * 2.0 + 10 then
                    sleep = EventsConfig.ActiveSleep
                    if distance <= bubble.radius * 2.0 then
                        if not inBubble[bubble.id] then
                            inBubble[bubble.id] = true
                            debugPrint(string.format('Player entered bubble #%d', bubble.id))

                            -- Let server handle notification after validation
                            TriggerEvent('eventbubble:enterBubble', bubble.id)
                        end
                    elseif inBubble[bubble.id] then
                        inBubble[bubble.id] = nil
                        debugPrint(string.format('Player exited bubble #%d', bubble.id))

                        -- Let server handle notification
                        TriggerEvent('eventbubble:exitBubble')
                    end
                else
                    sleep = EventsConfig.IdleSleep
                end
            end
        end

        Wait(sleep)
    end
end)

--- Marker rendering thread
--- Draws visual markers for event bubbles when player is nearby
CreateThread(function()
    debugPrint('Starting marker rendering thread')

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleepTime = EventsConfig.IdleSleep

        for _, bubble in ipairs(activeBubbles) do
            if bubble then -- Safety check for nil entries
                local distance = #(playerCoords - bubble.position)

                -- Only draw marker when OUTSIDE the bubble but within draw distance
                -- This prevents the marker from being invisible when you're inside looking out
                if distance > bubble.radius and distance <= bubble.radius + EventsConfig.DrawDistance then
                    DrawMarker(
                        EventsConfig.MarkerType,
                        bubble.position.x,
                        bubble.position.y,
                        bubble.position.z,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        bubble.radius * 2.0,
                        bubble.radius * 2.0,
                        bubble.radius * 2.0,
                        EventsConfig.BubbleColor.r,
                        EventsConfig.BubbleColor.g,
                        EventsConfig.BubbleColor.b,
                        EventsConfig.BubbleColor.a,
                        false,
                        true,
                        2,
                        false,
                        nil,
                        nil,
                        false
                    )
                    sleepTime = EventsConfig.ActiveSleep
                end
            end
        end

        Wait(sleepTime)
    end
end)

--- Cleanup handler on resource stop
---@param resourceName string The resource being stopped
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        debugPrint('Resource stopping - cleaning up')

        if inBubble then
            TriggerEvent("eventbubble:exitBubble")
        end
        activeBubbles = {}
        bubbleBlips = {}
        inBubble = {}

        debugPrint('Cleanup complete')
    end
end)

--- Plays event sound using xsound at configured location
---@return nil
local function playEventSound()
    debugPrint('Playing event sound')

    exports.xsound:PlayUrlPos(
        "eventsound",
        GetConvar("eventsound_url", "https://youtu.be/9EkZrMNZw4k"),
        GetConvarFloat("eventsound_volume", 0.4),
        vector3(
            GetConvarFloat("eventsound_coords_x", -2074.5996),
            GetConvarFloat("eventsound_coords_y", 3077.2302),
            GetConvarFloat("eventsound_coords_z", 32.8103)
        ),
        true
    )
    exports.xsound:Distance("eventsound", GetConvarFloat("eventsound_distance", 800.0))

    debugPrint(string.format('Event sound started - Volume: %.2f, Distance: %.1f',
        GetConvarFloat("eventsound_volume", 0.4),
        GetConvarFloat("eventsound_distance", 800.0)
    ))
end

--- State bag handler for event sound control
---@param bagName string State bag name
---@param key string State key
---@param value any State value
AddStateBagChangeHandler("eventsound", nil, function(bagName, key, value)
    if bagName ~= "global" then return end

    debugPrint(string.format('GlobalState.eventsound changed to: %s', tostring(value)))

    if not value then
        exports.xsound:Destroy("eventsound")
        debugPrint('Event sound stopped')
        return
    end

    playEventSound()
end)

--- Initialize event sound when ESX is loaded
CreateThread(function()
    debugPrint('Waiting for ESX to load...')

    while not ESX?.IsPlayerLoaded() do
        Wait(100)
    end

    debugPrint('ESX loaded - Checking for active event sound')

    if GlobalState.eventsound then
        debugPrint('Event sound is active - starting playback')
        playEventSound()
    else
        debugPrint('No event sound active')
    end
end)

--- Resource startup message
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    debugPrint('Client-side initialized')
    debugPrint(string.format('Config loaded - Debug: %s', tostring(EventsConfig.Debug)))
end)
