---@type table ox_inventory exports
local ox_inventory = exports.ox_inventory

--- Check if player has admin permission
---@param source number Player source ID
---@return boolean hasPermission Whether player is admin
function IsPlayerAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.getGroup() == AdminConfig.ADMIN_GROUP
end

--- Get job options from ESX or database
---@return table[] options Array of job options
function GetJobOptions()
    if JobOptionsCache then return JobOptionsCache end

    JobOptionsCache = {}

    -- Try ESX.GetJobs() first
    local jobs = ESX.GetJobs()
    if jobs then
        for name, job in pairs(jobs) do
            JobOptionsCache[#JobOptionsCache + 1] = {
                label = ('%s (%s)'):format(job.label, name),
                value = name
            }
        end
    end

    -- Fallback to MySQL query if GetJobs fails or is empty
    if #JobOptionsCache == 0 then
        local success, result = pcall(function()
            return MySQL.query.await('SELECT name, label FROM jobs', {})
        end)

        if success and result then
            for _, job in ipairs(result) do
                JobOptionsCache[#JobOptionsCache + 1] = {
                    label = ('%s (%s)'):format(job.label, job.name),
                    value = job.name
                }
            end
        else
            Utils.Debug('[ERROR] Failed to fetch jobs from database: ' .. tostring(result))
            JobOptionsCache = {{ label = 'None (Error)', value = '' }}
        end
    end

    table.sort(JobOptionsCache, function(a, b) return a.label < b.label end)

    if #JobOptionsCache == 0 then
        JobOptionsCache = {{ label = 'None (Error)', value = '' }}
    end

    return JobOptionsCache
end

--- Check if player can use command (cooldown check)
---@param source number Player source ID
---@return boolean canUse Whether player can use command
---@return string? error Error message if on cooldown
function CheckCooldown(source)
    local now = GetGameTimer()
    if Cooldowns[source] and now - Cooldowns[source] < AdminConfig.SPAWN_COOLDOWN then
        local timeLeft = math.ceil((AdminConfig.SPAWN_COOLDOWN - (now - Cooldowns[source])) / 1000)
        return false, Utils.FormatMessage(AdminConfig.MESSAGES.cooldown, timeLeft)
    end
    Cooldowns[source] = now
    return true
end

--- Revive players in radius
---@param source number Admin source ID
---@param radius number Radius in meters
function RevivePlayersInRadius(source, radius)
    radius = tonumber(radius) or AdminConfig.DEFAULT_RADIUS.revive

    if radius <= 0 then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.invalidRadius
        })
        return
    end

    local playerPed = GetPlayerPed(source)
    if not playerPed then
        Utils.Debug('Player ped not found for source ' .. source)
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local revived = 0

    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        if playerId ~= source then
            local targetPed = GetPlayerPed(playerId)
            if targetPed then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)

                if distance <= radius then
                    TriggerClientEvent('drp_admin:revive', playerId)
                    lib.notify(playerId, {
                        type = 'success',
                        description = AdminConfig.MESSAGES.revived
                    })
                    revived += 1
                end
            end
        end
    end

    Utils.Debug('Revived ' .. revived .. ' players within ' .. radius .. ' meters for player ' .. source)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.reviveSuccess, revived, radius)
    })
end

--- Teleport players in job to admin location
---@param source number Admin source ID
---@param jobName string Job name to teleport
function TeleportJobToAdmin(source, jobName)
    if not jobName or jobName == '' then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.mustSpecifyJob
        })
        return
    end

    local adminPed = GetPlayerPed(source)
    if not adminPed then
        Utils.Debug('Admin ped not found for source ' .. source)
        return
    end

    local adminCoords = GetEntityCoords(adminPed)
    local teleported = 0

    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        if playerId ~= source then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer and xPlayer.job.name == jobName then
                TriggerClientEvent('drp_admin:teleportGroup:teleport', playerId, adminCoords)
                lib.notify(playerId, {
                    type = 'success',
                    description = AdminConfig.MESSAGES.teleported
                })
                teleported += 1
            end
        end
    end

    Utils.Debug('Teleported ' .. teleported .. ' players from job ' .. jobName .. ' for player ' .. source)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.teleportSuccess, teleported, jobName)
    })
end

