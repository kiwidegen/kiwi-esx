name 'drp-stashes'
author 'KiwiDegen'
version '3.0.0'
description 'drp-stash system'
fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
game 'gta5'

ui_page 'web/build/index.html'

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'locales/en.lua',
  'shared/**.lua',
}

client_scripts {
  'client/**.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/**.lua',
  'client/modules/helper_functions.js'
}

files {
  'locales/*.json',
  'web/build/index.html',
  'web/build/**/*'
}
