fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'DRP Admin Tools - Modern ESX admin utilities'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/events.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/commands.lua',
    'server/events.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'oxmysql'
}