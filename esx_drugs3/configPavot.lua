Config = {}

Config.Locale = 'en'


Config.Delays = {
	PavotProcessing = 1000 * 10
}

Config.PavotDealerItems = {
	opium = 300
}

Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drug1s. Requires esx_license

Config.LicensePrices = {
	pavot_processing = {label = _U('license_pavot'), price = 15000}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
    PavotField = {coords = vector3(2811.71, 4763.63, 42.99), name = ("Champs de Pavot"), color = 40, sprite = 501, radius = 100.0},
    PavotProcessing = {coords = vector3(1711.420, -1677.12, 112.57), name = ("Extraction du latex"), color = 40, sprite = 478, radius = 10.0,}, 
	
    PavotDealer = {coords = vector3(756.31, -626.48, 28.88), name = ("Revente Opium"), color = 40, sprite = 500, radius = 25.0},	
}