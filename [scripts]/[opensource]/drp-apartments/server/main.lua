---@class ApartmentData
---@field name string Unique apartment identifier
---@field type string Apartment type/category
---@field label string Display label for apartment
---@field identifier string Owner's ESX identifier

---@class ApartmentObject
---@field offset number Spawn offset for apartment
---@field players table<number, string> Map of source to identifier

---@class ApartmentCategory
---@field apartments table<string, ApartmentObject> Map of apartment ID to apartment object

---@class ExtendedPlayer
---@field identifier string Player's unique identifier
---@field source number Player's server ID
---@field getName fun(): string Get player name
---@field getAccount fun(account: string): table Get account info
---@field addMoney fun(account: string, amount: number) Add money to account
---@field removeMoney fun(account: string, amount: number) Remove money from account
---@field getInventoryItem fun(item: string): table Get inventory item
---@field addInventoryItem fun(item: string, count: number) Add item to inventory
---@field removeInventoryItem fun(item: string, count: number) Remove item from inventory
---@field showNotification fun(msg: string, type?: string) Show notification to player

local ApartmentObjects = {}
local ESX = exports['es_extended']:getSharedObject()

-- Functions

--- Creates a unique apartment ID for given type
---@param type string Apartment type prefix
---@return string apartmentId Unique apartment identifier
local function CreateApartmentId(type)
    local UniqueFound = false
    local AparmentId = nil

    while not UniqueFound do
        AparmentId = tostring(math.random(1, 1000000))
        local result = MySQL.query.await('SELECT COUNT(*) as count FROM drp_apartments WHERE name = ?', { tostring(type .. AparmentId) })
        if result[1].count == 0 then
            UniqueFound = true
        end
    end
    return AparmentId
end

--- Retrieves apartment information from database
---@param apartmentId string Apartment identifier
---@return ApartmentData|nil apartmentInfo Apartment data or nil if not found
local function GetApartmentInfo(apartmentId)
    local retval = nil
    local result = MySQL.query.await('SELECT * FROM drp_apartments WHERE name = ?', { apartmentId })
    if result[1] ~= nil then
        retval = result[1]
    end
    return retval
end

--- Registers an apartment stash in ox_inventory
---@param apartmentId string Apartment identifier
---@param slots? number Number of inventory slots (default: 50)
---@param weight? number Max weight in grams (default: 100000)
local function RegisterApartmentStash(apartmentId, slots, weight)
    if not apartmentId then
        print('[drp-apartments] ERROR: Attempted to register stash with nil apartmentId')
        return
    end

    -- Register stash with ox_inventory (owner = false makes it a shared stash)
    exports.ox_inventory:RegisterStash(apartmentId, 'Apartment Storage', slots or 50, weight or 100000, false)
end

-- Events

--- Sets player's inside metadata and routing bucket for apartment
---@param house string Apartment type
---@param insideId string Apartment instance ID
---@param bool boolean True when entering, false when exiting
---@param isVisiting boolean Whether player is visiting or owns the apartment
RegisterNetEvent('drp-apartments:server:SetInsideMeta', function(house, insideId, bool, isVisiting)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if bool then
        local routeId = insideId:gsub('[^%-%d]', '')
        if not isVisiting then
            -- Store apartment info in player state
            Player(src).state.inside = {
                apartment = {
                    apartmentType = house,
                    apartmentId = insideId
                },
                house = nil
            }
        end
        SetPlayerRoutingBucket(src, tonumber(routeId))
    else
        -- Clear apartment info from player state
        Player(src).state.inside = {
            apartment = {
                apartmentType = nil,
                apartmentId = nil
            },
            house = nil
        }
        SetPlayerRoutingBucket(src, 0)
    end
end)

--- Returns player to default routing bucket
RegisterNetEvent('drp-apartments:returnBucket', function()
    local src = source
    SetPlayerRoutingBucket(src, 0)
end)

