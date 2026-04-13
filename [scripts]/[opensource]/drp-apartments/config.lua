---@class ApartmentConfig
---@field Starting boolean Enable automatic apartment assignment on first join
---@field SpawnOffset number Distance offset for player spawn positioning
---@field UseTarget boolean Use ox_target for interactions (true) or zones (false)
---@field ClothingScript string Clothing script identifier
---@field WeatherScript string Weather/time script identifier
---@field InteriorScript string Interior management script identifier
---@field EnableSounds boolean Enable interaction sound effects
---@field InteractionDistance number Maximum distance for zone interactions (when UseTarget is false)
---@field Locations table<string, ApartmentLocation> Apartment location definitions

---@class ApartmentLocation
---@field name string Unique apartment identifier
---@field label string Display name for the apartment
---@field coords ApartmentCoords Coordinate data for apartment entrance
---@field polyzoneBoxData TargetBoxData Target/zone interaction data

---@class ApartmentCoords
---@field enter vector4 Entrance coordinates (x, y, z, heading)

---@class TargetBoxData
---@field heading number Box rotation heading
---@field minZ number Minimum Z coordinate for interaction zone
---@field maxZ number Maximum Z coordinate for interaction zone
---@field debug boolean Enable debug visualization
---@field length number Zone length dimension
---@field width number Zone width dimension
---@field distance number Interaction distance
---@field created boolean Internal state tracker for zone creation

ApartmentsConfig = {}

---@type boolean Enable automatic apartment assignment on first join
ApartmentsConfig.Starting = true

---@type number Distance offset for player spawn positioning
ApartmentsConfig.SpawnOffset = 30

---@type boolean Use ox_target for interactions instead of zones
ApartmentsConfig.UseTarget = true

---@type string Clothing script to use: 'fivem-appearance', 'illenium-appearance', 'esx_skin'
ApartmentsConfig.ClothingScript = 'illenium-appearance'

---@type string Weather/time script to use: 'vSync', 'cd_easytime', 'Renewed-Weathersync'
ApartmentsConfig.WeatherScript = 'Renewed-Weathersync'

---@type string Interior script identifier for apartment interiors
ApartmentsConfig.InteriorScript = 'drp-interior' -- Keep for now, change to 'esx_property' or equivalent

---@type boolean Enable sound effects for interactions
ApartmentsConfig.EnableSounds = true

---@type number Maximum interaction distance when not using ox_target
ApartmentsConfig.InteractionDistance = 2.0

-- Maintain backward compatibility
Apartments = ApartmentsConfig
---@type table<string, ApartmentLocation> Apartment location definitions
ApartmentsConfig.Locations = {
    ["apartment1"] = {
        name = "apartment1",
        label = "South Rockford Drive",
        coords = {
            enter = vector4(-667.02, -1105.24, 14.63, 242.32),
        },
        polyzoneBoxData = {
            heading = 245,
            minZ = 13.5,
            maxZ = 16.0,
            debug = false,
            length = 1,
            width = 3,
            distance = 2.0,
            created = false
        }
    },
    ["apartment2"] = {
        name = "apartment2",
        label = "Morningwood Blvd",
        coords = {
            enter = vector4(-1288.52, -430.51, 35.15, 124.81),
        },
        polyzoneBoxData = {
            heading = 124,
            minZ = 34.0,
            maxZ = 37.0,
            debug = false,
            length = 1,
            width = 3,
            distance = 2.0,
            created = false
        }
    },
    ["apartment3"] = {
        name = "apartment3",
        label = "Integrity Way",
        coords = {
            enter = vector4(269.73, -640.75, 42.02, 249.07),
        },
        polyzoneBoxData = {
            heading = 250,
            minZ = 40,
            maxZ = 43.5,
            debug = false,
            length = 1,
            width = 1,
            distance = 2.0,
            created = false
        }
    },
    ["apartment4"] = {
        name = "apartment4",
        label = "Tinsel Towers",
        coords = {
            enter = vector4(-619.29, 37.69, 43.59, 181.03),
        },
        polyzoneBoxData = {
            heading = 180,
            minZ = 41.0,
            maxZ = 45.5,
            debug = false,
            length = 1,
            width = 2,
            distance = 2.0,
            created = false
        }
    },
    ["apartment5"] = {
        name = "apartment5",
        label = "Fantastic Plaza",
        coords = {
            enter = vector4(291.517, -1078.674, 29.405, 270.75),
        },
        polyzoneBoxData = {
            heading = 270,
            minZ = 28.5,
            maxZ = 31.0,
            debug = false,
            length = 1,
            width = 2,
            distance = 2.0,
            created = false
        }
    },
    ["apartment6"] = {
        name = "apartment6",
        label = "South Side Apartments",
        coords = {
            enter = vector4(-154.64, 6433.16, 31.91, 130.39),
        },
        polyzoneBoxData = {
            heading = 130,
            minZ = 30.91,
            maxZ = 33.41,
            debug = false,
            length = 1,
            width = 3,
            distance = 2.0,
            created = false
        }
    },
    ["apartment7"] = {
        name = "apartment7",
        label = "Von Crastenburg",
        coords = {
            enter = vector4(435.82, 215.08, 103.15, 158.74),
        },
        polyzoneBoxData = {
            heading = 159,
            minZ = 102.15,
            maxZ = 104.65,
            debug = false,
            length = 1,
            width = 3,
            distance = 2.0,
            created = false
        }
    },
}

-- Backward compatibility aliases
Apartments.Locations = ApartmentsConfig.Locations
