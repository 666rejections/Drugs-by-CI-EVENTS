local spawnedPavots = 0
local pavotPlants = {}
local isPickingUp, isProcessing = false, false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.CircleZones.PavotField.coords, true) < 50 then
			SpawnPavotPlants()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.PavotProcessing.coords, true) < 1 then
			if not isProcessing then
				ESX.ShowHelpNotification(_U('pavot_processprompt'))
			end

			if IsControlJustReleased(0, 38) and not isProcessing then
				if Config.LicenseEnable then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasProcessingLicense)
						if hasProcessingLicense then
							ProcessPavot()
							
							TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
							
							
							
						else
							OpenBuyLicenseMenu('pavot_processing')
						end
					end, GetPlayerServerId(PlayerId()), 'pavot_processing')
				else
					ProcessPavot()
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function ProcessPavot()
	isProcessing = true

	ESX.ShowNotification(_U('pavot_processingstarted'))
	TriggerServerEvent('esx_drugs3:processPavot')
	local timeLeft = Config.Delays.PavotProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.PavotProcessing.coords, false) > 4 then
			ESX.ShowNotification(_U('pavot_processingtoofar'))
			TriggerServerEvent('esx_drugs3:cancelProcessing')
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

		for i=1, #pavotPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(pavotPlants[i]), false) < 1 then
				nearbyObject, nearbyID = pavotPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then
			if not isPickingUp then
				ESX.ShowHelpNotification(_U('pavot_pickupprompt'))
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_drugs3:canPickUp', function(canPickUp)
					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(pavotPlants, nearbyID)
						spawnedPavots = spawnedPavots - 1
		
						TriggerServerEvent('esx_drugs3:pickedUpPavot')
					else
						ESX.ShowNotification(_U('pavot_inventoryfull'))
					end

					isPickingUp = false
				end, 'pavot')
			end
		else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(pavotPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnPavotPlants()
	while spawnedPavots < 25 do
		Citizen.Wait(0)
		local pavotCoords = GeneratePavotCoords()

		ESX.Game.SpawnLocalObject('prop_plant_cane_01a', pavotCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(pavotPlants, obj)
			spawnedPavots = spawnedPavots + 1
		end)
	end
end

function ValidatePavotCoord(plantCoord)
	if spawnedPavots > 0 then
		local validate = true

		for k, v in pairs(pavotPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.PavotField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GeneratePavotCoords()
	while true do
		Citizen.Wait(1)

		local pavotCoordX, pavotCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		pavotCoordX = Config.CircleZones.PavotField.coords.x + modX
		pavotCoordY = Config.CircleZones.PavotField.coords.y + modY

		local coordZ = GetCoordZ(pavotCoordX, pavotCoordY)
		local coord = vector3(pavotCoordX, pavotCoordY, coordZ)

		if ValidatePavotCoord(coord) then
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
