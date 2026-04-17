-- ╔══════════════════════════════╗
-- ║         Bike Guns            ║
-- ╚══════════════════════════════╝
if not Config.Modules.BikeGuns then return end

local DB_SHOTGUN <const> = `WEAPON_DBSHOTGUN`
local UNARMED    <const> = `WEAPON_UNARMED`

local function getCamDir()
    local rot = GetGameplayCamRot(2)
    return vector3(
        -math.sin(math.rad(rot.z)) * math.cos(math.rad(rot.x)),
         math.cos(math.rad(rot.z)) * math.cos(math.rad(rot.x)),
         math.sin(math.rad(rot.x))
    )
end

-- Thread spawns only while on a motorcycle or bicycle.
-- Wait(0) justified when armed — DisableControlAction must fire every frame.
-- Wait(200) when unarmed — flag/knockoff calls are persistent, no per-frame cost needed.

lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    local class = GetVehicleClass(vehicle)
    if class ~= 8 and class ~= 13 then return end

    SetPlayerCanDoDriveBy(PlayerId(), true)

    CreateThread(function()
        while cache.vehicle == vehicle do
            local _, weapon = GetCurrentPedWeapon(cache.ped)

            if weapon ~= UNARMED then
                if weapon == DB_SHOTGUN then
                    DisableControlAction(0, 26, true)
                    if IsControlJustPressed(0, 24) and GetAmmoInPedWeapon(cache.ped, DB_SHOTGUN) > 0 then
                        local dir    = getCamDir()
                        local coords = GetGameplayCamCoord() + (dir * 1000.0)
                        SetPedShootsAtCoord(cache.ped, coords.x, coords.y, coords.z, true)
                    end
                end
                if GetFollowVehicleCamViewMode() ~= 0 then
                    SetFollowVehicleCamViewMode(0)
                end
                Wait(0)
            else
                SetPedConfigFlag(cache.ped, 35, false)
                SetPedCanBeKnockedOffVehicle(cache.ped, 1)
                Wait(200)
            end
        end
    end)
end)
