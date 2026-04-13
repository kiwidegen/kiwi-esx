-- Module guard
if not ExtrasConfig.Modules.RemoveEntities then return end

--============================================================
--  ENTITY REMOVAL MODULE (Map-Wide Scanner)
--  Scans around player and removes specified props
--============================================================

Core.DebugPrint('RemoveEntities module loaded')

local cfg = ExtrasConfig.RemoveEntities
local deletedEntities = {}

--- Convert string to hash
---@param v string|number Hash value
---@return number hash Converted hash
local function toHash(v)
    if type(v) == 'number' then return v end
    if type(v) == 'string' then return GetHashKey(v) end
    return 0
end

--- Build hash list from config
---@return number[] hashes Array of prop hashes to remove
local function buildHashList()
    local hashes = {}
    local props = cfg.PropsToRemove or {}

    for i = 1, #props do
        local hash = toHash(props[i])
        if hash ~= 0 then
            hashes[#hashes + 1] = hash
        end
    end

    return hashes
end

--- Safely delete entity with network control
---@param ent number Entity handle
---@return boolean success Whether deletion was successful
local function deleteEntitySafe(ent)
    if not DoesEntityExist(ent) then return false end

    -- Track this entity as deleted
    if cfg.TrackDeleted then
        deletedEntities[ent] = true
    end

    -- NOTE: SetEntityAsMissionEntity() removed - it fills mission entity pool (256 limit)
    -- DeleteEntity() and SetEntityAsNoLongerNeeded() are sufficient for prop removal

    -- Request network control if networked
    if NetworkGetEntityIsNetworked(ent) and not NetworkHasControlOfEntity(ent) then
        NetworkRequestControlOfEntity(ent)
        local tries = 0
        while tries < 10 and not NetworkHasControlOfEntity(ent) do
            Wait(0)
            tries = tries + 1
        end
    end

    -- Delete the entity
    DeleteEntity(ent)
    SetEntityAsNoLongerNeeded(ent)

    -- Verify deletion
    if DoesEntityExist(ent) then
        DeleteObject(ent)
    end

    return not DoesEntityExist(ent)
end

--- Scan area around player and remove matching props
---@param hashes number[] Array of prop hashes to remove
---@return number count Number of entities deleted
local function scanAndRemove(hashes)
    local playerPos = GetEntityCoords(PlayerPedId())
    local deletedCount = 0

    for i = 1, #hashes do
        local hash = hashes[i]

        -- Get closest object of this type within scan radius
        local obj = GetClosestObjectOfType(
            playerPos.x,
            playerPos.y,
            playerPos.z,
            cfg.ScanRadius or 100.0,
            hash,
            false,
            false,
            false
        )

        -- Delete if found and not already deleted
        if obj ~= 0 and DoesEntityExist(obj) then
            if not (cfg.TrackDeleted and deletedEntities[obj]) then
                if deleteEntitySafe(obj) then
                    deletedCount = deletedCount + 1
                end
            end
        end
    end

    return deletedCount
end

-- Build hash list from config
local PropHashes = buildHashList()

if #PropHashes == 0 then
    Core.DebugPrint('No props configured for removal')
    return
end

Core.DebugPrint(string.format('Loaded %d prop types to remove', #PropHashes))

--============================================================
--  MAIN SCANNING THREAD
--============================================================
CreateThread(function()
    -- Wait significantly longer for world to fully load and stabilize
    -- This prevents pool overflow during startup when many systems are initializing
    Wait(30000) -- 30 seconds instead of 5

    Core.DebugPrint('Starting map-wide prop removal scanner...')

    while true do
        local deleted = scanAndRemove(PropHashes)

        if deleted > 0 then
            Core.DebugPrint(string.format('Removed %d entities', deleted))
        end

        Wait(cfg.CheckInterval or 10000)
    end
end)

--============================================================
--  CLEANUP
--============================================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deletedEntities = {}
    Core.DebugPrint('RemoveEntities module stopped')
end)
