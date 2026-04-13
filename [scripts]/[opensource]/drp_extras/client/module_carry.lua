-- Module guard
if not ExtrasConfig.Modules.Carry then return end

--============================================================
--  CARRY PLAYERS MODULE
--============================================================

---@class CarryData
---@field InProgress boolean Whether carry is in progress
---@field targetSrc number Target player server ID
---@field type string Type of carry ("carrying" or "beingcarried")
---@field personCarrying table Animation data for person carrying
---@field personCarried table Animation data for person being carried

local carry = {
    InProgress = false,
    targetSrc = -1,
    type = "",
    personCarrying = {
        animDict = "missfinale_c2mcs_1",
        anim = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    personCarried = {
        animDict = "nm",
        anim = "firemans_carry",
        attachX = 0.27,
        attachY = 0.15,
        attachZ = 0.63,
        flag = 33,
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

--- Toggle carry command
RegisterCommand("carry", function(source, args)
    if not carry.InProgress then
        local closestPlayer = GetClosestPlayer(3)
        if closestPlayer then
            local targetSrc = GetPlayerServerId(closestPlayer)
            if targetSrc ~= -1 then
                carry.InProgress = true
                carry.targetSrc = targetSrc
                TriggerServerEvent("drp_extras:carry:sync", targetSrc)
                ensureAnimDict(carry.personCarrying.animDict)
                carry.type = "carrying"
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
    else
        carry.InProgress = false
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("drp_extras:carry:stop", carry.targetSrc)
        carry.targetSrc = 0
    end
end, false)

--- Sync carry target
---@param targetSrc number Target player server ID
RegisterNetEvent("drp_extras:carry:syncTarget", function(targetSrc)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    carry.InProgress = true
    ensureAnimDict(carry.personCarried.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY,
        carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
    carry.type = "beingcarried"
end)

--- Stop carry
RegisterNetEvent("drp_extras:carry:stop", function()
    carry.InProgress = false
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

--- Animation loop (optimized)
CreateThread(function()
    while true do
        if carry.InProgress then
            if carry.type == "beingcarried" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000,
                        carry.personCarried.flag, 0, false, false, false)
                end
            elseif carry.type == "carrying" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0,
                        100000, carry.personCarrying.flag, 0, false, false, false)
                end
            end
            Wait(0)
        else
            Wait(500)  -- Not carrying, check less frequently
        end
    end
end)
