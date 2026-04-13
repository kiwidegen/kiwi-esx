fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'DRP cooldown system - Secure server-side validation'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'config/client.lua',
    'client/main.lua'
}

server_scripts {
    'config/server.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib'
}
