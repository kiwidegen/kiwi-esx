-- server/main.lua - drp Vans (OPTIMIZED)
-- Behavior:
--  • Timer ticks ONLY when exactly one team is "locking" (on foot, alive, within LockRange)
--  • Pauses if empty or contested
--  • Broadcasts notify when van is FOUND and when control changes / completes
--  • Splits loot across nearby winners; drops leftovers
--  • Admin-gated start/stop (ACE or ESX roles)
--  • Prunes stale proximity entries to handle disconnects / missed heartbeats
--  • OPTIMIZED: Random spawn selection, reduced broadcasts

local JSON = json

-- ========= runtime state =========
local state = {
    active           = false,
    netId            = nil,        -- vehicle net id
    pos              = nil,        -- vec4 (x,y,z,w)
    found            = false,      -- discovery happened
    controlSeconds   = 0,          -- accumulated control time
    controllingTeam  = nil,        -- current unique controller (string team id)
    mode             = 'freeforall', -- 'freeforall' | 'gang'
    gangWhitelist    = nil,        -- set[gname]=true if mode=='gang'
    spawning         = false,      -- van is waiting to spawn
    spawnData        = nil,        -- data for delayed spawn
}

-- proximity[src] = { near, lock, disc, alive, teamId, t=os.time() }
local proximity   = {}
local pendingLoot = nil

-- ========= utils =========
local function asPlayer(s)
    local n = tonumber(s)
    if not n or n < 1 then return nil end
    return n
end

local function broadcast(msg, typ)
    TriggerClientEvent('ox_lib:notify', -1, {
        title = 'Van Event',
        description = msg,
        type = typ or 'info'
    })
end

local function contains(container, key)
    if type(container) ~= 'table' then return false end
    if container[key] ~= nil then
        return container[key] == true or container[key] == 1 or container[key] == key
    end
    for _, v in ipairs(container) do if v == key then return true end end
    return false
end

local function discordLog(title, description, fields, colorName)
    exports['drp-logs']:log('events', {
        title = title,
        description = description,
        fields = fields or {},
        colorName = colorName or 'info'
    })
end

local function getDisplayName(src)
    local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
    if xPlayer then
        if xPlayer.getName then
            local n = xPlayer.getName()
            if n and n ~= '' then return n end
        end
        local first = (xPlayer.get and xPlayer.get('firstName')) or (xPlayer.variables and xPlayer.variables.firstName)
        local last  = (xPlayer.get and xPlayer.get('lastName'))  or (xPlayer.variables and xPlayer.variables.lastName)
        if first and last then return (('%s %s'):format(first, last)) end
    end
    local pn = GetPlayerName(src)
    if pn and pn ~= '' then return pn end
    return 'Citizen ' .. tostring(src)
end

