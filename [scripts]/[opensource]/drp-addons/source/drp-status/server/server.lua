---@diagnostic disable: undefined-global, lowercase-global
--- Status System - Server
--- Manages player status persistence and admin commands

local playerStatuses = {}

--- Load player status from database
---@param xPlayer table The ESX player object
local function loadPlayerStatus(xPlayer)
	local identifier = xPlayer.identifier

	MySQL.query('SELECT status FROM users WHERE identifier = ?', { identifier }, function(result)
		local statuses = {}

		if result[1] and result[1].status then
			-- Parse existing status from database
			local savedStatus = json.decode(result[1].status)

			if savedStatus then
				for _, status in ipairs(savedStatus) do
					statuses[#statuses + 1] = {
						name = status.name,
						val = status.val
					}
				end
			end
		end

		-- If no saved status, initialize with defaults
		if #statuses == 0 then
			for statusName, statusConfig in pairs(StatusConfig.Statuses) do
				statuses[#statuses + 1] = {
					name = statusName,
					val = statusConfig.default
				}
			end
		end

		-- Cache player status
		playerStatuses[xPlayer.source] = statuses

		-- Send to client
		TriggerClientEvent('drp_status:load', xPlayer.source, statuses)
	end)
end

--- Save player status to database
---@param xPlayer table The ESX player object
local function savePlayerStatus(xPlayer)
	if not playerStatuses[xPlayer.source] then return end

	local identifier = xPlayer.identifier
	local statusJson = json.encode(playerStatuses[xPlayer.source])

	MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', { statusJson, identifier })
end

--- Get player status from cache
---@param source number Player source/id
---@param statusName string The status name to retrieve
---@return number|nil value The status value or nil if not found
local function getPlayerStatus(source, statusName)
	if not playerStatuses[source] then return nil end

	for _, status in ipairs(playerStatuses[source]) do
		if status.name == statusName then
			return status.val
		end
	end

	return nil
end

--- Set player status in cache
---@param source number Player source/id
---@param statusName string The status name to set
---@param value number The value to set
local function setPlayerStatus(source, statusName, value)
	if not playerStatuses[source] then return end

	-- Clamp value
	value = math.max(0, math.min(StatusConfig.StatusMax, value))

	for i, status in ipairs(playerStatuses[source]) do
		if status.name == statusName then
			playerStatuses[source][i].val = value
			return
		end
	end
end

--- Add to player status in cache
---@param source number Player source/id
---@param statusName string The status name to modify
---@param value number The amount to add
local function addPlayerStatus(source, statusName, value)
	local currentValue = getPlayerStatus(source, statusName)
	if not currentValue then return end

	setPlayerStatus(source, statusName, currentValue + value)
end

-- Event Handlers
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	loadPlayerStatus(xPlayer)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		savePlayerStatus(xPlayer)
	end

	-- Clear cache
	playerStatuses[playerId] = nil
end)

RegisterNetEvent('drp_status:update', function(statuses)
	local _src = source

	if not _src or not playerStatuses[_src] then return end

	if not statuses or type(statuses) ~= 'table' then return end

	-- Update cache with client data
	playerStatuses[_src] = statuses
end)

-- txAdmin heal event compatibility
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= 'monitor' or type(eventData) ~= 'table' or type(eventData.id) ~= 'number' then
		return
	end

	local playerId = eventData.id

	-- Set all statuses to max
	for statusName in pairs(StatusConfig.Statuses) do
		setPlayerStatus(playerId, statusName, StatusConfig.StatusMax)
		TriggerClientEvent('drp_status:set', playerId, statusName, StatusConfig.StatusMax)
	end
end)

-- Exports for other resources
exports('getPlayerStatus', getPlayerStatus)
exports('setPlayerStatus', function(source, statusName, value)
	setPlayerStatus(source, statusName, value)
	TriggerClientEvent('drp_status:set', source, statusName, value)
end)
exports('addPlayerStatus', function(source, statusName, value)
	addPlayerStatus(source, statusName, value)
	TriggerClientEvent('drp_status:add', source, statusName, value)
end)
