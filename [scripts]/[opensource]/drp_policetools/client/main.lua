--- Main client file for DRP Police Tools
--- This file handles core functionality and module registration

local modules = {}

--- Register a police tool module
---@param name string The module name
---@param module table The module table
function RegisterPoliceModule(name, module)
  modules[name] = module
end

--- Get a registered module
---@param name string The module name
---@return table|nil module The module table or nil
function GetPoliceModule(name)
  return modules[name]
end

--- Check if local player is police
---@return boolean isPolice Whether the player is police
function IsPolice()
  return ESX.PlayerData.job and ESX.PlayerData.job.name and Config.PoliceJobs[ESX.PlayerData.job.name] or false
end

--- Load a model
---@param model string|number The model name or hash
---@return boolean success Whether the model loaded successfully
function LoadModel(model)
  local hash = type(model) == "string" and joaat(model) or model

  if HasModelLoaded(hash) then
    return true
  end

  RequestModel(hash)

  local timeout = 0
  while not HasModelLoaded(hash) and timeout < 5000 do
    Wait(10)
    timeout = timeout + 10
  end

  return HasModelLoaded(hash)
end

--- Handle player loaded
RegisterNetEvent('esx:playerLoaded', function(playerData)
  ESX.PlayerData = playerData

  -- Notify all modules
  for name, module in pairs(modules) do
    if module.OnPlayerLoaded then
      module.OnPlayerLoaded()
    end
  end
end)

--- Handle job change
RegisterNetEvent('esx:setJob', function(job)
  ESX.PlayerData.job = job

  -- Notify all modules
  for name, module in pairs(modules) do
    if module.OnJobChange then
      module.OnJobChange(job)
    end
  end
end)

--- Handle resource start
AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end

  Wait(1000)

  -- Initialize all modules
  for name, module in pairs(modules) do
    if module.OnResourceStart then
      module.OnResourceStart()
    end
  end
end)

--- Handle resource stop
AddEventHandler('onResourceStop', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end

  -- Cleanup all modules
  for name, module in pairs(modules) do
    if module.OnResourceStop then
      module.OnResourceStop()
    end
  end
end)
