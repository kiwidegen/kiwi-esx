---@class LootboxReward
---@field item? string Item name
---@field weapon? string Weapon name
---@field money? number Money amount
---@field black_money? number Black money amount
---@field amount? number Item/reward amount
---@field minAmount? number Minimum amount (for random ranges)
---@field maxAmount? number Maximum amount (for random ranges)
---@field label string Display label for the reward
---@field tier number Rarity tier (1-5)
---@field metadata? table Item/weapon metadata

---@class LootboxConfig
---@field list LootboxReward[] List of possible rewards

---@class ChanceTier
---@field name string Tier name
---@field rate number Probability rate (as percentage)

---@class CasesConfig
CasesConfig = {}

---@type string Image source path for UI
CasesConfig.IMAGE_SOURCE = 'nui://ox_inventory/web/images/'

---@type string Event to trigger when closing inventory HUD (leave empty if not used)
CasesConfig.CLOSE_INVENTORY_HUD_TRIGGER = ''

---@type ChanceTier[] Rarity tier chances (must add up to 100%)
CasesConfig.CHANCE = {
    [1] = { name = 'Common', rate = 70 },      -- 70% chance
    [2] = { name = 'Rare', rate = 20 },        -- 20% chance
    [3] = { name = 'Epic', rate = 8 },         -- 8% chance
    [4] = { name = 'Unique', rate = 1.5 },     -- 1.5% chance
    [5] = { name = 'Legendary', rate = 0.5 },  -- 0.5% chance
}

---@type boolean Enable Discord webhook notifications
CasesConfig.ENABLE_BROADCAST = true

---@type table<number, boolean> Which tiers trigger Discord notifications
CasesConfig.BROADCAST_TIER = {
    [1] = false,  -- Common
    [2] = false,  -- Rare
    [3] = true,   -- Epic
    [4] = true,   -- Unique
    [5] = true,   -- Legendary
}

---@type string Discord webhook URL for notifications (DEPRECATED - now uses drp-logs)
-- CasesConfig.DISCORD_WEBHOOK = '' -- Removed: Now using drp-logs export

---@type table<string, LootboxConfig> Lootbox configurations
CasesConfig.LOOTBOXES = {
    ['lootbox'] = {
        list = {
            { money = 1500000, label = 'Cash Prize: $1,500,000', tier = 5 },
            { weapon = 'WEAPON_TACTICALRIFLE', label = 'Tactical Rifle', tier = 5 },
            { weapon = 'WEAPON_MINISHOTGUN', label = 'Mini Shotgun', tier = 5 },
            { weapon = 'WEAPON_BLUEARP', label = 'Blue ARP', tier = 5 },
            { black_money = 250000, label = 'Black Cash: $250,000', tier = 4 },
            { item = 'goldbar', amount = 5, label = '5 Gold Bars', tier = 3 },
            { weapon = 'WEAPON_GLOCK22', label = 'GLOCK 22', tier = 3 },
            { item = 'heavy_armor', amount = 10, label = '10 Heavy Armor', tier = 3 },
            { item = 'rainbowmewtwogx', amount = 1, label = 'Rainbow Mewtwo GX', tier = 3 },
            { item = 'rainbowvmaxcharizard', amount = 1, label = 'Rainbow VMAX Charizard', tier = 3 },
            { item = 'light_armor', amount = 10, label = '10 Light Armor', tier = 4 },
            { item = 'snorlaxvmax', amount = 1, label = 'Snorlax VMAX', tier = 2 },
            { item = 'rainbowvmaxpikachu', amount = 1, label = 'Rainbow VMAX Pikachu', tier = 2 },
            { item = 'snorlaxvmaxrainbow', amount = 1, label = 'Snorlax VMAX Rainbow', tier = 1 },
        }
    },
    ['lootbox1'] = {
        list = {
            { money = 150000, label = 'Cash Prize: $150,000', tier = 5 },
            { weapon = 'WEAPON_TACTICALRIFLE', label = 'Tactical Rifle', tier = 5 },
            { weapon = 'WEAPON_MINISHOTGUN', label = 'Mini Shotgun', tier = 5 },
            { weapon = 'WEAPON_BLUEARP', label = 'Blue ARP', tier = 5 },
            { black_money = 20000, label = 'Black Cash: $20,000', tier = 4 },
            { item = 'goldbar', amount = 5, label = '5 Gold Bars', tier = 3 },
            { item = 'heavy_armor', amount = 10, label = '10 Heavy Armor', tier = 4 },
            { item = 'rainbowmewtwogx', amount = 1, label = 'Rainbow Mewtwo GX', tier = 3 },
            { item = 'rainbowvmaxcharizard', amount = 1, label = 'Rainbow VMAX Charizard', tier = 3 },
            { weapon = 'WEAPON_GLOCK22', label = 'GLOCK 22', tier = 3 },
            { item = 'light_armor', amount = 10, label = '10 Light Armor', tier = 2 },
            { item = 'snorlaxvmax', amount = 1, label = 'Snorlax VMAX', tier = 2 },
            { item = 'rainbowvmaxpikachu', amount = 1, label = 'Rainbow VMAX Pikachu', tier = 2 },
            { item = 'snorlaxvmaxrainbow', amount = 1, label = 'Snorlax VMAX Rainbow', tier = 1 },
        }
    },
}
