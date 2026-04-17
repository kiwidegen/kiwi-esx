-- ╔══════════════════════════════╗
-- ║          Heli Cam            ║
-- ╚══════════════════════════════╝
if not Config.Modules.HeliCam then return end

local ESX = exports['es_extended']:getSharedObject()
local cfg = Config.HeliCam

-- ─── State ───────────────────────────────────────────────────────────────────

local active         = false
local cam            = nil
local scaleform      = nil
local fov            = (cfg.fovMax + cfg.fovMin) * 0.5
local brightness     = cfg.brightness
local spotRadius     = cfg.spotRadius
local visionState    = 0  -- 0 normal, 1 night, 2 thermal
local displayMode    = 0  -- 0 full, 1 plate only, 2 off
local manualSpot     = false
local lockedVehicle  = nil

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function hasJob()
    local data = ESX.GetPlayerData()
    if not data or not data.job then return false end
    for _, j in ipairs(cfg.jobs) do
        if data.job.name == j then return true end
    end
    return false
end

local function inHeliCam()
    local veh = cache.vehicle
    return veh and cfg.vehicles[GetEntityModel(veh)] and GetPedInVehicleSeat(veh, -1) == cache.ped
end

local function highEnough()
    return GetEntityHeightAboveGround(cache.vehicle) > cfg.minHeight
end

local function rotToVec(rot)
    local z   = math.rad(rot.z)
    local x   = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function hideHUD()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    for _, id in ipairs({ 1, 2, 3, 4, 11, 12, 13, 15, 18, 19 }) do
        HideHudComponentThisFrame(id)
    end
end

local function handleZoom()
    local c = cfg.controls
    if IsControlJustPressed(0, c.zoomIn)  then fov = math.max(fov - cfg.zoomSpeed, cfg.fovMin) end
    if IsControlJustPressed(0, c.zoomOut) then fov = math.min(fov + cfg.zoomSpeed, cfg.fovMax) end
    local diff = fov - GetCamFov(cam)
    if math.abs(diff) > 0.1 then
        SetCamFov(cam, GetCamFov(cam) + diff * 0.05)
    end
end

local function handlePan()
    local rot   = GetCamRot(cam, 2)
    local axisX = GetDisabledControlNormal(0, 220)
    local axisY = GetDisabledControlNormal(0, 221)
    if axisX ~= 0.0 or axisY ~= 0.0 then
        local zoom = (1.0 / (cfg.fovMax - cfg.fovMin)) * (fov - cfg.fovMin)
        local newZ = rot.z + axisX * -1.0 * cfg.panSpeed * (zoom + 0.1)
        local newX = math.max(math.min(20.0, rot.x + axisY * -1.0 * cfg.panSpeed * (zoom + 0.1)), -89.5)
        SetCamRot(cam, newX, 0.0, newZ, 2)
    end
end

local function cycleVision()
    if visionState == 0 then
        SetNightvision(true)
        visionState = 1
    elseif visionState == 1 then
        SetNightvision(false)
        SetSeethrough(true)
        visionState = 2
    else
        SetSeethrough(false)
        visionState = 0
    end
end

local function renderVehicleInfo(veh)
    if not DoesEntityExist(veh) or displayMode == 2 then return end
    local name  = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
    local plate = GetVehicleNumberPlateText(veh)
    local speed = math.ceil(GetEntitySpeed(veh) * 2.237)

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.49)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')

    if displayMode == 0 then
        AddTextComponentString(('Speed: %d MPH\nModel: %s\nPlate: %s'):format(speed, name, plate))
    else
        AddTextComponentString(('Model: %s\nPlate: %s'):format(name, plate))
    end

    DrawText(0.45, 0.9)
end

-- ─── Close ───────────────────────────────────────────────────────────────────

local function close()
    active        = false
    manualSpot    = false
    lockedVehicle = nil
    fov           = (cfg.fovMax + cfg.fovMin) * 0.5
    visionState   = 0

    SetNightvision(false)
    SetSeethrough(false)
    ClearTimecycleModifier()
    RenderScriptCams(false, false, 0, true, false)

    if scaleform then SetScaleformMovieAsNoLongerNeeded(scaleform) end
    if cam       then DestroyCam(cam, false) end
    cam       = nil
    scaleform = nil
end

-- ─── Open ────────────────────────────────────────────────────────────────────

