---@class ExtrasConfig
ExtrasConfig = {}

---@type boolean Enable debug mode for troubleshooting
ExtrasConfig.Debug = false

--============================================================
--  MODULE TOGGLES
--============================================================

---@class ModuleToggles
---@field IdleCam boolean Enable idle camera module
---@field PistolWhip boolean Enable pistol whip module
---@field HandsUp boolean Enable hands up module
---@field Point boolean Enable pointing module
---@field Binoculars boolean Enable binoculars module
---@field CarWash boolean Enable car wash module
---@field CrouchProne boolean Enable crouch/prone module
---@field Fireworks boolean Enable fireworks module
---@field F8 boolean Enable F8 quit confirmation
---@field PlayerIDs boolean Enable player ID display
---@field HeliGuns boolean Allow guns in helicopters
---@field BikeGuns boolean Allow guns on bikes
---@field RemoveEntities boolean Enable entity removal system
---@field Seatbelt boolean Enable seatbelt system
---@field Carry boolean Enable carry players system
---@field TakeHostage boolean Enable take hostage system
---@field HolsterAnim boolean Enable weapon holster animations
---@field MaxSpeed boolean Enable vehicle max speed limiter
---@field RestrictedItems boolean Enable restricted items/weapons by job
---@field CombatLog boolean Enable combat log notifications
---@field AntiPistolWhip boolean Disable melee with guns equipped
---@field VestEquip boolean Enable vest equip with delay
---@field BikeKick boolean Enable bike kick feature
---@field CarClear boolean Enable automatic car clear system
---@field NoNPC boolean Disable ambient NPCs
---@field InfiniteStamina boolean Enable infinite stamina
---@field DeathNotifications boolean Show kill/death notifications
---@field AntiPeek boolean Prevent combat while using radio
---@field AmbientAudio boolean Disable ambient audio from houses/music
---@field OffRoadHandling boolean Reduce car performance off-road (excludes bikes/4x4s)
---@field CayoPerico boolean Enable Cayo Perico island
---@field VoiceCircle boolean Show voice range circle when changing voice modes

ExtrasConfig.Modules = {
    -- Core Modules
    IdleCam        = true,
    PistolWhip     = false,
    HandsUp        = true,
    Point          = true,
    Binoculars     = true,
    CarWash        = false,  -- Removed - using drp-addons version
    CrouchProne    = true,
    Fireworks      = true,
    F8             = true,
    PlayerIDs      = true,
    HeliGuns       = true,
    BikeGuns       = true,
    RemoveEntities = true, -- TEMPORARILY DISABLED FOR CRASH TESTING
    Seatbelt       = true,
    Carry              = true,
    TakeHostage        = true,
    HolsterAnim        = false,  -- Keep disabled - causes issues
    MaxSpeed           = true,
    RestrictedItems    = true,
    CombatLog          = true,
    AntiPistolWhip     = true,
    AntiPeek           = true,
    VestEquip          = true,
    BikeKick           = true,
    CarClear           = true,
    NoNPC              = false,
    InfiniteStamina    = false,
    DeathNotifications = true,
    AmbientAudio       = true,  -- Disable ambient sounds from houses/music
    OffRoadHandling    = true,  -- Reduce car performance off-road
    CayoPerico         = true,  -- Enable Cayo Perico island
    VoiceCircle        = true   -- Show voice range circle (requires pma-voice)
}

--============================================================
--  CORE SYSTEMS
--============================================================

---@type boolean Lock scenes to prevent interruption
ExtrasConfig.SceneLock = true

---@type number Scene lock radius in units
ExtrasConfig.SceneLockRadius = 12.0

---@type boolean Remove helmets automatically
ExtrasConfig.NoHelmet = true

---@type boolean Lock clothing to prevent changes
ExtrasConfig.LockClothes = true

---@type boolean Disable ambient scenarios
ExtrasConfig.DisableAmbientScenarios = true

--============================================================
--  PLAYER ID DISPLAY
--============================================================

---@class IDConfig
---@field Command string Command to display ID
---@field DistanceToDisplay number Distance to show ID to other players
---@field DisplayTime number How long to display ID (milliseconds)
---@field UseOxLibNotify boolean Use ox_lib notifications
---@field Translation table Translation strings

ExtrasConfig.ID = {
    Command = 'id',
    DistanceToDisplay = 5.0,
    DisplayTime = 5000,
    UseOxLibNotify = true,
    Translation = {
        on = 'Your ID is %d'
    }
}

--============================================================
--  ENTITY REMOVAL SYSTEM
--============================================================

---@class EntityRemovalConfig
---@field CheckInterval number How often to check for entities (milliseconds)
---@field ProximityRadius number Only check within this radius (0 = always check)
---@field CheckOnce boolean Check once on start then stop
---@field TrackDeleted boolean Track deleted entities to avoid repeated checks
---@field Objects table[] List of objects to remove

ExtrasConfig.RemoveEntities = {
    CheckInterval = 15000,  -- Check every 15 seconds (reduced frequency)
    ScanRadius = 50.0,      -- Scan 50m around player (reduced to prevent pool overflow)
    TrackDeleted = true,

    -- Props to remove map-wide (scans around player)
    PropsToRemove = {
        "prop_sec_barier_02b",
        "prop_sec_barier_02a"
    }
}

--============================================================
--  SEATBELT SYSTEM
--============================================================

