-- ╔══════════════════════════════╗
-- ║          Max Speed           ║
-- ╚══════════════════════════════╝
if not Config.Modules.MaxSpeed then return end

local cfg = Config.MaxSpeed

lib.onCache('vehicle', function(vehicle)
    if vehicle then
        SetVehicleMaxSpeed(vehicle, cfg.maxKMH / 3.6)
    end
end)
