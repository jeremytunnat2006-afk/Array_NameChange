fx_version 'cerulean'
game 'gta5'

author 'Array Solution'
description 'Array Solution - NameChange'
version '1.0.0'

ui_page 'ui/index.html'

shared_script 'config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/logo.png'
}