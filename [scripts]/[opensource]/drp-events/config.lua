---@class EventsConfig
EventsConfig = {}

-- Debug Settings
---@type boolean Enable debug mode for troubleshooting
EventsConfig.Debug = true

-- Permission Settings
---@type table<number, string> Groups allowed to create/manage events
EventsConfig.AllowedGroups = {
    'admin',
    'moderator',
    'eventmanager'
}

-- Job Detection
---@type boolean Auto-detect jobs from ESX database (recommended)
EventsConfig.AutoDetectJobs = true

-- Event Bubble Messages
---@type string Notification title for event messages
EventsConfig.NotificationTitle = 'Event System'

---@type string Message shown when entering event area
EventsConfig.EnterMessage = 'You have entered an event area'

---@type string Message shown when exiting event area
EventsConfig.ExitMessage = 'You have left the event area'

-- Event Bubble Visual Settings
---@class BubbleColor
---@field r number Red value (0-255)
---@field g number Green value (0-255)
---@field b number Blue value (0-255)
---@field a number Alpha/transparency value (0-255)

---@type BubbleColor RGBA color values for event bubble marker
EventsConfig.BubbleColor = {
    r = 0,      -- Red (0-255)
    g = 150,    -- Green (0-255)
    b = 255,    -- Blue (0-255)
    a = 120     -- Alpha/Transparency (0-255, higher = more visible)
}

-- Routing Bucket Settings
---@type number Dimension ID for event areas (routing bucket)
EventsConfig.EventDimension = 69

---@type number Default dimension ID for normal gameplay
EventsConfig.DefaultDimension = 0

-- Marker Settings
---@type number Marker type for event bubble visualization
EventsConfig.MarkerType = 28 -- Cylinder marker

---@type number Maximum distance to draw markers (from bubble edge)
EventsConfig.DrawDistance = 150.0

-- Blip Settings
---@type number Outer blip sprite ID
EventsConfig.OuterBlipSprite = 161

---@type number Outer blip color
EventsConfig.OuterBlipColor = 64

---@type number Outer blip scale
EventsConfig.OuterBlipScale = 2.0

---@type string Outer blip label
EventsConfig.OuterBlipLabel = 'Event Bubble'

---@type number Inner blip sprite ID
EventsConfig.InnerBlipSprite = 816

---@type number Inner blip color
EventsConfig.InnerBlipColor = 0

---@type number Inner blip scale
EventsConfig.InnerBlipScale = 1.0

---@type string Inner blip label
EventsConfig.InnerBlipLabel = 'Active Event'

-- Thread Optimization
---@type number Sleep time when not near any event bubble (ms)
EventsConfig.IdleSleep = 1500

---@type number Sleep time when near event bubble (ms)
EventsConfig.ActiveSleep = 0

-- Default Event Settings
---@type number Default radius for new events if not specified
EventsConfig.DefaultEventRadius = 50.0
