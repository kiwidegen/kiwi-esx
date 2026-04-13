---@class DRPConfig
Config = {}

-- ============================================
-- MEGAPHONE CONFIGURATION
-- ============================================

--- Jobs allowed to use megaphone
---@type table<string, boolean>
Config.Megaphone = {}
Config.Megaphone.AllowedJobs = {
    sapd = true,
    sadoj = true,
    fib = true,
    gtf = true,
    police = true,
    sheriff = true
}

--- Vehicle class that supports megaphone (18 = Emergency Vehicles)
---@type number
Config.Megaphone.VehicleClass = 18

-- ============================================
-- HELICAM CONFIGURATION
-- ============================================

Config.Helicam = {}

--- Helicopter models that support camera system
---@type table<number, string>
Config.Helicam.AllowedVehicles = {
    "polmav",
    "buzzm",
    "frogger2",
    "valk_swat",
    "sahpair",
    "2vd_supervolito",
    "hunter2",
    "hunter3",
    "mdsvolito",
    "dlswift",
    "unimav",
    "unimxv",
    "maverikc",
    "annm3",
    "jcon"  -- Buckingham Conada Police Helicopter
}

-- ============================================
-- CARWASH CONFIGURATION
-- ============================================

Config.Carwash = {}

--- Car wash locations and pricing
---@type table<number, {coords: vector3, price: number}>
Config.Carwash.Locations = {
    { coords = vector3(22.3163, -1391.9515, 28.3292),  price = 500 },
    { coords = vector3(169.35, -1716.72, 28.70),       price = 500 },
    { coords = vector3(-699.78, -933.04, 18.72),       price = 500 },
    { coords = vector3(1361.88, 3592.44, 34.45),       price = 500 },
    { coords = vector3(2702.1680, 3452.6550, 55.1407), price = 500 },
    { coords = vector3(-888.9489, -2042.5063, 8.9992), price = 500 }
}

--- Wash duration in milliseconds
---@type number
Config.Carwash.WashDuration = 10000

-- ============================================
-- VEHCONTROL (EMERGENCY VEHICLE) CONFIGURATION
-- ============================================

Config.VehControl = {}

--- Vehicle models that use fire truck sirens
---@type string[]
Config.VehControl.FiretruckSirenModels = {
    "FIRETRUK",
    "LSFDTRUCK",
    "AMBO",
    "ARROWLADDER",
    "LSFDAMBO",
    "FD1",
    "FD2",
    "FD3",
    "FD4",
    "POLSCHAFTER3"
}

--- Vehicle models that support powercall auxiliary siren
---@type string[]
Config.VehControl.PowercallModels = {
    "AMBULANCE",
    "FIRETRUK",
    "LGUARD",
    "LSFDTRUCK",

    -- Custom Cop Cars
    "evajv",              -- Vapid SUV
    "gresleyhellfirepd",  -- Bravado Gresley Hellfire PD
    "jcon",               -- Buckingham Conada Helicopter
    "pbbgtsj",            -- Bravado Banshee PD
    "sebbjv",             -- Bravado Buffalo (Unmarked)
    "spbbjh",             -- Bravado Buffalo (Highway)
    "spbbjv",             -- Bravado Buffalo (Patrol)
    "spbgjv",             -- Bravado Gauntlet
    "sphijv",             -- HVY Insurgent
    "spnsbjv",            -- Nagasaki Motorcycle
    "spvdjv",             -- Ford Dominator
    "stxhpd"              -- Bravado Buffalo (STX)
}
-- ============================================
-- AUTO THERMAL (VEHICLE THERMAL CAM) CONFIGURATION
-- ============================================

Config.AutoThermal = {}

--- Vehicle models that support thermal camera system (model hash -> camera height)
---@type table<number, number>
Config.AutoThermal.VehicleCamHeights = {
    [GetHashKey("sheriff2")] = 1.5,
    [GetHashKey("polcmd")] = 1.8,
    [GetHashKey("polcmd2")] = 1.8,

    -- Custom Cop Cars
    [GetHashKey("evajv")] = 1.8,              -- Vapid SUV
    [GetHashKey("gresleyhellfirepd")] = 1.6,  -- Bravado Gresley Hellfire PD
    [GetHashKey("pbbgtsj")] = 1.5,            -- Bravado Banshee PD
    [GetHashKey("sebbjv")] = 1.5,             -- Bravado Buffalo (Unmarked)
    [GetHashKey("spbbjh")] = 1.5,             -- Bravado Buffalo (Highway)
    [GetHashKey("spbbjv")] = 1.5,             -- Bravado Buffalo (Patrol)
    [GetHashKey("spbgjv")] = 1.6,             -- Bravado Gauntlet
    [GetHashKey("sphijv")] = 2.0,             -- HVY Insurgent
    [GetHashKey("spvdjv")] = 1.6,             -- Ford Dominator
    [GetHashKey("stxhpd")] = 1.5              -- Bravado Buffalo (STX)
}

-- ============================================
-- DAILY REWARD CONFIGURATION
-- ============================================

Config.DailyReward = {}

