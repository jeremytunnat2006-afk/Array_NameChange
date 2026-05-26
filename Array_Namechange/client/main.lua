local isMenuOpen = false

CreateThread(function()
    if Config.Blip.Enabled then
        local blip = AddBlipForCoord(Config.Location.Coords.x, Config.Location.Coords.y, Config.Location.Coords.z)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.Name)
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.Location.Coords)

        if dist < Config.Location.DrawDistance then
            wait = 0
            DrawMarker(
                Config.Marker.Type, 
                Config.Location.Coords.x, Config.Location.Coords.y, Config.Location.Coords.z - 1.0, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, 
                Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, Config.Marker.Color.a, 
                false, true, 2, false, nil, nil, false
            )

            if dist < Config.Location.InteractDistance then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("Drücke ~INPUT_CONTEXT~ um deine Identität zu ändern.")
                EndTextCommandDisplayHelp(0, false, true, -1)

                if IsControlJustReleased(0, 38) and not isMenuOpen then
                    openNameChangeUI()
                end
            end
        end
        Wait(wait)
    end
end)

function openNameChangeUI()
    if isMenuOpen then return end
    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end

RegisterNUICallback('confirmNameChange', function(data, cb)
    local firstname = data.firstname
    local lastname = data.lastname

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    isMenuOpen = false

    TriggerServerEvent('array_namechange:server:changeName', firstname, lastname)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    isMenuOpen = false
    cb('ok')
end)