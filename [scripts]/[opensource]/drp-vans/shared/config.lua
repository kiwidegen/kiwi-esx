VansConfig = {}

-- ===== Event Mechanics =====
VansConfig.VanSpawnDelay          = 10 * 60 -- 10 minutes delay before van spawns
VansConfig.ControlSecondsRequired = 10 * 60 -- 10 minutes to unlock
VansConfig.TickSeconds            = 1       -- server loop tick rate
VansConfig.ControlCheckRange      = 60.0    -- range to count as "nearby" for control
VansConfig.LockRange              = 4.0     -- must be within this range (alive, on foot) for timer to tick
VansConfig.DiscoveryRange         = 5.0     -- event "discovered" when someone within this range (on foot)

-- ===== Blip Configuration =====
VansConfig.RadiusBlipSize         = 200.0   -- search area radius blip (shown after discovery)
VansConfig.BlipHideRange          = 30.0    -- (reserved for future use)

-- ===== Vehicle =====
VansConfig.VehicleModel           = 'gburrito2' -- spawn vehicle model

-- ===== Spawn Locations =====
-- Random location is selected when event starts
---@type vector4[]
VansConfig.SpawnPoints = {

  vector4(-1136.5638, -1982.9838, 12.1650, 231.8331)   -- Original location
}

-- ===== Admin Access (ESX) =====
-- Admins can start/stop events via ACE permissions or ESX groups/jobs
VansConfig.AdminAllowedGroups = { 'admin', 'superadmin' } -- ESX group names
VansConfig.AdminJobs          = {}                        -- ESX job names (e.g. { 'police' })
VansConfig.AdminGangs         = {}                        -- ESX gang names (if using gang-based admin access)

-- ===== Discord Logging =====
-- Discord logging now handled by drp-logs resource
-- Logs are sent to the 'events' category

-- ===== Visual Effects =====
VansConfig.Visuals = {
    Smoke = true,  -- Red smoke effect on van after discovery
    Flare = true   -- Flare object attached to van
}

-- ===== Client Performance =====
VansConfig.TimerVisibleRange = 5.0 -- 3D timer only draws when within this range
