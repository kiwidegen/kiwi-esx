---@type table ESX shared object
ESX = exports['es_extended']:getSharedObject()

---@type table ox_inventory exports
local ox_inventory = exports.ox_inventory

--- Cooldowns table for spawn command
---@type table<number, number>
Cooldowns = {}

--- Job options cache
---@type table[]|nil
JobOptionsCache = nil

--- Cleanup cooldowns on player disconnect
AddEventHandler('playerDropped', function()
    Cooldowns[source] = nil
end)

--- Check and remove event weapons when player loads (handles disconnected players)
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    -- Access the eventWeaponRecipients table from functions.lua
    -- We need to use a getter function for this
    CheckAndRemoveEventWeapons(playerId, xPlayer.identifier)
end)
