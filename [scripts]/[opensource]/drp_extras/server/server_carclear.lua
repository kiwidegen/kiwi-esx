-- Module guard (server-side check)
if not Config or not ExtrasConfig.Modules or not ExtrasConfig.Modules.CarClear then return end

--============================================================
--  CAR CLEAR SERVER MODULE
--============================================================

--- Check if table contains value
---@param t table Table to search
---@param v any Value to find
---@return boolean found Whether value exists in table
local function table_contains(t, v)
    for key, value in pairs(t) do
        if (value == v) then
            return true
        end
    end
    return false
end

--- Check if notification should be sent at this time
---@param remaining_time number Time remaining in minutes
local function CheckTimer(remaining_time)
    if (table_contains(ExtrasConfig.CarClear.NotificationOn, remaining_time)) then
        ExtrasConfig.CarClearAnnounce(string.format(ExtrasConfig.CarClearNotification, ExtrasConfig.CarClear.Distance, remaining_time))
    end
end

--- Check if any player is within distance of position
---@param position vector3 Position to check
---@param radius number Radius to check
---@return boolean playerNearby Whether any player is nearby
local function IsAnyPlayerInDistance(position, radius)
    for key, value in pairs(GetPlayers()) do
        local playerPed = GetPlayerPed(value)
        local playerPosition = GetEntityCoords(playerPed)
        local distance = #(playerPosition - position)

        if (radius >= distance) then
            return true
        end
    end
    return false
end

--- Clear vehicles that are far from all players
local function ClearVehicles()
    local deletedCount = 0

    for key, value in pairs(GetAllVehicles()) do
        if (not IsAnyPlayerInDistance(GetEntityCoords(value), ExtrasConfig.CarClear.Distance)) then
            -- Optional: Trigger impound event if you have an impound system
            -- TriggerEvent('your-impound:changeState', GetVehicleNumberPlateText(value), 'impound')
            DeleteEntity(value)
            deletedCount = deletedCount + 1
        end
    end

    if deletedCount > 0 then
        ExtrasConfig.CarClearAnnounce(string.format("%s (%d vehicles deleted)", ExtrasConfig.CarClearClearedNotification, deletedCount))
    else
        ExtrasConfig.CarClearAnnounce("Vehicle clear completed - no vehicles were deleted")
    end
end

--- Start the car clear timer
local function StartTimer()
    local remaining_time = ExtrasConfig.CarClear.Time

    Wait(60000) -- Initial wait
    while remaining_time > 0 do
        remaining_time = remaining_time - 1

        CheckTimer(remaining_time)
        Wait(remaining_time > 0 and 60000 or 0)
    end

    ClearVehicles()
end

--- Main car clear thread
CreateThread(function()
    while true do
        StartTimer()
    end
end)
