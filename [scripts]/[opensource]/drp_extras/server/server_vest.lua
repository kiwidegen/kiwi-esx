-- Module guard (server-side check)
if not Config or not ExtrasConfig.Modules or not ExtrasConfig.Modules.VestEquip then return end

--============================================================
--  VEST EQUIP SERVER MODULE
--============================================================
--
--  NOTE: Vest functionality is now handled by ox_inventory.
--  Vest items (vest, vestpolice, heavyvest) are registered in:
--  resources/[ox]/ox_inventory/modules/items/client.lua
--
--  This module is kept for backwards compatibility with any
--  external scripts that may still trigger these events.
--============================================================

--- Remove vest item from inventory
---@param item string Item name
RegisterNetEvent("drp_extras:removevest", function(item)
    local source = source

    -- SECURITY: Only allow removing armor items
    local validItems = {
        'vest', 'vestpolice', 'heavyvest',
        'light_armor', 'heavy_armor'
    }

    local isValid = false
    for _, validItem in ipairs(validItems) do
        if item == validItem then
            isValid = true
            break
        end
    end

    if not isValid then return end

    -- Remove item via ox_inventory
    exports.ox_inventory:RemoveItem(source, item, 1)
end)
