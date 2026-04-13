# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A modern FiveM HUD system for ESX servers built with Lua (client/server) and React (UI). Uses a state-based architecture with delta updates to minimize NUI message overhead.

## Build Commands

### UI Development

```bash
cd ui
bun install           # Install dependencies
bun run dev          # Start Vite dev server (hot reload)
bun run build        # Build for production (outputs to ui/dist/)
```

The build output in `ui/dist/` is loaded by FiveM via `fxmanifest.lua`.

## Architecture

### State Management (client/main.lua)

The HUD uses a centralized state store (`HUD.state`) with three categories:

- **player**: health, armor, hunger, thirst, stress, stamina, oxygen, caffiene, voice, is_dead
- **vehicle**: speed (actually RPM), health, fuel, nitrous, tracker, seatbelt
- **ui**: hide, hide_icons, gps, admin, developer, cinematic, realestate, cornersell, inVehicle, isTalking, isTalkingOnRadio, forceHide

**Key principle**: The HUD only sends delta updates to the UI when values change (`HUD:UpdateState()`), not full state dumps. This minimizes NUI overhead.

### Module Pattern (client/)

The client is organized into modules that are instantiated and managed by the main HUD controller:

- **Player module** (`client/modules/player.lua`): Tracks player stats (health, armor, stamina, oxygen, talking). Uses `HasChanged()` with configurable thresholds to prevent unnecessary updates.

- **Vehicle module** (`client/modules/vehicle.lua`): Tracks vehicle stats when in vehicle. Handles OnEnter/OnExit events, shows/hides radar appropriately. Vehicle is detected via game events, not polling.

- **Events module** (`client/modules/events.lua`): Centralizes all event handlers (game events, net events, commands). This prevents scattered event registrations across the codebase.

### NUI Communication Pattern

**Client → UI (Lua → React)**:

```lua
-- Delta update (preferred)
SendNUIMessage({
    type = 'hud.update',
    payload = {
        category = 'player',
        key = 'health',
        value = 75
    }
})

-- Full state init (only on startup)
SendNUIMessage({
    type = 'hud.init',
    payload = {
        state = HUD.state,
        config = Config
    }
})
```

**UI → Client (React → Lua)**:

```javascript
// From React component
fetch(`https://${GetParentResourceName()}/hud.ready`, {
  method: "POST",
  body: JSON.stringify({}),
});
```

**Important**: The UI uses `useNuiEvent` hook to listen for messages. See `ui/src/hooks/useNuiEvent.js`.

### Config System (config.lua)

All colors, thresholds, and settings are in `config.lua`. The config is sent to the UI on init and used for styling. When modifying UI colors or vehicle thresholds, edit `config.lua`, not hardcoded values in the UI.

## Integration Points

### ESX Framework

- Uses `@es_extended/imports.lua` for ESX shared object
- Integrates with `esx_status` for hunger/thirst (polled every 5s in `HUD:InitializeNutrition()`)
- Listens for `esx:playerLoaded` and `esx:onPlayerLogout` events

### ox_lib

- Uses `lib.callback` for server callbacks (e.g., admin check)
- Imported via `@ox_lib/init.lua`

### pma-voice

- Listens to `pma-voice:setTalkingMode` for voice range changes
- Listens to `pma-voice:radioActive` for radio talking indicator

### ox_fuel

- Reads fuel from entity state: `Entity(vehicle).state.fuel`
- Does NOT use exports, uses statebag pattern

### Seatbelt Integration

- Expects external resource to trigger `seatbelt:client:ToggleSeatbelt` event
- Updates via `RegisterNetEvent` in vehicle module

## Common Development Patterns

### Adding a New Player Stat

1. Add to `HUD.state.player` in `client/main.lua`
2. Add update logic in `client/modules/player.lua:Update()`
3. Add config colors in `config.lua` under `Config.Player`
4. Update UI component in `ui/src/components/PlayerHud.jsx`

### Adding a New Vehicle Stat

1. Add to `HUD.state.vehicle` in `client/main.lua`
2. Add update logic in `client/modules/vehicle.lua:Update()`
3. Reset in `vehicle:ResetValues()` when exiting vehicle
4. Update UI component in `ui/src/components/VehicleHud.jsx`

### Adding a New Event Handler

All event handlers should go in `client/modules/events.lua`, categorized by type:

- `RegisterGameEvents()`: Native game events (gameEventTriggered)
- `RegisterNetEvents()`: Network events from server or other resources
- `RegisterCommands()`: Chat commands

### Debugging

Use the built-in command: `/huddebug` - prints entire HUD state to console.

## Important Notes

- **Vehicle speed display**: Actually shows RPM (`GetVehicleCurrentRpm`) converted to 0-100%, NOT actual speed. This is intentional for the HUD's visual design.
- **Health range**: FiveM health is 100-200, converted to 0-100% for display.
- **Stamina inversion**: Native stamina is inverted (100 = full, 0 = exhausted) in the player module.
- **Single update loop**: The entire HUD runs on one thread (`HUD:StartUpdateLoop()`) to minimize performance impact.
- **Minimap setup**: Uses custom square minimap textures loaded in `HUD:SetupMinimap()`. Radar visibility is controlled based on vehicle state and GPS toggle.
- **Stress system**: Server-side stress calculations in `server/modules/stress.lua` with configurable whitelisted jobs and gain/relief amounts.

## UI Development Notes

- React app uses Vite for bundling
- Uses custom `useNuiEvent` hook for listening to NUI messages
- Default config is embedded in `App.jsx` but overridden by Lua config on init
- All styling is in `ui/src/styles/main.css`
- Components: `App.jsx` (root), `PlayerHud.jsx`, `VehicleHud.jsx`, `ProgressRing.jsx`

## Testing Workflow

1. Make changes to Lua files → reload resource: `ensure drp-hud` in server console
2. Make changes to UI → run `bun run build` in `/ui` directory → reload resource
3. For rapid UI iteration, use `bun run dev` and configure Vite proxy if needed