--- Opens apartment stash inventory
---@param CurrentApartment string Apartment identifier for stash
RegisterNetEvent('drp-apartments:server:openStash', function(CurrentApartment)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not CurrentApartment or CurrentApartment == '' then
        print('[drp-apartments] ERROR: Player ' .. src .. ' tried to open stash with invalid apartment ID')
        return
    end

    -- Ensure stash is registered
    RegisterApartmentStash(CurrentApartment)

    print('[drp-apartments] Opening stash for apartment: ' .. CurrentApartment .. ' (Player: ' .. src .. ')')

    -- Open stash using ox_inventory
    exports.ox_inventory:forceOpenInventory(src, 'stash', CurrentApartment)
end)

--- Creates a new apartment for player
---@param type string Apartment type
---@param label string Apartment label prefix
---@param firstSpawn boolean Whether this is first spawn (new character)
RegisterNetEvent('drp-apartments:server:CreateApartment', function(type, label, firstSpawn)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local num = CreateApartmentId(type)
    local apartmentId = tostring(type .. num)
    label = tostring(label .. ' ' .. num)

    MySQL.insert('INSERT INTO drp_apartments (name, type, label, identifier) VALUES (?, ?, ?, ?)', {
        apartmentId,
        type,
        label,
        xPlayer.identifier
    })

    -- Register stash for new apartment
    RegisterApartmentStash(apartmentId)

    xPlayer.showNotification(Lang:t('success.receive_apart') .. ' (' .. label .. ')', 'success')

    if firstSpawn then
        TriggerClientEvent('drp-apartments:client:SpawnInApartment', src, apartmentId, type)
    end
    TriggerClientEvent('drp-apartments:client:SetHomeBlip', src, type)
end)

--- Updates existing apartment type and label
---@param type string New apartment type
---@param label string New apartment label
RegisterNetEvent('drp-apartments:server:UpdateApartment', function(type, label)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.update('UPDATE drp_apartments SET type = ?, label = ? WHERE identifier = ?', { type, label, xPlayer.identifier })

    xPlayer.showNotification(Lang:t('success.changed_apart'), 'success')
    TriggerClientEvent('drp-apartments:client:SetHomeBlip', src, type)
end)

--- Rings doorbell for all players inside apartment
---@param apartmentId string Apartment identifier
---@param apartment string Apartment type
RegisterNetEvent('drp-apartments:server:RingDoor', function(apartmentId, apartment)
    local src = source
    if ApartmentObjects[apartment].apartments[apartmentId] ~= nil and next(ApartmentObjects[apartment].apartments[apartmentId].players) ~= nil then
        for k, _ in pairs(ApartmentObjects[apartment].apartments[apartmentId].players) do
            TriggerClientEvent('drp-apartments:client:RingDoor', k, src)
        end
    end
end)

--- Opens apartment door for visitor
---@param target number Target player source
---@param apartmentId string Apartment identifier
---@param apartment string Apartment type
RegisterNetEvent('drp-apartments:server:OpenDoor', function(target, apartmentId, apartment)
    local xPlayer = ESX.GetPlayerFromId(target)
    if xPlayer ~= nil then
        TriggerClientEvent('drp-apartments:client:SpawnInApartment', xPlayer.source, apartmentId, apartment)
    end
end)

--- Adds player to apartment object tracking
---@param apartmentId string Apartment identifier
---@param apartment string Apartment type
---@param offset number Spawn offset
RegisterNetEvent('drp-apartments:server:AddObject', function(apartmentId, apartment, offset)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil and ApartmentObjects[apartment].apartments[apartmentId] ~= nil then
        ApartmentObjects[apartment].apartments[apartmentId].players[src] = xPlayer.identifier
    else
        if ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
            ApartmentObjects[apartment].apartments[apartmentId] = {}
            ApartmentObjects[apartment].apartments[apartmentId].offset = offset
            ApartmentObjects[apartment].apartments[apartmentId].players = {}
            ApartmentObjects[apartment].apartments[apartmentId].players[src] = xPlayer.identifier
        else
            ApartmentObjects[apartment] = {}
            ApartmentObjects[apartment].apartments = {}
            ApartmentObjects[apartment].apartments[apartmentId] = {}
            ApartmentObjects[apartment].apartments[apartmentId].offset = offset
            ApartmentObjects[apartment].apartments[apartmentId].players = {}
            ApartmentObjects[apartment].apartments[apartmentId].players[src] = xPlayer.identifier
        end
    end
end)

