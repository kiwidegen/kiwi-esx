--- Event handler for revive radius submission
---@param radius number Radius in meters
RegisterNetEvent('drp_admin:reviveRadius:submit', function(radius)
    local source = source
    RevivePlayersInRadius(source, radius)
end)

--- Event handler for teleport group submission
---@param jobName string Job name to teleport
RegisterNetEvent('drp_admin:teleportGroup:submit', function(jobName)
    local source = source
    TeleportJobToAdmin(source, jobName)
end)

--- Event handler for requesting job options
RegisterNetEvent('drp_admin:teleportGroup:requestJobOptions', function()
    local source = source
    local options = GetJobOptions()
    TriggerClientEvent('drp_admin:teleportGroup:setJobOptions', source, options)
end)

--- Event handler for delete vehicles radius submission
---@param radius number Radius in meters
RegisterNetEvent('drp_admin:deleteVehicles:submit', function(radius)
    local source = source
    DeleteVehiclesInRadius(source, radius)
end)

--- Event handler for spawn item submission
---@param itemName string Item name
---@param count number Item count
RegisterNetEvent('drp_admin:spawnItem', function(itemName, count)
    local source = source
    SpawnItem(source, itemName, count)
end)

--- Event handler for event cars submission
---@param model string Vehicle model name
---@param count number Number of vehicles to spawn
---@param carsPerRow number Number of cars per row
---@param spacing number Distance between vehicles in meters (side spacing)
---@param rowSpacing number Distance between rows in meters
---@param maxMods boolean Apply max mods to vehicles
RegisterNetEvent('drp_admin:eventCars:submit', function(model, count, carsPerRow, spacing, rowSpacing, maxMods)
    local source = source
    SpawnEventCars(source, model, count, carsPerRow, spacing, rowSpacing, maxMods)
end)

--- Event handler for event guns submission
---@param jobName string Job name
---@param primaryWeapon string Primary weapon
---@param secondaryWeapon? string Secondary weapon (optional)
---@param ammoAmount number Ammo amount
---@param armorCount number Armor count
RegisterNetEvent('drp_admin:eventGuns:submit', function(jobName, primaryWeapon, secondaryWeapon, ammoAmount, armorCount)
    local source = source
    GiveEventLoadout(source, jobName, primaryWeapon, secondaryWeapon, ammoAmount, armorCount)
end)

--- Event handler for remove guns submission
---@param jobName string Job name
RegisterNetEvent('drp_admin:removeGuns:submit', function(jobName)
    local source = source
    RemoveEventWeapons(source, jobName)
end)

--- Event handler for fix vehicles radius submission
---@param radius number Radius in meters
RegisterNetEvent('drp_admin:fixVehicles:submit', function(radius)
    local source = source
    RepairVehiclesInRadius(source, radius)
end)
