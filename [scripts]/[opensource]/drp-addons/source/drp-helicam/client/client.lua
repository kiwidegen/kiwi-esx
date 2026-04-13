---@diagnostic disable: undefined-global
local fov_max = 70.0
local fov_min = 5.0
local fov = (fov_max + fov_min) * 0.5
local cam = nil
local scaleform = nil
local helicam = false
local spotlight = false
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

--- Handle camera rotation with mouse/controller
---@param cam number Camera handle
---@param zoomvalue number Current zoom value
local function CheckInputRotation(cam, zoomvalue)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)

    local newZ = rotation.z + rightAxisX * -10.0 * (zoomvalue + 0.1)
    local newX = math.max(math.min(20.0, rotation.x + rightAxisY * -10.0 * (zoomvalue + 0.1)), -89.5)

    SetCamRot(cam, newX, 0.0, newZ, 2)
end

--- Hide HUD while camera is active
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

--- Check if vehicle is allowed to use helicam
---@param vehicle number Vehicle entity handle
---@return boolean isAllowed Whether vehicle can use helicam
local function IsVehicleAllowed(vehicle)
    for _, modelName in pairs(Config.Helicam.AllowedVehicles) do
        if IsVehicleModel(vehicle, GetHashKey(modelName)) then
            return true
        end
    end
    return false
end

--- Toggle helicopter camera
RegisterCommand("helicam", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle then
        if IsVehicleAllowed(vehicle) then
            if GetEntityHeightAboveGround(vehicle) > 1.5 then
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

                TriggerServerEvent("drp_helicam:toggle", helicam)

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
                        AttachCamToEntity(cam, playerVehicle, 0.0, 0.0, -1.5, true)
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

                TriggerServerEvent("drp_helicam:toggle", false)
            end
        end
    end
end, false)

--- Rappel from helicopter
RegisterCommand("rappel", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle then
        if IsVehicleAllowed(vehicle) then
            if GetEntityHeightAboveGround(vehicle) > 1.5 then
                if (GetPedInVehicleSeat(vehicle, 1) == playerPed) or (GetPedInVehicleSeat(vehicle, 2) == playerPed) then
                    TaskRappelFromHeli(playerPed, 1)
                end
            end
        end
    end
end, false)

--- Monitor camera state and exit if player leaves vehicle
CreateThread(function()
    while true do
        Wait(2000)
        if cam and GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
            helicam = false
        end
    end
end)

--- Toggle spotlight
RegisterCommand("spotlight", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and helicam then
        if IsVehicleAllowed(vehicle) then
            if GetEntityHeightAboveGround(vehicle) > 1.5 then
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    spotlight = not spotlight
                    TriggerServerEvent("drp_helicam:spotlight", vehicle, spotlight)
                end
            end
        end
    end
end, false)

--- Toggle vision modes (normal/night vision/thermal)
RegisterCommand("vision", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and helicam then
        if IsVehicleAllowed(vehicle) then
            if GetEntityHeightAboveGround(vehicle) > 1.5 then
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
    end
end, false)

--- Receive spotlight toggle from server
---@param vehicle number Vehicle entity handle
---@param state boolean Spotlight state
RegisterNetEvent("drp_helicam:spotlight", function(vehicle, state)
    SetVehicleSearchlight(vehicle, state, false)
end)

-- Register key mappings
RegisterKeyMapping("helicam", "Helicopter Camera", "keyboard", "E")
RegisterKeyMapping("rappel", "Rappel from Helicopter", "keyboard", "X")
RegisterKeyMapping("spotlight", "Toggle Searchlight", "keyboard", "L")
RegisterKeyMapping("vision", "Change Vision Mode", "mouse_button", "MOUSE_RIGHT")
