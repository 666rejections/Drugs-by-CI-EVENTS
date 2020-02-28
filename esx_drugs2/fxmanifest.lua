fx_version 'adamant'

game 'gta5'

description 'ESX Drugs'

version '2.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'configAcetone.lua',
	'server/main_sv.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'configAcetone.lua',
	'client/main_cl.lua',
	'client/acetone.lua'
}

dependencies {
	'es_extended'
}