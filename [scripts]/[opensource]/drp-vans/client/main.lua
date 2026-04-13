-- client/main.lua - 3D timer, contested/empty pauses, no NUI, no red blip
-- Ultra-lean: adaptive proximity cadence + delta-only server heartbeats

local ESX = ESX
CreateThread(function()
    while not ESX do
        local ok, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
        if ok and obj then ESX = obj end
        Wait(50)
    end
end)

-- ========= state =========
local state = {
    active   = false,
    netId    = nil,
    veh      = nil,
    pos      = nil,
    smoke    = nil,
    flare    = nil,
    found    = false,

    myAlive  = true,
    myLock   = false,

    timer = { seconds = 0, required = 0, ticking = false, label = nil },

    _visible = false
}

-- ---- perf locals ----
local GetEntityCoords, NetworkGetEntityFromNetworkId, PlayerPedId = GetEntityCoords, NetworkGetEntityFromNetworkId, PlayerPedId
local IsEntityDead, IsPedFatallyInjured, IsPedDeadOrDying, IsPedInAnyVehicle = IsEntityDead, IsPedFatallyInjured, IsPedDeadOrDying, IsPedInAnyVehicle
local World3dToScreen2d, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, EndTextCommandDisplayText =
      World3dToScreen2d, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, EndTextCommandDisplayText
local SetTextScale, SetTextFont, SetTextProportional, SetTextCentre, SetTextColour =
      SetTextScale, SetTextFont, SetTextProportional, SetTextCentre, SetTextColour
local GetOffsetFromEntityInWorldCoords, DoesEntityExist = GetOffsetFromEntityInWorldCoords, DoesEntityExist
local StartNetworkedParticleFxLoopedOnEntity, UseParticleFxAssetNextCall, RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, SetParticleFxLoopedColour =
      StartNetworkedParticleFxLoopedOnEntity, UseParticleFxAssetNextCall, RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, SetParticleFxLoopedColour
local DoesParticleFxLoopedExist, StopParticleFxLooped, AttachEntityToEntity, CreateObject =
      DoesParticleFxLoopedExist, StopParticleFxLooped, AttachEntityToEntity, CreateObject
local joaat, CreateVehicle, SetEntityAsMissionEntity, SetVehicleNeedsToBeHotwired, SetVehicleOnGroundProperly, SetEntityHeading =
      joaat, CreateVehicle, SetEntityAsMissionEntity, SetVehicleNeedsToBeHotwired, SetVehicleOnGroundProperly, SetEntityHeading
local NetworkGetNetworkIdFromEntity, SetNetworkIdCanMigrate, SetNetworkIdExistsOnAllMachines =
      NetworkGetNetworkIdFromEntity, SetNetworkIdCanMigrate, SetNetworkIdExistsOnAllMachines
local FreezeEntityPosition, SetEntityInvincible, SetEntityCanBeDamaged, SetVehicleCanBreak, SetVehicleTyresCanBurst, SetVehicleDoorsLockedForAllPlayers, SetVehicleDoorsLocked, SetVehicleUndriveable =
      FreezeEntityPosition, SetEntityInvincible, SetEntityCanBeDamaged, SetVehicleCanBreak, SetVehicleTyresCanBurst, SetVehicleDoorsLockedForAllPlayers, SetVehicleDoorsLocked, SetVehicleUndriveable

-- ========= helpers =========
local function isAlive()
    local ped = PlayerPedId()
    return not (IsEntityDead(ped) or IsPedFatallyInjured(ped) or IsPedDeadOrDying(ped, true))
end

local function isOnFoot()
    return not IsPedInAnyVehicle(PlayerPedId(), false)
end

local function getESXPlayerData()
    if ESX and ESX.PlayerLoaded then return ESX.PlayerData end
    return nil
end

local function getTeamId()
    local pd = getESXPlayerData()
    if pd then
        local job2 = pd.job2
        if job2 and job2.name and job2.name ~= '' and job2.name ~= 'unemployed' then
            return ('gang:%s'):format(job2.name)
        end
        local job = pd.job
        if job and job.name and job.name ~= '' then
            return ('job:%s'):format(job.name)
        end
    end
    local lp = LocalPlayer and LocalPlayer.state and LocalPlayer.state.PlayerData
    if lp then
        local gang = (lp.gang and lp.gang.name) or nil
        if gang and gang ~= '' then return ('gang:%s'):format(gang) end
        local job = (lp.job and lp.job.name) or nil
        if job and job ~= '' then return ('job:%s'):format(job) end
    end
    return ('player:%d'):format(GetPlayerServerId(PlayerId()))
