ScrappingConfig = {}

-- Loot Pool for Vehicle Scrapping
ScrappingConfig.VehicleLootPool = {
  rewards = {
    common = {
      { item = "copper",     minAmount = 1, maxAmount = 3, weight = 40 },
      { item = "steel",      minAmount = 1, maxAmount = 3, weight = 30 },
      { item = "plastic",    minAmount = 1, maxAmount = 3, weight = 20 },
      { item = "lead",       minAmount = 1, maxAmount = 3, weight = 15 },
      { item = "iron",       minAmount = 1, maxAmount = 3, weight = 15 },
      { item = "copperwire", minAmount = 1, maxAmount = 3, weight = 10 },
      { item = "rubber",     minAmount = 1, maxAmount = 3, weight = 10 },
    },
    rare = {
      { item = "box_ammo_9mm", minAmount = 1, maxAmount = 1, weight = 10 },
    },
  },
  -- Tier chances (must add up to 100)
  tierChances = {
    common = 95,  -- 95% chance for common items
    rare = 5,     -- 5% chance for rare items
  },
  nothingChance = 0.05,   -- 5% chance to get nothing
  minRewards = 1,         -- Minimum number of rewards
  maxRewards = 4,         -- Maximum number of rewards
  VehicleCooldown = 10    -- Cooldown in seconds for vehicle scrapping
}

-- Loot Pool for Bin Searching
ScrappingConfig.BinLootPool = {
  rewards = {
    common = {
      { item = "plastic",       minAmount = 1, maxAmount = 3, weight = 30 },
      { item = "glass",         minAmount = 1, maxAmount = 3, weight = 20 },
      { item = "bullet_casing", minAmount = 1, maxAmount = 3, weight = 15 },
      { item = "copperwire",    minAmount = 1, maxAmount = 3, weight = 15 },
      { item = "hack_usb",      minAmount = 1, maxAmount = 3, weight = 10 },
      { item = "steel",         minAmount = 1, maxAmount = 3, weight = 10 },
      { item = "polyethylene",  minAmount = 1, maxAmount = 3, weight = 10 },
      { item = "ceramic",       minAmount = 1, maxAmount = 3, weight = 10 },
      { item = "metalscrap",    minAmount = 1, maxAmount = 3, weight = 10 },
      { item = "weaponparts",    minAmount = 1, maxAmount = 1, weight = 10 },
    },

    rare = {
      { item = "box_ammo_9mm", minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "ditto",        minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "eevee",        minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "electabuzz",   minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "electrode",    minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "flareon",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "golduck",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "gyarados",     minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "hitmonchan",   minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "hitmonlee",    minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "jigglypuff",   minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "jolteon",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "jynx",         minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "kadabra",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "kangaskhan",   minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "lapras",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "machamp",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "magmar",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "mrmime",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "nidoking",     minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "nidoqueen",    minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "ninetails",    minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "onix",         minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "pidgeot",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "raichu",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "rapidash",     minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "rhydon",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "scyther",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "starmie",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "tangela",      minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "tauros",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "togepi",       minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "vaporeon",     minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "venomoth",     minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "venusaur",     minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "victreebel",   minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "vileplume",    minAmount = 1, maxAmount = 1, weight = 5 },
      { item = "wigglytuff",   minAmount = 1, maxAmount = 1, weight = 5 },
    },
    ultra_rare = {
      { item = "aerodactyl", minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "articuno",   minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "blastoise",  minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "charizard",  minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "dragonair",  minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "dragonite",  minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "dratini",    minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "kabuto",     minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "kabutops",   minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "mew",        minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "mewtwo",     minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "moltres",    minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "omanyte",    minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "omastar",    minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "porygon",    minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "snorlax",    minAmount = 1, maxAmount = 1, weight = 2 },
      { item = "zapdos",     minAmount = 1, maxAmount = 1, weight = 2 },
    },
    special = {
      { item = "blastoisev",           minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "charizardv",           minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "mewv",                 minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "pikachuv",             minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "snorlaxv",             minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "venusaurv",            minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "blastoisevmax",        minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "mewtwogx",             minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "snorlaxvmax",          minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "venusaurvmax",         minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "vmaxcharizard",        minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "vmaxpikachu",          minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "rainbowmewtwogx",      minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "rainbowvmaxcharizard", minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "rainbowvmaxpikachu",   minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "snorlaxvmaxrainbow",   minAmount = 1, maxAmount = 1, weight = 1 },
    },
    badges_boxes = {
      { item = "boosterbox",   minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "boosterpack",  minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "boulderbadge", minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "cascadebadge", minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "thunderbadge", minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "rainbowbadge", minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "soulbadge",    minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "marshbadge",   minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "volcanobadge", minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "earthbadge",   minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "trophybadge",  minAmount = 1, maxAmount = 1, weight = 1 },
      { item = "pokebox",      minAmount = 1, maxAmount = 1, weight = 1 },
    },
  },
  -- Tier chances (must add up to 100)
  tierChances = {
    common = 70,        -- 70% chance for common items
    rare = 20,          -- 20% chance for rare items (Pokemon cards)
    ultra_rare = 7,     -- 7% chance for ultra rare (Legendary Pokemon)
    special = 2,        -- 2% chance for special (V/VMAX cards)
    badges_boxes = 1,   -- 1% chance for badges/boxes
  },
  nothingChance = 0.10,   -- 10% chance to get nothing
  minRewards = 1,         -- Minimum number of rewards
  maxRewards = 3,         -- Maximum number of rewards
  BinCooldown = 15        -- Cooldown in seconds for bin searching
}
