fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Jim-Mining'
author 'Jimathy'
version '3.0.12'
description 'Mining Script (Cleaned & Modular)'

dependency 'jim_bridge'
server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
    'locales/*.lua',
    'config.lua',
    '@jim_bridge/starter.lua',
    'shared/*.lua',
}

client_scripts {
    'client/utils.lua',
    'client/mining.lua',
    'client/cracking.lua',
    'client/washing.lua',
    'client/dirt.lua',
    'client/main.lua'
}

server_scripts {
    'server/utils.lua',
    'server/rewards.lua',
    'server/repair.lua',
    'server/dirt.lua',
    'server/main.lua'
}