fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DRP Development'
description 'Vehicle Repair Script'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
