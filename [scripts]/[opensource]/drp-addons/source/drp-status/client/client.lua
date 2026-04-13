---@diagnostic disable: undefined-global, lowercase-global
--- Status System - Client
--- Clean hunger/thirst management with esx_status compatibility

local playerStatuses = {}
local isDead = false

--- Initialize player statuses with default values
local function initializeStatuses()
	for statusName, statusConfig in pairs(StatusConfig.Statuses) do
		playerStatuses[statusName] = statusConfig.default
	end
end

--- Set a specific status value
---@param statusName string The name of the status to set
---@param value number The value to set (0 to StatusConfig.StatusMax)
local function setStatus(statusName, value)
	if not playerStatuses[statusName] then return end

	-- Clamp value between 0 and StatusMax
	playerStatuses[statusName] = math.max(0, math.min(StatusConfig.StatusMax, value))
end

--- Add to a specific status value
---@param statusName string The name of the status to modify
---@param value number The amount to add (can be negative)
local function addStatus(statusName, value)
	if not playerStatuses[statusName] then return end

	local newValue = playerStatuses[statusName] + value
	setStatus(statusName, newValue)
end

--- Get current status value
---@param statusName string The name of the status
---@return number value Current status value
local function getStatus(statusName)
	return playerStatuses[statusName] or 0
end

--- Get all statuses as a table
---@return table statuses All current status values with percentages
local function getAllStatuses()
	local statuses = {}

	for statusName, value in pairs(playerStatuses) do
		statuses[#statuses + 1] = {
			name = statusName,
			val = value,
			percent = (value / StatusConfig.StatusMax) * 100
		}
	end

	return statuses
end

--- Process status tick (drain/regen)
local function processTick()
	for statusName, statusConfig in pairs(StatusConfig.Statuses) do
		if playerStatuses[statusName] then
			addStatus(statusName, statusConfig.tickAmount)
		end
	end
end

--- Handle damage when statuses reach 0
local function processDamage()
	if not StatusConfig.EnableDamage or isDead then return end

	local playerPed = PlayerPedId()
	local currentHealth = GetEntityHealth(playerPed)
	local damageToApply = 0

	-- Check if any status is at 0
	for statusName, value in pairs(playerStatuses) do
		if value <= 0 then
			if currentHealth <= StatusConfig.CriticalHealthThreshold then
				damageToApply = damageToApply + StatusConfig.CriticalDamageAmount
			else
				damageToApply = damageToApply + StatusConfig.DamageAmount
			end
		end
	end

	-- Apply damage if needed
	if damageToApply > 0 then
		local newHealth = math.max(0, currentHealth - damageToApply)
		SetEntityHealth(playerPed, newHealth)
	end
end

--- Main status tick thread
local function startStatusThread()
	CreateThread(function()
		while ESX.PlayerLoaded do
			Wait(StatusConfig.TickTime)

			processTick()
			processDamage()

			local statusData = getAllStatuses()

			-- Trigger esx_status compatible event for HUDs and other scripts
			TriggerEvent('esx_status:onTick', statusData)
		end
	end)
end

--- Update server with current status
local function updateServer()
	CreateThread(function()
		while ESX.PlayerLoaded do
			Wait(StatusConfig.UpdateInterval)
			TriggerServerEvent('drp_status:update', getAllStatuses())
		end
	end)
end

-- Event Handlers
RegisterNetEvent('drp_status:load', function(loadedStatuses)
	while not ESX.PlayerLoaded do Wait(100) end

	-- Load statuses from server
	for _, status in ipairs(loadedStatuses) do
		playerStatuses[status.name] = status.val
	end

	-- Start the status system
	startStatusThread()
	updateServer()

	TriggerEvent('drp_status:loaded')
	TriggerEvent('esx_status:loaded') -- Compatibility event
end)

RegisterNetEvent('drp_status:set', function(statusName, value)
	setStatus(statusName, value)
end)

RegisterNetEvent('drp_status:add', function(statusName, value)
	addStatus(statusName, value)
end)

-- esx_status compatibility events
RegisterNetEvent('esx_status:set', function(statusName, value)
	setStatus(statusName, value)
end)

RegisterNetEvent('esx_status:add', function(statusName, value)
	addStatus(statusName, value)
end)

RegisterNetEvent('esx_status:remove', function(statusName, value)
	addStatus(statusName, -value)
end)

AddEventHandler('esx_status:getStatus', function(statusName, cb)
	local value = getStatus(statusName)

	-- Return esx_status compatible object
	cb({
		name = statusName,
		val = value,
		percent = (value / StatusConfig.StatusMax) * 100,
		getPercent = function()
			return (value / StatusConfig.StatusMax) * 100
		end
	})
end)

AddEventHandler('esx_status:getAllStatus', function(cb)
	local statusObjects = {}

	for statusName, value in pairs(playerStatuses) do
		statusObjects[#statusObjects + 1] = {
			name = statusName,
			val = value,
			percent = (value / StatusConfig.StatusMax) * 100,
			getPercent = function()
				return (value / StatusConfig.StatusMax) * 100
			end
		}
	end

	cb(statusObjects)
end)

RegisterNetEvent('esx:onPlayerDeath', function()
	isDead = true
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
	if isDead then
		-- Reset statuses to respawn percentage
		local respawnValue = (StatusConfig.StatusMax * StatusConfig.RespawnStatusPercent) / 100

		for statusName in pairs(playerStatuses) do
			setStatus(statusName, respawnValue)
		end
	end

	isDead = false
end)

RegisterNetEvent('esx:onPlayerLogout', function()
	playerStatuses = {}
end)

-- Exports for external scripts
exports('getStatus', function(statusName)
	local value = getStatus(statusName)
	return {
		name = statusName,
		val = value,
		percent = (value / StatusConfig.StatusMax) * 100,
		getPercent = function()
			return (value / StatusConfig.StatusMax) * 100
		end
	}
end)

exports('getAllStatuses', getAllStatuses)
exports('setStatus', setStatus)
exports('addStatus', addStatus)

-- Initialize on load
initializeStatuses()
