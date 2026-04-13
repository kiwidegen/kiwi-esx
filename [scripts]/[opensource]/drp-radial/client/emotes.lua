-- client/emotes.lua
local ox_lib = exports.ox_lib
local activeEmotes = {}

--- Handles emote execution and toggling
---@param emoteId string The emote identifier
local function handleEmote(emoteId)
    if not activeEmotes[emoteId] then
        activeEmotes[emoteId] = true
        ExecuteCommand("e " .. emoteId)
    else
        activeEmotes[emoteId] = false
        ExecuteCommand("e c")
    end
end

CreateThread(function()
    while not ox_lib or not ox_lib.registerRadial do
        Wait(100)
    end

    -- Build emote menu items from config
    local emoteItems = {}
    for _, emote in ipairs(RadialConfig.EmoteMenuItems) do
        table.insert(emoteItems, {
            label = emote.title,
            icon = emote.icon or 'face-smile',
            onSelect = function()
                handleEmote(emote.id)
            end
        })
    end

    -- Register emote radial menu
    ox_lib:registerRadial({
        id = 'emote_menu',
        items = emoteItems
    })

    -- Add emote menu to main radial
    ox_lib:addRadialItem({
        id = 'emotes',
        label = "Emotes",
        icon = 'face-laugh',
        menu = 'emote_menu'
    })
end)
