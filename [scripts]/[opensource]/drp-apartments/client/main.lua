---@class ApartmentState
---@field InApartment boolean Whether player is currently in apartment
---@field ClosestHouse string|nil Name of closest apartment location
---@field CurrentApartment string|nil Current apartment identifier
---@field IsOwned boolean Whether player owns the closest apartment
---@field CurrentDoorBell number Player ID of person at door
---@field CurrentOffset number Vertical offset for apartment instance
---@field HouseObj table Interior object reference
---@field POIOffsets table|nil Point of interest offsets
---@field RangDoorbell string|nil Apartment where doorbell was rung

---@class TargetZoneState
---@field created boolean Whether zone has been created
---@field zone table|nil Zone reference

-- Framework initialization
ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}
local UseTarget = GetConvar('UseTarget', 'false') == 'true'

-- State variables
local InApartment = false
local ClosestHouse = nil
local CurrentApartment = nil
local IsOwned = false
local CurrentDoorBell = 0
local CurrentOffset = 0
local HouseObj = {}
local POIOffsets = nil
local RangDoorbell = nil

-- Target and zone tracking
---@type table<string, TargetZoneState>
local InApartmentTargets = {}

-- Polyzone state flags
local IsInsideEntranceZone = false
local IsInsideExitZone = false
local IsInsideStashZone = false
local IsInsideOutfitsZone = false
local IsInsideLogoutZone = false

-- Interior System Compatibility

--- Creates a simple apartment interior
---@param coords table Spawn coordinates
---@return table[] interior data [shellObj, POIOffsets]
local function CreateSimpleApartment(coords)
    -- Teleport player to apartment coords
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)

    -- Default POI offsets for apartment interactions
    local defaultOffsets = {
        exit = vector3(1.46, -10.33, 1.06),
        stash = vector3(-3.28, -7.32, 1.06),
        clothes = vector3(-7.92, -3.60, 1.06),
        logout = vector3(-1.32, -5.52, 1.06)
    }

    -- Return dummy shell object and offsets
    return {true, defaultOffsets}
end

--- Despawns apartment interior (cleanup)
---@param shellObj any Shell object reference
---@param callback function Callback to execute after despawn
---@return nil
local function DespawnSimpleApartment(shellObj, callback)
    -- No actual shell to despawn, just run callback
    if callback then callback() end
end

--- Draws 3D text at world coordinates
---@param x number X coordinate
---@param y number Y coordinate
---@param z number Z coordinate
---@param text string Text to display
---@return nil
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Menu Functions

--- Opens the entrance menu for apartment
---@return nil
local function OpenEntranceMenu()
    local menuOptions = {}

    if IsOwned then
        menuOptions[#menuOptions + 1] = {
            title = Lang:t('text.enter'),
            icon = 'fa-solid fa-door-open',
            onSelect = function()
                TriggerEvent('drp-apartments:client:EnterApartment')
            end
        }
    else
        menuOptions[#menuOptions + 1] = {
            title = Lang:t('text.move_here'),
            icon = 'fa-solid fa-hotel',
            onSelect = function()
                TriggerEvent('drp-apartments:client:UpdateApartment')
            end
        }
    end

    menuOptions[#menuOptions + 1] = {
        title = Lang:t('text.ring_doorbell'),
        icon = 'fa-solid fa-concierge-bell',
        onSelect = function()
            TriggerEvent('drp-apartments:client:DoorbellMenu')
        end
    }

    lib.registerContext({
        id = 'apartment_entrance_menu',
        title = Lang:t('text.options') or 'Apartment Options',
        options = menuOptions
    })

    lib.showContext('apartment_entrance_menu')
end

