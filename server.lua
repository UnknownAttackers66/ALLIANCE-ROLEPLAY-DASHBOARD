local ESX, QBCore

local function detectFramework()
    if Config.Framework == 'esx' or Config.Framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            local ok, obj = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if ok and obj then
                ESX = obj
                return 'esx'
            end
        end
    end

    if Config.Framework == 'qb' or Config.Framework == 'auto' then
        if GetResourceState('qb-core') == 'started' then
            local ok, obj = pcall(function()
                return exports['qb-core']:GetCoreObject()
            end)
            if ok and obj then
                QBCore = obj
                return 'qb'
            end
        end
    end

    return 'standalone'
end

local framework = detectFramework()

local function getIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, identifier in ipairs(identifiers) do
        if identifier:sub(1, 6) == 'license' then
            return identifier
        end
    end
    return identifiers[1] or 'unknown'
end

local function getPlaytime(src)
    -- Framework-independent fallback. Replace with your own saved playtime
    -- if your server already stores total hours.
    local minutes = Player(src).state and Player(src).state.playtime
    if type(minutes) == 'number' then
        return string.format('%.1fh', minutes / 60)
    end
    return '0h'
end

local function getJob(src)
    if framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getJob then
            local job = xPlayer.getJob()
            return {
                name = job.name,
                label = job.label,
                grade = job.grade,
                gradeLabel = job.grade_label
            }
        end
    elseif framework == 'qb' and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if player and player.PlayerData and player.PlayerData.job then
            local job = player.PlayerData.job
            return {
                name = job.name,
                label = job.label,
                grade = job.grade and job.grade.level or 0,
                gradeLabel = job.grade and job.grade.name or ''
            }
        end
    end
    return nil
end

RegisterNetEvent('alliance_dashboard:requestData', function()
    local src = source
    local player = Player(src)
    local job = getJob(src)

    local data = {
        player = {
            id = src,
            name = GetPlayerName(src) or 'Player',
            identifier = getIdentifier(src),
            ping = GetPlayerPing(src),
            playtime = getPlaytime(src),
            job = job
        },
        server = {
            players = #GetPlayers(),
            maxPlayers = GetConvarInt('sv_maxclients', 48),
            framework = framework
        }
    }

    TriggerClientEvent('alliance_dashboard:clientData', src, data)
end)
