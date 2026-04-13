---@diagnostic disable: missing-parameter, param-type-mismatch

ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}
local playerState = LocalPlayer.state

---@class CarryState
---@field isCarrying boolean Whether player is carrying someone
---@field isBeingCarried boolean Whether player is being carried
---@field carriedBy number? Server ID of person carrying
---@field carryingType 'carry'|'drag'|nil Type of carry

local carryState = {
    isCarrying = false,
    isBeingCarried = false,
    carriedBy = nil,
    carryingType = nil
}

local cache = {
    ped = PlayerPedId(),
    serverId = GetPlayerServerId(PlayerId())
}

-- Exports for other scripts
exports('IsCarrying', function() return carryState.isCarrying end)
exports('IsBeingCarried', function() return carryState.isBeingCarried end)

---@param key string
---@param val any
RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('esx:playerPedChanged', function(newPed)
    cache.ped = newPed
end)

--- Check if player can interact (not dead, not in inventory, etc)
---@return boolean canInteract
local function canPlayerInteract()
    return not playerState.invBusy
        and not IsPedDeadOrDying(cache.ped, true)
        and not IsPedInAnyVehicle(cache.ped, false)
        and not carryState.isCarrying
        and not carryState.isBeingCarried
end

--- Check if target can be carried
---@param targetPed number Target ped handle
---@return boolean canCarry
local function canCarryTarget(targetPed)
    if not DoesEntityExist(targetPed) then return false end
    if targetPed == cache.ped then return false end

    local isDead = IsPedDeadOrDying(targetPed, true)
    local isCuffed = IsPedCuffed(targetPed)
    local isInVehicle = IsPedInAnyVehicle(targetPed, false)

    -- Can carry if: dead, cuffed, or unconscious (not in vehicle for carry)
    return (isDead or isCuffed) and not isInVehicle
end

--- Check if target can be dragged
---@param targetPed number Target ped handle
---@return boolean canDrag
local function canDragTarget(targetPed)
    if not DoesEntityExist(targetPed) then return false end
    if targetPed == cache.ped then return false end

    local isDead = IsPedDeadOrDying(targetPed, true)
    local isCuffed = IsPedCuffed(targetPed)

    -- Can drag if: dead or cuffed (can be in vehicle)
    return isDead or isCuffed
end

--- Load animation dictionary
---@param dict string Animation dictionary
local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

--- Start carrying animation
local function startCarryAnimation()
    loadAnimDict('missfinale_c2mcs_1')
    TaskPlayAnim(cache.ped, 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, -1, 49, 0, false, false, false)
end

--- Start being carried animation
---@param carrierPed number Ped carrying the player
local function startBeingCarriedAnimation(carrierPed)
    loadAnimDict('nm')

    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
    end

    AttachEntityToEntity(
        cache.ped,
        carrierPed,
        GetPedBoneIndex(carrierPed, 40269), -- Spine bone
        -0.1, 0.0, 0.1,
        25.0, -290.0, -150.0,
        true, true, false, true, 1, true
    )

    TaskPlayAnim(cache.ped, 'nm', 'firemans_carry', 8.0, -8.0, -1, 1, 0, false, false, false)
end

--- Start dragging animation
local function startDragAnimation()
    loadAnimDict('amb@world_human_bum_slumped@male@laying_on_left_side@base')
    TaskPlayAnim(cache.ped, 'amb@world_human_bum_slumped@male@laying_on_left_side@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
end

--- Start being dragged by another player
---@param draggerPed number Ped dragging the player
local function startBeingDraggedAnimation(draggerPed)
    loadAnimDict('amb@world_human_bum_slumped@male@laying_on_left_side@base')

    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
    end

    AttachEntityToEntity(
        cache.ped,
        draggerPed,
        GetPedBoneIndex(draggerPed, 0x8b93), -- Hand bone
        0.5, 0.0, 0.0,
        0.0, 0.0, 0.0,
        true, true, false, true, 1, true
    )

    TaskPlayAnim(cache.ped, 'amb@world_human_bum_slumped@male@laying_on_left_side@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
end

--- Stop carry/drag animations and detach
local function stopCarryDrag()
    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
    end

    ClearPedTasksImmediately(cache.ped)

    carryState.isCarrying = false
    carryState.isBeingCarried = false
    carryState.carriedBy = nil
    carryState.carryingType = nil
end

--- Handle carry/drag controls while being carried
local function handleBeingCarriedControls()
    CreateThread(function()
        while carryState.isBeingCarried do
            Wait(0)

            -- Disable controls
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 23, true) -- Enter Vehicle

            -- Allow self-release if not carried by police
            if carryState.carriedBy then
                local carrierPlayer = GetPlayerFromServerId(carryState.carriedBy)
                if carrierPlayer and carrierPlayer ~= -1 then
                    -- Check if carrier is police
                    TriggerServerEvent('drp-carry:checkPoliceCarry', carryState.carriedBy)

                    -- Show help text for non-police carries
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName('Press ~INPUT_CONTEXT~ to break free')
                    EndTextCommandDisplayHelp(0, false, true, -1)

                    -- Check for break free input
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent('drp-carry:breakFree')
                    end
                end
            end
        end
    end)
end

--- Handle carry/drag controls while carrying
local function handleCarryingControls()
    CreateThread(function()
        while carryState.isCarrying do
            Wait(0)

            -- Disable combat and vehicle controls
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 23, true) -- Enter Vehicle
            DisableControlAction(0, 75, true) -- Exit Vehicle
        end
    end)
