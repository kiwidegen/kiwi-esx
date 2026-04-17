-- ╔══════════════════════════════╗
-- ║           F8 Server          ║
-- ╚══════════════════════════════╝
if not Config.Modules.F8 then return end

local lastHospitalEvent = {}

AddEventHandler('playerDropped', function(reason)
    local src    = source
    local ped    = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    TriggerClientEvent('kd-basics:f8:playerDisconnect', -1, {
        name = GetPlayerName(src),
        srco = src,
        date = os.date('%H:%M:%S'),
        res  = reason,
        pos  = { x = coords.x, y = coords.y, z = coords.z },
    })
end)

-- ─── Admin test command ───────────────────────────────────────────────────────
-- add_ace group.admin command.testf8 allow  (in server.cfg)

RegisterCommand('testf8', function(src)
    local ped    = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    TriggerClientEvent('kd-basics:f8:playerDisconnect', src, {
        name = GetPlayerName(src),
        srco = src,
        date = os.date('%H:%M:%S'),
        res  = 'TEST disconnect marker',
        pos  = { x = coords.x, y = coords.y, z = coords.z },
    })
end, true)  -- true = restricted; requires command.testf8 ACE

RegisterNetEvent('kd-basics:f8:sendHospital', function(data)
    local src = source
    local now = os.time()

    if lastHospitalEvent[src] and (now - lastHospitalEvent[src]) < 5 then return end
    lastHospitalEvent[src] = now

    if type(data) ~= 'table' or not data.pos then return end

    data.srco = src
    TriggerClientEvent('kd-basics:f8:hospitalEvent', -1, data)
end)
