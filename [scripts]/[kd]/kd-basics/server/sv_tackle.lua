-- ╔══════════════════════════════╗
-- ║       Tackle (Server)        ║
-- ╚══════════════════════════════╝
if not Config.Modules.Tackle then return end

RegisterNetEvent('kd-basics:tackle:tacklePlayer', function(targetSrc)
    local src = source
    if not src or src <= 0 then return end
    if not targetSrc or GetPlayerPed(targetSrc) == 0 then return end

    local srcCoords    = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
    if #(srcCoords - targetCoords) > 5.0 then return end

    TriggerClientEvent('kd-basics:tackle:getTackled', targetSrc)
end)