---@class SeatbeltConfig
---@field ToggleKey string Key to toggle seatbelt
---@field SoundResource string Sound effects resource name
---@field BuckleSound string Buckle sound file name
---@field UnbuckleSound string Unbuckle sound file name
---@field SoundVolume number Sound volume (0.0-1.0)
---@field MinSpeedForEjection number Minimum speed to trigger ejection (km/h)
---@field HighSpeedThreshold number Speed threshold for increased ejection chance (km/h)
---@field MinDamageForEjection number Minimum body damage to trigger ejection
---@field EjectDamageMultiplier number Damage multiplier when ejected
---@field ExcludedClasses table Vehicle classes excluded from seatbelt
---@field HUDResource string HUD resource name for integration
---@field UseHUDExport boolean Use HUD export for seatbelt status

ExtrasConfig.Seatbelt = {
    ToggleKey = 'B',
    SoundResource = 'InteractSound_SV',
    BuckleSound = 'carbuckle',
    UnbuckleSound = 'carunbuckle',
    SoundVolume = 0.25,
    MinSpeedForEjection = 100.0,
    HighSpeedThreshold = 120.0,
    MinDamageForEjection = 18.0,
    EjectDamageMultiplier = 8,
    ExcludedClasses = {
        [8] = true,   -- Motorcycles
        [13] = true,  -- Cycles
        [14] = true,  -- Boats
        [15] = true,  -- Helicopters
        [16] = true   -- Planes
    },
    HUDResource = 'drp-hud',
    UseHUDExport = true
}

--============================================================
--  RESTRICTED WEAPONS & ITEMS (Job-Based)
--============================================================

---@type table<string, string[]> Weapons restricted to specific jobs
ExtrasConfig.RestrictedWeapons = {
    ["WEAPON_COMBATPISTOL"] = { "doj", "fib", "police" },
    ["WEAPON_FLASHLIGHT"] = { "doj", "fib", "police" },
    ["WEAPON_NIGHTSTICK"] = { "doj", "fib", "police" },
    ["WEAPON_STUNGUN"] = { "doj", "fib", "police" },
    ["WEAPON_SPECIALCARBINE"] = { "doj", "fib", "police" },
    ["WEAPON_COMBATPDW"] = { "doj", "fib", "police" },
    ["WEAPON_SPECIALCARBINE_MK2"] = { "doj", "fib", "police" }
}

---@type table<string, string[]> Items restricted to specific jobs
ExtrasConfig.RestrictedItems = {
    ["vestpolice"] = { "doj", "fib", "police", "lssd" },
    ["clip2"] = { "doj", "fib", "police", "lssd" }
}

--============================================================
--  VEST EQUIP SYSTEM
--============================================================

---@type number Time in ms to equip vest (with progress bar)
ExtrasConfig.VestTime = 5000

--============================================================
--  TAKE HOSTAGE SYSTEM
--============================================================

---@type number[] Weapon hashes allowed for taking hostage
ExtrasConfig.TakeHostageWeapons = {
    `WEAPON_PISTOL`,
    `WEAPON_COMBATPISTOL`,
    `WEAPON_APPISTOL`,
    `WEAPON_PISTOL50`,
    `WEAPON_SNSPISTOL`,
    `WEAPON_HEAVYPISTOL`,
    `WEAPON_VINTAGEPISTOL`,
    `WEAPON_MARKSMANPISTOL`,
    `WEAPON_REVOLVER`,
    `WEAPON_DOUBLEACTION`
}

--============================================================
--  VEHICLE SYSTEMS
--============================================================

---@type number Maximum vehicle speed in km/h
ExtrasConfig.MaxKMH = 360

---@class CarClearConfig
---@field Time number Minutes between car clears
---@field Distance number Minimum distance from players to clear vehicle
---@field NotificationOn number[] Minutes before clear to send notification

ExtrasConfig.CarClear = {
    Time = 15,
    Distance = 100,
    NotificationOn = { 1 }
}

---@type string Car clear notification message
ExtrasConfig.CarClearNotification = "All vehicles that are %s meters away from players will be deleted in %s minutes!"

---@type string Car clear completed message
ExtrasConfig.CarClearClearedNotification = "The vehicle clear has been successfully completed!"

---@param message string Announcement message
---@return nil
function ExtrasConfig.CarClearAnnounce(message)
    -- Send notification to all players
    TriggerClientEvent('ox_lib:notify', -1, {
        title = 'Vehicle Clear',
        description = message,
        type = 'inform',
        duration = 8000,
        position = 'top-right'
    })
end

--============================================================
--  COMBAT LOG SYSTEM
--============================================================

---@type number Range in meters to notify nearby players of combat log
ExtrasConfig.CombatLogRange = 10

---@type string Combat log notification message
ExtrasConfig.CombatLogMessage = "Anti Combatlog - %s has left the server (Reason: %s)"

--============================================================
--  ANTI-PEEK SYSTEM
--============================================================

---@class AntiPeekConfig
---@field ShowNotification boolean Show notification when radio disables combat

ExtrasConfig.AntiPeek = {
    ShowNotification = false  -- Set to true to show notification when combat is disabled
}

--============================================================
--  OFF-ROAD HANDLING SYSTEM
--============================================================

---@class OffRoadHandlingConfig
---@field CheckInterval number How often to check surface type (milliseconds)
---@field TractionMultiplier number Traction reduction for off-road (0.0-1.0, lower = less traction)
---@field TractionLossMultiplier number How much easier to lose traction (higher = more slippery)
---@field ShowNotification boolean Show notification when entering/leaving off-road

ExtrasConfig.OffRoadHandling = {
    CheckInterval = 500,              -- Check every 500ms (balance between performance and responsiveness)
    TractionMultiplier = 0.8,         -- Reduce traction to 80% of normal (light reduction)
    TractionLossMultiplier = 1.5,     -- 1.5x easier to lose traction (light slipperiness)
    ShowNotification = false          -- Set to true to show notifications (can be annoying)
}
