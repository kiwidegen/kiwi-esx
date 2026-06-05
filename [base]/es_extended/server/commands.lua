-- /maxmod — max all mods on your current vehicle except tyres (admin only)
RegisterCommand('maxmod', function(playerId, args)
    if playerId == 0 then return end
    if not Core.IsPlayerAdmin(playerId) then return end
    TriggerClientEvent('esx:maxmodVehicle', playerId)
end, false)

-- /fixradius [radius] — repair all vehicles within radius (admin only)
RegisterCommand('fixradius', function(playerId, args)
    if playerId == 0 then return end
    if not Core.IsPlayerAdmin(playerId) then return end
    local radius = tonumber(args[1]) or 50
    TriggerClientEvent('esx:fixVehiclesRadius', playerId, radius)
end, false)

-- /fix — repair your current vehicle (admin only)
RegisterCommand('fix', function(playerId, args)
    if playerId == 0 then return end
    if not Core.IsPlayerAdmin(playerId) then return end
    TriggerClientEvent('esx:fixVehicle', playerId)
end, false)

-- /car [model] — spawn vehicle at your position (admin only)
RegisterCommand('car', function(playerId, args)
    if playerId == 0 then return end
    if not Core.IsPlayerAdmin(playerId) then return end

    local model = args[1]
    if not model then
        TriggerClientEvent('chat:addMessage', playerId, { args = { '[ESX]', 'Usage: /car [model]' } })
        return
    end

    TriggerClientEvent('esx:spawnCar', playerId, model)
end, false)

-- /dv — delete the vehicle you're in or the closest one (admin only)
RegisterCommand('dv', function(playerId, args)
    if playerId == 0 then return end
    if not Core.IsPlayerAdmin(playerId) then return end
    TriggerClientEvent('esx:deleteVehicle', playerId)
end, false)

-- /setjob [id] [job] [grade] — set a player's job (admin + console)
RegisterCommand('setjob', function(playerId, args)
    if not Core.IsPlayerAdmin(playerId) and playerId ~= 0 then return end

    local targetId = (args[1] == 'me') and playerId or tonumber(args[1])
    local job      = args[2]
    local grade    = args[3] or '0'

    local function reply(msg)
        if playerId == 0 then
            print(msg)
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { '[ESX]', msg } })
        end
    end

    if not targetId or not job then
        return reply('Usage: /setjob [id] [job] [grade]')
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        return reply(('Player %s not found'):format(targetId))
    end

    if not ESX.DoesJobExist(job, grade) then
        return reply(('Invalid job "%s" grade "%s"'):format(job, grade))
    end

    xTarget.setJob(job, grade)
    reply(('Set %s job to %s grade %s'):format(xTarget.getName(), job, grade))
end, false)

-- /giveitem [id] [item] [amount] — give an ox_inventory item to a player (admin + console)
RegisterCommand('giveitem', function(playerId, args)
    if not Core.IsPlayerAdmin(playerId) and playerId ~= 0 then return end

    local targetId = (args[1] == 'me') and playerId or tonumber(args[1])
    local item     = args[2]
    local amount   = tonumber(args[3]) or 1

    local function reply(msg)
        if playerId == 0 then
            print(msg)
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { '[ESX]', msg } })
        end
    end

    if not targetId or not item then
        return reply('Usage: /giveitem [id] [item] [amount]')
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        return reply(('Player %s not found'):format(targetId))
    end

    local success = exports.ox_inventory:AddItem(targetId, item, amount)
    if success then
        reply(('Gave %s x%s to %s'):format(item, amount, xTarget.getName()))
    else
        reply(('Failed — "%s" may not be a valid item'):format(item))
    end
end, false)