--- Delete vehicles in radius
---@param source number Admin source ID
---@param radius number Radius in meters
function DeleteVehiclesInRadius(source, radius)
    radius = tonumber(radius) or AdminConfig.DEFAULT_RADIUS.deleteVehicles

    if radius <= 0 then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.invalidRadius
        })
        return
    end

    local adminPed = GetPlayerPed(source)
    if not adminPed then
        Utils.Debug('Admin ped not found for source ' .. source)
        return
    end

    local adminCoords = GetEntityCoords(adminPed)

    TriggerClientEvent('drp_admin:deleteVehicles:delete', -1, adminCoords, radius)
    Utils.Debug('Triggered vehicle deletion within ' .. radius .. ' meters for player ' .. source)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.deleteVehiclesSuccess, radius)
    })
end

--- Spawn item for player
---@param source number Player source ID
---@param itemName string Item name
---@param count number Item count
function SpawnItem(source, itemName, count)
    local items = ox_inventory:Items()

    if not itemName or not count or not items[itemName] then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.invalidItem
        })
        return
    end

    local success, response = ox_inventory:AddItem(source, itemName, count)

    if success then
        Utils.Debug('Spawned ' .. count .. ' x ' .. itemName .. ' for player ' .. source)
        lib.notify(source, {
            type = 'success',
            description = Utils.FormatMessage(AdminConfig.MESSAGES.spawnSuccess, count, items[itemName].label)
        })
    else
        Utils.Debug('Failed to spawn ' .. count .. ' x ' .. itemName .. ' for player ' .. source .. ': ' .. tostring(response))
        lib.notify(source, {
            type = 'error',
            description = Utils.FormatMessage(AdminConfig.MESSAGES.spawnFailed, response or 'unknown error')
        })
    end
end

--- Track vehicles that should have fuel set (anti-cheat)
local authorizedFuelVehicles = {}

--- Track event cars spawned (for deletion)
---@type table<number, boolean> NetId -> true
local eventVehicles = {}

--- Track players who received event weapons (for cleanup)
---@type table<string, boolean> Identifier -> true
local eventWeaponRecipients = {}

--- Weapon to ammo type mapping for ox_inventory
---@type table<string, string> Weapon -> Ammo item
local weaponAmmoMap = {
    -- Pistols
    ['WEAPON_PISTOL'] = 'ammo-9',
    ['WEAPON_COMBATPISTOL'] = 'ammo-9',
    ['WEAPON_APPISTOL'] = 'ammo-9',
    ['WEAPON_HEAVYPISTOL'] = 'ammo-45',
    ['WEAPON_PISTOL50'] = 'ammo-50',
    ['WEAPON_SNSPISTOL'] = 'ammo-45',
    ['WEAPON_VINTAGEPISTOL'] = 'ammo-9',

    -- SMGs
    ['WEAPON_MICROSMG'] = 'ammo-45',
    ['WEAPON_SMG'] = 'ammo-9',
    ['WEAPON_ASSAULTSMG'] = 'ammo-9',
    ['WEAPON_MINISMG'] = 'ammo-9',

    -- Rifles
    ['WEAPON_ASSAULTRIFLE'] = 'ammo-rifle',
    ['WEAPON_CARBINERIFLE'] = 'ammo-rifle',
    ['WEAPON_ADVANCEDRIFLE'] = 'ammo-rifle',
    ['WEAPON_SPECIALCARBINE'] = 'ammo-rifle',
    ['WEAPON_COMPACTRIFLE'] = 'ammo-rifle2',

    -- Shotguns (check your ox_inventory config for correct ammo type)
    ['WEAPON_PUMPSHOTGUN'] = 'ammo-12',
    ['WEAPON_SAWNOFFSHOTGUN'] = 'ammo-12',
    ['WEAPON_BULLPUPSHOTGUN'] = 'ammo-12',

    -- Snipers
    ['WEAPON_SNIPERRIFLE'] = 'ammo-rifle2',
    ['WEAPON_HEAVYSNIPER'] = 'ammo-heavysniper',
}

