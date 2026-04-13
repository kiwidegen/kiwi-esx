Config = {}

Config.progressPerCatch = 0.05 -- The progress per one fish caught

---@class Fish
---@field price integer | { min: integer, max: integer }
---@field chance integer Percentage chance
---@field skillcheck SkillCheckDifficulity }

---@type table<string, Fish>
Config.fish = {
    -- Freshwater Fish
    ['brown_trout'] = { price = { min = 40, max = 70 }, chance = 40, skillcheck = { 'easy', 'medium' } },
    ['trout'] = { price = { min = 50, max = 100 }, chance = 35, skillcheck = { 'easy', 'medium' } },
    ['salmon'] = { price = { min = 200, max = 250 }, chance = 20, skillcheck = { 'easy', 'medium', 'medium' } },
    ['piranha'] = { price = { min = 350, max = 450 }, chance = 5, skillcheck = { 'easy', 'medium', 'hard' } },

    -- Normal/Saltwater Fish
    ['anchovy'] = { price = { min = 25, max = 50 }, chance = 40, skillcheck = { 'easy' } },
    ['barramundi'] = { price = { min = 100, max = 150 }, chance = 30, skillcheck = { 'easy', 'medium' } },
    ['bream'] = { price = { min = 60, max = 90 }, chance = 35, skillcheck = { 'easy', 'medium' } },
    ['flathead'] = { price = { min = 80, max = 120 }, chance = 30, skillcheck = { 'easy', 'medium' } },
    ['haddock'] = { price = { min = 150, max = 200 }, chance = 25, skillcheck = { 'easy', 'medium' } },
    ['mullet'] = { price = { min = 30, max = 60 }, chance = 45, skillcheck = { 'easy' } },
    ['red_snapper'] = { price = { min = 400, max = 500 }, chance = 20, skillcheck = { 'easy', 'medium', 'medium', 'medium' } },
    ['sea_bass'] = { price = { min = 120, max = 180 }, chance = 25, skillcheck = { 'easy', 'medium' } },
    ['grouper'] = { price = { min = 300, max = 400 }, chance = 20, skillcheck = { 'easy', 'medium', 'medium', 'medium' } },

    -- Deep Water Fish
    ['mahimahi'] = { price = { min = 450, max = 550 }, chance = 20, skillcheck = { 'easy', 'medium', 'medium', 'hard' } },
    ['marlin'] = { price = { min = 600, max = 750 }, chance = 15, skillcheck = { 'easy', 'medium', 'hard' } },
    ['bluefin_tuna'] = { price = { min = 1500, max = 2000 }, chance = 10, skillcheck = { 'easy', 'medium', 'hard', 'hard' } },
    ['tuna'] = { price = { min = 1000, max = 1300 }, chance = 18, skillcheck = { 'easy', 'medium', 'hard' } },
    ['shark'] = { price = { min = 2500, max = 3000 }, chance = 2, skillcheck = { 'easy', 'medium', 'hard', 'hard' } },
}

---@class FishingRod
---@field name string
---@field price integer
---@field minLevel integer The minimal level
---@field breakChance integer Percentage chance

---@type FishingRod[]
Config.fishingRods = {
    { name = 'basic_rod', price = 1000, minLevel = 1, breakChance = 20 },
    { name = 'graphite_rod', price = 2500, minLevel = 2, breakChance = 10 },
    { name = 'titanium_rod', price = 5000, minLevel = 3, breakChance = 1 },
}

---@class FishingBait
---@field name string
---@field price integer
---@field minLevel integer The minimal level
---@field waitDivisor number The total wait time gets divided by this value

---@type FishingBait[]
Config.baits = {
    { name = 'worms', price = 5, minLevel = 1, waitDivisor = 1.0 },       -- Low tier bait
    { name = 'mussel', price = 25, minLevel = 2, waitDivisor = 2.0 },     -- Mid tier bait
    { name = 'pilchards', price = 50, minLevel = 3, waitDivisor = 3.5 },  -- Best tier bait
}

---@class FishingZone
---@field locations vector3[] One of these gets picked at random
---@field radius number
---@field minLevel integer
---@field waitTime { min: integer, max: integer }
---@field includeOutside boolean Whether you can also catch fish from Config.outside
---@field blip BlipData?
---@field message { enter: string, exit: string }?
---@field fishList string[]

---@type FishingZone[]
Config.fishingZones = {
    {
        name = 'FreshWater',
        minLevel = 1,
        waitTime = { min = 5, max = 10 },
        includeOutside = true,
        message = { enter = 'You have entered freshwater.', exit = 'You have left freshwater.' },
        fishList = { 'brown_trout', 'trout', 'salmon', 'barramundi', 'piranha' },
        checkFunction = 'InFreshwaterFlyfish'
    },
    {
        name = 'CrabArea',
        minLevel = 1,
        waitTime = { min = 8, max = 15 },
        includeOutside = false,
        message = { enter = 'You have entered a crab area.', exit = 'You have left the crab area.' },
        fishList = { 'anchovy', 'mullet', 'bream' }, -- crabs would go here
        checkFunction = 'InCrabArea'
    },
    {
        name = 'SaltwaterFlyfish',
        minLevel = 2,
        waitTime = { min = 10, max = 20 },
        includeOutside = true,
        message = { enter = 'You have entered saltwater fishing grounds.', exit = 'You have left saltwater fishing grounds.' },
        fishList = { 'barramundi', 'flathead', 'haddock', 'sea_bass', 'red_snapper', 'grouper' },
        checkFunction = 'InSaltwaterFlyfish'
    },
    {
        name = 'DeepSea',
        minLevel = 3,
        waitTime = { min = 20, max = 40 },
        includeOutside = false,
        message = { enter = 'You have entered deep waters.', exit = 'You have left deep waters.' },
        fishList = { 'mahimahi', 'marlin', 'tuna', 'bluefin_tuna', 'shark' },
        checkFunction = 'InDeepsea'
    },
}

-- Outside of all zones
Config.outside = {
    waitTime = { min = 10, max = 25 },

    ---@type string[]
    fishList = {
        'anchovy', 'mullet', 'bream', 'flathead'
    }
}

Config.ped = {
    model = `s_m_m_cntrybar_01`,
    buyAccount = 'money',
    sellAccount = 'money',
    blip = {
        name = 'Fisherman',
        sprite = 356,
        color = 74,
        scale = 0.75
    },

    ---@type vector4[]
    locations = {
        vector4(-2081.3831, 2614.3223, 3.0840, 112.7910),
        vector4(-1492.3639, -939.2579, 10.2140, 144.0305)
    }
}

Config.renting = {
    model = `s_m_m_dockwork_01`, -- The ped model
    account = 'money',
    boats = {
        { model = `speeder`, price = 500, image = 'https://i.postimg.cc/mDSqWj4P/164px-Speeder.webp' },
        { model = `dinghy`, price = 750, image = 'https://i.postimg.cc/ZKzjZgj0/164px-Dinghy2.webp'  },
        { model = `tug`, price = 1250, image = 'https://i.postimg.cc/jq7vpKHG/164px-Tug.webp' }
    },
    blip = {
        name = 'Boat Rental',
        sprite = 410,
        color = 74,
        scale = 0.75
    },
    returnDivider = 5, -- Players can return it and get some cash back
    returnRadius = 30.0, -- The save radius

    ---@type { coords: vector4, spawn: vector4 }[]
    locations = {
        { coords = vector4(-1434.4818, -1512.2745, 2.1486, 25.8666), spawn = vector4(-1494.4496, -1537.6943, 2.3942, 115.6015) }
    }
}