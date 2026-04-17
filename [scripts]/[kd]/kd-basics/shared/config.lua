Config = {}

Config.Modules = {
    AmbientAudio    = true,
    Seatbelt        = true,
    TakeHostage     = true,
    VoiceCircle     = true,
    HandsUp         = true,
    Pointing        = true,
    Tackle          = true,
    Zipties         = true,
    AntiPeek        = true,
    Basics          = true,
    BikeGuns        = true,
    Bikes           = true,
    Binoculars      = true,
    Carry           = true,
    FriendlyPeds    = true,
    Clothing        = true,
    CrouchProne     = true,
    Density         = true,
    F8              = true,
    HeliCam         = true,
    Ids             = true,
    MaxSpeed        = true,
    OffRoadHandling = true,
    Repair          = true,
    RepairKit       = true,
    Trunk           = true,
}

Config.AntiPeek = {
    showNotification = false,
}

Config.Basics = {
    drivebyAllowed = {
        [joaat('primolx')]     = true,
        [joaat('gbimpaler')]   = true,
        [joaat('gbstanierle')] = true,
        [joaat('faggio')]      = true,
        [joaat('bmx')]         = true,
        [joaat('moonbeam')]    = true,
    },

    stealthKills = {
        'ACT_stealth_kill_a',
        'ACT_stealth_kill_weapon',
        'ACT_stealth_kill_b',
        'ACT_stealth_kill_c',
        'ACT_stealth_kill_d',
        'ACT_stealth_kill_a_gardener',
    },
}

Config.Bikes = {
    promptRange = 5.0,
    animDict    = 'amb@prop_human_seat_chair_mp@male@generic@base',
    animName    = 'base',

    models = {
        [joaat('scorcher')]    = { 0,  0.35,  0.45,  0, 0, 0 },
        [joaat('bmx')]         = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('bmx80rp')]     = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('bmx83600a')]   = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('bmx83rp')]     = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('bmx82rpii')]   = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('bmx82rmxiii')] = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('bmx82rmxii')]  = { 0,  0.2,   0.6,   0, 0, 0 },
        [joaat('cruiser')]     = { 0, -0.7,   0.2, -10, 0, 0 },
    },
}

Config.Binoculars = {
    jobs      = { 'police', 'sheriff' },
    item      = 'binoculars',
    maxFov    = 70.0,
    minFov    = 5.0,
    zoomSpeed = 10.0,
    panSpeed  = 8.0,
}

Config.Carry = {
    range = 3.0,

    carrying = {
        dict = 'missfinale_c2mcs_1',
        anim = 'fin_c2_mcs_1_camman',
        flag = 49,
    },
    carried = {
        dict   = 'nm',
        anim   = 'firemans_carry',
        flag   = 33,
        offset = vec3(0.27, 0.15, 0.63),
    },
}

Config.FriendlyPeds = {
    -- 0 = Companion, 1 = Respect, 2 = Like, 3 = Neutral
    relationship = 3,

    groups = {
        'CIVMALE',
        'CIVFEMALE',
        'SECURITY_GUARD',
        'PRIVATE_SECURITY',
        'DEALER',
        'HATES_PLAYER',
        'PRISONER',
        'AMBIENT_GANG_LOST',
        'AMBIENT_GANG_MEXICAN',
        'AMBIENT_GANG_FAMILY',
        'AMBIENT_GANG_BALLAS',
        'AMBIENT_GANG_MARABUNTE',
        'AMBIENT_GANG_CULT',
        'AMBIENT_GANG_SALVA',
        'AMBIENT_GANG_WEICHENG',
        'AMBIENT_GANG_HILLBILLY',
    },
}

Config.Clothing = {
    noHelmet = true,
}

Config.Density = {
    parked     = 0.2,
    vehicle    = 0.4,
    multiplier = 0.4,
    peds              = 0.6,
    scenarioInterior  = 0.0,
    scenarioExterior  = 0.0,

    suppressCops = true,
    suppressEMS  = true,

    highwayMultiplier = 4.0,

    highway = {
        vector3(645.63,  -197.93, 79.55),
        vector3(683.16,  -220.03, 79.55),
        vector3(742.92,  -105.17, 79.55),
        vector3(805.52,    9.34,  79.55),
        vector3(862.93,   93.07,  79.55),
        vector3(900.28,  140.79,  79.55),
        vector3(954.41,  209.74,  79.55),
        vector3(997.12,  263.34,  79.55),
        vector3(1041.46, 311.07,  79.55),
        vector3(1132.74, 404.59,  79.55),
        vector3(1184.76, 458.34,  79.55),
        vector3(1367.62, 635.54,  79.55),
        vector3(1418.51, 693.04,  79.55),
        vector3(1463.89, 751.80,  79.55),
        vector3(1505.00, 808.98,  79.55),
        vector3(1539.32, 870.05,  79.55),
        vector3(1594.36, 993.33,  79.55),
        vector3(1622.85, 1072.45, 79.55),
        vector3(1671.65, 1237.66, 79.55),
        vector3(1648.84, 1267.91, 79.55),
        vector3(1631.79, 1207.79, 79.55),
        vector3(1584.27, 1058.88, 79.55),
        vector3(1562.60, 993.50,  79.55),
        vector3(1545.62, 953.71,  79.55),
        vector3(1513.58, 885.83,  79.55),
        vector3(1464.51, 806.50,  79.55),
        vector3(1418.59, 739.43,  79.55),
        vector3(1369.72, 678.88,  79.55),
        vector3(1327.19, 636.52,  79.55),
        vector3(974.18,  283.91,  79.55),
        vector3(909.91,  218.82,  79.55),
        vector3(781.72,   50.79,  79.55),
        vector3(734.23,  -23.20,  79.55),
    },
    highwayThickness = 30.0,
}

