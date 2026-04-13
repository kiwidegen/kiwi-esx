-- server/main.lua
--- Main server file for DRP Police Tools
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

--- Check if a player is a police officer
---@param source number The player source
---@return boolean isPolice Whether the player is police
function IsPolice(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then
    return false
  end

  return Config.PoliceJobs[xPlayer.job.name] or false
end

--- Send a Discord log
---@param webhookType string The webhook type from Config.Discord.Webhooks
---@param title string The embed title
---@param description string The embed description
---@param color number The embed color
---@param fields table Optional fields array
function SendDiscordLog(webhookType, title, description, color, fields)
  if not Config.Discord.Enabled then
    return
  end

  local webhook = Config.Discord.Webhooks[webhookType]
  if not webhook or webhook == 'YOUR_WEBHOOK_URL_HERE' then
    return
  end

  local embed = {
    {
      title = title,
      description = description,
      color = color or Config.Discord.Colors.Success,
      fields = fields or {},
      footer = {
        text = 'DRP Police Tools | ' .. os.date('%Y-%m-%d %H:%M:%S')
      }
    }
  }

  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
    username = 'Police Tools',
    embeds = embed
  }), { ['Content-Type'] = 'application/json' })
end
