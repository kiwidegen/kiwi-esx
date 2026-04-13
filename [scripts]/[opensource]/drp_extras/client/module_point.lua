if not ExtrasConfig.Modules.Point then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('Point module loaded')

local mp_pointing = false

RegisterCommand('point', function()
    local ped = PlayerPedId()

    if not mp_pointing then
        RequestAnimDict("anim@mp_point")
        while not HasAnimDictLoaded("anim@mp_point") do Wait(0) end
        SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
        SetPedConfigFlag(ped, 36, 1)
        TaskMoveNetworkByName(ped, "task_mp_pointing", 0.5, false, "anim@mp_point", 24)
        mp_pointing = true
    else
        RequestTaskMoveNetworkStateTransition(ped, "Stop")
        ClearPedSecondaryTask(ped)
        SetPedConfigFlag(ped, 36, 0)
        mp_pointing = false
    end
end, false)

RegisterKeyMapping('point', 'Point', 'keyboard', 'B')
