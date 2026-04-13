---@param source integer
---@param fishName string
---@param amount integer
lib.callback.register('drp-fishing:sellFish', function(source, fishName, amount)
    local item = Config.fish[fishName]
    local price = type(item.price) == 'number' and item.price or math.random(item.price.min, item.price.max)

    ---@cast price number

    if not item or amount <= 0 then return end

    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if xPlayer.getInventoryItem(fishName).count >= amount then
        SetTimeout(3000, function()
            if xPlayer.getInventoryItem(fishName).count < amount then return end

            xPlayer.removeInventoryItem(fishName, amount)
            xPlayer.addAccountMoney(Config.ped.sellAccount, price * amount)
        end)

        return true
    end

    return false
end)

---@param source integer
---@param amount integer
lib.callback.register('drp-fishing:buy', function(source, data, amount)
    local type, index in data

    if type ~= 'fishingRods' and type ~= 'baits' then return end

    local item = Config[type][index]
    local price = item.price * amount

    if not item or amount <= 0 then return end

    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer
    or GetPlayerLevel(xPlayer) < item.minLevel then return end

    if xPlayer.getAccount(Config.ped.buyAccount).money >= price then
        SetTimeout(3000, function()
            if xPlayer.getAccount(Config.ped.buyAccount).money < price then return end

            xPlayer.removeAccountMoney(Config.ped.buyAccount, price)
            xPlayer.addInventoryItem(item.name, amount)
        end)

        return true
    end

    return false
end)