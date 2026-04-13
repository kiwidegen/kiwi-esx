# DRP Drugs - Advanced ESX Drug Selling System

A comprehensive drug selling system for ESX Legacy with modern ox dependencies.

## Features

- **Zone-Based Selling**: 9 unique territories with different risk/reward profiles
- **Dynamic 2x Bonus**: Random zone + drug combination selected on each restart
- **Weekend Bonus**: 25% price increase on Friday, Saturday, and Sunday
- **Robbery System**: NPCs can steal your drugs - chase them down or kill them to recover
- **Police Alerts**: Integration with rcore_dispatch for realistic police callouts
- **Cop Bonus**: More police online = higher prices
- **Gradual Selling**: NPCs purchase 1-4 bags at random with weighted chances
- **ox_lib Integration**: Modern UI with progress circles, notifications, and radial menu
- **ox_target Recovery**: Easy drug recovery from thieves using 3rd eye targeting

## Dependencies

- **es_extended** (ESX Legacy)
- **ox_lib**
- **ox_target**
- **ox_inventory**
- **oxmysql**
- **rcore_dispatch**

## Installation

1. Ensure all dependencies are installed and started before this resource
2. Import SQL tables if required (none needed - uses existing ESX tables)
3. Add `ensure drp-drugs` to your server.cfg
4. Configure zones and settings in `config/server_config.lua`
5. Restart your server

## Configuration

Edit `config/server_config.lua` to customize:

- **Debug Mode**: Enable/disable debug prints and zone visualization
- **Police Required**: Minimum cops needed to start selling
- **Sell Difficulty**: Chance (1-20) that NPCs ignore you
- **Weekend Bonus**: Price multiplier for weekends (default: 1.25x)
- **Drug Prices**: Min/max prices for each drug type
- **Zones**: Territory boundaries, price modifiers, snitch chances, steal chances

### Zone Configuration

Each zone has:
- `points`: Polygon boundaries (vector2)
- `minZ` / `maxZ`: Height range
- `priceMod`: Price multiplier for this zone
- `snitchChance`: Probability (0-1) police get alerted
- `stealChance`: Probability (0-1) NPC steals instead of buying

## Usage

### Commands

- `/sell` - Toggle drug selling on/off
- `/cornersell` - Alternative toggle command

### Radial Menu

Open your ox_lib radial menu and select "Sell Drugs"

### How to Sell

1. Stand in a selling zone (you'll see a notification when entering)
2. Use `/sell` or radial menu to start selling
3. NPCs will approach you automatically
4. Accept (E) or decline (G) their offers
5. Watch for robberies - chase thieves to recover your drugs!

## Selling Zones

1. **Paleto Bay** - Rural area, moderate prices, 15% steal chance
2. **Grapeseed** - Low risk, standard prices, 12% steal chance
3. **Sandy Shores** - Desert town, standard prices, 10% steal chance
4. **University** - High risk/reward, 1.2x prices, 22% steal chance
5. **Vespucci Beach** - Tourist area, 1.2x prices, 15% steal chance
6. **Airport** - Industrial zone, 1.1x prices, 12% steal chance
7. **The Hood** - Gang territory, 1.15x prices, 20% steal chance
8. **Vinewood** - Wealthy area, 1.3x prices, 10% steal chance
9. **Mirror Park** - Suburban zone, 1.2x prices, 18% steal chance

## Recovery System

If an NPC steals your drugs:

1. They will flee - chase them down!
2. Kill them or catch up to them
3. Use **ox_target** (3rd eye) on the thief
4. Click "Recover Drugs" to get them back
5. You have **2 minutes** before they escape

## Price Calculation

Final price = `(Base Price + Cop Bonus) × Bag Amount × Zone Modifier × Weekend Bonus × 2x Bonus`

- **Base Price**: Random between min/max for drug type
- **Cop Bonus**: $60-100 per online cop
- **Bag Amount**: 1-4 bags (weighted random)
- **Zone Modifier**: Varies by territory (1.0x - 1.3x)
- **Weekend Bonus**: 1.25x on Fri/Sat/Sun
- **2x Bonus**: Only if selling the active 2x drug in the active 2x zone

## Support

For issues or questions, contact the developer.

## Credits

- **Author**: KiwiDegen
- **Framework**: ESX Legacy
- **Version**: 2.0.0

---

© 2025 KiwiDegen. All rights reserved.
