fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'Demon RP Extras - Quality of life and gameplay enhancement scripts'
version '2.0.0'

-- Dependencies
shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/**/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*.lua'
}

-- Audio files for seatbelt
ui_page 'client/seatbelt_sounds.html'

files {
    'audiodirectory/seatbelt_sounds/*.wav',
    'client/seatbelt_sounds.html'
}

-- Dependencies list
dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib'
}
