-- ╔══════════════════════════════╗
-- ║         Repair Kit           ║
-- ╚══════════════════════════════╝
if not Config.Modules.RepairKit then return end

local cfg = Config.Repair

-- ─── Basic — engine + tyres ──────────────────────────────────────────────────

local function doBasicRepair(vehicle)
    if lib.progressCircle({
        duration     = 10000,
        position     = 'bottom',
        label        = 'Repairing engine...',
        useWhileDead = false,
        canCancel    = true,
        disable      = { move = true, combat = true },
        anim         = { dict = 'mini@repair', clip = 'fixing_a_player' },
    }) then
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineHealth(vehicle, cfg.basicRepairEngine)
        SetVehiclePetrolTankHealth(vehicle, cfg.basicRepairPetrolTank)
        SetVehicleEngineOn(vehicle, true, false)

        for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
            SetVehicleTyreFixed(vehicle, i)
        end

        ClearPedTasksImmediately(cache.ped)
        TriggerEvent('kd-basics:resetRepairState', cfg.basicRepairEngine, cfg.basicRepairPetrolTank, GetVehicleBodyHealth(vehicle))
        TriggerServerEvent('kd-basics:server:removeRepairKit', 'repairkit')
        lib.notify({ title = 'Repair Kit', description = 'Engine and tyres patched up.', type = 'success' })
    else
        lib.notify({ title = 'Repair Kit', description = 'Repair cancelled.', type = 'error' })
    end
end

-- ─── Advanced — engine + tyres + body ────────────────────────────────────────

local function doAdvRepair(vehicle)
    if lib.progressCircle({
        duration     = 15000,
        position     = 'bottom',
        label        = 'Fully repairing vehicle...',
        useWhileDead = false,
        canCancel    = true,
        disable      = { move = true, combat = true },
        anim         = { dict = 'mini@repair', clip = 'fixing_a_player' },
    }) then
        SetVehicleFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleEngineOn(vehicle, true, false)

        ClearPedTasksImmediately(cache.ped)
        TriggerEvent('kd-basics:resetRepairState', 1000.0, 1000.0, 1000.0)
        TriggerServerEvent('kd-basics:server:removeRepairKit', 'adv_repairkit')
        lib.notify({ title = 'Repair Kit', description = 'Vehicle fully repaired.', type = 'success' })
    else
        lib.notify({ title = 'Repair Kit', description = 'Repair cancelled.', type = 'error' })
    end
end

-- ─── Item exports (called by ox_inventory) ───────────────────────────────────

exports('useRepairKit', function()
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
    if not vehicle then
        lib.notify({ title = 'Repair Kit', description = 'No vehicle nearby.', type = 'error' })
        return
    end
    CreateThread(function() doBasicRepair(vehicle) end)
end)

exports('useAdvRepairKit', function()
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
    if not vehicle then
        lib.notify({ title = 'Repair Kit', description = 'No vehicle nearby.', type = 'error' })
        return
    end
    CreateThread(function() doAdvRepair(vehicle) end)
end)

-- ─── ox_target — bonnet bone ──────────────────────────────────────────────────

exports.ox_target:addGlobalVehicle({
    {
        name  = 'kd-repairkit',
        icon  = 'fas fa-wrench',
        label = 'Repair Vehicle',
        bones = 'bonnet',
        canInteract = function(entity)
            if GetVehicleClass(entity) == 21 then return false end
            return exports.ox_inventory:Search('count', 'adv_repairkit') > 0
                or exports.ox_inventory:Search('count', 'repairkit') > 0
        end,
        onSelect = function(data)
            if exports.ox_inventory:Search('count', 'adv_repairkit') > 0 then
                CreateThread(function() doAdvRepair(data.entity) end)
            else
                CreateThread(function() doBasicRepair(data.entity) end)
            end
        end,
    },
})
