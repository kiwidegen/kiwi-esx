-- Stress system

ESX = exports['es_extended']:getSharedObject()

local function GetStress(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    
    return xPlayer.get('stress') or 0
end

local function SetStress(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    amount = math.max(0, math.min(100, amount))
    xPlayer.set('stress', amount)
    TriggerClientEvent('hud:client:UpdateStress', source, amount)
end

local function IsStressWhitelistedJob(job)
    for _, v in pairs(HudConfig.Stress.whitelistedJobs) do
        if v == job then return true end
    end
    return false
end

-- Gain stress
RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    -- Check if job is whitelisted
    if IsStressWhitelistedJob(xPlayer.job.name) then return end
    
    local currentStress = GetStress(src)
    local newStress = currentStress + amount
    
    SetStress(src, newStress)
end)

-- Relieve stress
RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local currentStress = GetStress(src)
    local newStress = currentStress - amount
    
    SetStress(src, newStress)
end)

-- Exports
exports('GetStress', GetStress)
exports('SetStress', SetStress)

-- Passive stress relief (every minute)
CreateThread(function()
    while true do
        Wait(60000)
        
        local players = ESX.GetExtendedPlayers()
        for _, xPlayer in pairs(players) do
            local currentStress = GetStress(xPlayer.source)
            if currentStress > 0 then
                local newStress = currentStress - 1
                SetStress(xPlayer.source, newStress)
            end
        end
    end
end)