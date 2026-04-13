---@diagnostic disable: missing-parameter, param-type-mismatch

ESX = exports['es_extended']:getSharedObject()

---@class ActiveCarry
---@field carrier number Server ID of carrier
---@field target number Server ID of target
---@field type 'carry'|'drag' Type of carry

---@type table<number, ActiveCarry> Active carries indexed by carrier ID
local activeCarries = {}

--- Get player from source
---@param source number Player source
---@return table|nil xPlayer ESX player object
local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

--- Check if player is police
---@param source number Player source
---@return boolean isPolice
local function isPolice(source)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    return xPlayer.job.name == 'police'
end

--- Get active carry by carrier ID
---@param carrierId number Carrier server ID
---@return ActiveCarry|nil carry Active carry data
local function getActiveCarry(carrierId)
    return activeCarries[carrierId]
end

--- Get active carry by target ID
---@param targetId number Target server ID
---@return ActiveCarry|nil carry Active carry data
local function getCarryByTarget(targetId)
    for carrierId, carry in pairs(activeCarries) do
        if carry.target == targetId then
            return carry
        end
    end
    return nil
end

--- Start a carry/drag
---@param source number Carrier source
---@param targetId number Target server ID
---@param carryType 'carry'|'drag' Type of carry
RegisterNetEvent('drp-carry:requestCarry', function(targetId, carryType)
    local source = source
    local xPlayer = getPlayer(source)
    if not xPlayer then return end

    local xTarget = getPlayer(targetId)
    if not xTarget then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'Target player not found',
            type = 'error'
        })
        return
    end

    -- Check if carrier is already carrying someone
    if getActiveCarry(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You are already carrying someone',
            type = 'error'
        })
        return
    end

    -- Check if target is already being carried
    if getCarryByTarget(targetId) then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'This person is already being carried',
            type = 'error'
        })
        return
    end

    -- Create carry record
    activeCarries[source] = {
        carrier = source,
        target = targetId,
        type = carryType
    }

    -- Sync to all clients
    TriggerClientEvent('drp-carry:syncCarry', -1, source, targetId, carryType)

    -- Notifications
    TriggerClientEvent('ox_lib:notify', source, {
        description = 'You started ' .. (carryType == 'carry' and 'carrying' or 'dragging') .. ' someone',
        type = 'inform'
    })
end)

--- Stop carrying/dragging
---@param source number Carrier source
RegisterNetEvent('drp-carry:stopCarry', function()
    local source = source
    local carry = getActiveCarry(source)

    if not carry then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You are not carrying anyone',
            type = 'error'
        })
        return
    end

    -- Remove carry record
    activeCarries[source] = nil

    -- Sync to all clients
    TriggerClientEvent('drp-carry:syncStop', -1, carry.carrier, carry.target)

    -- Notifications
    TriggerClientEvent('ox_lib:notify', source, {
        description = 'You stopped ' .. (carry.type == 'carry' and 'carrying' or 'dragging'),
        type = 'inform'
    })

    TriggerClientEvent('ox_lib:notify', carry.target, {
        description = 'You were released',
        type = 'inform'
    })
end)

--- Break free from carry (self-release)
---@param source number Target source
RegisterNetEvent('drp-carry:breakFree', function()
    local source = source
    local carry = getCarryByTarget(source)

    if not carry then return end

    -- Check if carrier is police (cannot break free from police)
    if isPolice(carry.carrier) then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You cannot break free from police escort',
            type = 'error'
        })
        return
    end

    -- Remove carry record
    activeCarries[carry.carrier] = nil

    -- Sync to all clients
    TriggerClientEvent('drp-carry:syncStop', -1, carry.carrier, carry.target)

    -- Notifications
    TriggerClientEvent('ox_lib:notify', carry.carrier, {
        description = 'The person broke free',
        type = 'error'
    })

    TriggerClientEvent('ox_lib:notify', source, {
        description = 'You broke free',
        type = 'success'
    })
end)

