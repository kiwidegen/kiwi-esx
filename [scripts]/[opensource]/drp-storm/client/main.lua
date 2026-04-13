local onCooldown = false
local cooldownEndTime = 0
local cooldownThread = nil

-- Cached natives (updated periodically instead of every frame)
local cache = {
    ped = PlayerPedId(),
    lastUpdate = 0
}

--- Update cache periodically
---@return nil
local function UpdateCache()
    local currentTime = GetGameTimer()
    if currentTime - cache.lastUpdate >= 1000 then
        cache.ped = PlayerPedId()
        cache.lastUpdate = currentTime
    end
end

--- Start cooldown enforcement thread (only when needed)
---@return nil
local function StartCooldownThread()
    if cooldownThread then return end

    cooldownThread = true
    CreateThread(function()
        local notificationShown = false
        local unarmedHash <const> = `WEAPON_UNARMED`

        while cooldownThread and onCooldown do
            UpdateCache()
            local currentWeapon = GetSelectedPedWeapon(cache.ped)

            -- Force unequip any weapon (client-side enforcement)
            if currentWeapon ~= unarmedHash then
                SetCurrentPedWeapon(cache.ped, unarmedHash, true)

                -- Show warning only once per cooldown session
                if not notificationShown then
                    lib.notify({
                        title = 'Cooldown Active',
                        description = 'You cannot use weapons right now',
                        type = 'error',
                        duration = 2000
                    })
                    notificationShown = true
                end
            end

            -- Disable melee attacks
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            DisableControlAction(0, 143, true) -- Melee Block

            -- Disable weapon wheel
            DisableControlAction(0, 37, true) -- Weapon Wheel

            Wait(0)
        end

        cooldownThread = nil
    end)
end

--- Stop cooldown enforcement thread
---@return nil
local function StopCooldownThread()
    cooldownThread = nil
end

--- Start cooldown (CLIENT DISPLAY ONLY - Server controls logic)
---@param duration number Cooldown duration in seconds
local function StartCooldown(duration)
    onCooldown = true
    cooldownEndTime = GetGameTimer() + (duration * 1000)

    -- Show notification with countdown
    local notification = Config.Notifications.cooldownActive
    lib.notify({
        id = 'combat_cooldown',
        title = notification.title,
        description = notification.description,
        type = notification.type,
        icon = notification.icon,
        iconColor = notification.iconColor,
        countdown = duration,
        duration = duration * 1000
    })

    -- Remove any equipped weapons
    UpdateCache()
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)

    -- Start enforcement thread
    StartCooldownThread()

    -- Wait for cooldown to expire
    CreateThread(function()
        while onCooldown do
            local remaining = cooldownEndTime - GetGameTimer()

            if remaining <= 0 then
                onCooldown = false
                StopCooldownThread()

                -- Show expiration notification
                lib.notify(Config.Notifications.cooldownExpired)
                break
            end

            Wait(1000)
        end
    end)
end

--- Remove cooldown (CLIENT DISPLAY ONLY - Server controls logic)
local function RemoveCooldown()
    onCooldown = false
    cooldownEndTime = 0
    StopCooldownThread()
end

--- Check if player is on cooldown
---@return boolean isOnCooldown Whether player is currently on cooldown
local function IsOnCooldown()
    if not onCooldown then return false end

    local remaining = cooldownEndTime - GetGameTimer()
    if remaining <= 0 then
        onCooldown = false
        StopCooldownThread()
        return false
    end

    return true
end

-- Events from server
RegisterNetEvent('drp-cooldown:client:startCooldown', function(duration)
    StartCooldown(duration)
end)

RegisterNetEvent('drp-cooldown:client:removeCooldown', function()
    RemoveCooldown()
end)

-- Check cooldown on resource start (optimized with shorter wait)
CreateThread(function()
    Wait(500) -- Wait for server to be ready (reduced from 1000ms)

    local remaining = lib.callback.await('drp-cooldown:server:checkCooldown', false)
    if remaining and remaining > 0 then
        StartCooldown(remaining)
    end
end)

-- Debug: Check current weapon (triggered by /checkweapon command)
RegisterNetEvent('drp-cooldown:client:checkCurrentWeapon', function()
    UpdateCache() -- Ensure cache is fresh
    local weaponHash = GetSelectedPedWeapon(cache.ped)

    if weaponHash == `WEAPON_UNARMED` then
        lib.notify({
            title = 'Weapon Debug',
            description = 'You are not holding any weapon',
            type = 'info'
        })
        return
    end

    -- Send weapon info to server for validation check
    TriggerServerEvent('drp-cooldown:server:validateWeapon', weaponHash)
end)

RegisterNetEvent('drp-cooldown:client:showWeaponInfo', function(weaponHash, weaponGroup, isBlocked)
    lib.notify({
        title = 'Weapon Debug',
        description = string.format(
            'Hash: 0x%08X\nGroup: 0x%08X\nTriggers Cooldown: %s',
            weaponHash,
            weaponGroup,
            isBlocked and 'YES' or 'NO'
        ),
        type = isBlocked and 'error' or 'success',
        duration = 10000
    })
end)

-- Export functions for other resources
exports('IsOnCooldown', IsOnCooldown)
exports('GetCooldownRemaining', function()
    if not IsOnCooldown() then return 0 end
    return math.floor((cooldownEndTime - GetGameTimer()) / 1000)
end)
