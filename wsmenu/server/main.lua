ESX = exports["es_extended"]:getSharedObject()



RegisterCommand("sm",  function(source, args, rawCommandString)
   local xPlayer = ESX.GetPlayerFromId(source)
   	if xPlayer.getGroup() ~= "user" then
      TriggerClientEvent('opensnmenu', source)
	end
end)

RegisterNetEvent('sm:dvrange')
AddEventHandler('sm:dvrange', function(xPlayer)
   local xPlayer = ESX.GetPlayerFromId(source)
	local PedVehicle = GetVehiclePedIsIn(GetPlayerPed(xPlayer.source), false)
	if DoesEntityExist(PedVehicle) then
		DeleteEntity(PedVehicle)
	end
	local Vehicles = ESX.OneSync.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(xPlayer.source)), 5.0)
	for i=1, #Vehicles do 
		local Vehicle = NetworkGetEntityFromNetworkId(Vehicles[i])
		if DoesEntityExist(Vehicle) then
			DeleteEntity(Vehicle)
		end
	end
end)
