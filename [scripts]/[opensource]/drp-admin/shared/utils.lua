---@class Utils
Utils = {}

--- Get player coordinates
---@param playerId number Player server ID
---@return vector3 coords Player coordinates
function Utils.GetPlayerCoords(playerId)
    local ped = GetPlayerPed(playerId)
    return GetEntityCoords(ped)
end

--- Calculate distance between two coordinates (modern method)
---@param coords1 vector3 First coordinate
---@param coords2 vector3 Second coordinate
---@return number distance Distance in units
function Utils.GetDistance(coords1, coords2)
    return #(coords1 - coords2)
end

--- Debug print function (only prints if debug is enabled)
---@param message string Message to print
function Utils.Debug(message)
    if AdminConfig.DEBUG then
        print('[DRP-ADMIN] ' .. message)
    end
end

--- Format notification message with variables
---@param message string Message template
---@param ... any Variables to format into message
---@return string formatted Formatted message
function Utils.FormatMessage(message, ...)
    return message:format(...)
end