local function open()
    if active then return end
    local heli = cache.vehicle
    active     = true
    fov        = (cfg.fovMax + cfg.fovMin) * 0.5

    SetTimecycleModifier('heliGunCam')
    SetTimecycleModifierStrength(0.3)

    cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)
    AttachCamToEntity(cam, heli, 0.0, 0.0, -1.5, true)
    SetCamRot(cam, 0.0, 0.0, GetEntityHeading(heli), 2)
    SetCamFov(cam, fov)
    RenderScriptCams(true, false, 0, true, false)

    -- render loop — Wait(0) required for camera/scaleform every frame
    CreateThread(function()
        scaleform = lib.requestScaleformMovie('HELI_CAM')
        BeginScaleformMovieMethod(scaleform, 'SET_CAM_LOGO')
        ScaleformMovieMethodAddParamInt(0)
        EndScaleformMovieMethod()

        local c = cfg.controls
        while active and not IsEntityDead(cache.ped) and inHeliCam() and highEnough() do

            -- vision cycle
            if IsControlJustPressed(0, c.vision) then
                cycleVision()
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end

            -- display cycle
            if IsControlJustPressed(0, c.display) then
                displayMode = (displayMode + 1) % 3
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end

            -- spotlight toggle
            if IsControlJustPressed(0, c.spotlight) then
                manualSpot = not manualSpot
                if not manualSpot then
                    SetVehicleSearchlight(cache.vehicle, false, false)
                end
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end

            -- brightness
            if IsControlJustPressed(0, c.brightnessUp) and brightness < cfg.brightnessMax then
                brightness = brightness + 1.0
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end
            if IsControlJustPressed(0, c.brightnessDown) and brightness > cfg.brightnessMin then
                brightness = brightness - 1.0
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end

            -- radius
            if IsControlJustPressed(0, c.radiusUp) and spotRadius < cfg.spotRadiusMax then
                spotRadius = spotRadius + 1.0
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end
            if IsControlJustPressed(0, c.radiusDown) and spotRadius > cfg.spotRadiusMin then
                spotRadius = spotRadius - 1.0
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end

            -- lock on / release
            if IsControlJustPressed(0, c.lockOn) then
                if lockedVehicle then
                    lockedVehicle = nil
                    local rot = GetCamRot(cam, 2)
                    local oldCam = cam
                    DestroyCam(oldCam, false)
                    cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)
                    AttachCamToEntity(cam, cache.vehicle, 0.0, 0.0, -1.5, true)
                    SetCamRot(cam, rot, 2)
                    SetCamFov(cam, fov)
                    RenderScriptCams(true, false, 0, true, false)
                    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                else
                    -- raycast from cam to find vehicle
                    local coords  = GetCamCoord(cam)
                    local forward = rotToVec(GetCamRot(cam, 2))
                    local ray     = CastRayPointToPoint(coords, coords + forward * 500.0, 10, cache.vehicle, 0)
                    local _, _, _, _, hit = GetRaycastResult(ray)
                    if hit and hit > 0 and IsEntityAVehicle(hit) then
                        lockedVehicle = hit
                        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                    end
                end
            end

            -- if locked on, point cam at target
            if lockedVehicle then
                if DoesEntityExist(lockedVehicle) then
                    local d = #(GetEntityCoords(cache.vehicle) - GetEntityCoords(lockedVehicle))
                    if d > cfg.maxTargetDist then
                        lockedVehicle = nil
                    else
                        PointCamAtEntity(cam, lockedVehicle, 0.0, 0.0, 0.0, true)
                        renderVehicleInfo(lockedVehicle)
                    end
                else
                    lockedVehicle = nil
                end
            else
                handlePan()
            end

            -- manual spotlight
            if manualSpot then
                local heliCoords = GetEntityCoords(cache.vehicle)
                local origin     = heliCoords + vector3(0.0, 0.0, -1.5)
                local forward    = rotToVec(GetCamRot(cam, 2))
                DrawSpotLight(origin.x, origin.y, origin.z, forward.x, forward.y, forward.z, 255, 255, 255, 800.0, 10.0, brightness, spotRadius, 1.0)
            else
                SetVehicleSearchlight(cache.vehicle, false, false)
            end

            handleZoom()
            hideHUD()

            BeginScaleformMovieMethod(scaleform, 'SET_ALT_FOV_HEADING')
            ScaleformMovieMethodAddParamFloat(GetEntityCoords(cache.vehicle).z)
            ScaleformMovieMethodAddParamFloat((1.0 / (cfg.fovMax - cfg.fovMin)) * (fov - cfg.fovMin))
            ScaleformMovieMethodAddParamFloat(GetCamRot(cam, 2).z)
            EndScaleformMovieMethod()
            DrawScaleformMovie(scaleform, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255)

            Wait(0)
        end

        if active then close() end
    end)
end

-- ─── Keybind — event-driven, no polling thread ───────────────────────────────

lib.addKeybind({
    name        = 'helicamToggle',
    description = 'Toggle Helicopter Camera',
    defaultKey  = 'e',
    onPressed   = function()
        if active then
            close()
        elseif inHeliCam() and highEnough() then
            if hasJob() then
                open()
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            else
                lib.notify({ title = 'Heli Cam', description = 'Unauthorised.', type = 'error' })
            end
        end
    end,
})

lib.onCache('vehicle', function(vehicle)
    if active and (not vehicle or not cfg.vehicles[GetEntityModel(vehicle)]) then
        close()
    end
end)
