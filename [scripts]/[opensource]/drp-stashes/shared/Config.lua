StashesConfig = {}

--- Locale helper function
---@param key string Locale key (e.g. 'Interact.targetLabel')
---@param ... any Additional arguments for string formatting
---@return string
function locale(key, ...)
  local keys = {}
  for k in string.gmatch(key, "[^.]+") do
    table.insert(keys, k)
  end

  local value = Lang
  for _, k in ipairs(keys) do
    if value[k] then
      value = value[k]
    else
      return key
    end
  end

  if type(value) == "string" and ... then
    return string.format(value, ...)
  end

  return value
end

--- Enable this if you are using old data from before version 3.0.0
--- This loads command ADjustStashes to adjust old data to new data format
--- Turn to false after you run the command IF you need to use it
StashesConfig.OldData = false

--- Default stash settings
StashesConfig.Defaults = {
  slots = 50,
  maxWeight = 1000000
}

--- Available objects for stash creation
StashesConfig.Objects = {
  {value = 'tr_prop_tr_chest_01a', label = 'Small Chest'},
  {value = 'prop_champ_box_01',    label = 'Medium Crate'},
  {value = 'prop_box_wood05a',     label = 'Large Crate'},
  {value = 'prop_lev_crate_01',    label = 'Large Wooden Crate'},
  {value = 'prop_container_03mb',  label = 'Shipping Container'},
}

--- Set to false if you do not want to use backpacks
StashesConfig.UseBackpacks = true
