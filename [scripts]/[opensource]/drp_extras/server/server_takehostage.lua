-- Module guard (server-side check)
if not Config or not ExtrasConfig.Modules or not ExtrasConfig.Modules.TakeHostage then return end

--============================================================
--  TAKE HOSTAGE SERVER MODULE
--============================================================

local takingHostage = {}
--takingHostage[source] = targetSource, source is taking targetSource hostage
local takenHostage = {}
--takenHostage[targetSource] = source, targetSource is being taken hostage by source

--- Sync take hostage between players
---@param targetSrc number Target player server ID
RegisterServerEvent("drp_extras:takehostage:sync")
AddEventHandler("drp_extras:takehostage:sync", function(targetSrc)
    local source = source

    -- SECURITY: Validate player IDs exist
    if not GetPlayerPed(source) or source == 0 then return end
    if not GetPlayerPed(targetSrc) or targetSrc == 0 then return end

    -- SECURITY: Can't take yourself hostage
    if source == targetSrc then
        return
    end

    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)

    -- SECURITY: Verify distance to prevent teleport exploits
    if #(sourceCoords - targetCoords) <= 3.0 then
        TriggerClientEvent("drp_extras:takehostage:syncTarget", targetSrc, source)
        takingHostage[source] = targetSrc
        takenHostage[targetSrc] = source
    end
end)

--- Release hostage
---@param targetSrc number Target player server ID
RegisterServerEvent("drp_extras:takehostage:release")
AddEventHandler("drp_extras:takehostage:release", function(targetSrc)
    local source = source

    -- SECURITY: Only allow release if source is actually taking them hostage
    if takingHostage[source] == targetSrc and takenHostage[targetSrc] == source then
        TriggerClientEvent("drp_extras:takehostage:release", targetSrc)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    end
end)

--- Kill hostage
---@param targetSrc number Target player server ID
RegisterServerEvent("drp_extras:takehostage:kill")
AddEventHandler("drp_extras:takehostage:kill", function(targetSrc)
    local source = source

    -- SECURITY: Only allow killing hostage if source is actually taking them hostage
    if takingHostage[source] == targetSrc and takenHostage[targetSrc] == source then
        TriggerClientEvent("drp_extras:takehostage:kill", targetSrc)
    end
end)

--- Stop take hostage
---@param targetSrc number Target player server ID
RegisterServerEvent("drp_extras:takehostage:stop")
AddEventHandler("drp_extras:takehostage:stop", function(targetSrc)
    local source = source

    if takingHostage[source] then
        TriggerClientEvent("drp_extras:takehostage:stop", targetSrc)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    elseif takenHostage[source] then
        TriggerClientEvent("drp_extras:takehostage:stop", takenHostage[source])
        takingHostage[takenHostage[source]] = nil
        takenHostage[source] = nil
    end
end)

--- Cleanup on player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source

    if takingHostage[source] then
        TriggerClientEvent("drp_extras:takehostage:stop", takingHostage[source])
        takenHostage[takingHostage[source]] = nil
        takingHostage[source] = nil
    end

    if takenHostage[source] then
        TriggerClientEvent("drp_extras:takehostage:stop", takenHostage[source])
        takingHostage[takenHostage[source]] = nil
        takenHostage[source] = nil
    end
end)
