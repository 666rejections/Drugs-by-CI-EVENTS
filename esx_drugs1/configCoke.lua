Config = {}

Config.Locale = 'en'


Config.Delays = {
	CokeProcessing = 1000 * 10
}

Config.CokeDealerItems = {
	coke_pooch = 100,
	coke_cut_pooch = 1000,
	crack_pooch = 120
}




Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drug1s. Requires esx_license

Config.LicensePrices = {
	coke_processing = {label = _U('license_coke'), price = 15000}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
    CokeField = {coords = vector3(-1153.72, 39.17,  46.25)},
    CokeProcessing = {coords = vector3(-2344.73, 257.15, 169.60)}, 
	
    CokeDealer = {coords = vector3(383.218, -1024.566, 29.536), name = ("Revente drogues dure"), color = 6, sprite = 378, radius = 25.0},	
	
}