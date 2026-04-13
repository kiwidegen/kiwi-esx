-- Jungle Juice Item Export for ox_inventory

exports('junglejuice', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local src = inventory.id

        if exports.ox_inventory:RemoveItem(src, 'junglejuice', 1, nil, slot) then
            TriggerClientEvent('hud:client:consumeJungleJuice', src, 50)
        end
    end
end)
