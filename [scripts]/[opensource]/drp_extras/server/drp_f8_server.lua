---@diagnostic disable: undefined-global

local function getPlayerPosition(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    return { x = coords.x, y = coords.y, z = coords.z }
end

AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src)
    local pos = getPlayerPosition(src)
    local date = os.date('%H:%M:%S')
    local info = {
        name = name,
        srco = src,
        date = date,
        res = reason,
        pos = pos
    }
    TriggerClientEvent('drp_f8:playerDisconnect', -1, info)
end)

-- Rate limiting for hospital events
local lastHospitalEvent = {}

RegisterNetEvent('drp_f8:sendHospital', function(data)
    local source = source
    local currentTime = os.time()

    -- SECURITY: Rate limit to prevent spam (1 event per 5 seconds per player)
    if lastHospitalEvent[source] and (currentTime - lastHospitalEvent[source]) < 5 then
        return
    end

    lastHospitalEvent[source] = currentTime

    -- SECURITY: Validate data structure
    if type(data) ~= 'table' or not data.pos then
        return
    end

    -- Force source to be the actual triggering player
    data.srco = source

    TriggerClientEvent('drp_f8:hospitalEvent', -1, data)
end)
