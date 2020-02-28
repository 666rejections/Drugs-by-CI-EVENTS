local spawnedLithiums = 0
local lithiumPlants = {}
local isPickingUp, isProcessing = false, false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.CircleZones.LithiumField.coords, true) < 50 then
			SpawnLithiumPlants()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.LithiumProcessing.coords, true) < 1 then
			if not isProcessing then
				ESX.ShowHelpNotification(_U('lithium_processprompt'))
			end

			if IsControlJustReleased(0, 38) and not isProcessing then
				if Config.LicenseEnable then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasProcessingLicense)
						if hasProcessingLicense then
							ProcessLithium()
							
							TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
							
							
							
						else
							OpenBuyLicenseMenu('lithium_processing')
						end
					end, GetPlayerServerId(PlayerId()), 'lithium_processing')
				else
					ProcessLithium()
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function ProcessLithium()
	isProcessing = true

	ESX.ShowNotification(_U('lithium_processingstarted'))
	TriggerServerEvent('esx_drugs4:processLithium')
	local timeLeft = Config.Delays.LithiumProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.LithiumProcessing.coords, false) > 4 then
			ESX.ShowNotification(_U('lithium_processingtoofar'))
			TriggerServerEvent('esx_drugs4:cancelProcessing')
			break
		end
	end

	isProcessing = false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #lithiumPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(lithiumPlants[i]), false) < 1 then
				nearbyObject, nearbyID = lithiumPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then
			if not isPickingUp then
				ESX.ShowHelpNotification(_U('lithium_pickupprompt'))
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_drugs4:canPickUp', function(canPickUp)
					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(lithiumPlants, nearbyID)
						spawnedLithiums = spawnedLithiums - 1
		
						TriggerServerEvent('esx_drugs4:pickedUpLithium')
					else
						ESX.ShowNotification(_U('lithium_inventoryfull'))
					end

					isPickingUp = false
				end, 'lithium')
			end
		else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(lithiumPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnLithiumPlants()
	while spawnedLithiums < 25 do
		Citizen.Wait(0)
		local lithiumCoords = GenerateLithiumCoords()

		ESX.Game.SpawnLocalObject('prop_battery_01', lithiumCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(lithiumPlants, obj)
			spawnedLithiums = spawnedLithiums + 1
		end)
	end
end

function ValidateLithiumCoord(plantCoord)
	if spawnedLithiums > 0 then
		local validate = true

		for k, v in pairs(lithiumPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.LithiumField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateLithiumCoords()
	while true do
		Citizen.Wait(1)

		local lithiumCoordX, lithiumCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		lithiumCoordX = Config.CircleZones.LithiumField.coords.x + modX
		lithiumCoordY = Config.CircleZones.LithiumField.coords.y + modY

		local coordZ = GetCoordZ(lithiumCoordX, lithiumCoordY)
		local coord = vector3(lithiumCoordX, lithiumCoordY, coordZ)

		if ValidateLithiumCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 43.0
end
