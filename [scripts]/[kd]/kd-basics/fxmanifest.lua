fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kd-basics'
description 'Core gameplay modules'
version '1.0.0'

dependencies {
    'ox_lib',
    'es_extended',
    'ox_target',
    'pma-voice',
}

data_file 'DLC_POP_GROUPS' 'popgroups.ymt'

ui_page 'html/seatbelt.html'

files {
    'popgroups.ymt',
    'html/seatbelt.html',
    'audiodirectory/seatbelt_sounds/*.wav',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/ids.lua',
    'client/clothing.lua',
    'client/basics.lua',
    'client/bikes.lua',
    'client/bikeguns.lua',
    'client/binoculars.lua',
    'client/carry.lua',
    'client/crouchprone.lua',
    'client/density.lua',
    'client/friendlypeds.lua',
    'client/helicam.lua',
    'client/ambientaudio.lua',
    'client/antipeek.lua',
    'client/maxspeed.lua',
    'client/offroadhandling.lua',
    'client/f8.lua',
    'client/trunk.lua',
    'client/repair.lua',
    'client/repairkit.lua',
    'client/handsup.lua',
    'client/pointing.lua',
    'client/seatbelt.lua',
    'client/tackle.lua',
    'client/takehostage.lua',
    'client/voicecircle.lua',
    'client/zipties.lua',
}

server_scripts {
    'server/sv_items.lua',
    'server/sv_carry.lua',
    'server/sv_f8.lua',
    'server/sv_tackle.lua',
    'server/sv_takehostage.lua',
    'server/sv_zipties.lua',
}
