# DRP-DRUGS Testing Guide

## Overview
This script provides a fully converted ESX drug selling system with support for weed, coke, meth, and heroin bricks. The system includes territory-based selling zones, police alerts, and comprehensive debug logging.

## Debug Mode

Debug mode can be toggled in `config/server_config.lua`:

```lua
Config.Debug = false  -- Set to true to enable debug output
```

When enabled, debug mode provides:
- Console prints with detailed transaction info
- In-game notifications for zone entry/exit
- Sale attempt details (prices, modifiers, steal attempts)
- Police alert information
- Server-side transaction logging

## Commands

- `/sell` or `/cornersell` - Toggle drug selling on/off

## Testing Steps

### 1. Enable Debug Mode
```lua
-- In config/server_config.lua
Config.Debug = true
```

### 2. Give Test Items
Use your admin panel or run these commands:
```
/giveitem meth_brick 10
/giveitem coke_brick 10
/giveitem weed_brick 10
/giveitem heroin_brick 10
```

### 3. Test Territory Zones

The script includes 6 selling zones:

**Normal Zones (1x multiplier):**
- `paleto` - Paleto Bay (5% snitch, 15% steal chance)
- `grapeseed` - Grapeseed (5% snitch)
- `sandy` - Sandy Shores (5% snitch)
- `airport` - Airport (8% snitch, 1.1x price)

**2x Zones (double price):**
- `uni` - University area (10% snitch, 22% steal chance, 1.2x price)
- `vespucci` - Vespucci Beach (10% snitch, 1.2x price)

### 4. Test Selling Process

1. **Enter a zone** - Debug will show: "Entered selling zone: [zone name]"
2. **Run `/sell` command** - System checks:
   - Police count (Config.PoliceRequired = 2)
   - Drug inventory
   - Zone validity
3. **Wait for NPC** - Script finds nearby NPCs to approach
4. **Accept/Decline offer**:
   - Press `E` to accept
   - Press `G` to decline
5. **Monitor console** - Debug prints show:
   - Drug type and amount
   - Territory and price modifier
   - Base price + cop bonus
   - Final price calculation
   - Whether NPC steals or pays
   - Police alert rolls

### 5. Test Different Scenarios

**Scenario 1: Normal Sale**
- Enter normal zone (e.g., Sandy Shores)
- Sell drugs normally
- Check black money received

**Scenario 2: 2x Zone Sale**
- Enter 2x zone (e.g., University)
- Notice "~y~2x~w~" indicator in offer text
- Verify price is doubled

**Scenario 3: Theft**
- Enter zone with steal chance (Paleto or Uni)
- Multiple sales until theft occurs
- Check debug: "Drugs were STOLEN!"
- Verify no money received

**Scenario 4: Police Alert**
- Have at least one player as police job
- Sell multiple times in zone
- Monitor for snitch rolls
- Police receive dispatch with:
  - Suspect gender
  - Street name
  - Blip on map (5 minute duration)

**Scenario 5: Distance Check**
- Start selling
- Walk >25 units from start location
- Selling automatically stops

### 6. Verify Drug Support

All drug types are supported:
```lua
sellableDrugs = {
  'weed_brick',   -- $50-$100
  'coke_brick',   -- $150-$250
  'meth_brick',   -- $200-$300
  'heroin_brick'  -- $180-$280
}
```

Test each drug type to verify:
- Correct pricing
- Proper inventory removal
- Black money addition

## New Features

### Weekend Demand Bonus
- **Friday, Saturday, Sunday** = 25% price increase
- Applies to corner selling in zones
- Shows `[WEEKEND]` indicator in green during sales
- Uses in-game day/night cycle (GetClockDayOfWeek)

## Configuration Options

### `config/server_config.lua`

```lua
Config.Debug = false              -- Enable debug logging
Config.PoliceRequired = 0         -- Minimum police to sell (set to 0 for testing)
Config.SellDifficulty = 15        -- Difficulty 1-20 (lower = easier)
Config.WeekendPriceBonus = 1.25   -- 25% bonus on weekends (Friday, Saturday, Sunday)

Config.Drugs = {
  ["meth_brick"] = {
    price = { min = 200, max = 300 },
    label = "Meth Brick"
  }
  -- ... other drugs
}
```

### Zone Properties
- `priceMod` - Price multiplier for zone
- `snitchChance` - Probability of police alert (0-1)
- `stealChance` - Probability of NPC stealing (0-1)
- `is2x` - Double price zone flag

## Debug Output Examples

### Zone Entry
```
[DRP-DRUGS DEBUG] Entered zone: uni
[DRP-DRUGS DEBUG] Config loaded from server
```

### Sale Attempt
```
[DRP-DRUGS DEBUG] === Drug Sale Attempt ===
[DRP-DRUGS DEBUG] Drug: Meth Brick x2
[DRP-DRUGS DEBUG] Territory: uni (Modifier: 1.2x)
[DRP-DRUGS DEBUG] Base Price: $250
[DRP-DRUGS DEBUG] Cop Bonus: $180
[DRP-DRUGS DEBUG] Final Price: $1032
[DRP-DRUGS DEBUG] 2x Zone: true
[DRP-DRUGS DEBUG] Will Steal: false
```

### Server Processing
```
[DRP-DRUGS DEBUG] === Processing Sale ===
[DRP-DRUGS DEBUG] Player: 1 (John Doe)
[DRP-DRUGS DEBUG] Drug: meth_brick x2
[DRP-DRUGS DEBUG] Territory: uni
[DRP-DRUGS DEBUG] Price: $1032
[DRP-DRUGS DEBUG] Stolen: false
[DRP-DRUGS DEBUG] Removed 2x meth_brick from inventory
[DRP-DRUGS DEBUG] Added $1032 black money to player
[DRP-DRUGS DEBUG] === Sale Complete ===
```

### Police Alert
```
[DRP-DRUGS DEBUG] !!! POLICE ALERTED !!! (Snitch Roll: 0.08 <= 0.1)
[DRP-DRUGS DEBUG] === Police Alert Triggered ===
[DRP-DRUGS DEBUG] Player: 1 (John Doe)
[DRP-DRUGS DEBUG] Location: Prosperity Street
[DRP-DRUGS DEBUG] Alerting 2 police officers
```

## Common Issues

### "Not enough police on duty"
- Ensure Config.PoliceRequired is set appropriately
- Have players with 'police' job online
- Check debug for current police count

### "You have no drugs to sell"
- Verify items are named correctly (meth_brick, not meth)
- Check inventory using F2
- Use debug to see detected drug count

### "You need to be in a selling zone"
- Verify coordinates match zone boundaries
- Debug shows zone entry/exit messages
- Try entering zone center

### NPCs not approaching
- Wait 3-5 seconds after starting
- Move slightly if stuck
- Check if too many players nearby
- Ensure not in vehicle

## Next Steps

After testing is complete, you can:
1. Disable debug mode (`Config.Debug = false`)
2. Implement ox_lib radial menu for `/sell` command
3. Adjust zone boundaries as needed
4. Fine-tune prices and probabilities
5. Add custom animations or props

## Support

For issues or questions, check:
- Server console for errors
- F8 console for client errors
- Enable debug mode for detailed logging
