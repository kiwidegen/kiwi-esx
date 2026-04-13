if not ExtrasConfig.Modules.PlayerIDs then return end
---@diagnostic disable: undefined-global
Core.DebugPrint('Player ID module loaded')

local isActive = false
local playerTags = {}
local comps = { GamerName = 0, AudioIcon = 4 }
local DIST <const> = ExtrasConfig.ID.DistanceToDisplay or 5.0
local DISPLAY_TIME <const> = ExtrasConfig.ID.DisplayTime or 5000

local function cleanTags()
    for _, v in pairs(playerTags) do
        if v.tag and IsMpGamerTagActive(v.tag) then
            RemoveMpGamerTag(v.tag)
        end
    end
    playerTags = {}
end

local function showTags()
    local myPed = PlayerPedId()
    local myPos = GetEntityCoords(myPed)

    for _, pid in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(pid)
        if DoesEntityExist(ped) then
            local tagData = playerTags[pid]
            if not tagData or not IsMpGamerTagActive(tagData.tag) then
                tagData = {
                    tag = CreateFakeMpGamerTag(ped, ('ID: %s'):format(GetPlayerServerId(pid)), false, false, '', 0),
                    ped = ped
                }
                playerTags[pid] = tagData
            end

            local tag = tagData.tag
            local dist = #(GetEntityCoords(ped) - myPos)
            local visible = dist <= DIST and HasEntityClearLosToEntity(myPed, ped, 17)
            SetMpGamerTagVisibility(tag, comps.GamerName, visible)
            SetMpGamerTagVisibility(tag, comps.AudioIcon, visible and NetworkIsPlayerTalking(pid))
        end
    end
end

local function toggleIDs()
    if isActive then return end
    isActive = true
    Core.Notify('Player IDs', ('Your ID is %s'):format(GetPlayerServerId(PlayerId())), 'info', 2500)

    -- add self tag (so you see your own ID)
    if not playerTags['self'] or not IsMpGamerTagActive(playerTags['self'].tag) then
        local myPed = PlayerPedId()
        playerTags['self'] = {
            tag = CreateFakeMpGamerTag(myPed, ('ID: %s'):format(GetPlayerServerId(PlayerId())), false, false, '', 0),
            ped = myPed
        }
        SetMpGamerTagVisibility(playerTags['self'].tag, comps.GamerName, true)
    end

    CreateThread(function()
        local timer = DISPLAY_TIME
        while timer > 0 do
            showTags()
            timer -= 50
            Wait(50)
        end
        isActive = false
        cleanTags()
    end)
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(1000) end
    Wait(1000)
    local cmd = (ExtrasConfig.ID and ExtrasConfig.ID.Command) or 'id'
    RegisterCommand(cmd, toggleIDs, false)
    Core.DebugPrint(string.format('[drp_modules] Registered /%s command', cmd))
end)
