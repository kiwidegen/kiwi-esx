-- Minimal shared utilities — only what the core actually uses.

ESX.Math = {}

function ESX.Math.Round(value, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10 ^ numDecimalPlaces
        return math.floor((value * power) + 0.5) / power
    end
    return math.floor(value + 0.5)
end

ESX.Round = ESX.Math.Round

ESX.Table = {}

function ESX.Table.SizeOf(t)
    local n = 0
    for _ in pairs(t) do n += 1 end
    return n
end

function ESX.Table.ToArray(t)
    local arr = {}
    for _, v in pairs(t) do arr[#arr + 1] = v end
    return arr
end

function ESX.IsFunctionReference(val)
    local t = type(val)
    return t == 'function' or (t == 'table' and type(getmetatable(val)?.__call) == 'function')
end

-- Returns the full Config table or a specific key.
-- Called by ox_inventory, ox_doorlock, and other ox resources.
function ESX.GetConfig(key)
    if key then return Config[key] end
    return Config
end

-- Legacy shared-object event — works on both client and server.
AddEventHandler('esx:getSharedObject', function(cb)
    if ESX.IsFunctionReference(cb) then cb(ESX) end
end)
