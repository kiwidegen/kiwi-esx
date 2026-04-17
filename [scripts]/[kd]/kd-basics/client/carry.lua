-- ╔══════════════════════════════╗
-- ║           Carry              ║
-- ╚══════════════════════════════╝
if not Config.Modules.Carry then return end

local carrying    = false  -- local player id of who we are carrying
local beingCarried = false -- ped entity of our carrier

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function stopCarrying()
    if not carrying then return end
    TriggerServerEvent('kd-basics:server:stopCarrying', GetPlayerServerId(carrying))
    carrying = false
end

local function stopBeingCarried()
    beingCarried = false
    DetachEntity(cache.ped, true, false)
    ClearPedTasksImmediately(cache.ped)
end

-- ─── Carrying loop ───────────────────────────────────────────────────────────

local function startCarryingLoop()
    local cfg = Config.Carry.carrying
    loadAnim(cfg.dict)

    -- Wait(0) required — DisableControlAction must fire every frame
    CreateThread(function()
        local nextAnim = 0

        while carrying and DoesEntityExist(GetPlayerPed(carrying)) do
            if GetGameTimer() >= nextAnim and not IsEntityPlayingAnim(cache.ped, cfg.dict, cfg.anim, 3) then
                TaskPlayAnim(cache.ped, cfg.dict, cfg.anim, 8.0, -8.0, 100000, cfg.flag, false, false, false)
                nextAnim = GetGameTimer() + 1000
            end

            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 24,  true) -- attack
            DisableControlAction(0, 257, true) -- attack 2
            DisableControlAction(0, 263, true) -- melee
            DisableControlAction(0, 25,  true) -- aim
            DisableControlAction(0, 323, true) -- hands up
            DisableControlAction(0, 22,  true) -- jump

            if IsPedDeadOrDying(cache.ped) then
                stopCarrying()
                break
            end

            Wait(0)
        end

        -- carrier walked out of range or target disappeared
        if carrying then
            carrying = false
            ClearPedTasksImmediately(cache.ped)
        end
    end)
end

-- ─── Being carried loop ──────────────────────────────────────────────────────

local function startBeingCarriedLoop()
    local cfg = Config.Carry.carried
    loadAnim(cfg.dict)

    -- Wait(0) required — DisableControlAction must fire every frame
    CreateThread(function()
        local nextAnim = 0

        while beingCarried and DoesEntityExist(beingCarried) do
            if GetGameTimer() >= nextAnim then
                if not IsPedDeadOrDying(cache.ped) then
                    if not IsEntityPlayingAnim(cache.ped, cfg.dict, cfg.anim, 3) then
                        TaskPlayAnim(cache.ped, cfg.dict, cfg.anim, 8.0, -8.0, 100000, cfg.flag, false, false, false)
                    end
                    if not IsEntityAttachedToEntity(cache.ped, beingCarried) then
                        AttachEntityToEntity(cache.ped, beingCarried, 0, cfg.offset, 0.5, 0.5, 180, false, false, false, false, 2, false)
                    end
                else
                    ClearPedTasksImmediately(cache.ped)
                end
                nextAnim = GetGameTimer() + 1000
            end

            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 21,  true) -- sprint
            DisableControlAction(0, 24,  true) -- attack
            DisableControlAction(0, 257, true) -- attack 2
            DisableControlAction(0, 263, true) -- melee
            DisableControlAction(0, 25,  true) -- aim
            DisableControlAction(0, 323, true) -- hands up
            DisableControlAction(0, 22,  true) -- jump

            Wait(0)
        end

        if beingCarried then
            stopBeingCarried()
        end
    end)
end

-- ─── /carry command ──────────────────────────────────────────────────────────

RegisterCommand('carry', function()
    -- if being carried, try to wiggle free
    if beingCarried then
        local carrierServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(beingCarried))
        TriggerServerEvent('kd-basics:server:stopCarrying', carrierServerId)
        stopBeingCarried()
        return
    end

    -- if already carrying, put them down
    if carrying then
        stopCarrying()
        return
    end

    -- find nearest player
    local myCoords          = GetEntityCoords(cache.ped)
    local targetId, _, dist = lib.getClosestPlayer(myCoords, Config.Carry.range, false)

    if not targetId or dist > Config.Carry.range then
        lib.notify({ title = 'Carry', description = 'Nobody nearby to carry.', type = 'error' })
        return
    end

    carrying = targetId
    TriggerServerEvent('kd-basics:server:requestCarry', GetPlayerServerId(targetId))
end, false)

-- ─── Net events (client) ─────────────────────────────────────────────────────

-- target accepted — start carrying them
RegisterNetEvent('kd-basics:client:getCarried', function(carrierSrc)
    local carrierPed = GetPlayerPed(GetPlayerFromServerId(carrierSrc))
    if not carrierPed or not DoesEntityExist(carrierPed) then return end
    beingCarried = carrierPed
    startBeingCarriedLoop()
end)

-- carrier gets a confirm dialog when target accepts
RegisterNetEvent('kd-basics:client:carryConfirm', function(carrierSrc)
    local ok = lib.alertDialog({
        header  = 'Carry Request',
        content = 'Someone wants to carry you. Accept?',
        labels  = { confirm = 'Yes', cancel = 'No' },
        centered = true,
        cancel   = true,
        size     = 'md',
    })

    if ok == 'confirm' then
        TriggerServerEvent('kd-basics:server:acceptCarry', carrierSrc)
    else
        TriggerServerEvent('kd-basics:server:denyCarry', carrierSrc)
    end
end)

-- carrier was denied
RegisterNetEvent('kd-basics:client:carryDenied', function()
    carrying = false
    ClearPedTasksImmediately(cache.ped)
    lib.notify({ title = 'Carry', description = 'They refused to be carried.', type = 'error' })
end)

-- someone stopped carrying us
RegisterNetEvent('kd-basics:client:stopBeingCarried', function()
    stopBeingCarried()
end)

-- we stopped carrying someone (server confirmed)
RegisterNetEvent('kd-basics:client:stopCarrying', function()
    carrying = false
    DetachEntity(cache.ped, true, false)
    ClearPedTasksImmediately(cache.ped)
end)

-- carrier accepted target and should start the loop
RegisterNetEvent('kd-basics:client:beginCarrying', function()
    startCarryingLoop()
end)
