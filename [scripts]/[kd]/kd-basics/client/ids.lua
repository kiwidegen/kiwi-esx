-- ╔══════════════════════════════╗
-- ║       IDs Above Head         ║
-- ╚══════════════════════════════╝
if not Config.Modules.Ids then return end

local showIDs   = false
local distances = {}

-- ─── 3D text ─────────────────────────────────────────────────────────────────

local function Draw3DText(pos, text, r, g, b)
    local onScreen, sx, sy = World3dToScreen2d(pos.x, pos.y, pos.z + 1.15)
    if not onScreen then return end

    local dist  = #(GetGameplayCamCoords() - pos)
    local scale = (1 / dist) * 2 * ((1 / GetGameplayCamFov()) * 100)

    SetTextScale(0.0 * scale, 0.85 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(r, g, b, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(sx, sy)
end

-- ─── Distance tracking ───────────────────────────────────────────────────────

CreateThread(function()
    while true do
        local myCoords = GetEntityCoords(cache.ped)

        for _, id in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(id)
            distances[id] = #(myCoords - GetEntityCoords(ped))
        end

        Wait(Config.Ids.distTick)
    end
end)

-- ─── Render ──────────────────────────────────────────────────────────────────
-- Wait(0) required — DrawText/DrawMarker must be called every frame to appear.
-- Thread sleeps at 500ms when IDs are hidden so it has no cost when inactive.

CreateThread(function()
    while true do
        if not showIDs then
            Wait(500)
            goto continue
        end

        for _, id in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(id)
            if distances[id] and distances[id] < Config.Ids.range then
                local pos = GetEntityCoords(ped)
                if HasEntityClearLosToEntity(cache.ped, ped, 17) then
                    local talking  = NetworkIsPlayerTalking(id)
                    local serverId = tostring(GetPlayerServerId(id))

                    if talking then
                        Draw3DText(pos, serverId, 247, 124, 24)
                        DrawMarker(27,
                            pos.x, pos.y, pos.z - 0.97,
                            0, 0, 0, 0, 0, 0,
                            1.001, 1.001, 0.5,
                            173, 216, 230, 100,
                            false, false, 2, false, nil, nil, false
                        )
                    else
                        Draw3DText(pos, serverId, 255, 255, 255)
                    end
                end
            end
        end

        Wait(0)
        ::continue::
    end
end)

-- ─── Toggle ──────────────────────────────────────────────────────────────────

RegisterCommand('toggleids', function()
    showIDs = not showIDs

    if showIDs then
        lib.showTextUI('Showing IDs', {
            position = 'left-center',
            icon     = 'id-card',
            style    = {
                borderRadius    = 0,
                backgroundColor = '#4d94ff',
                color           = 'white',
            },
        })
    else
        lib.hideTextUI()
    end
end, false)

RegisterKeyMapping('toggleids', 'Toggle Player IDs', 'keyboard', 'HOME')