--- Cooldown time in seconds before player can claim again (24 hours)
---@type number
Config.DailyReward.CooldownSeconds = 86400

--- Minimum reward amount
---@type number
Config.DailyReward.MinReward = 1000

--- Maximum reward amount
---@type number
Config.DailyReward.MaxReward = 5000

-- ============================================
-- RICH PRESENCE (DISCORD) CONFIGURATION
-- ============================================

Config.RichPresence = {}

--- Discord application ID
---@type string
Config.RichPresence.AppId = "YOUR_DISCORD_APP_ID"

--- Discord invite link
---@type string
Config.RichPresence.DiscordLink = "https://discord.gg/yourserver"

--- FiveM server link
---@type string
Config.RichPresence.FiveMLink = "fivem://connect/yourserver.com"

--- Server display name
---@type string
Config.RichPresence.ServerName = "Your Server Name"

--- Maximum player count
---@type number
Config.RichPresence.MaxPlayers = 32

--- Large logo asset name (must be uploaded to Discord application)
---@type string
Config.RichPresence.LargeLogo = "logo_large"

--- Small logo asset name (must be uploaded to Discord application)
---@type string
Config.RichPresence.SmallLogo = "logo_small"

-- ============================================
-- DJ SYSTEM CONFIGURATION
-- ============================================

Config.DJ = {}

--- DJ booth locations with job restrictions and playlists
---@type table<string, {jobs: string[], coords: vector3, radius: number, playlist: table[]}>
Config.DJ = {
    ['Hotbox'] = {
        jobs = { 'bahama' },
        coords = vector3(3473.30, 4951.87, 34.99),
        radius = 150.0,
        playlist = {
            {
                name = 'JUNGE BALLER',
                producer = 'Ski Aggu, Haaland936, SIRA',
                link = 'https://www.youtube.com/watch?v=Eiv4M9XY9D4'
            },
            {
                name = 'Baile',
                producer = 'Kauta, Amo, Haaland936',
                link = 'https://www.youtube.com/watch?v=54xMH2KK2dw'
            },
            {
                name = 'HEUTE MIT MIR',
                producer = 'Nimo',
                link = 'https://www.youtube.com/watch?v=p-AWcCCbBHw'
            },
            {
                name = 'FE!N',
                producer = 'Travis Scott, ft. Playboi Carti',
                link = 'https://www.youtube.com/watch?v=U-l4ya3ejko'
            },
            {
                name = 'The Buzz',
                producer = 'Hermitude',
                link = 'https://www.youtube.com/watch?v=bQSi33FJZM4'
            },
            {
                name = 'Losing It',
                producer = 'FISHER',
                link = 'https://www.youtube.com/watch?v=u31thuMehjM'
            },
            {
                name = 'Hau den Stein',
                producer = 'Hemso',
                link = 'https://www.youtube.com/watch?v=5w-eUtT060A'
            },
            {
                name = 'California Gurls',
                producer = 'Katy Perry ft. Snoop Dogg',
                link = 'https://www.youtube.com/watch?v=F57P9C4SAW4'
            }
        }
    },
    ['Hotbox2'] = {
        jobs = { 'hotbox' },
        coords = vector3(-848.6174, -232.1573, 30.9809),
        radius = 150.0,
        playlist = {
            {
                name = 'JUNGE BALLER',
                producer = 'Ski Aggu, Haaland936, SIRA',
                link = 'https://www.youtube.com/watch?v=Eiv4M9XY9D4'
            },
            {
                name = 'Baile',
                producer = 'Kauta, Amo, Haaland936',
                link = 'https://www.youtube.com/watch?v=54xMH2KK2dw'
            },
            {
                name = 'HEUTE MIT MIR',
                producer = 'Nimo',
                link = 'https://www.youtube.com/watch?v=p-AWcCCbBHw'
            },
            {
                name = 'FE!N',
                producer = 'Travis Scott, ft. Playboi Carti',
                link = 'https://www.youtube.com/watch?v=U-l4ya3ejko'
            },
            {
                name = 'The Buzz',
                producer = 'Hermitude',
                link = 'https://www.youtube.com/watch?v=bQSi33FJZM4'
            },
            {
                name = 'Losing It',
                producer = 'FISHER',
                link = 'https://www.youtube.com/watch?v=u31thuMehjM'
            },
            {
                name = 'Hau den Stein',
                producer = 'Hemso',
                link = 'https://www.youtube.com/watch?v=5w-eUtT060A'
            },
            {
                name = 'California Gurls',
                producer = 'Katy Perry ft. Snoop Dogg',
                link = 'https://www.youtube.com/watch?v=F57P9C4SAW4'
            }
        }
    },
    ['Hotbox3'] = {
        jobs = { 'hotbox' },
        coords = vector3(-857.9683, -241.0392, 61.9961),
        radius = 25.0,
        playlist = {
            {
                name = 'JUNGE BALLER',
                producer = 'Ski Aggu, Haaland936, SIRA',
                link = 'https://www.youtube.com/watch?v=Eiv4M9XY9D4'
            },
            {
                name = 'Baile',
                producer = 'Kauta, Amo, Haaland936',
                link = 'https://www.youtube.com/watch?v=54xMH2KK2dw'
            },
            {
                name = 'HEUTE MIT MIR',
                producer = 'Nimo',
                link = 'https://www.youtube.com/watch?v=p-AWcCCbBHw'
            },
            {
                name = 'FE!N',
                producer = 'Travis Scott, ft. Playboi Carti',
                link = 'https://www.youtube.com/watch?v=U-l4ya3ejko'
            },
            {
                name = 'The Buzz',
                producer = 'Hermitude',
                link = 'https://www.youtube.com/watch?v=bQSi33FJZM4'
            },
            {
                name = 'Losing It',
                producer = 'FISHER',
                link = 'https://www.youtube.com/watch?v=u31thuMehjM'
            },
            {
                name = 'Hau den Stein',
                producer = 'Hemso',
                link = 'https://www.youtube.com/watch?v=5w-eUtT060A'
            },
            {
                name = 'California Gurls',
                producer = 'Katy Perry ft. Snoop Dogg',
                link = 'https://www.youtube.com/watch?v=F57P9C4SAW4'
            }
        }
    },
    ['sapd'] = {
        jobs = { 'sapd' },
        coords = vector3(-1075.6914, -799.0899, 19.3275),
        radius = 10.0,
        playlist = {}
    },
    ['sapd2'] = {
        jobs = { 'sapd' },
        coords = vector3(-1106.0486, -843.6112, 34.2746),
        radius = 10.0,
        playlist = {}
    },
    ['cd'] = {
        jobs = { 'cd' },
        coords = vector3(1117.7733, -642.1153, 56.8180),
        radius = 25.0,
        playlist = {}
    },
    ['cd2'] = {
        jobs = { 'cd' },
        coords = vector3(-1373.7397, -929.2950, 9.9895),
        radius = 25.0,
        playlist = {}
    },
    ['paradiso'] = {
        jobs = { 'paradiso' },
        coords = vector3(229.9019, 3998.1726, 55.7643),
        radius = 150.0,
        playlist = {}
    },
    ['sevo_lounge'] = {
        jobs = { 'sevo_lounge' },
        coords = vector3(-1126.9263, -381.4326, 49.3038),
        radius = 50.0,
        playlist = {}
    },
    ['ldp'] = {
        jobs = { 'ldp' },
        coords = vector3(-1187.3740, -1415.9940, 17.9132),
        radius = 25.0,
        playlist = {}
    },
    ['vm'] = {
        jobs = { 'vm' },
        coords = vector3(132.0226, -1702.2968, 38.4659),
        radius = 25.0,
        playlist = {}
    }
}

