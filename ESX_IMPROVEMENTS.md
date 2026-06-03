# ESX Extended — Code Review & Improvement Notes

> Reviewed against: `[base]/es_extended`
> Total: ~17,500 lines of Lua across 60 files
> Status: ESX Legacy is dead upstream. This doc captures what to fix, cut, or replace if you maintain a fork.

---

## Table of Contents

1. [Dependencies](#1-dependencies)
2. [Dead & Leftover Code](#2-dead--leftover-code)
3. [Bloat](#3-bloat)
4. [Architecture Problems](#4-architecture-problems)
5. [Performance Issues](#5-performance-issues)
6. [Security Gaps](#6-security-gaps)
7. [Specific Improvement Recommendations](#7-specific-improvement-recommendations)
8. [Quick Wins (Low Effort)](#8-quick-wins-low-effort)

---

## 1. Dependencies

### Hard Dependencies (will break without these)

| Dependency | Used For | Notes |
|---|---|---|
| `oxmysql` | All database queries | Replaces `mysql-async`. Required. |
| `ox_lib` | `require()` module system, class imports | Fallback exists in `imports.lua` but it's incomplete |

### Soft Dependencies (detected at runtime, alters behaviour)

| Dependency | Used For | Notes |
|---|---|---|
| `ox_inventory` | Alternative inventory/loadout system | Bridged via `server/bridge/inventory/oxinventory.lua` and `server/classes/overrides/oxinventory.lua` |

### How OX Inventory is detected

```lua
-- server/bridge/inventory/oxinventory.lua
if GetResourceState("ox_inventory") == "started" then
    Config.CustomInventory = "ox"
    -- overrides xPlayer inventory methods
end
```

If `ox_inventory` starts *after* `es_extended`, this detection can silently fail. There is no retry or error thrown.

### Implicit Dependencies (assumed present, never checked)

- `chat` resource — `/` command suggestions are sent to `chat` with no guard if it is missing.
- `spawnmanager` — `ESX.DisableSpawnManager()` calls into it on the client. Crashes silently if not present.
- `skinchanger` — `skinchanger:modelLoaded` event is listened for. No fallback if absent.
- `esx_identity` — `Config.Identity = true` branch assumes this resource exists with no check.
- `esx_multicharacter` — `Config.Multichar = true` branch assumes this resource exists with no check.

### ox_lib Fallback (imports.lua)

`imports.lua` ships a partial reimplementation of `require()` in case `ox_lib` is not present:

```lua
-- imports.lua ~line 1
if not lib then
    -- manual require() shim
end
```

This shim is ~346 lines and duplicates functionality that `ox_lib` already provides. It exists only as a safety net but adds confusion about what the actual minimum dependency set is. **Pick one: require ox_lib as a hard dep, or remove the shim and document the dep clearly.**

---

## 2. Dead & Leftover Code

### 2.1 Removed Event Stubs (events.lua)

These events were removed from the framework but left as registered listeners that just throw errors. They serve no runtime purpose and add event table overhead:

```lua
RegisterNetEvent("esx:addWeapon", function()
    error("event ^5'esx:addWeapon'^1 Has Been Removed...")
end)

RegisterNetEvent("esx:removeWeapon", function()
    error("event ^5'esx:removeWeapon'^1 Has Been Removed...")
end)
```

**Fix:** Delete these entirely. If a resource is still calling removed events it should fail loudly at the call site, not silently until a fake listener screams.

### 2.2 Migration Scripts (server/migration/)

```
server/migration/main.lua
server/migration/v1.13.3/ssn/main.lua
server/migration/v1.13.5/jobType/main.lua
```

These ran one-time database column migrations for versions that are years old. Any server running today has already run them. They still execute checks on every resource start.

**Fix:** Delete the migration folder. If you need migrations, use a proper versioned migration system (e.g., a `schema_version` table) and remove past ones.

### 2.3 Duplicate Job Count Tracking

Job player counts are maintained in two places simultaneously:

```lua
-- server RAM
Core.JobsPlayerCount[job][grade] += 1

-- GlobalState (replicated to ALL clients)
GlobalState["JobsPlayerCount"] = Core.JobsPlayerCount
```

The client never actually needs per-grade job counts — it only uses the job name. Replicating the entire count table to every connected client on every job change is unnecessary bandwidth.

**Fix:** Remove GlobalState replication. Expose a server callback if a resource genuinely needs counts.

### 2.4 Leftover Pickup System (default inventory only)

`client/modules/events.lua` contains ~100 lines of pickup creation/interaction logic that is completely bypassed when `ox_inventory` is active:

```lua
if not Config.CustomInventory then
    -- pickup creation, deletion, prop spawning, interaction zone
end
```

This code path is dead for most modern servers using OX Inventory. It creates networked objects, zones, and threads even during loading just to immediately bail out.

**Fix:** Either extract the pickup system into a standalone optional module or remove it if your server uses OX Inventory.

### 2.5 Deprecated Skin System References

`server/main.lua` and `xPlayer` both load and save a `skin` JSON column from the `users` table. ESX has not shipped a built-in skin system in years — `skinchanger` is a separate resource. The column is read, stored in `xPlayer.skin`, and synced to the client but never acted on by `es_extended` itself.

**Fix:** Remove `skin` from the player object and database queries in `es_extended`. Let `skinchanger` or your skin resource own that data column directly.

### 2.6 Billing Table (es_extended.sql)

The `billing` table is defined in the SQL schema but `es_extended` contains zero code that reads from or writes to it. It is owned by `esx_billing` (a separate resource).

**Fix:** Remove `billing` from `es_extended.sql`. It has no business being in the core schema file.

### 2.7 Car Dealer Table (es_extended.sql)

Same problem as billing — `cardealer_vehicles` is defined in the core SQL but owned entirely by `esx_vehicleshop`. Core never touches it.

**Fix:** Remove from core SQL.

### 2.8 Addon Account / Addon Inventory Tables (es_extended.sql)

`addon_account` and `addon_inventory` tables are defined and included but the actual society/org logic lives in `esx_society`. The core only creates the tables, never queries them beyond initial setup.

**Fix:** Move table creation to `esx_society` or document clearly that the core schema is a convenience bundle, not core functionality.

### 2.9 Parachute State Tracking (client/modules/events.lua)

```lua
-- tracks parachute separately from normal weapon system
local parachuteInLoadout = false
```

There is a dedicated block that handles parachute weapon hash separately from the rest of the loadout. This is a leftover workaround for a FiveM/GTA bug that may or may not still be relevant. No comment explains why it exists.

**Fix:** Test if the parachute still needs special-casing. If not, remove. If yes, add a comment.

### 2.10 NUI Chunking Wrapper (client/modules/wrapper.lua)

```lua
-- wrapper.lua
-- splits large NUI payloads into chunks and reassembles
```

This 15-line file exists to work around old FiveM NUI message size limits. Those limits were significantly raised years ago. Modern FiveM can handle large NUI payloads natively.

**Fix:** Test without the chunking. If NUI works fine (it almost certainly will), delete `wrapper.lua` and the corresponding `wrapper.js`.

---

## 3. Bloat

### 3.1 Weapons Config (1,108 lines)

`shared/config/weapons.lua` is a hardcoded list of every GTA weapon with all components. This entire file is loaded on both server and client at startup and kept in memory for the lifetime of the resource.

**Problems:**
- Rarely queried at runtime (only for label lookups and loadout restore)
- Component lists are used almost never in practice
- Adding custom weapons requires editing a core file

**Fix:** Lazy-load weapon data on first query. Move to a JSON file loaded once. Expose `ESX.GetWeapon()` as the only access point so the storage format can change without breaking the API.

### 3.2 Admin Commands in Core (client/functions.lua + server/modules/commands.lua)

Admin tools (noclip, freeze, teleport, vehicle spawner, max mods) are baked into `es_extended`. This means:

- They cannot be disabled without editing core files
- They run event listeners and threads for every player, including non-admins
- Updating them requires touching the core framework

**Fix:** Extract admin commands into a standalone `esx_admin` resource that lists `es_extended` as a dependency. The core should expose APIs (teleport player, freeze player), not implement the UI/UX of admin tools.

### 3.3 Discord Logging Baked In (shared/config/logs.lua + server/modules/commands.lua)

Discord webhook logging is implemented directly in the framework and called from command handlers. This creates a tight coupling between core logic and a specific logging backend.

**Problems:**
- Hardcoded to Discord (no abstraction)
- Logs fire inline in command callbacks, blocking the thread if the HTTP call is slow
- No retry or error handling on webhook failure

**Fix:** Emit a local server event (e.g., `esx:adminAction`) with the action data. Let a dedicated logging resource subscribe and forward to Discord, database, or any other backend.

### 3.4 17 Locale Files Always Parsed

All locale files are in the `fxmanifest` and loaded by FiveM at startup. Only one is used at runtime. The other 16 are wasted parse time and memory.

**Fix:** Load only the active locale at startup. Use a `@locale` convar to select the file dynamically via `LoadResourceFile` instead of shipping all 17 in the manifest.

### 3.5 Weapons Config is Dead Weight with OX Inventory (shared/config/weapons.lua — 1,108 lines)

`shared/config/weapons.lua` is loaded unconditionally on both server and client at every startup. When `ox_inventory` is active, **none of it is ever read at runtime.**

Here is what the override file does to every weapon method on `xPlayer`:

```lua
-- server/classes/overrides/oxinventory.lua
addWeapon          = function() return function() end end,
removeWeapon       = function() return function() end end,
hasWeapon          = function() return function() return false end end,
addWeaponComponent = function() return function() end end,
addWeaponAmmo      = function() return function() end end,
setWeaponTint      = function() return function() end end,
-- etc.
```

The loadout DB column and client restore logic are both fully gated:

```lua
-- server/main.lua:284
if not Config.CustomInventory then
    -- ESX.GetWeaponLabel() / ESX.GetWeapon() called here — never reached with OX
end
```

Result: 1,108 lines of weapon/component/tint/ammo definitions sit in memory doing nothing. OX Inventory manages all of that itself via its own item registry.

**Fix:** Remove `shared/config/weapons.lua` from `fxmanifest.lua` and delete `shared/functions.lua` entries for `ESX.GetWeapon`, `ESX.GetWeaponFromHash`, `ESX.GetWeaponLabel`, `ESX.GetWeaponComponent`, `ESX.GetWeaponList`. Verify no other resource in your server calls these functions directly (they should be using OX Inventory exports instead).

### 3.6 Mustache.js Bundled (html/js/mustache.min.js)

The default inventory UI uses Mustache.js as a template engine. If you are running `ox_inventory`, this file is never executed. It is loaded in the NUI page regardless.

**Fix:** Conditional script loading in `ui.html`, or remove the default inventory UI entirely if your server has committed to OX Inventory.

---

## 4. Architecture Problems

### 4.1 God Object: xPlayer (969 lines)

The `xPlayer` class does everything:
- Money management
- Inventory management
- Weapon/loadout management
- Job management
- Metadata storage
- Notification sending
- Database saving
- UI triggers

This makes it impossible to swap out any one subsystem without touching the class. Adding a new inventory system required an entire override file (`server/classes/overrides/oxinventory.lua`) that monkey-patches methods at runtime.

**Better pattern:** Separate concerns. `xPlayer` should be a thin identity/state object. Inventory, weapons, accounts should be injectable services.

### 4.2 Callback System is Homegrown

ESX implements its own RPC (request/response) system over raw network events with manual ID tracking and timeout management. `ox_lib` now ships `lib.callback` which is more robust, handles errors better, and is maintained.

**Fix:** Replace `ESX.TriggerServerCallback` / `ESX.RegisterServerCallback` with `lib.callback` from `ox_lib` and remove `client/modules/callback.lua` and `server/modules/callback.lua`.

### 4.3 Monolithic client/functions.lua (1,395 lines)

This file mixes:
- Player data access helpers
- Inventory notification helpers
- Weapon restoration logic
- Admin commands (noclip, TPM, etc.)
- Spawn handling
- NUI helpers
- UI menu system

None of these belong together. Large files are a maintenance burden and make it hard to understand what the framework's actual public API surface is.

**Fix:** Break into focused modules:
```
client/modules/player.lua        -- data access helpers
client/modules/inventory.lua     -- item/weapon helpers
client/modules/spawn.lua         -- spawn/restore logic
client/modules/ui.lua            -- notifications, menus
client/modules/admin.lua         -- or move to esx_admin
```

### 4.4 Sync Strategy: Polling vs. Events

Several systems use polling loops where events would be more appropriate:

```lua
-- death.lua — runs every 250ms for every client
while true do
    Wait(250)
    if IsPedDeadOrDying(PlayerPedId()) then
        -- handle death
    end
end
```

FiveM exposes `AddEventHandler("gameEventTriggered", ...)` which fires `CEventNetworkEntityDamage` natively when a ped dies. This eliminates the polling loop entirely.

### 4.5 Database Schema Ownership is Unclear

`es_extended.sql` contains tables for: core players, jobs, items, owned vehicles, billing (esx_billing), car dealer (esx_vehicleshop), addon accounts (esx_society), addon inventory (esx_society).

There is no clear line between "core schema" and "convenience schema". This makes it hard to know what you can safely drop when replacing a subsystem.

---

## 5. Performance Issues

### 5.1 GlobalState Job Count Replication

Every time any player's job changes, the entire `Core.JobsPlayerCount` table is written to `GlobalState` and replicated to every connected client. On a 64-player server with frequent job changes (deliveries, clocking in/out), this is constant replication overhead.

### 5.2 State Bag Listener on Every Client

```lua
-- events.lua
AddStateBagChangeHandler("vehicleProperties", nil, function(...)
    -- fires on every vehicle state bag change for every client
end)
```

The `nil` scope means this fires on every entity's state bag. On a busy server with many vehicles, this handler fires constantly. It should be scoped to specific entities when possible.

### 5.3 Database Auto-Save Interval

```lua
-- server/main.lua
SetInterval(function()
    for _, xPlayer in pairs(ESX.Players) do
        xPlayer.save()
    end
end, 600000) -- every 10 minutes
```

All online players are saved simultaneously every 10 minutes. On large servers this creates a burst of DB writes at the interval boundary. A staggered save (spread over the interval window) would flatten the load spike.

### 5.4 JSON Columns Decoded on Every Property Access

`accounts`, `inventory`, `loadout`, `metadata` are stored as JSON in MySQL and decoded on load into Lua tables. This is fine on load. However, `xPlayer.save()` re-encodes them to JSON every save cycle even if nothing changed. There is no dirty-flag to skip unchanged fields.

---

## 6. Security Gaps

### 6.1 Command Argument Injection

Admin commands that build strings from player input (job names, coordinates) pass them directly to DB queries through OxMySQL's parameterized API — that part is safe. However, the same strings are passed back to clients in notification messages with no sanitization. A malicious admin could craft job names with NUI injection payloads.

### 6.2 GetInvokingResource() is Not Enough

Events marked as secure use `GetInvokingResource()` to check the calling resource. This prevents random external resources from triggering internal events, but it does not validate the `source` (player server ID) beyond a nil check. A compromised or malicious resource listed in the manifest can still spoof calls.

### 6.3 Callback Source Not Validated

```lua
-- server/modules/callback.lua
ESX.RegisterServerCallback("some:callback", function(source, cb, ...)
    -- source is truested as the requesting player
    -- no secondary check that source matches the original requester
end)
```

The callback system does not re-validate that the `source` responding to a callback is the same client that originally requested it. This is generally hard to exploit but is worth noting.

---

## 7. Specific Improvement Recommendations

### Priority 1 — Remove / Delete

- [ ] **Delete `shared/config/weapons.lua`** — 1,108 lines, never read when OX Inventory is active. Also remove `ESX.GetWeapon`, `ESX.GetWeaponFromHash`, `ESX.GetWeaponLabel`, `ESX.GetWeaponComponent`, `ESX.GetWeaponList` from `shared/functions.lua` and the `weapons.lua` entry from `fxmanifest.lua`
- [ ] Delete `server/migration/` folder entirely
- [ ] Remove dead event stubs (`esx:addWeapon`, `esx:removeWeapon`) from `events.lua`
- [ ] Remove `billing` and `cardealer_vehicles` tables from `es_extended.sql`
- [ ] Remove `skin` field from `xPlayer` and DB queries — let skinchanger own it
- [ ] Delete `html/js/mustache.min.js` and default inventory NUI if using OX Inventory
- [ ] Remove NUI chunking wrapper (`wrapper.lua` / `wrapper.js`) after testing

### Priority 2 — Extract / Separate

- [ ] Move admin commands out of core into a standalone `esx_admin` resource
- [ ] Move Discord logging into a dedicated logging resource, emit events from core
- [ ] Move pickup system into an optional module or separate resource
- [ ] Split `client/functions.lua` (1,395 lines) into focused modules

### Priority 3 — Replace / Modernise

- [ ] Replace homegrown callback system with `lib.callback` from ox_lib
- [ ] Replace death polling loop with `gameEventTriggered` / `CEventNetworkEntityDamage`
- [ ] Replace GlobalState job count replication with on-demand server callbacks
- [ ] Replace full locale file loading with single-locale lazy load
- [ ] Add dirty-flag to `xPlayer.save()` to skip unchanged JSON columns

### Priority 4 — Refactor

- [ ] Decompose `xPlayer` god object — separate inventory, weapons, accounts into services
- [ ] Clarify schema ownership — annotate which tables in `es_extended.sql` belong to external resources
- [ ] Stagger the 10-minute database auto-save across the interval window
- [ ] Scope the state bag handler to specific vehicle entities, not global

---

## 8. Quick Wins (Low Effort)

These can be done in under an hour each and improve things immediately:

1. **Delete migration folder** — safe, no runtime risk
2. **Delete removed event stubs** — remove ~20 lines from `events.lua`
3. **Remove `billing` / `cardealer_vehicles` from SQL** — edit one file, no code changes
4. **Add `Config.EnableDefaultInventory` flag** — skip pickup system init when using OX Inventory without touching the code structure
5. **Add staggered save** — change the save interval loop to add a small random `Wait()` per player
6. **Document the actual hard deps at the top of `fxmanifest.lua`** — comment block listing what is truly required vs optional
7. **Delete ox_lib shim from `imports.lua`** — make ox_lib a declared hard dependency and remove the 346-line fallback
8. **Delete `shared/config/weapons.lua` + remove its 5 helper functions from `shared/functions.lua`** — biggest single dead-weight cut if you are on OX Inventory. Grep your other resources for `ESX.GetWeapon` calls first to make sure nothing else relies on it

---

*This document reflects the state of the codebase as reviewed. ESX upstream is no longer maintained — these improvements are for a maintained fork.*