--- Opens the exit menu inside apartment
---@return nil
local function OpenExitMenu()
    local menuOptions = {}

    menuOptions[#menuOptions + 1] = {
        title = Lang:t('text.open_door'),
        icon = 'fa-solid fa-door-open',
        onSelect = function()
            TriggerEvent('drp-apartments:client:OpenDoor')
        end
    }

    menuOptions[#menuOptions + 1] = {
        title = Lang:t('text.leave'),
        icon = 'fa-solid fa-sign-out-alt',
        onSelect = function()
            TriggerEvent('drp-apartments:client:LeaveApartment')
        end
    }

    lib.registerContext({
        id = 'apartment_exit_menu',
        title = Lang:t('text.options') or 'Apartment Options',
        options = menuOptions
    })

    lib.showContext('apartment_exit_menu')
end

-- Zone Registration (ox_lib zones for non-target mode)

--- Registers an entrance zone using ox_lib zones
---@param apartmentID string Apartment location identifier
---@param apartmentData table Apartment configuration data
---@return nil
local function RegisterApartmentEntranceZone(apartmentID, apartmentData)
    local coords = apartmentData.coords['enter']
    local boxName = 'apartmentEntrance_' .. apartmentID
    local boxData = apartmentData.polyzoneBoxData

    if boxData.created then
        return
    end

    local zone = lib.zones.box({
        coords = vector3(coords.x, coords.y, coords.z),
        size = vector3(boxData.length, boxData.width, 5.0),
        rotation = 340.0,
        debug = false,
        onEnter = function()
            if not InApartment then
                lib.showTextUI(Lang:t('text.options'), {
                    position = 'left-center'
                })
                IsInsideEntranceZone = true
            end
        end,
        onExit = function()
            lib.hideTextUI()
            IsInsideEntranceZone = false
        end
    })

    boxData.created = true
    boxData.zone = zone
end

-- Target Registration (ox_target for target mode)

--- Registers an entrance target using ox_target (DISABLED - using DrawText3D instead)
---@param apartmentID string Apartment location identifier
---@param apartmentData table Apartment configuration data
---@return nil
local function RegisterApartmentEntranceTarget(apartmentID, apartmentData)
    -- Disabled - entrance interactions now use DrawText3D with E/G keys only
    return
end

-- Interior Zone Registration (ox_lib zones)

--- Registers an interior interaction zone
---@param targetKey string Zone identifier
---@param coords vector3 Zone coordinates
---@param heading number Zone heading
---@param text string Text to display
---@return nil
local function RegisterInApartmentZone(targetKey, coords, heading, text)
    if not InApartment then
        return
    end

    if InApartmentTargets[targetKey] and InApartmentTargets[targetKey].created then
        return
    end

    Wait(100)

    InApartmentTargets[targetKey] = {
        created = true,
        coords = coords,
        text = text
    }
end

-- Interior Target Registration (ox_target)

--- Registers an interior interaction target (DISABLED - using DrawText3D instead)
---@param targetKey string Target identifier
---@param coords vector3 Target coordinates
---@param heading number Target heading
---@param options table[] Target options
---@return nil
local function RegisterInApartmentTarget(targetKey, coords, heading, options)
    -- Disabled - interior interactions now use DrawText3D with E key only
    return
end

-- Target/Zone Management Functions

--- Sets up entrance targets/zones for all apartment locations
---@return nil
local function SetApartmentsEntranceTargets()
    if Apartments.Locations and next(Apartments.Locations) then
        for id, apartment in pairs(Apartments.Locations) do
            if apartment and apartment.coords and apartment.coords['enter'] then
                if UseTarget then
                    RegisterApartmentEntranceTarget(id, apartment)
                else
                    RegisterApartmentEntranceZone(id, apartment)
                end
            end
        end
    end
end