Config.F8 = {
    sceneLock       = true,
    sceneLockRadius = 12.0,
}

Config.HeliCam = {
    jobs          = { 'police', 'sheriff' },
    vehicles      = { [joaat('polmav')] = true },
    minHeight     = 1.5,
    maxTargetDist = 700.0,

    fovMax    = 80.0,
    fovMin    = 5.0,
    zoomSpeed = 3.0,
    panSpeed  = 4.0,

    brightness    = 1.0,
    brightnessMin = 1.0,
    brightnessMax = 10.0,

    spotRadius    = 4.0,
    spotRadiusMin = 4.0,
    spotRadiusMax = 10.0,

    controls = {
        toggle         = 51,
        spotlight      = 183,
        vision         = 25,
        display        = 44,
        lockOn         = 22,
        zoomIn         = 241,
        zoomOut        = 242,
        brightnessUp   = 246,
        brightnessDown = 173,
        radiusUp       = 21,
        radiusDown     = 36,
    },
}

Config.Ids = {
    range    = 25,
    distTick = 2500,
}

Config.MaxSpeed = {
    maxKMH = 400,
}

Config.OffRoadHandling = {
    checkInterval          = 500,
    tractionMultiplier     = 0.8,
    tractionLossMultiplier = 1.5,
    showNotification       = false,
}

Config.Repair = {
    deformationMultiplier       = -1,
    deformationExponent         = 0.7,
    collisionDamageExponent     = 0.7,
    engineDamageExponent        = 0.9,

    damageFactorEngine          = 2.0,
    damageFactorBody            = 2.75,
    damageFactorPetrolTank      = 22.0,
    weaponsDamageMultiplier     = 0.00,

    degradingHealthSpeedFactor  = 7.4,
    cascadingFailureSpeedFactor = 2.0,

    degradingFailureThreshold   = 690.0,
    cascadingFailureThreshold   = 320.0,
    engineSafeGuard             = 100.0,

    torqueMultiplierEnabled  = false,
    limpMode                 = false,
    limpModeMultiplier       = 0.15,
    compatibilityMode        = false,
    randomTireBurstInterval  = 0,

    jumpDamageThreshold  = 16.0,
    jumpSevereThreshold  = 25.0,

    classDamageMultiplier = {
        [0]  = 0.20,  -- Compacts
        [1]  = 0.20,  -- Sedans
        [2]  = 0.15,  -- SUVs
        [3]  = 0.20,  -- Coupes
        [4]  = 0.20,  -- Muscle
        [5]  = 0.20,  -- Sports Classics
        [6]  = 0.20,  -- Sports
        [7]  = 0.25,  -- Super
        [8]  = 0.10,  -- Motorcycles
        [9]  = 0.15,  -- Off-road
        [10] = 0.15,  -- Industrial
        [11] = 0.15,  -- Utility
        [12] = 0.20,  -- Vans
        [13] = 0.65,  -- Cycles
        [14] = 0.00,  -- Boats
        [15] = 0.85,  -- Helicopters
        [16] = 0.85,  -- Planes
        [17] = 0.55,  -- Service
        [18] = 0.20,  -- Emergency
        [19] = 0.55,  -- Military
        [20] = 0.55,  -- Commercial
        [21] = 0.85,  -- Trains
    },

    basicRepairEngine     = 650.0,
    basicRepairPetrolTank = 750.0,
}

Config.Zipties = {
    applySpeed  = 5000,
    removeSpeed = 5000,

    enableLooseTimer = true,
    looseTimer       = 600000,

    enableIdleAnim = true,
    idleAnim = {
        dict = 're@stag_do@idle_a',
        name = 'idle_a_ped',
    },

    disabledControls = {
        24, 257, 25, 263, 45, 22, 44, 37, 288, 289, 170, 167, 0, 26, 73, 199, 59, 71, 72, 47, 264, 140, 141, 142, 143
    },
}

Config.VoiceCircle = {
    color        = { r = 220, g = 20, b = 20 },
    drawDuration = 2000,
    lerpSpeed    = 0.1,
}

Config.TakeHostage = {
    requireHandsUp = true,

    allowedWeapons = {
        `WEAPON_PISTOL`,
        `WEAPON_COMBATPISTOL`,
        `WEAPON_APPISTOL`,
        `WEAPON_PISTOL50`,
    },
}

Config.Seatbelt = {
    ToggleKey            = 'Y',
    BuckleSound          = 'carbuckle',
    UnbuckleSound        = 'carunbuckle',
    SoundVolume          = 0.25,
    MinSpeedForEjection  = 100.0,
    MinDamageForEjection = 18.0,
    EjectDamageMultiplier = 8,

    ExcludedClasses = {
        [8]  = true,  -- Motorcycles
        [13] = true,  -- Cycles
        [14] = true,  -- Boats
        [15] = true,  -- Helicopters
        [16] = true,  -- Planes
    },
}

Config.Trunk = {
    anim = {
        dict   = 'timetable@floyd@cryingonbed@base',
        name   = 'base',
        flag   = 1,
        offset = vec3(0.0, -2.2, 0.5),
    },
}