end

--- Start carrying a player
---@param targetServerId number Target player's server ID
local function startCarry(targetServerId)
    if not canPlayerInteract() then return end

    TriggerServerEvent('drp-carry:requestCarry', targetServerId, 'carry')
end

--- Start dragging a player
---@param targetServerId number Target player's server ID
local function startDrag(targetServerId)
    if not canPlayerInteract() then return end

    TriggerServerEvent('drp-carry:requestCarry', targetServerId, 'drag')
end

--- Stop carrying/dragging
local function stopCarry()
    TriggerServerEvent('drp-carry:stopCarry')
end

--- Pull player from vehicle
---@param targetServerId number Target player's server ID
local function pullFromVehicle(targetServerId)
    if not canPlayerInteract() then return end

    TriggerServerEvent('drp-carry:pullFromVehicle', targetServerId)
end

--- Place player in vehicle
---@param targetServerId number Target player's server ID
---@param seat number Vehicle seat (-1 to 2)
local function placeInVehicle(targetServerId, seat)
    if not carryState.isCarrying then
        lib.notify({
            description = 'You are not carrying anyone',
            type = 'error'
        })
        return
    end

    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 5.0, false)

    if not vehicle then
        lib.notify({
            description = 'No vehicle nearby',
            type = 'error'
        })
        return
    end

    TriggerServerEvent('drp-carry:placeInVehicle', targetServerId, VehToNet(vehicle), seat)
end

--- Open vehicle seat selection menu
---@param targetServerId number Target player's server ID
local function openSeatSelectionMenu(targetServerId)
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 5.0, false)

    if not vehicle then
        lib.notify({
            description = 'No vehicle nearby',
            type = 'error'
        })
        return
    end

    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    local options = {}

    -- Driver seat
    if IsVehicleSeatFree(vehicle, -1) then
        options[#options + 1] = {
            title = 'Driver Seat',
            icon = 'fa-solid fa-steering-wheel',
            onSelect = function()
                placeInVehicle(targetServerId, -1)
            end
        }
    end

    -- Passenger seats
    for i = 0, maxSeats - 1 do
        if IsVehicleSeatFree(vehicle, i) then
            options[#options + 1] = {
                title = 'Passenger Seat ' .. (i + 1),
                icon = 'fa-solid fa-chair',
                onSelect = function()
                    placeInVehicle(targetServerId, i)
                end
            }
        end
    end

    if #options == 0 then
        lib.notify({
            description = 'No available seats',
            type = 'error'
        })
        return
    end

    lib.registerContext({
        id = 'drp_carry_seat_menu',
        title = 'Select Seat',
        options = options
    })

    lib.showContext('drp_carry_seat_menu')
end

-- Network Events
RegisterNetEvent('drp-carry:syncCarry', function(carrierServerId, targetServerId, carryType)
    local carrierPlayer = GetPlayerFromServerId(carrierServerId)
    local targetPlayer = GetPlayerFromServerId(targetServerId)

    if carrierPlayer == -1 or targetPlayer == -1 then return end

    local carrierPed = GetPlayerPed(carrierPlayer)
    local targetPed = GetPlayerPed(targetPlayer)

    if cache.serverId == carrierServerId then
        -- I'm the carrier
        carryState.isCarrying = true
        carryState.carryingType = carryType

        if carryType == 'carry' then
            startCarryAnimation()
        elseif carryType == 'drag' then
            startDragAnimation()
        end

        handleCarryingControls()

    elseif cache.serverId == targetServerId then
        -- I'm being carried
        carryState.isBeingCarried = true
        carryState.carriedBy = carrierServerId
        carryState.carryingType = carryType

        if carryType == 'carry' then
            startBeingCarriedAnimation(carrierPed)
        elseif carryType == 'drag' then
            startBeingDraggedAnimation(carrierPed)
        end

        handleBeingCarriedControls()
    end
end)

