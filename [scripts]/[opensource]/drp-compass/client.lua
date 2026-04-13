-- client.lua (ESX compass: hide until loaded, hide on death, show ONLY on revive/spawn; no debug)

local lastHeading = 0
local hudEnabled = false
local streetsEnabled = true
local lastPostal = "N/A"
local lastPlayerPos = { x = 0, y = 0 }
local cacheDistanceThreshold = 50.0
local lastStreetInfo = ""
local lastStreetPos = { x = 0, y = 0 }

-- Lifecycle
local playerLoaded = false
local isDead = false -- authoritative death state; ONLY events can clear it

-- Start hidden
CreateThread(function()
  SendNUIMessage({ type = 'toggleHUD', state = false })
end)

-- Postal data
local postalData
local resourceName = GetCurrentResourceName()
local jsonFile = LoadResourceFile(resourceName, "html/oulsen_satmap_postals.json")
if jsonFile then
  local ok, result = pcall(json.decode, jsonFile)
  if ok then postalData = result end
end

local function GetNearestPostal(playerX, playerY)
  if not postalData then return "N/A" end
  local playerPos = { x = playerX, y = playerY }
  local dx, dy = playerPos.x - lastPlayerPos.x, playerPos.y - lastPlayerPos.y
  if math.sqrt(dx * dx + dy * dy) < cacheDistanceThreshold then
    return lastPostal
  end
  local closestPostal, minDistance = nil, math.huge
  for _, postal in ipairs(postalData) do
    local ddx, ddy = playerX - postal.x, playerY - postal.y
    local distance = math.sqrt(ddx * ddx + ddy * ddy)
    if distance < minDistance then
      minDistance = distance
      closestPostal = postal.code
    end
  end
  lastPostal = closestPostal or "N/A"
  lastPlayerPos = playerPos
  return lastPostal
end

local function showHUD()
  if hudEnabled or not playerLoaded or isDead then return end
  hudEnabled = true
  SendNUIMessage({ type = 'toggleHUD', state = true })
end

local function hideHUD()
  if not hudEnabled then return end
  hudEnabled = false
  SendNUIMessage({ type = 'toggleHUD', state = false })
end

----------------------------------------------------------------
-- ESX / death lifecycle (EVENT-DRIVEN: no auto-show on "not dead")
----------------------------------------------------------------

-- Fully loaded -> show only if alive
RegisterNetEvent('esx:playerLoaded', function()
  playerLoaded = true
  isDead = IsEntityDead(PlayerPedId())
  if isDead then hideHUD() else showHUD() end
end)

-- ESX spawn/respawn -> this is our ONLY auto re-show path
RegisterNetEvent('esx:onPlayerSpawn', function()
  playerLoaded = true
  isDead = false
  showHUD()
end)

-- Some ESX setups emit this on death
RegisterNetEvent('esx:onPlayerDeath', function()
  isDead = true
  hideHUD()
end)

-- Baseevents (recommended) -> catch deaths reliably
AddEventHandler('baseevents:onPlayerDied', function()
  isDead = true
  hideHUD()
end)

AddEventHandler('baseevents:onPlayerKilled', function(_, _)
  isDead = true
  hideHUD()
end)

-- Ambulancejob explicit revive event (when present)
RegisterNetEvent('esx_ambulancejob:revive', function()
  isDead = false
  showHUD()
end)

-- Safety watcher: NEVER shows; only hides if we somehow miss a death
CreateThread(function()
  while true do
    Wait(250)
    if playerLoaded then
      if IsEntityDead(PlayerPedId()) and not isDead then
        isDead = true
        hideHUD()
      end
    end
  end
end)

---------------------------------------------------------
-- Main update loop (only runs when HUD is enabled)
---------------------------------------------------------
CreateThread(function()
  while true do
    if hudEnabled then
      local ped = PlayerPedId()
      local heading = GetGameplayCamRot(2).z % 360
      if heading < 0 then heading = heading + 360 end
      local headingDiff = math.abs(heading - lastHeading)
      local waitTime = headingDiff > 1.0 and 16 or 100

      if headingDiff > 1.0 or streetsEnabled then
        local streetInfo = ""
        if streetsEnabled then
          local playerPos = GetEntityCoords(ped)
          local dx, dy = playerPos.x - lastStreetPos.x, playerPos.y - lastStreetPos.y
          if math.sqrt(dx * dx + dy * dy) > cacheDistanceThreshold then
            local streetHash1, streetHash2 = GetStreetNameAtCoord(playerPos.x, playerPos.y, playerPos.z)
            local street1 = GetStreetNameFromHashKey(streetHash1)
            local street2 = GetStreetNameFromHashKey(streetHash2)
            streetInfo = street1
            if street2 ~= "" then streetInfo = streetInfo .. " & " .. street2 end
            local postal = GetNearestPostal(playerPos.x, playerPos.y)
            streetInfo = streetInfo .. ", " .. postal
            lastStreetInfo = streetInfo
            lastStreetPos = { x = playerPos.x, y = playerPos.y }
          else
            streetInfo = lastStreetInfo
          end
        end

        SendNUIMessage({
          type = 'updateHeading',
          heading = heading,
          streetInfo = streetInfo
        })
        lastHeading = heading
      end

      Wait(waitTime)
    else
      Wait(500)
    end
  end
end)

---------------------------------------------------------
-- Commands (manual control)
---------------------------------------------------------
RegisterCommand('togglecompass', function()
  SendNUIMessage({ type = 'toggleHUD' })
end, false)

RegisterCommand('compass', function()
  -- respect death/loaded state
  if not playerLoaded or isDead then return end
  hudEnabled = not hudEnabled
  SendNUIMessage({ type = 'toggleHUD', state = hudEnabled })
end, false)

RegisterCommand('streets', function()
  streetsEnabled = not streetsEnabled
  SendNUIMessage({ type = 'toggleStreets', state = streetsEnabled })
end, false)
