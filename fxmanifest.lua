fx_version 'adamant'

game 'gta5'

author 'BabyDrill'

name 'wolf_death-system'

version '1.0'

description 'The best FREE Death System for Academy https://discord.gg/yjPGt2YMcg'

ui_page 'nui/index.html'

lua54 'yes'

client_script "client.lua"
server_scripts {
	"config.lua",
	"server.lua"
}

files {
	'nui/*.html',
    'nui/*.js',
    'nui/*.css'
}