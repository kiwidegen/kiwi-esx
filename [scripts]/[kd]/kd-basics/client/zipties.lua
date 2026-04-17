-- ╔══════════════════════════════╗
-- ║          Zipties             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Zipties then return end

local cfg  = Config.Zipties
local prop = nil

-- ─── Loose timer ──────────────────────────────────────────────────────────────
-- Generation counter ensures old timers silently expire if zipties removed early

local looseTimerGen = 0

local function startLooseTimer()
    if not cfg.enableLooseTimer then return end
    looseTimerGen = looseTimerGen + 1
    local gen = looseTimerGen
    CreateThread(function()
        Wait(cfg.looseTimer)
        if looseTimerGen == gen then
            lib.notify({ description = 'You feel the zipties slowly losing grip.', type = 'inform', position = 'center-right' })
            TriggerServerEvent('kd-basics:zipties:remove', GetPlayerServerId(PlayerId()))
        end
    end)
end

local function cancelLooseTimer()
    looseTimerGen = looseTimerGen + 1
end

-- ─── Prop ─────────────────────────────────────────────────────────────────────

local function addProp()
    lib.requestModel('hei_prop_zip_tie_positioned', 500)
    local ped    = cache.ped
    local coords = GetEntityCoords(ped)
    prop = CreateObject(joaat('hei_prop_zip_tie_positioned'), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 60309),
        -0.052249352753165, -0.049750459611295,  0.014318422211053,
        -72.882460219129,   -79.949307599006,    -2.1615025690178,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded('hei_prop_zip_tie_positioned')
end

-- ─── Ziptied loop ─────────────────────────────────────────────────────────────
-- Wait(0) only while ziptied — DisableControlAction must fire every frame

local function ziptieLoop()
    CreateThread(function()
        lib.requestAnimDict(cfg.idleAnim.dict, 500)
        while LocalPlayer.state.ziptied do
            local ped = cache.ped
            DisablePlayerFiring(ped, true)
            for _, control in ipairs(cfg.disabledControls) do
                DisableControlAction(0, control, true)
            end
            if not IsEntityPlayingAnim(ped, cfg.idleAnim.dict, cfg.idleAnim.name, 3) then
                TaskPlayAnim(ped, cfg.idleAnim.dict, cfg.idleAnim.name, 2.0, 2.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(0)
        end
    end)
end

-- ─── Apply / remove (called by ox_inventory item exports) ────────────────────

local function useZiptie()
    local targetId, _, dist = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.0, false)
    if not targetId or dist > 2.0 then
        lib.notify({ title = 'Zipties', description = 'Nobody nearby to ziptie.', type = 'error' })
        return
    end

    local isZipTied = lib.callback.await('kd-basics:zipties:checkZipTied', false, GetPlayerServerId(targetId))
    if isZipTied then
        lib.notify({ title = 'Zipties', description = 'Target is already restrained.', type = 'error' })
        return
    end

    TriggerServerEvent('kd-basics:zipties:apply', GetPlayerServerId(targetId))
    lib.progressCircle({
        label        = 'Restraining...',
        position     = 'bottom',
        duration     = cfg.applySpeed,
        useWhileDead = false,
        canCancel    = false,
        disable      = { move = true, combat = true },
        anim         = { dict = 'mp_arresting', clip = 'a_uncuff' },
    })
end

local function removeZiptie()
    local targetId, _, dist = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.0, false)
    if not targetId or dist > 2.0 then
        lib.notify({ title = 'Zipties', description = 'Nobody nearby to unziptie.', type = 'error' })
        return
    end

    local isZipTied = lib.callback.await('kd-basics:zipties:checkZipTied', false, GetPlayerServerId(targetId))
    if not isZipTied then
        lib.notify({ title = 'Zipties', description = 'Target is not restrained.', type = 'error' })
        return
    end

    if lib.progressCircle({
        label        = 'Cutting zipties...',
        position     = 'bottom',
        duration     = cfg.removeSpeed,
        useWhileDead = false,
        canCancel    = false,
        disable      = { move = true, combat = true },
        anim         = { dict = 'mp_arresting', clip = 'a_uncuff' },
        prop         = {
            model = 'prop_cs_scissors',
            pos   = { x = -0.025287743788795, y = -0.031117719230269, z = 0.024014968931296 },
            rot   = { x =  6.2230962714031,   y =  8.469599338023,    z = -46.429241988336  },
        },
    }) then
        TriggerServerEvent('kd-basics:zipties:remove', GetPlayerServerId(targetId))
    end
end

exports('useZipties',    useZiptie)
exports('removeZipties', removeZiptie)
exports('isZipTied',     function() return LocalPlayer.state.ziptied end)

-- ─── Net events ───────────────────────────────────────────────────────────────

RegisterNetEvent('kd-basics:zipties:apply', function()
    local ped = cache.ped
    if LocalPlayer.state.ziptied then return end

    LocalPlayer.state:set('ziptied', true, true)
    SetEnableHandcuffs(ped, true)
    DisablePlayerFiring(ped, true)
    SetCurrentPedWeapon(ped, joaat('WEAPON_UNARMED'), true)
    SetPedCanPlayGestureAnims(ped, false)
    DisplayRadar(false)

    if GetResourceState('pma-voice') == 'started' then
        exports['pma-voice']:setVoiceProperty('radioEnabled', false)
    end
    if GetResourceState('lb-phone') == 'started' then
        exports['lb-phone']:ToggleDisabled(true)
    end

    addProp()
    startLooseTimer()
    if cfg.enableIdleAnim then ziptieLoop() end

    lib.notify({ title = 'Zipties', description = 'You have been restrained.', type = 'error' })
end)

RegisterNetEvent('kd-basics:zipties:remove', function()
    local ped = cache.ped
    if not LocalPlayer.state.ziptied then return end

    LocalPlayer.state:set('ziptied', false, true)
    SetEnableHandcuffs(ped, false)
    DisablePlayerFiring(ped, false)
    SetPedCanPlayGestureAnims(ped, true)
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    DisplayRadar(true)

    if DoesEntityExist(prop) then DeleteEntity(prop) end
    prop = nil

    cancelLooseTimer()

    if GetResourceState('pma-voice') == 'started' then
        exports['pma-voice']:setVoiceProperty('radioEnabled', true)
    end
    if GetResourceState('lb-phone') == 'started' then
        exports['lb-phone']:ToggleDisabled(false)
    end

    lib.notify({ title = 'Zipties', description = 'You have been freed.', type = 'success' })
end)
