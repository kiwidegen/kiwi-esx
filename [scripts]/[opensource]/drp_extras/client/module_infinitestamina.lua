-- Module guard
if not ExtrasConfig.Modules.InfiniteStamina then return end

--============================================================
--  INFINITE STAMINA MODULE
--============================================================

CreateThread(function()
    while true do
        -- Restore player stamina (only needs to run every 100ms)
        RestorePlayerStamina(PlayerId(), 1.0)

        Wait(100)
    end
end)
