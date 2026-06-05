-- ox_inventory bridge sets server.UseItem = ESX.UseItem.
-- Item usage is handled entirely by ox_inventory; this is a required stub.
function ESX.UseItem(source, item) end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player lookups
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.GetPlayerFromId(source)
    return ESX.Players[tonumber(source)]
end

function ESX.GetPlayerFromIdentifier(identifier)
    return Core.playersByIdentifier[identifier]
end

function ESX.GetPlayerIdFromIdentifier(identifier)
    return Core.playersByIdentifier[identifier]?.source
end

function ESX.IsPlayerLoaded(source)
    return ESX.Players[tonumber(source)] ~= nil
end

function ESX.GetExtendedPlayers(key, val, minimal)
    if not key then
        if minimal then
            local out = {}
            for src in pairs(ESX.Players) do out[#out + 1] = src end
            return out
        end
        return ESX.Table.ToArray(ESX.Players)
    end

    local result = {}
    for _, xPlayer in pairs(ESX.Players) do
        local match = (key == 'job' and xPlayer.job.name == val) or xPlayer[key] == val
        if match then
            result[#result + 1] = minimal and xPlayer.source or xPlayer
        end
    end
    return result
end

function ESX.GetNumPlayers(key, val)
    if not key then return #GetPlayers() end
    if key == 'job' then return Core.JobsPlayerCount[val] or 0 end
    return #ESX.GetExtendedPlayers(key, val)
end

ESX.GetPlayers = GetPlayers

-- ─────────────────────────────────────────────────────────────────────────────
-- Identifier
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.GetIdentifier(playerId)
    if GetConvarInt('sv_fxdkMode', 0) == 1 then return 'ESX-DEBUG-LICENSE' end

    playerId     = tostring(playerId)
    local idType = Config.Identifier
    local id     = GetPlayerIdentifierByType(playerId, idType)

    assert(id, ('[ESX] No %s identifier found for player %s'):format(idType, playerId))

    return id:gsub(('%s:'):format(idType), '')
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Jobs
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.DoesJobExist(job, grade)
    while not Core.JobsLoaded do Citizen.Wait(200) end
    return (ESX.Jobs[job] and ESX.Jobs[job].grades[tostring(grade)] ~= nil) or false
end

function ESX.GetJobs(jobType)
    while not Core.JobsLoaded do Citizen.Wait(200) end
    if not jobType then return ESX.Jobs end

    jobType = type(jobType) == 'string' and { jobType } or jobType
    local lookup, filtered = {}, {}
    for i = 1, #jobType do lookup[jobType[i]] = true end
    for name, obj in pairs(ESX.Jobs) do
        if lookup[obj.type] then filtered[name] = obj end
    end
    return filtered
end

function ESX.RefreshJobs()
    Core.JobsLoaded = false
    local Jobs = {}

    local jobs = MySQL.query.await('SELECT * FROM jobs')
    for _, v in ipairs(jobs) do
        Jobs[v.name] = v
        Jobs[v.name].grades = {}
    end

    local grades = MySQL.query.await('SELECT * FROM job_grades')
    for _, v in ipairs(grades) do
        if Jobs[v.job_name] then
            Jobs[v.job_name].grades[tostring(v.grade)] = v
        else
            print(('[^3WARNING^7] Ignoring grade for missing job "%s"'):format(v.job_name))
        end
    end

    for name, v in pairs(Jobs) do
        if ESX.Table.SizeOf(v.grades) == 0 then
            Jobs[name] = nil
            print(('[^3WARNING^7] Ignoring job "%s" — no grades found'):format(name))
        end
    end

    if not next(Jobs) then
        ESX.Jobs = {
            unemployed = {
                id = 0, name = 'unemployed', label = 'Unemployed', type = 'civ', whitelisted = false,
                grades = { ['0'] = { grade = 0, name = 'unemployed', label = 'Unemployed', salary = 200 } },
            }
        }
    else
        ESX.Jobs = Jobs
    end

    TriggerEvent('esx:jobsRefreshed')
    Core.JobsLoaded = true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Admin / ACE
-- ─────────────────────────────────────────────────────────────────────────────

function Core.IsPlayerAdmin(playerSrc)
    if type(playerSrc) ~= 'number' then return false end
    if IsPlayerAceAllowed(playerSrc, 'command') or GetConvar('sv_lan', '') == 'true' then
        return true
    end
    local xPlayer = ESX.Players[playerSrc]
    return xPlayer and Config.AdminGroups[xPlayer.group] or false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SSN generation
-- ─────────────────────────────────────────────────────────────────────────────

local reservedSSNs = {
    ['078-05-1120'] = true,
    ['219-09-9999'] = true,
    ['123-45-6789'] = true,
}

function Core.generateSSN()
    while true do
        local area   = math.random(1, 899)
        if area == 666 then goto continue end

        local group  = math.random(1, 99)
        local serial = math.random(1, 9999)

        if area == 987 and group == 65 and serial >= 4320 and serial <= 4329 then
            goto continue
        end

        local candidate = string.format('%03d-%02d-%04d', area, group, serial)
        if reservedSSNs[candidate] then goto continue end

        local exists = MySQL.scalar.await('SELECT 1 FROM users WHERE ssn = ? LIMIT 1', { candidate })
        if not exists then return candidate end

        ::continue::
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Save
-- ─────────────────────────────────────────────────────────────────────────────

local SAVE_QUERY = [[
    UPDATE users
    SET accounts = ?, job = ?, job_grade = ?, `group` = ?, position = ?, metadata = ?
    WHERE identifier = ?
]]

function Core.SavePlayer(xPlayer, cb)
    if not xPlayer.spawned then
        return cb and cb()
    end

    local ped = GetPlayerPed(xPlayer.source)
    xPlayer.setMeta('health',       GetEntityHealth(ped))
    xPlayer.setMeta('armor',        GetPedArmour(ped))
    xPlayer.setMeta('lastPlaytime', xPlayer.getPlayTime())

    MySQL.prepare(SAVE_QUERY, {
        json.encode(xPlayer.getAccounts(true)),
        xPlayer.job.name,
        xPlayer.job.grade,
        xPlayer.group,
        json.encode(xPlayer.getCoords(false, true)),
        json.encode(xPlayer.getMeta()),
        xPlayer.identifier,
    }, function(rows)
        if rows == 1 then
            print(('[^2INFO^7] Saved player "^5%s^7"'):format(xPlayer.name))
            TriggerEvent('esx:playerSaved', xPlayer.playerId, xPlayer)
        end
        if cb then cb() end
    end)
end

function Core.SavePlayers(cb)
    local players = ESX.Players
    if not next(players) then return cb and cb() end

    local params = {}
    for _, xPlayer in pairs(players) do
        if xPlayer.spawned then
            local ped = GetPlayerPed(xPlayer.source)
            xPlayer.setMeta('health',       GetEntityHealth(ped))
            xPlayer.setMeta('armor',        GetPedArmour(ped))
            xPlayer.setMeta('lastPlaytime', xPlayer.getPlayTime())

            params[#params + 1] = {
                json.encode(xPlayer.getAccounts(true)),
                xPlayer.job.name,
                xPlayer.job.grade,
                xPlayer.group,
                json.encode(xPlayer.getCoords(false, true)),
                json.encode(xPlayer.getMeta()),
                xPlayer.identifier,
            }
        end
    end

    if not next(params) then return cb and cb() end

    MySQL.prepare(SAVE_QUERY, params, function(results)
        if not results then return end
        if cb then return cb() end
        print(('[^2INFO^7] Saved ^5%s^7 %s'):format(#params, #params > 1 and 'players' or 'player'))
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- RegisterCommand — kept for resource compatibility
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.RegisterCommand(name, group, cb, allowConsole, suggestion)
    if type(name) == 'table' then
        for _, v in ipairs(name) do ESX.RegisterCommand(v, group, cb, allowConsole, suggestion) end
        return
    end

    Core.RegisteredCommands[name] = { group = group, cb = cb, allowConsole = allowConsole }

    if suggestion then
        TriggerClientEvent('chat:addSuggestion', -1,
            ('/%s'):format(name), suggestion.help or '', suggestion.arguments or {})
    end

    RegisterCommand(name, function(playerId, args)
        local cmd     = Core.RegisteredCommands[name]
        local xPlayer = ESX.Players[playerId]

        if not cmd.allowConsole and playerId == 0 then return end

        cb(xPlayer or false, args, function(msg)
            if playerId == 0 then
                print(msg)
            elseif xPlayer then
                TriggerClientEvent('chat:addMessage', playerId, { args = { msg } })
            end
        end)
    end, true)

    if type(group) == 'table' then
        for _, v in ipairs(group) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
        end
    else
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Legacy lib.callback bridge
-- Resources still using ESX callbacks can register via lib.callback directly.
-- These stubs prevent hard errors if old resources call the old API.
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.RegisterServerCallback(name, cb)
    lib.callback.register(name, function(source, ...)
        local p = promise.new()
        cb(source, function(...) p:resolve({ ... }) end, ...)
        local res = Citizen.Await(p)
        return table.unpack(res)
    end)
end

function ESX.TriggerClientCallback(source, name, cb, ...)
    lib.callback(name, source, cb, ...)
end
