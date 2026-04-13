-- Module guard (server-side check)
if not Config or not ExtrasConfig.Modules or not ExtrasConfig.Modules.Carry then return end

--============================================================
--  CARRY PLAYERS SERVER MODULE
--============================================================

local carrying = {}
--carrying[source] = targetSource, source is carrying targetSource
local carried = {}
--carried[targetSource] = source, targetSource is being carried by source

--- Sync carry between players
---@param targetSrc number Target player server ID
RegisterServerEvent("drp_extras:carry:sync")
AddEventHandler("drp_extras:carry:sync", function(targetSrc)
    local source = source

    -- SECURITY: Validate player IDs exist
    if not GetPlayerPed(source) or source == 0 then return end
    if not GetPlayerPed(targetSrc) or targetSrc == 0 then return end

    -- SECURITY: Can't carry yourself
    if source == targetSrc then
        return
    end

    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)

    -- SECURITY: Verify distance to prevent teleport exploits
    if #(sourceCoords - targetCoords) <= 3.0 then
        TriggerClientEvent("drp_extras:carry:syncTarget", targetSrc, source)
        carrying[source] = targetSrc
        carried[targetSrc] = source
    end
end)

--- Stop carrying
---@param targetSrc number Target player server ID
RegisterServerEvent("drp_extras:carry:stop")
AddEventHandler("drp_extras:carry:stop", function(targetSrc)
    local source = source

    if carrying[source] then
        TriggerClientEvent("drp_extras:carry:stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("drp_extras:carry:stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)

--- Cleanup on player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source

    if carrying[source] then
        TriggerClientEvent("drp_extras:carry:stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("drp_extras:carry:stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)
