---@diagnostic disable: undefined-global
--- Sync spotlight state to all clients
---@param vehicle number Vehicle entity handle
---@param state boolean Spotlight state
RegisterNetEvent("drp_helicam:spotlight", function(vehicle, state)
    TriggerClientEvent("drp_helicam:spotlight", -1, vehicle, state)
end)

--- Handle helicam toggle (for future features like notifications)
---@param active boolean Whether helicam is active
RegisterNetEvent("drp_helicam:toggle", function(active)
    local source = source
    -- Reserved for future features (e.g., notify police of active surveillance)
end)