--- Pull player from vehicle
---@param source number Carrier source
---@param targetId number Target server ID
RegisterNetEvent('drp-carry:pullFromVehicle', function(targetId)
    local source = source
    local xPlayer = getPlayer(source)
    if not xPlayer then return end

    local xTarget = getPlayer(targetId)
    if not xTarget then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'Target player not found',
            type = 'error'
        })
        return
    end

    -- Sync pull from vehicle
    TriggerClientEvent('drp-carry:syncPullFromVehicle', targetId, targetId)

    -- Start dragging after a delay
    SetTimeout(1000, function()
        -- Check if carrier is still nearby
        local carrierCoords = GetEntityCoords(GetPlayerPed(source))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        local distance = #(carrierCoords - targetCoords)

        if distance < 5.0 then
            -- Create carry record
            activeCarries[source] = {
                carrier = source,
                target = targetId,
                type = 'drag'
            }

            -- Sync to all clients
            TriggerClientEvent('drp-carry:syncCarry', -1, source, targetId, 'drag')

            TriggerClientEvent('ox_lib:notify', source, {
                description = 'You pulled the person from the vehicle',
                type = 'inform'
            })
        end
    end)
end)

--- Place player in vehicle
---@param source number Carrier source
---@param targetId number Target server ID
---@param vehicleNet number Vehicle network ID
---@param seat number Seat index
RegisterNetEvent('drp-carry:placeInVehicle', function(targetId, vehicleNet, seat)
    local source = source
    local carry = getActiveCarry(source)

    if not carry or carry.target ~= targetId then
        TriggerClientEvent('ox_lib:notify', source, {
            description = 'You are not carrying this person',
            type = 'error'
        })
        return
    end

    -- Remove carry record
    activeCarries[source] = nil

    -- Sync place in vehicle
    TriggerClientEvent('drp-carry:syncPlaceInVehicle', -1, targetId, vehicleNet, seat)

    -- Notifications
    TriggerClientEvent('ox_lib:notify', source, {
        description = 'You placed the person in the vehicle',
        type = 'success'
    })

    TriggerClientEvent('ox_lib:notify', targetId, {
        description = 'You were placed in a vehicle',
        type = 'inform'
    })
end)

--- Check if carry is by police (for break free validation)
---@param source number Target source checking
---@param carrierId number Carrier server ID
RegisterNetEvent('drp-carry:checkPoliceCarry', function(carrierId)
    local source = source
    local allowed = not isPolice(carrierId)
    TriggerClientEvent('drp-carry:allowBreakFree', source, allowed)
end)

--- Clean up carries when player disconnects
AddEventHandler('playerDropped', function(reason)
    local source = source

    -- Check if player was carrying someone
    local carry = getActiveCarry(source)
    if carry then
        activeCarries[source] = nil
        TriggerClientEvent('drp-carry:syncStop', -1, carry.carrier, carry.target)
        TriggerClientEvent('ox_lib:notify', carry.target, {
            description = 'The person carrying you disconnected',
            type = 'error'
        })
    end

    -- Check if player was being carried
    carry = getCarryByTarget(source)
    if carry then
        activeCarries[carry.carrier] = nil
        TriggerClientEvent('drp-carry:syncStop', -1, carry.carrier, carry.target)
        TriggerClientEvent('ox_lib:notify', carry.carrier, {
            description = 'The person you were carrying disconnected',
            type = 'error'
        })
    end
end)

--- Export: Check if player is carrying someone
---@param source number Player source
---@return boolean isCarrying
exports('IsCarrying', function(source)
    return getActiveCarry(source) ~= nil
end)

--- Export: Check if player is being carried
---@param source number Player source
---@return boolean isBeingCarried
exports('IsBeingCarried', function(source)
    return getCarryByTarget(source) ~= nil
end)

--- Export: Get carry data for player
---@param source number Player source
---@return ActiveCarry|nil carry Carry data if exists
exports('GetCarryData', function(source)
    local carry = getActiveCarry(source)
    if carry then return carry end
    return getCarryByTarget(source)
end)

--- Export: Force stop carry
---@param source number Player source (carrier or target)
exports('ForceStopCarry', function(source)
    local carry = getActiveCarry(source)
    if not carry then
        carry = getCarryByTarget(source)
    end

    if carry then
        activeCarries[carry.carrier] = nil
        TriggerClientEvent('drp-carry:syncStop', -1, carry.carrier, carry.target)
    end
end)
