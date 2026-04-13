local ped = nil

Citizen.CreateThread(function()

	-- Blips --
	local blip = AddBlipForCoord(Config.NPCLocation.coords)
	SetBlipSprite(blip, 272)
	SetBlipScale(blip, 0.65)
	SetBlipColour (blip, 5)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Pawn Shop")
	EndTextCommandSetBlipName(blip)

	-- NPC --
	local pedModel = GetHashKey("a_m_m_afriamer_01")
	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do
		Wait(1)
	end

	ped = CreatePed(4, pedModel, Config.NPCLocation.coords.x, Config.NPCLocation.coords.y, Config.NPCLocation.coords.z - 1.0, Config.NPCLocation.heading, false, true)

	SetPedDiesWhenInjured(ped, true)
	SetEntityInvincible(ped, true)
	FreezeEntityPosition(ped, true)
	SetPedRelationshipGroupHash(ped, "MISSION8")
	SetRelationshipBetweenGroups(0, "MISSION8", "PLAYER")
	SetBlockingOfNonTemporaryEvents(ped, true)

	exports.ox_target:addLocalEntity(ped, {
		{
			name = 'pawnshop_npc',
			label = "Open Pawn Shop",
			icon = "fas fa-shop",
			distance = 2.5,
			onSelect = function()
				TriggerEvent('frp-pawnshop:client:openPawnShop')
			end
		}
	})
end)

RegisterNetEvent('frp-pawnshop:client:openPawnShop')
AddEventHandler('frp-pawnshop:client:openPawnShop', function()
	-- Log pawnshop access
	TriggerServerEvent('frp-pawnshop:srv:access')
	
	local categories = {}
	for k,v in pairs(Config.Items) do
		categories[#categories+1] = {
			title = v.label,
			description = 'Sell your '..v.item..' for €'..v.price.. ' each.',
			onSelect = function(args)
				OpenAmountMenu(v.item)
			end,
		}
	end

	lib.registerContext({
		id = 'pawn:sell-menu',
		title = 'Pawn Shop: Sell Menu',
		options = categories
	})

	lib.showContext('pawn:sell-menu')
end)

OpenAmountMenu = function(item)
	local input = lib.inputDialog('How many '..Config.Items[item].label.. ' do you want to sell?', {
		{type = 'number', label = 'Enter amount'},
	})

	if input then
		local count = exports.ox_inventory:Search('count', item)
		if count >= tonumber(input[1]) then
			LocalPlayer.state.invBusy = true

			if lib.progressCircle({
				duration = 3000,
				label = 'Selling '..Config.Items[item].label,
				position = 'bottom',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = true,
					combat = true,
				},
				anim = {
					dict = 'mp_common',
					clip = 'givetake1_a',
				},
			}) then
				ClearPedTasks(PlayerPedId())
				TriggerServerEvent('frp-pawnshop:srv:sellitem', item, input[1])
			else
				ClearPedTasks(PlayerPedId())
			end

			LocalPlayer.state.invBusy = false
			Wait(1000)
			indexId = nil
		else
			lib.notify({
				description = 'You don\'t have enough to sell this amount!',
				type = 'error'
			})
		end
	end
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	DeletePed(ped)
end)