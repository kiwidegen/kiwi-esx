--- Revive Radius Command
lib.addCommand('reviveradius', {
    help = 'Revive all players within a specified radius',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering revive radius dialog for player ' .. source)
    TriggerClientEvent('drp_admin:reviveRadius:openDialog', source)
end)

--- Teleport Group Command
lib.addCommand('tpgroup', {
    help = 'Teleport all players in a job to your location',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering teleport group dialog for player ' .. source)
    local options = GetJobOptions()
    TriggerClientEvent('drp_admin:teleportGroup:setJobOptions', source, options)
    TriggerClientEvent('drp_admin:teleportGroup:openDialog', source)
end)

--- Delete Cars Radius Command
lib.addCommand('delcarsradius', {
    help = 'Delete all unused vehicles within a specified radius',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering delete cars radius dialog for player ' .. source)
    TriggerClientEvent('drp_admin:deleteVehicles:openDialog', source)
end)

--- DRP Spawn Command
lib.addCommand('drpspawn', {
    help = 'Spawn items (admin only)',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    local canUse, error = CheckCooldown(source)
    if not canUse then
        lib.notify(source, {
            type = 'error',
            description = error
        })
        return
    end

    Utils.Debug('Triggering spawn menu for player ' .. source)
    TriggerClientEvent('drp_admin:openSpawnMenu', source)
end)

--- Event Cars Command
lib.addCommand('eventcar', {
    help = 'Spawn event vehicles in a line',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering event cars dialog for player ' .. source)
    TriggerClientEvent('drp_admin:eventCars:openDialog', source)
end)

--- Event Guns Command
lib.addCommand('eventguns', {
    help = 'Give event loadout to players in a job',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering event guns dialog for player ' .. source)
    local options = GetJobOptions()
    TriggerClientEvent('drp_admin:teleportGroup:setJobOptions', source, options)
    TriggerClientEvent('drp_admin:eventGuns:openDialog', source)
end)

--- Remove Guns Command
lib.addCommand('removeguns', {
    help = 'Remove event weapons from players in a job',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering remove guns dialog for player ' .. source)
    local options = GetJobOptions()
    TriggerClientEvent('drp_admin:teleportGroup:setJobOptions', source, options)
    TriggerClientEvent('drp_admin:removeGuns:openDialog', source)
end)

--- Max Mods Command
lib.addCommand('maxmods', {
    help = 'Max upgrade your current vehicle',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering max mods for player ' .. source)
    TriggerClientEvent('drp_admin:maxMods', source)
end)

--- Fix Radius Command
lib.addCommand('fixradius', {
    help = 'Repair all vehicles within a specified radius',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Triggering fix vehicles radius dialog for player ' .. source)
    TriggerClientEvent('drp_admin:fixVehicles:openDialog', source)
end)

--- Delete Event Cars Command
lib.addCommand('deleventcars', {
    help = 'Delete all event cars spawned with /eventcar',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Deleting event cars for player ' .. source)
    DeleteEventCars(source)
end)

--- Remove All Event Guns Command
lib.addCommand('removeallguns', {
    help = 'Remove event weapons from ALL players who received them (online only)',
    restricted = 'group.' .. AdminConfig.ADMIN_GROUP
}, function(source)
    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.noPermission
        })
        return
    end

    Utils.Debug('Removing all event weapons for player ' .. source)
    RemoveAllEventWeapons(source)
end)
