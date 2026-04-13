if not ExtrasConfig.Modules.IdleCam then return end

---@diagnostic disable: undefined-global
Core.DebugPrint('IdleCam module loaded')

CreateThread(function()
    while true do
        InvalidateIdleCam()
        InvalidateVehicleIdleCam()
        Wait(15000)
    end
end)

if ExtrasConfig.DisableAmbientScenarios then
    CreateThread(function()
        Core.DebugPrint('Ambient Scenarios Disabled')
        SetScenarioTypeEnabled('WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN', false)
        SetScenarioTypeEnabled('WORLD_VEHICLE_PARK_PARALLEL', false)
        SetScenarioTypeEnabled('WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN_LOW', false)
        SetScenarioTypeEnabled('WORLD_VEHICLE_DRIVE_SOLO', false)
        SetScenarioTypeEnabled('WORLD_VEHICLE_DRIVE_PASSENGERS', false)
        SetScenarioTypeEnabled('WORLD_VEHICLE_DRIVE_PARKED', false)
    end)
end
