-- ╔══════════════════════════════╗
-- ║          Hands Up            ║
-- ╚══════════════════════════════╝
if not Config.Modules.HandsUp then return end

local handsUp  = false
local animDict = 'missminuteman_1ig_2'
local animName = 'handsup_base'

CreateThread(function()
    lib.requestAnimDict(animDict)
end)

RegisterCommand('+handsup', function()
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) then return end

    if not handsUp then
        handsUp = true
        TaskPlayAnim(ped, animDict, animName, 8.0, 8.0, -1, 49, 0, false, false, false)
    else
        handsUp = false
        ClearPedTasks(ped)
    end
end, false)

RegisterCommand('-handsup', function() end, false)

RegisterKeyMapping('+handsup', 'Hands Up', 'keyboard', 'X')
