-- ╔══════════════════════════════╗
-- ║          Pointing            ║
-- ╚══════════════════════════════╝
if not Config.Modules.Pointing then return end

local pointing = false

local function startPointing()
    local ped = cache.ped
    RequestAnimDict('anim@mp_point')
    while not HasAnimDictLoaded('anim@mp_point') do Wait(0) end
    SetPedCurrentWeaponVisible(ped, false, true, true, true)
    SetPedConfigFlag(ped, 36, true)
    Citizen.InvokeNative(0x2D537BA194896636, ped, 'task_mp_pointing', 0.5, false, 'anim@mp_point', 24)
    RemoveAnimDict('anim@mp_point')
end

local function stopPointing()
    local ped = cache.ped
    Citizen.InvokeNative(0xD01015C7316AE176, ped, 'Stop')
    if not IsPedInjured(ped) then ClearPedSecondaryTask(ped) end
    if not IsPedInAnyVehicle(ped, true) then
        SetPedCurrentWeaponVisible(ped, true, true, true, true)
    end
    SetPedConfigFlag(ped, 36, false)
    ClearPedSecondaryTask(ped)
end

RegisterCommand('point', function()
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) then return end

    if pointing then
        stopPointing()
        pointing = false
        return
    end

    startPointing()
    pointing = true

    -- Wait(1) instead of Wait(0) — sufficient for smooth signal updates at ~1000fps
    while pointing do
        ped = cache.ped

        local camPitch = GetGameplayCamRelativePitch()
        camPitch = math.max(-70.0, math.min(42.0, camPitch))
        camPitch = (camPitch + 70.0) / 112.0

        local camHeading  = GetGameplayCamRelativeHeading()
        local cosCamHead  = math.cos(math.rad(camHeading))
        local sinCamHead  = math.sin(math.rad(camHeading))
        camHeading = math.max(-180.0, math.min(180.0, camHeading))
        camHeading = (camHeading + 180.0) / 360.0

        local blocked = false
        local coords  = GetOffsetFromEntityInWorldCoords(ped,
            (cosCamHead * -0.2) - (sinCamHead  * (0.4 * camHeading + 0.3)),
            (sinCamHead * -0.2) + (cosCamHead  * (0.4 * camHeading + 0.3)),
            0.6)
        local ray = StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7)
        local _, hit = GetShapeTestResult(ray)
        if hit and hit == 1 then blocked = true end

        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, 'Pitch',   camPitch)
        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, 'Heading', camHeading * -1.0 + 1.0)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, 'isBlocked',      blocked)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, 'isFirstPerson',
            Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

        if IsPedInAnyVehicle(ped, false) or IsPedInjured(ped) then
            stopPointing()
            pointing = false
        end

        Wait(1)
    end
end, false)

RegisterKeyMapping('point', 'Point', 'keyboard', 'B')
