-- client/modules/armory.lua
local ArmoryModule = {}

--- Check if a vehicle is a police vehicle
---@param vehicle number The vehicle entity
---@return boolean isPoliceVehicle Whether the vehicle is a police vehicle
local function IsPoliceVehicle(vehicle)
  local model = GetEntityModel(vehicle)
  local modelName = GetDisplayNameFromVehicleModel(model):lower()

  for _, policeModel in ipairs(Config.Armory.VehicleModels) do
    if GetHashKey(policeModel) == model or policeModel:lower() == modelName then
      return true
    end
  end
  return false
end

--- Open armory menu
---@param vehicle number The vehicle entity
local function openArmoryMenu(vehicle)
  if not IsPolice() then
    lib.notify({
      title = 'Armory',
      description = 'Only police can access the armory',
      type = 'error'
    })
    return
  end

  local options = {}

  for _, item in ipairs(Config.Armory.Items) do
    table.insert(options, {
      title = item.label,
      description = ('Take %dx %s'):format(item.amount, item.label),
      icon = item.icon,
      onSelect = function()
        TriggerServerEvent('drp_policetools:armory:getItem', item.name, item.amount)
      end
    })
  end

  lib.registerContext({
    id = 'drp_armory_menu',
    title = 'Police Armory',
    options = options
  })

  lib.showContext('drp_armory_menu')
end

--- Register ox_target for all police vehicle models
local function registerGlobalTargets()
  -- Register each model individually
  for _, modelName in ipairs(Config.Armory.VehicleModels) do
    exports.ox_target:addModel(modelName, {
      {
        name = 'police_armory_' .. modelName,
        icon = 'fas fa-shield',
        label = 'Open Armory',
        bones = { 'boot', 'trunk' },
        distance = Config.Armory.InteractionDistance,
        onSelect = function(data)
          openArmoryMenu(data.entity)
        end,
        canInteract = function(entity, distance, coords, name, bone)
          return IsPolice()
        end
      }
    })
  end
end

--- Module callbacks
function ArmoryModule.OnResourceStart()
  registerGlobalTargets()
end

function ArmoryModule.OnPlayerLoaded()
end

function ArmoryModule.OnResourceStop()
  -- ox_target cleanup happens automatically
end

-- Register the module
RegisterPoliceModule('armory', ArmoryModule)
