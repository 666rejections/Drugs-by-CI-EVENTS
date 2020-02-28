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
	'configLithium.lua',
	'server/main_lithium_sv.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'configLithium.lua',
	'client/main_lithium_cl.lua',
	'client/lithium.lua'
}

dependencies {
	'es_extended'
}
