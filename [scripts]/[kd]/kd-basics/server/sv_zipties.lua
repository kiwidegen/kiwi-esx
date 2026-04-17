-- ╔══════════════════════════════╗
-- ║      Zipties (Server)        ║
-- ╚══════════════════════════════╝
if not Config.Modules.Zipties then return end

lib.callback.register('kd-basics:zipties:checkZipTied', function(source, targetSrc)
    local target = Player(targetSrc)
    return target and target.state.ziptied or false
end)

RegisterNetEvent('kd-basics:zipties:apply', function(targetSrc)
    local src = source
    if not src or src <= 0 then return end
    if not targetSrc or GetPlayerPed(targetSrc) == 0 then return end

    local srcCoords    = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
    if #(srcCoords - targetCoords) > 3.0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Zipties', description = 'Target is too far away.', type = 'error' })
        return
    end

    if Player(targetSrc).state.ziptied then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Zipties', description = 'Target is already restrained.', type = 'error' })
        return
    end

    local count = exports.ox_inventory:GetItem(src, 'ziptie', nil, true)
    if not count or count < 1 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Zipties', description = 'You have no zipties.', type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, 'ziptie', 1)
    Player(targetSrc).state:set('ziptied', true, true)
    TriggerClientEvent('kd-basics:zipties:apply', targetSrc)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Zipties', description = 'Target restrained.', type = 'success' })
end)

RegisterNetEvent('kd-basics:zipties:remove', function(targetSrc)
    local src = source
    if not src or src <= 0 then return end
    if not targetSrc or GetPlayerPed(targetSrc) == 0 then return end

    if not Player(targetSrc).state.ziptied then return end

    if src ~= targetSrc then
        local srcCoords    = GetEntityCoords(GetPlayerPed(src))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
        if #(srcCoords - targetCoords) > 3.0 then
            TriggerClientEvent('ox_lib:notify', src, { title = 'Zipties', description = 'Target is too far away.', type = 'error' })
            return
        end
    end

    Player(targetSrc).state:set('ziptied', false, true)
    TriggerClientEvent('kd-basics:zipties:remove', targetSrc)
    if src ~= targetSrc then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Zipties', description = 'Zipties removed.', type = 'success' })
    end
end)