--- Sets up interior targets/zones for current apartment
---@return nil
local function SetInApartmentTargets()
    if not POIOffsets then
        return
    end

    local enterCoords = Apartments.Locations[ClosestHouse].coords.enter
    local entrancePos = vector3(enterCoords.x + POIOffsets.exit.x, enterCoords.y + POIOffsets.exit.y, enterCoords.z - CurrentOffset + POIOffsets.exit.z)
    local stashPos = vector3(enterCoords.x - POIOffsets.stash.x, enterCoords.y - POIOffsets.stash.y, enterCoords.z - CurrentOffset + POIOffsets.stash.z)
    local outfitsPos = vector3(enterCoords.x - POIOffsets.clothes.x, enterCoords.y - POIOffsets.clothes.y, enterCoords.z - CurrentOffset + POIOffsets.clothes.z)

    -- Always use DrawText3D zones (no context menus)
    RegisterInApartmentZone('stashPos', stashPos, 0, '~g~E~w~ - ' .. Lang:t('text.open_stash'))
    RegisterInApartmentZone('outfitsPos', outfitsPos, 0, '~g~E~w~ - ' .. Lang:t('text.change_outfit'))
    RegisterInApartmentZone('entrancePos', entrancePos, 0, '~g~E~w~ - Leave Apartment')
end

--- Deletes all apartment entrance targets/zones
---@return nil
local function DeleteApartmentsEntranceTargets()
    if Apartments.Locations and next(Apartments.Locations) then
        for id, apartment in pairs(Apartments.Locations) do
            if UseTarget then
                exports.ox_target:removeZone('apartmentEntrance_' .. id)
            else
                if apartment.polyzoneBoxData.zone then
                    apartment.polyzoneBoxData.zone:remove()
                    apartment.polyzoneBoxData.zone = nil
                end
            end
            apartment.polyzoneBoxData.created = false
        end
    end
end

--- Deletes all interior targets/zones
---@return nil
local function DeleteInApartmentTargets()
    IsInsideExitZone = false
    IsInsideStashZone = false
    IsInsideOutfitsZone = false
    IsInsideLogoutZone = false

    if InApartmentTargets and next(InApartmentTargets) then
        for id, _ in pairs(InApartmentTargets) do
            if UseTarget then
                exports.ox_target:removeZone('inApartmentTarget_' .. id)
            end
        end
    end
    InApartmentTargets = {}
end

-- Utility Functions

--- Loads animation dictionary
---@param dict string Animation dictionary name
---@return nil
local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

