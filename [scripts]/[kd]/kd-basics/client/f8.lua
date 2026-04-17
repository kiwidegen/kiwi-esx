-- ╔══════════════════════════════╗
-- ║             F8               ║
-- ╚══════════════════════════════╝
if not Config.Modules.F8 then return end

local cfg = Config.F8

local MARKER_LIFETIME <const> = 30000
local VISIBLE_DIST    <const> = 24.0

local markers    = {}
local activeLock = nil

-- ─── 3D text ─────────────────────────────────────────────────────────────────

local function Draw3DText(pos, text, zOffset)
    local onScreen, sx, sy = World3dToScreen2d(pos.x, pos.y, pos.z + (zOffset or 1.0))
    if not onScreen then return end
    local dist  = #(GetGameplayCamCoords() - pos)
    local scale = (1 / dist) * 2 * ((1 / GetGameplayCamFov()) * 100)
    SetTextScale(0.0 * scale, 0.85 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 50, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(sx, sy)
end

-- ─── Events ───────────────────────────────────────────────────────────────────

RegisterNetEvent('kd-basics:f8:playerDisconnect', function(info)
    if type(info) ~= 'table' or not info.pos then return end
    markers[#markers + 1] = {
        coords  = info.pos,
        text    = ('%s (ID: %s) disconnected [%s]\nReason: %s'):format(
                      tostring(info.name or 'Unknown'),
                      tostring(info.srco or '?'),
                      tostring(info.date or ''),
                      tostring(info.res  or 'Unknown')),
        zOffset = 1.0,
        expire  = GetGameTimer() + MARKER_LIFETIME,
    }
end)

RegisterNetEvent('kd-basics:f8:hospitalEvent', function(info)
    if type(info) ~= 'table' or not info.pos then return end

    if info.checkedIn then
        markers[#markers + 1] = {
            coords  = info.pos,
            text    = ('ID %s %s checked into hospital %s'):format(
                          tostring(info.srco or '?'),
                          tostring(info.name or 'Unknown'),
                          tostring(info.date or '')),
            zOffset = 1.2,
            expire  = GetGameTimer() + MARKER_LIFETIME,
        }
    end

    if cfg.sceneLock and info.dead then
        activeLock = {
            center   = vector3(info.pos.x, info.pos.y, info.pos.z),
            radius   = cfg.sceneLockRadius,
            lastNote = 0,
        }
    end
end)

-- ─── Render loop ─────────────────────────────────────────────────────────────
-- Wait(0) only when markers or scene lock are active — sleeps at 500ms otherwise

CreateThread(function()
    while true do
        if #markers > 0 or activeLock then
            local ppos = GetEntityCoords(cache.ped)
            local t    = GetGameTimer()

            for i = #markers, 1, -1 do
                local m = markers[i]
                if t >= m.expire then
                    markers[i] = markers[#markers]
                    markers[#markers] = nil
                elseif #(ppos - vector3(m.coords.x, m.coords.y, m.coords.z)) <= VISIBLE_DIST then
                    Draw3DText(vector3(m.coords.x, m.coords.y, m.coords.z), m.text, m.zOffset)
                end
            end

            if activeLock then
                if IsEntityDead(cache.ped) then
                    local dist = #(ppos - activeLock.center)
                    if dist > activeLock.radius then
                        SetEntityCoordsNoOffset(cache.ped, activeLock.center.x, activeLock.center.y, activeLock.center.z, false, false, false)
                        if t - activeLock.lastNote > 2500 then
                            lib.notify({ title = 'Scene Lock', description = 'You are dead. Stay on scene.', type = 'warning', duration = 2500 })
                            activeLock.lastNote = t
                        end
                    end
                    Draw3DText(activeLock.center, ('SCENE LOCK • Radius: %.1fm'):format(activeLock.radius), 1.6)
                else
                    activeLock = nil
                end
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)
