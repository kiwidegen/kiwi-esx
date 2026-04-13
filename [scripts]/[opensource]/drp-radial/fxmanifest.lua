

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'Demon ox_lib radial'
version '1.0.0'

dependencies {
    'ox_lib'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/init.lua',
    'client/clothing.lua',
    'client/elevator.lua',
    'client/vehicle.lua',
    'client/general.lua',
    'client/emotes.lua',
}

server_scripts {
    '@ox_lib/init.lua',
    'server/main.lua',
}
