

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'Demon Scrapping - ESX Legacy'
version '2.0.0'

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'node_modules/.bin/session_store.js'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

dependencies {
  'es_extended',
  'ox_lib',
  'ox_target',
  'ox_inventory',
  'oxmysql'
}
