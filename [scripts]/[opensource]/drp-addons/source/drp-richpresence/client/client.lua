---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()
local firstSpawn = true
local Usercount = 0

AddEventHandler("playerSpawned", function()
    if firstSpawn then
        SetDiscordRichPresenceAction(0, "Discord", Config.RichPresence.DiscordLink)
        SetDiscordRichPresenceAction(1, "FiveM", Config.RichPresence.FiveMLink)
        firstSpawn = false
    end
end)

CreateThread(function()
    while true do
        local PlayerData = ESX.GetPlayerData()
        if PlayerData then
            SetDiscordAppId(Config.RichPresence.AppId)
            SetDiscordRichPresenceAsset(Config.RichPresence.LargeLogo)
            SetDiscordRichPresenceAssetSmall(Config.RichPresence.SmallLogo)

            if PlayerData.job then
                SetDiscordRichPresenceAssetSmallText(PlayerData.job.label .. " - " .. PlayerData.job.grade_label)
            else
                SetDiscordRichPresenceAssetSmallText("Unemployed")
            end

            SetRichPresence(("ID: %s | Name: %s | Players: %s/%s"):format(
                GetPlayerServerId(PlayerId()),
                GetPlayerName(PlayerId()),
                Usercount,
                Config.RichPresence.MaxPlayers
            ))
            SetDiscordRichPresenceAssetText(Config.RichPresence.ServerName)
        end
        Wait(60000) -- Update every 60 seconds
    end
end)

RegisterNetEvent("drp_richpresence:updatePlayers", function(players)
    Usercount = players
end)
