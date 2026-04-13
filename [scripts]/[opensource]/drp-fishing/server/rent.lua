local pending = {}
local spawned = {}

lib.callback.register('drp-fishing:rentVehicle', function(source, index)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local boat = Config.renting.boats[index]

    if xPlayer.getAccount(Config.renting.account).money > boat.price then
        xPlayer.removeAccountMoney(Config.renting.account, boat.price)
        pending[source] = true
        return true
    end

    return false
end)

RegisterNetEvent('drp-fishing:registerBoat', function(netId)
    local source = source

    if pending[source] then
        spawned[netId] = true
        pending[source] = nil
    end
end)

local function getBoatPrice(vehicle)
    for _, boat in ipairs(Config.renting.boats) do
        if boat.model == GetEntityModel(vehicle) then
            return boat.price
        end
    end
end

lib.callback.register('drp-fishing:returnVehicle', function(source, netId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local price = getBoatPrice(vehicle) / Config.renting.returnDivider

    if not xPlayer
    or not price
    or not spawned[netId]
    or GetPedInVehicleSeat(vehicle, -1) ~= GetPlayerPed(source) then
        return
    end

    xPlayer.addAccountMoney(Config.renting.account, price)
    spawned[netId] = nil

    SetTimeout(1500, function()
        DeleteEntity(vehicle)
    end)

    return true
end)