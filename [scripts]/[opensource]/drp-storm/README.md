# DRP Storm - Secure Combat Cooldown System

A secure, server-side validated combat cooldown system that works with **ALL weapons** including custom guns.

## Features

- **100% Server-Side Validation** - No client-triggered events, cheaters cannot bypass
- **Custom Weapon Support** - Works with ANY custom weapon using weapon groups
- **Weapon Group Detection** - Automatically detects weapon types (pistol, rifle, melee, etc.)
- **Debug Commands** - Test and validate custom weapons easily
- **Zero Client Trust** - All security decisions made server-side

---

## How It Works

### Security Architecture

**Client Side:**
- Only handles UI/UX (notifications, weapon disabling visuals)
- Cannot trigger cooldowns
- Has NO knowledge of weapon validation logic

**Server Side:**
- Detects player deaths via `entityDying` event
- Validates weapon type using weapon groups
- Full authority over cooldown logic
- Logs weapon hash + group for debugging

### Weapon Detection

Instead of maintaining a hardcoded list of weapon hashes (which breaks with custom weapons), this system uses **weapon groups**:

```lua
-- Weapon hash → Weapon group → Is it blocked?
0x1B06D571 (WEAPON_CARBINERIFLE) → GROUP_RIFLE → ✅ Blocked
0xYOURCUSTOM (WEAPON_CUSTOM_AK47) → GROUP_RIFLE → ✅ Blocked (automatically!)
```

As long as your custom weapon is registered with the correct weapon group in `weapons.meta`, it will work automatically.

---

## Configuration

### config/server.lua

#### Blocked Weapon Groups
```lua
Config.BlockedWeaponGroups = {
    -- Firearms
    [`GROUP_PISTOL`] = true,
    [`GROUP_SMG`] = true,
    [`GROUP_RIFLE`] = true,
    [`GROUP_SHOTGUN`] = true,
    [`GROUP_SNIPER`] = true,
    [`GROUP_MG`] = true,

    -- Melee
    [`GROUP_MELEE`] = true,
    [`GROUP_UNARMED`] = true,
}
```

#### Exclude Specific Weapons
If you want to exclude specific weapons even if they're in a blocked group:
```lua
Config.ExcludedWeapons = {
    [`WEAPON_STUNGUN`] = true, -- Taser won't trigger cooldown
}
```

#### Include Specific Weapons
If you want to include specific weapons even if they're NOT in a blocked group:
```lua
Config.IncludedWeapons = {
    [`WEAPON_CUSTOM_RAILGUN`] = true, -- Custom weapon will trigger cooldown
}
```

#### Cooldown Duration
```lua
Config.CooldownDuration = 300 -- 5 minutes (in seconds)
```

---

## Custom Weapons

### Automatic Detection
If your custom weapon is properly registered with a weapon group, it will automatically work:

**weapons.meta:**
```xml
<Item>
  <Name>WEAPON_CUSTOM_AK47</Name>
  <Model>w_ar_assaultrifle</Model>
  <WeaponGroup>GROUP_RIFLE</WeaponGroup>  <!-- This is what matters! -->
</Item>
```

### Manual Testing
Use the debug command to test any weapon:

1. Hold the weapon in-game
2. Run: `/checkweapon`
3. You'll see:
   - Weapon hash
   - Weapon group
   - Whether it triggers cooldown

**Example Output:**
```
Hash: 0xDEADBEEF
Group: 0x1234ABCD (GROUP_RIFLE)
Triggers Cooldown: YES
```

Server console will also log:
```
[drp-cooldown] Weapon check by PlayerName [12]: Hash=0xDEADBEEF, Group=0x1234ABCD, Blocked=true
```

---

## Commands

### Admin Commands
| Command | Description | Permission |
|---------|-------------|------------|
| `/cooldown <id> [duration]` | Place player on cooldown | `group.admin` |
| `/removecooldown <id>` | Remove player cooldown | `group.admin` |
| `/checkweapon` | Debug current weapon | `group.admin` |

### Player Commands
| Command | Description |
|---------|-------------|
| `/testcooldown [duration]` | Test cooldown on yourself |

---

## How Deaths Are Detected

### Primary Method: entityDying Event
```lua
AddEventHandler('entityDying', function(victim, killer, weaponHash)
    -- Server-side death detection
    -- Validates weapon type server-side
    -- Cheaters cannot fake this event
end)
```

### Backup Method: State Bag Monitoring
```lua
AddStateBagChangeHandler('isDead', nil, function(bagName, key, value)
    -- Redundant failsafe for death detection
    -- Uses stored death cause from entityDying
end)
```

---

## Security Features

### What Cheaters CANNOT Do:
❌ Trigger cooldown events manually
❌ Bypass weapon validation
❌ See the weapon whitelist
❌ Modify cooldown duration
❌ Fake death events

### What Cheaters CAN Do (and why it doesn't matter):
✅ Bypass client-side weapon disabling → Server still validates everything
✅ Modify their local cooldown timer → Server controls the actual cooldown
✅ Try to trigger events → Server validates or ignores

---

## Troubleshooting

### Custom Weapon Not Triggering Cooldown

1. **Check weapon group in weapons.meta:**
   ```xml
   <WeaponGroup>GROUP_RIFLE</WeaponGroup>
   ```

2. **Test with /checkweapon command:**
   - Hold weapon
   - Run `/checkweapon`
   - Check the weapon group

3. **If weapon group is wrong, you have two options:**
   - Fix the weapon group in weapons.meta (recommended)
   - Add to `Config.IncludedWeapons` manually

### Cooldown Not Working At All

1. **Check server console for errors**
2. **Test with `/testcooldown 30`**
3. **Check if resource is started:** `ensure drp-storm`
4. **Verify ox_lib is installed and updated**

### Weapon Hash Unknown

If you need to find a weapon hash:
1. Hold the weapon
2. Run `/checkweapon`
3. Server console will show the hash

---

## Available Weapon Groups

```lua
GROUP_PISTOL        -- All pistols
GROUP_SMG           -- Submachine guns
GROUP_RIFLE         -- Assault rifles
GROUP_SHOTGUN       -- Shotguns
GROUP_SNIPER        -- Sniper rifles
GROUP_MG            -- Machine guns
GROUP_MELEE         -- Melee weapons
GROUP_UNARMED       -- Fists
GROUP_THROWN        -- Grenades, molotovs
GROUP_HEAVY         -- RPG, minigun
GROUP_STUNGUN       -- Tasers
GROUP_PETROLCAN     -- Special items
```

---

## Technical Details

### Server-Side Validation Flow
```
1. Player dies (entityDying event fires)
2. Server gets weapon hash that killed player
3. Server checks weapon group via GetWeapontypeGroup()
4. Server validates if weapon group is blocked
5. Server applies cooldown if valid
6. Server notifies client to show UI
```

### Files Structure
```
drp-storm/
├── fxmanifest.lua          # Resource manifest
├── config/
│   ├── client.lua          # UI notifications only
│   └── server.lua          # All validation logic (secure)
├── client/
│   └── main.lua            # UI/UX only
├── server/
│   └── main.lua            # All logic and validation
└── README.md               # This file
```

---

## Credits

**Author:** KiwiDegen
**Version:** 2.0.0
**Security:** Server-side validated
**Custom Weapons:** ✅ Supported

---

## Support

For issues or questions:
1. Check server console for error messages
2. Use `/checkweapon` to debug weapon detection
3. Verify weapon groups in your weapons.meta files
