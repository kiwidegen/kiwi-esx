# DRP HUD v2

A modern FiveM HUD system for ESX servers with React UI and optimized delta updates.

## Features

- **Player Stats**: Health, armor, hunger, thirst, stress, stamina, oxygen, voice, caffeine
- **Vehicle HUD**: Racing-style speedometer with RPM bar, gear display, fuel, engine health, seatbelt, traction control
- **Caffeine System**: Speed boost and stamina restoration
- **Optimized Performance**: Delta updates instead of full state dumps
- **Minimap Integration**: Shows/hides based on vehicle state and GPS toggle

## Installation

1. Place `drp-hud` in your resources folder
2. Add to `server.cfg`:
   ```
   ensure drp-hud
   ```
3. Build UI (if modifying):
   ```bash
   cd ui
   bun install
   bun run build
   ```

## Dependencies

- **ESX Framework** (`es_extended`)
- **ox_lib**
- **pma-voice**
- **esx_status** (hunger/thirst)
- **ox_fuel** (vehicle fuel)

## Commands

### Player Commands

- `/gps` - Toggle minimap
- `/cinematic` - Toggle cinematic mode (hides HUD)
- `/hideui` - Force hide HUD
- `/huddebug` - Print HUD state to console

### Test Commands

- `/testcaf [amount]` - Add caffeine (default: 50)
- `/caffeine [amount]` - Add caffeine with notification

## Caffeine System

The caffeine system provides:

- **Speed boost**: 1.0x to 1.15x multiplier based on caffeine level (0-100)
- **Stamina restoration**: Prevents stamina drain while active
- **Auto decay**: -1 point per 30 seconds

### Integration with ox_inventory

To make an item trigger the caffeine effect, add this to your item's server-side callback:

```lua
-- In your ox_inventory items.lua or where you register usable items
exports('energy_drink', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local src = inventory.id

        -- Trigger caffeine effect (50 = amount of caffeine to add)
        TriggerClientEvent('hud:client:consumeCaffiene', src, 50)

        -- Remove item
        exports.ox_inventory:RemoveItem(src, 'energy_drink', 1, nil, slot)

        -- Optional notification
        TriggerClientEvent('esx:showNotification', src, '⚡ You feel energized!')

        return true
    end
end)
```

**Caffeine amounts guide:**

- Coffee: 25-35
- Energy drink: 50-60
- Strong energy drink: 75-85

## Events

### Client Events

- `hud:client:hide_icons` - Hide player stat icons
- `hud:client:consumeCaffiene` - Add caffeine (amount)
- `hud:client:UpdateStress` - Update stress level
- `hud:client:set_cornerselling` - Toggle corner selling mode
- `seatbelt:client:ToggleSeatbelt` - Toggle seatbelt

### Server Events

- `hud:server:GainStress` - Add stress (amount)
- `hud:server:RelieveStress` - Remove stress (amount)

## Configuration

All settings are in `config.lua`:

```lua
Config.UpdateRate = 100  -- HUD update rate in ms

-- Player stat colors
Config.Player = {
    health = { ... },
    armor = { ... },
    -- etc
}

-- Vehicle settings
Config.Vehicle = {
    fuelBlinkAmountMinimum = 25,
    engineLightHealthMinimum = 300,
    -- etc
}
```

## Stress System

Whitelisted jobs don't gain stress from shooting/punching:

```lua
Config.WhitelistedJobs = {
    'police',
    'ambulance',
    'sheriff',
    'state',
    -- Add more jobs
}
```

Stress gain/relief amounts:

```lua
Config.Stress = {
    gainAmount = 5,
    reliefAmount = 5
}
```

## Minimap

Uses default GTA V minimap. Shows when:

- In vehicle (unless cinematic mode)
- GPS enabled (`/gps`)

Hides when:

- On foot and GPS disabled
- Cinematic mode active
- During character selection

## Development

### UI Development

```bash
cd ui
bun run dev     # Hot reload development server
bun run build   # Production build
```

### File Structure

```
drp-hud/
├── client/
│   ├── main.lua           # Main HUD controller
│   ├── modules/
│   │   ├── player.lua     # Player stats tracking
│   │   ├── vehicle.lua    # Vehicle stats tracking
│   │   ├── events.lua     # Event handlers
│   │   └── buffs.lua      # Caffeine system
├── server/
│   ├── main.lua
│   └── modules/
│       └── stress.lua     # Stress system
├── ui/
│   ├── src/
│   │   ├── App.jsx
│   │   ├── components/
│   │   │   ├── PlayerHud.jsx
│   │   │   └── VehicleHud.jsx
│   │   └── hooks/
│   │       └── useNuiEvent.js
│   └── dist/              # Built UI files
├── config.lua
└── fxmanifest.lua
```

## Troubleshooting

**HUD not showing:**

- Check F8 console for errors
- Verify all dependencies are started
- Run `/huddebug` to check state
- Ensure HUD shows after `esx:playerLoaded`

**Vehicle HUD stuck on screen:**

- Fixed in latest version with exit detection
- Restart resource: `ensure drp-hud`

**Stamina always visible:**

- Should only show when actively sprinting
- Check player.lua sprint detection

## Credits

Built for DRP by demon