--- Spawn event cars in a grid pattern
---@param source number Admin source ID
---@param model string Vehicle model name
---@param count number Number of vehicles to spawn
---@param carsPerRow number Number of cars per row
---@param spacing number Distance between vehicles in meters (side spacing)
---@param rowSpacing number Distance between rows in meters
---@param maxMods boolean Apply max mods to vehicles
function SpawnEventCars(source, model, count, carsPerRow, spacing, rowSpacing, maxMods)
    model = model or AdminConfig.EVENT_CARS.defaultModel
    count = tonumber(count) or AdminConfig.EVENT_CARS.count
    carsPerRow = tonumber(carsPerRow) or AdminConfig.EVENT_CARS.carsPerRow
    spacing = tonumber(spacing) or AdminConfig.EVENT_CARS.spacing
    rowSpacing = tonumber(rowSpacing) or AdminConfig.EVENT_CARS.rowSpacing
    maxMods = maxMods or false

    local adminPed = GetPlayerPed(source)
    if not adminPed then
        Utils.Debug('Admin ped not found for source ' .. source)
        return
    end

    local adminCoords = GetEntityCoords(adminPed)
    local heading = GetEntityHeading(adminPed)

    -- Calculate spawn positions in a grid pattern
    for i = 1, count do
        -- Calculate row and column (0-indexed for math, then adjust)
        local row = math.floor((i - 1) / carsPerRow)
        local col = (i - 1) % carsPerRow

        -- Calculate side offset (right of admin)
        local sideOffset = (col + 1) * spacing
        local sideOffsetX = math.cos(math.rad(heading + 90)) * sideOffset
        local sideOffsetY = math.sin(math.rad(heading + 90)) * sideOffset

        -- Calculate forward offset (ahead of admin)
        local forwardOffset = row * rowSpacing
        local forwardOffsetX = math.cos(math.rad(heading)) * forwardOffset
        local forwardOffsetY = math.sin(math.rad(heading)) * forwardOffset

        local spawnCoords = vector3(
            adminCoords.x + sideOffsetX + forwardOffsetX,
            adminCoords.y + sideOffsetY + forwardOffsetY,
            adminCoords.z
        )

        Utils.Debug('[SPAWN] Starting spawn for vehicle #' .. i .. ' model: ' .. model .. ' at row ' .. row .. ', col ' .. col)

        -- Create vehicle using ESX with initial fuel property
        -- Pass 'automobile' as 6th parameter to specify vehicle type explicitly
        ESX.OneSync.SpawnVehicle(model, spawnCoords, heading, {
            fuel = 100
        }, function(vehicle)
            Utils.Debug('[SPAWN] Callback executed for vehicle #' .. i .. ', handle: ' .. tostring(vehicle))

            if vehicle and vehicle ~= 0 then
                -- In OneSync, the vehicle handle from callback is the network ID
                -- We can use it directly without DoesEntityExist check
                local netId = vehicle
                Utils.Debug('[SPAWN] Vehicle #' .. i .. ' spawned with handle/netId: ' .. netId)

                -- Authorize this vehicle for fuel setting (anti-cheat)
                authorizedFuelVehicles[netId] = true

                -- Track as event vehicle for deletion
                eventVehicles[netId] = true

                -- Set fuel directly on server-side using statebag
                SetTimeout(1000, function()
                    local veh = NetworkGetEntityFromNetworkId(netId)
                    if veh and veh ~= 0 then
                        Entity(veh).state.fuel = 100.0
                        Utils.Debug('[FUEL] Set fuel to 100 for netId: ' .. netId)

                        -- Apply max mods if requested
                        if maxMods then
                            Utils.Debug('[MODS] Triggering max mods for netId: ' .. netId)
                            TriggerClientEvent('drp_admin:applyMaxMods', -1, netId)
                        end

                        -- Remove authorization after setting (one-time use)
                        SetTimeout(2000, function()
                            authorizedFuelVehicles[netId] = nil
                        end)
                    else
                        Utils.Debug('[FUEL] ERROR: Could not get entity from netId: ' .. netId)
                    end
                end)
            else
                Utils.Debug('[SPAWN] ERROR: Vehicle #' .. i .. ' callback returned invalid handle')
            end
        end, 'automobile')
    end

    local modsText = maxMods and ' with max mods' or ''
    local numRows = math.ceil(count / carsPerRow)
    Utils.Debug('Spawned ' .. count .. ' event vehicles in ' .. numRows .. ' row(s) of ' .. carsPerRow .. ' car(s)' .. modsText .. ' for player ' .. source)

    local layoutText = carsPerRow > 1 and (' (' .. carsPerRow .. ' per row)') or ''
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.carsSpawned, count) .. layoutText .. modsText
    })
end

