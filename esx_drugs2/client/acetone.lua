local spawnedAcetones = 0
local acetonePlants = {}
local isPickingUp, isProcessing = false, false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.CircleZones.AcetoneField.coords, true) < 50 then
			SpawnAcetonePlants()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.AcetoneProcessing.coords, true) < 1 then
			if not isProcessing then
				ESX.ShowHelpNotification(_U('acetone_processprompt'))
			end

			if IsControlJustReleased(0, 38) and not isProcessing then
				if Config.LicenseEnable then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasProcessingLicense)
						if hasProcessingLicense then
							ProcessAcetone()
							
							TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
							
							
							
						else
							OpenBuyLicenseMenu('acetone_processing')
						end
					end, GetPlayerServerId(PlayerId()), 'acetone_processing')
				else
					ProcessAcetone()
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function ProcessAcetone()
	isProcessing = true

	ESX.ShowNotification(_U('acetone_processingstarted'))
	TriggerServerEvent('esx_drugs2:processAcetone')
	local timeLeft = Config.Delays.AcetoneProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.AcetoneProcessing.coords, false) > 4 then
			ESX.ShowNotification(_U('acetone_processingtoofar'))
			TriggerServerEvent('esx_drugs2:cancelProcessing')
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

		for i=1, #acetonePlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(acetonePlants[i]), false) < 1 then
				nearbyObject, nearbyID = acetonePlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then
			if not isPickingUp then
				ESX.ShowHelpNotification(_U('acetone_pickupprompt'))
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_drugs2:canPickUp', function(canPickUp)
					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(acetonePlants, nearbyID)
						spawnedAcetones = spawnedAcetones - 1
		
						TriggerServerEvent('esx_drugs2:pickedUpAcetone')
					else
						ESX.ShowNotification(_U('acetone_inventoryfull'))
					end

					isPickingUp = false
				end, 'acetone')
			end
		else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(acetonePlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnAcetonePlants()
	while spawnedAcetones < 25 do
		Citizen.Wait(0)
		local acetoneCoords = GenerateAcetoneCoords()

		ESX.Game.SpawnLocalObject('prop_coke_block_half_b', acetoneCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(acetonePlants, obj)
			spawnedAcetones = spawnedAcetones + 1
		end)
	end
end

function ValidateAcetoneCoord(plantCoord)
	if spawnedAcetones > 0 then
		local validate = true

		for k, v in pairs(acetonePlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.AcetoneField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateAcetoneCoords()
	while true do
		Citizen.Wait(1)

		local acetoneCoordX, acetoneCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		acetoneCoordX = Config.CircleZones.AcetoneField.coords.x + modX
		acetoneCoordY = Config.CircleZones.AcetoneField.coords.y + modY

		local coordZ = GetCoordZ(acetoneCoordX, acetoneCoordY)
		local coord = vector3(acetoneCoordX, acetoneCoordY, coordZ)

		if ValidateAcetoneCoord(coord) then
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
