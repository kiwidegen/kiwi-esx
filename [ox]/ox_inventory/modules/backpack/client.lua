if not lib then return end

local Items = require 'modules.items.client'
local backpackProp = nil
local currentBackpackModel = nil

local function deleteBackpack()
    if backpackProp and DoesEntityExist(backpackProp) then
        DeleteEntity(backpackProp)
    end
    backpackProp = nil
    currentBackpackModel = nil
end

local function updateBackpackVisual()
    local ped = cache.ped
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    local backpackItem = nil

    if PlayerData.inventory then
        for i = 1, 5 do
            local item = PlayerData.inventory[i]
            if item and item.name == 'backpack' then
                backpackItem = item
                break
            end
        end
    end

    if not backpackItem then
        deleteBackpack()
        return
    end

    local itemData = Items[backpackItem.name]
    if not itemData or not itemData.client or not itemData.client.backpackProp then
        deleteBackpack()
        return
    end

    local model = itemData.client.backpackProp
    local hash = type(model) == 'number' and model or joaat(model)

    if currentBackpackModel == hash then return end

    deleteBackpack()

    local ok, result = pcall(lib.requestModel, hash, 500)
    if not ok or not result then return end

    local pedCoords = GetEntityCoords(ped)
    backpackProp = CreateObject(hash, pedCoords.x, pedCoords.y, pedCoords.z, false, true, true)
    currentBackpackModel = hash

    local bone = itemData.client.backpackBone or 24818
    local pos = itemData.client.backpackPos or vec3(0.08, -0.15, -0.05)
    local rot = itemData.client.backpackRot or vec3(0.0, -90.0, 180.0)
    local boneIndex = GetPedBoneIndex(ped, bone)

    AttachEntityToEntity(backpackProp, ped, boneIndex, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 2, true)
    SetModelAsNoLongerNeeded(hash)
end

AddEventHandler('ox_inventory:updateInventory', function()
    updateBackpackVisual()
end)

CreateThread(function()
    while not PlayerData.loaded do Wait(100) end
    Wait(1000)
    updateBackpackVisual()
end)

lib.onCache('ped', function()
    deleteBackpack()
    Wait(500)
    updateBackpackVisual()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        deleteBackpack()
    end
end)
