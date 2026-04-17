-- ╔══════════════════════════════╗
-- ║        Voice Circle          ║
-- ╚══════════════════════════════╝
if not Config.Modules.VoiceCircle then return end

local cfg = Config.VoiceCircle

local proximityRange = 0.0
local lerpRange      = 0.0
local endTime        = 0
local drawing        = false

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function startDrawing()
    endTime = GetGameTimer() + cfg.drawDuration
    if drawing then return end
    drawing = true

    CreateThread(function()
        local ped = cache.ped
        while GetGameTimer() < endTime do
            local pos   = GetEntityCoords(ped)
            local posZ  = pos.z - 1.0
            local alpha = math.floor((endTime - GetGameTimer()) / cfg.drawDuration * 255)
            local r, g, b = cfg.color.r, cfg.color.g, cfg.color.b

            DrawMarker(1, pos.x, pos.y, posZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                lerpRange, lerpRange,  0.125, r, g, b, alpha, false, true, 2, nil, nil, false)
            DrawMarker(1, pos.x, pos.y, posZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                lerpRange, lerpRange, -0.125, r, g, b, alpha, false, true, 2, nil, nil, false)

            lerpRange = lerp(lerpRange, proximityRange, cfg.lerpSpeed)
            Wait(0)
        end

        lerpRange = 0.0
        drawing   = false
    end)
end

local function updateVoiceInfo()
    local proximity = LocalPlayer.state.proximity
    if proximity then
        proximityRange = (proximity.distance or 1) * 4
    end
end

AddEventHandler('pma-voice:setTalkingMode', function()
    updateVoiceInfo()
    startDrawing()
end)

CreateThread(function()
    while GetResourceState('pma-voice') ~= 'started' do
        Wait(50)
    end
    updateVoiceInfo()
end)
