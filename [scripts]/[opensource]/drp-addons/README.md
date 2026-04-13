# DRP-Addons

Modern ESX Legacy resource pack containing essential server utilities and features.

## Features

This resource includes 15 highly optimized modules:

**Performance:** 0.0ms resmon / 0.3% time usage - Optimized for 700+ player servers

### 1. drp-megaphone
- Vehicle megaphone system for emergency services
- Job-based access control
- Audio effects via pma-voice
- **Keybind:** B

### 2. drp-carlock
- Vehicle locking system with key fob animation
- Entity state-based ownership
- Faction vehicle support
- **Keybind:** L

### 3. drp-helicam
- Helicopter camera system
- Night vision and thermal vision modes
- Searchlight control
- Rappel from helicopter
- **Keybinds:** E (camera), X (rappel), L (spotlight), Right Mouse (vision modes)

### 4. drp-carwash
- Car wash locations with blips
- Marker-based interaction
- Payment system
- Vehicle dirt level check

### 6. drp-vehcontrol
- Advanced emergency vehicle siren control
- Multiple siren tones (Wail, Yelp, Priority)
- Air horn and manual siren control
- Turn signal auto-cancel
- Hazard lights toggle
- Powercall (auxiliary siren)
- Network synced across all players
- **Keybinds:** Q (lights), ALT/Comma (siren on/off), E/R (change tone), Arrow Up (powercall), = (left signal), - (right signal), Backspace (hazards)

### 7. drp-richpresence
- Discord Rich Presence integration
- Real-time player count display
- Server name and links
- Custom Discord application assets
- Automatic updates

### 8. drp-emoteall
- Admin command to force emotes on nearby players
- Radius-based targeting
- Server-side validation
- **Command:** /emoteall [radius] [emote]

### 9. drp-dailyreward
- Daily login reward system
- MySQL database tracking
- Configurable reward amounts
- 24-hour cooldown
- Automatic claim on spawn

### 10. drp-auto_thermal
- Vehicle-mounted thermal camera for police cars
- Same features as helicam for ground vehicles
- Zoom controls
- Night vision and thermal vision modes
- **Keybinds:** E (camera), Right Mouse (vision modes)

### 11. drp-dj
- DJ booth system for clubs and venues
- YouTube music playback via xsound
- Job-based access control
- Custom playlists per location
- Volume control and pause/resume
- Marker-based interaction

### 12. drp-sit
- Advanced multi-seat sitting system
- 200+ sittable object models
- Precise vec4 positioning with rotation
- ox_target integration
- Network entity synchronization for multiplayer
- **Keybind:** E (get up)

### 13. drp-sling
- Visible weapon on back system
- Hotbar slots 1-5 monitoring
- ox_inventory integration
- Vehicle state detection (auto-hide in vehicles)
- Support for pistols, rifles, melee weapons
- Configurable bone attachments and positions

### 14. drp-status
- Hunger and thirst status system
- esx_status compatible
- Tick-based status drain with damage
- MySQL persistence
- txAdmin heal event support
- Configurable tick rates and drain amounts

### 15. drp-carry
- Carry/drag other players
- Police carry restrictions
- Break-free mechanic for non-police carries
- Animated carry and drag positions
- Full control disabling while carried
- **Keybind:** E (break free when being carried)

## Installation

1. **Copy the resource:**
   ```
   Copy the drp-addons folder to your server's resources directory
   ```

2. **Install SQL:**
   ```
   Import source/drp-holdup/sql/install.sql into your database
   Import source/drp-dailyreward/sql/install.sql into your database
   Import source/drp-status/sql/install.sql into your database
   ```

3. **Add to server.cfg:**
   ```
   ensure drp-addons
   ```

4. **Configure:**
   - Edit `config.lua` to customize:
     - Megaphone job whitelist
     - Helicam allowed vehicles
     - Carwash locations and prices
     - Holdup store locations and rewards
     - VehControl siren models
     - AutoThermal vehicle camera heights
     - DailyReward cooldown and reward amounts
     - RichPresence Discord app settings
     - DJ booth locations and playlists

