-- ╔══════════════════════════════╗
-- ║    Take Hostage (Server)     ║
-- ╚══════════════════════════════╝
if not Config.Modules.TakeHostage then return end

local takingHostage = {}
local takenHostage  = {}

RegisterNetEvent('kd-basics:takehostage:sync', function(targetSrc)
    local src = source
    if not src or src <= 0 then return end
    if not targetSrc or targetSrc <= 0 or targetSrc == src then return end
    if GetPlayerPed(targetSrc) == 0 then return end

    local srcCoords    = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
    if #(srcCoords - targetCoords) > 3.0 then return end

    takingHostage[src]      = targetSrc
    takenHostage[targetSrc] = src
    TriggerClientEvent('kd-basics:takehostage:syncTarget', targetSrc, src)
end)

RegisterNetEvent('kd-basics:takehostage:release', function(targetSrc)
    local src = source
    if takingHostage[src] ~= targetSrc or takenHostage[targetSrc] ~= src then return end

    TriggerClientEvent('kd-basics:takehostage:release', targetSrc)
    TriggerClientEvent('kd-basics:takehostage:stop', src)
    takingHostage[src]      = nil
    takenHostage[targetSrc] = nil
end)

RegisterNetEvent('kd-basics:takehostage:kill', function(targetSrc)
    local src = source
    if takingHostage[src] ~= targetSrc or takenHostage[targetSrc] ~= src then return end

    TriggerClientEvent('kd-basics:takehostage:kill', targetSrc)
    TriggerClientEvent('kd-basics:takehostage:stop', src)
    takingHostage[src]      = nil
    takenHostage[targetSrc] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    if takingHostage[src] then
        TriggerClientEvent('kd-basics:takehostage:stop', takingHostage[src])
        takenHostage[takingHostage[src]] = nil
        takingHostage[src] = nil
    end
    if takenHostage[src] then
        TriggerClientEvent('kd-basics:takehostage:stop', takenHostage[src])
        takingHostage[takenHostage[src]] = nil
        takenHostage[src] = nil
    end
end)
