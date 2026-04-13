HudConfig = {}

-- Update Rates (milliseconds)
HudConfig.UpdateRate = 100 -- Main update loop

-- HUD Positions
HudConfig.Position = {
    -- Player HUD (health, armor, hunger, etc.)
    player = {
        bottom = '5px',     -- Distance from bottom
        left = '50%',        -- Horizontal position (50% = centered)
        -- If you want to position from left edge instead, change left to a pixel value like '20px'
    },

    -- Vehicle HUD - Overall container position
    vehicle = {
        bottom = '20px',     -- Distance from bottom
        right = '20px',      -- Distance from right edge

        -- Spacing between elements (in pixels)
        gap = 4,             -- Gap between all elements (speed/gear to RPM, RPM to status)

        -- Individual element adjustments (optional fine-tuning)
        -- Leave commented to use default layout, or uncomment to customize
        -- speedGearGap = 32,   -- Space between speed and gear
        -- rpmOffset = 0,       -- Extra vertical offset for RPM bar
        -- statusOffset = 0,    -- Extra vertical offset for status indicators
    }
}

-- Player Stats Colors
HudConfig.Player = {
    health = {
        icon = '#db1212',
        bar_background = '#ffffff40',
        bar_gradient_start = '#db1212',
        bar_gradient_end = '#b50d0d'
    },
    armor = {
        icon = '#7dbee3',
        bar_background = '#ffffff40',
        bar_gradient_start = '#7dbee3',
        bar_gradient_end = '#1096e3'
    },
    hunger = {
        icon = '#e69160',
        bar_background = '#ffffff40',
        bar_gradient_start = '#e69160',
        bar_gradient_end = '#e85b09'
    },
    thirst = {
        icon = '#09d8eb',
        bar_background = '#ffffff40',
        bar_gradient_start = '#09d8eb',
        bar_gradient_end = '#4ea8cf'
    },
    stamina = {
        icon = '#c7c7c7',
        bar_background = '#ffffff40',
        bar_gradient_start = '#c2c2c2',
        bar_gradient_end = '#c7c7c7'
    },
    oxygen = {
        icon = '#24a2e0',
        bar_background = '#ffffff40',
        bar_gradient_start = '#03a9fc',
        bar_gradient_end = '#24a2e0'
    },
    voice = {
        icon_talking = '#77e339',
        icon_not_talking = '#ffffff',
        bar_background = '#ffffff40',
        bar_gradient_start = '#77e339',
        bar_gradient_end = '#0ee341'
    },
    junglejuice = {
        icon = '#c79d6f',
        bar_background = '#ffffff40',
        bar_gradient_start = '#c79d6f',
        bar_gradient_end = '#c79d6f'
    }
}


-- Vehicle Settings
HudConfig.Vehicle = {
    useCircleHud = false, -- true = circle speedo, false = bars

    -- RPM Bar Settings (when useCircleHud = false)
    metricText = 'RPM',
    barAmount = 10,
    barThreshhold = 100,
    barColor = { r = 255, g = 100, b = 0 },
    emptyBarColor = 'rgba(128, 128, 128, 0.658)',

    -- Fuel
    fuelBlinkAmountMinimum = 15,

    -- Engine Health
    engineLightHealthMinimum = 400,

    -- Display Colors
    colors = {
        speedText = '#ffffff',           -- Speed number color
        speedUnit = '#ffffff',           -- "KM/h" text color
        gearText = '#ffffff',            -- Gear display color
        gearIcon = '#ffffff',            -- Gear icon color
        rpmBarInactive = '#ffffff40',    -- Inactive RPM segment background
        statusGood = '#22aa22',          -- Status indicator good (green)
        statusBad = '#ff3333',           -- Status indicator warning (red)
        statusInactive = '#333',         -- Status indicator inactive background
        statusBg = 'rgba(0, 0, 0, 0.7)', -- Status indicator container background
        statusBorder = 'rgba(255, 255, 255, 0.1)', -- Status indicator border
        statusText = 'rgba(255, 255, 255, 0.9)'    -- Status indicator label text
    }
}

-- Notification Settings
HudConfig.Notification = {
    position = 'RIGHT', -- LEFT, MIDDLE, RIGHT
    height = '15%' -- Distance from top
}

-- Stress System
HudConfig.Stress = {
    whitelistedJobs = {
        'police',
        'ambulance',
        'mechanic'
    },
    gainAmount = {
        shoot = 2,
        kill = 5,
        crash = 3
    },
    reliefAmount = {
        smoke = 10,
        drink = 5
    }
}

-- Jungle Juice Buff System
HudConfig.JungleJuice = {
    ArmorRegenRate = 1,           -- armor points per tick
    ArmorRegenInterval = 2000,    -- ms between regen ticks (2 seconds)
    MaxSpeedBoost = 0.15,         -- 15% max speed increase at 100 junglejuice
    ReloadSpeedMultiplier = 1.25, -- 25% faster reload (1.25x speed)
}
