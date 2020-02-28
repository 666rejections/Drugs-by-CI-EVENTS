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
	'configPavot.lua',
	'server/main_pavot_sv.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'configPavot.lua',
	'client/main_pavot_cl.lua',
	'client/pavot.lua'
}

dependencies {
	'es_extended'
}
