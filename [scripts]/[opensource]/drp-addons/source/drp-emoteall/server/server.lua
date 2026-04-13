---@diagnostic disable: undefined-global
--- Trigger emote for multiple players
RegisterNetEvent("drp_emoteall:trigger", function(serverIds, emote)
    for _, targetId in ipairs(serverIds) do
        TriggerClientEvent("drp_emoteall:execute", targetId, emote)
    end
end)