--- Give event loadout to players in a job
---@param source number Admin source ID
---@param jobName string Job name
---@param primaryWeapon string Primary weapon name
---@param secondaryWeapon? string Secondary weapon name (optional)
---@param ammoAmount number Ammo amount
---@param armorCount number Armor count
function GiveEventLoadout(source, jobName, primaryWeapon, secondaryWeapon, ammoAmount, armorCount)
    if not jobName or jobName == '' then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.mustSpecifyJob
        })
        return
    end

    local equipped = 0

    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.job.name == jobName then
            Utils.Debug('[EVENT-GUNS] Giving loadout to player ' .. playerId .. ' (job: ' .. jobName .. ')')

            -- Track this player for event weapon cleanup
            eventWeaponRecipients[xPlayer.identifier] = true

            -- Give primary weapon
            if primaryWeapon and primaryWeapon ~= 'none' then
                exports.ox_inventory:AddItem(playerId, primaryWeapon, 1)

                -- Give ammo for primary weapon
                local ammoType = weaponAmmoMap[primaryWeapon]
                if ammoType and ammoAmount > 0 then
                    exports.ox_inventory:AddItem(playerId, ammoType, ammoAmount)
                    Utils.Debug('[EVENT-GUNS] Gave ' .. ammoAmount .. ' x ' .. ammoType .. ' for ' .. primaryWeapon)
                end
            end

            -- Give secondary weapon
            if secondaryWeapon and secondaryWeapon ~= 'none' and secondaryWeapon ~= '' then
                exports.ox_inventory:AddItem(playerId, secondaryWeapon, 1)

                -- Give ammo for secondary weapon
                local ammoType = weaponAmmoMap[secondaryWeapon]
                if ammoType and ammoAmount > 0 then
                    exports.ox_inventory:AddItem(playerId, ammoType, ammoAmount)
                    Utils.Debug('[EVENT-GUNS] Gave ' .. ammoAmount .. ' x ' .. ammoType .. ' for ' .. secondaryWeapon)
                end
            end

            -- Give armor
            if armorCount > 0 then
                exports.ox_inventory:AddItem(playerId, 'armor', armorCount)
            end

            lib.notify(playerId, {
                type = 'success',
                description = AdminConfig.MESSAGES.loadoutReceived
            })
            equipped += 1
        end
    end

    local weaponList = primaryWeapon
    if secondaryWeapon and secondaryWeapon ~= 'none' and secondaryWeapon ~= '' then
        weaponList = weaponList .. ' + ' .. secondaryWeapon
    end

    Utils.Debug('Gave weapons (' .. weaponList .. ') to ' .. equipped .. ' players in job ' .. jobName)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.loadoutGiven, weaponList, equipped, jobName)
    })
end

--- Remove event weapons from players in a job
---@param source number Admin source ID
---@param jobName string Job name
function RemoveEventWeapons(source, jobName)
    if not jobName or jobName == '' then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.mustSpecifyJob
        })
        return
    end

    local removed = 0

    -- Remove from online players
    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.job.name == jobName then
            Utils.Debug('[REMOVE-GUNS] Removing weapons from player ' .. playerId .. ' (job: ' .. jobName .. ')')

            -- Remove all weapons from event weapons list
            for _, weaponData in ipairs(AdminConfig.EVENT_WEAPONS) do
                if weaponData.value and weaponData.value ~= 'none' then
                    -- Remove weapon
                    exports.ox_inventory:RemoveItem(playerId, weaponData.value, 1)

                    -- Remove associated ammo
                    local ammoType = weaponAmmoMap[weaponData.value]
                    if ammoType then
                        local ammoCount = exports.ox_inventory:Search(playerId, 'count', ammoType)
                        if ammoCount > 0 then
                            exports.ox_inventory:RemoveItem(playerId, ammoType, ammoCount)
                            Utils.Debug('[REMOVE-GUNS] Removed ' .. ammoCount .. ' x ' .. ammoType)
                        end
                    end
                end
            end

            -- Remove from tracking
            eventWeaponRecipients[xPlayer.identifier] = nil

            lib.notify(playerId, {
                type = 'inform',
                description = AdminConfig.MESSAGES.gunsRemovedNotify
            })
            removed += 1
        end
    end

    Utils.Debug('Removed event weapons from ' .. removed .. ' online players in job ' .. jobName)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.gunsRemoved, removed, jobName)
    })
end

