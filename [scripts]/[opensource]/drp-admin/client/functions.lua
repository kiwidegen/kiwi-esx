---@type table ox_inventory exports
local ox_inventory = exports.ox_inventory

--- Get sorted item options for spawn menu
---@return table[] options Array of item options with label and value
function GetItemOptions()
    if ItemOptions then return ItemOptions end

    local items = ox_inventory:Items()
    ItemOptions = {}

    for itemName, data in pairs(items) do
        ItemOptions[#ItemOptions + 1] = {
            label = ('%s (%s)'):format(data.label, itemName),
            value = itemName
        }
    end

    table.sort(ItemOptions, function(a, b) return a.label < b.label end)
    return ItemOptions
end

--- Open revive radius dialog
function OpenReviveRadiusDialog()
    Utils.Debug('Opening revive radius dialog for player ' .. GetPlayerServerId(PlayerId()))

    local input = lib.inputDialog(AdminConfig.DIALOGS.reviveRadius, {
        {
            type = 'number',
            label = 'Radius (meters)',
            description = 'Enter the radius to revive players',
            placeholder = tostring(AdminConfig.DEFAULT_RADIUS.revive),
            default = AdminConfig.DEFAULT_RADIUS.revive,
            required = true,
            min = AdminConfig.RADIUS_LIMITS.min
        }
    }, { allowCancel = true })

    if input then
        Utils.Debug('Revive radius dialog submitted with radius: ' .. tostring(input[1]))
        TriggerServerEvent('drp_admin:reviveRadius:submit', input[1])
    else
        Utils.Debug('Revive radius dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Open teleport group dialog
function OpenTeleportGroupDialog()
    Utils.Debug('Opening teleport group dialog for player ' .. GetPlayerServerId(PlayerId()))

    if not JobOptions then
        Utils.Debug('Job options not loaded, requesting from server')
        TriggerServerEvent('drp_admin:teleportGroup:requestJobOptions')
        Wait(500)
    end

    if not JobOptions or #JobOptions == 0 then
        Utils.Debug('No job options available')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.noJobsAvailable
        })
        return
    end

    local input = lib.inputDialog(AdminConfig.DIALOGS.teleportGroup, {
        {
            type = 'select',
            label = 'Select Job',
            options = JobOptions,
            required = true,
            searchable = true,
            clearable = false,
            placeholder = 'Select a job...'
        }
    }, { allowCancel = true })

    if input then
        Utils.Debug('Teleport group dialog submitted with job: ' .. tostring(input[1]))
        TriggerServerEvent('drp_admin:teleportGroup:submit', input[1])
    else
        Utils.Debug('Teleport group dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Open delete cars radius dialog
function OpenDeleteCarsDialog()
    Utils.Debug('Opening delete cars radius dialog for player ' .. GetPlayerServerId(PlayerId()))

    local input = lib.inputDialog(AdminConfig.DIALOGS.deleteVehicles, {
        {
            type = 'number',
            label = 'Radius (meters)',
            description = 'Enter the radius to delete unused vehicles',
            placeholder = tostring(AdminConfig.DEFAULT_RADIUS.deleteVehicles),
            default = AdminConfig.DEFAULT_RADIUS.deleteVehicles,
            required = true,
            min = AdminConfig.RADIUS_LIMITS.min
        }
    }, { allowCancel = true })

    if input then
        Utils.Debug('Delete cars radius dialog submitted with radius: ' .. tostring(input[1]))
        TriggerServerEvent('drp_admin:deleteVehicles:submit', input[1])
    else
        Utils.Debug('Delete cars radius dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Open spawn item menu
function OpenSpawnMenu()
    Utils.Debug('Opening spawn menu for player ' .. GetPlayerServerId(PlayerId()))
    local keepMenuOpen = true

    while keepMenuOpen do
        local input = lib.inputDialog(AdminConfig.DIALOGS.spawnItem, {
            {
                type = 'select',
                label = 'Select Item',
                options = GetItemOptions(),
                required = true,
                searchable = true,
                clearable = false,
                placeholder = 'Search items...'
            },
            {
                type = 'number',
                label = 'Amount',
                default = 1,
                min = AdminConfig.SPAWN_LIMITS.min,
                max = AdminConfig.SPAWN_LIMITS.max,
                required = true,
                placeholder = ('Enter quantity (%d-%d)'):format(AdminConfig.SPAWN_LIMITS.min, AdminConfig.SPAWN_LIMITS.max)
            }
        }, { allowCancel = true })

        if input then
            local itemName = input[1]
            local count = tonumber(input[2])
            Utils.Debug('Spawn menu submitted with item: ' .. itemName .. ', count: ' .. count)
            TriggerServerEvent('drp_admin:spawnItem', itemName, count)
        else
            Utils.Debug('Spawn menu cancelled by player')
            lib.notify({
                type = 'error',
                description = AdminConfig.MESSAGES.cancelled
            })
            keepMenuOpen = false
        end
    end
end

--- Delete vehicles in radius (client-side execution)
---@param centerCoords vector3 Center coordinates
---@param radius number Radius in meters
function DeleteVehiclesInRadius(centerCoords, radius)
    local vehicles = GetGamePool('CVehicle')
    local deleted = 0

    for _, vehicle in ipairs(vehicles) do
        if not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(centerCoords - vehicleCoords)

            if distance <= radius then
                DeleteEntity(vehicle)
                deleted += 1
            end
        end
    end

    Utils.Debug('Deleted ' .. deleted .. ' vehicles within ' .. radius .. ' meters for player ' .. GetPlayerServerId(PlayerId()))
end

--- Open event cars dialog
function OpenEventCarsDialog()
    Utils.Debug('Opening event cars dialog for player ' .. GetPlayerServerId(PlayerId()))

    local input = lib.inputDialog(AdminConfig.DIALOGS.eventCars, {
        {
            type = 'input',
            label = 'Vehicle Model',
            description = 'Enter vehicle spawn name (leave empty for default)',
            placeholder = AdminConfig.EVENT_CARS.defaultModel,
            required = false
        },
        {
            type = 'number',
            label = 'Number of Cars',
            description = 'Total number of cars to spawn',
            default = AdminConfig.EVENT_CARS.count,
            min = 1,
            max = 40,
            required = true
        },
        {
            type = 'number',
            label = 'Cars Per Row',
            description = 'How many cars wide (1-4)',
            default = AdminConfig.EVENT_CARS.carsPerRow,
            min = 1,
            max = 4,
            required = true
        },
        {
            type = 'number',
            label = 'Side Spacing (meters)',
            description = 'Distance between cars side-by-side',
            default = AdminConfig.EVENT_CARS.spacing,
            min = 2,
            max = 20,
            required = true
        },
        {
            type = 'number',
            label = 'Row Spacing (meters)',
            description = 'Distance between rows front-to-back',
            default = AdminConfig.EVENT_CARS.rowSpacing,
            min = 2,
            max = 20,
            required = true
        },
        {
            type = 'checkbox',
            label = 'Max Mods',
            description = 'Apply max performance upgrades to spawned vehicles',
            checked = false
        }
    }, { allowCancel = true })

    if input then
        local model = input[1] and input[1] ~= '' and input[1] or AdminConfig.EVENT_CARS.defaultModel
        local count = tonumber(input[2]) or AdminConfig.EVENT_CARS.count
        local carsPerRow = tonumber(input[3]) or AdminConfig.EVENT_CARS.carsPerRow
        local spacing = tonumber(input[4]) or AdminConfig.EVENT_CARS.spacing
        local rowSpacing = tonumber(input[5]) or AdminConfig.EVENT_CARS.rowSpacing
        local maxMods = input[6] or false
        Utils.Debug('Event cars dialog submitted with model: ' .. model .. ', count: ' .. count .. ', carsPerRow: ' .. carsPerRow .. ', spacing: ' .. spacing .. ', rowSpacing: ' .. rowSpacing .. ', maxMods: ' .. tostring(maxMods))
        TriggerServerEvent('drp_admin:eventCars:submit', model, count, carsPerRow, spacing, rowSpacing, maxMods)
    else
        Utils.Debug('Event cars dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Open event guns dialog
function OpenEventGunsDialog()
    Utils.Debug('Opening event guns dialog for player ' .. GetPlayerServerId(PlayerId()))

    if not JobOptions then
        Utils.Debug('Job options not loaded, requesting from server')
        TriggerServerEvent('drp_admin:teleportGroup:requestJobOptions')
        Wait(500)
    end

    if not JobOptions or #JobOptions == 0 then
        Utils.Debug('No job options available')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.noJobsAvailable
        })
        return
    end

    local input = lib.inputDialog(AdminConfig.DIALOGS.eventGuns, {
        {
            type = 'select',
            label = 'Select Job',
            options = JobOptions,
            required = true,
            searchable = true,
            clearable = false,
            placeholder = 'Select a job...'
        },
        {
            type = 'select',
            label = 'Primary Weapon',
            options = AdminConfig.EVENT_WEAPONS,
            required = true,
            searchable = true,
            clearable = false,
            placeholder = 'Select primary weapon...'
        },
        {
            type = 'select',
            label = 'Secondary Weapon',
            options = AdminConfig.EVENT_WEAPONS,
            required = false,
            searchable = true,
            clearable = true,
            placeholder = 'Select secondary weapon (optional)...'
        },
        {
            type = 'number',
            label = 'Ammo Amount',
            description = 'Ammo for each weapon',
            default = AdminConfig.DEFAULT_AMMO,
            min = 0,
            max = 9999,
            required = true
        },
        {
            type = 'number',
            label = 'Armor Count',
            description = 'Number of armor items (0 for none)',
            default = 0,
            min = 0,
            max = 10,
            required = true
        }
    }, { allowCancel = true })

    if input then
        local jobName = input[1]
        local primaryWeapon = input[2]
        local secondaryWeapon = input[3]
        local ammoAmount = tonumber(input[4])
        local armorCount = tonumber(input[5])

        Utils.Debug('Event guns dialog submitted - Job: ' .. jobName .. ', Primary: ' .. primaryWeapon)
        TriggerServerEvent('drp_admin:eventGuns:submit', jobName, primaryWeapon, secondaryWeapon, ammoAmount, armorCount)
    else
        Utils.Debug('Event guns dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Open remove guns dialog
function OpenRemoveGunsDialog()
    Utils.Debug('Opening remove guns dialog for player ' .. GetPlayerServerId(PlayerId()))

    if not JobOptions then
        Utils.Debug('Job options not loaded, requesting from server')
        TriggerServerEvent('drp_admin:teleportGroup:requestJobOptions')
        Wait(500)
    end

    if not JobOptions or #JobOptions == 0 then
        Utils.Debug('No job options available')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.noJobsAvailable
        })
        return
    end

    local input = lib.inputDialog(AdminConfig.DIALOGS.removeGuns, {
        {
            type = 'select',
            label = 'Select Job',
            options = JobOptions,
            required = true,
            searchable = true,
            clearable = false,
            placeholder = 'Select a job...'
        }
    }, { allowCancel = true })

    if input then
        Utils.Debug('Remove guns dialog submitted with job: ' .. input[1])
        TriggerServerEvent('drp_admin:removeGuns:submit', input[1])
    else
        Utils.Debug('Remove guns dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Max upgrade current vehicle
function MaxModsVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.notInVehicle
        })
        return
    end

    Utils.Debug('Maxing out vehicle mods for player ' .. GetPlayerServerId(PlayerId()))

    -- Set max performance mods
    SetVehicleModKit(vehicle, 0)

    -- Engine (11), Brakes (12), Transmission (13), Suspension (15), Armor (16)
    SetVehicleMod(vehicle, 11, GetNumVehicleMods(vehicle, 11) - 1, false) -- Engine
    SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false) -- Brakes
    SetVehicleMod(vehicle, 13, GetNumVehicleMods(vehicle, 13) - 1, false) -- Transmission
    SetVehicleMod(vehicle, 15, GetNumVehicleMods(vehicle, 15) - 1, false) -- Suspension
    SetVehicleMod(vehicle, 16, GetNumVehicleMods(vehicle, 16) - 1, false) -- Armor

    -- Turbo (18)
    ToggleVehicleMod(vehicle, 18, true)

    -- Repair and clean
    SetVehicleFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)

    lib.notify({
        type = 'success',
        description = AdminConfig.MESSAGES.vehicleMaxed
    })