--- Plays door opening animation
---@return nil
local function openHouseAnim()
    loadAnimDict('anim@heists@keycard@')
    TaskPlayAnim(PlayerPedId(), 'anim@heists@keycard@', 'exit', 5.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(400)
    ClearPedTasks(PlayerPedId())
end

--- Enters an apartment
---@param house string Apartment location identifier
---@param apartmentId string Apartment identifier
---@param new boolean|nil Whether this is a new apartment
---@return nil
local function EnterApartment(house, apartmentId, new)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_open', 0.1)
    openHouseAnim()
    Wait(250)

    ESX.TriggerServerCallback('drp-apartments:GetApartmentOffset', function(offset)
        if offset == nil or offset == 0 then
            ESX.TriggerServerCallback('drp-apartments:GetApartmentOffsetNewOffset', function(newoffset)
                if newoffset > 230 then
                    newoffset = 210
                end
                CurrentOffset = newoffset
                TriggerServerEvent('drp-apartments:server:AddObject', apartmentId, house, CurrentOffset)

                local coords = {
                    x = Apartments.Locations[house].coords.enter.x,
                    y = Apartments.Locations[house].coords.enter.y,
                    z = Apartments.Locations[house].coords.enter.z - CurrentOffset
                }

                local data = exports['drp-interior']:CreateApartmentFurnished(coords)
                Wait(100)
                HouseObj = data[1]
                POIOffsets = data[2]
                InApartment = true
                CurrentApartment = apartmentId
                ClosestHouse = house
                RangDoorbell = nil
                Wait(500)
                -- Disable weather sync when inside apartment (Renewed-Weathersync)
                LocalPlayer.state:set('syncWeather', false, true)
                LocalPlayer.state:set('playerWeather', 'EXTRASUNNY', true)
                Wait(100)
                TriggerServerEvent('drp-apartments:server:SetInsideMeta', house, apartmentId, true, false)
                TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_close', 0.1)
                TriggerServerEvent('drp-apartments:server:setCurrentApartment', CurrentApartment)
            end, house)
        else
            if offset > 230 then
                offset = 210
            end
            CurrentOffset = offset
            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_open', 0.1)
            TriggerServerEvent('drp-apartments:server:AddObject', apartmentId, house, CurrentOffset)

            local coords = {
                x = Apartments.Locations[ClosestHouse].coords.enter.x,
                y = Apartments.Locations[ClosestHouse].coords.enter.y,
                z = Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset
            }

            local data = exports['drp-interior']:CreateApartmentFurnished(coords)
            Wait(100)
            HouseObj = data[1]
            POIOffsets = data[2]
            InApartment = true
            CurrentApartment = apartmentId
            Wait(500)
            -- Disable weather sync when inside apartment (Renewed-Weathersync)
            LocalPlayer.state:set('syncWeather', false, true)
            LocalPlayer.state:set('playerWeather', 'EXTRASUNNY', true)
            Wait(100)
            TriggerServerEvent('drp-apartments:server:SetInsideMeta', house, apartmentId, true, true)
            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_close', 0.1)
            TriggerServerEvent('drp-apartments:server:setCurrentApartment', CurrentApartment)
        end

        if new ~= nil then
            if new then
                TriggerEvent('drp-interior:client:SetNewState', true)
            else
                TriggerEvent('drp-interior:client:SetNewState', false)
            end
        else
            TriggerEvent('drp-interior:client:SetNewState', false)
        end
    end, apartmentId)
end

--- Leaves the current apartment
---@param house string Apartment location identifier
---@return nil
local function LeaveApartment(house)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_open', 0.1)
    openHouseAnim()

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end

    -- Delete interior objects
    if HouseObj and type(HouseObj) == 'table' then
        exports['drp-interior']:DespawnInterior(HouseObj, function() end)
    end
    HouseObj = nil

    -- Re-enable weather sync when leaving apartment (Renewed-Weathersync)
    LocalPlayer.state:set('syncWeather', true, true)

    -- Server cleanup BEFORE teleport
    TriggerServerEvent('drp-apartments:server:SetInsideMeta', house, CurrentApartment, false, false)
    TriggerServerEvent('drp-apartments:server:RemoveObject', CurrentApartment, house)
    TriggerServerEvent('drp-apartments:server:setCurrentApartment', nil)
    TriggerServerEvent('drp-apartments:returnBucket')

    Wait(100)

    -- Clear local state
    CurrentApartment = nil
    InApartment = false
    CurrentOffset = 0
    DeleteInApartmentTargets()
    DeleteApartmentsEntranceTargets()

    -- Teleport player
    SetEntityCoords(PlayerPedId(), Apartments.Locations[house].coords.enter.x, Apartments.Locations[house].coords.enter.y, Apartments.Locations[house].coords.enter.z, false, false, false, true)
    SetEntityHeading(PlayerPedId(), Apartments.Locations[house].coords.enter.w)

    Wait(500)

    -- Fade back in
    DoScreenFadeIn(1000)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_close', 0.1)
end

--- Sets the closest apartment to player and checks ownership
---@return nil
local function SetClosestApartment()
    local pos = GetEntityCoords(PlayerPedId())
    local current = nil
    local dist = 100

    for id, _ in pairs(Apartments.Locations) do
        local enterCoords = Apartments.Locations[id].coords.enter
        local distcheck = #(pos - vector3(enterCoords.x, enterCoords.y, enterCoords.z))
        if distcheck < dist then
            current = id
        end
    end

    if current ~= ClosestHouse and ESX.PlayerLoaded and not InApartment then
        ClosestHouse = current
        ESX.TriggerServerCallback('drp-apartments:IsOwner', function(result)
            IsOwned = result
            DeleteApartmentsEntranceTargets()
            DeleteInApartmentTargets()
        end, ClosestHouse)
    end
end

--- Opens doorbell menu showing available tenants
---@return nil
function MenuOwners()
    ESX.TriggerServerCallback('drp-apartments:GetAvailableApartments', function(apartments)
        if next(apartments) == nil then
            lib.notify({
                description = Lang:t('error.nobody_home'),
                type = 'error',
                duration = 3500
            })
        else
            local menuOptions = {}

            for k, v in pairs(apartments) do
                menuOptions[#menuOptions + 1] = {
                    title = v,
                    icon = 'fa-solid fa-user',
                    onSelect = function()
                        TriggerEvent('drp-apartments:client:RingMenu', { apartmentId = k })
                    end
                }
            end

            lib.registerContext({
                id = 'apartment_doorbell_menu',
                title = Lang:t('text.tennants'),
                options = menuOptions
            })

            lib.showContext('apartment_doorbell_menu')
        end
    end, ClosestHouse)
end

-- ESX Event Handlers

--- Handles player loaded event
---@param xPlayer table ESX player data
---@return nil
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    ESX.PlayerLoaded = true

    -- Set up apartment blips on player load
    ESX.TriggerServerCallback('drp-apartments:GetOwnedApartment', function(apartment)
        if apartment then
            TriggerEvent('drp-apartments:client:SetHomeBlip', apartment.type)
        else
            TriggerEvent('drp-apartments:client:SetHomeBlip', nil)
        end
    end, xPlayer.identifier)
end)

