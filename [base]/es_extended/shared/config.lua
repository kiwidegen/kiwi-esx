ESX    = {}
Config = {}

Config.Locale = GetConvar('esx:locale', 'en')

-- Tell ox_inventory it is the active inventory system for this ESX install.
Config.CustomInventory = 'ox'

-- Money accounts tracked by es_extended.
-- ox_inventory owns items and weapons — do NOT add those here.
Config.Accounts = {
    bank        = { label = 'Bank',         round = true },
    money       = { label = 'Cash',         round = true },
    black_money = { label = 'Black Money',  round = true },
}

-- Starting balance for new players (per account name).
Config.StartingAccountMoney = { bank = 50000 }

-- Fallback spawn position(s) for new / position-less players.
Config.DefaultSpawns = {
    { x = 222.2027, y = -864.0162, z = 30.2922, heading = 1.0 },
}

-- Groups that grant admin access via ESX.
Config.AdminGroups = {
    ['owner'] = true,
    ['admin'] = true,
}

-- Identifier type used as the primary key in the users table.
Config.Identifier = GetConvar('esx:identifier', 'license')

-- Job duty state assigned when a player changes job (true = on duty by default).
Config.DefaultJobDuty = true

-- Paycheck: pay players their job grade_salary on interval.
Config.EnablePaycheck   = true
Config.PaycheckInterval = 15 * 60000   -- milliseconds

-- Set true to load/save firstname, lastname, dateofbirth, sex, height columns.
Config.Identity = true

Config.EnableDebug      = false
Config.SaveDeathStatus  = true   -- save dead state to player metadata on death

-- ─────────────────────────────────────────────────────────────────────────────
-- Adjustments
-- ─────────────────────────────────────────────────────────────────────────────

Config.DisableHealthRegeneration = true  -- disable health regen
Config.DisableVehicleRewards     = true  -- stop players receiving weapons from stolen vehicles
Config.DisableNPCDrops           = true  -- stop NPCs dropping weapons on death
Config.DisableDispatchServices   = true   -- disable police/fire/ambulance dispatch AI
Config.DisableScenarios          = true   -- disable NPC world vehicle scenarios
Config.DisableAimAssist          = false  -- disable aim assist (mainly for controllers)
Config.DisableVehicleSeatShuff   = true  -- stop players being moved to driver seat on entry
Config.DisableDisplayAmmo        = false  -- hide ammo counter HUD
Config.EnablePVP                 = true   -- allow player vs player combat
Config.EnableWantedLevel         = false  -- use GTA's normal wanted level system

-- HUD components to hide (true = hidden).
-- Index matches SetHudComponentSize / SetHudComponentPosition component IDs.
Config.RemoveHudComponents = {
    [1]  = false, -- WANTED_STARS
    [2]  = false, -- WEAPON_ICON
    [3]  = false, -- CASH
    [4]  = false, -- MP_CASH
    [5]  = false, -- MP_MESSAGE
    [6]  = true,  -- VEHICLE_NAME
    [7]  = true,  -- AREA_NAME
    [8]  = true,  -- VEHICLE_CLASS
    [9]  = true,  -- STREET_NAME
    [10] = false, -- HELP_TEXT
    [11] = false, -- FLOATING_HELP_TEXT_1
    [12] = false, -- FLOATING_HELP_TEXT_2
    [13] = false, -- CASH_CHANGE
    [14] = false, -- RETICLE
    [15] = false, -- SUBTITLE_TEXT
    [16] = false, -- RADIO_STATIONS
    [17] = false, -- SAVING_GAME
    [18] = false, -- GAME_STREAM
    [19] = false, -- WEAPON_WHEEL
    [20] = false, -- WEAPON_WHEEL_STATS
    [21] = false, -- HUD_COMPONENTS
    [22] = false, -- HUD_WEAPONS
}


-- Pattern for AI vehicle plates. 1=digit, A=letter, .=either, ^X=literal X.
Config.CustomAIPlates = '........'

-- Discord rich presence. Set appId to 0 to disable.
Config.DiscordActivity = {
    appId    = 0,
    assetName = 'LargeIcon',
    assetText = '{server_name}',
    buttons  = {
        { label = 'Join Server', url = 'fivem://connect/{server_endpoint}' },
        { label = 'Discord',     url = 'https://discord.gg/yourserver' },
    },
    presence = '{player_name} [{player_id}] | {server_players}/{server_maxplayers}',
    refresh  = 60 * 1000,
}
