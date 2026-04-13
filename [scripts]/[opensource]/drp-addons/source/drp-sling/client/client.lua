-- ESX Initialization
ESX = exports['es_extended']:getSharedObject()

---@class AttachedWeapon
---@field hash number Weapon hash
---@field handle number Entity handle

---@type table<string, AttachedWeapon> Currently attached weapon objects
local attached_weapons = {}

---@type table<integer, table> Hotbar items (slots 1-5)
local hotbar = {}

---@type 'Back'|'Front' Current sling position for firearms
local sling = "Back"

---@type boolean Whether player data is loaded
local playerLoaded = false

---@type boolean Whether player was in vehicle last check
local wasInVehicle = false

---@type table Cache for frequently used values
local cache = {
  playerId = PlayerId(),
  serverId = GetPlayerServerId(PlayerId()),
  ped = PlayerPedId()
}

--- Check if weapon hash exists in hotbar
---@param hash number Weapon hash to check
---@return boolean inHotbar Whether weapon is in hotbar
local function inHotbar(hash)
  for _, item in pairs(hotbar) do
    if item and item.name and SlingConfig.compatable_weapon_hashes[item.name] then
      local itemHash = GetHashKey(item.name)

      if SlingConfig.Debug then
        print(("[DEBUG] Checking hash %s against item %s (hash: %s)"):format(hash, item.name, itemHash))
      end

      if hash == itemHash then
        return true
      end
    end
  end
  return false
end

--- Attach weapon model to ped bone
---@param attachModel string|number Weapon model name or hash
---@param modelHash number Weapon hash
---@param boneNumber number Bone index to attach to
---@param x number X offset
---@param y number Y offset
---@param z number Z offset
---@param xR number X rotation
---@param yR number Y rotation
---@param zR number Z rotation
local function attachWeapon(attachModel, modelHash, boneNumber, x, y, z, xR, yR, zR)
  local model = type(attachModel) == 'number' and attachModel or GetHashKey(attachModel)
  RequestModel(model)

  local loadAttempts = 0
  while not HasModelLoaded(model) and loadAttempts < 50 do
    Wait(100)
    loadAttempts += 1

    if SlingConfig.Debug then
      print(("[DEBUG] Waiting for model %s to load (attempt %d)"):format(tostring(attachModel), loadAttempts))
    end
  end

  if not HasModelLoaded(model) then
    if SlingConfig.Debug then
      print(("[ERROR] Failed to load model %s after %d attempts"):format(tostring(attachModel), loadAttempts))
    end
    return
  end

  local bone = GetPedBoneIndex(cache.ped, boneNumber)
  local obj = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)

  attached_weapons[attachModel] = {
    hash = modelHash,
    handle = obj
  }

  AttachEntityToEntity(
    obj, cache.ped, bone,
    x, y, z,
    xR, yR, zR,
    true, true, false, false, 2, true
  )

  if SlingConfig.Debug then
    print(("[DEBUG] Attached weapon model %s (hash %s) to bone %d"):format(
      tostring(attachModel), tostring(modelHash), boneNumber))
  end
end