--- Handles job change event
---@param job table Job data
---@return nil
RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

--- Handles player logout event
---@return nil
RegisterNetEvent('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    PlayerData = {}
    CurrentApartment = nil
    InApartment = false
    CurrentOffset = 0

    DeleteApartmentsEntranceTargets()
    DeleteInApartmentTargets()
end)

-- Resource Event Handlers

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    PlayerData = ESX.GetPlayerData()
    ESX.PlayerLoaded = true
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if HouseObj ~= nil then
            exports['drp-interior']:DespawnInterior(HouseObj, function()
                CurrentApartment = nil
                -- Re-enable weather sync when resource stops (Renewed-Weathersync)
                LocalPlayer.state:set('syncWeather', true, true)
                DoScreenFadeIn(500)
                while not IsScreenFadedOut() do
                    Wait(10)
                end
                SetEntityCoords(PlayerPedId(), Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z)
                SetEntityHeading(PlayerPedId(), Apartments.Locations[ClosestHouse].coords.enter.w)
                Wait(1000)
                InApartment = false
                DoScreenFadeIn(1000)
            end)
        end

        DeleteApartmentsEntranceTargets()
        DeleteInApartmentTargets()
    end
end)

-- Apartment Events

--- Handles spawn UI setup
---@param cData table Character data
---@return nil
RegisterNetEvent('drp-apartments:client:setupSpawnUI', function(cData)
    -- Disabled for ESX - ESX handles spawn UI through multicharacter/spawn system
    ESX.TriggerServerCallback('drp-apartments:GetOwnedApartment', function(result)
        if result then
            TriggerEvent('drp-apartments:client:SetHomeBlip', result.type)
        else
            TriggerEvent('drp-apartments:client:SetHomeBlip', nil)
        end
    end, cData and cData.identifier or PlayerData.identifier)
end)

--- Handles spawning in apartment
---@param apartmentId string Apartment identifier
---@param apartment string Apartment location
---@return nil
RegisterNetEvent('drp-apartments:client:SpawnInApartment', function(apartmentId, apartment)
    local pos = GetEntityCoords(PlayerPedId())
    if RangDoorbell ~= nil then
        local enterCoords = Apartments.Locations[RangDoorbell].coords.enter
        local doorbelldist = #(pos - vector3(enterCoords.x, enterCoords.y, enterCoords.z))
        if doorbelldist > 5 then
            lib.notify({
                description = Lang:t('error.to_far_from_door'),
                type = 'error'
            })
            return
        end
    end
    ClosestHouse = apartment
    EnterApartment(apartment, apartmentId, true)
    IsOwned = true
end)

