---@diagnostic disable: undefined-global
-- Police Vehicle Thermal/Night Vision Camera System

local fov_max = 70.0
local fov_min = 5.0
local fov = (fov_max + fov_min) * 0.5
local cam = nil
local scaleform = nil
local helicam = false
local vision = 0

--- Handle camera zoom
---@param cam number Camera handle
local function HandleZoom(cam)
    if IsControlJustPressed(0, 241) then
        fov = math.max(fov - 2.0, fov_min)
    elseif IsControlJustPressed(0, 242) then
        fov = math.min(fov + 2.0, fov_max)
    end
    SetCamFov(cam, fov)
end

--- Handle camera rotation
---@param cam number Camera handle
---@param zoomvalue number Zoom value
local function CheckInputRotation(cam, zoomvalue)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)

    local newZ = rotation.z + rightAxisX * -10.0 * (zoomvalue + 0.1)
    local newX = math.max(math.min(20.0, rotation.x + rightAxisY * -10.0 * (zoomvalue + 0.1)), -89.5)

    SetCamRot(cam, newX, 0.0, newZ, 2)
end

--- Hide HUD while camera active
local function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    HideHudComponentThisFrame(1)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(8)
    HideHudComponentThisFrame(9)
    HideHudComponentThisFrame(13)
    HideHudComponentThisFrame(11)
    HideHudComponentThisFrame(12)
    HideHudComponentThisFrame(15)
    HideHudComponentThisFrame(18)
    HideHudComponentThisFrame(19)
end

--- Get camera height for specific vehicle
---@param vehicle number Vehicle entity handle
---@return number height Camera height offset
local function GetCamHeightForVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    return Config.AutoThermal.VehicleCamHeights[model] or 1.5
end

--- Check if vehicle is allowed to use thermal cam
---@param vehicle number Vehicle entity handle
---@return boolean allowed Whether vehicle can use camera
local function IsVehicleAllowed(vehicle)
    local model = GetEntityModel(vehicle)
    return Config.AutoThermal.VehicleCamHeights[model] ~= nil
end

--- Toggle thermal camera
RegisterCommand("thermalcam", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle then
        if IsVehicleAllowed(vehicle) then
            helicam = not helicam

            if not helicam then
                ClearTimecycleModifier()
                fov = (fov_max + fov_min) * 0.5
                RenderScriptCams(false, false, 0, 1, 0)
                SetScaleformMovieAsNoLongerNeeded(scaleform)
                DestroyCam(cam, false)
                SetNightvision(false)
                SetSeethrough(false)
                vision = 0
            end

            TriggerServerEvent("drp_auto_thermal:toggle", helicam)

            while helicam do
                Wait(0)
                local playerPed = PlayerPedId()
                local playerVehicle = GetVehiclePedIsIn(playerPed, false)

                if cam == nil then
                    SetTimecycleModifier("heliGunCam")
                    SetTimecycleModifierStrength(0.3)

                    scaleform = RequestScaleformMovie("HELI_CAM")
                    while not HasScaleformMovieLoaded(scaleform) do
                        Wait(100)
                    end

                    cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
                    local camHeight = GetCamHeightForVehicle(playerVehicle)
                    AttachCamToEntity(cam, playerVehicle, 0.0, 0.0, camHeight, true)
                    SetCamRot(cam, 0.0, 0.0, GetEntityHeading(playerVehicle))

                    if fov == 50 then
                        fov = 50.1
                    end
                    SetCamFov(cam, fov)
                    RenderScriptCams(true, false, 0, 1, 0)

                    PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
                    PushScaleformMovieFunctionParameterInt(1)
                    PopScaleformMovieFunctionVoid()
                end

                while helicam and not IsEntityDead(playerPed) and (GetVehiclePedIsIn(playerPed) == playerVehicle) do
                    local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
                    CheckInputRotation(cam, zoomvalue)
                    HandleZoom(cam)
                    HideHUDThisFrame()
                    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
                    Wait(0)
                end

                RenderScriptCams(false, false, 0, 1, 0)
                DestroyCam(cam, false)
                cam = nil
                ClearTimecycleModifier()
                SetScaleformMovieAsNoLongerNeeded(scaleform)
            end

            TriggerServerEvent("drp_auto_thermal:toggle", false)
        end
    end
end, false)

--- Monitor camera state
CreateThread(function()
    while true do
        Wait(2000)
        if cam and GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
            helicam = false
        end
    end
end)

--- Toggle vision modes
RegisterCommand("carvision", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and helicam then
        if IsVehicleAllowed(vehicle) then
            if vision == 0 then
                SetNightvision(true)
                vision = 1
            elseif vision == 1 then
                SetNightvision(false)
                SetSeethrough(true)
                vision = 2
            else
                SetSeethrough(false)
                vision = 0
            end
        end
    end
end, false)

-- Register key mappings
RegisterKeyMapping("thermalcam", "Toggle Vehicle Camera", "keyboard", "E")
RegisterKeyMapping("carvision", "Change Vision Mode", "mouse_button", "MOUSE_RIGHT")
