-- Money boost system (server-side)

ESX = exports['es_extended']:getSharedObject()

-- Store active money boosts per player
local activeBoosts = {}

-- Helper to get player's current money boost percentage
local function GetPlayerMoneyBoost(source)
    return activeBoosts[source] or 0
end

-- Helper to apply money boost to an amount
local function ApplyMoneyBoost(source, baseAmount)
    local boost = GetPlayerMoneyBoost(source)

    if boost > 0 then
        local bonusAmount = math.floor(baseAmount * (boost / 100))
        local totalAmount = baseAmount + bonusAmount

        Utils.Debug('Money boost applied:', baseAmount, '+', bonusAmount, '=', totalAmount)

        return totalAmount, bonusAmount
    end

    return baseAmount, 0
end

-- Update player's boost status (called from client)
RegisterNetEvent('hud:server:updateMoneyBoost', function(percentage)
    local src = source
    activeBoosts[src] = percentage

    if percentage <= 0 then
        activeBoosts[src] = nil
    end
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local src = source
    activeBoosts[src] = nil
end)

-- Export for other resources to use when giving money
exports('ApplyMoneyBoost', ApplyMoneyBoost)
exports('GetPlayerMoneyBoost', GetPlayerMoneyBoost)

-- Example: Hook into ESX money functions
-- You would integrate this with your existing money give functions

--[[ EXAMPLE USAGE IN YOUR SCRIPTS:

    -- Before giving money, apply boost:
    local boostedAmount, bonus = exports['drp-hud']:ApplyMoneyBoost(source, baseAmount)

    -- Give the boosted amount
    xPlayer.addMoney(boostedAmount)

    -- Optional: Notify about bonus
    if bonus > 0 then
        TriggerClientEvent('esx:showNotification', source, string.format('Earned $%d (+$%d bonus!)', boostedAmount, bonus))
    end

]]

-- ESX Money hooks (optional - integrate with your existing systems)
AddEventHandler('esx:onAddMoney', function(source, account, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Check if player has active money boost
    local boost = GetPlayerMoneyBoost(source)
    if boost > 0 and account == 'money' then
        local bonusAmount = math.floor(amount * (boost / 100))

        if bonusAmount > 0 then
            -- Give bonus after a tiny delay to avoid conflicts
            SetTimeout(100, function()
                xPlayer.addMoney(bonusAmount)
                TriggerClientEvent('esx:showNotification', source, string.format('+$%d Money Boost Bonus!', bonusAmount), 'success')
            end)
        end
    end
end)

print('^2[drp-hud]^0 Money boost system loaded')