--- Refresh all weapon attachments based on current hotbar
local function refreshWeapons()
  local isInVehicle = IsPedInAnyVehicle(cache.ped, false)

  -- Remove all existing attachments
  for key, attached_object in pairs(attached_weapons) do
    if DoesEntityExist(attached_object.handle) then
      DeleteObject(attached_object.handle)

      if SlingConfig.Debug then
        print(("[DEBUG] Removed weapon model %s (hash: %s)"):format(key, attached_object.hash))
      end
    end
    attached_weapons[key] = nil
  end

  -- Don't attach weapons while in vehicle
  if isInVehicle then
    if SlingConfig.Debug then
      print("[DEBUG] Player in vehicle, skipping weapon attachment")
    end
    return
  end

  -- Reattach weapons from hotbar
  for slot, item in pairs(hotbar) do
    if item and item.name and SlingConfig.compatable_weapon_hashes[item.name] then
      local data = SlingConfig.compatable_weapon_hashes[item.name]
      local wep_model = data.model
      local wep_hash = data.hash
      local wep_type = data.type or "Firearm"
      local isEquipped = GetSelectedPedWeapon(cache.ped) == wep_hash

      if not isEquipped then
        local position
        if wep_type == "Melee" then
          position = "Back"
        elseif wep_type == "Pistol" then
          position = "Hip"
        else
          position = sling
        end

        if SlingConfig.Debug then
          print(("[DEBUG] Reattaching %s (model: %s, type: %s) to %s in slot %d"):format(
            item.name, wep_model, wep_type, position, slot))
        end

        local pos = SlingConfig.Positions[wep_type][position]
        attachWeapon(wep_model, wep_hash, pos.bone, pos.x, pos.y, pos.z,
          pos.x_rotation, pos.y_rotation, pos.z_rotation)
      elseif SlingConfig.Debug then
        print(("[DEBUG] Skipping attachment for %s (currently equipped in slot %d)"):format(item.name, slot))
      end
    end
  end
end

