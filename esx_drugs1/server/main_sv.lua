ESX = nil
local playersProcessingCoke = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_drugs1:sellCoke')
AddEventHandler('esx_drugs1:sellCoke', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.CokeDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs1: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
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

ESX.RegisterServerCallback('esx_drugs1:buyLicense', function(source, cb, licenseName)
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
		print(('esx_drugs1: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs1:pickedUpCoke')
AddEventHandler('esx_drugs1:pickedUpCoke', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem('coke', 1) then
		xPlayer.addInventoryItem('coke', 1)
	else
		xPlayer.showNotification(_U('coke_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs1:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs1:processCoke')
AddEventHandler('esx_drugs1:processCoke', function()
	if not playersProcessingCoke[source] then
		local _source = source

		playersProcessingCoke[_source] = ESX.SetTimeout(Config.Delays.CokeProcessing, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xCoke = xPlayer.getInventoryItem('coke')

			if xCoke.count > 3 then
				if xPlayer.canSwapItem('coke', 3, 'coke_pooch', 1) then
					xPlayer.removeInventoryItem('coke', 3)
					xPlayer.addInventoryItem('coke_pooch', 1)

					xPlayer.showNotification(_U('coke_processed'))
				else
					xPlayer.showNotification(_U('coke_processingfull'))
				end
			else
				xPlayer.showNotification(_U('coke_processingenough'))
			end

			playersProcessingCoke[_source] = nil
		end)
	else
		print(('esx_drugs1: %s attempted to exploit coke processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingCoke[playerId] then
		ESX.ClearTimeout(playersProcessingCoke[playerId])
		playersProcessingCoke[playerId] = nil
	end
end

RegisterServerEvent('esx_drugs1:cancelProcessing')
AddEventHandler('esx_drugs1:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
