function GB.Core.Start(self)
    Citizen.CreateThread(function()
        while true do
            if NetworkIsSessionStarted() then
                TriggerEvent('GB-Core:Start')
                TriggerServerEvent('GB-Core:ServerStart')
                break
            end
        end
    end)
end
GB.Core.Start(self)

RegisterNetEvent('GB-Core:client:getObject')
AddEventHandler('GB-Core:client:getObject', function(callback)
    callback(GB)
    print('Called Back ' .. GB .. )
end)