--- Update hotbar from ox_inventory
local function updateHotbar()
  local items = exports.ox_inventory:GetPlayerItems() or {}
  hotbar = {}

  for slot, item in pairs(items) do
    if slot >= 1 and slot <= 5 then
      hotbar[slot] = item
    end
  end

  if SlingConfig.Debug then
    print(("[DEBUG] Hotbar updated: %d items"):format(#hotbar))
    for slot, item in pairs(hotbar) do
      if item and item.name then
        print(("[DEBUG] Hotbar slot %d: %s (label: %s)"):format(
          slot, item.name, item.label or "unknown"))
      end
    end
  end
end

-- Wait for player to load
CreateThread(function()
  local timeout = GetGameTimer() + 15000

  while not playerLoaded do
    if exports.ox_inventory:GetPlayerItems() ~= nil or GetGameTimer() > timeout then
      playerLoaded = true

      if SlingConfig.Debug then
        print("[DEBUG] Player loaded (fallback), enabling sling functionality")
      end

      updateHotbar()
      break
    end

    if SlingConfig.Debug then
      print("[DEBUG] Waiting for playerLoaded or inventory data")
    end

    Wait(1000)
  end

  refreshWeapons()
end)

-- Handle vehicle enter/exit via game events
AddEventHandler("gameEventTriggered", function(name, args)
    if name == "CEventNetworkPlayerEnteredVehicle" then
        if SlingConfig.Debug then
            print("[DEBUG] Player entered vehicle, removing all weapon attachments")
        end
        refreshWeapons()
        wasInVehicle = true
    elseif name == "CEventNetworkPlayerLeftVehicle" then
        if SlingConfig.Debug then
            print(("[DEBUG] Player exited vehicle, restoring sling position: %s"):format(sling))
        end
        wasInVehicle = false
        refreshWeapons()
    end
end)

-- Main weapon management thread
CreateThread(function()
  while true do
    Wait(500)

    if not playerLoaded then
      goto continue
    end

    cache.ped = PlayerPedId()
    local isInVehicle = IsPedInAnyVehicle(cache.ped, false)

    updateHotbar()

    -- Handle vehicle enter/exit fallback
    if isInVehicle and not wasInVehicle then
      if SlingConfig.Debug then
        print("[DEBUG] Player entered vehicle, removing all weapon attachments")
      end

      refreshWeapons()
      wasInVehicle = true
    elseif not isInVehicle and wasInVehicle then
      if SlingConfig.Debug then
        print(("[DEBUG] Player exited vehicle, restoring sling position: %s"):format(sling))
      end

      wasInVehicle = false
      refreshWeapons()
    end

    -- Attach weapons if not in vehicle
    if not isInVehicle then
      for slot, item in pairs(hotbar) do
        if item and item.name and SlingConfig.compatable_weapon_hashes[item.name] then
          local data = SlingConfig.compatable_weapon_hashes[item.name]
          local wep_model = data.model
          local wep_hash = data.hash
          local wep_type = data.type or "Firearm"
          local isEquipped = GetSelectedPedWeapon(cache.ped) == wep_hash

          if not attached_weapons[wep_model] and not isEquipped then
            local position
            if wep_type == "Melee" then
              position = "Back"
            elseif wep_type == "Pistol" then
              position = "Hip"
            else
              position = sling
            end

            if SlingConfig.Debug then
              print(("[DEBUG] Attaching %s (model: %s, type: %s) to %s in slot %d"):format(
                item.name, wep_model, wep_type, position, slot))
            end

            local pos = SlingConfig.Positions[wep_type][position]
            attachWeapon(wep_model, wep_hash, pos.bone, pos.x, pos.y, pos.z,
              pos.x_rotation, pos.y_rotation, pos.z_rotation)
          elseif SlingConfig.Debug then
            print(("[DEBUG] Skipping %s (already attached: %s, equipped: %s, slot: %d)"):format(
              item.name,
              attached_weapons[wep_model] and "true" or "false",
              isEquipped and "true" or "false",
              slot))
          end
        end
      end
    end

    -- Remove weapons that are equipped, not in hotbar, or player is in vehicle
    for key, attached_object in pairs(attached_weapons) do
      local isEquipped = GetSelectedPedWeapon(cache.ped) == attached_object.hash

      if isEquipped or not inHotbar(attached_object.hash) or isInVehicle then
        if SlingConfig.Debug then
          print(("[DEBUG] Removing model %s (hash: %s, equipped: %s, in hotbar: %s, in vehicle: %s)"):format(
            key, attached_object.hash,
            isEquipped and "true" or "false",
            inHotbar(attached_object.hash) and "true" or "false",
            isInVehicle and "true" or "false"))
        end

        DeleteObject(attached_object.handle)
        attached_weapons[key] = nil
      end
    end

    ::continue::
  end
end)

--- ESX player loaded event
RegisterNetEvent('esx:playerLoaded', function()
  playerLoaded = true

  if SlingConfig.Debug then
    print("[DEBUG] Player loaded via esx:playerLoaded, enabling sling functionality")
  end
end)

--- Update ped cache when changed
AddEventHandler('esx:playerPedChanged', function(newPed)
  cache.ped = newPed

  if SlingConfig.Debug then
    print(("[DEBUG] Player ped changed to %d"):format(newPed))
  end
end)

--- Toggle sling position between Front and Back
RegisterNetEvent('demon_sling:client:changeSling', function()
  if IsPedInAnyVehicle(cache.ped, false) then
    if SlingConfig.Debug then
      print("[DEBUG] Sling change blocked: in vehicle")
    end

    lib.notify({
      description = 'Cannot change sling position while in a vehicle',
      type = 'error',
      duration = 3000
    })
    return
  end

  if SlingConfig.Debug then
    print("[DEBUG] Received demon_sling:client:changeSling")
  end

  sling = (sling == "Back") and "Front" or "Back"

  if SlingConfig.Debug then
    print(("[DEBUG] Sling position changed to %s (firearms only)"):format(sling))
  end

  updateHotbar()
  refreshWeapons()

  lib.notify({
    description = ('Sling position changed to %s for firearms'):format(sling),
    type = 'success',
    duration = 3000
  })
end)

--- Handle inventory updates from ox_inventory
---@param data table|nil Inventory update data
RegisterNetEvent('ox_inventory:inventory:updated', function(data)
  if SlingConfig.Debug then
    print("[DEBUG] Inventory updated, refreshing sling attachments")

    if data and data.item and data.item.name then
      print(("[DEBUG] Inventory update for item: %s, slot: %s"):format(
        data.item.name,
        tostring(data.toSlot or data.fromSlot or "unknown")))
    end
  end

  updateHotbar()
  refreshWeapons()
end)
