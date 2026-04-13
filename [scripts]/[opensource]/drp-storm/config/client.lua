---@class ClientConfig
Config = {}

-- Notification settings
Config.Notifications = {
    cooldownActive = {
        title = 'Combat Cooldown Active',
        description = 'You cannot use weapons or melee',
        type = 'error',
        icon = 'skull-crossbones',
        iconColor = '#C53030'
    },
    cooldownExpired = {
        title = 'Cooldown Expired',
        description = 'You can now use weapons again',
        type = 'success',
        icon = 'check-circle',
        iconColor = '#38A169'
    },
    adminPlacedCooldown = {
        title = 'Admin Cooldown',
        description = 'An admin has placed you on cooldown',
        type = 'warning',
        icon = 'user-shield',
        iconColor = '#DD6B20'
    }
}
