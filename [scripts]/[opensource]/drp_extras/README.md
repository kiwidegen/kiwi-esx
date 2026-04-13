# DRP-Extras

Quality of life and gameplay enhancement scripts for Demon RP - ESX Legacy Framework.

## Overview

This resource combines multiple gameplay modules into a single, optimized package. All modules can be toggled individually in the config file, allowing for flexible server customization.

## Features

### Core Modules (Original DRP-Extras)

- **Idle Camera** - Cinematic camera when idle
- **Hands Up** - Raise hands animation and controls
- **Point** - Point at things/people
- **Binoculars** - Use binoculars
- **Car Wash** - Wash vehicles
- **Crouch/Prone** - Crouch and prone mechanics
- **Fireworks** - Firework effects
- **F8 Quit Confirmation** - Confirm before quitting
- **Player IDs** - Display player IDs with command
- **Heli Guns** - Allow/disallow guns in helicopters
- **Bike Guns** - Allow/disallow guns on bikes
- **Entity Removal** - Remove specific world objects
- **Seatbelt System** - Realistic seatbelt with audio
- **Clothing Lock** - Lock clothing and auto-remove helmets

### Additional Modules (Merged from Fare)

- **Carry Players** - Fireman carry other players
- **Take Hostage** - Take players hostage at gunpoint
- **Vest Equip** - Delayed vest equipping with progress bar
- **Holster Animations** - Weapon draw/holster animations (optional)
- **Max Speed Limiter** - Limit vehicle max speed
- **Restricted Items** - Job-based item/weapon restrictions
- **Combat Log Notifications** - Notify nearby players of disconnects
- **Anti Pistol Whip** - Disable melee with weapons equipped
- **Death Notifications** - Show kill/death info
- **Car Clear System** - Automatic vehicle cleanup
- **No NPC** - Disable ambient NPCs and traffic
- **Infinite Stamina** - No stamina depletion

## Dependencies

Required:

- [es_extended](https://github.com/esx-framework/esx_core) - ESX Legacy Framework
- [ox_lib](https://github.com/overextended/ox_lib) - Overextended library
- [ox_inventory](https://github.com/overextended/ox_inventory) - Inventory system
- [oxmysql](https://github.com/overextended/oxmysql) - MySQL wrapper

Optional:

- `drp-hud` - For seatbelt HUD integration

## Installation

1. Download and extract `drp_extras` to your resources folder
2. Ensure all dependencies are installed and started
3. Add `ensure drp_extras` to your `server.cfg`
4. Configure `config.lua` to enable/disable desired modules
5. Restart your server

## Configuration

All module toggles and settings are in `config.lua`. Each module can be enabled/disabled independently:

```lua
Config.Modules = {
    IdleCam        = true,
    HandsUp        = true,
    Carry          = true,
    TakeHostage    = true,
    -- ... and many more
}
```

### Important Config Sections

- **Module Toggles** - Enable/disable features
- **Seatbelt System** - Customize seatbelt mechanics
- **Restricted Items** - Define job-based restrictions
- **Entity Removal** - Specify objects to remove
- **Car Clear** - Configure automatic vehicle cleanup
- **Combat Log** - Set notification range

## Commands

- `/id` - Display your player ID to nearby players
- `/carry` - Carry/release a nearby player
- `/th` - Take a nearby player hostage (requires pistol with ammo)

## Key Bindings

Default keybinds (can be changed in-game):

- `B` - Toggle seatbelt
- `PLUS` - Use vest (hotkey, if enabled)
- `MINUS` - Use magazine (hotkey, if enabled)

## Module Details

### Carry Players

Allows players to carry unconscious or cooperative players in a fireman carry.

### Take Hostage

Take players hostage at gunpoint. Requires a pistol with ammunition.

- `G` - Release hostage
- `H` - Kill hostage

### Seatbelt System

Realistic seatbelt with:

- Audio feedback
- Ejection on high-speed crashes
- Damage reduction when buckled
- HUD integration support

### Restricted Items

Job-based restrictions for weapons and items. Players without proper jobs will have items automatically removed.

### Car Clear

Automatically removes vehicles that are far from all players at configured intervals.

## Performance

- Optimized thread usage with conditional execution
- Module guards prevent unused code from loading
- Modern Lua 5.4 syntax for better performance
- Efficient distance calculations

## Credits

- **Original DRP-Extras**: KiwiDegen
- **Merged Modules**: Various community scripts
- **Framework**: ESX Legacy Team
- **Libraries**: Overextended

## License

This resource combines multiple community scripts. Please respect individual licenses and credits.

## Support

For issues or questions:

- Create an issue on GitHub
- Check documentation at: https://documentation.esx-framework.org/

## Version History

### v2.0.0 (Current)

- Merged DRP-Extras with Fare Base One
- Removed all webhook integrations
- Added ESX Legacy compliance
- Improved annotations and documentation
- Modularized all features
- Updated to modern ox_lib standards

### v1.0.0

- Initial DRP-Extras release