end

--- Open fix vehicles radius dialog
function OpenFixVehiclesDialog()
    Utils.Debug('Opening fix vehicles radius dialog for player ' .. GetPlayerServerId(PlayerId()))

    local input = lib.inputDialog(AdminConfig.DIALOGS.fixVehicles, {
        {
            type = 'number',
            label = 'Radius (meters)',
            description = 'Enter the radius to repair vehicles',
            placeholder = tostring(AdminConfig.DEFAULT_RADIUS.fixVehicles),
            default = AdminConfig.DEFAULT_RADIUS.fixVehicles,
            required = true,
            min = AdminConfig.RADIUS_LIMITS.min
        }
    }, { allowCancel = true })

    if input then
        Utils.Debug('Fix vehicles radius dialog submitted with radius: ' .. tostring(input[1]))
        TriggerServerEvent('drp_admin:fixVehicles:submit', input[1])
    else
        Utils.Debug('Fix vehicles radius dialog cancelled by player')
        lib.notify({
            type = 'error',
            description = AdminConfig.MESSAGES.cancelled
        })
    end
end

--- Repair vehicles in radius (client-side execution)
---@param centerCoords vector3 Center coordinates
---@param radius number Radius in meters
function RepairVehiclesInRadius(centerCoords, radius)
    local vehicles = GetGamePool('CVehicle')
    local repaired = 0

    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(centerCoords - vehicleCoords)

        if distance <= radius then
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
            repaired += 1
        end
    end

    Utils.Debug('Repaired ' .. repaired .. ' vehicles within ' .. radius .. ' meters for player ' .. GetPlayerServerId(PlayerId()))
end
