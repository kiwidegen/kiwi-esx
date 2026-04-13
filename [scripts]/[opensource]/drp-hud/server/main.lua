-- Server main file

ESX = exports['es_extended']:getSharedObject()

-- Admin check callback
lib.callback.register('drp-hud:isAdmin', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local group = xPlayer.getGroup()
    return group == 'admin' or group == 'superadmin' or group == 'mod'
end)

-- Give cash to nearby player
RegisterNetEvent('hud:server:give_cash', function(targetId, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not xTarget then return end
    
    amount = tonumber(amount)
    if amount <= 0 then return end
    
    local playerMoney = xPlayer.getMoney()
    
    if playerMoney >= amount then
        xPlayer.removeMoney(amount)
        xTarget.addMoney(amount)
        
        TriggerClientEvent('esx:showNotification', src, 'You gave $' .. amount)
        TriggerClientEvent('esx:showNotification', targetId, 'You received $' .. amount)
    else
        TriggerClientEvent('esx:showNotification', src, 'Not enough cash')
    end
end)

-- Money change notifications
AddEventHandler('esx:onAddMoney', function(source, account, amount)
    -- Optional: Trigger money change animations
end)

AddEventHandler('esx:onRemoveMoney', function(source, account, amount)
    -- Optional: Trigger money change animations
end)

print('^2[drp-hud]^0 Server initialized')