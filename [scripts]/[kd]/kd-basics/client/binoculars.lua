-- ╔══════════════════════════════╗
-- ║         Binoculars           ║
-- ╚══════════════════════════════╝
if not Config.Modules.Binoculars then return end

local active    = false
local cam       = nil
local scaleform = nil
local fov       = (Config.Binoculars.maxFov + Config.Binoculars.minFov) * 0.5

local function handleRotation()
    local rot  = GetCamRot(cam, 2)
    local axisX = GetControlNormal(0, 220)
    local axisY = GetControlNormal(0, 221)

    if axisX ~= 0.0 or axisY ~= 0.0 then
        local zoom  = (1.0 / (Config.Binoculars.maxFov - Config.Binoculars.minFov)) * (fov - Config.Binoculars.minFov)
        local newZ  = rot.z + axisX * -1.0 * Config.Binoculars.panSpeed  * (zoom + 0.1)
        local newX  = math.max(math.min(20.0, rot.x + axisY * -1.0 * Config.Binoculars.panSpeed * (zoom + 0.1)), -89.5)
        SetCamRot(cam, newX, 0.0, newZ, 2)
        SetEntityHeading(cache.ped, newZ)
    end
end

local function handleZoom()
    local up   = IsPedSittingInAnyVehicle(cache.ped) and 17 or 241
    local down = IsPedSittingInAnyVehicle(cache.ped) and 16 or 242

    if IsControlJustPressed(0, up) then
        fov = math.max(fov - Config.Binoculars.zoomSpeed, Config.Binoculars.minFov)
    end
    if IsControlJustPressed(0, down) then
        fov = math.min(fov + Config.Binoculars.zoomSpeed, Config.Binoculars.maxFov)
    end

    local diff = fov - GetCamFov(cam)
    if math.abs(diff) > 0.01 then
        SetCamFov(cam, GetCamFov(cam) + diff * 0.05)
    end
end

local function hideHUD()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    for _, id in ipairs({ 1,2,3,4,6,7,8,9,11,12,13,15,18,19 }) do
        HideHudComponentThisFrame(id)
    end
end

-- ─── Open / close ────────────────────────────────────────────────────────────

local function close()
    active = false
    fov    = (Config.Binoculars.maxFov + Config.Binoculars.minFov) * 0.5
    ClearPedTasks(cache.ped)
    ClearTimecycleModifier()
    RenderScriptCams(false, true, 500, false, false)
    if scaleform then SetScaleformMovieAsNoLongerNeeded(scaleform) end
    if cam then DestroyCam(cam, false) end
    cam       = nil
    scaleform = nil
    lib.hideTextUI()
end

local function open()
    local ped = cache.ped
    fov       = (Config.Binoculars.maxFov + Config.Binoculars.minFov) * 0.5
    active    = true

    lib.showTextUI('[E] Close', { position = 'left-center' })
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_BINOCULARS', 0, true)

    cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)
    AttachCamToEntity(cam, ped, 0.0, 0.2, 0.7, true)
    SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped), 2)
    RenderScriptCams(true, false, 500, true, false)

    -- render loop — Wait(0) required for camera/scaleform to update every frame
    CreateThread(function()
        while active do
            scaleform = lib.requestScaleformMovie('BINOCULARS')
            BeginScaleformMovieMethod(scaleform, 'SET_CAM_LOGO')
            ScaleformMovieMethodAddParamInt(0)
            EndScaleformMovieMethod()

            if IsControlJustPressed(0, 51) then
                close()
                break
            end

            handleRotation()
            handleZoom()
            hideHUD()

            DrawScaleformMovie(scaleform, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255)
            Wait(0)
        end
    end)
end

-- ─── Close keybind ───────────────────────────────────────────────────────────

lib.addKeybind({
    name        = 'closeBinoculars',
    description = 'Close Binoculars',
    defaultKey  = 'e',
    onPressed   = function()
        if not active then return end
        close()
    end,
})

-- ─── Net event (triggered from server after job check) ───────────────────────

RegisterNetEvent('kd-basics:client:useBinoculars', function()
    if cache.vehicle or IsPedSwimming(cache.ped) or IsEntityDead(cache.ped) then
        lib.notify({ title = 'Binoculars', description = 'You cannot use binoculars right now.', type = 'error' })
        return
    end

    if active then
        close()
    else
        open()
    end
end)
