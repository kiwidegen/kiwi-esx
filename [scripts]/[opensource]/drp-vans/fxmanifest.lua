fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'drp Vans Event'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}

use_experimental_fxv2_oal 'yes'

escrow_ignore {
    'shared/*.lua',
    'config.lua'
}
