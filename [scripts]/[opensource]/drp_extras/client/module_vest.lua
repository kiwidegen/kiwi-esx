-- Module guard
if not ExtrasConfig.Modules.VestEquip then return end

--============================================================
--  VEST EQUIP MODULE
--============================================================
--
--  NOTE: Vest functionality is now handled by ox_inventory.
--  Vest items (vest, vestpolice, heavyvest) are registered in:
--  resources/[ox]/ox_inventory/modules/items/client.lua
--
--  This module is kept for backwards compatibility with any
--  external scripts that may still trigger these events.
--============================================================

--- Play animation with proper loading
---@param dict string Animation dictionary
---@param anim string Animation name
---@param flags number Animation flags
local function PlayAnimation(dict, anim, flags)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end

    TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 2.0, -1, flags, 0.0, false, false, false)
end

--- Give vest with progress bar
---@param item string Item name
AddEventHandler("drp_extras:givevest", function(item)
    -- Determine armor amount based on item type
    local armorAmount = 100
    local label = 'Putting on Vest'

    if item == 'light_armor' then
        armorAmount = 50
        label = 'Putting on Light Armor'
    elseif item == 'heavy_armor' then
        armorAmount = 100
        label = 'Putting on Heavy Armor'
    end

    if lib.progressCircle({
        duration = ExtrasConfig.VestTime,
        position = 'bottom',
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle',
            clip = 'gang_chatting_idle01',
        },
    }) then
        SetPlayerMaxArmour(PlayerId(), 100)
        SetPedArmour(PlayerPedId(), armorAmount)
        TriggerServerEvent("drp_extras:removevest", item)

        lib.notify({
            description = armorAmount == 50 and 'You feel slightly more protected.' or 'You feel completely protected.',
            type = 'success'
        })
    else
        lib.notify({
            description = 'Vest equip cancelled',
            type = 'error'
        })
    end
end)

--- Give magazine with reload animation
RegisterNetEvent("drp_extras:givemag", function()
    PlayAnimation('weapons@first_person@aim_rng@generic@pistol@pistol_str', 'reload_aim', 51)
    Wait(1500)
    ClearPedTasks(PlayerPedId())
end)

--- Keybind: Equip Armor (= key)
RegisterCommand('+equip_armor', function()
    local ped = PlayerPedId()

    if GetPedArmour(ped) >= 100 then
        lib.notify({ type = 'error', description = "You already have full armor!" })
        return
    end

    -- Try heavy armor first, then light armor
    local heavyCount = exports.ox_inventory:Search('count', 'heavy_armor')
    local lightCount = exports.ox_inventory:Search('count', 'light_armor')

    if heavyCount > 0 then
        TriggerEvent('drp_extras:givevest', 'heavy_armor')
    elseif lightCount > 0 then
        TriggerEvent('drp_extras:givevest', 'light_armor')
    else
        lib.notify({ type = 'error', description = "You don't have any armor!" })
    end
end, false)

RegisterCommand('-equip_armor', function() end, false)
RegisterKeyMapping('+equip_armor', 'Equip Armor', 'keyboard', 'EQUALS')
