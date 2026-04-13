---@class AdminConfig
AdminConfig = {}

---@type boolean Enable debug mode (prints debug messages)
AdminConfig.DEBUG = false

---@type number Cooldown time in milliseconds for spawn command
AdminConfig.SPAWN_COOLDOWN = 5000

---@type table<string, number> Default values for radius commands
AdminConfig.DEFAULT_RADIUS = {
    revive = 50,
    deleteVehicles = 50,
    fixVehicles = 50
}

---@type table<number, number> Min and max values for radius commands
AdminConfig.RADIUS_LIMITS = {
    min = 1,
    max = 1000
}

---@type table<number, number> Spawn command limits
AdminConfig.SPAWN_LIMITS = {
    min = 1,
    max = 100
}

---@type string Admin permission group
AdminConfig.ADMIN_GROUP = 'admin'

---@type table Event car configuration
AdminConfig.EVENT_CARS = {
    defaultModel = 'adder', -- Default car model if not specified
    spacing = 4.0,          -- Distance between each spawned car (side spacing)
    rowSpacing = 6.0,       -- Distance between rows (front/back spacing)
    count = 4,              -- Number of cars to spawn
    carsPerRow = 1          -- Number of cars per row (1-4)
}

---@type table[] Available weapons for event loadouts
AdminConfig.EVENT_WEAPONS = {
    { label = 'Pistol', value = 'WEAPON_PISTOL' },
    { label = 'Combat Pistol', value = 'WEAPON_COMBATPISTOL' },
    { label = 'AP Pistol', value = 'WEAPON_APPISTOL' },
    { label = 'Heavy Pistol', value = 'WEAPON_HEAVYPISTOL' },
    { label = 'Micro SMG', value = 'WEAPON_MICROSMG' },
    { label = 'SMG', value = 'WEAPON_SMG' },
    { label = 'Assault SMG', value = 'WEAPON_ASSAULTSMG' },
    { label = 'Assault Rifle', value = 'WEAPON_ASSAULTRIFLE' },
    { label = 'Carbine Rifle', value = 'WEAPON_CARBINERIFLE' },
    { label = 'Advanced Rifle', value = 'WEAPON_ADVANCEDRIFLE' },
    { label = 'Special Carbine', value = 'WEAPON_SPECIALCARBINE' },
    { label = 'Pump Shotgun', value = 'WEAPON_PUMPSHOTGUN' },
    { label = 'Sawed-Off Shotgun', value = 'WEAPON_SAWNOFFSHOTGUN' },
    { label = 'Sniper Rifle', value = 'WEAPON_SNIPERRIFLE' },
    { label = 'Heavy Sniper', value = 'WEAPON_HEAVYSNIPER' },
    { label = 'None', value = 'none' }
}

---@type number Default ammo amount for event weapons
AdminConfig.DEFAULT_AMMO = 250

---@type table<string, string> Notification messages
AdminConfig.MESSAGES = {
    noPermission = 'You do not have permission to use this command.',
    invalidRadius = 'Radius must be greater than 0.',
    invalidItem = 'Invalid item or amount.',
    cancelled = 'Cancelled',
    cooldown = 'Please wait %d seconds.',

    -- Success messages
    reviveSuccess = 'Revived %d players within %d meters.',
    revived = 'You have been revived by an admin.',
    teleportSuccess = 'Teleported %d players from job %s.',
    teleported = 'You have been teleported to the event location.',
    deleteVehiclesSuccess = 'Deleted unused vehicles within %d meters.',
    spawnSuccess = 'Spawned %d x %s',
    spawnFailed = 'Failed to spawn: %s',

    -- Error messages
    noJobsAvailable = 'No jobs available to teleport.',
    mustSpecifyJob = 'You must specify a job name.',
    invalidLoadout = 'Invalid loadout type.',

    -- Event command messages
    carsSpawned = 'Spawned %d event vehicles.',
    eventCarsDeleted = 'Deleted %d event vehicles.',
    loadoutGiven = 'Gave %s loadout to %d players in job %s.',
    loadoutReceived = 'You received event weapons!',
    gunsRemoved = 'Removed event weapons from %d players in job %s.',
    gunsRemovedNotify = 'Event weapons have been removed.',

    -- Vehicle command messages
    notInVehicle = 'You must be in a vehicle.',
    vehicleMaxed = 'Vehicle fully upgraded!',
    vehiclesFixed = 'Repaired %d vehicles within %d meters.'
}

---@type table<string, string> Dialog titles
AdminConfig.DIALOGS = {
    reviveRadius = 'Revive Radius',
    teleportGroup = 'Teleport Group',
    deleteVehicles = 'Delete Vehicles Radius',
    spawnItem = 'Spawn Item',
    eventCars = 'Spawn Event Cars',
    eventGuns = 'Give Event Loadout',
    removeGuns = 'Remove Event Weapons',
    fixVehicles = 'Repair Vehicles Radius'
}
