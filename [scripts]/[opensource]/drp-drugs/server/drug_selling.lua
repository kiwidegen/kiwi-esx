ESX = exports['es_extended']:getSharedObject()

--- Dynamic 2x zone and drug (changes on restart)
local active2xZone = nil
local active2xDrug = nil

--- Debug print helper
---@param message string Debug message
local function debugPrint(message)
  if Config and DrugsConfig.Debug then
    print('^3[DRP-DRUGS DEBUG]^7 ' .. message)
  end
end

--- Randomly select a 2x zone and drug for this restart
local function select2xBonus()
  -- Get all zone names
  local zones = {}
  for zoneName, _ in pairs(DrugsConfig.Zones) do
    zones[#zones + 1] = zoneName
  end

  -- Get all drug names
  local drugs = {}
  for drugName, _ in pairs(DrugsConfig.Drugs) do
    drugs[#drugs + 1] = drugName
  end

  -- Random selection
  if #zones > 0 and #drugs > 0 then
    active2xZone = zones[math.random(1, #zones)]
    active2xDrug = drugs[math.random(1, #drugs)]

    print('^2[DRP-DRUGS]^7 2x Bonus activated!')
    print('^2[DRP-DRUGS]^7 Zone: ^3' .. active2xZone .. '^7')
    print('^2[DRP-DRUGS]^7 Drug: ^3' .. active2xDrug .. '^7')
  end
end

-- Select 2x bonus on resource start
CreateThread(function()
  Wait(1000) -- Wait for config to load
  select2xBonus()
end)

--- Get player's available drugs from inventory
---@param source number Player source
---@return table|nil availableDrugs Array of drug data or nil if none
local function getAvailableDrugs(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then return nil end

  local availableDrugs = {}

  -- Get sellable drugs dynamically from config
  for drugItem, drugConfig in pairs(DrugsConfig.Drugs) do
    local item = xPlayer.getInventoryItem(drugItem)
    if item and item.count > 0 then
      availableDrugs[#availableDrugs + 1] = {
        item = drugItem,
        label = item.label or drugConfig.label or drugItem,
        amount = item.count
      }
    end
  end

  debugPrint('Player ' .. source .. ' has ' .. #availableDrugs .. ' drug types available')
  return #availableDrugs > 0 and availableDrugs or nil
end

--- Process drug sale transaction
---@param source number Player source
---@param drugItem string Drug item name
---@param amount number Amount to sell
---@param price number Sale price
---@param territory string Territory name
---@param wasStolen boolean Whether drugs were stolen instead of bought
local function processSale(source, drugItem, amount, price, territory, wasStolen)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then return end

  -- Check if this is a 2x sale (correct zone AND drug)
  if territory == active2xZone and drugItem == active2xDrug then
    print('^3[DRP-DRUGS]^7 ^2[2X BONUS SALE]^7 Player: ^5' .. xPlayer.getName() .. '^7 | Zone: ^5' .. territory .. '^7 | Drug: ^5' .. drugItem .. '^7 | Sale: ^2$' .. price .. '^7')
  end

  debugPrint('=== Processing Sale ===')
  debugPrint('Player: ' .. source .. ' (' .. xPlayer.getName() .. ')')
  debugPrint('Drug: ' .. drugItem .. ' x' .. amount)
  debugPrint('Territory: ' .. territory)
  debugPrint('Price: $' .. price)
  debugPrint('Stolen: ' .. tostring(wasStolen))

  local item = xPlayer.getInventoryItem(drugItem)
  if not item or item.count < amount then
    debugPrint('ERROR: Player does not have enough ' .. drugItem)
    return
  end

  -- Remove drugs from inventory
  xPlayer.removeInventoryItem(drugItem, amount)
  debugPrint('Removed ' .. amount .. 'x ' .. drugItem .. ' from inventory')

  -- Add money only if not stolen
  if not wasStolen then
    xPlayer.addAccountMoney('black_money', price)
    debugPrint('Added $' .. price .. ' black money to player')
  else
    debugPrint('No money added (drugs stolen)')
  end

  -- Update player's available drugs
  local updatedDrugs = getAvailableDrugs(source)
  TriggerClientEvent('drp-drugs:client:updateHoldings', source, updatedDrugs)

  -- Log the transaction
  if wasStolen then
    TriggerEvent('drp-drugs:server:log', {
      source = source,
      action = 'drug_stolen',
      drug = drugItem,
      amount = amount,
      territory = territory
    })
  else
    TriggerEvent('drp-drugs:server:log', {
      source = source,
      action = 'drug_sold',
      drug = drugItem,
      amount = amount,
      price = price,
      territory = territory
    })
  end

  debugPrint('=== Sale Complete ===')
end

--- Get current police count
---@return number copCount Number of online police
local function getPoliceCount()
  local copCount = 0
  local xPlayers = ESX.GetExtendedPlayers()

  for _, xPlayer in pairs(xPlayers) do
    if xPlayer.job.name == 'police' then
      copCount += 1
    end
  end

  debugPrint('Current police count: ' .. copCount)
  return copCount
end

-- Callbacks
ESX.RegisterServerCallback('drp-drugs:server:getConfig', function(source, cb)
  debugPrint('Config requested by player ' .. source)
  cb({
    Debug = DrugsConfig.Debug,
    Drugs = DrugsConfig.Drugs,
    Zones = DrugsConfig.Zones,
    PoliceRequired = DrugsConfig.PoliceRequired,
    SellDifficulty = DrugsConfig.SellDifficulty,
    WeekendPriceBonus = DrugsConfig.WeekendPriceBonus,
    Active2xZone = active2xZone,
    Active2xDrug = active2xDrug
  })
end)

ESX.RegisterServerCallback('drp-drugs:server:getAvailableDrugs', function(source, cb)
  cb(getAvailableDrugs(source))
end)

ESX.RegisterServerCallback('drp-drugs:server:getPoliceCount', function(source, cb)
  cb(getPoliceCount())
end)

-- Events
RegisterNetEvent('drp-drugs:server:sell', function(drugItem, amount, price, territory, wasStolen)
  local source = source
  processSale(source, drugItem, amount, price, territory, wasStolen or false)
end)

--- Get ped gender (0 = male, 1 = female)
---@param ped number Ped handle
---@return number gender 0 for male, 1 for female
function GetPedGender(ped)
  local model = GetEntityModel(ped)
  if model == GetHashKey("mp_f_freemode_01") then
    return 1 -- Female
  end
  return 0 -- Male (default)
end

--- Recover stolen drugs
RegisterNetEvent('drp-drugs:server:recoverDrugs', function(drugItem, amount)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then return end

  debugPrint('Player ' .. source .. ' recovering ' .. amount .. 'x ' .. drugItem)

  -- Add drugs back to player
  xPlayer.addInventoryItem(drugItem, amount)

  -- Update player's available drugs
  local updatedDrugs = getAvailableDrugs(source)
  TriggerClientEvent('drp-drugs:client:updateHoldings', source, updatedDrugs)

  -- Log the recovery
  TriggerEvent('drp-drugs:server:log', {
    source = source,
    action = 'drug_recovered',
    drug = drugItem,
    amount = amount
  })
end)

-- Logging handler using drp-logs
RegisterNetEvent('drp-drugs:server:log', function(data)
  local xPlayer = ESX.GetPlayerFromId(data.source)
  if not xPlayer then return end

  local drugConfig = DrugsConfig.Drugs[data.drug] or {}
  local drugLabel = drugConfig.label or data.drug

  if data.action == 'drug_sold' then
    exports['drp-logs']:log('drugs', {
      source = data.source,
      title = 'Drug Sale',
      description = 'Player sold drugs in ' .. (data.territory or 'Unknown Territory'),
      colorName = 'success',
      fields = {
        { name = 'Drug', value = drugLabel, inline = true },
        { name = 'Amount', value = tostring(data.amount), inline = true },
        { name = 'Price', value = '$' .. tostring(data.price), inline = true },
        { name = 'Territory', value = data.territory or 'Unknown', inline = true },
        { name = '2x Bonus?', value = (data.territory == active2xZone and data.drug == active2xDrug) and 'Yes' or 'No', inline = true }
      }
    })
  elseif data.action == 'drug_stolen' then
    exports['drp-logs']:log('drugs', {
      source = data.source,
      title = 'Drugs Stolen',
      description = 'Player had drugs stolen during sale',
      colorName = 'error',
      fields = {
        { name = 'Drug', value = drugLabel, inline = true },
        { name = 'Amount', value = tostring(data.amount), inline = true },
        { name = 'Territory', value = data.territory or 'Unknown', inline = true }
      }
    })
  elseif data.action == 'drug_recovered' then
    exports['drp-logs']:log('drugs', {
      source = data.source,
      title = 'Drugs Recovered',
      description = 'Player recovered stolen drugs',
      colorName = 'warning',
      fields = {
        { name = 'Drug', value = drugLabel, inline = true },
        { name = 'Amount', value = tostring(data.amount), inline = true }
      }
    })
  end
end)
