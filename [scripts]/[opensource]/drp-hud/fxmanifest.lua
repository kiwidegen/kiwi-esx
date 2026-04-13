fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'drp hud'
version '2.0.0'

-- Shared
shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

-- Client
client_scripts {
    'client/utils.lua',
    'client/modules/*.lua',
    'client/main.lua'
}

-- Server
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/*.lua',
    'server/main.lua',
    'items/*.lua',
    'client/utils/v2_settings.js'
}

-- UI
ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/**/*'
}

-- Escrow protection (protects all Lua files except config.lua)
escrow_ignore {
    'config.lua'
}

dependency '/assetpacks'
