---@diagnostic disable: undefined-global
-- Daily reward client - triggers automatically on spawn
AddEventHandler('playerSpawned', function()
    Wait(5000) -- Wait 5 seconds after spawn
    TriggerServerEvent('drp_dailyreward:checkAndClaim')
end)
