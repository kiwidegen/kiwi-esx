math.randomseed(os.time())

---@param first { price: integer }
---@param second { price: integer }
local function sortByPrice(first, second)
    return first.price < second.price
end

table.sort(Config.fishingRods, sortByPrice)
table.sort(Config.baits, sortByPrice)

for _, zone in ipairs(Config.fishingZones) do
    if zone.includeOutside then
        for _, fishName in ipairs(Config.outside.fishList) do
            table.insert(zone.fishList, fishName)
        end
    end
end

---@param fish string[]
local function getRandomFish(fish)
    local sum = 0

    for _, fishName in ipairs(fish) do
        sum += Config.fish[fishName].chance
    end

    sum = math.floor(sum)

    local value = math.random(sum)
    local last = 1

    for i = 1, #fish do
        local current = Config.fish[fish[i]].chance

        if value >= last and value < last + current then
            return fish[i]
        end

        last += current
    end
end

---@param xPlayer table
---@return FishingBait?
local function getBestBait(xPlayer)
    for i = #Config.baits, 1, -1 do
        local bait = Config.baits[i]

        if xPlayer.getInventoryItem(bait.name).count > 0 then
            return bait
        end
    end
end

---@type table<integer, boolean>
local busy = {}

for _, rod in ipairs(Config.fishingRods) do
    ESX.RegisterUsableItem(rod.name, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)

        if not xPlayer or xPlayer.getInventoryItem(rod.name).count == 0 or busy[source] then return end

        busy[source] = true

        ---@type boolean, { index: integer, locationIndex: integer }?
        local hasWater, currentZone = lib.callback.await('drp-fishing:getCurrentZone', source)

        if not hasWater then
            busy[source] = nil
            return
        end

        -- Check if it's possible for the player to be in that zone
        if currentZone then
            local data = Config.fishingZones[currentZone.index]
            local coords = data.locations[currentZone.locationIndex]

            if #(GetEntityCoords(GetPlayerPed(source)) - coords) > data.radius then
                busy[source] = nil
                return
            end
        end

        local fishList = currentZone and Config.fishingZones[currentZone.index].fishList or Config.outside.fishList
        local bait = getBestBait(xPlayer)

        if not bait then
            TriggerClientEvent('drp-fishing:showNotification', source, locale('no_bait'), 'error')
            busy[source] = nil
            return
        end

        local fishName = getRandomFish(fishList)

        if not xPlayer.canCarryItem(fishName, 1) then
            busy[source] = nil
            return
        end

        xPlayer.removeInventoryItem(bait.name, 1)
        local success = lib.callback.await('drp-fishing:itemUsed', source, bait, Config.fish[fishName])

        if success then
            xPlayer.addInventoryItem(fishName, 1)
            AddPlayerLevel(xPlayer, Config.progressPerCatch)
            Utils.logToDiscord(source, xPlayer, ('Caught a %s.'):format(Utils.getItemLabel(fishName)))
        elseif math.random(100) <= rod.breakChance then
            xPlayer.removeInventoryItem(rod.name, 1)
            TriggerClientEvent('drp-fishing:showNotification', source, locale('rod_broke'), 'error')
        end

        busy[source] = nil
    end)
end
