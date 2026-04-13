if not ExtrasConfig.Modules.F8 then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('F8 module loaded')

local disconnectLocations, activeLock = {}, nil
local MARKER_LIFETIME <const> = 30000
local MAX_DRAWS_PER_FRAME <const> = 12
local VISIBLE_DIST <const> = 24.0

local function nowMs() return GetGameTimer() end

local function pushMarker(pos, text, zOffset)
    disconnectLocations[#disconnectLocations + 1] = {
        coords = pos,
        text = text,
        zOffset = zOffset or 1.0,
        expire = nowMs() + MARKER_LIFETIME
    }
end

--=============================
-- Disconnect marker
--=============================
RegisterNetEvent('drp_f8:playerDisconnect', function(info)
    if type(info) ~= 'table' or not info.pos then return end
    pushMarker(info.pos,
        ("%s (ID: %s) disconnected [%s]\nReason: %s"):format(
            tostring(info.name or 'Unknown'),
            tostring(info.srco or '?'),
            tostring(info.date or ''),
            tostring(info.res or 'Unknown')
        ),
        1.0
    )
end)

--=============================
-- Hospital marker
--=============================
RegisterNetEvent('drp_f8:hospitalEvent', function(info)
    if type(info) ~= 'table' or not info.pos then return end

    -- Only show marker if they checked in (not for deaths without check-in)
    if info.checkedIn then
        pushMarker(info.pos,
            ("ID %s %s has checked into hospital %s"):format(
                tostring(info.srco or '?'),
                tostring(info.name or 'Unknown'),
                tostring(info.date or '')
            ),
            1.2 -- slightly higher to prevent overlap
        )
    end

    if ExtrasConfig.SceneLock and info.dead then
        activeLock = {
            center = vector3(info.pos.x, info.pos.y, info.pos.z),
            radius = tonumber(ExtrasConfig.SceneLockRadius) or 12.0,
            lastNote = 0
        }
    end
end)

--=============================
-- Render loop (optimized)
--=============================
CreateThread(function()
    while true do
        -- Only run fast when there's actually something to render
        if #disconnectLocations > 0 or activeLock then
            local ped = PlayerPedId()
            local ppos = GetEntityCoords(ped)
            local t = nowMs()

            -- Prune + draw markers
            for i = #disconnectLocations, 1, -1 do
                local m = disconnectLocations[i]
                if t >= (m.expire or 0) then
                    table.remove(disconnectLocations, i)
                elseif #(ppos - vector3(m.coords.x, m.coords.y, m.coords.z)) <= VISIBLE_DIST then
                    Core.DrawText3D(m.coords, m.text, m.zOffset)
                end
            end

            -- Scene lock enforcement
            if activeLock then
                if IsEntityDead(ped) then
                    local dist = #(ppos - activeLock.center)
                    if dist > activeLock.radius then
                        SetEntityCoordsNoOffset(ped, activeLock.center.x, activeLock.center.y, activeLock.center.z, false, false, false)
                        local n = t
                        if n - (activeLock.lastNote or 0) > 2500 then
                            Core.Notify('Scene Lock', 'You are dead. Stay on scene.', 'warning', 2500)
                            activeLock.lastNote = n
                        end
                    end
                    Core.DrawText3D(activeLock.center, ("SCENE LOCK • Radius: %.1fm"):format(activeLock.radius), 1.6)
                else
                    activeLock = nil
                end
            end

            Wait(0)
        else
            Wait(500)  -- Nothing to render, check less frequently
        end
    end
end)

--=============================
-- Manual test command
--=============================
RegisterCommand('testf8', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local fakeInfo = {
        name = 'Test_Player',
        srco = GetPlayerServerId(PlayerId()),
        date = Core.SimpleTimestamp(),
        res = 'Manual Test Trigger',
        pos = { x = pos.x, y = pos.y, z = pos.z },
        dead = true,
        checkedIn = false
    }
    TriggerEvent('drp_f8:playerDisconnect', fakeInfo)
    TriggerEvent('drp_f8:hospitalEvent', fakeInfo)
    Core.Notify('F8 Test', 'Fake disconnect + hospital event fired.', 'success', 3000)
end, false)
