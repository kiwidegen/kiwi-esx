-- Main HUD Controller - Single source of truth

local hudActive = false

HUD = {
    state = {
        player = {
            health = 0,
            armor = 0,
            hunger = 0,
            thirst = 0,
            stamina = 100,
            stress = 0,
            oxygen = 100,
            junglejuice = 0,
            voice = 33,
            is_dead = false,
        },
        vehicle = {
            speed = 0,
            rpm = 0,
            gear = 0,
            health = 1000,
            fuel = 100,
            tracker = 0,
            seatbelt = false,
            traction_lost = false,
            engine_on = false
        },
        ui = {
            hide = true,
            hide_icons = false,
            gps = false,
            admin = false,
            developer = false,
            cinematic = false,
            cornersell = false,
            inVehicle = false,
            isTalking = false,
            isTalkingOnRadio = false,
            forceHide = false
        }
    },

    modules = {},
    updateRate = HudConfig.UpdateRate or 100,
    initialized = false
}

function HUD:Show()
    hudActive = true
    Utils.Debug('Showing HUD')
    SendNUIMessage({ type = 'show' })
    self:UpdateState('ui', 'hide', false)
    DisplayRadar(true)
end

function HUD:Hide()
    hudActive = false
    Utils.Debug('Hiding HUD')
    SendNUIMessage({ type = 'hide', payload = { opacity = 0 } })
    self:UpdateState('ui', 'hide', true)
end

function HUD:Init()
    if self.initialized then return end

    Utils.Debug('Initializing HUD...')

    self.modules.player = Player:new(self)
    self.modules.vehicle = Vehicle:new(self)
    self.modules.events = Events
    self.modules.buffs = Buffs:new(self)

    Vehicle.hud = self

    self.modules.events:Init(self)

    self:StartUpdateLoop()

    self.modules.player:StartJungleJuiceDecay()
    self.modules.buffs:StartJungleJuiceSystem()
    self:InitializeNutrition()
    self:SetupMinimap()
    self:StartAlignmentUpdate()

    Wait(2000)
    self:SendFullState()

    self.initialized = true
    Utils.Debug('HUD initialized successfully')
end

function HUD:StartUpdateLoop()
    CreateThread(function()
        while true do
            Wait(self.updateRate)

            if self.state.ui.forceHide then
                self:UpdateState('ui', 'hide', true)
            end

            self.modules.player:Update()

            if self.state.ui.inVehicle then
                self.modules.vehicle:Update()
            end
        end
    end)

    -- Pause menu opacity handler
    CreateThread(function()
        while true do
            if hudActive then
                local pause = IsPauseMenuActive()
                if pause then
                    SendNUIMessage({ type = 'hide', payload = { opacity = 0 } })
                else
                    SendNUIMessage({ type = 'hide', payload = { opacity = 1 } })
                end
            end
            Wait(200)
        end
    end)
end

function HUD:UpdateState(category, key, value)
    if not self.state[category] then
        Utils.Debug('Invalid category:', category)
        return
    end

    if self.state[category][key] ~= value then
        self.state[category][key] = value

        -- Only send full state for UI visibility changes, otherwise send delta
        if category == 'ui' and (key == 'hide' or key == 'inVehicle') then
            self:SendFullState()
        else
            self:SendDeltaUpdate(category, key, value)
        end

        Utils.Debug('Updated', category, key, '=', value)
    end
end

function HUD:SendDeltaUpdate(category, key, value)
    SendNUIMessage({
        type = 'hud.update',
        payload = {
            category = category,
            key = key,
            value = value
        }
    })
end

function HUD:SendFullState()
    local x, y, size = getAlignment()
    local hudData = {
        hide = self.state.ui.hide,
        hide_icons = self.state.ui.hide_icons,
        inVehicle = self.state.ui.inVehicle,
        isTalking = self.state.ui.isTalking,
        isTalkingOnRadio = self.state.ui.isTalkingOnRadio,
        cinematic = self.state.ui.cinematic,
        gps = self.state.ui.gps,
        voice = self.state.player.voice,
        player = self.state.player,
        vehicle = self.state.vehicle,
        alignment = {
            x = x,
            y = y,
            size = size
        },
        config = {
            player = HudConfig.Player,
            vehicle = HudConfig.Vehicle,
            position = HudConfig.Position
        }
    }

    SendNUIMessage({
        type = 'hud.data',
        payload = hudData
    })

    Utils.Debug('Sent full state to UI')
end

function HUD:StartAlignmentUpdate()
    -- Alignment updates are now handled by delta updates
    -- Only send periodic updates every 30 seconds to sync alignment changes
    CreateThread(function()
        while true do
            Wait(30000)  -- Changed from 1000ms to 30000ms (30 seconds)
            self:SendFullState()
        end
    end)
end

function HUD:InitializeNutrition()
    CreateThread(function()
        while true do
            Wait(5000)

            TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                if status then
                    local hunger = math.floor(status.getPercent())
                    self:UpdateState('player', 'hunger', hunger)
                end
            end)

            TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                if status then
                    local thirst = math.floor(status.getPercent())
                    self:UpdateState('player', 'thirst', thirst)
                end
            end)
        end
    end)
end

function HUD:SetupMinimap()
    -- Hide minimap initially (shows when HUD:Show() is called)
    DisplayRadar(false)
end

RegisterNUICallback('hud.data', function(data, cb)
    HUD:SendFullState()
    cb('ok')
end)

RegisterNUICallback('ready', function(data, cb)
    Utils.Debug('NUI ready callback, show:', data.show, 'hudActive:', hudActive)
    if data.show and hudActive then
        Wait(1000)
        SendNUIMessage({ type = 'show' })
    end
    cb('ok')
end)

-- Start with HUD hidden
HUD:Hide()

CreateThread(function()
    Wait(1000)
    HUD:Init()
end)

exports('GetJungleJuice', function()
    return HUD.state.player.junglejuice or 0
end)

exports('SetSeatbelt', function(enabled)
    if type(enabled) ~= 'boolean' then
        Utils.Debug('SetSeatbelt export called with invalid type:', type(enabled))
        return
    end

    HUD:UpdateState('vehicle', 'seatbelt', enabled)
    Utils.Debug('Seatbelt state updated via export:', enabled)
end)
