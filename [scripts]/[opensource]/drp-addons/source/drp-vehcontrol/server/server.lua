---@diagnostic disable: undefined-global
-- Emergency Vehicle Control - Server-side sync

--- Sync turn signal state to all clients
RegisterServerEvent('drp_vehcontrol:TogIndicState')
AddEventHandler('drp_vehcontrol:TogIndicState', function(newstate)
    local source = source
    TriggerClientEvent('drp_vehcontrol:TogIndicState', -1, source, newstate)
end)

--- Sync default siren mute state to all clients
RegisterServerEvent('drp_vehcontrol:TogDfltSrnMuted')
AddEventHandler('drp_vehcontrol:TogDfltSrnMuted', function(toggle)
    local source = source
    TriggerClientEvent('drp_vehcontrol:TogDfltSrnMuted', -1, source, toggle)
end)

--- Sync siren state to all clients
RegisterServerEvent('drp_vehcontrol:SetLxSirenState')
AddEventHandler('drp_vehcontrol:SetLxSirenState', function(newstate)
    local source = source
    TriggerClientEvent('drp_vehcontrol:SetLxSirenState', -1, source, newstate)
end)

--- Sync powercall state to all clients
RegisterServerEvent('drp_vehcontrol:TogPwrcallState')
AddEventHandler('drp_vehcontrol:TogPwrcallState', function(toggle)
    local source = source
    TriggerClientEvent('drp_vehcontrol:TogPwrcallState', -1, source, toggle)
end)

--- Sync air horn/manual control state to all clients
RegisterServerEvent('drp_vehcontrol:SetAirManuState')
AddEventHandler('drp_vehcontrol:SetAirManuState', function(newstate)
    local source = source
    TriggerClientEvent('drp_vehcontrol:SetAirManuState', -1, source, newstate)
end)
