--============================================================
--  VOICE RANGE CIRCLE MODULE
--============================================================
-- Description: Shows visual circle on ground when changing voice modes
-- Features:
--   - Displays circle showing voice range
--   - Smooth animation with lerp
--   - Auto-fades after 2 seconds
--   - Integrates with pma-voice
--============================================================

if not ExtrasConfig.Modules.VoiceCircle then return end

---@class VoiceMode
---@field r number Red color value (0-255)
---@field g number Green color value (0-255)
---@field b number Blue color value (0-255)

---@type table<number, VoiceMode> Voice mode colors
local voiceModes = {
    [1] = { -- Whisper
        r = 80, g = 170, b = 255
    },
    [2] = { -- Normal
        r = 80, g = 170, b = 255
    },
    [3] = { -- Shouting
        r = 80, g = 170, b = 255
    }
}

---@type number Lerp animation speed (0.0-1.0)
local lerpSpeed = 0.1

---@type VoiceMode Current voice mode settings
local currentVoiceMode = voiceModes[1]

---@type number Game timer when circle should stop drawing
local endTime = GetGameTimer()

---@type number Target proximity range in units
local proximityRange = 0.0

---@type number Current lerped range value
local lerpRange = 0.0

---@type number Duration to display circle in milliseconds
local drawDuration = 2000

--- Linear interpolation between two values
---@param a number Start value
---@param b number End value
---@param t number Interpolation factor (0.0-1.0)
---@return number result Interpolated value
local function lerp(a, b, t)
    return a + (b - a) * t
end

--- Creates thread to draw and animate the circle
local function createCircleThread()
    CreateThread(function()
        local ped = PlayerPedId()
        while GetGameTimer() < endTime do
            local pos = GetEntityCoords(ped)
            pos = vec3(pos.x, pos.y, pos.z - 1.0)
            local drawAlpha = math.floor((endTime - GetGameTimer()) / drawDuration * 255)

            -- Draw top circle
            DrawMarker(
                1, -- Type (cylinder)
                pos.x, pos.y, pos.z,
                0.0, 0.0, 0.0, -- Direction
                0.0, 0.0, 0.0, -- Rotation
                lerpRange, lerpRange, 0.125, -- Scale
                currentVoiceMode.r, currentVoiceMode.g, currentVoiceMode.b, drawAlpha,
                false, true, 2, nil, nil, false
            )

            -- Draw bottom circle
            DrawMarker(
                1, -- Type (cylinder)
                pos.x, pos.y, pos.z,
                0.0, 0.0, 0.0, -- Direction
                0.0, 0.0, 0.0, -- Rotation
                lerpRange, lerpRange, -0.125, -- Scale
                currentVoiceMode.r, currentVoiceMode.g, currentVoiceMode.b, drawAlpha,
                false, true, 2, nil, nil, false
            )

            lerpRange = lerp(lerpRange, proximityRange, lerpSpeed)
            Wait(0)
        end
    end)
end

--- Updates voice info from pma-voice state
local function updateVoiceInfo()
    local proximity = LocalPlayer.state.proximity
    if proximity then
        currentVoiceMode = voiceModes[proximity.index]
        proximityRange = (proximity.distance or 1) * 4
    end
end

-- Event handler for voice mode changes
AddEventHandler('pma-voice:setTalkingMode', function()
    updateVoiceInfo()
    endTime = GetGameTimer() + drawDuration
    createCircleThread()
end)

-- Wait for pma-voice to start before initializing
CreateThread(function()
    while GetResourceState('pma-voice') ~= 'started' do
        Wait(50)
    end
    updateVoiceInfo()
end)
