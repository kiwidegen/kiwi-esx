-- Module guard (server-side check)
if not Config or not ExtrasConfig.Modules or not ExtrasConfig.Modules.RestrictedItems then return end

--============================================================
--  RESTRICTED ITEMS/WEAPONS SERVER MODULE
--============================================================

--- Check if table contains value (case-insensitive)
---@param t table Table to search
---@param v string Value to find
---@return boolean found Whether value exists in table
local function TableContains(t, v)
    for key, value in pairs(t) do
        if (value:lower() == v:lower()) then
            return true
        end
    end
    return false
end

--- Check if player is allowed to have item
---@param job string Player job name
---@param item string Item name
---@return boolean allowed Whether player can have item
local function IsPlayerAllowedToHaveItem(job, item)
    if (ExtrasConfig.RestrictedItems[item:lower()] ~= nil and not TableContains(ExtrasConfig.RestrictedItems[item:lower()], job:lower())) then
        return false
    end
    return true
end

--- Check if player is allowed to have weapon
---@param job string Player job name
---@param weapon string Weapon name
---@return boolean allowed Whether player can have weapon
local function IsPlayerAllowedToHaveWeapon(job, weapon)
    if (ExtrasConfig.RestrictedWeapons[weapon:upper()] ~= nil and not TableContains(ExtrasConfig.RestrictedWeapons[weapon:upper()], job:lower())) then
        return false
    end
    return true
end

--- Check all player items and weapons for restricted items
---@param xPlayer table ESX player object
---@param job string Job name (optional, defaults to player's current job)
local function CheckPlayerRestricted(xPlayer, job)
    job = job or xPlayer.getJob().name

    -- Check inventory items using ox_inventory
    local inventory = exports.ox_inventory:GetInventoryItems(xPlayer.source)
    if inventory then
        for slot, item in pairs(inventory) do
            if item and item.name and item.count and item.count > 0 then
                if (not IsPlayerAllowedToHaveItem(job, item.name)) then
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                        description = 'You are not allowed to possess this item',
                        type = 'error'
                    })
                    exports.ox_inventory:RemoveItem(xPlayer.source, item.name, item.count)
                end
            end
        end
    end

    -- Check weapons
    for key, value in ipairs(xPlayer.getLoadout()) do
        if (not IsPlayerAllowedToHaveWeapon(job, value.name)) then
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                description = 'You are not allowed to possess this weapon',
                type = 'error'
            })
            xPlayer.removeWeapon(value.name)
        end
    end
end

--- ox_inventory hook - check when item is added
exports('canCarryItem', function(source, item, count, metadata)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return true end

    local job = xPlayer.getJob().name
    local itemUpper = item:upper()

    -- Check if it's a restricted weapon (weapons in ox_inventory are items too)
    if itemUpper:match("^WEAPON_") then
        if not IsPlayerAllowedToHaveWeapon(job, itemUpper) then
            TriggerClientEvent('ox_lib:notify', source, {
                description = 'You are not allowed to possess this weapon',
                type = 'error'
            })

            return false  -- Prevent pickup
        end
    end

    -- Check if item is restricted
    if not IsPlayerAllowedToHaveItem(job, item) then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You are not allowed to possess this item',
            type = 'error'
        })

        return false  -- Prevent pickup
    end

    return true  -- Allow pickup
end)

--- ESX weapon check hook
AddEventHandler('esx:onAddWeapon', function(source, weapon)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local job = xPlayer.getJob().name

    -- Check if weapon is restricted
    if not IsPlayerAllowedToHaveWeapon(job, weapon) then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You are not allowed to possess this weapon',
            type = 'error'
        })

        xPlayer.removeWeapon(weapon)
    end
end)

--- Check restrictions when job changes
AddEventHandler("esx:setJob", function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    CheckPlayerRestricted(xPlayer, job.name)
end)

--- Check restrictions when player loads
RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    Wait(2000)  -- Wait for inventory to load
    CheckPlayerRestricted(xPlayer)
end)

--- Periodic check every 30 seconds
CreateThread(function()
    while true do
        Wait(30000)

        for _, playerId in ipairs(GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                CheckPlayerRestricted(xPlayer)
            end
        end
    end
end)
