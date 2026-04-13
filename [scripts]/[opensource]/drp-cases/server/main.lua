--- OX Inventory export
local oxInventory = exports.ox_inventory

--- Active lootbox openings to prevent spam
---@type table<number, boolean>
local activeLootboxes = {}

--- Send notification to Discord webhook via drp-logs
---@param source number Player server ID
---@param reward LootboxReward Reward information
---@param rewardType string Type of reward (item, weapon, money, black_money)
local function sendDiscordNotification(source, reward, rewardType)
    if not CasesConfig.ENABLE_BROADCAST then return end
    if not CasesConfig.BROADCAST_TIER[reward.tier] then return end

    local playerName = GetPlayerName(source)
    local tierName = CasesConfig.CHANCE[reward.tier].name
    local colorName = 'info'

    -- Set color based on tier
    if reward.tier == 5 then
        colorName = 'orange'  -- Legendary - Orange
    elseif reward.tier == 4 then
        colorName = 'error'   -- Unique - Red
    elseif reward.tier == 3 then
        colorName = 'warning' -- Epic - Yellow
    elseif reward.tier == 2 then
        colorName = 'success' -- Rare - Green
    else
        colorName = 'info'    -- Common - Blue
    end

    local fields = {
        { name = 'Reward', value = reward.label, inline = true },
        { name = 'Tier', value = tierName, inline = true }
    }

    -- Add amount field if applicable
    if rewardType == 'item' and reward.amount then
        table.insert(fields, { name = 'Amount', value = tostring(reward.amount), inline = true })
    elseif rewardType == 'money' then
        table.insert(fields, { name = 'Amount', value = '$' .. tostring(reward.money), inline = true })
    elseif rewardType == 'black_money' then
        table.insert(fields, { name = 'Amount', value = '$' .. tostring(reward.black_money), inline = true })
    end

    exports['drp-logs']:log('lootbox', {
        source = source,
        title = 'Lootbox Reward - ' .. tierName,
        description = string.format('%s received a %s tier reward from a lootbox', playerName, tierName),
        colorName = colorName,
        fields = fields
    })
end

--- Calculate random reward based on tier rates
---@param lootboxId string Lootbox identifier
---@return LootboxReward|nil reward Selected reward or nil if invalid
local function calculateReward(lootboxId)
    local lootboxConfig = CasesConfig.LOOTBOXES[lootboxId]
    if not lootboxConfig then return nil end

    -- Build weighted pool
    local pool = {}
    for _, reward in ipairs(lootboxConfig.list) do
        local tierConfig = CasesConfig.CHANCE[reward.tier]
        if tierConfig then
            local weight = math.floor(tierConfig.rate * 100)
            for i = 1, weight do
                pool[#pool + 1] = reward
            end
        end
    end

    -- Select random reward from weighted pool
    if #pool > 0 then
        local randomIndex = math.random(1, #pool)
        return pool[randomIndex]
    end

    return nil
end

--- Give reward to player
---@param source number Player server ID
---@param reward LootboxReward Reward to give
---@return boolean success Whether reward was given successfully
local function giveReward(source, reward)
    local success = false
    local playerName = GetPlayerName(source)

    if reward.item then
        local amount = reward.amount or 1
        success = oxInventory:AddItem(source, reward.item, amount)
        if success then
            sendDiscordNotification(source, reward, 'item')
        end
    elseif reward.weapon then
        local metadata = { durability = 100, ammo = 50 }
        success = oxInventory:AddItem(source, reward.weapon, 1, metadata)
        if not success then
            -- Fallback without metadata
            success = oxInventory:AddItem(source, reward.weapon, 1)
        end
        if success then
            sendDiscordNotification(source, reward, 'weapon')
        end
    elseif reward.money then
        success = oxInventory:AddItem(source, 'money', reward.money)
        if success then
            sendDiscordNotification(source, reward, 'money')
        end
    elseif reward.black_money then
        success = oxInventory:AddItem(source, 'black_money', reward.black_money)
        if success then
            sendDiscordNotification(source, reward, 'black_money')
        end
    end

    return success
end

--- Server event: Use lootbox item
---@param lootboxId string Lootbox item identifier
RegisterNetEvent('drp-cases:useLootbox', function(lootboxId)
    local source = source

    -- Prevent spam
    if activeLootboxes[source] then
        lib.notify(source, {
            title = 'Lootbox',
            description = 'Please wait until the current lootbox is finished opening!',
            type = 'error'
        })
        return
    end

    -- Validate lootbox exists
    if not CasesConfig.LOOTBOXES[lootboxId] then
        lib.notify(source, {
            title = 'Lootbox',
            description = 'Invalid lootbox type!',
            type = 'error'
        })
        return
    end

    -- Remove lootbox from inventory
    if not oxInventory:RemoveItem(source, lootboxId, 1) then
        lib.notify(source, {
            title = 'Lootbox',
            description = 'You don\'t have that lootbox!',
            type = 'error'
        })
        return
    end

    -- Mark as active
    activeLootboxes[source] = true

    -- Calculate reward server-side
    local reward = calculateReward(lootboxId)
    if not reward then
        lib.notify(source, {
            title = 'Lootbox',
            description = 'Error calculating reward!',
            type = 'error'
        })
        activeLootboxes[source] = nil
        return
    end

    -- Send lootbox data and reward to client for UI display
    TriggerClientEvent('drp-cases:openUI', source, {
        lootboxId = lootboxId,
        rewards = CasesConfig.LOOTBOXES[lootboxId].list,
        selectedReward = reward,
        imageSource = CasesConfig.IMAGE_SOURCE
    })
end)

--- Server event: Confirm reward (called after UI animation completes)
---@param reward LootboxReward Reward to give
RegisterNetEvent('drp-cases:confirmReward', function(reward)
    local source = source

    if not activeLootboxes[source] then
        return
    end

    -- Give the reward
    local success = giveReward(source, reward)

    if success then
        lib.notify(source, {
            title = 'Lootbox',
            description = string.format('You received: %s', reward.label),
            type = 'success'
        })
    else
        lib.notify(source, {
            title = 'Lootbox',
            description = 'Failed to add reward to inventory!',
            type = 'error'
        })
    end

    -- Clear active state
    activeLootboxes[source] = nil
end)

--- Clean up active lootbox on player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    if activeLootboxes[source] then
        activeLootboxes[source] = nil
    end
end)
