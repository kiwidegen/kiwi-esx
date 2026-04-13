fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DRP Development'
description 'Event management system with routing buckets and sound integration'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'xsound'
}
