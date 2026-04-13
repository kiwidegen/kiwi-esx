ESX = exports['es_extended']:getSharedObject()

---@class RecycleItem
---@field name string Item name
---@field label string Item display label
---@field amount number Item quantity
---@field price number Unit price

--- Get player instance with validation
---@param source number Player source ID
---@return table|nil xPlayer ESX player object or nil
local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

--- Add item to player inventory using ox_inventory with validation
---@param source number Player source ID
---@param item string Item name
---@param count number Item count
---@return boolean success Whether item was added
local function addInventoryItem(source, item, count)
    -- Check if player can carry the item
    if not exports.ox_inventory:CanCarryItem(source, item, count) then
        print(string.format('[drp-recycle] Cannot add %s x%d to player %d - inventory full', item, count, source))
        lib.notify(source, {
            title = 'Recycle Job',
            description = 'Your inventory is full! Cannot receive items.',
            type = 'error',
            duration = 5000
        })
        return false
    end

    local success = exports.ox_inventory:AddItem(source, item, count)
    if success then
        print(string.format('[drp-recycle] Added %s x%d to player %d', item, count, source))
    else
        print(string.format('[drp-recycle] FAILED to add %s x%d to player %d', item, count, source))
        lib.notify(source, {
            title = 'Recycle Job',
            description = 'Failed to receive items. Please try again.',
            type = 'error',
            duration = 5000
        })
    end
    return success
end

