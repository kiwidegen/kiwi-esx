---@diagnostic disable: undefined-global, lowercase-global
--- Sit System - Client
--- Advanced sitting system with multi-seat support and precise positioning

local state = require 'source.drp-sit.client.state'
local models = SitConfig.Models
local actions = SitConfig.Actions

--- Rotate offset based on entity heading
---@param offset vector3 The offset to rotate
---@param heading number Entity heading
---@return vector3 rotated Rotated offset
local function rotateOffset(offset, heading)
	local rad = math.rad(heading)
	local cosH = math.cos(rad)
	local sinH = math.sin(rad)

	local newX = offset.x * cosH - offset.y * sinH
	local newY = offset.x * sinH + offset.y * cosH

	return vec3(newX, newY, offset.z)
end

--- Execute sitting action (scenario or animation)
---@param action string Action name
---@param coords vector3 Coordinates to sit at
---@param heading number Heading to face
local function execAction(action, coords, heading)
	SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, true, false, false, false)

	local actionData = actions[action]
	if actionData.type == 'scenario' then
		TaskStartScenarioAtPosition(cache.ped, actionData.scenario, coords.x, coords.y, coords.z, heading, 0, true, true)
	elseif actionData.type == 'anim' then
		lib.requestAnimDict(actionData.dict)
		TaskPlayAnim(cache.ped, actionData.dict, actionData.name, 8.0, -8.0, -1, 1, 0, false, false, false)
		RemoveAnimDict(actionData.dict)
	end
end

--- Handle sitting on an entity
---@param entity number Entity handle
---@param seat number Seat index
local function playSit(entity, seat)
	local netId = NetworkGetNetworkIdFromEntity(entity)
	local taken = lib.callback.await('drp-sit:server:Occupy', false, netId, seat)
	if not taken then return end

	state:set('sitting', true)
	state:set('entity', entity)

	local hash = GetEntityModel(entity)
	local model = models[hash]
	local seatOffset = model.seats[seat]
	local seatCoords = GetEntityCoords(entity)
	local seatHeading = GetEntityHeading(entity)
	local rotatedOffset = rotateOffset(seatOffset, seatHeading)
	local coords = seatCoords + rotatedOffset
	local heading = seatHeading + seatOffset.w

	if not model.action then return end
	execAction(model.action, coords, heading)

	local keybind = lib.addKeybind({
		name = 'drp-sit:keybind:get_up',
		description = 'Get up from seat',
		defaultKey = SitConfig.GetUpKey,
		disabled = true,
		onReleased = function(self)
			TriggerServerEvent('drp-sit:server:Free', netId, seat)
			lib.hideTextUI()
			self:disable(true)
			ClearPedTasks(cache.ped)
			state:set('sitting', false)
			state:set('entity', 0)
		end
	})

	lib.showTextUI('[' .. SitConfig.GetUpKey .. '] - Get Up', {
		position = "left-center"
	})
	keybind:disable(false)
end

--- Event to sit down
AddEventHandler('drp-sit:client:Sit', function(data)
	if state.sitting then return end
	if not DoesEntityExist(data.entity) then return end

	if not NetworkGetEntityIsNetworked(data.entity) then
		NetworkRegisterEntityAsNetworked(data.entity)
	end

	Wait(100)

	if not NetworkGetEntityIsNetworked(data.entity) then
		print('^3[WARNING]: Chair can\'t be networked^0')
		return
	end

	local hash = GetEntityModel(data.entity)
	local netId = NetworkGetNetworkIdFromEntity(data.entity)
	local seat = lib.callback.await('drp-sit:server:GetFree', 200, netId, hash)
	if not seat then
		lib.notify({
			description = 'Seat is occupied',
			type = 'error'
		})
		return
	end

	playSit(data.entity, seat)
end)

--- Unregister networked entity
RegisterNetEvent('drp-sit:client:Unregister', function(netId)
	if GetInvokingResource() then return end

	local entity = NetworkGetEntityFromNetworkId(netId)
	NetworkUnregisterNetworkedEntity(entity)
end)

--- Setup ox_target for all sittable objects
CreateThread(function()
	Wait(1000) -- Wait for resources to load

	local targetModels = {}
	for targetModel in pairs(models) do
		targetModels[#targetModels + 1] = targetModel
	end

	exports.ox_target:addModel(targetModels, {
		{
			label = 'Sit Down',
			name = 'drp-sit:sit',
			icon = 'fa-solid fa-chair',
			distance = SitConfig.MaxDistance,
			canInteract = function(entity)
				return DoesEntityExist(entity) and not cache.vehicle and not state.sitting
			end,
			onSelect = function(data)
				TriggerEvent('drp-sit:client:Sit', data)
			end,
		}
	})

	state:init()
end)
