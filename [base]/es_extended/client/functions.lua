-- ─────────────────────────────────────────────────────────────────────────────
-- Client helpers — keep this lean.
-- For inventory use exports.ox_inventory, for UI use lib.*, for targeting use
-- exports.ox_target.
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

function ESX.GetPlayerData()
    return ESX.PlayerData
end

function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val
    if val ~= current then
        TriggerEvent('esx:setPlayerData', key, val, current)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Thin shims — these exist only so old resources don't hard-error.
-- New resources should call lib.notify / lib.callback / ox_inventory directly.
-- ─────────────────────────────────────────────────────────────────────────────

function ESX.ShowNotification(msg, notifyType, _length, title)
    lib.notify({
        title       = title or 'Notification',
        description = msg,
        type        = notifyType or 'inform',
    })
end

function ESX.ShowHelpNotification(msg)
    lib.showTextUI(msg)
end

-- lib.callback shim for resources still using the old callback pattern.
function ESX.TriggerServerCallback(name, cb, ...)
    lib.callback(name, false, cb, ...)
end

-- SecureNetEvent shim — registers a net event that only fires when source is a real player.
-- Third-party resources (kd-hud etc.) call this instead of RegisterNetEvent directly.
function ESX.SecureNetEvent(name, func)
    RegisterNetEvent(name)
    AddEventHandler(name, function(...)
        if source == '' or source == 0 then return end
        func(...)
    end)
end
