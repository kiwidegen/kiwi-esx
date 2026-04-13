-- server/modules/armory.lua
local ArmoryModule = {}

--- Handle item request from armory
RegisterNetEvent('drp_policetools:armory:getItem', function(itemName, amount)
  local source = source

  if not source or source == 0 then
    return
  end

  if not IsPolice(source) then
    return
  end

  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then
    return
  end

  -- Verify item is in allowed armory items
  local isAllowed = false
  local itemLabel = itemName
  for _, item in ipairs(Config.Armory.Items) do
    if item.name == itemName then
      isAllowed = true
      itemLabel = item.label
      break
    end
  end

  if not isAllowed then
    return
  end

  -- Check if player can carry the item
  local canCarry = exports.ox_inventory:CanCarryItem(source, itemName, amount)

  if canCarry then
    exports.ox_inventory:AddItem(source, itemName, amount)

    TriggerClientEvent('ox_lib:notify', source, {
      title = 'Armory',
      description = ('Received %dx %s'):format(amount, itemLabel),
      type = 'success'
    })

    -- Send Discord log via drp-logs
    local identifier = xPlayer.getIdentifier()
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade_label or xPlayer.job.grade_name

    exports['drp-logs']:log('police', {
      source = source,
      title = '🛡️ Armory Access',
      description = 'Officer withdrew items from the armory',
      colorName = 'info',
      fields = {
        {
          name = 'Job',
          value = ('`%s` - %s'):format(job, grade),
          inline = true
        },
        {
          name = 'Item',
          value = ('`%dx %s`'):format(amount, itemLabel),
          inline = false
        }
      }
    })
  else
    TriggerClientEvent('ox_lib:notify', source, {
      title = 'Armory',
      description = 'Inventory is full',
      type = 'error'
    })
  end
end)

--- Module initialization
function ArmoryModule.Init()
end

-- Register the module
RegisterPoliceModule('armory', ArmoryModule)

-- Initialize
ArmoryModule.Init()