--- Handles last location spawn in apartment
---@param apartmentType string Apartment location type
---@param apartmentId string Apartment identifier
---@return nil
RegisterNetEvent('drp-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
    ClosestHouse = apartmentType
    EnterApartment(apartmentType, apartmentId, false)
end)

--- Sets home blip on map
---@param home string|nil Home apartment type
---@return nil
RegisterNetEvent('drp-apartments:client:SetHomeBlip', function(home)
    CreateThread(function()
        SetClosestApartment()
        for name, _ in pairs(Apartments.Locations) do
            RemoveBlip(Apartments.Locations[name].blip)

            local enterCoords = Apartments.Locations[name].coords.enter
            Apartments.Locations[name].blip = AddBlipForCoord(enterCoords.x, enterCoords.y, enterCoords.z)

            if name == home then
                SetBlipSprite(Apartments.Locations[name].blip, 475)
                SetBlipDisplay(Apartments.Locations[name].blip, 4)
                SetBlipScale(Apartments.Locations[name].blip, 0.65)
                SetBlipAsShortRange(Apartments.Locations[name].blip, true)
                SetBlipColour(Apartments.Locations[name].blip, 3)
                AddTextEntry(Apartments.Locations[name].label, Apartments.Locations[name].label)
                BeginTextCommandSetBlipName(Apartments.Locations[name].label)
                EndTextCommandSetBlipName(Apartments.Locations[name].blip)
            else
                SetBlipSprite(Apartments.Locations[name].blip, 476)
                SetBlipDisplay(Apartments.Locations[name].blip, 4)
                SetBlipScale(Apartments.Locations[name].blip, 0.65)
                SetBlipAsShortRange(Apartments.Locations[name].blip, true)
                SetBlipColour(Apartments.Locations[name].blip, 3)
                -- Use same name for all non-home apartments so they group together
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName('Apartments')
                EndTextCommandSetBlipName(Apartments.Locations[name].blip)
            end
        end
    end)
end)

--- Handles doorbell ring menu selection
---@param data table Menu data containing apartmentId
---@return nil
RegisterNetEvent('drp-apartments:client:RingMenu', function(data)
    RangDoorbell = ClosestHouse
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'doorbell', 0.1)
    TriggerServerEvent('drp-apartments:server:RingDoor', data.apartmentId, ClosestHouse)
end)

--- Handles incoming doorbell ring
---@param player number Player source ringing doorbell
---@param _ any Unused parameter
---@return nil
RegisterNetEvent('drp-apartments:client:RingDoor', function(player, _)
    CurrentDoorBell = player
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'doorbell', 0.1)
    lib.notify({
        description = Lang:t('info.at_the_door'),
        type = 'inform'
    })
end)

--- Opens doorbell menu
---@return nil
RegisterNetEvent('drp-apartments:client:DoorbellMenu', function()
    MenuOwners()
end)

--- Enters apartment
---@return nil
RegisterNetEvent('drp-apartments:client:EnterApartment', function()
    ESX.TriggerServerCallback('drp-apartments:GetOwnedApartment', function(result)
        if result ~= nil then
            EnterApartment(ClosestHouse, result.name)
        end
    end)
end)

--- Updates/creates apartment ownership
---@return nil
RegisterNetEvent('drp-apartments:client:UpdateApartment', function()
    local apartmentType = ClosestHouse
    local apartmentLabel = Apartments.Locations[ClosestHouse].label

    ESX.TriggerServerCallback('drp-apartments:GetOwnedApartment', function(result)
        if result == nil then
            TriggerServerEvent("drp-apartments:server:CreateApartment", apartmentType, apartmentLabel, false)
        else
            TriggerServerEvent('drp-apartments:server:UpdateApartment', apartmentType, apartmentLabel)
        end
    end)

    IsOwned = true

    DeleteApartmentsEntranceTargets()
    DeleteInApartmentTargets()
end)

