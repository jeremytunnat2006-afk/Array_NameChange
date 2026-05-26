Config = {}

-- ==========================================
-- GRUNDEINSTELLUNGEN
-- ==========================================
Config.Framework = 'auto' -- 'auto', 'esx', 'qbcore'

Config.Location = {
    Coords = vector3(-555.25, -187.09, 38.22),
    DrawDistance = 10.0,
    InteractDistance = 1.5
}

Config.Blip = {
    Enabled = true,
    Sprite = 498,
    Color = 2,
    Scale = 0.8,
    Name = "Bürgerbüro - Identität"
}

Config.Marker = {
    Type = 1,
    Size = vector3(1.5, 1.5, 1.0),
    Color = { r = 0, g = 85, b = 255, a = 100 } -- Blau passend zum UI
}

Config.Price = 5000
Config.MoneyType = 'bank' -- 'money', 'cash', 'bank'
Config.MaxLength = 12

-- ==========================================
-- PRO-FEATURES: LOGS, ANTI-TROLL & INVENTAR
-- ==========================================

-- 1. Discord Webhook Logs
Config.Webhook = {
    Enabled = true,
    URL = "https://discord.com/api/webhooks/1508689563290177556/E34E4-e07vQsRgxucffzTgo-VLYeimWTZPPxgWuGW8dyJo0S3zE0FVBHfuPkDlnNq51s", 
    BotName = "Array Solution",
    BotColor = 3447003, -- Blau
    AvatarURL = "https://via.placeholder.com/150/061121/ffffff?text=A"
}

-- 2. Anti-Troll: Blacklist
Config.AntiTroll = {
    EnableBlacklist = true,
    BlacklistedWords = {
        "admin", "moderator", "support", "polizei", "medic", "array", "hitler", "jesus", "nazi"
    },
    
    -- 3. Anti-Troll: Cooldown
    EnableCooldown = true,
    CooldownHours = 24 -- 24 Stunden Wartezeit
}

-- 4. Inventar Metadaten-Sync
Config.Inventory = {
    Enabled = true,
    Type = "ox", 
    IdCardItemName = "id_card" 
}