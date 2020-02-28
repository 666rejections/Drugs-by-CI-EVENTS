Config = {}

Config.Locale = 'en'


Config.Delays = {
	LithiumProcessing = 1000 * 10
}

Config.LithiumDealerItems = {
	batterie = 20
}

Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drug1s. Requires esx_license

Config.LicensePrices = {
	lithium_processing = {label = _U('license_lithium'), price = 15000}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
    LithiumField = {coords = vector3(199.06, 6949.01, 10.50), name = ("Dépôts de vieille batteries"), color = 40, sprite = 501, radius = 100.0},
    LithiumProcessing = {coords = vector3(1486.64, 1132.06, 114.33), name = ("Recyclage batteries"), color = 40, sprite = 478, radius = 10.0,}, 
	
    LithiumDealer = {coords = vector3(-1053.61, -2648.65, 17.83), name = ("Revente Batterie"), color = 6, sprite = 378, radius = 25.0},	
}