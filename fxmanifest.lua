fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'iSeeEthan'
description 'A simple menu for RedM'
version '1.0.0'

-- needed for jo_libs
lua54 'yes'

shared_scripts {
    '@jo_libs/init.lua',
}

server_scripts {
    'server/server.lua',
}

client_scripts {
    'client/config.lua',
    'client/main.lua',
}

ui_page 'nui://jo_libs/nui/menu/index.html'

dependencies {
    'jo_libs',
}