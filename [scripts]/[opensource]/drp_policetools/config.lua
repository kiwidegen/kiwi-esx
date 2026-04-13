-- config.lua
Config = {}

-- Police job names
Config.PoliceJobs = {
  ['police'] = true,
  ['sheriff'] = true
}

-- Note: Discord logging now handled by drp-logs resource
-- All police tool logs go to the 'police' category in drp-logs

-- Armory Module Config
Config.Armory = {
  VehicleModels = {
    "police",
    "police2",
    "police3",
    "police4",
    "policeb",
    "policet",
    "sheriff",
    "sheriff2",
    "gresleyhellfirepd",
    "elegy3",
    "evajv",
    "gresleyhellfire",
    "jcon",
    "pbbgtsj",
    "sebbjv",
    "spbbjh",
    "spbbjv",
    "spbgjv",
    "sphijv",
    "spnsbjv",
    "spvdjv",
    "stxhpd"
  },
  InteractionDistance = 2.5,
  Items = {
    {
      name = 'heavy_armor',
      label = 'Heavy Body Armor',
      amount = 1,
      icon = 'shield-halved'
    },
    {
      name = 'spikestrip_remote',
      label = 'Remote Spike Strip',
      amount = 1,
      icon = 'bullets'
    },
    {
      name = 'repairkit',
      label = 'Advanced repairkit',
      amount = 1,
      icon = 'bullets'
    },
    {
      name = 'ammo-9',
      label = '9mm Ammo',
      amount = 100,
      icon = 'bullets'
    },
    {
      name = 'ammo-45',
      label = '.45 ACP Ammo',
      amount = 50,
      icon = 'bullets'
    },
    {
      name = 'ammo-rifle',
      label = 'Rifle Ammo',
      amount = 100,
      icon = 'bullets'
    },
    {
      name = 'ammo-shotgun',
      label = 'Shotgun Shells',
      amount = 50,
      icon = 'bullets'
    }
  }
}

-- Police Vehicle Whitelist Config
Config.PoliceVehicles = {
  Model = {
    "police",
    "police2",
    "police3",
    "police4",
    "policeb",
    "policet",
    "sheriff",
    "sheriff2",
    "gresleyhellfirepd",
    "elegy3",
    "evajv",
    "gresleyhellfire",
    "jcon",
    "pbbgtsj",
    "sebbjv",
    "spbbjh",
    "spbbjv",
    "spbgjv",
    "sphijv",
    "spnsbjv",
    "spvdjv",
    "stxhpd"
  },
  CheckInterval = 500,
  EjectDelay = 100
}

-- Spike Strip Module Config
Config.SpikeStrip = {
  MaxControlDistance = 50.0,
  Model = 'p_ld_stinger_s',
  RemoteItemName = 'spikestrip_remote',
  DeployKey = 38,
  ToggleKey = 38,
  DetectionDistance = 3.5,
  VehicleCooldown = 10000,
  CheckInterval = 100
}

-- Add more tool configs here later
-- Config.Flashlight = {}
-- Config.Radar = {}
