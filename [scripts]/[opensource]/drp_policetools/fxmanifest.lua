-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'DRP Police Tools'
version '1.0.0'

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client/*.lua',
  'client/modules/*.lua',

}

server_scripts {
  'server/*.lua',
  'server/modules/*.lua',

}
