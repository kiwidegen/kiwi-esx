# kd-basics — Install Guide

---

## Dependencies

Make sure these are started **before** kd-basics:

| Resource | Required |
|---|---|
| `ox_lib` | Yes |
| `es_extended` | Yes |
| `ox_inventory` | Yes |

---

## 1. Add Items (ox_inventory)

Open `ox_inventory/data/items.lua` and add the entries from `install/items.lua`.

Each item that triggers a script uses `server.export` to call back into kd-basics:

```lua
['binoculars'] = {
    label       = 'Binoculars',
    weight      = 500,
    stack       = false,
    close       = true,
    description = 'Police-issued binoculars for long-range observation.',
    server      = {
        export = 'kd-basics.useBinoculars'  -- calls exports('useBinoculars') in server/sv_items.lua
    },
},
```

> How it works: player uses item → ox_inventory reads `server.export` → calls `exports['kd-basics']:useBinoculars()` server-side → job check → triggers client event

---

## 2. Server Config Load Order

In your `server.cfg`:

```
ensure ox_lib
ensure es_extended
ensure ox_inventory
ensure kd-basics
```

---

## 3. Config

All adjustable values are in `shared/config.lua`. No need to touch logic files.

| Key | Default | Description |
|---|---|---|
| `Config.Binoculars.jobs` | `{ 'police', 'sheriff' }` | Jobs allowed to use binoculars |
| `Config.Binoculars.item` | `'binoculars'` | Item name in ox_inventory |
| `Config.Ids.range` | `25` | Metres before player IDs stop showing |
| `Config.Bikes.promptRange` | `5.0` | Metres before handlebar prompt shows |
| `Config.Carry.range` | `3.0` | Metres to find a player to carry |

---

## 4. Give Items In-Game

```
/giveitem [playerid] binoculars 1
```

---

## Checklist

- [ ] `ox_lib` started before kd-basics
- [ ] `es_extended` started before kd-basics
- [ ] `ox_inventory` started before kd-basics
- [ ] Items added to `ox_inventory/data/items.lua` with correct `server.export`
- [ ] 0 console errors on `ensure kd-basics`
