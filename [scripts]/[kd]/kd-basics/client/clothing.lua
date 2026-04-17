-- ╔══════════════════════════════╗
-- ║         Clothing             ║
-- ╚══════════════════════════════╝
if not Config.Modules.Clothing then return end

local cfg = Config.Clothing

-- ─── Damage prop lock ─────────────────────────────────────────────────────────

SetPedCanLosePropsOnDamage(cache.ped, false, 0)

lib.onCache('ped', function(ped)
    if not ped then return end
    SetPedCanLosePropsOnDamage(ped, false, 0)
    if LocalPlayer.state.helmetRestricted then
        SetPedHelmet(ped, false)
        SetPedConfigFlag(ped, 35, false)
        RemovePedHelmet(ped, true)
        ClearPedProp(ped, 0)
    end
end)

-- ─── No-helmet ────────────────────────────────────────────────────────────────
-- State bag tracks whether helmet should be blocked. Natives are called once on
-- state change — no polling loop.

if cfg.noHelmet then
    lib.onCache('vehicle', function(vehicle)
        local restricted = vehicle ~= nil and (function()
            local class = GetVehicleClass(vehicle)
            return class == 8 or class == 13 or class == 15
        end)()

        LocalPlayer.state:set('helmetRestricted', restricted, false)
    end)

    AddStateBagChangeHandler('helmetRestricted', ('player:%d'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
        if value then
            SetPedHelmet(cache.ped, false)
            SetPedConfigFlag(cache.ped, 35, false)
            RemovePedHelmet(cache.ped, true)
            ClearPedProp(cache.ped, 0)
        end
    end)
end
