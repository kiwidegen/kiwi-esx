-- Resource Metadata
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DRP Fishing'
description 'Advanced Fishing'
version '1.0.1'

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    'config/zones.lua',
    'utils/cl_main.lua',
    'config/cl_edit.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'utils/sv_main.lua',
    'config/sv_config.lua',
    'locales/*.lua',
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'oxmysql',
    'qtarget',
    'PolyZone',
    'NW_fishingGame'
}
