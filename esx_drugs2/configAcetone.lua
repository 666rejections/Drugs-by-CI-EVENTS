Config = {}

Config.Locale = 'en'


Config.Delays = {
	AcetoneProcessing = 1000 * 10
}

Config.AcetoneDealerItems = {
	acetone_pooch = 10
}

Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drug1s. Requires esx_license

Config.LicensePrices = {
	acetone_processing = {label = _U('license_acetone'), price = 15000}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
    AcetoneField = {coords = vector3(1774.42, 3841.21, 30.32), name = ("Bloc d'Acétone"), color = 40, sprite = 501, radius = 100.0},
    AcetoneProcessing = {coords = vector3(-1161.727, -59.723, 44.994), name = ("Extractions Bloc d'Acétone"), color = 40, sprite = 478, radius = 10.0}, 
    AcetoneDealer = {coords = vector3(1253.78, -1978.83, 42.26), name = ("Revente Acétone"), color = 40, sprite = 500, radius = 25.0},	
}