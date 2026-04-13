---@class ServerConfig
Config = Config or {}

-- Cooldown duration in seconds
Config.CooldownDuration = 300 -- 5 minutes (300 seconds)

-- Ace permission for admin commands
Config.AdminPermission = 'group.admin' -- Change to your permission system

-- Weapon groups that trigger cooldown (SERVER-SIDE ONLY - NOT EXPOSED TO CLIENT)
-- This approach works with ALL weapons including custom ones
Config.BlockedWeaponGroups = {
    -- Firearms
    [`GROUP_PISTOL`] = true,
    [`GROUP_SMG`] = true,
    [`GROUP_RIFLE`] = true,
    [`GROUP_SHOTGUN`] = true,
    [`GROUP_SNIPER`] = true,
    [`GROUP_MG`] = true,
    [`GROUP_STUNGUN`] = true,

    -- Melee
    [`GROUP_MELEE`] = true,
    [`GROUP_UNARMED`] = true,
}

-- Optional: Specific weapons to exclude even if in a blocked group
Config.ExcludedWeapons = {
    -- Example: Exclude specific weapons that shouldn't trigger cooldown
    -- [`WEAPON_STUNGUN`] = true,
}

-- Optional: Specific weapons to include even if not in a blocked group
Config.IncludedWeapons = {
    -- Example: Include specific custom weapons
    -- [`WEAPON_CUSTOM_GUN`] = true,
}

--- Check if weapon triggers cooldown (SERVER-SIDE ONLY)
--- Works with ALL weapons including custom guns if they're properly registered with weapon groups
---@param weaponHash number Weapon hash to check
---@return boolean shouldTrigger Whether the weapon triggers cooldown
function Config.IsWeaponBlocked(weaponHash)
    if not weaponHash or weaponHash == 0 then return false end

    -- Check if weapon is specifically excluded
    if Config.ExcludedWeapons[weaponHash] then
        return false
    end

    -- Check if weapon is specifically included
    if Config.IncludedWeapons[weaponHash] then
        return true
    end

    -- Get weapon group (works with custom weapons)
    local weaponGroup = GetWeapontypeGroup(weaponHash)

    -- Check if weapon group is blocked
    return Config.BlockedWeaponGroups[weaponGroup] == true
end