end

-- ========= visuals (gated) =========
local function ensureRedSmoke(entity)
    if Config and VansConfig.Visuals and VansConfig.Visuals.Smoke == false then return end
    if state.smoke and DoesParticleFxLoopedExist(state.smoke) then return end
    local dict = 'core'; RequestNamedPtfxAsset(dict); while not HasNamedPtfxAssetLoaded(dict) do Wait(0) end
    UseParticleFxAssetNextCall(dict)
    local handle = StartNetworkedParticleFxLoopedOnEntity('exp_grd_flare', entity, 0.0, -2.0, -1.2, 0.0, 0.0, 0.0, 1.6, false, false, false)
    if handle then
        SetParticleFxLoopedColour(handle, 1.0, 0.0, 0.0, false)
        state.smoke = handle
    end
end

local function ensureFlare(entity)
    if state.flare and DoesEntityExist(state.flare) then return end
    local model = joaat('prop_flare_01')
    if lib.requestModel then lib.requestModel(model, 5000) end
    local c = GetEntityCoords(entity)
    local obj = CreateObject(model, c.x, c.y, c.z - 1.0, true, false, false)
    if obj and DoesEntityExist(obj) then
        AttachEntityToEntity(obj, entity, 0, 0.0, -2.0, -1.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
        state.flare = obj
    end
end

-- ========= 3D timer draw (0 while not visible) =========
local TIMER_VISIBLE_RANGE = (Config and VansConfig.TimerVisibleRange) or 5.0
local RANGE2              = TIMER_VISIBLE_RANGE * TIMER_VISIBLE_RANGE
local DRAW_OFFSET         = vector3(0.0, -2.0, 1.0)
local FONT                = 4
local BASE_SCALE          = 0.52

local function draw3dTextAt(coords, text, scale)
    local on, sx, sy = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not on then return end
    SetTextScale(scale, scale)
    SetTextFont(FONT)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 235)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(sx, sy)
end

local lastBase, nextProbeMs, lastRem, lastLabel = nil, 0, -1, '00:00'

CreateThread(function()
    while true do
        local sleep = 250
        if state.active and state.veh and DoesEntityExist(state.veh) and state.found then
            local now = GetGameTimer()
            if now >= (nextProbeMs or 0) then
                lastBase = GetOffsetFromEntityInWorldCoords(state.veh, DRAW_OFFSET.x, DRAW_OFFSET.y, DRAW_OFFSET.z)
                local me = GetEntityCoords(PlayerPedId())
                local dx, dy, dz = me.x - lastBase.x, me.y - lastBase.y, me.z - lastBase.z
                state._visible = (dx*dx + dy*dy + dz*dz) <= RANGE2
                nextProbeMs = now + 250
            end
            if state._visible then
                local rem = state.timer.required > state.timer.seconds and (state.timer.required - state.timer.seconds) or 0
                if rem ~= lastRem then
                    local mm, ss = (rem // 60), (rem % 60)
                    lastLabel = (mm < 10 and '0'..mm or tostring(mm)) .. ':' .. (ss < 10 and '0'..ss or tostring(ss))
                    lastRem = rem
                end
                draw3dTextAt(lastBase, lastLabel, BASE_SCALE)
                sleep = 0
            end
        end
        Wait(sleep)
    end
end)

-- ========= proximity heartbeat (adaptive + delta-only net) =========
local lastNear, lastDisc, lastLock, lastAlive, lastTeam = false, false, false, true, nil
local lastSend = 0

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local my  = GetEntityCoords(ped)

        local alive = isAlive()
        local onFoot = isOnFoot()

        local near, disc, lock = false, false, false

        local function ranges(origin)
            local dx, dy, dz = my.x - origin.x, my.y - origin.y, my.z - origin.z
            local d2 = dx*dx + dy*dy + dz*dz
            local ctrlR = (Config and (VansConfig.ControlCheckRange or 60.0)) or 60.0
            local discR = (Config and (VansConfig.DiscoveryRange or 5.0)) or 5.0
            local lockR = (Config and (VansConfig.LockRange or 4.0)) or 4.0
            near = d2 <= (ctrlR*ctrlR)
            disc = onFoot and (d2 <= (discR*discR))
            lock = onFoot and alive and (d2 <= (lockR*lockR))
        end

        if state.pos then
            ranges(state.pos)
        else
            local veh = state.veh or (state.netId and NetworkGetEntityFromNetworkId(state.netId))
            if veh and DoesEntityExist(veh) then ranges(GetEntityCoords(veh)) end
        end

        state.myAlive = alive
        state.myLock  = lock and true or false

        local team = getTeamId()
        local now  = GetGameTimer()

        local changed = (near ~= lastNear) or (disc ~= lastDisc) or (lock ~= lastLock) or (alive ~= lastAlive) or (team ~= lastTeam)
        if changed or (now - lastSend) >= 5000 then
            TriggerServerEvent('drp-vans:sv:proximity', near, alive, team, disc, lock)
            lastNear, lastDisc, lastLock, lastAlive, lastTeam = near, disc, lock, alive, team
            lastSend = now
        end

        -- adaptive cadence: far -> slower, near -> faster
        local sleep
        if not near then
            sleep = 2000
        else
            -- inside control radius?
            if lock then sleep = 600 else sleep = 1000 end
        end
        Wait(sleep)
    end
end)

