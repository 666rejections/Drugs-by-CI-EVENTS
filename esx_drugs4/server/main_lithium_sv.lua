ESX = nil
local playersProcessingLithium = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_drugs4:sellLithium')
AddEventHandler('esx_drugs4:sellLithium', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.LithiumDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs4: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
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

ESX.RegisterServerCallback('esx_drugs4:buyLicense', function(source, cb, licenseName)
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
		print(('esx_drugs4: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs4:pickedUpLithium')
AddEventHandler('esx_drugs4:pickedUpLithium', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem('lithium', 1) then
		xPlayer.addInventoryItem('lithium', 1)
	else
		xPlayer.showNotification(_U('lithium_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs4:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs4:processLithium')
AddEventHandler('esx_drugs4:processLithium', function()
	if not playersProcessingLithium[source] then
		local _source = source

		playersProcessingLithium[_source] = ESX.SetTimeout(Config.Delays.LithiumProcessing, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xLithium = xPlayer.getInventoryItem('lithium')

			if xLithium.count > 3 then
				if xPlayer.canSwapItem('lithium', 3, 'lithium_pooch', 1) then
					xPlayer.removeInventoryItem('lithium', 3)
					xPlayer.addInventoryItem('lithium_pooch', 1)

					xPlayer.showNotification(_U('lithium_processed'))
				else
					xPlayer.showNotification(_U('lithium_processingfull'))
				end
			else
				xPlayer.showNotification(_U('lithium_processingenough'))
			end

			playersProcessingLithium[_source] = nil
		end)
	else
		print(('esx_drugs4: %s attempted to exploit lithium processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingLithium[playerId] then
		ESX.ClearTimeout(playersProcessingLithium[playerId])
		playersProcessingLithium[playerId] = nil
	end
end

RegisterServerEvent('esx_drugs4:cancelProcessing')
AddEventHandler('esx_drugs4:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
