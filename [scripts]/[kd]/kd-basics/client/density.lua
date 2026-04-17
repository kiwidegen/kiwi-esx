-- ╔══════════════════════════════╗
-- ║          Density             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Density then return end

local cfg = Config.Density

-- pre-computed values swapped on zone enter/exit
local dParked, dVehicle, dMultiplier = cfg.parked, cfg.vehicle, cfg.multiplier

-- constant values cached as locals — avoids table lookup every frame
local cPeds        = cfg.peds
local cScenIn      = cfg.scenarioInterior
local cScenEx      = cfg.scenarioExterior
local cSuppCops    = cfg.suppressCops

-- ─── Dispatch suppression (called once — persistent) ─────────────────────────

if cfg.suppressCops then
    for i = 1, 7 do EnableDispatchService(i, false) end  -- all police/swat dispatch
end
if cfg.suppressEMS then
    EnableDispatchService(5, false)  -- ambulance dispatch
end

-- ─── Highway zone ─────────────────────────────────────────────────────────────

lib.zones.poly({
    points    = Config.Density.highway,
    thickness = Config.Density.highwayThickness,
    onEnter   = function()
        dParked     = cfg.parked     * cfg.highwayMultiplier
        dVehicle    = cfg.vehicle    * cfg.highwayMultiplier
        dMultiplier = cfg.multiplier * cfg.highwayMultiplier
    end,
    onExit = function()
        dParked     = cfg.parked
        dVehicle    = cfg.vehicle
        dMultiplier = cfg.multiplier
    end,
})

-- ─── Density loop ─────────────────────────────────────────────────────────────
-- Wait(0) required — *ThisFrame natives reset every frame if not called

CreateThread(function()
    while true do
        SetParkedVehicleDensityMultiplierThisFrame(dParked)
        SetVehicleDensityMultiplierThisFrame(dVehicle)
        SetRandomVehicleDensityMultiplierThisFrame(dMultiplier)
        SetPedDensityMultiplierThisFrame(cPeds)
        SetScenarioPedDensityMultiplierThisFrame(cScenIn, cScenEx)
        if cSuppCops then
            SetCreateRandomCops(false)
            SetCreateRandomCopsNotOnScenarios(false)
        end
        -- EMS suppressed via scenarioInterior/scenarioExterior = 0.0 above
        Wait(0)
    end
end)
