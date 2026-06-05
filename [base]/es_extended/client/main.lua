-- ─────────────────────────────────────────────────────────────────────────────
-- Client-side ESX state
-- ─────────────────────────────────────────────────────────────────────────────

Core        = {}
Core.Events = {}

ESX.PlayerData   = {}
ESX.PlayerLoaded = false
ESX.playerId     = PlayerId()
ESX.serverId     = GetPlayerServerId(ESX.playerId)

exports('getSharedObject', function() return ESX end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Trigger server join once the network is active
-- ─────────────────────────────────────────────────────────────────────────────

CreateThread(function()
    while not NetworkIsPlayerActive(ESX.playerId) do
        Wait(100)
    end

    -- Disable spawnmanager auto-spawn so we control when the player appears
    if GetResourceState('spawnmanager') == 'started' then
        exports.spawnmanager:setAutoSpawn(false)
    end

    DoScreenFadeOut(0)
    Wait(500)
    TriggerServerEvent('esx:onPlayerJoined')
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Player loaded
-- ─────────────────────────────────────────────────────────────────────────────

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData, isNew)
    ESX.PlayerData   = playerData
    ESX.PlayerLoaded = true

    local pos     = playerData.position
    local heading = pos.w or pos.heading or 0.0

    -- Load model
    local model = `mp_m_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    -- Move to spawn coords and wait for collision
    local ped   = PlayerPedId()
    local timer = GetGameTimer()
    SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, true)
    SetEntityHeading(ped, heading)
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    while not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - timer) < 5000 do
        Wait(0)
    end

    -- Resurrect and signal spawn (matches old ESX arg order)
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, heading, false, true)
    TriggerEvent('playerSpawned', pos)

    -- Wait for ped entity to exist
    while not DoesEntityExist(PlayerPedId()) do Wait(20) end
    ped = PlayerPedId()
    SetPedDefaultComponentVariation(ped)

    -- Wait for streaming (max 2s)
    timer = GetGameTimer()
    while not HaveAllStreamingRequestsCompleted(ped) and (GetGameTimer() - timer) < 2000 do
        Wait(0)
    end

    -- Dismiss loading screens
    TriggerEvent('esx:loadingScreenOff')
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(500)

    -- Finalise player state
    ClearPedTasksImmediately(ped)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    ESX.PlayerData.ped  = ped
    ESX.PlayerData.dead = false
    Adjustments:Load()
    TriggerEvent('esx:onPlayerSpawn')
    TriggerServerEvent('esx:onPlayerSpawn')
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Keep PlayerData in sync with server pushes
-- ─────────────────────────────────────────────────────────────────────────────

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    if not ESX.PlayerData.accounts then return end
    for i = 1, #ESX.PlayerData.accounts do
        if ESX.PlayerData.accounts[i].name == account.name then
            ESX.PlayerData.accounts[i] = account
            break
        end
    end
    TriggerEvent('esx:setPlayerData', 'accounts', ESX.PlayerData.accounts)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    TriggerEvent('esx:setPlayerData', 'job', job)
end)

RegisterNetEvent('esx:setGroup')
AddEventHandler('esx:setGroup', function(group)
    ESX.PlayerData.group = group
    TriggerEvent('esx:setPlayerData', 'group', group)
end)

RegisterNetEvent('esx:updatePlayerData')
AddEventHandler('esx:updatePlayerData', function(key, val)
    ESX.PlayerData[key] = val
    TriggerEvent('esx:setPlayerData', key, val)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Notifications from server (paycheck, etc.)
-- ─────────────────────────────────────────────────────────────────────────────

RegisterNetEvent('esx:notify')
AddEventHandler('esx:notify', function(data)
    lib.notify(data)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Execute a command string the server sends to this client
-- ─────────────────────────────────────────────────────────────────────────────

RegisterNetEvent('esx:executeCommand')
AddEventHandler('esx:executeCommand', function(command)
    ExecuteCommand(command)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Vehicle entry / exit watcher
-- Fires esx:enteredVehicle and esx:exitedVehicle for adjustments and other
-- resources that relied on these events from the old events module.
-- ─────────────────────────────────────────────────────────────────────────────

CreateThread(function()
    local lastVehicle = 0
    while true do
        Wait(500)
        if ESX.PlayerLoaded then
            local ped     = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle ~= 0 and vehicle ~= lastVehicle then
                local seat = -1
                for s = -1, 7 do
                    if GetPedInVehicleSeat(vehicle, s) == ped then
                        seat = s
                        break
                    end
                end
                TriggerEvent('esx:enteredVehicle', vehicle,
                    GetVehicleNumberPlateText(vehicle), seat,
                    GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
                    VehToNet(vehicle))
                lastVehicle = vehicle

            elseif vehicle == 0 and lastVehicle ~= 0 then
                TriggerEvent('esx:exitedVehicle', lastVehicle)
                lastVehicle = 0
            end
        end
    end
end)
