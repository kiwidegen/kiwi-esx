if not ExtrasConfig.Modules.CrouchProne then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('CrouchProne module loaded')

local crouched = false

RegisterCommand('crouch', function()
    crouched = not crouched
    local ped = PlayerPedId()

    if crouched then
        RequestAnimSet('move_ped_crouched')
        while not HasAnimSetLoaded('move_ped_crouched') do Wait(0) end
        SetPedMovementClipset(ped, 'move_ped_crouched', 0.25)
    else
        ResetPedMovementClipset(ped, 0)
    end
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL')