-- ========= UI (admin) =========
local function getItemOptions()
    local items = exports.ox_inventory:Items()
    local opts = {}
    for name, data in pairs(items) do
        opts[#opts + 1] = { label = data.label or name, value = name }
    end
    table.sort(opts, function(a, b) return a.label < b.label end)
    return opts
end

-- FIXED: Properly handle callback with pcall
local function getGangOptions()
    local success, result = pcall(function()
        return lib.callback.await('drp-vans:sv:getGangOptions', false)
    end)

    if success and result then
        return result
    else
        print('[drp-vans] Warning: Could not fetch gang options from server')
        return {}
    end
end

RegisterCommand('vanstart', function()
    local itemOptions = getItemOptions()
    local gangOptions = getGangOptions()

    local function itemField(label)
        return {
            type = 'select', label = label, options = itemOptions,
            search = true, clearable = true, required = false, placeholder = 'Search items...'
        }
    end

    local inputs = {
        { type = 'select', label = 'Mode', options = {
            { label = 'Free For All', value = 'freeforall' },
            { label = 'Gang Event', value = 'gang' }
        }, default = 'freeforall', required = true },
        { type = 'select', label = 'Allowed Gangs (Gang Event only)', options = gangOptions, multiple = true, clearable = true, required = false, placeholder = 'Pick gangs (optional)' },
        itemField('Item 1'), { type = 'number', label = 'Item 1 count', default = 0, min = 0, step = 1, required = false },
        itemField('Item 2'), { type = 'number', label = 'Item 2 count', default = 0, min = 0, step = 1, required = false },
        itemField('Item 3'), { type = 'number', label = 'Item 3 count', default = 0, min = 0, step = 1, required = false },
    }

    local resp = lib.inputDialog('Van Event Setup', inputs)
    if not resp then return end

    local mode = resp[1] or 'freeforall'
    local gangs = resp[2] or {}

    local items = {}
    local function add(name, count)
        if type(name) == 'table' then name = name.value end
        if name and count and count > 0 then items[#items + 1] = { name = tostring(name), count = tonumber(count) } end
    end
    add(resp[3], resp[4]); add(resp[5], resp[6]); add(resp[7], resp[8])

    local payload = { items = items, mode = mode, gangs = gangs }
    local ok, message = lib.callback.await('drp-vans:sv:prepareStart', false, payload)
    if not ok then
        lib.notify({ title = 'Van Event', description = message or 'Not authorized / already active.', type = 'error' })
        return
    end

    lib.notify({ title = 'Van Event', description = message or 'Event scheduled - van will spawn in 10 minutes', type = 'success' })
end, false)

RegisterCommand('vanstop', function() TriggerServerEvent('drp-vans:sv:stop') end, false)

-- ========= server -> client =========
-- Spawn van after delay
RegisterNetEvent('drp-vans:cl:spawnVan', function(data)
    local modelHash = joaat(data.model or (Config and VansConfig.VehicleModel) or 'gburrito2')
    local pos = data.pos or { x = 0.0, y = 0.0, z = 72.0 }
    local heading = data.heading or 0.0

    if lib.requestModel then lib.requestModel(modelHash, 10000) end
    local veh = CreateVehicle(modelHash, pos.x, pos.y, pos.z, heading, true, false)
    if not veh or not DoesEntityExist(veh) then
        lib.notify({ title = 'Van Event', description = 'Client spawn failed.', type = 'error' })
        TriggerServerEvent('drp-vans:sv:vehicleSpawned', -1, nil)
        return
    end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, heading)

    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)

    state.veh = veh
    state.netId = netId
    state.pos = vector3(pos.x, pos.y, pos.z)

    TriggerServerEvent('drp-vans:sv:vehicleSpawned', netId, nil)
end)

