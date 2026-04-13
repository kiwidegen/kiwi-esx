fx_version 'cerulean'
author 'NielsfnStore'
description 'ESX Legacy Pawn Shop'
game 'gta5'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/utils/helper_functions.js'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}
escrow_ignore {
    '*.sql',
    'config.lua',
    'config/**/*.lua',
    'config/*.lua',
    'configs/**/*.lua',
    'configs/*.lua',
    'README*',
    'README.md',
    'sql/**/*.sql',
    'sql/*.sql'
}


