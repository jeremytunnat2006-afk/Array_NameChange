local CurrentVersion = "1.0.0"
local GithubVersionURL = "https://raw.githubusercontent.com/DEIN_NAME/Array_NameChange/main/version.txt"

local QBCore = nil
local ESX = nil

-- Framework Initialisierung
if Config.Framework == 'auto' then
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    end
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

CreateThread(function()
    print("^0")
    print("^5      ___                           ^0")
    print("^5     /   |  ______________ ___  __  ^0")
    print("^5    / /| | / ___/ ___/ __ `| / / /  ^0")
    print("^5   / ___ |/ /  / /  / /_/ | /_/ /   ^0")
    print("^5  /_/  |_/_/  /_/   \\__,_/\\__, /    ^0")
    print("^5                         /____/     ^0")
    print("^7              S O L U T I O N       ^0")
    print("^0===================================================^0")
    print("^2[SUCCESS] ^0Script ^5Array_NameChange^0 (v"..CurrentVersion..") gestartet!^0")
    print("^0===================================================^0")

    -- Hier wurde die Anzeige in der Serverliste (Convars) angepasst:
    SetConvarServerInfo("Array Solution", "https://discord.gg/zdAjm7KGTX")

    PerformHttpRequest(GithubVersionURL, function(err, text, headers)
        if err == 200 then
            local remoteVersion = text:gsub("%s+", "")
            if remoteVersion ~= CurrentVersion then
                print("^1[UPDATE] ^0Ein neues Update für ^5Array_NameChange^0 ist verfügbar!^0")
            end
        end
    end, "GET", "", "")
end)

-- Hilfsfunktionen
local function SendDiscordLog(title, message)
    if not Config.Webhook.Enabled or Config.Webhook.URL == "" then return end
    
    local embed = {{ 
        ["title"] = title, 
        ["description"] = message, 
        ["color"] = Config.Webhook.BotColor, 
        ["footer"] = { ["text"] = "Array Solution Log" }, 
        ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ') 
    }}
    
    PerformHttpRequest(Config.Webhook.URL, function(err, text, headers) end, 'POST', json.encode({
        username = Config.Webhook.BotName, 
        avatar_url = Config.Webhook.AvatarURL, 
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

local function SyncInventoryMetadata(src, newFirstname, newLastname)
    if Config.Inventory.Enabled and Config.Inventory.Type == "ox" and GetResourceState('ox_inventory') == 'started' then
        local items = exports.ox_inventory:Search(src, 'slots', Config.Inventory.IdCardItemName)
        if items then
            for _, item in pairs(items) do
                local currentMetadata = item.metadata or {}
                currentMetadata.firstname = newFirstname
                currentMetadata.lastname = newLastname
                exports.ox_inventory:SetMetadata(src, item.slot, currentMetadata)
            end
        end
    end
end

local function NotifyPlayer(src, msg, type)
    if ESX then
        TriggerClientEvent('esx:showNotification', src, msg)
    elseif QBCore then
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    end
end

local function IsNameBlacklisted(firstname, lastname)
    if not Config.AntiTroll.EnableBlacklist then return false end
    local firstLower, lastLower = string.lower(firstname), string.lower(lastname)
    
    for _, badWord in ipairs(Config.AntiTroll.BlacklistedWords) do
        local lowerBadWord = string.lower(badWord)
        if string.find(firstLower, lowerBadWord) or string.find(lastLower, lowerBadWord) then
            return true
        end
    end
    return false
end

-- Haupt-Event
RegisterNetEvent('array_namechange:server:changeName', function(newFirstname, newLastname)
    local src = source
    if not src then return end
    
    if not newFirstname or not newLastname or #newFirstname > Config.MaxLength or #newLastname > Config.MaxLength then 
        NotifyPlayer(src, 'Eingabe ungültig oder zu lang!', 'error')
        return 
    end

    if IsNameBlacklisted(newFirstname, newLastname) then
        NotifyPlayer(src, 'Dieser Name ist blockiert!', 'error')
        return
    end

    local identifier = nil

    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end
        identifier = xPlayer.identifier
        
        -- Geld check ESX
        if Config.Price > 0 then
            if xPlayer.getAccount(Config.MoneyType).money >= Config.Price then 
                xPlayer.removeAccountMoney(Config.MoneyType, Config.Price)
            else 
                NotifyPlayer(src, 'Du hast nicht genug Geld!', 'error')
                return 
            end
        end

    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end
        identifier = Player.PlayerData.citizenid
        
        -- Geld check QBCore
        if Config.Price > 0 then
            if not Player.Functions.RemoveMoney(Config.MoneyType, Config.Price, "name-change") then
                NotifyPlayer(src, 'Du hast nicht genug Geld!', 'error')
                return
            end
        end
    end

    if not identifier then return end

    -- Cooldown Check
    if Config.AntiTroll.EnableCooldown then
        local lastChange = GetResourceKvpInt("array_nc_cd_" .. identifier)
        local currentTime = os.time()
        
        if lastChange > 0 and (currentTime - lastChange) < (Config.AntiTroll.CooldownHours * 3600) then
            local remainingHours = math.ceil(((Config.AntiTroll.CooldownHours * 3600) - (currentTime - lastChange)) / 3600)
            NotifyPlayer(src, 'Du musst noch ' .. remainingHours .. ' Stunden warten!', 'error')
            
            -- Geld zurückgeben falls abgebrochen (Safety Catch)
            if Config.Price > 0 then
                if ESX then
                    local xPlayer = ESX.GetPlayerFromId(src)
                    xPlayer.addAccountMoney(Config.MoneyType, Config.Price)
                elseif QBCore then
                    local Player = QBCore.Functions.GetPlayer(src)
                    Player.Functions.AddMoney(Config.MoneyType, Config.Price, "name-change-refund")
                end
            end
            return
        end
    end

    -- Datenbank Updates (oxmysql)
    if ESX then
        MySQL.update('UPDATE users SET firstname = ?, lastname = ? WHERE identifier = ?', {
            newFirstname, newLastname, identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                if Config.AntiTroll.EnableCooldown then SetResourceKvpInt("array_nc_cd_" .. identifier, os.time()) end
                SyncInventoryMetadata(src, newFirstname, newLastname)
                SendDiscordLog("Identität Geändert", "**Spieler:** " .. GetPlayerName(src) .. " (ID: " .. src .. ")\n**Neu:** " .. newFirstname .. " " .. newLastname .. "\n**ID:** " .. identifier)
                NotifyPlayer(src, 'Dein Name wurde geändert! Bitte relogge (F8 -> quit).', 'success')
            end
        end)
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        local charinfo = Player.PlayerData.charinfo
        charinfo.firstname = newFirstname
        charinfo.lastname = newLastname
        Player.Functions.SetPlayerData("charinfo", charinfo)

        MySQL.update('UPDATE players SET charinfo = ? WHERE citizenid = ?', {
            json.encode(charinfo), identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                if Config.AntiTroll.EnableCooldown then SetResourceKvpInt("array_nc_cd_" .. identifier, os.time()) end
                SyncInventoryMetadata(src, newFirstname, newLastname)
                SendDiscordLog("Identität Geändert", "**Spieler:** " .. GetPlayerName(src) .. " (ID: " .. src .. ")\n**Neu:** " .. newFirstname .. " " .. newLastname .. "\n**ID:** " .. identifier)
                NotifyPlayer(src, 'Dein Name wurde geändert! Bitte reconnecte.', 'success')
            end
        end)
    end
end)