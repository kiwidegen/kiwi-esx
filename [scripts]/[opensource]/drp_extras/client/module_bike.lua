if not ExtrasConfig.Modules.BikeGuns then return end
---@diagnostic disable: undefined-global
Core.DebugPrint('Bike module loaded (drive + all weapons + melee)')

local DB_SHOTGUN <const> = `WEAPON_DBSHOTGUN`
local UNARMED <const> = `WEAPON_UNARMED`

---Get camera direction vector (for DB shotgun aiming)
---@return vector3
local function GetCamDir()
    local rot = GetGameplayCamRot(2)
    local heading, pitch = rot.z, rot.x
    local x = -math.sin(math.rad(heading)) * math.cos(math.rad(pitch))
    local y = math.cos(math.rad(heading)) * math.cos(math.rad(pitch))
    local z = math.sin(math.rad(pitch))
    return vector3(x, y, z)
end

CreateThread(function()
    local ped = PlayerPedId()
    local nextPedCheck = GetGameTimer() + 1500

    while true do
        local wait = 1000
        local now = GetGameTimer()

        if now >= nextPedCheck then
            ped = PlayerPedId()
            nextPedCheck = now + 1500
        end

        if DoesEntityExist(ped) and not IsEntityDead(ped) and IsPedOnAnyBike(ped) then
            wait = 0
            local _, weapon = GetCurrentPedWeapon(ped)

            if weapon ~= UNARMED then
                -- Always allow drive-by shooting for any gun
                SetPlayerCanDoDriveBy(PlayerId(), true)

                -- Handle DB shotgun manually (FiveM normally disables it)
                if weapon == DB_SHOTGUN then
                    DisableControlAction(0, 26, true) -- disable cinematic cam key
                    if IsControlJustPressed(0, 24) and GetAmmoInPedWeapon(ped, DB_SHOTGUN) > 0 then
                        local camCoords = GetGameplayCamCoord()
                        local dir = GetCamDir()
                        local coords = camCoords + (dir * 1000.0)
                        SetPedShootsAtCoord(ped, coords.x, coords.y, coords.z, true)
                    end
                end

                -- Keep camera in third-person
                if GetFollowVehicleCamViewMode() ~= 0 then
                    SetFollowVehicleCamViewMode(0)
                end
            else
                -- Player is UNARMED - enable melee combat on bike
                SetPlayerCanDoDriveBy(PlayerId(), true)
                SetPedConfigFlag(ped, 35, false)  -- Enable melee attacks
                SetPedCanBeKnockedOffVehicle(ped, 1)
            end
        else
            Wait(500)
        end

        Wait(wait)
    end
end)
