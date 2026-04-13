-- Module guard
if not ExtrasConfig.Modules.DeathNotifications then return end

--============================================================
--  DEATH NOTIFICATIONS MODULE
--============================================================

---@type number Cached player ped
local cachedPed = PlayerPedId()

-- Update cached ped when it changes
AddEventHandler('esx:playerPedChanged', function(newPed)
    cachedPed = newPed
end)

--- Common environmental death weapon hashes
---@type table<number, string>
local deathCauses <const> = {
    [-1553120962] = "ran yourself over",
    [-842959696] = "fell to your death",
    [539292904] = "fell to your death",
    [341774354] = "drowned",
    [-10959621] = "drowned",
    [148160082] = "were killed by a Cougar",
    [-100946242] = "were mauled by a dog",
    [1223143800] = "were killed by a boar",
    [-1716189206] = "died in a knife fight",
    [615608432] = "were molotoved",
    [883325847] = "were burned to death",
    [GetHashKey("WEAPON_RUN_OVER_BY_CAR")] = "were run over",
    [GetHashKey("WEAPON_RAMMED_BY_CAR")] = "were run over",
    [GetHashKey("WEAPON_FIRE")] = "burned to death",
}

--- Determine death cause from weapon hash
---@param weaponHash number Weapon hash that caused death
---@param attacker number Entity that caused death
---@param victim number Victim entity
---@return string deathMessage Death cause description
local function getDeathCause(weaponHash, attacker, victim)
    -- Check if suicide (attacker is victim or invalid)
    local isSuicide = attacker == victim or attacker == 0 or not IsEntityAPed(attacker)

    -- Check for known environmental deaths
    if deathCauses[weaponHash] then
        return deathCauses[weaponHash]
    end

    -- Get weapon label from ESX
    local weaponData = ESX.GetWeaponFromHash(weaponHash)
    local weaponName = weaponData?.label or "unknown means"

    -- Detect specific death types
    if weaponHash == GetHashKey("WEAPON_EXPLOSION") then
        return isSuicide and "blew yourself up" or "died in an explosion"
    end

    if weaponHash == GetHashKey("WEAPON_FALL") then
        return "fell to your death"
    end

    if weaponHash == GetHashKey("WEAPON_DROWNING") or weaponHash == GetHashKey("WEAPON_DROWNING_IN_VEHICLE") then
        return "drowned"
    end

    -- Vehicle deaths
    local vehicleHashes = {
        [GetHashKey("VEHICLE_WEAPON_ROTORS")] = true,
        [GetHashKey("VEHICLE_WEAPON_PLAYER_LASER")] = true,
    }

    if vehicleHashes[weaponHash] then
        return "died in a vehicle incident"
    end

    -- Fire deaths
    if weaponHash == GetHashKey("WEAPON_FIRE") or weaponHash == GetHashKey("WEAPON_MOLOTOV") or weaponHash == GetHashKey("WEAPON_PETROLCAN") then
        return "burned to death"
    end

    -- Suicide with weapon
    if isSuicide and weaponData then
        return "killed yourself with a " .. weaponName
    end

    -- Starvation/bleed out (no weapon, no attacker)
    if weaponHash == 0 or weaponHash == GetHashKey("WEAPON_UNARMED") then
        return "died from injuries or starvation"
    end

    -- Generic environmental death
    if isSuicide then
        return "killed yourself"
    end

    return "died from " .. weaponName
end

--- Notify when you are killed
AddEventHandler("gameEventTriggered", function(event, data)
    if event ~= "CEventNetworkEntityDamage" then
        return
    end

    local victim, victimDied = data[1], data[6]
    local attacker = data[2]
    local weapon = data[7]

    if victim ~= cachedPed or victimDied == 0 then
        return
    end

    -- Check if killed by another player
    if IsEntityAPed(attacker) and IsPedAPlayer(attacker) and attacker ~= cachedPed then
        local killerServerIndex = NetworkGetPlayerIndexFromPed(attacker)
        local dist = #(GetEntityCoords(cachedPed) - GetEntityCoords(attacker))
        local weaponData = ESX.GetWeaponFromHash(weapon)

        lib.notify({
            description = string.format(
                "You were killed by player %s with %s (Distance: %sm)",
                GetPlayerServerId(killerServerIndex),
                weaponData?.label or "unknown weapon",
                math.floor(dist)
            ),
            type = 'error'
        })
    else
        -- Self-inflicted or environmental death
        local deathMessage = getDeathCause(weapon, attacker, victim)

        lib.notify({
            description = "You " .. deathMessage,
            type = 'error'
        })
    end
end)

--- Notify when you kill another player
AddEventHandler("gameEventTriggered", function(event, data)
    if event ~= "CEventNetworkEntityDamage" then
        return
    end

    local victim, victimDied = data[1], data[6]
    local attacker = data[2]
    local weapon = data[7]

    if attacker ~= cachedPed or victimDied == 0 then
        return
    end

    if not IsEntityAPed(victim) or not IsPedAPlayer(victim) then
        return
    end

    local victimServerIndex = NetworkGetPlayerIndexFromPed(victim)
    local dist = #(GetEntityCoords(cachedPed) - GetEntityCoords(victim))
    local weaponData = ESX.GetWeaponFromHash(weapon)

    lib.notify({
        description = string.format(
            "You killed player %s with %s (Distance: %sm)",
            GetPlayerServerId(victimServerIndex),
            weaponData?.label or "unknown weapon",
            math.floor(dist)
        ),
        type = 'inform'
    })
end)

--- Disable inventory open controls (moved to event-based check)
-- Only disable when actually needed, not every frame
-- These controls are typically handled by inventory resource anyway
