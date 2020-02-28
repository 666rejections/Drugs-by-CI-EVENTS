ESX = nil
local playersProcessingAcetone = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_drugs2:sellAcetone')
AddEventHandler('esx_drugs2:sellAcetone', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.AcetoneDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs2: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
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

ESX.RegisterServerCallback('esx_drugs2:buyLicense', function(source, cb, licenseName)
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
		print(('esx_drugs2: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs2:pickedUpAcetone')
AddEventHandler('esx_drugs2:pickedUpAcetone', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem('acetone', 1) then
		xPlayer.addInventoryItem('acetone', 1)
	else
		xPlayer.showNotification(_U('acetone_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs2:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs2:processAcetone')
AddEventHandler('esx_drugs2:processAcetone', function()
	if not playersProcessingAcetone[source] then
		local _source = source

		playersProcessingAcetone[_source] = ESX.SetTimeout(Config.Delays.AcetoneProcessing, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xAcetone = xPlayer.getInventoryItem('acetone')

			if xAcetone.count > 3 then
				if xPlayer.canSwapItem('acetone', 3, 'acetone_pooch', 1) then
					xPlayer.removeInventoryItem('acetone', 3)
					xPlayer.addInventoryItem('acetone_pooch', 1)

					xPlayer.showNotification(_U('acetone_processed'))
				else
					xPlayer.showNotification(_U('acetone_processingfull'))
				end
			else
				xPlayer.showNotification(_U('acetone_processingenough'))
			end

			playersProcessingAcetone[_source] = nil
		end)
	else
		print(('esx_drugs2: %s attempted to exploit acetone processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingAcetone[playerId] then
		ESX.ClearTimeout(playersProcessingAcetone[playerId])
		playersProcessingAcetone[playerId] = nil
	end
end

RegisterServerEvent('esx_drugs2:cancelProcessing')
AddEventHandler('esx_drugs2:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
