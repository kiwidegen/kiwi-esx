-- ─────────────────────────────────────────────────────────────────────────────
-- ESX shared-object bootstrap
-- Third-party resources load this via:
--   shared_scripts { '@es_extended/imports.lua' }
-- ─────────────────────────────────────────────────────────────────────────────

ESX = exports['es_extended']:getSharedObject()
ESX.currentResourceName = GetCurrentResourceName()

if not IsDuplicityVersion() then
    -- ── Client ───────────────────────────────────────────────────────────────

    -- Keep PlayerData in sync with server-push events
    AddEventHandler('esx:setPlayerData', function(key, val)
        if GetInvokingResource() == 'es_extended' then
            ESX.PlayerData[key] = val
        end
    end)

    -- Server sends playerData before the ped exists — just store it.
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        ESX.PlayerData = xPlayer
    end)

    -- Fires after es_extended has fully spawned the ped.
    AddEventHandler('esx:onPlayerSpawn', function()
        ESX.PlayerData.ped  = PlayerPedId()
        ESX.PlayerData.dead = false
        ESX.PlayerLoaded    = true
        -- Live coords accessor so ESX.PlayerData.coords always reflects position
        setmetatable(ESX.PlayerData, {
            __index = function(self, key)
                if key == 'coords' then
                    return GetEntityCoords(PlayerPedId())
                end
            end,
        })
    end)

    RegisterNetEvent('esx:onPlayerLogout')
    AddEventHandler('esx:onPlayerLogout', function()
        ESX.PlayerLoaded = false
        ESX.PlayerData   = {}
    end)
else
    -- ── Server ───────────────────────────────────────────────────────────────

    -- ESX.Player(src) — convenience wrapper for resources doing ESX.Player(src):getJob()
    function ESX.Player(src)
        if type(src) ~= 'number' then
            src = ESX.GetPlayerIdFromIdentifier(src)
            if not src then return end
        end
        return ESX.GetPlayerFromId(src)
    end
end
