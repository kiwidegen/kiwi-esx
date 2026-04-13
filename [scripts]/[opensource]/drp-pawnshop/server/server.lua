ESX = exports["es_extended"]:getSharedObject()

-- drp-logs helper
local function sendLog(title, source, fields, colorName)
    exports['drp-logs']:log('economy', {
        source = source,
        title = title,
        colorName = colorName or 'default',
        fields = fields
    })
end

RegisterServerEvent('frp-pawnshop:srv:sellitem')
AddEventHandler('frp-pawnshop:srv:sellitem', function(item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerName = GetPlayerName(_source) or 'Unknown'
    local itemData = Config.Items[item]

    if not itemData then
        -- Log invalid item attempt
        sendLog('Pawnshop • Invalid Item', _source, {
            { name = 'Item', value = tostring(item or 'Unknown'), inline = true },
            { name = 'Amount', value = tostring(count or 'Unknown'), inline = true },
            { name = 'Status', value = 'Invalid Item - Not Configured', inline = false }
        }, 'error')

        DropPlayer(_source, "Exploiting is forbidden")
        return
    end

    local playerItemCount = xPlayer.getInventoryItem(item).count
    local totalPrice = itemData.price * count

    if playerItemCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addInventoryItem('money', totalPrice)

        -- Log successful sale
        sendLog('Pawnshop • Item Sold', _source, {
            { name = 'Item', value = tostring(itemData.label), inline = true },
            { name = 'Amount', value = tostring(count), inline = true },
            { name = 'Price Per Item', value = '$' .. tostring(ESX.Math.GroupDigits(itemData.price)), inline = true },
            { name = 'Total Price', value = '$' .. tostring(ESX.Math.GroupDigits(totalPrice)), inline = true },
            { name = 'New Cash Balance', value = '$' .. tostring(ESX.Math.GroupDigits(xPlayer.getMoney())), inline = true },
            { name = 'Status', value = 'Successfully Sold', inline = false }
        }, 'success')

        TriggerClientEvent('esx:showNotification', _source, 'success', 'You sold ' .. count .. ' ' .. itemData.label .. ' for $' .. totalPrice)
    else
        -- Log exploit attempt
        sendLog('Pawnshop • Exploit Attempt', _source, {
            { name = 'Item', value = tostring(itemData.label), inline = true },
            { name = 'Requested Amount', value = tostring(count), inline = true },
            { name = 'Current Amount', value = tostring(playerItemCount), inline = true },
            { name = 'Shortage', value = tostring(count - playerItemCount), inline = true },
            { name = 'Status', value = 'BAN - Exploit Attempt', inline = false }
        }, 'error')

        DropPlayer(_source, "Exploiting is forbidden")
    end
end)

-- Log pawnshop access
RegisterServerEvent('frp-pawnshop:srv:access')
AddEventHandler('frp-pawnshop:srv:access', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerName = GetPlayerName(_source) or 'Unknown'

    sendLog('Pawnshop • Access', _source, {
        { name = 'Job', value = tostring(xPlayer.getJob().label or xPlayer.getJob().name), inline = true },
        { name = 'Cash Balance', value = '$' .. tostring(ESX.Math.GroupDigits(xPlayer.getMoney())), inline = true },
        { name = 'Bank Balance', value = '$' .. tostring(ESX.Math.GroupDigits(xPlayer.getAccount('bank').money)), inline = true },
        { name = 'Status', value = 'Pawnshop Access', inline = false }
    }, 'info')
end)