-- ╔══════════════════════════════╗
-- ║            Trunk             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Trunk then return end

local inTrunk       = false
local trunkVeh      = nil
local exitRequested = false

-- ─── Enter ───────────────────────────────────────────────────────────────────

local function getInTrunk(vehicle)
    local playerPed = cache.ped

    if Entity(vehicle).state.trunkOccupied then
        lib.notify({ title = 'Trunk', description = 'There is already someone in the trunk.', type = 'error' })
        return
    end

    lib.requestAnimDict('timetable@floyd@cryingonbed@base', 5000)

    SetCarBootOpen(vehicle)
    Wait(150)
    AttachEntityToEntity(playerPed, vehicle, -1, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
    TaskPlayAnim(playerPed, 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)

    trunkVeh = vehicle
    inTrunk  = true

    lib.showTextUI('[X] Exit trunk', { position = 'left-center' })

    Entity(vehicle).state:set('trunkOccupied', true, true)

    Wait(600)
    SetVehicleDoorShut(vehicle, 5)
end

-- ─── Main loop ───────────────────────────────────────────────────────────────
-- Wait(200) — no per-frame natives needed, visibility/anim checks are low-freq

CreateThread(function()
    while true do
        if inTrunk then
            local playerPed = cache.ped
            local vehicle   = trunkVeh

            if not DoesEntityExist(vehicle) or IsPedDeadOrDying(playerPed) or IsPedFatallyInjured(playerPed) then
                -- force eject
                SetEntityCollision(playerPed, true, true)
                DetachEntity(playerPed, true, true)
                SetEntityVisible(playerPed, true, false)
                ClearPedTasksImmediately(playerPed)
                lib.hideTextUI()
                inTrunk  = false
                trunkVeh = nil
            else
                SetEntityCollision(playerPed, false, false)

                if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                    SetEntityVisible(playerPed, false, false)
                else
                    SetEntityVisible(playerPed, true, false)
                    if not IsEntityPlayingAnim(playerPed, 'timetable@floyd@cryingonbed@base', 'base', 3) then
                        TaskPlayAnim(playerPed, 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                    end
                end

                if exitRequested then
                    exitRequested = false
                    SetCarBootOpen(vehicle)
                    SetEntityCollision(playerPed, true, true)
                    Wait(300)
                    inTrunk  = false
                    trunkVeh = nil
                    DetachEntity(playerPed, true, true)
                    SetEntityVisible(playerPed, true, false)
                    ClearPedTasksImmediately(playerPed)
                    SetEntityCoords(playerPed, GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -0.5, -0.75))
                    lib.hideTextUI()
                    Wait(150)
                    if DoesEntityExist(vehicle) then
                        SetVehicleDoorShut(vehicle, 5)
                        Entity(vehicle).state:set('trunkOccupied', false, true)
                    end
                end
            end

            Wait(200)
        else
            Wait(500)
        end
    end
end)

-- ─── Exit keybind ────────────────────────────────────────────────────────────

lib.addKeybind({
    name        = 'trunkExit',
    description = 'Exit vehicle trunk',
    defaultKey  = 'x',
    onPressed   = function()
        if inTrunk then exitRequested = true end
    end,
})

-- ─── ox_target ───────────────────────────────────────────────────────────────

exports.ox_target:addGlobalVehicle({
    {
        name  = 'kd-trunk-enter',
        icon  = 'fa-solid fa-car-rear',
        label = 'Get in Trunk',
        bones = 'boot',
        canInteract = function(entity, distance, coords, name, boneId)
            if GetVehicleDoorLockStatus(entity) > 1 then return end
            if IsVehicleDoorDamaged(entity, 5) then return end
            return #(coords - GetEntityBonePosition_2(entity, boneId)) < 0.9
        end,
        onSelect = function(data)
            CreateThread(function() getInTrunk(data.entity) end)
        end,
    },
})

-- ─── Cleanup ─────────────────────────────────────────────────────────────────

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if inTrunk then
        local playerPed = cache.ped
        SetEntityCollision(playerPed, true, true)
        DetachEntity(playerPed, true, true)
        SetEntityVisible(playerPed, true, false)
        ClearPedTasksImmediately(playerPed)
        lib.hideTextUI()
        if trunkVeh and DoesEntityExist(trunkVeh) then
            Entity(trunkVeh).state:set('trunkOccupied', false, true)
        end
    end
end)
