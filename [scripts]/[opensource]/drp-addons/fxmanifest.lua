fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DRP Framework'
description 'DRP Server Addons - Essential utilities and features'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',
    'source/drp-sit/models.lua',
    'source/drp-sit/actions.lua',
    'source/drp-sling/data.lua'
}

client_scripts {
    'source/**/client/**.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'source/**/server/**.lua',
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'oxmysql',
    'pma-voice'
}

-- Files that won't be encrypted (configuration files users can edit)
escrow_ignore {
    'config.lua',
    'source/drp-sit/models.lua',
    'source/drp-sit/actions.lua',
    'source/drp-sling/data.lua'
}
