local Config = require("config.config")

Citizen.CreateThread(function()
    while(true) do
        SetPedDensityMultiplierThisFrame(Config.pedDensityMultiplier)
        SetScenarioPedDensityMultiplierThisFrame(Config.ScenarioPedDensityMultiplier.interiorMult, Config.ScenarioPedDensityMultiplier.exteriorMult)
        SetParkedVehicleDensityMultiplierThisFrame(Config.parkedVehicleDensityMultiplier)
        SetRandomVehicleDensityMultiplierThisFrame(Config.randomVehicleDensityMultiplier)
        SetVehicleDensityMultiplierThisFrame(Config.vehicleDensityMultiplier)
        Citizen.Wait(0)
    end
end)