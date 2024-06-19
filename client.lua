local spawnedVehicle = nil

-- Function to spawn vehicle
local function spawnVehicle(model)
    local playerPed = PlayerPedId()
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end

    local vehicle = CreateVehicle(model, Config.SpawnCoords.x, Config.SpawnCoords.y, Config.SpawnCoords.z, Config.SpawnHeading, true, false)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    SetModelAsNoLongerNeeded(model)

    spawnedVehicle = vehicle
    exports['ox_lib']:showTextUI("Tryck [E] för att ta bort fordon", { position = "right-center" })
end

-- Function to delete vehicle
local function deleteVehicle()
    if spawnedVehicle then
        DeleteVehicle(spawnedVehicle)
        spawnedVehicle = nil
        exports['ox_lib']:showTextUI("Fordon borttaget", { position = "right-center" })
        Wait(1500)
        exports['ox_lib']:hideTextUI()
    end
end

-- Open the context menu
local function openVehicleMenu()
    print("Öppnar meny")
    local options = {}

    for _, vehicle in ipairs(Config.Vehicles) do
        table.insert(options, {
            title = vehicle.label,
            description = "Spawn " .. vehicle.label,
            event = 'spawnVehicle',
            args = { model = vehicle.model }
        })
    end

    exports['ox_lib']:registerContext({
        id = 'vehicle_menu',
        title = 'Välj ett fordon',
        options = options
    })

    exports['ox_lib']:showContext('vehicle_menu')
end

RegisterNetEvent('spawnVehicle')
AddEventHandler('spawnVehicle', function(data)
    spawnVehicle(data.model)
end)

-- Main thread to check for player proximity to the menu coordinates
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.MenuCoords)
        
        if distance < 3.0 then
            if spawnedVehicle then
                exports['ox_lib']:showTextUI("Tryck [E] för att ta bort fordon", { position = "right-center" })
                if IsControlJustReleased(0, 38) then -- 'E' key
                    print("Fordon Bort taget")
                    deleteVehicle()
                end
            else
                exports['ox_lib']:showTextUI("Tryck [E] för att ta fram fordon", { position = "right-center" })
                if IsControlJustReleased(0, 38) then -- 'E' key
                    print("Öppnar meny")
                    openVehicleMenu()
                end
            end
        else
            exports['ox_lib']:hideTextUI()
        end
    end
end)

local function drawMenuMarker()
    local coords = Config.MenuCoords
    local markerType = 36 -- Regular circle marker
    local scale = 1.0
    local color = { r = 255, g = 0, b = 0, a = 150 } -- Red color with some transparency

    DrawMarker(markerType, coords.x, coords.y, coords.z - 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
end

-- Register marker drawing in main thread
CreateThread(function()
    while true do
        Wait(0)
        drawMenuMarker()
    end
end)