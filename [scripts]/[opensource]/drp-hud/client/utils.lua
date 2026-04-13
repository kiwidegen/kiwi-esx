-- Utility functions for HUD

Utils = {}

-- Check if value changed significantly (prevents spam updates)
function Utils.HasChangedSignificantly(oldValue, newValue, threshold)
    threshold = threshold or 1
    return math.abs(oldValue - newValue) >= threshold
end

-- Format number with commas
function Utils.FormatNumber(number)
    local formatted = tostring(number)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Get alignment for UI positioning (NOT USED - alignment.lua handles this)
function Utils.GetAlignment()
    local minimap = {}
    local resX, resY = GetActiveScreenResolution()
    local aspectRatio = GetAspectRatio()
    local scaleX = 1/resX
    local scaleY = 1/resY
    local minimapRawX, minimapRawY

    SetScriptGfxAlign(string.byte('L'), string.byte('B'))

    if IsBigmapActive() then
        minimapRawX, minimapRawY = GetScriptGfxPosition(-0.003975, 0.022 + (-0.460416666))
        minimap.width = scaleX * (resX / (2.52 * aspectRatio))
        minimap.height = scaleY * (resY / (2.3374))
    else
        minimapRawX, minimapRawY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
        minimap.width = scaleX * (resX / (4 * aspectRatio))
        minimap.height = scaleY * (resY / (5.674))
    end

    ResetScriptGfxAlign()

    minimap.leftX = minimapRawX
    minimap.rightX = minimapRawX + minimap.width
    minimap.topY = minimapRawY
    minimap.bottomY = minimapRawY + minimap.height
    minimap.X = minimapRawX + (minimap.width / 2)
    minimap.Y = minimapRawY + (minimap.height / 2)

    local x1 = resX * minimap.rightX
    local y1 = resY * minimap.topY
    local x2 = resX * minimap.rightX
    local y2 = resY * minimap.bottomY
    local x3 = (resX / 30) + ((x1 + x2) / 2)
    local y3 = resY - ((y1 + y2) / 2) - (resY / 20)

    return math.floor(x3), math.floor(y3), (resY / 5.6)
end

-- Debug print
function Utils.Debug(...)
    if GetConvarInt('hud_debug', 0) == 1 then
        print('^3[HUD DEBUG]^0', ...)
    end
end
