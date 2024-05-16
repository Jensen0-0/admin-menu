ESX = exports["es_extended"]:getSharedObject()

local PlayerData = {}
local isMenuOpen = false
local isVehicleMenuOpen = false
local isTeleportMenuOpen = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function (xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('opensnmenu', function()
    OpenMenu()
end)

local options = {
    {label = "Staff outfit aan | uit", value = "shesje_aan"}, 
    {label = "Speler Opties", value = "player_menu"}, 
    {label = "Skin veranderen", value = "verander_skin"}, 
    {label = "Teleport Menu", value = "tp_menu"}, 
    {label = "Voertuig Menu", value = "vehicle_menu"}, 
}

local vehicleOptions = {
    {label = "Spawn Voertuig", value = "spawn_car"},  
    {label = "Repareer Voertuig", value = "fix_car"},  
    {label = "Verwijder Voertuig", value = "delete_vehicle"},  
    {label = "Verwijder Voertuigen In Aura", value = "dv_5"}, 
}

function OpenMenu()
    isMenuOpen = true

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_menu', {
        title = "Ws Staff Menu",
        align = "top-right",
        elements = options
    }, function(data, menu)
        isMenuOpen = false

        if data.current.value == 'shesje_aan' then
            TriggerServerEvent("staffzaak:ToggleClothing")
        end

        if data.current.value == 'player_menu' then
            ESX.UI.Menu.CloseAll()
            TriggerEvent('open:police:actionmenu')
        end

        if data.current.value == 'verander_skin' then
            VeranderSkin()
        end

        if data.current.value == 'vehicle_menu' then
            openVehicleMenu()
        end

        if data.current.value == 'tp_menu' then
            openTeleportMenu()
        end
    end,
    function(data, menu)
        menu.close()
        isMenuOpen = false
    end)

end

function openVehicleMenu()
    isVehicleMenuOpen = true

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
        title = "Woensel Voertuig Menu",
        align = "top-right",
        elements = vehicleOptions
    }, function(data, menu)
        isVehicleMenuOpen = false

        if data.current.value == 'spawn_car' then
            SpawnCar()
        end

        if data.current.value == 'fix_car' then
            FixCar()
        end

        if data.current.value == 'delete_vehicle' then
            DeleteCar()
        end

        if data.current.value == 'dv_5' then
            DvRange()
        end

    end, function(data, menu)
        menu.close()
        isVehicleMenuOpen = false
    end)
end

function openTeleportMenu()
    isTeleportMenuOpen = true
    local teleportOptions = {}

    for k, v in pairs(Config.teleports) do
        table.insert(teleportOptions, {label = k, value = k})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
        title = "Ws Voertuig Menu",
        align = "top-right",
        elements = teleportOptions
    }, function(data, menu)
        isTeleportMenuOpen = false

        local teleport = Config.teleports[data.current.value].pos
        SetEntityCoords(PlayerPedId(), teleport.x, teleport.y, teleport.z - 1)
        SetEntityHeading(PlayerPedId(), teleport.w)

    end, function(data, menu)
        menu.close()
        isTeleportMenuOpen = false
    end)
end

function HesjeAan()
    TriggerEvent('skinchanger:loadSkin', {
        sex          = 0,
        bproof_1     = 10,
        bproof_2     = 0,
    })
end

function HesjeUit()
    TriggerEvent('skinchanger:loadSkin', {
        sex          = 0,
        bproof_1     = 0,
        bproof_2     = 0,
    })
end

function FixCar()
    local vehicle
    if IsPedInAnyVehicle(PlayerPedId()) then
        vehicle = GetVehiclePedIsIn(PlayerPedId())
    else
        vehicle = ESX.Game.GetClosestVehicle()
    end
    if DoesEntityExist(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = 0
        while not NetworkHasControlOfEntity(vehicle) and timeout < 20 do
            Citizen.Wait(100)
            NetworkRequestControlOfEntity(vehicle)
            timeout = timeout + 1
        end
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleFixed(vehicle)
    
        SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle))
        SetVehicleOnGroundProperly(vehicle)
        exports['mythic_notify']:DoHudText('success', 'Je auto gemaakt!')
    else
        exports['mythic_notify']:DoHudText('error', 'Er is geen voertuig in de buurt!')
    end
end

function VeranderSkin()
    TriggerEvent('esx_skin:openSaveableMenu')
    TriggerEvent('esx_skin:save')
end

function SpawnCar()
    local ModelHash = "admincar"
    if not IsModelInCdimage(ModelHash) then return end
    RequestModel(ModelHash)
    while not HasModelLoaded(ModelHash) do
      Citizen.Wait(10)
    end
    local MyPed = PlayerPedId()
    local Vehicle = CreateVehicle(ModelHash, GetEntityCoords(MyPed), GetEntityHeading(MyPed), true, false)
    SetModelAsNoLongerNeeded(ModelHash)
    TaskWarpPedIntoVehicle(MyPed, Vehicle, -1)
end

function DeleteCar()
    local ped = PlayerPedId()
    local isInVehicle = IsPedInAnyVehicle(ped, false)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if isInVehicle then
        DeleteVehicle(vehicle)
        exports['mythic_notify']:DoHudText('success', 'Voeruig is verwijderd')
    else
        exports['mythic_notify']:DoHudText('error', 'Je zit niet in een voertuig!')
    end
end

function DvRange()
    TriggerServerEvent('sm:dvrange')
end

function TpMarker()
    local WaypointHandle = GetFirstBlipInfoId(8)

    if DoesBlipExist(WaypointHandle) then
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

                break
            end

            Citizen.Wait(5)
        end

        exports['mythic_notify']:DoHudText('error', 'Je bent ge tpd!')
    else
        exports['mythic_notify']:DoHudText('error', 'Je hebt geen waypoint geplaatst!')
    end
end

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, 318) and not isMenuOpen then
            ExecuteCommand('sm')
        end
        Citizen.Wait(10)
    end
end)
