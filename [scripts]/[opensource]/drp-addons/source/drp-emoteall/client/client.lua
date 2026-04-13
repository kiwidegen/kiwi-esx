---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()
local cache = cache or {}

--- Command to make all nearby players perform an emote
RegisterCommand("emoteall", function(src, args)
    local radius = tonumber(args[1])
    if not radius then
        lib.notify({
            title = 'Emote All',
            description = 'Syntax error: /emoteall radius emote',
            type = 'error'
        })
        return
    end
    radius = math.min(60, radius) -- Max 60m radius

    local emote = args[2]
    if not emote then
        lib.notify({
            title = 'Emote All',
            description = 'Syntax error: /emoteall radius emote',
            type = 'error'
        })
        return
    end

    local Players = ESX.Game.GetPlayersInArea(GetEntityCoords(cache.ped), radius)

    local ServerIds = {}
    for i, targetPlayerId in ipairs(Players) do
        if not IsPedDeadOrDying(GetPlayerPed(targetPlayerId), true) then
            ServerIds[#ServerIds + 1] = GetPlayerServerId(targetPlayerId)
        end
    end

    if #ServerIds == 0 then
        lib.notify({
            title = 'Emote All',
            description = ('No players found in radius (%dm).'):format(radius),
            type = 'inform'
        })
        return
    end

    TriggerServerEvent("drp_emoteall:trigger", ServerIds, emote)
    lib.notify({
        title = 'Emote All',
        description = ('Emote triggered for %d players in %dm radius.'):format(#ServerIds, radius),
        type = 'success'
    })
end)

--- Receive emote command from server
RegisterNetEvent("drp_emoteall:execute", function(emote)
    ExecuteCommand(("e %s"):format(emote))
end)
