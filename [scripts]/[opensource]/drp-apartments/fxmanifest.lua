fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Kakarot (ESX Conversion)'
description 'ESX Apartments - Provides players with an apartment on server join'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}
