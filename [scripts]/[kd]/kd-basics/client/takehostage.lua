-- ╔══════════════════════════════╗
-- ║        Take Hostage          ║
-- ╚══════════════════════════════╝
if not Config.Modules.TakeHostage then return end

local cfg = Config.TakeHostage

local state = {
    inProgress = false,
    type       = '',
    targetSrc  = -1,
}

local agrAnim = { dict = 'anim@gangops@hostage@', clip = 'perp_idle',   flag = 49 }
local hosAnim = {
    dict    = 'anim@gangops@hostage@',
    clip    = 'victim_idle',
    flag    = 49,
    attachX = -0.24,
    attachY =  0.11,
    attachZ =  0.0,
}

CreateThread(function()
    lib.requestAnimDict(agrAnim.dict)
    lib.requestAnimDict('reaction@shove')
end)

-- ─── Command ──────────────────────────────────────────────────────────────────

local function callTakeHostage()
    if state.inProgress then return end

    local ped = cache.ped
    ClearPedSecondaryTask(ped)
    DetachEntity(ped, true, false)

    local foundWeapon
    for _, hash in ipairs(cfg.allowedWeapons) do
        if HasPedGotWeapon(ped, hash, false) and GetAmmoInPedWeapon(ped, hash) > 0 then
            foundWeapon = hash
            break
        end
    end

    if not foundWeapon then
        lib.notify({ title = 'Take Hostage', description = 'You need a loaded pistol.', type = 'error' })
        return
    end

    local targetId, _, dist = lib.getClosestPlayer(GetEntityCoords(ped), 1.5, false)
    if not targetId or dist > 1.5 then
        lib.notify({ title = 'Take Hostage', description = 'No player nearby.', type = 'error' })
        return
    end

    if cfg.requireHandsUp then
        local targetPed = GetPlayerPed(targetId)
        if not IsEntityPlayingAnim(targetPed, 'random@mugging3', 'handsup_standing_base', 3) then
            lib.notify({ title = 'Take Hostage', description = 'They need to have their hands up.', type = 'error' })
            return
        end
    end

    SetCurrentPedWeapon(ped, foundWeapon, true)
    state.inProgress = true
    state.targetSrc  = GetPlayerServerId(targetId)
    state.type       = 'agressor'
    TriggerServerEvent('kd-basics:takehostage:sync', state.targetSrc)
end

RegisterCommand('th', callTakeHostage, false)

-- ─── Net events ───────────────────────────────────────────────────────────────

RegisterNetEvent('kd-basics:takehostage:syncTarget', function(agressorSrc)
    local agrPed = GetPlayerPed(GetPlayerFromServerId(agressorSrc))
    state.inProgress = true
    state.type       = 'hostage'
    AttachEntityToEntity(cache.ped, agrPed, 0, hosAnim.attachX, hosAnim.attachY, hosAnim.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
end)

RegisterNetEvent('kd-basics:takehostage:release', function()
    state.inProgress = false
    state.type       = ''
    state.targetSrc  = -1
    local ped = cache.ped
    DetachEntity(ped, true, false)
    TaskPlayAnim(ped, 'reaction@shove', 'shoved_back', 8.0, -8.0, -1, 0, 0, false, false, false)
    Wait(250)
    ClearPedSecondaryTask(ped)
end)

RegisterNetEvent('kd-basics:takehostage:kill', function()
    state.inProgress = false
    state.type       = ''
    state.targetSrc  = -1
    local ped = cache.ped
    DetachEntity(ped, true, false)
    SetEntityHealth(ped, 0)
    TaskPlayAnim(ped, agrAnim.dict, 'victim_fail', 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent('kd-basics:takehostage:stop', function()
    state.inProgress = false
    state.type       = ''
    state.targetSrc  = -1
    local ped = cache.ped
    ClearPedSecondaryTask(ped)
    DetachEntity(ped, true, false)
end)

-- ─── Control / animation loop ─────────────────────────────────────────────────
-- Wait(0) only when in progress — DisableControlAction must fire every frame

CreateThread(function()
    local textShowing = false

    while true do
        if state.inProgress then
            local ped   = cache.ped
            local isAgr = state.type == 'agressor'
            local dict  = isAgr and agrAnim.dict or hosAnim.dict
            local clip  = isAgr and agrAnim.clip or hosAnim.clip
            local flag  = isAgr and agrAnim.flag or hosAnim.flag

            if not IsEntityPlayingAnim(ped, dict, clip, 3) then
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, 100000, flag, 0, false, false, false)
            end

            if isAgr then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 58, true)
                DisableControlAction(0, 21, true)
                DisablePlayerFiring(cache.playerId, true)

                if not textShowing then
                    textShowing = true
                    lib.showTextUI('[G] Release  [H] Kill', { position = 'left-center', icon = 'hand-back-fist' })
                end

                local tSrc = state.targetSrc

                if IsEntityDead(ped) then
                    state.inProgress = false
                    state.type       = ''
                    state.targetSrc  = -1
                    textShowing      = false
                    lib.hideTextUI()
                    TaskPlayAnim(ped, 'reaction@shove', 'shove_var_a', 8.0, -8.0, -1, 168, 0, false, false, false)
                    TriggerServerEvent('kd-basics:takehostage:release', tSrc)
                elseif IsDisabledControlJustPressed(0, 47) then
                    state.inProgress = false
                    state.type       = ''
                    state.targetSrc  = -1
                    textShowing      = false
                    lib.hideTextUI()
                    TaskPlayAnim(ped, 'reaction@shove', 'shove_var_a', 8.0, -8.0, -1, 168, 0, false, false, false)
                    TriggerServerEvent('kd-basics:takehostage:release', tSrc)
                elseif IsDisabledControlJustPressed(0, 74) then
                    state.inProgress = false
                    state.type       = ''
                    state.targetSrc  = -1
                    textShowing      = false
                    lib.hideTextUI()
                    TaskPlayAnim(ped, agrAnim.dict, 'perp_fail', 8.0, -8.0, -1, 168, 0, false, false, false)
                    TriggerServerEvent('kd-basics:takehostage:kill', tSrc)
                end
            else
                DisableControlAction(0, 21,  true)
                DisableControlAction(0, 24,  true)
                DisableControlAction(0, 25,  true)
                DisableControlAction(0, 47,  true)
                DisableControlAction(0, 58,  true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 143, true)
                DisableControlAction(0, 75,  true)
                DisableControlAction(27, 75, true)
                DisableControlAction(0, 22,  true)
                DisableControlAction(0, 32,  true)
                DisableControlAction(0, 268, true)
                DisableControlAction(0, 33,  true)
                DisableControlAction(0, 269, true)
                DisableControlAction(0, 34,  true)
                DisableControlAction(0, 270, true)
                DisableControlAction(0, 35,  true)
                DisableControlAction(0, 271, true)
            end

            Wait(0)
        else
            if textShowing then
                textShowing = false
                lib.hideTextUI()
            end
            Wait(500)
        end
    end
end)
