-- Module guard
if not ExtrasConfig.Modules.TakeHostage then return end

--============================================================
--  TAKE HOSTAGE MODULE
--============================================================

---@class TakeHostageData
---@field allowedWeapons number[] Weapon hashes allowed for taking hostage
---@field InProgress boolean Whether hostage situation is in progress
---@field type string Type ("agressor" or "hostage")
---@field targetSrc number Target player server ID
---@field agressor table Animation data for aggressor
---@field hostage table Animation data for hostage

local takeHostage = {
    allowedWeapons = ExtrasConfig.TakeHostageWeapons or {
        `WEAPON_PISTOL`,
        `WEAPON_COMBATPISTOL`,
    },
    InProgress = false,
    type = "",
    targetSrc = -1,
    agressor = {
        animDict = "anim@gangops@hostage@",
        anim = "perp_idle",
        flag = 49,
    },
    hostage = {
        animDict = "anim@gangops@hostage@",
        anim = "victim_idle",
        attachX = -0.24,
        attachY = 0.11,
        attachZ = 0.0,
        flag = 49,
    }
}

--- Get the closest player within radius
---@param radius number Search radius in units
---@return number|nil playerId Closest player ID or nil
local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

--- Ensure animation dictionary is loaded
---@param animDict string Animation dictionary name
---@return string animDict The loaded animation dictionary
local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    return animDict
end

--- Take hostage command handler
RegisterCommand("th", function()
    callTakeHostage()
end)

--- Event handler for take hostage
RegisterNetEvent('drp_extras:takehostage:client', function()
    callTakeHostage()
end)

--- Main take hostage function
function callTakeHostage()
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)

    local canTakeHostage = false
    local foundWeapon = nil

    for i = 1, #takeHostage.allowedWeapons do
        if HasPedGotWeapon(PlayerPedId(), takeHostage.allowedWeapons[i], false) then
            if GetAmmoInPedWeapon(PlayerPedId(), takeHostage.allowedWeapons[i]) > 0 then
                canTakeHostage = true
                foundWeapon = takeHostage.allowedWeapons[i]
                break
            end
        end
    end

    if not canTakeHostage then
        lib.notify({
            description = 'You need a weapon with ammunition to take a hostage!',
            type = 'error'
        })
        return
    end

    if not takeHostage.InProgress and canTakeHostage then
        local closestPlayer = GetClosestPlayer(1)
        if closestPlayer then
            local targetSrc = GetPlayerServerId(closestPlayer)
            if targetSrc ~= -1 then
                SetCurrentPedWeapon(PlayerPedId(), foundWeapon, true)
                takeHostage.InProgress = true
                takeHostage.targetSrc = targetSrc
                TriggerServerEvent("drp_extras:takehostage:sync", targetSrc)
                ensureAnimDict(takeHostage.agressor.animDict)
                takeHostage.type = "agressor"
            else
                lib.notify({
                    description = 'No player nearby',
                    type = 'error'
                })
            end
        else
            lib.notify({
                description = 'No player nearby',
                type = 'error'
            })
        end
    end
end

--- Sync hostage target
---@param target number Target player server ID
RegisterNetEvent("drp_extras:takehostage:syncTarget", function(target)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    takeHostage.InProgress = true
    ensureAnimDict(takeHostage.hostage.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY,
        takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
    takeHostage.type = "hostage"
end)

--- Release hostage
RegisterNetEvent("drp_extras:takehostage:release", function()
    takeHostage.InProgress = false
    takeHostage.type = ""
    DetachEntity(PlayerPedId(), true, false)
    ensureAnimDict("reaction@shove")
    TaskPlayAnim(PlayerPedId(), "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
    Wait(250)
    ClearPedSecondaryTask(PlayerPedId())
end)

--- Kill hostage
RegisterNetEvent("drp_extras:takehostage:kill", function()
    takeHostage.InProgress = false
    takeHostage.type = ""
    SetEntityHealth(PlayerPedId(), 0)
    DetachEntity(PlayerPedId(), true, false)
    ensureAnimDict("anim@gangops@hostage@")
    TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

--- Stop take hostage
RegisterNetEvent("drp_extras:takehostage:stop", function()
    takeHostage.InProgress = false
    takeHostage.type = ""
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

--- Animation loop thread (optimized)
CreateThread(function()
    while true do
        if takeHostage.type == "agressor" or takeHostage.type == "hostage" then
            if takeHostage.type == "agressor" then
                if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000,
                        takeHostage.agressor.flag, 0, false, false, false)
                end
            elseif takeHostage.type == "hostage" then
                if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000,
                        takeHostage.hostage.flag, 0, false, false, false)
                end
            end
            Wait(0)
        else
            Wait(500)  -- Not in hostage situation, check less frequently
        end
    end
end)

--- Control handler thread (optimized)
CreateThread(function()
    local alreadyTakenHostage = false
    while true do
        local HostageTaken = false

        if takeHostage.InProgress and takeHostage.type == "agressor" then
            HostageTaken = true
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 25, true) -- disable aim
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisableControlAction(0, 21, true) -- disable sprint
            DisablePlayerFiring(PlayerPedId(), true)

            if IsEntityDead(PlayerPedId()) then
                takeHostage.type = ""
                takeHostage.InProgress = false
                ensureAnimDict("reaction@shove")
                TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("drp_extras:takehostage:release", takeHostage.targetSrc)
            end

            if IsDisabledControlJustPressed(0, 47) then -- release
                takeHostage.type = ""
                takeHostage.InProgress = false
                ensureAnimDict("reaction@shove")
                TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("drp_extras:takehostage:release", takeHostage.targetSrc)
            elseif IsDisabledControlJustPressed(0, 74) then -- kill
                takeHostage.type = ""
                takeHostage.InProgress = false
                ensureAnimDict("anim@gangops@hostage@")
                TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("drp_extras:takehostage:kill", takeHostage.targetSrc)
                TriggerServerEvent("drp_extras:takehostage:stop", takeHostage.targetSrc)
                Wait(100)
                SetPedShootsAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0)
            end
        elseif takeHostage.InProgress and takeHostage.type == "hostage" then
            DisableControlAction(0, 21, true)  -- disable sprint
            DisableControlAction(0, 24, true)  -- disable attack
            DisableControlAction(0, 25, true)  -- disable aim
            DisableControlAction(0, 47, true)  -- disable weapon
            DisableControlAction(0, 58, true)  -- disable weapon
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(0, 75, true)  -- disable exit vehicle
            DisableControlAction(27, 75, true) -- disable exit vehicle
            DisableControlAction(0, 22, true)  -- disable jump
            DisableControlAction(0, 32, true)  -- disable move up
            DisableControlAction(0, 268, true)
            DisableControlAction(0, 33, true)  -- disable move down
            DisableControlAction(0, 269, true)
            DisableControlAction(0, 34, true)  -- disable move left
            DisableControlAction(0, 270, true)
            DisableControlAction(0, 35, true)  -- disable move right
            DisableControlAction(0, 271, true)
        end

        if HostageTaken and not alreadyTakenHostage then
            alreadyTakenHostage = true
            lib.showTextUI('[H] Kill  \n[G] Release', {
                position = 'left-center',
                icon = 'hand-back-fist'
            })
        end

        if not HostageTaken and alreadyTakenHostage then
            alreadyTakenHostage = false
            lib.hideTextUI()
        end

        if HostageTaken then
            Wait(0)  -- Active hostage needs frame-perfect control
        else
            Wait(500)  -- Not active, check less frequently
        end
    end
end)
