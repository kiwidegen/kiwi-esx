-- Module guard (server-side check)
if not Config or not ExtrasConfig.Modules or not ExtrasConfig.Modules.CombatLog then return end

--============================================================
--  COMBAT LOG NOTIFICATION SERVER MODULE
--============================================================

--- Send disconnect notification to nearby players
---@param playerName string Player name
---@param reason string Disconnect reason
---@param playerTargetPosition vector3 Player position
local function SendDisconnectToAllPlayers(playerName, reason, playerTargetPosition)
    for key, value in pairs(GetPlayers()) do
        local playerPed = GetPlayerPed(value)
        local playerPosition = GetEntityCoords(playerPed)
        local distance = #(playerPosition - playerTargetPosition)

        if (ExtrasConfig.CombatLogRange >= distance) then
            local xPlayer = ESX.GetPlayerFromId(value)

            if (xPlayer) then
                TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                    description = string.format(ExtrasConfig.CombatLogMessage, playerName, reason),
                    type = 'inform'
                })
            end
        end
    end
end

--- Notify nearby players when someone disconnects
AddEventHandler("playerDropped", function(reason)
    SendDisconnectToAllPlayers(GetPlayerName(source), reason, GetEntityCoords(GetPlayerPed(source)))
end)