--- Check and remove event weapons from a player on login
---@param playerId number Player source ID
---@param identifier string Player identifier
function CheckAndRemoveEventWeapons(playerId, identifier)
    if not eventWeaponRecipients[identifier] then
        return -- Player not tracked
    end

    Utils.Debug('[RECONNECT-CHECK] Player ' .. playerId .. ' reconnected with event weapons, removing...')

    -- Remove all weapons from event weapons list
    for _, weaponData in ipairs(AdminConfig.EVENT_WEAPONS) do
        if weaponData.value and weaponData.value ~= 'none' then
            exports.ox_inventory:RemoveItem(playerId, weaponData.value, 1)

            -- Remove associated ammo
            local ammoType = weaponAmmoMap[weaponData.value]
            if ammoType then
                local ammoCount = exports.ox_inventory:Search(playerId, 'count', ammoType)
                if ammoCount > 0 then
                    exports.ox_inventory:RemoveItem(playerId, ammoType, ammoCount)
                end
            end
        end
    end

    -- Remove from tracking
    eventWeaponRecipients[identifier] = nil

    -- Notify player
    lib.notify(playerId, {
        type = 'inform',
        description = 'Event weapons have been removed.'
    })

    Utils.Debug('[RECONNECT-CHECK] Removed event weapons from player ' .. playerId)
end

--- Remove event weapons from ALL tracked players (online only)
---@param source number Admin source ID
function RemoveAllEventWeapons(source)
    local onlineRemoved = 0
    local offlineCount = 0

    -- Get list of all tracked identifiers
    local trackedIdentifiers = {}
    for identifier, _ in pairs(eventWeaponRecipients) do
        trackedIdentifiers[#trackedIdentifiers + 1] = identifier
    end

    if #trackedIdentifiers == 0 then
        lib.notify(source, {
            type = 'error',
            description = 'No players have received event weapons.'
        })
        return
    end

    -- Remove from online players
    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and eventWeaponRecipients[xPlayer.identifier] then
            Utils.Debug('[REMOVE-ALL] Removing weapons from online player ' .. playerId)

            -- Remove all weapons from event weapons list
            for _, weaponData in ipairs(AdminConfig.EVENT_WEAPONS) do
                if weaponData.value and weaponData.value ~= 'none' then
                    exports.ox_inventory:RemoveItem(playerId, weaponData.value, 1)

                    local ammoType = weaponAmmoMap[weaponData.value]
                    if ammoType then
                        local ammoCount = exports.ox_inventory:Search(playerId, 'count', ammoType)
                        if ammoCount > 0 then
                            exports.ox_inventory:RemoveItem(playerId, ammoType, ammoCount)
                        end
                    end
                end
            end

            -- Remove from tracking
            eventWeaponRecipients[xPlayer.identifier] = nil

            lib.notify(playerId, {
                type = 'inform',
                description = AdminConfig.MESSAGES.gunsRemovedNotify
            })
            onlineRemoved += 1
        end
    end

    -- Count remaining offline players
    offlineCount = 0
    for _, _ in pairs(eventWeaponRecipients) do
        offlineCount += 1
    end

    local message = ('Removed event weapons from %d online players.'):format(onlineRemoved)
    if offlineCount > 0 then
        message = message .. (' %d offline players will be cleaned on reconnect.'):format(offlineCount)
    end

    Utils.Debug('[REMOVE-ALL] Removed from ' .. onlineRemoved .. ' online players, ' .. offlineCount .. ' still offline')
    lib.notify(source, {
        type = 'success',
        description = message
    })
end

--- Delete all event cars
---@param source number Admin source ID
function DeleteEventCars(source)
    local deleted = 0

    for netId, _ in pairs(eventVehicles) do
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
            deleted = deleted + 1
            Utils.Debug('[DELETE] Deleted event vehicle netId: ' .. netId)
        end
        eventVehicles[netId] = nil
    end

    Utils.Debug('Deleted ' .. deleted .. ' event vehicles for player ' .. source)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.eventCarsDeleted, deleted)
    })
end

--- Repair vehicles in radius
---@param source number Admin source ID
---@param radius number Radius in meters
function RepairVehiclesInRadius(source, radius)
    radius = tonumber(radius) or AdminConfig.DEFAULT_RADIUS.fixVehicles

    if radius <= 0 then
        lib.notify(source, {
            type = 'error',
            description = AdminConfig.MESSAGES.invalidRadius
        })
        return
    end

    local adminPed = GetPlayerPed(source)
    if not adminPed then
        Utils.Debug('Admin ped not found for source ' .. source)
        return
    end

    local adminCoords = GetEntityCoords(adminPed)

    -- Trigger client-side repair for all clients
    TriggerClientEvent('drp_admin:fixVehicles:repair', -1, adminCoords, radius)

    Utils.Debug('Triggered vehicle repair within ' .. radius .. ' meters for player ' .. source)
    lib.notify(source, {
        type = 'success',
        description = Utils.FormatMessage(AdminConfig.MESSAGES.vehiclesFixed, 0, radius)
    })
end
