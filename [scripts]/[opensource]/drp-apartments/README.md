# DRP Apartments - ESX Legacy

ESX Legacy apartment system with modern dependencies (ox_lib, ox_target, ox_inventory, oxmysql).

## Features

- 🏠 **5 Apartment Locations** - Multiple buildings across Los Santos
- 🎯 **Dual Interaction Modes** - ox_target or zone-based interactions
- 📦 **ox_inventory Integration** - Unique stash per apartment
- 👔 **Wardrobe System** - Save and load outfits
- 🔔 **Visitor/Doorbell System** - Ring doorbells and grant access
- 🗺️ **Map Blips** - Home blip marking and location markers
- 🌍 **Routing Buckets** - Isolated apartment instances
- ⚡ **Performance Optimized** - Lua 5.4, modern coding practices
- 📝 **Fully Annotated** - Complete LuaLS type annotations

## Dependencies

### Required
- [es_extended](https://github.com/esx-framework/esx_legacy) - ESX Legacy framework
- [ox_lib](https://github.com/overextended/ox_lib) - UI and utilities
- [ox_target](https://github.com/overextended/ox_target) - Targeting system
- [ox_inventory](https://github.com/overextended/ox_inventory) - Inventory system
- [oxmysql](https://github.com/overextended/oxmysql) - Database connector

### Optional (Configurable)
- **Interior System**: drp-interior, esx_property, or custom solution
- **Clothing**: fivem-appearance, illenium-appearance, or esx_skin
- **Weather**: vSync, cd_easytime, or Renewed-Weathersync
- **Sounds**: InteractSound or xsound

## Installation

### 1. Database Setup

Execute the SQL file to create the apartments table:

```sql
-- Located in: drp_apartments.sql
-- Creates the drp_apartments table with proper indexes
```

### 2. Resource Installation

1. **Place the folder** as `drp-apartments`
2. **Place in your resources directory**:
   ```
   [esx]/drp-apartments/
   ```

3. **Add to server.cfg**:
   ```cfg
   ensure drp-apartments
   ```

### 3. Configuration

Edit `config.lua` to match your server setup:

```lua
---@type boolean Use ox_target (true) or zones (false)
Config.UseTarget = true

---@type string Clothing script: 'fivem-appearance', 'illenium-appearance', 'esx_skin'
Config.ClothingScript = 'fivem-appearance'

---@type string Weather script: 'vSync', 'cd_easytime', 'Renewed-Weathersync'
Config.WeatherScript = 'Renewed-Weathersync'

---@type string Interior script identifier
Config.InteriorScript = 'drp-interior'
```

### 4. Interior System Setup

The script requires an interior system to function. You can use drp-interior or create a custom solution:

#### Using drp-interior
Keep `Config.InteriorScript = 'drp-interior'` and ensure drp-interior is installed.

#### Custom Interior System
Create a wrapper that matches the export format:

```lua
-- In your interior resource
exports('CreateApartmentFurnished', function(coords)
    local shellObj = -- Create your interior/shell
    local offsets = {
        exit = vector3(1.46, -10.33, 1.06),
        stash = vector3(-3.28, -7.32, 1.06),
        clothes = vector3(-7.92, -3.60, 1.06),
        logout = vector3(-1.32, -5.52, 1.06)
    }
    return {shellObj, offsets}
end)

exports('DespawnInterior', function(shellObj, callback)
    -- Cleanup your interior/shell
    if callback then callback() end
end)
```

Then update `config.lua`:
```lua
Config.InteriorScript = 'your_interior_resource'
```

### 5. ox_inventory Stash Registration

Stashes are automatically registered when apartments are created. No additional configuration needed.

### 6. Clothing System Integration

Update the client code if not using fivem-appearance:

**In `client/main.lua`, line 857:**

```lua
-- For illenium-appearance:
exports['illenium-appearance']:openWardrobe()

-- For esx_skin:
TriggerEvent('esx_skin:openSaveableMenu')
```

## Usage

### For Players

1. **First Join**: New players automatically receive an apartment at a configured location
2. **Entering**: Go to any apartment building and use the entrance interaction
3. **Moving**: Choose "Move Here" to transfer your apartment to a different building
4. **Doorbell**: Ring doorbells to visit other players' apartments
5. **Interior**: Use stash, wardrobe, and logout bed inside

### For Developers

#### Event Reference

**Client Events:**
```lua
-- Spawn in apartment
TriggerEvent('drp-apartments:client:SpawnInApartment', apartmentId, apartmentType)

-- Enter apartment
TriggerEvent('drp-apartments:client:EnterApartment')

-- Leave apartment
TriggerEvent('drp-apartments:client:LeaveApartment')

-- Open stash
TriggerEvent('drp-apartments:client:OpenStash')
```

**Server Events:**
```lua
-- Create apartment
TriggerServerEvent('drp-apartments:server:CreateApartment', type, label, firstSpawn)

-- Update apartment
TriggerServerEvent('drp-apartments:server:UpdateApartment', type, label)

-- Open stash
TriggerServerEvent('drp-apartments:server:openStash', apartmentId)
```

#### Callback Reference

```lua
-- Get owned apartment
ESX.TriggerServerCallback('drp-apartments:GetOwnedApartment', function(apartment)
    print(apartment.name, apartment.type, apartment.label)
end)

-- Check ownership
ESX.TriggerServerCallback('drp-apartments:IsOwner', function(isOwner)
    print('Owns apartment:', isOwner)
end, apartmentType)

-- Get available apartments (with players inside)
ESX.TriggerServerCallback('drp-apartments:GetAvailableApartments', function(apartments)
    for id, label in pairs(apartments) do
        print(id, label)
    end
end, apartmentType)
```

## Apartment Locations

| ID | Label | Coordinates |
|----|-------|-------------|
| apartment1 | South Rockford Drive | `-667.02, -1105.24, 14.63` |
| apartment2 | Morningwood Blvd | `-1288.52, -430.51, 35.15` |
| apartment3 | Integrity Way | `269.73, -640.75, 42.02` |
| apartment4 | Tinsel Towers | `-619.29, 37.69, 43.59` |
| apartment5 | Fantastic Plaza | `291.517, -1078.674, 29.405` |

## Configuration Options

### Main Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Starting` | boolean | `true` | Auto-assign apartments on first join |
| `SpawnOffset` | number | `30` | Vertical offset between instances |
| `UseTarget` | boolean | `true` | Use ox_target vs zones |
| `ClothingScript` | string | `'fivem-appearance'` | Clothing system |
| `WeatherScript` | string | `'vSync'` | Weather/time system |
| `InteriorScript` | string | `'drp-interior'` | Interior system |
| `EnableSounds` | boolean | `true` | Enable sound effects |
| `InteractionDistance` | number | `2.0` | Max interaction distance |

### Adding New Locations

Edit `config.lua`:

```lua
Config.Locations["apartment6"] = {
    name = "apartment6",
    label = "Custom Location",
    coords = {
        enter = vector4(x, y, z, heading),
    },
    polyzoneBoxData = {
        heading = 0,
        minZ = z - 1.0,
        maxZ = z + 2.0,
        debug = false,
        length = 1,
        width = 3,
        distance = 2.0,
        created = false
    }
}
```

## Troubleshooting

### Apartments not showing
- Ensure dependencies are started before drp-apartments
- Check `ensure ox_lib` is before `ensure drp-apartments` in server.cfg
- Verify database table was created successfully

### Stash not opening
- Ensure ox_inventory is running
- Check server console for stash registration errors
- Verify player owns the apartment

### Interior not loading
- Check Config.InteriorScript matches your interior resource
- Ensure interior resource is running and exports are correct
- Verify POI offsets are configured properly

### Target not working
- Set `Config.UseTarget = false` to use zones instead
- Ensure ox_target is running
- Check target distance in polyzoneBoxData

## Credits

- **Framework**: [ESX Legacy](https://github.com/esx-framework/esx_legacy)
- **Dependencies**: [Overextended](https://github.com/overextended)

## License

GNU General Public License v3.0

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the configuration guide
3. Ensure all dependencies are properly installed
4. Check server/client console for errors