-- OPTIMIZED: Random spawn point selection
local function getRandomSpawnPoint()
    if not VansConfig.SpawnPoints or #VansConfig.SpawnPoints == 0 then
        return vec4(0.0, 0.0, 72.0, 0.0)
    end
    return VansConfig.SpawnPoints[math.random(#VansConfig.SpawnPoints)]
end

-- ACE + ESX group/job/job2/gang allow list
local function isAdmin(src)
    if IsPlayerAceAllowed(("%s"):format(src), 'drp.van')      then return true end
    if IsPlayerAceAllowed(("%s"):format(src), 'group.admin')  then return true end
    if IsPlayerAceAllowed(("%s"):format(src), 'command')      then return true end

    local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
    if not xPlayer then return false end

    local grp = (xPlayer.getGroup and xPlayer.getGroup()) or xPlayer.group
    if grp and Config and VansConfig.AdminAllowedGroups and contains(VansConfig.AdminAllowedGroups, grp) then return true end

    local jobName  = (xPlayer.getJob  and xPlayer.getJob().name)  or (xPlayer.job  and xPlayer.job.name)
    local job2Name = (xPlayer.getJob2 and xPlayer.getJob2().name) or (xPlayer.job2 and xPlayer.job2.name)
    if jobName  and Config and VansConfig.AdminJobs  and contains(VansConfig.AdminJobs,  jobName)  then return true end
    if job2Name and Config and VansConfig.AdminGangs and contains(VansConfig.AdminGangs, job2Name) then return true end

    -- optionally from xPlayer.get('gang') if your ESX flavor stores it
    local gang = (xPlayer.get and xPlayer.get('gang')) or xPlayer.gang
    local gangName = (type(gang) == 'table' and gang.name) or (type(gang) == 'string' and gang) or nil
    if gangName and Config and VansConfig.AdminGangs and contains(VansConfig.AdminGangs, gangName) then return true end

    return false
end

-- gangs-only gate
local function teamAllowed(info)
    if state.mode ~= 'gang' then return true end
    if not info.teamId or info.teamId:sub(1,5) ~= 'gang:' then return false end
    local g = info.teamId:sub(6)
    if state.gangWhitelist and not state.gangWhitelist[g] then return false end
    return true
end

-- OPTIMIZED: Batch proximity pruning
local function pruneStaleProximity()
    local now = os.time()
    local stale = {}
    for src, info in pairs(proximity) do
        if (now - (info.t or now)) > 12 then
            stale[#stale + 1] = src
        end
    end
    for i = 1, #stale do
        proximity[stale[i]] = nil
    end
end

-- OPTIMIZED: Pre-compiled team counter
local function countTeams(teams)
    local count = 0
    for _ in pairs(teams) do count = count + 1 end
    return count
end

-- compute control status from proximity table
-- Returns: teamId | nil, hasUnique (bool), repSrc | nil, hasLock (bool)
local function computeControl()
    local nearTeams, nearRep = {}, {}
    local lockTeams, lockRep = {}, {}

    for src, info in pairs(proximity) do
        if info.near and info.alive and teamAllowed(info) then
            if not nearTeams[info.teamId] then
                nearTeams[info.teamId] = true
                nearRep[info.teamId]   = src
            end
            if info.lock then
                lockTeams[info.teamId] = true
                lockRep[info.teamId]   = src
            end
        end
    end

    local lc = countTeams(lockTeams)
    if lc == 1 then
        for teamId,_ in pairs(lockTeams) do
            return teamId, true, lockRep[teamId], true
        end
    end

    local nc = countTeams(nearTeams)
    if nc == 1 then
        for teamId,_ in pairs(nearTeams) do
            return teamId, true, nearRep[teamId], false -- unique near, but no lock -> paused
        end
    end

    return nil, false, nil, false
end

local function displayLabelForHUD(_teamId, repSrc)
    return getDisplayName(repSrc)
end

local function resetState()
    state = {
        active           = false,
        netId            = nil,
        pos              = nil,
        found            = false,
        controlSeconds   = 0,
        controllingTeam  = nil,
        mode             = 'freeforall',
        gangWhitelist    = nil,
        spawning         = false,
        spawnData        = nil
    }
    proximity   = {}
    pendingLoot = nil
end

local function buildLootLabel(list)
    local parts = {}
    for _, it in ipairs(list or {}) do
        parts[#parts + 1] = (("%dx %s"):format(it.count or 0, it.name or "item"))
    end
    return (#parts > 0) and table.concat(parts, ", ") or "None"
end

local function mergeItems(items)
    local map, out = {}, {}
    for _, it in ipairs(items or {}) do
        if it.name and it.count and it.count > 0 then
            local key = it.name .. '|' .. JSON.encode(it.metadata or {})
            map[key] = map[key] or { name = it.name, count = 0, metadata = it.metadata or {} }
            map[key].count = map[key].count + it.count
        end
    end
    for _, v in pairs(map) do out[#out + 1] = v end
    return out
end

local function awardLootToWinners(winners, loot)
    loot = mergeItems(loot)
    local leftovers = {}
    if #loot == 0 or not winners or #winners == 0 then return loot end

    -- split evenly; distribute remainder to first N
    local plans = {}
    for _, src in ipairs(winners) do plans[src] = {} end
    for _, it in ipairs(loot) do
        local total = tonumber(it.count) or 0
        if total > 0 then
            local n = #winners
            local per = math.floor(total / n)
            local rem = total - per * n
            for idx, src in ipairs(winners) do
                local give = per + ((idx <= rem) and 1 or 0)
                if give > 0 then
                    plans[src][#plans[src] + 1] = { name = it.name, count = give, metadata = it.metadata or {} }
                end
            end
        end
    end

    -- grant (ox_inventory)
    for _, src in ipairs(winners) do
        local granted, failed = {}, {}
        local bundle = mergeItems(plans[src])
        for _, gi in ipairs(bundle) do
            local ok, res = pcall(function() return exports.ox_inventory:AddItem(src, gi.name, gi.count, gi.metadata or {}) end)
            if ok and res then
                granted[#granted + 1] = gi
            else
                failed[#failed + 1] = gi
            end
        end
        if #granted > 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Van Event',
                description = ('You received %s'):format(buildLootLabel(granted)),
                type = 'success'
            })
        end
        for _, f in ipairs(failed) do leftovers[#leftovers + 1] = f end
    end

    return leftovers
end

-- ========= gang DB auto-detect =========
local function dbQuery(sql, params)
    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(sql, params or {})
    elseif MySQL and MySQL.Async and MySQL.Async.fetchAll then
        local p = promise.new()
        MySQL.Async.fetchAll(sql, params or {}, function(res) p:resolve(res) end)
        return Citizen.Await(p)
    elseif exports.oxmysql and exports.oxmysql.query_async then
        return exports.oxmysql:query_async(sql, params or {})
    end
    return {}
end

local function tableExists(name)
    local rows = dbQuery('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? LIMIT 1', { name })
    return rows and rows[1] ~= nil
end

local function columnExists(tbl, col)
    local rows = dbQuery([[
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1
    ]], { tbl, col })
    return rows and rows[1] ~= nil
end

local function fetchGangOptions()
    local opts, seen = {}, {}

    if tableExists('gangs') then
        local rows = dbQuery('SELECT name, label FROM gangs')
        for _, r in ipairs(rows or {}) do
            if r.name and r.name ~= '' then seen[r.name] = r.label or r.name end
        end
    elseif tableExists('jobs') and columnExists('jobs','type') then
        local rows = dbQuery('SELECT name, label FROM jobs WHERE type="gang"')
        for _, r in ipairs(rows or {}) do
            if r.name and r.name ~= '' then seen[r.name] = r.label or r.name end
        end
    elseif tableExists('jobs') and columnExists('jobs','is_gang') then
        local rows = dbQuery('SELECT name, label FROM jobs WHERE is_gang=1')
        for _, r in ipairs(rows or {}) do
            if r.name and r.name ~= '' then seen[r.name] = r.label or r.name end
        end
    elseif tableExists('users') and columnExists('users','job2') then
        local rows = dbQuery('SELECT DISTINCT job2 AS name FROM users WHERE job2 IS NOT NULL AND job2<>"" AND job2<>"unemployed"')
        for _, r in ipairs(rows or {}) do
            if r.name and r.name ~= '' then seen[r.name] = r.name end
        end
    end

    for name,label in pairs(seen) do
        opts[#opts+1] = { label = label, value = name }
    end
    table.sort(opts,function(a,b) return a.label<b.label end)
    return opts
end

lib.callback.register('drp-vans:sv:getGangOptions', function(_src)
    return fetchGangOptions()
end)

-- ========= callbacks / RPC =========
-- Start request from client admin UI (OPTIMIZED: random spawn selection)
-- payload = { items=[{name,count,metadata?},...], mode='freeforall'|'gang', gangs=['ballas',...], pos?, heading? }
lib.callback.register('drp-vans:sv:prepareStart', function(src, payload)
    src = asPlayer(src) or 0
    if src == 0 then return false, 'Invalid caller.' end
    if not isAdmin(src) then return false, 'Not authorized.' end
    if state.active or state.spawning then return false, 'Event already active.' end

    payload = payload or {}

    -- OPTIMIZED: Random spawn selection
    local spawn = getRandomSpawnPoint()
    if payload.pos and payload.pos.x then
        spawn = vec4(payload.pos.x, payload.pos.y, payload.pos.z, payload.heading or 0.0)
    end

    state.mode = (payload.mode == 'gang') and 'gang' or 'freeforall'
    state.gangWhitelist = nil
    if state.mode == 'gang' and payload.gangs and #payload.gangs > 0 then
        state.gangWhitelist = {}
        for _, g in ipairs(payload.gangs) do state.gangWhitelist[g] = true end
    end

    pendingLoot = {}
    if payload.items and type(payload.items) == 'table' then
        for _, it in ipairs(payload.items) do
            if it.name and it.count and it.count > 0 then
                pendingLoot[#pendingLoot + 1] = {
                    name     = it.name,
                    count    = tonumber(it.count) or 0,
                    metadata = it.metadata or {}
                }
            end
        end
    end

    -- Store spawn data for delayed spawn
    state.spawning = true
    state.spawnData = {
        spawn = spawn,
        model = (Config and VansConfig.VehicleModel) or 'gburrito2',
        adminSrc = src
    }

    local modeText = (state.mode == 'gang') and 'Gang Event' or 'Free For All'
    local spawnDelay = tonumber(Config and VansConfig.VanSpawnDelay) or 600

    -- Notify all players with countdown
    TriggerClientEvent('ox_lib:notify', -1, {
        id = 'van_spawn_countdown',
        title = 'Van Event',
        description = ('Van will be placed in 10 minutes! %s'):format(modeText),
        type = 'info',
        countdown = spawnDelay,
        duration = spawnDelay * 1000
    })

    discordLog('Van Event Starting',
        ('Mode: **%s**\nLoot: %s\nSpawn Delay: %d seconds'):format(modeText, buildLootLabel(pendingLoot), spawnDelay), {
            { name='Allowed gangs', value=(state.gangWhitelist and table.concat((function()
                local t = {}
                for g,_ in pairs(state.gangWhitelist) do t[#t+1] = g end
                table.sort(t); return t
            end)(), ', ') or 'All'), inline=false }
        }, 'info')

    -- Schedule van spawn after delay
    SetTimeout(spawnDelay * 1000, function()
        if not state.spawning then return end

        -- Tell the admin client to spawn the van
        TriggerClientEvent('drp-vans:cl:spawnVan', state.spawnData.adminSrc, {
            model = state.spawnData.model,
            pos = { x = state.spawnData.spawn.x, y = state.spawnData.spawn.y, z = state.spawnData.spawn.z },
            heading = state.spawnData.spawn.w
        })

        -- Notify all players van has been placed
        TriggerClientEvent('ox_lib:notify', -1, {
            title = 'Van Event',
            description = 'Van has been placed!',
            type = 'success',
            duration = 5000
        })

        -- Initialize active state
        state.active = true
        state.pos = state.spawnData.spawn
        state.controlSeconds = 0
        state.found = false
        state.controllingTeam = nil
        proximity = {}
    end)

    return true, 'Event starting - van will spawn in 10 minutes'
end)

-- client spawned vehicle, persist netId and notify clients to lock & begin
RegisterNetEvent('drp-vans:sv:vehicleSpawned', function(netId, _items)
    local src = asPlayer(source); if not src then return end
    if not state.active or state.netId then return end
    if not netId or netId == -1 then
        resetState()
        return
    end

    state.netId = netId
    TriggerClientEvent('drp-vans:cl:applyProps', -1, netId, true) -- locked/undriveable
    TriggerClientEvent('drp-vans:cl:begin', -1, netId, { x = state.pos.x, y = state.pos.y, z = state.pos.z })
end)

-- proximity heartbeat from clients
RegisterNetEvent('drp-vans:sv:proximity', function(near, alive, teamId, disc, lock)
    if not state.active then return end
    local src = asPlayer(source); if not src then return end
    proximity[src] = {
        near   = near  and true or false,
        alive  = alive and true or false,
        teamId = teamId or ('player:' .. tostring(src)),
        disc   = disc  and true or false,
        lock   = lock  and true or false,
        t      = os.time()
    }
end)

-- cleanup proximity on disconnect
AddEventHandler('playerDropped', function()
    local src = asPlayer(source)
    if src and proximity[src] then
        proximity[src] = nil
    end
end)

-- admin stop
RegisterNetEvent('drp-vans:sv:stop', function()
    local src = asPlayer(source) or 0
    if src == 0 or not isAdmin(src) then return end
    if state.active and state.netId then
        TriggerClientEvent('drp-vans:cl:cleanup', -1, state.netId)
    end
    broadcast('Van event stopped by admin.', 'warning')
    discordLog('Event Stopped', ('By: **%s**'):format(getDisplayName(src)), {}, 'warning')
    resetState()
end)

-- ========= control loop (OPTIMIZED: reduced broadcasts) =========
CreateThread(function()
    while true do
        ::continue::
        local tickSeconds = tonumber(Config and VansConfig.TickSeconds) or 1
        Wait(tickSeconds * 1000)

        if not state.active or not state.netId then goto continue end

        -- OPTIMIZED: Prune stale entries once per tick
        pruneStaleProximity()

        local controlSecondsRequired = tonumber(Config and VansConfig.ControlSecondsRequired) or 600

        -- Discovery (any on-foot player within discovery range)
        if not state.found then
            for src, info in pairs(proximity) do
                if info.disc and info.alive and teamAllowed(info) then
                    state.found = true
                    local finder = getDisplayName(src)
                    TriggerClientEvent('drp-vans:cl:onFound', -1, state.netId, { x = state.pos.x, y = state.pos.y, z = state.pos.z })
                    -- Single notification when van is found
                    TriggerClientEvent('ox_lib:notify', -1, {
                        title = 'Van Event',
                        description = ('The van has been found by %s! Hold the area to unlock it.'):format(finder),
                        type = 'info',
                        duration = 5000
                    })
                    discordLog('Van Found', ('Finder: **%s**'):format(finder), {}, 'success')
                    break -- OPTIMIZED: Early exit after discovery
                end
            end
        end

        if state.found then
            local team, hasUnique, repSrc, hasLock = computeControl()
            if hasUnique then
                local label = displayLabelForHUD(team, repSrc)

                -- OPTIMIZED: Only broadcast when control changes (disabled for cleaner notifications)
                if state.controllingTeam ~= team then
                    state.controllingTeam = team
                    -- Control change notification removed - using countdown timer instead
                    discordLog('Control Changed', ('Now in control: **%s**'):format(label), {}, 'orange')
                end

                if hasLock then
                    state.controlSeconds = state.controlSeconds + tickSeconds
                    TriggerClientEvent('drp-vans:cl:updateTimer', -1, state.controlSeconds, controlSecondsRequired, true,  team, label)
                else
                    -- unique near team but not locking -> paused
                    TriggerClientEvent('drp-vans:cl:updateTimer', -1, state.controlSeconds, controlSecondsRequired, false, team, label)
                end

                if state.controlSeconds >= controlSecondsRequired then
                    -- winners = nearby + alive + allowed on winning team
                    local winners, names = {}, {}
                    for src, info in pairs(proximity) do
                        if info.near and info.alive and info.teamId == state.controllingTeam and teamAllowed(info) then
                            winners[#winners + 1] = src
                            names[#names + 1] = getDisplayName(src)
                        end
                    end

                    local leftovers = awardLootToWinners(winners, pendingLoot or {})
                    if leftovers and #leftovers > 0 and exports.ox_inventory and exports.ox_inventory.CreateDrop then
                        pcall(function()
                            exports.ox_inventory:CreateDrop(leftovers, vector3(state.pos.x, state.pos.y, state.pos.z))
                        end)
                    end

                    broadcast(('The van was secured by %s (%s).'):format(label, (#names > 0 and table.concat(names, ', ') or '—')), 'success')
                    discordLog('Van Secured',
                        ('Winner: **%s**\nMembers: %s'):format(label, (#names > 0 and table.concat(names, ', ') or '—')), {}, 'success')

                    TriggerClientEvent('drp-vans:cl:onWin', -1, state.netId, { x = state.pos.x, y = state.pos.y, z = state.pos.z }, state.controllingTeam)
                    TriggerClientEvent('drp-vans:cl:cleanup', -1, state.netId)
                    resetState()
                end
            else
                -- OPTIMIZED: Only broadcast if control WAS active (disabled for cleaner notifications)
                if state.controllingTeam ~= nil then
                    state.controllingTeam = nil
                    -- Control paused notification removed - using countdown timer instead
                    discordLog('Control Paused', 'Area contested or no valid controller.', {}, 'warning')
                end
                -- paused; no single near team -> label nil
                TriggerClientEvent('drp-vans:cl:updateTimer', -1, state.controlSeconds, controlSecondsRequired, false, nil, nil)
            end
        end
    end
end)
