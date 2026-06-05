-- ─────────────────────────────────────────────────────────────────────────────
-- Core / ESX state
-- ─────────────────────────────────────────────────────────────────────────────

Core = {}
Core.JobsPlayerCount    = {}
Core.RegisteredCommands = {}
Core.DatabaseConnected  = false
Core.playersByIdentifier = {}
Core.JobsLoaded          = false

ESX.Players = {}
ESX.Jobs    = {}

exports('getSharedObject', function() return ESX end)
exports('GetPlayerFromId', function(src) return ESX.Players[tonumber(src)] end)
exports('GetPlayers',      function() return ESX.Players end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Player Class
-- Stripped to: identity, money/accounts, job, group, metadata, state helpers.
-- No inventory — ox_inventory owns that.
-- No weapons — ox_inventory owns that.
-- No showNotification — use lib.notify from your resources.
-- ─────────────────────────────────────────────────────────────────────────────

function CreateExtendedPlayer(playerId, identifier, ssn, group, accounts, job, name, coords, metadata)
    local self       = {}
    self.accounts    = accounts
    self.coords      = coords
    self.group       = group
    self.identifier  = identifier
    self.ssn         = ssn
    self.job         = job
    self.name        = name
    self.playerId    = playerId
    self.source      = playerId
    self.variables   = {}
    self.metadata    = metadata
    self.lastPlaytime     = metadata.lastPlaytime or 0
    self.paycheckEnabled  = true
    self.admin            = Core.IsPlayerAdmin(playerId)
    self.spawned          = false
    self.license          = ('%s:%s'):format(Config.Identifier, identifier)

    if type(self.metadata.jobDuty) ~= 'boolean' then
        self.metadata.jobDuty = job.name ~= 'unemployed' and Config.DefaultJobDuty or false
    end
    self.job.onDuty = self.metadata.jobDuty

    ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))

    local stateBag = Player(self.source).state
    stateBag:set('identifier', self.identifier, false)
    stateBag:set('license',    self.license,    false)
    stateBag:set('job',        self.job,        true)
    stateBag:set('group',      self.group,      true)
    stateBag:set('name',       self.name,       true)

    -- ── Misc ──────────────────────────────────────────────────────────────────

    function self.triggerEvent(eventName, ...)
        assert(type(eventName) == 'string', 'eventName must be a string')
        TriggerClientEvent(eventName, self.source, ...)
    end

    function self.togglePaycheck(toggle) self.paycheckEnabled = toggle  end
    function self.isPaycheckEnabled()    return self.paycheckEnabled     end
    function self.isAdmin()              return Core.IsPlayerAdmin(self.source) end
    function self.kick(reason)           DropPlayer(self.source, reason) end

    function self.getPlayTime()
        return self.lastPlaytime + GetPlayerTimeOnline(tostring(self.source))
    end

    function self.getIdentifier() return self.identifier end
    function self.getSSN()        return self.ssn        end
    function self.getSource()     return self.source     end
    function self.getPlayerId()   return self.source     end
    function self.getName()       return self.name       end

    function self.setName(newName)
        self.name = newName
        Player(self.source).state:set('name', self.name, true)
    end

    function self.setCoords(coordinates)
        local ped = GetPlayerPed(self.source)
        SetEntityCoords(ped, coordinates.x, coordinates.y, coordinates.z, false, false, false, false)
        SetEntityHeading(ped, coordinates.w or coordinates.heading or 0.0)
    end

    function self.getCoords(vector, heading)
        local ped    = GetPlayerPed(self.source)
        local coords = GetEntityCoords(ped)
        local h      = GetEntityHeading(ped)
        if vector then
            return heading and vector4(coords.x, coords.y, coords.z, h) or coords
        end
        local t = { x = coords.x, y = coords.y, z = coords.z }
        if heading then t.heading = h end
        return t
    end

    function self.set(k, v)
        self.variables[k] = v
        self.triggerEvent('esx:updatePlayerData', 'variables', self.variables)
    end

    function self.get(k) return self.variables[k] end

    function self.executeCommand(command)
        assert(type(command) == 'string', 'executeCommand: must be string')
        self.triggerEvent('esx:executeCommand', command)
    end

    -- ── Group ─────────────────────────────────────────────────────────────────

    function self.getGroup() return self.group end

    function self.setGroup(newGroup)
        local lastGroup = self.group
        ExecuteCommand(('remove_principal identifier.%s group.%s'):format(self.license, self.group))
        self.group = newGroup
        TriggerEvent('esx:setGroup', self.source, self.group, lastGroup)
        self.triggerEvent('esx:setGroup', self.group, lastGroup)
        Player(self.source).state:set('group', self.group, true)
        ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))
    end

    -- ── Accounts / Money ──────────────────────────────────────────────────────

    function self.getAccounts(minimal)
        if not minimal then return self.accounts end
        local out = {}
        for i = 1, #self.accounts do
            out[self.accounts[i].name] = self.accounts[i].money
        end
        return out
    end

    function self.getAccount(account)
        account = string.lower(account)
        for i = 1, #self.accounts do
            if string.lower(self.accounts[i].name) == account then
                return self.accounts[i]
            end
        end
        return nil
    end

    function self.setAccountMoney(accountName, money, reason)
        assert(tonumber(money) and money >= 0,
            ('setAccountMoney: invalid amount %s for account %s'):format(money, accountName))
        local account = self.getAccount(accountName)
        assert(account, ('setAccountMoney: unknown account %s'):format(accountName))
        money = account.round and ESX.Math.Round(money) or money
        self.accounts[account.index].money = money
        self.triggerEvent('esx:setAccountMoney', account)
        TriggerEvent('esx:setAccountMoney', self.source, accountName, money, reason or 'unknown')
    end

    function self.addAccountMoney(accountName, money, reason)
        assert(tonumber(money) and money > 0,
            ('addAccountMoney: invalid amount %s for account %s'):format(money, accountName))
        local account = self.getAccount(accountName)
        assert(account, ('addAccountMoney: unknown account %s'):format(accountName))
        money = account.round and ESX.Math.Round(money) or money
        self.accounts[account.index].money += money
        self.triggerEvent('esx:setAccountMoney', account)
        TriggerEvent('esx:addAccountMoney', self.source, accountName, money, reason or 'unknown')
    end

    function self.removeAccountMoney(accountName, money, reason)
        assert(tonumber(money) and money > 0,
            ('removeAccountMoney: invalid amount %s for account %s'):format(money, accountName))
        local account = self.getAccount(accountName)
        assert(account, ('removeAccountMoney: unknown account %s'):format(accountName))
        money = account.round and ESX.Math.Round(money) or money
        assert(self.accounts[account.index].money - money >= 0,
            ('removeAccountMoney: insufficient funds in %s'):format(accountName))
        self.accounts[account.index].money -= money
        self.triggerEvent('esx:setAccountMoney', account)
        TriggerEvent('esx:removeAccountMoney', self.source, accountName, money, reason or 'unknown')
    end

    function self.getMoney()              return self.getAccount('money').money          end
    function self.setMoney(money)         self.setAccountMoney('money', ESX.Math.Round(money))          end
    function self.addMoney(money, r)      self.addAccountMoney('money', ESX.Math.Round(money), r)       end
    function self.removeMoney(money, r)   self.removeAccountMoney('money', ESX.Math.Round(money), r)    end

    -- ── Job ───────────────────────────────────────────────────────────────────

    function self.getJob() return self.job end

    function self.setJob(newJob, grade, onDuty)
        grade = tostring(grade)
        if not ESX.DoesJobExist(newJob, grade) then
            return print(('[^3WARNING^7] setJob: invalid job for ID=%s job=%s grade=%s'):format(
                self.source, newJob, grade))
        end

        if newJob == 'unemployed' then onDuty = false end
        if type(onDuty) ~= 'boolean' then onDuty = Config.DefaultJobDuty end

        local lastJob  = self.job
        local jobObj   = ESX.Jobs[newJob]
        local gradeObj = jobObj.grades[grade]

        self.job = {
            id           = jobObj.id,
            name         = jobObj.name,
            label        = jobObj.label,
            type         = jobObj.type,
            onDuty       = onDuty,
            grade        = tonumber(grade) or 0,
            grade_name   = gradeObj.name,
            grade_label  = gradeObj.label,
            grade_salary = gradeObj.salary,
        }

        self.metadata.jobDuty = onDuty
        TriggerEvent('esx:setJob', self.source, self.job, lastJob)
        self.triggerEvent('esx:setJob', self.job, lastJob)
        Player(self.source).state:set('job', self.job, true)
    end

    -- ── Metadata ──────────────────────────────────────────────────────────────

    function self.getMeta(index, subIndex)
        if not index then return self.metadata end
        local meta = self.metadata[index]
        if meta == nil then return nil end
        if subIndex then
            if type(subIndex) == 'string' then return meta[subIndex] end
            if type(subIndex) == 'table' then
                local out = {}
                for i = 1, #subIndex do out[subIndex[i]] = meta[subIndex[i]] end
                return out
            end
        end
        return meta
    end

    function self.setMeta(index, value, subValue)
        assert(type(index) == 'string', 'setMeta: index must be string')
        assert(value ~= nil, 'setMeta: value is nil')
        if not subValue then
            self.metadata[index] = value
        else
            assert(type(value) == 'string', 'setMeta: value must be string when using subValue')
            if type(self.metadata[index]) ~= 'table' then self.metadata[index] = {} end
            self.metadata[index][value] = subValue
        end
        self.triggerEvent('esx:updatePlayerData', 'metadata', self.metadata)
    end

    function self.clearMeta(index, subValues)
        assert(type(index) == 'string', 'clearMeta: index must be string')
        if not subValues then
            self.metadata[index] = nil
        elseif type(subValues) == 'string' then
            if type(self.metadata[index]) == 'table' then self.metadata[index][subValues] = nil end
        elseif type(subValues) == 'table' then
            for i = 1, #subValues do
                if type(self.metadata[index]) == 'table' then
                    self.metadata[index][subValues[i]] = nil
                end
            end
        end
        self.triggerEvent('esx:updatePlayerData', 'metadata', self.metadata)
    end

    -- ox_inventory calls this to sync weight/items back to ESX playerdata.
    -- We don't store inventory on the player; ox owns it. This is a required stub.
    function self.syncInventory(weight, maxWeight, items, accounts)
        if accounts then
            for name, amount in pairs(accounts) do
                local acc = self.getAccount(name)
                if acc and acc.money ~= amount then
                    self.setAccountMoney(name, amount, 'ox_inventory_sync')
                end
            end
        end
    end

    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DB queries (assembled once at resource start based on Config.Identity)
