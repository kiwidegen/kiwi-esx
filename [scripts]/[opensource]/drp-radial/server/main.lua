-- server/main.lua
local ESX = exports["es_extended"]:getSharedObject()

-- Existing elevator teleport event
RegisterServerEvent('elevator:teleportGroup')
AddEventHandler('elevator:teleportGroup', function(playerIds, coords)
    for _, playerId in ipairs(playerIds) do
        TriggerClientEvent('elevator:teleportClient', playerId, coords)
    end
end)

-- Share Contact event for LB Phone
RegisterServerEvent('drp-radial:shareContact')
AddEventHandler('drp-radial:shareContact', function(target, shareData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer and xTarget then
        local phoneNumber = exports["lb-phone"]:GetPhoneNumber(source) or shareData.number
        local contactData = {
            number = phoneNumber,
            firstname = shareData.firstname,
            lastname = shareData.lastname or "",
            email = shareData.email or "",
            address = shareData.address or "",
            avatar = shareData.avatar or ""
        }
        -- Notify target and add contact via LB Phone event
        TriggerClientEvent('ox_lib:notify', target, {
            title = "New Contact",
            description = "Received contact: " .. contactData.firstname .. " (" .. contactData.number .. ")",
            type = 'success',
            position = 'top-right'
        })
        -- Use LB Phone's receiveAirShare event
        TriggerClientEvent('phone:client:ReceiveAirShare', target, "contact", contactData)
    end
end)

-- Force Flip event for unrestricted car flipping
RegisterServerEvent('drp-radial:forceFlip')
AddEventHandler('drp-radial:forceFlip', function(netId)
    local source = source
    -- Validate the vehicle exists and the player is near it
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        -- Trigger client-side event to flip the vehicle
        TriggerClientEvent('drp-radial:client:forceFlip', source, netId)
    end
end)