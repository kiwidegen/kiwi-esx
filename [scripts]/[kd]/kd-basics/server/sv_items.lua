-- ╔══════════════════════════════╗
-- ║        Usable Items          ║
-- ╚══════════════════════════════╝

print('[kd-basics] sv_items.lua loading')

-- ox_inventory passes: (action, item, inventory)
-- player source is inventory.id

local ESX = exports['es_extended']:getSharedObject()
print('[kd-basics] ESX loaded')

local function isAllowedJob(source, allowedJobs)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local job = xPlayer.getJob().name
    for _, allowed in ipairs(allowedJobs) do
        if job == allowed then return true end
    end
    return false
end

-- binoculars
print('[kd-basics] useBinoculars export registered')
exports('useBinoculars', function(event, item, inventory, slot, data)
    print('[kd-basics] useBinoculars called - event:', event, 'source:', inventory and inventory.id)
    if event ~= 'usedItem' then return end
    local source = inventory.id
    if not isAllowedJob(source, Config.Binoculars.jobs) then
        print('[kd-basics] useBinoculars - job check failed for source:', source)
        TriggerClientEvent('ox_lib:notify', source, { title = 'Binoculars', description = 'You are not authorised to use this.', type = 'error' })
        return
    end
    print('[kd-basics] useBinoculars - job OK, triggering client event for source:', source)
    TriggerClientEvent('kd-basics:client:useBinoculars', source)
end)

-- repairkit item removal (called by client after successful repair)
-- item param is 'repairkit' or 'adv_repairkit'
RegisterNetEvent('kd-basics:server:removeRepairKit', function(item)
    local src     = source
    if not src or src <= 0 then return end
    if item ~= 'repairkit' and item ~= 'adv_repairkit' then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    xPlayer.removeInventoryItem(item, 1)
end)
