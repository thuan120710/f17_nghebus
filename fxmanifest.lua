fx_version 'cerulean'
games { 'gta5' }

description 'f17_nghebus - Hệ thống Nghề Lái Xe Bus'
version '1.0.0'

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'ui/dist/thongbao_bus.mp3'
}

VoKy_AntiLoader {
    'client/client.lua'
}

client_scripts {
    'config/config.lua',
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/config.lua',
    'server/server.lua'
}
