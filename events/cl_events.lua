-- Call GB.

GB.Functions = GB.Functions or {}
GB.RequestId = GB.RequestId or {}
GB.ServerCallback = GB.ServerCallback or {}
GB.ServerCallbacks = {}
GB.CurrentRequestId = 0

GB.Functions.GetKey = function(key)
    local Keys = {
        ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
        ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
        ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
        ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
        ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
        ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
        ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
        ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
    }
    return Keys[key]
end

GB.Functions.GetPlayerData = function(source) -- get all data from database for the player
    return GB.GetPlayerData
end

-- Type Admin [ Basic ]
GB.Functions.DeleteVehicle = function(vehicle)
    SetEntityAsMissionEntity(vehicle, false, true)
    DeleteVehicle(vehicle)
end

GB.Functions.GetVehicleDirection = function()
    local civilian = PlayerPedId()
    local civilianCoords = GetEntityCoords(civilian)
    local inDirection = GetOffsetFromEntityInWorldCoords(civilian, 0, 10, 0)
    local rayHandle = StartShapeTestRay(civilianCoords, inDirection, 10, civilian, 0)
    local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and GetEntityType(entityType) == 2 then
        return entityHit
    end

    return nill
end

GB.Functions.DeleteObject = function(object)
    SetEntityAsMissionEntity(object, false, true)
    DeleteObject(object)
end

GB.Functions.GetClosestPlayer = function(coords)
    local players = GB.Functions.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = coords
    local usePlayerPed = false
    local civilian = PlayerPedId()
    local civilianId = PlayerId()

    if coords == nil then
        usePlayerPed = true
        coords = GetEntityCoords(civilian)
    end

    for i = 1, #players, 1 do
        local target = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(target)
            local distance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance

end

-- Callbacks
GB.Functions.TriggerServerCallback = function(name, cb, ...)
    GB.ServerCallbacks[GB.CurrentRequestId] = cb

    TriggerServerEvent('GB-Core:server:triggerServerCallback', name, GB.CurrentRequestId, ...)

    if GB.CurrentRequestId < 65535 then
        GB.CurrentRequestId = GB.CurrentRequestId + 1
    else
        GB.CurrentRequestId = 0
    end
end

GB.Functions.GetPlayers = function()
    local MaxPlayer = 120
    local players = {}

    for i=0, MaxPlayer, 1 do
        local civilian = GetPlayerPed(1)
        if DoesEntityExist(civilian) then
            table.insert(players, i)
        end
    end
    return players
end

RegisterNetEvent('GB-Core:client:serverCallback')
AddEventHandler('GB-Core:client:serverCallback', function(requestId, ...)
    GB.ServerCallbacks[requestId](...)
    GB.ServerCallbacks[requestId] = nil
end)

-- Other
RegisterNetEvent('GB-SetCharacterData')
AddEventHandler('GB-SetCharacterData', function(Player)
    pData = Player
end)