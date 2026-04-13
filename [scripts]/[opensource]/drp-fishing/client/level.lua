local level = 1

---@param l number
local function updated(l)
    if not l then return end
    
    level = l
    Update(level)
end

lib.callback('drp-fishing:getLevel', false, updated)

RegisterNetEvent('esx:playerLoaded', function()
    lib.callback('drp-fishing:getLevel', 100, updated)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    lib.callback('drp-fishing:getLevel', 100, updated)
end)

RegisterNetEvent('drp-fishing:updateLevel', updated)

function GetCurrentLevel()
    return math.floor(level)
end

function GetCurrentLevelProgress()
    return level - math.floor(level)
end
