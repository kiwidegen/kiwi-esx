ESX = exports['es_extended']:getSharedObject()

---@class ClientConfig
---@field enter_location vector4
---@field exit_location vector4
---@field package_locations table<number, vector4>
---@field dropoff_location vector4
---@field warehouse_objects string[]
---@field PickupBoxModel string
local Config = nil

-- Cache
local cache = {
    ped = PlayerPedId(),
    coords = GetEntityCoords(PlayerPedId())
}

-- Translations
local Translations = {
    success = {
        you_have_been_clocked_in = "You Have Been Clocked In",
    },
    text = {
        point_enter_warehouse = "[E] Enter Warehouse",
        enter_warehouse = "Enter Warehouse",
        exit_warehouse = "Exit Warehouse",
        point_exit_warehouse = "[E] Exit Warehouse",
        hand_in_package = "Hand In Package",
        point_hand_in_package = "[E] Hand In Package",
        get_package = "Get Package",
        point_get_package = "[E] Get Package",
        picking_up_the_package = "Picking up the package",
        unpacking_the_package = "Unpacking the package",
    },
    error = {
        you_have_clocked_out = "You Have Clocked Out"
    },
}

-- State Variables
local inside = false
local current_package = nil
local current_package_obj = nil
local current_package_grabbed = false

--- Draw 3D text at coordinates
---@param x number X coordinate
---@param y number Y coordinate
---@param z number Z coordinate
---@param text string Text to display
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

--- Select random package location
---@return vector4 package Random package location
local function randomPackage()
    return RecycleConfig.package_locations[math.random(1, #RecycleConfig.package_locations)]
end

--- Pickup package and attach to player
local function pickupPackage()
    local ped = cache.ped
    local pos = GetEntityCoords(ped, true)

    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do
        Wait(1)
    end

    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 5.0, -1, -1, 50, 0, false, false, false)
    local model = GetHashKey(RecycleConfig.PickupBoxModel)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local object = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    current_package_obj = object
end

--- Drop package and cleanup
local function dropPackage()
    ClearPedTasks(cache.ped)
    if DoesEntityExist(current_package_obj) then
        DetachEntity(current_package_obj, true, true)
        DeleteObject(current_package_obj)
    end
    current_package_obj = nil
    current_package = nil
    current_package_grabbed = false
end

--- Start warehouse work thread
local function startWarehouseThread()
    local ped = cache.ped
    SetEntityCoords(ped, RecycleConfig.exit_location.x, RecycleConfig.exit_location.y, RecycleConfig.exit_location.z)
    SetEntityHeading(ped, RecycleConfig.exit_location.w)
    inside = true

    lib.notify({
        title = 'Recycle Job',
        description = Translations.success.you_have_been_clocked_in,
        type = 'success'
    })

    CreateThread(function()
        while inside do
            Wait(1)
            cache.ped = PlayerPedId()
            local player_pos = GetEntityCoords(cache.ped)

            if current_package ~= nil then
                if not current_package_grabbed then
                    DrawText3D(current_package.x, current_package.y, current_package.z, Translations.text.point_get_package)

                    if IsControlJustReleased(0, 38) and #(player_pos - current_package.xyz) < 3.0 then
                        if lib.progressCircle({
                            duration = math.random(4000, 6000),
                            label = Translations.text.picking_up_the_package,
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                move = true,
                                combat = true,
                                car = true,
                            },
                            anim = {
                                dict = "mp_car_bomb",
                                clip = "car_bomb_mechanic",
                                flag = 49,
                            },
                        }) then
                            pickupPackage()
                            current_package_grabbed = true
                        else
                            lib.notify({
                                title = 'Recycle Job',
                                description = 'Package pickup canceled',
                                type = 'error'
                            })
                        end
                    end
                else
                    DrawText3D(RecycleConfig.dropoff_location.x, RecycleConfig.dropoff_location.y, RecycleConfig.dropoff_location.z, Translations.text.point_hand_in_package)

                    if IsControlJustReleased(0, 38) and #(player_pos - RecycleConfig.dropoff_location.xyz) < 1.0 then
                        if lib.progressCircle({
                            duration = math.random(2000, 4000),
                            label = Translations.text.unpacking_the_package,
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                move = true,
                                combat = true,
                                car = true,
                            },
                        }) then
                            dropPackage()
                            TriggerServerEvent('drp-recycle:server:getItem')
                        else
                            lib.notify({
                                title = 'Recycle Job',
                                description = 'Package processing canceled',
                                type = 'error'
                            })
                        end
                    end
                end
            else
                current_package = randomPackage()
            end

            if #(player_pos - RecycleConfig.exit_location.xyz) < 2.0 then
                DrawText3D(RecycleConfig.exit_location.x, RecycleConfig.exit_location.y, RecycleConfig.exit_location.z, Translations.text.point_exit_warehouse)

                if IsControlJustReleased(0, 38) then
                    SetEntityCoords(cache.ped, RecycleConfig.enter_location.x, RecycleConfig.enter_location.y, RecycleConfig.enter_location.z)
                    SetEntityHeading(cache.ped, RecycleConfig.enter_location.w)
                    Wait(500)
                    inside = false

                    lib.notify({
                        title = 'Recycle Job',
                        description = Translations.error.you_have_clocked_out,
                        type = 'error'
                    })
                end
            end
        end
    end)