## Dependencies

### Required:
- es_extended (ESX Legacy)
- ox_lib
- ox_target
- oxmysql
- pma-voice

### Optional:
- lockpick (for handcuff break-free feature)
- jobs_creator (for carlock faction vehicles)
- xsound (for DJ system music playback)

## Configuration

All modules are configured in `config.lua`. Key sections:

### Megaphone
```lua
Config.Megaphone.AllowedJobs = {
    police = true,
    sheriff = true
}
```

### Helicam
```lua
Config.Helicam.AllowedVehicles = {
    "polmav",
    "buzzm",
    -- Add more helicopter models
}
```

### Carwash
```lua
Config.Carwash.Locations = {
    { coords = vector3(22.32, -1391.95, 28.33), price = 500 },
    -- Add more locations
}
```

### Holdup
```lua
Config.Holdup.Stores = {
    ["store_id"] = {
        position = vector3(x, y, z),
        nameOfStore = "Store Name",
        secondsRemaining = 200,
        reward = 10000,
        MaxDistance = 20.0,
        blip = true
    }
}
```

### VehControl
```lua
Config.VehControl.FiretruckSirenModels = {
    "FIRETRUK",
    "LSFDTRUCK",
    -- Add more fire truck models
}

Config.VehControl.PowercallModels = {
    "AMBULANCE",
    "FIRETRUK",
    -- Add vehicles with powercall
}
```

### AutoThermal
```lua
Config.AutoThermal.VehicleCamHeights = {
    [GetHashKey("sheriff2")] = 1.5,
    [GetHashKey("polcmd")] = 1.8,
    -- Add more vehicle models with camera height offset
}
```

### DailyReward
```lua
Config.DailyReward.CooldownSeconds = 86400  -- 24 hours
Config.DailyReward.MinReward = 1000
Config.DailyReward.MaxReward = 5000
```

### RichPresence
```lua
Config.RichPresence.AppId = "YOUR_DISCORD_APP_ID"
Config.RichPresence.ServerName = "Your Server Name"
Config.RichPresence.MaxPlayers = 32
-- Configure Discord links and logo assets
```

### DJ
```lua
Config.DJ = {
    ['club_name'] = {
        jobs = { 'dj', 'club_owner' },  -- nil = anyone can use
        coords = vector3(x, y, z),
        radius = 50.0,
        playlist = {
            {
                name = 'Song Name',
                producer = 'Artist Name',
                link = 'https://www.youtube.com/watch?v=...'
            }
        }
    }
}
```

## Exports

### drp-carlock
```lua
-- Give vehicle keys to player
exports['drp-addons']:GiveVehicleKeys(vehicle)

-- Trigger car lock function
exports['drp-addons']:CarLock()
```

## Events

### drp-holdup
```lua
-- Police notification (automatic)
TriggerClientEvent('drp_holdup:setBlip', policeId, storeId, storeName, coords)
```

### drp-drugs
```lua
-- Client-side: Trigger drug effects (use with ox_inventory item events)
TriggerEvent('drp_drugs:useCocaine')
TriggerEvent('drp_drugs:useWeed')
TriggerEvent('drp_drugs:useLSD')
TriggerEvent('drp_drugs:useHallucinogenic')
TriggerEvent('drp_drugs:useAlcohol')
TriggerEvent('drp_drugs:useTHCGummy')
```

### drp-dj
```lua
-- Server-side: Play music at location
TriggerServerEvent('drp_dj:playMusic', locationId, youtubeUrl)

-- Server-side: Pause/resume music
TriggerServerEvent('drp_dj:pauseMusic', locationId)

-- Server-side: Change volume
TriggerServerEvent('drp_dj:changeVolume', locationId, volume)
```

### drp-dailyreward
```lua
-- Client-side: Check and claim reward (automatic on spawn)
TriggerServerEvent('drp_dailyreward:checkAndClaim')
```

## ox_inventory Items

Add these items to your `ox_inventory/data/items.lua`:

```lua
-- Drug Items
['cocaine'] = {
    label = 'Cocaine',
    weight = 10,
    stack = true,
    close = true,
    description = 'Powdered stimulant',
    client = {
        event = 'drp_drugs:useCocaine',
        remove = function() return true end
    }
},

['weed'] = {
    label = 'Weed',
    weight = 10,
    stack = true,
    close = true,
    description = 'Dried cannabis',
    client = {
        event = 'drp_drugs:useWeed',
        remove = function() return true end
    }
},

['lsd'] = {
    label = 'LSD',
    weight = 5,
    stack = true,
    close = true,
    description = 'Psychedelic tabs',
    client = {
        event = 'drp_drugs:useLSD',
        remove = function() return true end
    }
},

['hallucinogenic'] = {
    label = 'Hallucinogenic',
    weight = 10,
    stack = true,
    close = true,
    description = 'Mind-altering substance',
    client = {
        event = 'drp_drugs:useHallucinogenic',
        remove = function() return true end
    }
},

['alcohol'] = {
    label = 'Alcohol',
    weight = 500,
    stack = true,
    close = true,
    description = 'Alcoholic beverage',
    client = {
        event = 'drp_drugs:useAlcohol',
        remove = function() return true end
    }
},

['thc_gummy'] = {
    label = 'THC Gummy',
    weight = 5,
    stack = true,
    close = true,
    description = 'Cannabis-infused edible',
    client = {
        event = 'drp_drugs:useTHCGummy',
        remove = function() return true end
    }
},
```

## Commands

### Admin Commands
- `/emoteall [radius] [emote]` - Force emote on nearby players (admin only)

### Player Commands
All systems use keybinds instead of commands for better UX:
- **Megaphone:** B
- **Car Lock:** L
- **Helicam:** E (toggle), X (rappel), L (spotlight), Right Mouse (vision)
- **Auto Thermal:** E (toggle), Right Mouse (vision)
- **VehControl:** Q (lights), ALT/Comma (siren), E/R (tone), Up Arrow (powercall), =/- (signals), Backspace (hazards)
- **Sit:** E (get up)
- **Carry:** E (break free when being carried)

## Troubleshooting

### Megaphone not working:
- Ensure pma-voice is installed and running
- Check job name matches Config.Megaphone.AllowedJobs
- Verify you're in an emergency vehicle (class 18)

### Carlock not working on faction vehicles:
- Ensure jobs_creator events are being triggered
- Check entity state ownership is set correctly

### Holdup robberies not saving cooldown:
- Verify SQL table was created
- Check oxmysql is installed and configured
- Review server console for SQL errors

### VehControl sirens not syncing:
- Ensure all clients have the resource
- Check network events are not blocked
- Verify vehicle is class 18 (emergency)
- Try restarting the resource

### Turn signals auto-canceling too quickly:
- Signals cancel after traveling at >6 speed for 3 seconds
- This is by design to mimic real vehicles
- Adjust `delay_ind_timer` in client code if needed

### DJ system not playing music:
- Ensure xsound is installed and running
- Check YouTube URL is valid
- Verify player's job matches location job restrictions
- Check server console for xsound errors

### Drug effects not working:
- Ensure events are triggered from ox_inventory item usage
- Check event names match exactly (drp_drugs:use*)
- Verify animations are loading properly
- Check client console for script errors

### Daily rewards not claiming:
- Verify SQL table was created (daily_rewards)
- Check oxmysql connection
- Ensure player spawns properly (playerSpawned event)
- Review cooldown settings in config

### RichPresence not showing:
- Verify Discord App ID is correct
- Check Discord application has assets uploaded
- Ensure asset names match config (logo_large, logo_small)
- Restart FiveM client after config changes

### AutoThermal camera not working:
- Check vehicle model is in Config.AutoThermal.VehicleCamHeights
- Use GetHashKey() for model hashes in config
- Verify player is in the configured vehicle
- Check keybind conflicts (E key)

## Credits

Converted from NERO/5L framework to modern ESX Legacy by DRP Framework.

## License

Proprietary - DRP Framework 2025
