fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Lean ESX core — identity, jobs, money only. ox suite handles everything else.'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/utils.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/events.lua',
    'server/commands.lua',
}

client_scripts {
    'client/adjustments.lua',
    'client/death.lua',
    'client/main.lua',
    'client/functions.lua',
    'client/commands.lua',
}

files {
    'imports.lua',
    'locale.lua',
}

dependencies {
    '/native:0x6AE51D4B',
    '/native:0xA61C8FC6',
    'oxmysql',
    'ox_lib',
    'ox_inventory',
    'ox_target',
}