end

--- Initialize blip and warehouse objects
local function initializeWarehouse()
    -- Create blip
    local blip = AddBlipForCoord(RecycleConfig.enter_location.x, RecycleConfig.enter_location.y, RecycleConfig.enter_location.z)
    SetBlipSprite(blip, 365)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Recycling Centre")
    EndTextCommandSetBlipName(blip)

    -- Spawn warehouse objects
    for _, location in pairs(RecycleConfig.package_locations) do
        local model = GetHashKey(RecycleConfig.warehouse_objects[math.random(1, #RecycleConfig.warehouse_objects)])
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end

        local obj = CreateObject(model, location.x, location.y, location.z, false, true, true)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
    end
end

--- Open sell items menu
local function openSellMenu()
    ESX.TriggerServerCallback('drp-recycle:getItems', function(items)
        if #items == 0 then
            lib.notify({
                title = 'Recycle Shop',
                description = 'You don\'t have any items to sell',
                type = 'error'
            })
            return
        end

        local contextOptions = {
            {
                title = '**Sell All Items**',
                description = 'Sell everything in your inventory at once',
                icon = 'dollar-sign',
                onSelect = function()
                    TriggerServerEvent('drp-recycle:sellAllItems')
                end
            }
        }

        for _, item in pairs(items) do
            contextOptions[#contextOptions + 1] = {
                title = ('Sell %s (x%d)'):format(item.label, item.amount),
                description = ('Price: $%d each | Total: $%d'):format(item.price, item.price * item.amount),
                icon = 'recycle',
                image = ('nui://ox_inventory/web/images/%s.png'):format(item.name),
                metadata = {
                    { label = 'Quantity', value = item.amount },
                    { label = 'Total Value', value = ('$%d'):format(item.price * item.amount) }
                },
                onSelect = function()
                    TriggerServerEvent('drp-recycle:sellItem', item.name)
                end
            }
        end

        lib.registerContext({
            id = 'recycle_shop_context',
            title = 'Recycle Shop',
            options = contextOptions,
            canClose = true
        })

        lib.showContext('recycle_shop_context')
    end)
end

-- Event: Open sell menu
RegisterNetEvent('drp-recycle:openItemsMenu', function()
    openSellMenu()
end)

-- Initialize on resource start
CreateThread(function()
    ESX.TriggerServerCallback('drp-recycle:getConfig', function(serverConfig)
        Config = serverConfig
        initializeWarehouse()
    end)
end)

-- Entrance interaction thread
CreateThread(function()
    while true do
        Wait(1)

        if not Config then
            Wait(1000)
            goto continue
        end

        cache.ped = PlayerPedId()
        local player_pos = GetEntityCoords(cache.ped)
        local dist = #(player_pos - RecycleConfig.enter_location.xyz)

        if dist < 10.0 then
            if dist < 2.0 then
                DrawText3D(RecycleConfig.enter_location.x, RecycleConfig.enter_location.y, RecycleConfig.enter_location.z, Translations.text.point_enter_warehouse)

                if IsControlJustReleased(0, 38) and not inside then
                    startWarehouseThread()
                end
            else
                DrawText3D(RecycleConfig.enter_location.x, RecycleConfig.enter_location.y, RecycleConfig.enter_location.z, Translations.text.enter_warehouse)
            end
        elseif dist > 50.0 then
            Wait(2000)
        end

        ::continue::
    end
end)

-- ox_target for selling
CreateThread(function()
    while not Config do Wait(100) end

    exports.ox_target:addModel({'ex_prop_ex_laptop_01a'}, {
        {
            name = 'drp_recycle_sell',
            event = 'drp-recycle:openItemsMenu',
            icon = 'fa-solid fa-dollar-sign',
            label = 'Sell your items',
            distance = 2.5,
        }
    })
end)