--- Generate random items for package processing
---@param source number Player source ID
---@return boolean success Whether items were added
local function givePackageItems(source)
    local xPlayer = getPlayer(source)
    if not xPlayer then
        print('[drp-recycle] ERROR: Player not found for source: ' .. tostring(source))
        lib.notify(source, {
            title = 'Recycle Job',
            description = 'An error occurred. Please try again.',
            type = 'error'
        })
        return false
    end

    local itemsReceived = {}
    local totalItems = 0

    -- Guarantee at least one base item
    local randItem = RecycleConfig.ItemTable[math.random(1, #RecycleConfig.ItemTable)]
    local baseAmount = math.random(RecycleConfig.MinItemReceivedQty, RecycleConfig.MaxItemReceivedQty)

    print(string.format('[drp-recycle] Base item: %s x%d', randItem, baseAmount))
    if addInventoryItem(source, randItem, baseAmount) then
        itemsReceived[randItem] = (itemsReceived[randItem] or 0) + baseAmount
        totalItems += 1
    end

    -- Chance for additional items (0-2 more)
    local extraItems = math.random(0, RecycleConfig.MaxItemsReceived - 1)
    for i = 1, extraItems do
        Wait(100)
        local additionalItem = RecycleConfig.ItemTable[math.random(1, #RecycleConfig.ItemTable)]
        local amount = math.random(RecycleConfig.MinItemReceivedQty, RecycleConfig.MaxItemReceivedQty)

        print(string.format('[drp-recycle] Extra item %d: %s x%d', i, additionalItem, amount))
        if addInventoryItem(source, additionalItem, amount) then
            itemsReceived[additionalItem] = (itemsReceived[additionalItem] or 0) + amount
            totalItems += 1
        end
    end

    -- Chance for trojan_usb (7% chance)
    local chance = math.random(1, 100)
    if chance <= RecycleConfig.ChanceItemProbability then
        print('[drp-recycle] Lucky! Giving trojan_usb')
        if addInventoryItem(source, RecycleConfig.ChanceItem, 1) then
            itemsReceived[RecycleConfig.ChanceItem] = (itemsReceived[RecycleConfig.ChanceItem] or 0) + 1
            totalItems += 1
            lib.notify(source, {
                title = 'Recycle Job',
                description = '🎉 Lucky! Found a rare item!',
                type = 'success',
                duration = 7000
            })
        end
    end

    -- Chance for lucky plastic (10% chance)
    local luck = math.random(1, RecycleConfig.LuckyItemProbability)
    local odd = math.random(1, RecycleConfig.LuckyItemProbability)
    if luck == odd then
        local random = math.random(1, 3)
        print(string.format('[drp-recycle] Lucky! Giving %s x%d', RecycleConfig.LuckyItem, random))
        if addInventoryItem(source, RecycleConfig.LuckyItem, random) then
            itemsReceived[RecycleConfig.LuckyItem] = (itemsReceived[RecycleConfig.LuckyItem] or 0) + random
            totalItems += 1
        end
    end

    -- Build notification message with received items
    if totalItems > 0 then
        local itemsList = {}
        for itemName, count in pairs(itemsReceived) do
            local itemData = exports.ox_inventory:Items(itemName)
            local label = itemData and itemData.label or itemName
            itemsList[#itemsList + 1] = string.format('%dx %s', count, label)
        end

        lib.notify(source, {
            title = 'Package Processed',
            description = 'Received: ' .. table.concat(itemsList, ', '),
            type = 'success',
            duration = 6000
        })
    else
        lib.notify(source, {
            title = 'Recycle Job',
            description = 'No items received - inventory may be full',
            type = 'error'
        })
    end

    return totalItems > 0
end

--- Retrieve player's recyclable items with pricing
---@param source number Player source ID
---@return RecycleItem[] items Array of recyclable items
local function getPlayerRecycleItems(source)
    local xPlayer = getPlayer(source)
    if not xPlayer then return {} end

    local items = {}

    for _, itemName in pairs(RecycleConfig.ItemTable) do
        local itemCount = exports.ox_inventory:Search(source, 'count', itemName)
        if itemCount and itemCount > 0 then
            local itemData = exports.ox_inventory:Items(itemName)
            items[#items + 1] = {
                name = itemName,
                label = itemData and itemData.label or itemName,
                amount = itemCount,
                price = RecycleConfig.SellPrices[itemName] or 0
            }
        end
    end

    return items
end

--- Process single item sale
---@param source number Player source ID
---@param itemName string Item to sell
---@return boolean success Whether sale was successful
local function sellSingleItem(source, itemName)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end

    local itemCount = exports.ox_inventory:Search(source, 'count', itemName)

    if not itemCount or itemCount <= 0 then
        lib.notify(source, {
            title = 'Recycle Shop',
            description = 'You don\'t have this item',
            type = 'error'
        })
        return false
    end

    local price = (RecycleConfig.SellPrices[itemName] or 0) * itemCount

    if exports.ox_inventory:RemoveItem(source, itemName, itemCount) then
        xPlayer.addMoney(price)

        local itemData = exports.ox_inventory:Items(itemName)
        local itemLabel = itemData and itemData.label or itemName

        lib.notify(source, {
            title = 'Recycle Shop',
            description = ('Sold %dx %s for $%d'):format(itemCount, itemLabel, price),
            type = 'success'
        })
        return true
    end

    return false
end

--- Process all recyclable items sale
---@param source number Player source ID
---@return boolean success Whether sale was successful
local function sellAllItems(source)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end

    local totalEarnings = 0
    local itemsSold = 0

    for _, itemName in pairs(RecycleConfig.ItemTable) do
        local itemCount = exports.ox_inventory:Search(source, 'count', itemName)
        if itemCount and itemCount > 0 then
            local earnings = (RecycleConfig.SellPrices[itemName] or 0) * itemCount
            if exports.ox_inventory:RemoveItem(source, itemName, itemCount) then
                totalEarnings = totalEarnings + earnings
                itemsSold = itemsSold + 1
            end
        end
    end

    if totalEarnings > 0 then
        xPlayer.addMoney(totalEarnings)
        lib.notify(source, {
            title = 'Recycle Shop',
            description = ('Sold all items for $%d'):format(totalEarnings),
            type = 'success'
        })
        return true
    else
        lib.notify(source, {
            title = 'Recycle Shop',
            description = 'No items to sell',
            type = 'error'
        })
        return false
    end
end

-- Event: Give items from package processing
RegisterNetEvent('drp-recycle:server:getItem', function()
    local src = source
    print('[drp-recycle] Package turn-in event triggered by source: ' .. src)

    -- Validate source
    if not src or src == 0 then
        print('[drp-recycle] ERROR: Invalid source ID')
        return
    end

    -- Validate player exists
    local xPlayer = getPlayer(src)
    if not xPlayer then
        print('[drp-recycle] ERROR: Player not found for source: ' .. src)
        return
    end

    -- Give items and check result
    local success = givePackageItems(src)
    if not success then
        print('[drp-recycle] WARNING: Failed to give items to player ' .. src)
    end
end)

-- Callback: Get player's recyclable items
ESX.RegisterServerCallback('drp-recycle:getItems', function(source, cb)
    cb(getPlayerRecycleItems(source))
end)

-- Callback: Get config data for client
ESX.RegisterServerCallback('drp-recycle:getConfig', function(source, cb)
    cb({
        enter_location = RecycleConfig.enter_location,
        exit_location = RecycleConfig.exit_location,
        package_locations = RecycleConfig.package_locations,
        dropoff_location = RecycleConfig.dropoff_location,
        warehouse_objects = RecycleConfig.warehouse_objects,
        PickupBoxModel = RecycleConfig.PickupBoxModel
    })
end)

-- Event: Sell single item
RegisterNetEvent('drp-recycle:sellItem', function(itemName)
    local src = source

    if not itemName or type(itemName) ~= 'string' then return end

    sellSingleItem(src, itemName)
end)

-- Event: Sell all items
RegisterNetEvent('drp-recycle:sellAllItems', function()
    local src = source
    sellAllItems(src)
end)

-- Debug command to check if items exist
RegisterCommand('recycletest', function(source)
    local xPlayer = getPlayer(source)
    if not xPlayer then
        print('Player not found')
        return
    end

    print('=== Recycle Debug ===')
    print('Config loaded:', Config ~= nil)
    print('Item table count:', Config and #RecycleConfig.ItemTable or 0)

    if Config then
        print('Testing items:')
        for _, itemName in pairs(RecycleConfig.ItemTable) do
            local itemData = exports.ox_inventory:Items(itemName)
            if itemData then
                print((' ✓ %s exists: %s'):format(itemName, itemData.label))
            else
                print((' ✗ %s NOT FOUND'):format(itemName))
            end
        end

        print('Testing add item...')
        local result = exports.ox_inventory:AddItem(source, 'plastic', 1)
        print('Add item result:', result)
    end
end, false)
