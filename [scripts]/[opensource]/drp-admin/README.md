# DRP Admin Tools

Modern ESX admin utilities with ox_lib, ox_inventory, and oxmysql integration.

## Version 2.0.0

Complete rewrite with modular structure, modern ESX practices, and native revive functionality.

---

## Commands

All commands require admin permission (`Config.ADMIN_GROUP` - default: 'admin')

### Player Management

#### `/reviveradius`
Revive all players within a specified radius.
- Opens dialog to input radius (default: 50 meters)
- Revives all players within range
- Uses native GTA functions (no external dependencies)

### Teleportation

#### `/tpgroup`
Teleport all players from a specific job to your location.
- Select job from searchable dropdown
- All players with that job will be teleported to you
- Sends notification to teleported players

### Vehicle Management

#### `/delcarsradius`
Delete all unoccupied vehicles within a specified radius.
- Opens dialog to input radius (default: 50 meters)
- Only deletes vehicles with no driver
- Helps clean up event areas

#### `/eventcar`
Spawn event vehicles in a line for races or events.
- Specify vehicle model (default: 'adder')
- Choose number of vehicles (1-10, default: 4)
- Vehicles spawn in a line to your right with proper spacing
- Perfect for setting up racing events

### Loadout Management

#### `/eventguns`
Give event loadout to all players in a specific job.
- Select target job from dropdown
- Choose loadout type (Pistol, SMG, Rifle, Heavy)
- All players in that job receive the loadout instantly
- Perfect for gang wars and PvP events

**Available Loadouts:**
- **Pistol** - WEAPON_PISTOL + 250 ammo
- **SMG** - WEAPON_SMG + 500 ammo
- **Rifle** - WEAPON_ASSAULTRIFLE + 500 ammo
- **Heavy** - WEAPON_ASSAULTRIFLE + WEAPON_PISTOL + 5x armor

#### `/removeguns`
Remove event weapons from all players in a specific job.
- Select target job from dropdown
- Removes all event weapons and ammo
- Run this after events to clean up loadouts

### Item Spawning

#### `/drpspawn`
Spawn items with an intuitive searchable menu.
- Has 5-second cooldown to prevent spam
- Search through all items
- Specify amount (1-100)
- Menu stays open for spawning multiple items
- Admin only

---

## Installation

### Requirements
- `es_extended` (ESX Legacy Framework)
- `ox_lib`
- `ox_inventory`
- `oxmysql`

### Setup
1. Ensure all dependencies are installed
2. Place `drp-admin` in your resources folder
3. Add to `server.cfg`:
   ```
   ensure drp-admin
   ```
4. Restart your server or run:
   ```
   refresh
   start drp-admin
   ```

---

## Configuration

All settings are in `config.lua`. Edit to customize:

### Basic Settings
```lua
Config.DEBUG = false              -- Enable debug messages
Config.ADMIN_GROUP = 'admin'      -- Required permission group
```

### Cooldowns
```lua
Config.SPAWN_COOLDOWN = 5000      -- Spawn command cooldown (ms)
```

### Default Values
```lua
Config.DEFAULT_RADIUS = {
    revive = 50,                   -- Default revive radius
    deleteVehicles = 50            -- Default vehicle delete radius
}

Config.EVENT_CARS = {
    defaultModel = 'adder',        -- Default car model
    spacing = 4.0,                 -- Space between cars (meters)
    count = 4                      -- Default number of cars
}
```

### Loadout Configuration
Edit `Config.EVENT_LOADOUTS` to customize event loadouts:
```lua
Config.EVENT_LOADOUTS = {
    pistol = {
        { item = 'WEAPON_PISTOL', ammo = 250 },
    },
    -- Add more loadouts as needed
}
```

### Messages
All notification messages are in `Config.MESSAGES` for easy localization.

---

## File Structure

```
drp-admin/
├── config.lua              # All configuration settings
├── fxmanifest.lua          # Resource manifest
├── client/
│   ├── main.lua            # Client initialization & caching
│   ├── functions.lua       # Dialog functions & client logic
│   └── events.lua          # Client event handlers
├── server/
│   ├── main.lua            # Server initialization
│   ├── functions.lua       # Core server functions
│   ├── commands.lua        # Command registration
│   └── events.lua          # Server event handlers
└── shared/
    └── utils.lua           # Shared utility functions
```

---

## What Changed from demon_admin?

### Renamed
- ✅ Resource renamed from `demon_admin` to `drp-admin`
- ✅ Spawn command renamed from `/demonspawn` to `/drpspawn`
- ✅ All events use `drp_admin:` prefix

### Dependencies
- ✅ Replaced `mysql-async` with `oxmysql`
- ✅ Removed `wasabi_ambulance` dependency
- ✅ Added native revive functionality

### New Commands
- ✅ `/eventcar` - Spawn event vehicles
- ✅ `/eventguns` - Give loadouts to jobs
- ✅ `/removeguns` - Remove event weapons

### Code Quality
- ✅ Full modular structure (separated files)
- ✅ Comprehensive LuaLS annotations
- ✅ Modern Lua 5.4 syntax (`+=`, `-=`)
- ✅ Proper configuration system
- ✅ Configurable debug system
- ✅ Optimized caching (items, jobs, players)
- ✅ Consistent event naming
- ✅ Modern vector math
- ✅ Resource cleanup handlers

### Performance
- Item options cached to avoid repeated queries
- Job options cached with database fallback
- Player data cached on client
- Efficient table operations
- Optimized entity loops

---

## Usage Examples

### Running an Event
1. Set up event area:
   ```
   /eventcar     # Spawn race cars
   /tpgroup      # Teleport gang members
   ```

2. Give loadouts:
   ```
   /eventguns    # Select job and loadout type
   ```

3. After event cleanup:
   ```
   /removeguns        # Remove weapons
   /delcarsradius     # Clean up vehicles
   ```

### General Admin Tasks
```
/reviveradius     # Revive players in area
/tpgroup          # Gather players for meeting
/drpspawn         # Spawn items as needed
```

---

## Debug Mode

Enable debug messages in `config.lua`:
```lua
Config.DEBUG = true
```

Debug messages appear as `[DRP-ADMIN]` in server/client console.

---

## Support

Check your console for debug messages if commands aren't working:
- Enable `Config.DEBUG = true`
- Look for `[DRP-ADMIN]` messages
- Verify you have admin permission

---

## Credits

**Author:** KiwiDegen
**Version:** 2.0.0
**Framework:** ESX Legacy

Fully modularized and optimized following modern ESX conversion guidelines.