RegisterNetEvent('drp-carry:syncStop', function(carrierServerId, targetServerId)
    if cache.serverId == carrierServerId or cache.serverId == targetServerId then
        stopCarryDrag()
    end
end)

RegisterNetEvent('drp-carry:syncPullFromVehicle', function(targetServerId)
    if cache.serverId == targetServerId then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        if vehicle ~= 0 then
            TaskLeaveVehicle(cache.ped, vehicle, 16)
        end
    end
end)

RegisterNetEvent('drp-carry:syncPlaceInVehicle', function(targetServerId, vehicleNet, seat)
    if cache.serverId == targetServerId then
        local vehicle = NetToVeh(vehicleNet)
        if DoesEntityExist(vehicle) then
            TaskWarpPedIntoVehicle(cache.ped, vehicle, seat)
        end
    end

    -- Stop carry for carrier
    if carryState.isCarrying then
        stopCarryDrag()
    end
end)

RegisterNetEvent('drp-carry:allowBreakFree', function(allowed)
    if not allowed and IsControlJustPressed(0, 38) then
        lib.notify({
            description = 'You cannot break free from police escort',
            type = 'error'
        })
    end
end)

-- ox_target Setup
CreateThread(function()
    -- Carry/Drag Players
    exports.ox_target:addGlobalPlayer({
        {
            name = 'drp_carry_player',
            icon = 'fa-solid fa-hands-holding',
            label = 'Carry',
            distance = 2.0,
            canInteract = function(entity, distance, coords, name, bone)
                return canPlayerInteract() and canCarryTarget(entity)
            end,
            onSelect = function(data)
                local targetPlayer = NetworkGetPlayerIndexFromPed(data.entity)
                if targetPlayer ~= -1 then
                    startCarry(GetPlayerServerId(targetPlayer))
                end
            end
        },
        {
            name = 'drp_drag_player',
            icon = 'fa-solid fa-person-walking',
            label = 'Drag',
            distance = 2.0,
            canInteract = function(entity, distance, coords, name, bone)
                return canPlayerInteract() and canDragTarget(entity)
            end,
            onSelect = function(data)
                local targetPlayer = NetworkGetPlayerIndexFromPed(data.entity)
                if targetPlayer ~= -1 then
                    startDrag(GetPlayerServerId(targetPlayer))
                end
            end
        },
        {
            name = 'drp_stop_carry',
            icon = 'fa-solid fa-hand',
            label = 'Release',
            distance = 2.0,
            canInteract = function(entity, distance, coords, name, bone)
                if not carryState.isCarrying then return false end
                local targetPlayer = NetworkGetPlayerIndexFromPed(entity)
                return targetPlayer ~= -1 and IsEntityAttachedToEntity(entity, cache.ped)
            end,
            onSelect = function(data)
                stopCarry()
            end
        },
        {
            name = 'drp_place_in_vehicle',
            icon = 'fa-solid fa-car',
            label = 'Place in Vehicle',
            distance = 2.0,
            canInteract = function(entity, distance, coords, name, bone)
                if not carryState.isCarrying then return false end
                local targetPlayer = NetworkGetPlayerIndexFromPed(entity)
                if targetPlayer == -1 then return false end

                local vehicleCoords = GetEntityCoords(cache.ped)
                local vehicle = lib.getClosestVehicle(vehicleCoords, 5.0, false)

                return vehicle ~= nil and IsEntityAttachedToEntity(entity, cache.ped)
            end,
            onSelect = function(data)
                local targetPlayer = NetworkGetPlayerIndexFromPed(data.entity)
                if targetPlayer ~= -1 then
                    openSeatSelectionMenu(GetPlayerServerId(targetPlayer))
                end
            end
        },
        {
            name = 'drp_pull_from_vehicle',
            icon = 'fa-solid fa-person-walking-arrow-right',
            label = 'Pull from Vehicle',
            distance = 3.0,
            canInteract = function(entity, distance, coords, name, bone)
                if not canPlayerInteract() then return false end
                if not IsPedInAnyVehicle(entity, false) then return false end
                return canDragTarget(entity)
            end,
            onSelect = function(data)
                local targetPlayer = NetworkGetPlayerIndexFromPed(data.entity)
                if targetPlayer ~= -1 then
                    pullFromVehicle(GetPlayerServerId(targetPlayer))
                end
            end
        }
    })
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    stopCarryDrag()
end)
