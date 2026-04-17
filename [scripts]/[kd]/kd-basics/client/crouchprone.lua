-- ╔══════════════════════════════╗
-- ║        Crouch / Prone        ║
-- ╚══════════════════════════════╝
if not Config.Modules.CrouchProne then return end

local crouched = false

lib.addKeybind({
    name        = 'crouch',
    description = 'Toggle Crouch',
    defaultKey  = 'LCONTROL',
    onPressed   = function()
        crouched = not crouched
        if crouched then
            CreateThread(function()
                RequestAnimSet('move_ped_crouched')
                while not HasAnimSetLoaded('move_ped_crouched') do Wait(0) end
                SetPedMovementClipset(cache.ped, 'move_ped_crouched', 0.25)
            end)
        else
            ResetPedMovementClipset(cache.ped, 0)
        end
    end,
})
