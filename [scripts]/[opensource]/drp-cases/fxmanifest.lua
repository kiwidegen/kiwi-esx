fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KiwiDegen'
description 'DRP Cases - Modern Lootbox System with OX Inventory - ESX Legacy'
version '2.0.0'

ui_page 'html/ui.html'

shared_scripts {
    '@ox_lib/init.lua',
    'server/config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js',
    'html/case.mp3'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'drp-logs'
}
