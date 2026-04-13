-- Module guard
if not ExtrasConfig.Modules.NoNPC then return end

--============================================================
--  NO NPC MODULE
--  Disables ambient NPCs, vehicles, and scenarios
--============================================================

CreateThread(function()
    -- Set these once on startup
    SetGarbageTrucks(false)
    SetRandomBoats(false)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)

    while true do
        -- Disable ambient peds and vehicles (needs to be done every frame)
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetPedDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

        Wait(0)
    end
end)
