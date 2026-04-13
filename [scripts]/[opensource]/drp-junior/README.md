# DRP Junior - New Player Protection System

Protects new players for their first hour in the city by restricting combat and preventing vehicle damage to others.

## Features

- **1 Hour Protection**: New players get 1 hour (3600 seconds) of protection from joining the server
- **Combat Restrictions**:
  - Cannot punch/melee attack
  - Cannot use weapons
- **Vehicle Protection**:
  - Junior's vehicle becomes semi-transparent when driving
  - Vehicle cannot damage other players/peds
  - Vehicle phases through other peds
- **Live Countdown**: Shows a countdown timer notification with time remaining
- **Welcome Messages**: Greets new players and explains the protection system

## Installation

1. Import the database table:
   ```sql
   -- Run the contents of database.sql in your database
   ```

2. Add to your `server.cfg`:
   ```
   ensure drp-junior
   ```

3. Restart your server or start the resource:
   ```
   start drp-junior
   ```

## Configuration

Edit `config.lua` to customize settings:

### Basic Settings
- `PROTECTION_DURATION`: Duration in seconds (default: 3600 = 1 hour)
- `VEHICLE_ALPHA`: Vehicle transparency (0-255, default: 150)
- `CHECK_INTERVAL`: How often to check protection status in ms
- `WELCOME_TITLE`: Welcome message title
- `PROTECTION_MESSAGE`: Protection notification description

### Discord Webhook Settings
- `DISCORD_WEBHOOK`: Your Discord webhook URL (leave empty to disable)
- `DISCORD.enabled`: Enable/disable Discord logging (default: true)
- `DISCORD.botName`: Bot name shown in Discord (default: 'Junior Protection')
- `DISCORD.color`: Default embed color (default: 3447003 - Blue)
- `DISCORD.footer`: Footer text for embeds
- `DISCORD.avatar`: Optional avatar URL for webhook

**Example Discord Setup:**
```lua
Config.DISCORD_WEBHOOK = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE'
```

**Discord Events Logged:**
- 🆕 New player joins (first time) - Green
- 🛡️ Admin removes protection - Red
- 🧪 Player uses /testnew command - Yellow

## Commands

### `/testnew`
- **Description**: Simulate being a new player (for testing)
- **Permission**: Anyone
- **Usage**: `/testnew`
- **Note**: Relogging recommended after using this command

### `/removejunior [player id]`
- **Description**: Remove junior protection from a player
- **Permission**: Admin/Superadmin only
- **Usage**: `/removejunior 1`
- **Example**: `/removejunior 5` removes protection from player ID 5

## How It Works

1. When a player connects for the first time, their join timestamp is saved to the database
2. The server checks if they're within the protection period (1 hour)
3. If protected:
   - Client disables melee and weapon controls
   - When driving, vehicle becomes semi-transparent
   - Vehicle collisions with peds are disabled
   - Countdown timer shows time remaining
4. After 1 hour, protection automatically expires

## For Other Scripts

You can check if a player is protected using the export:

```lua
local isProtected = exports['drp-junior']:isPlayerProtected(source)

if isProtected then
    -- Player is protected, don't allow certain actions
end
```

## Dependencies

- es_extended (ESX Legacy)
- ox_lib
- oxmysql

## Performance Optimizations

This script has been heavily optimized for minimal performance impact:

**Client-Side:**
- Cached player ped, coords, and vehicle (updated every 500ms instead of every frame)
- Uses `GetGamePool()` instead of `Find*` natives (much faster)
- Entity collision checks update every 500ms instead of every frame
- Combat restriction checks run at 100ms intervals (not every frame)
- Vehicle thread runs at 250ms intervals
- Early exits to prevent unnecessary processing

**Server-Side:**
- First join timestamps cached in memory (reduces database queries)
- Cache automatically updated on changes
- Early exits in damage handlers
- Efficient protection status checks
- Minimal database calls after initial load

**Memory Management:**
- Automatic garbage collection
- No memory leaks
- Efficient table operations
- Cache persists for quick rejoin handling

## Notes

- Protection does NOT make players invincible - they can still be damaged/killed
- Protection is tied to player identifier, not character
- Database tracks first join permanently
- Vehicle transparency resets when player exits vehicle
- Protection status updates automatically
- Server-side damage blocking prevents bypass exploits
