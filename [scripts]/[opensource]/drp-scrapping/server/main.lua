---@class RewardItem
---@field item string Item name
---@field minAmount number Minimum amount
---@field maxAmount number Maximum amount
---@field weight number Weight for random selection

---@class LootPool
---@field rewards table<string, RewardItem[]> Reward tiers
---@field nothingChance number Chance to get nothing (0-1)
---@field minRewards number Minimum number of rewards
---@field maxRewards number Maximum number of rewards

-- Cooldown variables
---@type table<number, number>
local lastScrapTimes = {} -- Stores the last scrap time for each player

---@type table<number, number>
local searchedBins = {} -- Stores the last search time for each bin entity

--- Select a tier based on configured chances
---@param tierChances table<string, number> Tier name to chance mapping
---@return string tier Selected tier name
local function selectTier(tierChances)
  local roll = math.random(1, 100)
  local cumulative = 0

  for tier, chance in pairs(tierChances) do
    cumulative = cumulative + chance
    if roll <= cumulative then
      return tier
    end
  end

  -- Fallback to common if something goes wrong
  return 'common'
end

--- Helper function to select rewards from a loot pool using tier-based system
---@param lootPool LootPool The loot pool configuration
---@param minRewards number Minimum rewards to give
---@param maxRewards number Maximum rewards to give
---@return table<number, {item: string, amount: number}> rewards Selected rewards
local function selectRewards(lootPool, minRewards, maxRewards)
  local rewards = {}
  local numRewards = math.random(minRewards, maxRewards)

  -- Select rewards based on tier system
  for i = 1, numRewards do
    -- Select a tier based on configured chances
    local selectedTier = selectTier(lootPool.tierChances)
    local tierItems = lootPool.rewards[selectedTier]

    if tierItems and #tierItems > 0 then
      -- Build weighted list for this tier
      local weightedItems = {}
      for _, item in ipairs(tierItems) do
        for j = 1, item.weight do
          weightedItems[#weightedItems + 1] = {
            item = item.item,
            minAmount = item.minAmount,
            maxAmount = item.maxAmount
          }
        end
      end

      -- Select random item from this tier
      if #weightedItems > 0 then
        local index = math.random(1, #weightedItems)
        local selectedItem = weightedItems[index]
        rewards[#rewards + 1] = {
          item = selectedItem.item,
          amount = math.random(selectedItem.minAmount, selectedItem.maxAmount)
        }
      end
    end
  end

  return rewards
end

--- Send notification to player using ox_lib
---@param source number Player source
---@param description string Notification message
---@param type 'inform'|'error'|'success' Notification type
local function notify(source, description, type)
  lib.notify(source, {
    description = description,
    type = type or 'inform',
    duration = 5000,
    position = 'top-right'
  })
end

--- Callback to check if the player has a blow torch
---@param source number Player source
---@return boolean hasBlowTorch Whether player has a blowtorch
lib.callback.register('drp-scrapping:hasBlowTorch', function(source)
  if not source then
    print('[ERROR] drp-scrapping:hasBlowTorch - Source is nil')
    return false
  end

  -- Check inventory using ox_inventory export
  local blowTorch = exports.ox_inventory:Search(source, 'count', 'blowtorch')
  return blowTorch and blowTorch > 0
end)

--- Event to reward the player for vehicle scrapping
---@param source number Player source
RegisterNetEvent('drp-scrapping:reward', function()
  local src = source
  if not src then
    print('[ERROR] drp-scrapping:reward - Source is nil')
    return
  end

  -- Check cooldown
  local currentTime = os.time()
  if lastScrapTimes[src] and (currentTime - lastScrapTimes[src]) < ScrappingConfig.VehicleLootPool.VehicleCooldown then
    notify(src, 'You must wait before scrapping another vehicle.', 'error')
    return
  end

  -- Update cooldown
  lastScrapTimes[src] = currentTime

  -- Get torch inventory
  local torchItems = exports.ox_inventory:Search(src, 'slots', 'blowtorch')
  if not torchItems or #torchItems == 0 then
    notify(src, 'You need a blowtorch to scrap this vehicle.', 'error')
    return
  end

  -- Reduce torch durability
  local torch = torchItems[1]
  local currentDurability = torch.metadata.durability or 100
  local newDurability = currentDurability - 10 -- 10 durability loss per use
  if newDurability <= 0 then
    exports.ox_inventory:RemoveItem(src, 'blowtorch', 1, nil, torch.slot)
    notify(src, 'Your blowtorch broke!', 'error')
  else
    exports.ox_inventory:SetMetadata(src, torch.slot, { durability = newDurability })
  end

  -- Chance to get nothing
  if math.random() < ScrappingConfig.VehicleLootPool.nothingChance then
    notify(src, 'You found nothing useful.', 'inform')
    return
  end

  -- Select rewards from loot pool
  local rewards = selectRewards(ScrappingConfig.VehicleLootPool, ScrappingConfig.VehicleLootPool.minRewards,
    ScrappingConfig.VehicleLootPool.maxRewards)
  local addedItems = false

  for _, reward in ipairs(rewards) do
    if exports.ox_inventory:CanCarryItem(src, reward.item, reward.amount) then
      exports.ox_inventory:AddItem(src, reward.item, reward.amount)
      addedItems = true
    else
      notify(src, 'Not enough space for ' .. reward.item .. '.', 'error')
    end
  end

  if addedItems then
    notify(src, 'You scrapped some valuable materials!', 'success')
  end
end)

--- Event to reward the player for bin searching
---@param binEntity number Bin entity handle
RegisterNetEvent('drp-scrapping:binReward', function(binEntity)
  local src = source
  if not src then
    print('[ERROR] drp-scrapping:binReward - Source is nil')
    return
  end

  if not binEntity then
    notify(src, 'Invalid bin entity.', 'error')
    return
  end

  -- Check bin cooldown
  local currentTime = os.time()
  if searchedBins[binEntity] and (currentTime - searchedBins[binEntity]) < ScrappingConfig.BinLootPool.BinCooldown then
    notify(src, 'You have already searched this bin.', 'error')
    return
  end

  -- Update bin cooldown
  searchedBins[binEntity] = currentTime

  -- Chance to get nothing
  if math.random() < ScrappingConfig.BinLootPool.nothingChance then
    notify(src, 'You found nothing, champ.', 'inform')
    return
  end

  -- Select rewards from loot pool
  local rewards = selectRewards(ScrappingConfig.BinLootPool, ScrappingConfig.BinLootPool.minRewards, ScrappingConfig.BinLootPool.maxRewards)
  local addedItems = false

  for _, reward in ipairs(rewards) do
    if exports.ox_inventory:CanCarryItem(src, reward.item, reward.amount) then
      exports.ox_inventory:AddItem(src, reward.item, reward.amount)
      addedItems = true
    else
      notify(src, 'Not enough space for ' .. reward.item .. '.', 'error')
    end
  end

  if addedItems then
    notify(src, 'You found something, bin chicken!', 'success')
  end
end)
