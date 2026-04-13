--- UI open state
---@type boolean
local isUIOpen = false

--- Currently opening lootbox
---@type boolean
local isOpeningLootbox = false

--- Close NUI callback
RegisterNUICallback('drp-cases:NUIoff', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'off' })
    isUIOpen = false
    cb('ok')
end)

--- ESC key listener to close UI
CreateThread(function()
    while true do
        if isUIOpen then
            DisableControlAction(0, 322, true) -- ESC key
            Wait(0)
        else
            Wait(500)
        end
    end
end)

--- Triggered when player uses a lootbox item from ox_inventory
---@param itemData string|table Item data from inventory
RegisterNetEvent('demon_cases:useItemClient', function(itemData)
    -- Extract lootbox ID from item data
    local lootboxId = type(itemData) == 'table' and itemData.name or tostring(itemData)

    -- Prevent opening multiple lootboxes at once
    if isOpeningLootbox then
        lib.notify({
            title = 'Lootbox',
            description = 'Please wait until the current lootbox is finished opening!',
            type = 'error'
        })
        return
    end

    -- Prevent opening if UI is already open
    if isUIOpen then
        lib.notify({
            title = 'Lootbox',
            description = 'Lootbox UI is already open!',
            type = 'error'
        })
        return
    end

    -- Mark as opening
    isOpeningLootbox = true

    -- Request lootbox opening from server
    TriggerServerEvent('drp-cases:useLootbox', lootboxId)
end)

--- Open lootbox UI with reward data from server
---@param data table Lootbox data containing rewards and selected reward
RegisterNetEvent('drp-cases:openUI', function(data)
    if not isOpeningLootbox then return end

    -- Close inventory if needed
    if data.closeInventoryEvent and data.closeInventoryEvent ~= '' then
        TriggerEvent(data.closeInventoryEvent)
    end

    -- Ensure UI is closed before opening
    SendNUIMessage({ type = 'off' })
    Wait(100)

    -- Open UI with focus
    isUIOpen = true
    SetNuiFocus(true, true)

    -- Send lootbox data to UI
    SendNUIMessage({
        type = 'ui',
        data = data.rewards,
        img = data.imageSource,
        win = data.selectedReward
    })

    -- Wait for animation to complete (8.3 seconds)
    SetTimeout(8300, function()
        -- Confirm reward with server
        TriggerServerEvent('drp-cases:confirmReward', data.selectedReward)

        -- Force close UI after animation
        SetTimeout(500, function()
            SetNuiFocus(false, false)
            SendNUIMessage({ type = 'off' })
            isUIOpen = false
            isOpeningLootbox = false
        end)
    end)
end)

--- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if isUIOpen then
        SetNuiFocus(false, false)
        SendNUIMessage({ type = 'off' })
    end
end)