--- Removes player from apartment object tracking
---@param apartmentId string Apartment identifier
---@param apartment string Apartment type
RegisterNetEvent('drp-apartments:server:RemoveObject', function(apartmentId, apartment)
    local src = source
    if ApartmentObjects[apartment].apartments[apartmentId].players ~= nil then
        ApartmentObjects[apartment].apartments[apartmentId].players[src] = nil
        if next(ApartmentObjects[apartment].apartments[apartmentId].players) == nil then
            ApartmentObjects[apartment].apartments[apartmentId] = nil
        end
    end
end)

--- Sets player's current apartment in state
---@param ap string|nil Apartment identifier or nil
RegisterNetEvent('drp-apartments:server:setCurrentApartment', function(ap)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    Player(src).state.currentapartment = ap
end)

-- Callbacks

--- Gets list of available apartments with active players
---@param source number Player source
---@param cb function Callback function
---@param apartment string Apartment type
ESX.RegisterServerCallback('drp-apartments:GetAvailableApartments', function(source, cb, apartment)
    local apartments = {}
    if ApartmentObjects ~= nil and ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
        for k, _ in pairs(ApartmentObjects[apartment].apartments) do
            if (ApartmentObjects[apartment].apartments[k] ~= nil and next(ApartmentObjects[apartment].apartments[k].players) ~= nil) then
                local apartmentInfo = GetApartmentInfo(k)
                apartments[k] = apartmentInfo.label
            end
        end
    end
    cb(apartments)
end)

--- Gets spawn offset for specific apartment
---@param source number Player source
---@param cb function Callback function
---@param apartmentId string Apartment identifier
ESX.RegisterServerCallback('drp-apartments:GetApartmentOffset', function(source, cb, apartmentId)
    local retval = 0
    if ApartmentObjects ~= nil then
        for k, _ in pairs(ApartmentObjects) do
            if (ApartmentObjects[k].apartments[apartmentId] ~= nil and tonumber(ApartmentObjects[k].apartments[apartmentId].offset) ~= 0) then
                retval = tonumber(ApartmentObjects[k].apartments[apartmentId].offset)
            end
        end
    end
    cb(retval)
end)

--- Gets next available offset for new apartment instance
---@param source number Player source
---@param cb function Callback function
---@param apartment string Apartment type
ESX.RegisterServerCallback('drp-apartments:GetApartmentOffsetNewOffset', function(source, cb, apartment)
    local retval = Apartments.SpawnOffset
    if ApartmentObjects ~= nil and ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
        for k, _ in pairs(ApartmentObjects[apartment].apartments) do
            if (ApartmentObjects[apartment].apartments[k] ~= nil) then
                retval = ApartmentObjects[apartment].apartments[k].offset + Apartments.SpawnOffset
            end
        end
    end
    cb(retval)
end)

--- Gets owned apartment data for player
---@param source number Player source
---@param cb function Callback function
---@param cid? string Player identifier (optional, uses source if not provided)
ESX.RegisterServerCallback('drp-apartments:GetOwnedApartment', function(source, cb, cid)
    if cid ~= nil then
        local result = MySQL.query.await('SELECT * FROM drp_apartments WHERE identifier = ?', { cid })
        if result[1] ~= nil then
            return cb(result[1])
        end
        return cb(nil)
    else
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return cb(nil) end

        local result = MySQL.query.await('SELECT * FROM drp_apartments WHERE identifier = ?', { xPlayer.identifier })
        if result[1] ~= nil then
            return cb(result[1])
        end
        return cb(nil)
    end
end)

--- Checks if player owns apartment of specific type
---@param source number Player source
---@param cb function Callback function
---@param apartment string Apartment type to check
ESX.RegisterServerCallback('drp-apartments:IsOwner', function(source, cb, apartment)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        local result = MySQL.query.await('SELECT * FROM drp_apartments WHERE identifier = ?', { xPlayer.identifier })
        if result[1] ~= nil then
            if result[1].type == apartment then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

--- Gets player's saved outfits from database
---@param source number Player source
---@param cb function Callback function
ESX.RegisterServerCallback('drp-apartments:GetOutfits', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local result = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { xPlayer.identifier })
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)
