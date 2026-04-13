local policeWeaponHashes = {
    [GetHashKey('WEAPON_TACTICALRIFLE')] = true,
    [GetHashKey('WEAPON_PISTOL')] = true,
    [GetHashKey('WEAPON_CARBINERIFLE')] = true,
    [GetHashKey('WEAPON_STUNGUN')] = true,
    [GetHashKey('WEAPON_NIGHTSTICK')] = true,
    [GetHashKey('WEAPON_PUMPSHOTGUN')] = true
}

local lastWeapon = GetHashKey('WEAPON_UNARMED')
local isMonitoring = false

-- Only start monitoring when player has a restricted weapon equipped
local function startWeaponMonitor()
    if isMonitoring then return end
    isMonitoring = true

    CreateThread(function()
        while isMonitoring do
            Wait(1000)

            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)

            if weapon ~= lastWeapon then
                lastWeapon = weapon

                if weapon ~= GetHashKey('WEAPON_UNARMED') and policeWeaponHashes[weapon] then
                    TriggerServerEvent('weapon:checkAuth', weapon)
                end
            end

            -- Stop monitoring if player is unarmed
            if weapon == GetHashKey('WEAPON_UNARMED') then
                isMonitoring = false
            end
        end
    end)
end

-- Use ox_inventory hook instead of constant checking
AddEventHandler('ox_inventory:itemCount', function(itemName, count)
    if count > 0 then
        local hash = GetHashKey(itemName)
        if policeWeaponHashes[hash] then
            startWeaponMonitor()
        end
    end
end)

-- Event-driven weapon check on equip
AddEventHandler('ox_inventory:currentWeapon', function(currentWeapon)
    if currentWeapon then
        local hash = GetHashKey(currentWeapon.name)
        if policeWeaponHashes[hash] then
            startWeaponMonitor()
            TriggerServerEvent('weapon:checkAuth', hash)
        end
    else
        lastWeapon = GetHashKey('WEAPON_UNARMED')
    end
end)

RegisterNetEvent('weapon:forceRemove', function()
    local ped = PlayerPedId()
    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
    lastWeapon = GetHashKey('WEAPON_UNARMED')
    isMonitoring = false
end)
