local isOpen = false

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 57) then -- F10
            ToggleDashboard()
        end
    end
end)

function ToggleDashboard()
    isOpen = not isOpen

    SetNuiFocus(isOpen, isOpen)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = isOpen and 'open' or 'close'
    })

    if isOpen then
        TriggerServerEvent('alliance_dashboard:requestData')
    end
end

RegisterNetEvent('alliance_dashboard:clientData', function(data)
    SendNUIMessage({
        action = 'data',
        data = data
    })
end)

RegisterNUICallback('requestData', function(_, cb)
    TriggerServerEvent('alliance_dashboard:requestData')
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
