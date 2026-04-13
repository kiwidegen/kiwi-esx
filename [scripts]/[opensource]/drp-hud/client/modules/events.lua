-- Event handlers module

Events = {}

function Events:Init(hud)
    self.hud = hud
    self:RegisterGameEvents()
    self:RegisterNetEvents()
    self:RegisterCommands()
end

function Events:RegisterGameEvents()
    local hud = self.hud  -- Capture self.hud in local variable for closure

    AddEventHandler('gameEventTriggered', function(event, data)
        if event == 'CEventNetworkPlayerEnteredVehicle' then
            if data[1] == PlayerId() then
                hud.modules.vehicle:OnEnter()
            end
        elseif event == 'CEventNetworkPlayerLeftVehicle' then
            if data[1] == PlayerId() then
                hud.modules.vehicle:OnExit()
            end
        end
    end)

    -- pma-voice integration
    AddEventHandler('pma-voice:setTalkingMode', function(mode)
        local voicePercent = 50

        if mode == 1 then
            voicePercent = 15
        elseif mode == 2 then
            voicePercent = 50
        elseif mode == 3 then
            voicePercent = 100
        end

        hud:UpdateState('player', 'voice', voicePercent)
    end)

    AddEventHandler('pma-voice:radioActive', function(talking)
        hud:UpdateState('ui', 'isTalkingOnRadio', talking)
    end)

    -- Get initial voice mode
    CreateThread(function()
        Wait(3000)
        TriggerEvent('pma-voice:settingsCallback', function(voiceSettings)
            if voiceSettings and voiceSettings.voiceMode then
                Utils.Debug('Initial voice mode:', voiceSettings.voiceMode)
                local mode = voiceSettings.voiceMode
                local voicePercent = 66

                if mode == 1 then
                    voicePercent = 33
                elseif mode == 2 then
                    voicePercent = 66
                elseif mode == 3 then
                    voicePercent = 100
                end

                hud:UpdateState('player', 'voice', voicePercent)
            end
        end)
    end)
end

function Events:RegisterNetEvents()
    local hud = self.hud  -- Capture self.hud in local variable for closure

    RegisterNetEvent('hud:client:hide_icons', function(value)
        hud:UpdateState('ui', 'hide_icons', value)
    end)

    RegisterNetEvent('hud:client:set_cornerselling', function(value)
        hud:UpdateState('ui', 'cornersell', value)
    end)

    RegisterNetEvent('hud:client:consumeJungleJuice', function(amount)
        local current = hud.state.player.junglejuice or 0
        local newAmount = math.min(current + amount, 100)
        hud:UpdateState('player', 'junglejuice', newAmount)
        Utils.Debug('Consumed jungle juice:', amount, '| New total:', newAmount)
    end)

    RegisterNetEvent('hud:client:UpdateStress', function(stress)
        hud:UpdateState('player', 'stress', stress)
    end)

    RegisterNetEvent('esx:playerLoaded', function()
        Utils.Debug('esx:playerLoaded triggered')
        while IsScreenFadedOut() do
            Wait(200)
        end
        Wait(1000) -- Extra delay for character selection
        hud:Show()

        lib.callback('drp-hud:isAdmin', false, function(isAdmin)
            hud:UpdateState('ui', 'admin', isAdmin)
        end)
    end)

    RegisterNetEvent('esx_multicharacter:characterLoaded', function()
        Utils.Debug('esx_multicharacter:characterLoaded triggered')
        hud:Hide()
        Wait(1000) -- Delay to ensure spawn UI is done
        hud:Show()
    end)

    AddEventHandler('playerSpawned', function()
        Utils.Debug('playerSpawned triggered')
        if not hudActive then
            while IsScreenFadedOut() do
                Wait(200)
            end
            Wait(1000) -- Extra delay
            hud:Show()
        end
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        Utils.Debug('esx:onPlayerLogout triggered')
        Wait(1000)
        hud:Hide()
    end)

    -- Seatbelt toggle event
    RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
        local current = hud.state.vehicle.seatbelt or false
        hud:UpdateState('vehicle', 'seatbelt', not current)
        Utils.Debug('Seatbelt toggled:', not current)
    end)
end

function Events:RegisterCommands()
    local hud = self.hud  -- Capture self.hud in local variable for closure

    RegisterCommand('cinematic', function()
        local current = hud.state.ui.cinematic or false
        hud:UpdateState('ui', 'cinematic', not current)
    end, false)

    RegisterCommand('gps', function()
        local current = hud.state.ui.gps or false
        hud:UpdateState('ui', 'gps', not current)
        DisplayRadar(not current)
    end, false)

    RegisterCommand('hideui', function()
        local current = hud.state.ui.forceHide or false
        hud:UpdateState('ui', 'forceHide', not current)
    end, false)

    RegisterCommand('huddebug', function()
        print('^6========== HUD DEBUG ==========^0')
        print('^2State:^0', json.encode(hud.state, {indent = true}))
        print('^6===============================^0')
    end, false)

    RegisterCommand('junglejuice', function(source, args)
        local amount = tonumber(args[1]) or 50
        TriggerEvent('hud:client:consumeJungleJuice', amount)
        TriggerEvent('esx:showNotification', '⚡ Jungle Juice activated!')
    end, false)

    RegisterCommand('testjuice', function(source, args)
        local amount = tonumber(args[1]) or 50
        TriggerEvent('hud:client:consumeJungleJuice', amount)
        print('^3[Test JungleJuice]^0 Added ' .. amount .. ' jungle juice')
    end, false)

    RegisterCommand('testvoice', function(source, args)
        local mode = tonumber(args[1]) or 2
        TriggerEvent('pma-voice:setTalkingMode', mode)
    end, false)

    RegisterCommand('testseatbelt', function(source, args)
        TriggerEvent('seatbelt:client:ToggleSeatbelt')
        print('^3[Test Seatbelt]^0 Toggled seatbelt')
    end, false)
end

return Events
