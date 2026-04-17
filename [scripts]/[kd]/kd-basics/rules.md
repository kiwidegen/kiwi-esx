# kd-basics — Development Rules

---

## Structure

Every module MUST have:
- `fxmanifest.lua`
- `client/` scripts
- `server/` scripts
- `shared/config.lua` (or per-module config)

**Never hardcode values inside logic files.**

---

## Server Security

MUST validate on the server:
- Money transactions
- Item ownership
- Job checks

**Never trust client triggers — `TriggerServerEvent` is unsafe by default.**

---

## Event Protection

Every `RegisterNetEvent` MUST:
- Check `source`
- Validate all parameters

Never allow raw unprotected events like:
```lua
-- BAD
RegisterNetEvent('giveMoney')
AddEventHandler('giveMoney', function(amount)
    -- no checks
end)
```

---

## Performance

Never use:
```lua
while true do
    Wait(0) -- hard no
end
```

Use `Wait(200)` minimum for logic loops. Use `Wait(500+)` where responsiveness allows.
Distance checks must be optimised — calculate once, sleep between checks.

---

## State Bags

Use state bags wherever possible instead of polling loops or repeated native calls.

- Prefer `LocalPlayer.state:set(key, value, false)` for client-only state
- Prefer `Player(source).state:set(key, value, true)` for server-synced state
- Use `AddStateBagChangeHandler` to react to state changes — event-driven, zero poll cost
- Never poll for state that could be tracked via a state bag change

---

## Config

Everything adjustable goes in config:
- Prices
- Locations
- Timers
- Model lists

**Never edit core logic for simple value changes.**

---

## Console

On `ensure kd-basics`:
- 0 errors
- 0 spam warnings

If it errors on start — it doesn't ship.

---

## Dependencies

Must confirm on start:
- `ox_lib`
- `es_extended`
- `ox_inventory` (where needed)

If a dependency is missing — script should not start.

---

## Exploit Testing

Before any module ships, try to break it:
- Spam the events
- Trigger without the required job
- Modify client-side values

**If it works → fix it.**

---

## UI / UX

- Use `ox_lib` exclusively for notifications, progress bars, context menus
- No notification spam
- Timers must feel smooth (prefer 2.5s / 5s feedback loops)

---

## Integration

Scripts must connect with:
- `ox_inventory` for items
- ESX for jobs/money
- Economy — nothing is free

**Scripts should not feel standalone.**

---

## Auto-Fail Conditions

Do NOT ship if ANY of these are true:

- Console errors on start
- Client can give themselves money or items
- Any `Wait(0)` infinite loop
- Hardcoded values in logic files
- No config
- No server-side validation

