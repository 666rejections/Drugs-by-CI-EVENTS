ESX = nil
local playersProcessingPavot = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_drugs3:sellPavot')
AddEventHandler('esx_drugs3:sellPavot', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.PavotDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs3: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		xPlayer.showNotification(_U('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
	xPlayer.showNotification(_U('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
end)

ESX.RegisterServerCallback('esx_drugs3:buyLicense', function(source, cb, licenseName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local license = Config.LicensePrices[licenseName]

	if license then
		if xPlayer.getMoney() >= license.price then
			xPlayer.removeMoney(license.price)

			TriggerEvent('esx_license:addLicense', source, licenseName, function()
				cb(true)
			end)
		else
			cb(false)
		end
	else
		print(('esx_drugs3: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs3:pickedUpPavot')
AddEventHandler('esx_drugs3:pickedUpPavot', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem('pavot', 1) then
		xPlayer.addInventoryItem('pavot', 1)
	else
		xPlayer.showNotification(_U('pavot_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs3:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs3:processPavot')
AddEventHandler('esx_drugs3:processPavot', function()
	if not playersProcessingPavot[source] then
		local _source = source

		playersProcessingPavot[_source] = ESX.SetTimeout(Config.Delays.PavotProcessing, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xPavot = xPlayer.getInventoryItem('pavot')

			if xPavot.count > 3 then
				if xPlayer.canSwapItem('pavot', 3, 'pavot_pooch', 1) then
					xPlayer.removeInventoryItem('pavot', 3)
					xPlayer.addInventoryItem('pavot_pooch', 1)

					xPlayer.showNotification(_U('pavot_processed'))
				else
					xPlayer.showNotification(_U('pavot_processingfull'))
				end
			else
				xPlayer.showNotification(_U('pavot_processingenough'))
			end

			playersProcessingPavot[_source] = nil
		end)
	else
		print(('esx_drugs3: %s attempted to exploit pavot processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingPavot[playerId] then
		ESX.ClearTimeout(playersProcessingPavot[playerId])
		playersProcessingPavot[playerId] = nil
	end
end

RegisterServerEvent('esx_drugs3:cancelProcessing')
AddEventHandler('esx_drugs3:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
