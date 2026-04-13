---@type table<string, number>
local levels = {}

MySQL.ready(function()
    local data = MySQL.query.await('SELECT * FROM drp_fishing')

    for _, entry in ipairs(data) do
        levels[entry.user_identifier] = entry.xp
    end
end)

local function save()
    local query = 'UPDATE drp_fishing SET xp = ? WHERE user_identifier = ?'
    local parameters = {}
    local size = 0

    for identifier, level in pairs(levels) do
        size += 1
        parameters[size] = {
            level,
            identifier
        }
    end

    if size > 0 then
        print('Saving player progress.')
        MySQL.prepare.await(query, parameters)
    end
end

lib.cron.new('*/10 * * * *', save)
AddEventHandler('txAdmin:events:serverShuttingDown', save)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining ~= 60 then return end

	save()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == cache.resource then
		save()
	end
end)


local function createPlayer(identifier)
    levels[identifier] = 1.0
    MySQL.insert.await('INSERT INTO drp_fishing (user_identifier, xp) VALUES(?, ?)', { identifier, levels[identifier] })
end

lib.callback.register('drp_fishing:getLevel', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local identifier = xPlayer.getIdentifier()

    if not levels[identifier] then
        createPlayer(identifier)
    end

    return levels[identifier]
end)

---@param xPlayer table
---@param amount number
function AddPlayerLevel(xPlayer, amount)
    local identifier = xPlayer.getIdentifier()
    local level = math.floor(levels[identifier])

    levels[identifier] += amount

    if math.floor(levels[identifier]) - level > 0 then
        TriggerClientEvent('drp_fishing:showNotification', xPlayer.source, locale('unlocked_level'), 'success')
    end

    TriggerClientEvent('drp_fishing:updateLevel', xPlayer.source, levels[identifier])
end

---@param xPlayer table
function GetPlayerLevel(xPlayer)
    return levels[xPlayer.getIdentifier()]
end