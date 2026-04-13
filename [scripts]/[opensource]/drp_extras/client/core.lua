---@diagnostic disable: undefined-global

Core = {}

--============================================================
--  NOTIFY WRAPPER
--============================================================
function Core.Notify(title, msg, nType, dur)
    if exports.ox_lib then
        exports.ox_lib:notify({
            title = title,
            description = msg,
            type = nType or 'info',
            duration = dur or 3500
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255,255,255},
            args = {('[%s] %s'):format(title, msg)}
        })
    end
end

--============================================================
--  DEBUG PRINT
--============================================================
function Core.DebugPrint(...)
    if ExtrasConfig.Debug then
        print('^5[drp_modules]^7', ...)
    end
end

--============================================================
--  3D TEXT DRAWING
--============================================================
function Core.DrawText3D(pos, text, zOffset)
    local cam = GetGameplayCamCoords()
    local vpos = vector3(pos.x, pos.y, pos.z + (zOffset or 0.0))
    local dist = #(vpos - cam)
    if dist > 24.0 then return end

    local scale = (1.0 / math.max(dist, 0.1)) * (1.0 / GetGameplayCamFov()) * 90.0
    SetTextScale(0.0, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 220)
    SetTextOutline()
    SetTextCentre(true)
    SetDrawOrigin(vpos.x, vpos.y, vpos.z, 0)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

--============================================================
--  SIMPLE TIMESTAMP
--============================================================
function Core.SimpleTimestamp()
    local ms = GetGameTimer()
    local sec = math.floor(ms / 1000)
    local m = sec // 60
    local s = sec % 60
    return string.format("%02dm %02ds", m, s)
end
