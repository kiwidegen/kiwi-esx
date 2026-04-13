---@class RecycleConfig
---@field enter_location vector4 Warehouse entrance coordinates
---@field exit_location vector4 Warehouse exit coordinates
---@field package_locations table<number, vector4> Package spawn locations
---@field dropoff_location vector4 Package dropoff coordinates
---@field warehouse_objects string[] Props for package locations
---@field PickupBoxModel string Box model for carrying
---@field MaxItemsReceived number Maximum items per package (0-2 extra after base)
---@field MinItemReceivedQty number Minimum quantity per item
---@field MaxItemReceivedQty number Maximum quantity per item
---@field ChanceItem string Rare item name
---@field ChanceItemProbability number Chance for rare item (0-100)
---@field LuckyItem string Lucky bonus item name
---@field LuckyItemProbability number Chance for lucky item (1-10)
---@field ItemTable string[] Available items from packages
---@field SellPrices table<string, number> Item sell prices
RecycleConfig = {}

-- Warehouse Locations
RecycleConfig.enter_location = vector4(-184.88, 6271.18, 31.49, 36.97)
RecycleConfig.exit_location = vector4(1073.08, -3102.59, -39.0, 88.64)
RecycleConfig.dropoff_location = vector4(1048.12, -3097.11, -39.0, 86.34)

-- Package Spawn Locations
RecycleConfig.package_locations = {
    vector4(1067.68, -3095.43, -39.9, 342.39),
    vector4(1065.2, -3095.56, -39.9, 356.53),
    vector4(1062.73, -3095.15, -39.9, 184.81),
    vector4(1060.37, -3095.06, -39.9, 190.3),
    vector4(1057.95, -3095.51, -39.9, 359.02),
    vector4(1055.58, -3095.53, -39.9, 0.95),
    vector4(1053.09, -3095.57, -39.9, 347.64),
    vector4(1053.07, -3102.46, -39.9, 180.26),
    vector4(1055.49, -3102.45, -39.9, 180.46),
    vector4(1057.93, -3102.55, -39.9, 174.22),
    vector4(1060.19, -3102.38, -39.9, 189.44),
    vector4(1062.71, -3102.53, -39.9, 182.11),
    vector4(1065.19, -3102.48, -39.9, 176.23),
    vector4(1067.46, -3102.62, -39.9, 188.28),
    vector4(1067.69, -3110.01, -39.9, 173.63),
    vector4(1065.13, -3109.88, -39.9, 179.46),
    vector4(1062.7, -3110.07, -39.9, 174.32),
    vector4(1060.24, -3110.26, -39.9, 177.77),
    vector4(1057.76, -3109.82, -39.9, 183.88),
    vector4(1055.52, -3109.76, -39.9, 181.36),
    vector4(1053.16, -3109.71, -39.9, 177.0),
}

-- Warehouse Props
RecycleConfig.warehouse_objects = {
    "prop_boxpile_05a",
    "prop_boxpile_04a",
    "prop_boxpile_06b",
    "prop_boxpile_02c",
    "prop_boxpile_02b",
    "prop_boxpile_01a",
    "prop_boxpile_08a",
}

-- Pickup Box Model
RecycleConfig.PickupBoxModel = "prop_cs_cardbox_01"

-- Item Reward Settings
RecycleConfig.MaxItemsReceived = 3        -- Player gets 1 base + 0-2 extra items
RecycleConfig.MinItemReceivedQty = 1
RecycleConfig.MaxItemReceivedQty = 3

-- Special Items
RecycleConfig.ChanceItem = "trojan_usb"
RecycleConfig.ChanceItemProbability = 7   -- 7% chance

RecycleConfig.LuckyItem = "plastic"
RecycleConfig.LuckyItemProbability = 10   -- 10% chance (1/10)

-- Available Items
RecycleConfig.ItemTable = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "rubber",
    "trojan_usb"
}

-- Sell Prices
RecycleConfig.SellPrices = {
    ['metalscrap'] = 150,
    ['plastic'] = 200,
    ['copper'] = 220,
    ['iron'] = 250,
    ['aluminum'] = 270,
    ['steel'] = 300,
    ['rubber'] = 180,
    ['trojan_usb'] = 400
}

-- Export config for server use
_ENV.Config = RecycleConfig