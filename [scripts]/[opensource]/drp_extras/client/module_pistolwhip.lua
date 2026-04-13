if not ExtrasConfig.Modules.PistolWhip then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('PistolWhip module loaded')

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedArmed(ped, 6) then
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
        end
        Wait(0)
    end
end)
