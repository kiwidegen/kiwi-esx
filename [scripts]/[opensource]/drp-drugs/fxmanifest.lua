fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'DRP Drugs - Advanced ESX Drug Selling System'
author 'KiwiDegen'
version '2.0.0'

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'config/server_config.lua'
}

server_scripts {
  'server/drug_selling.lua'
}

client_scripts {
  'client/selling/utils.lua',
  'client/selling/main.lua',
  'client/selling/zones.lua'
}

dependencies {
  'es_extended',
  'ox_lib',
  'ox_target',
  'ox_inventory',
  'rcore_dispatch'
}

escrow_ignore {
  'config/server_config.lua'
}
