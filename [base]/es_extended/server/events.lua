GlobalState.playerCount = 0

-- Tell ox_inventory this server is running ESX
SetConvarReplicated('inventory:framework', 'esx')
SetConvarReplicated('inventory:weight',    '24000')

-- ─────────────────────────────────────────────────────────────────────────────
-- DB startup
-- ─────────────────────────────────────────────────────────────────────────────

local function startDBSync()
    CreateThread(function()
        local interval <const> = 10 * 60 * 1000
        while true do
            Wait(interval)
            Core.SavePlayers()
        end
    end)
end

MySQL.ready(function()
    Core.DatabaseConnected = true
    ESX.RefreshJobs()
    print('[^2INFO^7] ESX lean core initialized!')
    startDBSync()
    if Config.EnablePaycheck then startPaycheck() end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Player joining
-- ─────────────────────────────────────────────────────────────────────────────

AddEventHandler('playerConnecting', function(_, _, deferrals)
    local playerId = source
    deferrals.defer()
    Wait(0)

    if not SetEntityOrphanMode then
        return deferrals.done('[ESX] Server artifact version too old (minimum 10188).')
    end

    local onesync = GetConvar('onesync', 'off')
    if onesync == 'off' or onesync == 'legacy' then
        return deferrals.done(('[ESX] OneSync Infinity required. Current setting: %s'):format(onesync))
    end

    if not Core.DatabaseConnected then
        return deferrals.done('[ESX] Database not connected — check oxmysql config.')
    end

    local ok, identifier = pcall(ESX.GetIdentifier, playerId)
    if not ok or not identifier then
        return deferrals.done('[ESX] Could not retrieve your identifier. Please try again.')
    end

    local existing = ESX.GetPlayerFromIdentifier(identifier)
    if existing and GetPlayerPing(tostring(existing.source)) > 0 then
        return deferrals.done(('[ESX] Identifier already active on this server: %s'):format(identifier))
    end

    deferrals.done()
end)

RegisterNetEvent('esx:onPlayerJoined', function()
    local playerId   = source
    local identifier = ESX.GetIdentifier(playerId)

    if not identifier then
        return DropPlayer(playerId, '[ESX] Missing identifier.')
    end

    if ESX.Players[playerId] then return end

    while not Core.JobsLoaded do Wait(50) end

    local exists = MySQL.scalar.await('SELECT 1 FROM users WHERE identifier = ?', { identifier })
    if exists then
        loadESXPlayer(identifier, playerId, false)
    else
        createESXPlayer(identifier, playerId)
    end
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
    local xPlayer = ESX.Players[source]
    if not xPlayer then return end
    xPlayer.spawned = true
    if Config.SaveDeathStatus then
        xPlayer.setMeta('dead', false)
    end
end)

RegisterNetEvent('esx:onPlayerDeath', function(data)
    local xPlayer = ESX.Players[source]
    if not xPlayer then return end
    if Config.SaveDeathStatus then
        xPlayer.setMeta('dead', true)
    end
    TriggerEvent('esx:onPlayerDeath', source, xPlayer, data)
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local xPlayer  = ESX.Players[playerId]
    if not xPlayer then return end

    TriggerEvent('esx:playerDropped', playerId, reason)

    local job = xPlayer.getJob().name
    Core.JobsPlayerCount[job] = math.max(0, (Core.JobsPlayerCount[job] or 1) - 1)
    GlobalState[('%s:count'):format(job)] = Core.JobsPlayerCount[job]

    Core.SavePlayer(xPlayer, function()
        GlobalState.playerCount                  -= 1
        ESX.Players[playerId]                     = nil
        Core.playersByIdentifier[xPlayer.identifier] = nil
    end)
end)

-- Multichar / explicit logout path
AddEventHandler('esx:playerLogout', function(playerId, cb)
    local xPlayer = ESX.Players[playerId]
    if not xPlayer then return cb and cb() end

    TriggerEvent('esx:playerDropped', playerId, 'esx_player_logout')
    TriggerClientEvent('esx:onPlayerLogout', playerId)

    local job = xPlayer.getJob().name
    Core.JobsPlayerCount[job] = math.max(0, (Core.JobsPlayerCount[job] or 1) - 1)
    GlobalState[('%s:count'):format(job)] = Core.JobsPlayerCount[job]

    Core.SavePlayer(xPlayer, function()
        GlobalState.playerCount                  -= 1
        ESX.Players[playerId]                     = nil
        Core.playersByIdentifier[xPlayer.identifier] = nil
        if cb then cb() end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Job / group count tracking
-- ─────────────────────────────────────────────────────────────────────────────

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
    local job = xPlayer.getJob().name
    Core.JobsPlayerCount[job] = (Core.JobsPlayerCount[job] or 0) + 1
    GlobalState[('%s:count'):format(job)] = Core.JobsPlayerCount[job]
    if isNew then Player(xPlayer.source).state:set('isNew', true, false) end
    exports.ox_inventory:setPlayerInventory(xPlayer)
end)

AddEventHandler('esx:setJob', function(src, job, lastJob)
    Core.JobsPlayerCount[lastJob.name] = math.max(0, (Core.JobsPlayerCount[lastJob.name] or 1) - 1)
    Core.JobsPlayerCount[job.name]     = (Core.JobsPlayerCount[job.name] or 0) + 1
    GlobalState[('%s:count'):format(lastJob.name)] = Core.JobsPlayerCount[lastJob.name]
    GlobalState[('%s:count'):format(job.name)]     = Core.JobsPlayerCount[job.name]
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Paycheck
-- ─────────────────────────────────────────────────────────────────────────────

function startPaycheck()
    CreateThread(function()
        while true do
            Wait(Config.PaycheckInterval)
            for _, xPlayer in pairs(ESX.Players) do
                if xPlayer.spawned and xPlayer.isPaycheckEnabled() then
                    local salary = xPlayer.getJob().grade_salary or 0
                    if salary > 0 then
                        xPlayer.addAccountMoney('bank', salary, 'paycheck')
                        xPlayer.triggerEvent('esx:notify', {
                            title       = 'Paycheck',
                            description = ('Received $%s from your job'):format(salary),
                            type        = 'inform',
                        })
                    end
                end
            end
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- txAdmin hooks — save before restart / shutdown
-- ─────────────────────────────────────────────────────────────────────────────

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            Core.SavePlayers()
        end)
    end
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    Core.SavePlayers()
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Conflict guard — stop resources that break ESX
-- ─────────────────────────────────────────────────────────────────────────────

local conflictResources = {
    essentialmode = true, ['es_admin2'] = true, ['basic-gamemode'] = true,
    mapmanager = true, ['qb-core'] = true, ['default_spawnpoint'] = true,
}

AddEventHandler('onResourceStart', function(key)
    if conflictResources[string.lower(key)] then
        Wait(0)
        StopResource(key)
        error(('ESX: stopped conflicting resource "%s"'):format(key))
    end
end)

for key in pairs(conflictResources) do
    local state = GetResourceState(key)
    if state == 'started' or state == 'starting' then
        StopResource(key)
        error(('ESX: stopped conflicting resource "%s"'):format(key))
    end
end
