---@diagnostic disable: undefined-global
-- Locales for drp-apartments (ESX Version)
-- Compatible with ox_lib locale system

local Translations = {
    error = {
        to_far_from_door = 'You are too far away from the doorbell',
        nobody_home = 'There is nobody home',
        nobody_at_door = 'There is nobody at the door',
        no_apartment = 'You do not own an apartment',
        already_inside = 'You are already inside an apartment',
        not_owner = 'You do not own this apartment',
    },
    success = {
        receive_apart = 'You received an apartment',
        changed_apart = 'You moved to a new apartment',
        door_opened = 'Door opened for visitor',
        stash_opened = 'Stash opened',
    },
    info = {
        at_the_door = 'Someone is at the door!',
        ringing_doorbell = 'Ringing doorbell...',
        entering_apartment = 'Entering apartment...',
        leaving_apartment = 'Leaving apartment...',
    },
    text = {
        options = '[E] Apartment Options',
        enter = 'Enter Apartment',
        ring_doorbell = 'Ring Doorbell',
        logout = 'Logout Character',
        change_outfit = 'Change Outfit',
        open_stash = 'Open Stash',
        move_here = 'Move Here',
        open_door = 'Open Door',
        leave = 'Leave Apartment',
        close_menu = 'Close Menu',
        tennants = 'Tenants',
        select_tenant = 'Select a tenant to ring',
        apartment_menu = 'Apartment Menu',
        entrance_menu = 'Entrance Options',
        exit_menu = 'Exit Options',
    },
}

-- Compatibility function for ox_lib locale system
function _L(key)
    local keys = {}
    for k in string.gmatch(key, "[^.]+") do
        table.insert(keys, k)
    end

    local value = Translations
    for _, k in ipairs(keys) do
        value = value[k]
        if not value then return key end
    end

    return value or key
end

-- Legacy compatibility
Lang = Lang or {
    t = function(self, key)
        return _L(key)
    end
}