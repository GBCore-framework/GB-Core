-- Call GB.
GB.Functions = GB.Functions or {}
GB.Commands = {}
GB.CommandSuggestions = {}
GB.ServerCallbacks = GB.ServerCallbacks or {}
GB.ServerCallback = {}

GB.Functions.RegisterServerCallback = function(name, cb)
    GB.ServerCallback[name] = cb
end

GB.Functions.TriggerServerCallback = function(name, requestId, source, cb, ...)
    if GB.ServerCallbacks[name] ~= nil then
        GB.ServerCallbacks[name](source, cb, ...)
    end
end

GB.Functions.getPlayer = function(source)
    if GB.Players[source] ~= nil then
        return GB.Players[source]
    end
end

GB.Functions.AdminPlayer = function(source) -- Admin
    if GB.APlayers[source] ~= nil then
        return GB.APlayers[source]
    end
end

RegisterServerEvent('GB-Core:server:UpdatePlayer')
AddEventHandler('GB-Core:server:UpdatePlayer', function()
    local civilian = source
    local player = GB.Functions.GetPlayer(civilian)
    if player then
        Player.Functions.Save()
    end
end)

-- Character SQL
GB.Functions.CreatePlayer = function(source, Data)
    exports['ghmattimysql']:execute('INSERT INTO players (`identifier`, `license`, `name`, `cash`, `bank`) VALUES (@identifier, @license, @name, @cash, @bank)' {
        ['identifier'] = Data.identifier,
        ['license'] = Data.license,
        ['name'] = Data.name,
        ['cash'] = Data.cash,
        ['bank'] = Data.bank
    })

    print('[GB-Core] ' ..Data.name.. ' was created successfully')

    GB.Functions.LoadPlayer(source, Data)
end

GB.Functions.LoadPlayer = function(source, pData, cid)
    local src = source
    local identifier = pData.identifier

    Citizen.Wait(7)
    exports['ghmattimysql']:execute('SELECT * FROM players WHERE identifier = @identifier AND cid = @cid', {['@identifier'] = identifier, ['@cid'] = cid}, function(result)
        
        -- Server
        exports['ghmattimysql']:execute('UPDATE players SET name = @name WHERE identifier = @identifier AND cid = @cid', { ['@identifier']  = identifier, ['@name'] = pData.name, ['@cid'] = cid})

        GB.Player.LoadData(source, identifier, cid)
        Citizen.Wait(7)
        local player = GB.Functions.getPlayer(source)
        TriggerClientEvent('GB-SetCharacterData', source {
            identifier = result[1].identifier,
            license = result[1].license,
            cid = result[1].cid,
            name = result[1].name,
            cash = result[1].cash,
            bank = result[1].bank,
            citizenId = result[1].citizenId,
        })

        TriggerClientEvent('GB-Core:PlayerLoaded', source)
        -- TODO: TriggerClientEvent UI
        -- TODO: Trigger for Admin
    end)
end

GB.Functions.addGroupCommand = function(command, group, callback, callbackfailed, suggestion, arguments)
    GB.Commands[command] = {}
    GB.Commands[command].perm = math.maxinteger
    GB.Commands[command].group = group
    GB.Commands[command].cmd = callback
    GB.Commands[command].callbackfailed = callbackfailed
    GB.Commands[command].arguments = arguments or -1

    if suggestion then
        if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
        if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end
        
        GB.CommandsSuggestion[command] = suggestion
    end

    ExecuteCommand('add_ace group.' .. group .. ' command.' .. command .. ' allow')

    RegisterCommand(command, function(source, args)
        local Source = source
        local pData = GB.Functions.AgetPlayer(Source)

        if (source ~= 0) then
            if pData ~= nil then
                if pData.Data.usergroup == GB.Commands[command].group then
                    if ((#args <= GB.Commands[command].arguments and #args == GB.Commands[command].arguments) or GB.Commands[command].arguments == -1) then
                        callback(source, args, GB.Players[source])
                    end
                else
                    callbackfailed(source, args, GB.Players[source])
                end
            end
        else
            if ((#args <= GB.Commands[command].arguments and #args == GB.Commands[command].arguments) or GB.Commands[command].arguments == -1) then
                callback(source, args, GB.Players[source])
            end
        end
    end, true)
end

-- Usergroups for Admin
GB.Functions.setupAdmin = function(player, group)
    local identifier = player.Data.identifier
    local pCid = player.Data.cid
    exports['ghmattimysql']:execute('DELETE FROM ranking WHERE identifier = @identifier', {['@identifier'] = identifier})
    Wait(1000)

    exports['ghmattimysql']:execute('INSERT INTO ranking (`usergroup`, `identifier`) VALUES (@usergroup, @identifier)', {
        ['@usergroup'] = group,
        ['@identifier'] = identifier
    })
    print('[GB-Core] Function group: ' .. group)
    TriggerClientEvent('GB-Admin:updateGroup', player.Data.PlayerId, group)
end

GB.Function.BuildCommands = function(source)
    local Source = source
    for k, v in pairs(GB.CommandsSuggestion) do
        TriggerClientEvent('chat:addSuggestion', src, '/'..k, v.help, v.params)
    end
end

GB.Function.ClearCommands = function(source)
    local Source = source
    for k, v in pairs(GB.CommandsSuggestion) do
        TriggerClientEvent('chat:removeSuggestion', src, '/'..k, v.help, v.params)
    end
end