--- Opens door for visitor
---@return nil
RegisterNetEvent('drp-apartments:client:OpenDoor', function()
    if CurrentDoorBell == 0 then
        lib.notify({
            description = Lang:t('error.nobody_at_door'),
            type = 'error'
        })
        return
    end
    TriggerServerEvent('drp-apartments:server:OpenDoor', CurrentDoorBell, CurrentApartment, ClosestHouse)
    CurrentDoorBell = 0
end)

--- Leaves apartment
---@return nil
RegisterNetEvent('drp-apartments:client:LeaveApartment', function()
    LeaveApartment(ClosestHouse)
end)

--- Opens apartment stash
---@return nil
RegisterNetEvent('drp-apartments:client:OpenStash', function()
    if CurrentApartment then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'StashOpen', 0.4)
        TriggerServerEvent('drp-apartments:server:openStash', CurrentApartment)
    end
end)

--- Opens outfit menu
---@return nil
RegisterNetEvent('drp-apartments:client:ChangeOutfit', function()
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Clothes1', 0.4)
    -- Use illenium-appearance event for outfit menu
    TriggerEvent('illenium-appearance:client:openOutfitMenu')
end)

--- Logs out character
---@return nil
RegisterNetEvent('drp-apartments:client:Logout', function()
    TriggerServerEvent('esx:onPlayerLogout')
    ESX.PlayerLoaded = false
end)

-- Main Threads

-- Main interaction thread (works for both target and non-target modes)
CreateThread(function()
    local sleep = 5000
    while not ESX.PlayerLoaded do
        Wait(sleep)
    end

    while true do
        sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        if not InApartment then
            SetClosestApartment()

            -- Check distance to closest apartment entrance
            if ClosestHouse and Apartments.Locations[ClosestHouse] then
                local enterCoords = Apartments.Locations[ClosestHouse].coords.enter
                local dist = #(playerCoords - vector3(enterCoords.x, enterCoords.y, enterCoords.z))

                if dist < 2.0 then
                    sleep = 0

                    -- Show appropriate text based on ownership
                    if IsOwned then
                        DrawText3D(enterCoords.x, enterCoords.y, enterCoords.z + 0.3, '~g~E~w~ - Enter | ~g~G~w~ - Ring Doorbell')

                        if IsControlJustPressed(0, 38) then -- E key
                            TriggerEvent('drp-apartments:client:EnterApartment')
                        end
                    else
                        DrawText3D(enterCoords.x, enterCoords.y, enterCoords.z + 0.3, '~g~E~w~ - Move Here | ~g~G~w~ - Ring Doorbell')

                        if IsControlJustPressed(0, 38) then -- E key
                            TriggerEvent('drp-apartments:client:UpdateApartment')
                        end
                    end

                    -- G key for doorbell
                    if IsControlJustPressed(0, 47) then -- G key
                        TriggerEvent('drp-apartments:client:DoorbellMenu')
                    end
                end
            end
        elseif InApartment then
            sleep = 0
            SetInApartmentTargets()

            -- Draw text for interior zones
            for key, target in pairs(InApartmentTargets) do
                if target.created and target.coords and target.text then
                    local dist = #(playerCoords - target.coords)
                    if dist < 1.5 then
                        DrawText3D(target.coords.x, target.coords.y, target.coords.z + 0.1, target.text)

                        if IsControlJustPressed(0, 38) then -- E key
                            if key == 'stashPos' then
                                TriggerEvent('drp-apartments:client:OpenStash')
                            elseif key == 'outfitsPos' then
                                TriggerEvent('drp-apartments:client:ChangeOutfit')
                            elseif key == 'entrancePos' then
                                TriggerEvent('drp-apartments:client:LeaveApartment')
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

