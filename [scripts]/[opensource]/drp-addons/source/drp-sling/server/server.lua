-- ESX Initialization
ESX = exports['es_extended']:getSharedObject()

--- Get ESX player from source
---@param source number Player source ID
---@return table|nil xPlayer ESX player object or nil
local function getPlayer(source)
  return ESX.GetPlayerFromId(source)
end

--- Handle /sling command registration
---@param source number Player source ID
---@param args table Command arguments (unused)
RegisterCommand("sling", function(source, args)
  if SlingConfig.Debug then
    print(("[DEBUG] Player %d triggered /sling command"):format(source))
  end

  local xPlayer = getPlayer(source)
  if not xPlayer then
    if SlingConfig.Debug then
      print(("[ERROR] No ESX player for source %d"):format(source))
    end
    return
  end

  TriggerClientEvent("demon_sling:client:changeSling", source)

  if SlingConfig.Debug then
    print(("[DEBUG] Sent demon_sling:client:changeSling to player %d"):format(source))
  end
end, false)

if SlingConfig.Debug then
  print("[DEBUG] Registered /sling command (ESX)")
end
