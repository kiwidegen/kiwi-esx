-- ╔══════════════════════════════╗
-- ║         Carry (Server)       ║
-- ╚══════════════════════════════╝
if not Config.Modules.Carry then return end

-- carrier → requests target to be carried
RegisterNetEvent('kd-basics:server:requestCarry', function(targetSrc)
    local src = source
    if not src or src <= 0 then return end
    if not targetSrc or targetSrc <= 0 then return end
    if targetSrc == src then return end

    TriggerClientEvent('kd-basics:client:carryConfirm', targetSrc, src)
end)

-- target accepted — notify both sides
RegisterNetEvent('kd-basics:server:acceptCarry', function(carrierSrc)
    local src = source
    if not src or src <= 0 then return end
    if not carrierSrc or carrierSrc <= 0 then return end

    TriggerClientEvent('kd-basics:client:getCarried', src, carrierSrc)
    TriggerClientEvent('kd-basics:client:beginCarrying', carrierSrc)
end)

-- target denied
RegisterNetEvent('kd-basics:server:denyCarry', function(carrierSrc)
    local src = source
    if not src or src <= 0 then return end
    if not carrierSrc or carrierSrc <= 0 then return end

    TriggerClientEvent('kd-basics:client:carryDenied', carrierSrc)
end)

-- stop carrying (called by either carrier putting down or target wiggling free)
RegisterNetEvent('kd-basics:server:stopCarrying', function(targetSrc)
    local src = source
    if not src or src <= 0 then return end
    if not targetSrc or targetSrc <= 0 then return end

    TriggerClientEvent('kd-basics:client:stopBeingCarried', targetSrc)
    TriggerClientEvent('kd-basics:client:stopCarrying', src)
end)