-- ============================================
-- SIT CONFIGURATION
-- ============================================

SitConfig = {}

--- Maximum distance to interact with sittable objects
---@type number
SitConfig.MaxDistance = 1.5

--- Key to get up from sitting
---@type string
SitConfig.GetUpKey = 'E'

--- Sittable object models and configurations
--- Loaded from source/drp-sit/models.lua
---@type table<number, {maxSeats: number, action: string, seats: table}>
SitConfig.Models = {}

--- Sitting actions (scenarios and animations)
--- Loaded from source/drp-sit/actions.lua
---@type table<string, {type: string, scenario: string}>
SitConfig.Actions = {}

-- ============================================
-- STATUS SYSTEM CONFIGURATION
-- ============================================

StatusConfig = {}

--- Maximum value for any status (compatible with esx_status)
---@type number
StatusConfig.StatusMax = 1000000

--- How often to process status updates (milliseconds)
---@type number
StatusConfig.TickTime = 1000

--- How often to save status to database (milliseconds)
---@type number
StatusConfig.UpdateInterval = 30000

--- Statuses Definition
---@type table<string, {default: number, tickAmount: number}>
StatusConfig.Statuses = {
	hunger = {
		default = 1000000,  -- Starting value
		tickAmount = -100   -- Amount to change per tick (negative = drain, positive = regen)
	},
	thirst = {
		default = 1000000,
		tickAmount = -90
	}
}

--- Enable damage when statuses reach 0
---@type boolean
StatusConfig.EnableDamage = true

--- HP to remove per tick when status is at 0
---@type number
StatusConfig.DamageAmount = 1

--- HP to remove per tick when health is below critical threshold
---@type number
StatusConfig.CriticalDamageAmount = 5

--- Health level that triggers critical damage
---@type number
StatusConfig.CriticalHealthThreshold = 150

--- Percentage of max to set statuses on respawn (50 = 500000)
---@type number
StatusConfig.RespawnStatusPercent = 50

-- ============================================
-- WEAPON SLING CONFIGURATION
-- ============================================

---@class SlingConfig
---@field Debug boolean Enable debug mode
---@field Positions table<string, table<string, WeaponPosition>> Position configurations
---@field compatable_weapon_hashes table<string, WeaponData> Compatible weapon definitions
SlingConfig = {}

--- Enable for debugging weapon attachment issues
---@type boolean
SlingConfig.Debug = false
