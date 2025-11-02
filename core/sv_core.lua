RegisterServerEvent('GB-Base:ServerStart')
AddEventHandler('GB-Base:SeverStart', function()
    local civilian = source
    Citizen.CreateThread(function()
        local Identifier = GetPlayerIdentifiers(civilian)[1] -- This gets Steam:192913931
        if not Identifier then
            DropPlayer(civilian, "Identity Not Loaded") -- Removes player if not found.
        end
        return
    end)
end)

RegisterNetEvent('GB-Base:server:getObject')
AddEventHandler('GB-Base:server:getObject', function(callback)
    callback(GB)
end)

-- Commands
AddEventHandler('GB-Base:addCommand', function(command, callback, suggestion, args)
    GB.Functions.addCommand(command, callback, suggestion, args)
end)

AddEventHandler('GB-Base:addGroupCommand', function(command, group, callback, callbackfailed, suggestion, args)
    GB.Functions.addGroupCommand(command, group, callback, callbackfailed, suggestion, args)
end)

-- Callback server
RegisterServerEvent('GB-Base:server:triggerServerCallback')
AddEventHandler('GB-Base:server:triggerServerCallback', function(name, requestId, ...)
    local civilian = source

    GB.Functions.TriggerServerEvent(name, requestId, civilian, function(...)
        TriggerClientEvent('GB-Base:client:serverCallback', civilian, requestId, ...)
    end, ...)
end)