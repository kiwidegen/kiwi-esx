---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()

--- Check if player has enough money and remove it
---@param source number Player source
---@param callback function Callback function
---@param price number Wash price
ESX.RegisterServerCallback('drp_carwash:checkMoney', function(source, callback, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        callback(false)
        return
    end

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        callback(true)
    else
        callback(false)
    end
end)
