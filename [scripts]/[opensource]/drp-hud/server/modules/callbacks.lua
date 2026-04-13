-- Server callbacks

ESX = exports['es_extended']:getSharedObject()

-- Example: Get player data callback
lib.callback.register('drp-hud:getPlayerData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    
    return {
        name = xPlayer.getName(),
        job = xPlayer.job.name,
        grade = xPlayer.job.grade,
        money = xPlayer.getMoney(),
        bank = xPlayer.getAccount('bank').money
    }
end)

-- Example: Check if player can do action
lib.callback.register('drp-hud:canDoAction', function(source, action)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    -- Add your logic here
    return true
end)