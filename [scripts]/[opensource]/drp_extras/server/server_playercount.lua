--============================================================
--  PLAYER COUNT TRACKING SERVER MODULE
--  Broadcasts player count to clients for display purposes
--============================================================

--- Broadcast player count when player drops
AddEventHandler("playerDropped", function()
    TriggerClientEvent("drp_extras:playercount", -1, #GetPlayers())
end)

--- Broadcast player count when player joins
AddEventHandler("playerJoining", function()
    TriggerClientEvent("drp_extras:playercount", -1, #GetPlayers())
end)

--- Allow clients to request player count
RegisterNetEvent("drp_extras:playercount:request", function()
    TriggerClientEvent("drp_extras:playercount", source, #GetPlayers())
end)