RegisterNetEvent('drp-vans:cl:applyProps', function(netId, locked)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) then return end
    SetEntityAsMissionEntity(veh, true, true)
    FreezeEntityPosition(veh, locked)
    SetEntityInvincible(veh, locked)
    SetEntityCanBeDamaged(veh, not locked)
    SetVehicleCanBreak(veh, not locked)
    SetVehicleTyresCanBurst(veh, false)
    SetVehicleDoorsLockedForAllPlayers(veh, locked)
    SetVehicleDoorsLocked(veh, locked and 2 or 1)
    SetVehicleUndriveable(veh, locked)
end)

RegisterNetEvent('drp-vans:cl:begin', function(netId, pos)
    state.active = true
    state.netId  = netId
    state.pos    = vector3(pos.x, pos.y, pos.z)
    state.veh    = NetworkGetEntityFromNetworkId(netId)
end)

RegisterNetEvent('drp-vans:cl:onFound', function(netId, pos)
    if not state.active then return end
    state.found = true
    state.veh = NetworkGetEntityFromNetworkId(netId)
    if state.veh and DoesEntityExist(state.veh) then
        ensureFlare(state.veh)
        ensureRedSmoke(state.veh) -- obeys VansConfig.Visuals.Smoke
    end
end)

RegisterNetEvent('drp-vans:cl:updateTimer', function(seconds, required, ticking, team, displayLabel)
    if not state.active then return end
    state.timer.seconds  = tonumber(seconds or 0) or 0
    state.timer.required = tonumber(required or 0) or 0
    state.timer.ticking  = (ticking and true) or false
    state.timer.label    = displayLabel
end)

RegisterNetEvent('drp-vans:cl:onWin', function(netId, pos, team)
    lib.notify({ title = 'Van Event', description = 'Van unlocked! Loot awarded.', type = 'success' })
end)

local function clearAll()
    if state.smoke and DoesParticleFxLoopedExist(state.smoke) then StopParticleFxLooped(state.smoke, true) end
    state.smoke = nil
    if state.flare and DoesEntityExist(state.flare) then DeleteEntity(state.flare) end
    if state.veh and DoesEntityExist(state.veh) then DeleteEntity(state.veh) end
    state.flare = nil
    state.active, state.netId, state.veh, state.pos, state.found = false, nil, nil, nil, false
    state.myAlive, state.myLock = true, false
    state.timer = { seconds = 0, required = 0, ticking = false, label = nil }
    lastBase, nextProbeMs, lastRem, lastLabel, state._visible = nil, 0, -1, '00:00', false
end

RegisterNetEvent('drp-vans:cl:cleanup', function() clearAll() end)

-- optional ESX refresh
AddEventHandler('esx:playerLoaded', function(xPlayer) ESX.PlayerData = xPlayer end)
RegisterNetEvent('esx:setJob',  function(job)  if ESX and ESX.PlayerData then ESX.PlayerData.job  = job  end end)
RegisterNetEvent('esx:setJob2', function(job2) if ESX and ESX.PlayerData then ESX.PlayerData.job2 = job2 end end)
