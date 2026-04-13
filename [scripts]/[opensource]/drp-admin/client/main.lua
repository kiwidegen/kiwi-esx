---@type table ox_inventory exports
local ox_inventory = exports.ox_inventory

--- Cache for player data
---@class PlayerCache
---@field playerId number Player ID
---@field serverId number Server ID
---@field ped number Player ped entity
local cache = {
    playerId = PlayerId(),
    serverId = GetPlayerServerId(PlayerId()),
    ped = PlayerPedId()
}

--- Item options cache for spawn menu
---@type table[]|nil
ItemOptions = nil

--- Job options cache for teleport menu
---@type table[]|nil
JobOptions = nil

--- Update player ped cache when it changes
AddEventHandler('esx:playerPedChanged', function(newPed)
    cache.ped = newPed
end)

--- Resource start handler
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    cache.ped = PlayerPedId()
    cache.playerId = PlayerId()
    cache.serverId = GetPlayerServerId(PlayerId())
end)
