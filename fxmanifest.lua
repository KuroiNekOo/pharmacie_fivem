fx_version 'cerulean'
game 'gta5'

name 'pharmacie'
description 'Systeme de maladies et pharmacie'
author 'Custom'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory'
}