-- ─────────────────────────────────────────────────────────────────────────────

local SELECT_PLAYER = 'SELECT accounts, ssn, job, job_grade, `group`, position, metadata'
if Config.Identity then
    SELECT_PLAYER = SELECT_PLAYER .. ', firstname, lastname, dateofbirth, sex, height'
end
SELECT_PLAYER = SELECT_PLAYER .. ' FROM users WHERE identifier = ?'

local INSERT_PLAYER = 'INSERT INTO users SET accounts = ?, identifier = ?, ssn = ?, `group` = ?'
if Config.Identity then
    INSERT_PLAYER = INSERT_PLAYER .. ', firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ?'
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player load / create
-- ─────────────────────────────────────────────────────────────────────────────

local function buildAccounts(raw)
    local saved    = (raw and raw ~= '') and json.decode(raw) or {}
    local accounts = {}
    for account, data in pairs(Config.Accounts) do
        local index  = #accounts + 1
        accounts[index] = {
            name  = account,
            money = saved[account] or Config.StartingAccountMoney[account] or 0,
            label = data.label,
            round = data.round ~= false,
            index = index,
        }
    end
    return accounts
end

function loadESXPlayer(identifier, playerId, isNew)
    local result = MySQL.prepare.await(SELECT_PLAYER, { identifier })

    if not result then
        return DropPlayer(playerId, '[ESX] Failed to load character from database.')
    end

    -- Job
    local job   = result.job       or 'unemployed'
    local grade = tostring(result.job_grade or '0')

    if not ESX.DoesJobExist(job, grade) then
        print(('[^3WARNING^7] Invalid job for %s [%s / %s] — defaulting to unemployed'):format(
            identifier, job, grade))
        job, grade = 'unemployed', '0'
    end

    local jobObj   = ESX.Jobs[job]
    local gradeObj = jobObj.grades[grade]

    local jobData = {
        id           = jobObj.id,
        name         = jobObj.name,
        label        = jobObj.label,
        type         = jobObj.type,
        grade        = tonumber(grade) or 0,
        grade_name   = gradeObj.name,
        grade_label  = gradeObj.label,
        grade_salary = gradeObj.salary,
    }

    -- Group
    local group = result.group or 'user'
    if group == 'superadmin' then group = 'admin' end

    -- Spawn coords
    local coords = (result.position and result.position ~= '')
        and json.decode(result.position)
        or Config.DefaultSpawns[math.random(1, #Config.DefaultSpawns)]

    -- Metadata
    local metadata = (result.metadata and result.metadata ~= '') and json.decode(result.metadata) or {}

    local xPlayer = CreateExtendedPlayer(
        playerId, identifier, result.ssn, group,
        buildAccounts(result.accounts), jobData,
        GetPlayerName(playerId), coords, metadata
    )

    -- Identity fields stored as player variables
    if Config.Identity and result.firstname and result.firstname ~= '' then
        xPlayer.set('firstName',   result.firstname)
        xPlayer.set('lastName',    result.lastname)
        xPlayer.set('dateofbirth', result.dateofbirth)
        xPlayer.set('sex',         result.sex)
        xPlayer.set('height',      result.height)
        xPlayer.setName(('%s %s'):format(result.firstname, result.lastname))
    end

    ESX.Players[playerId]                = xPlayer
    Core.playersByIdentifier[identifier] = xPlayer
    GlobalState.playerCount              = GlobalState.playerCount + 1

    local userData = {
        identifier = xPlayer.identifier,
        name       = xPlayer.getName(),
        ssn        = xPlayer.ssn,
        group      = xPlayer.group,
        accounts   = xPlayer.getAccounts(),
        job        = xPlayer.getJob(),
        money      = xPlayer.getMoney(),
        position   = xPlayer.coords,
        metadata   = xPlayer.getMeta(),
        variables  = xPlayer.variables,
    }

    TriggerEvent('esx:playerLoaded', playerId, xPlayer, isNew)
    xPlayer.triggerEvent('esx:playerLoaded', userData, isNew)

    print(('[^2INFO^7] Player "^5%s^7" (ID ^5%s^7) loaded'):format(xPlayer.getName(), playerId))
end

function createESXPlayer(identifier, playerId, data)
    local accounts = {}
    for account, money in pairs(Config.StartingAccountMoney) do
        accounts[account] = money
    end

    local group  = Core.IsPlayerAdmin(playerId) and 'admin' or 'user'
    local ssn    = Core.generateSSN()
    local params

    if Config.Identity and data then
        params = {
            json.encode(accounts), identifier, ssn, group,
            data.firstname, data.lastname, data.dateofbirth, data.sex, data.height,
        }
    else
        params = { json.encode(accounts), identifier, ssn, group }
    end

    MySQL.prepare(INSERT_PLAYER, params, function()
        loadESXPlayer(identifier, playerId, true)
    end)
end
