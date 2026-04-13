-- Optimized weapon restrictions with hash table lookups and caching

-- Hash table for O(1) weapon name lookups
local restrictedWeapons = {
    ['WEAPON_TACTICALRIFLE'] = true,
    ['WEAPON_PISTOL'] = true,
    ['WEAPON_CARBINERIFLE'] = true,
    ['WEAPON_STUNGUN'] = true,
    ['WEAPON_NIGHTSTICK'] = true,
    ['WEAPON_PUMPSHOTGUN'] = true
}

-- Pre-compute weapon hashes for O(1) hash lookups (avoid GetHashKey in loops)
local weaponHashes = {}
for weapon in pairs(restrictedWeapons) do
    weaponHashes[GetHashKey(weapon)] = weapon
end

-- Cache ox_inventory export
local oxInventory = exports.ox_inventory

-- Unified authorization check (single source of truth)
local function isAuthorized(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.job.name == 'police'
end

-- Fast weapon check with nil safety
local function isRestrictedWeapon(itemName)
    if not itemName then return false end
    return restrictedWeapons[string.upper(itemName)] or false
end

-- Hook when player tries to use/equip weapon
oxInventory:registerHook('usingItem', function(payload)
    if not payload or not payload.itemName then return end

    if isRestrictedWeapon(payload.itemName) and not isAuthorized(payload.source) then
        lib.notify(payload.source, {
            type = 'error',
            description = 'You cannot use this weapon!'
        })
        return false
    end
end, {})

-- Hook when weapon is equipped/swapped
oxInventory:registerHook('swapItems', function(payload)
    if not payload or not payload.fromSlot then return end

    local item = oxInventory:GetSlot(payload.source, payload.fromSlot)

    if item and isRestrictedWeapon(item.name) and not isAuthorized(payload.source) then
        lib.notify(payload.source, {
            type = 'error',
            description = 'You are not authorized to equip this weapon!'
        })
        return false
    end
end, {})

-- Cache player jobs to track changes
local playerJobs = {}

-- Remove weapons on job change (police -> non-police)
---@param job JobData New job data
RegisterNetEvent('esx:setJob', function(job)
    local src = source
    if not job or type(job) ~= 'table' or not job.name then return end

    local lastJob = playerJobs[src]
    playerJobs[src] = job

    -- Only remove weapons if changing FROM police TO non-police
    if lastJob and type(lastJob) == 'table' and lastJob.name == 'police' and job.name ~= 'police' then
        for weapon in pairs(restrictedWeapons) do
            oxInventory:RemoveItem(src, weapon, 100)
        end
    end
end)

-- Clean up cache when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    playerJobs[src] = nil
end)

-- Check equipped weapons via hash (optimized with pre-computed hash table)
RegisterNetEvent('weapon:checkAuth', function(weaponHash)
    if not weaponHash then return end

    local src = source
    local weaponName = weaponHashes[weaponHash]

    if weaponName and not isAuthorized(src) then
        oxInventory:RemoveItem(src, weaponName, 1)
        TriggerClientEvent('weapon:forceRemove', src)
        lib.notify(src, {
            type = 'error',
            description = 'Unauthorized weapon confiscated!'
        })
    end
end)
