-- ╔══════════════════════════════╗
-- ║           Tackle             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Tackle then return end

local animDict = 'swimming@first_person@diving'
local animName = 'dive_run_fwd_-45_loop'

CreateThread(function()
    lib.requestAnimDict(animDict)
end)

local function doTackleAnim()
    local ped = cache.ped
    if IsPedRagdoll(ped) then return end

    if IsEntityPlayingAnim(ped, animDict, animName, 3) then
        ClearPedTasksImmediately(ped)
        return
    end

    TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 49, 0, false, false, false)
    Wait(250)
    ClearPedTasksImmediately(ped)
    SetPedToRagdoll(ped, 150, 150, 0, 0, 0, 0)
end

local function tackle()
    local targetId, _, dist = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.0, false)
    if not targetId or dist > 2.0 then return end
    TriggerServerEvent('kd-basics:tackle:tacklePlayer', GetPlayerServerId(targetId))
    doTackleAnim()
end

RegisterNetEvent('kd-basics:tackle:getTackled', function()
    SetPedToRagdoll(cache.ped, math.random(1000, 6000), math.random(1000, 6000), 0, 0, 0, 0)
end)

RegisterCommand('+tackle', function()
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) then return end
    if GetEntitySpeed(ped) <= 2.5 then return end
    tackle()
end, false)

RegisterCommand('-tackle', function() end, false)

RegisterKeyMapping('+tackle', 'Tackle Player', 'keyboard', 'G')
