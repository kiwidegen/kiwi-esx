-- Player stats module

Player = {}

function Player:new(hud)
    local obj = {
        hud = hud,
        lastValues = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Player:Update()
    local ped = PlayerPedId()
    local playerId = PlayerId()

    -- Health (100-200 range converted to 0-100)
    local health = GetEntityHealth(ped)
    local healthPercent = 0
    if health > 100 then
        healthPercent = math.floor(((health - 100) / 100) * 100)
    end

    if self:HasChanged('health', healthPercent) then
        self.hud:UpdateState('player', 'health', healthPercent)
    end

    -- Armor
    local armor = GetPedArmour(ped)
    if self:HasChanged('armor', armor) then
        self.hud:UpdateState('player', 'armor', armor)
    end

    -- Voice mode is handled by event listener in events.lua

    -- Talking state (poll from MumbleIsPlayerTalking)
    local isTalking = MumbleIsPlayerTalking(playerId) == 1
    if self:HasChanged('isTalking', isTalking) then
        self.hud:UpdateState('ui', 'isTalking', isTalking)
    end

    -- Stamina (0 = full, 100 = exhausted)
    local staminaRaw = GetPlayerSprintStaminaRemaining(playerId)
    local stamina = 100 - math.floor(staminaRaw)

    -- Only show stamina when player is actively sprinting (shift held, not swimming)
    local isSprinting = IsPedSprinting(ped)
    local isSwimming = IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped)

    if not isSprinting or isSwimming then
        stamina = 0
    end

    -- Use threshold of 1 for stamina to ensure 0 updates are caught
    if self:HasChanged('stamina', stamina, 1) then
        self.hud:UpdateState('player', 'stamina', stamina)
    end

    -- Oxygen
    local oxygen = math.floor(GetPlayerUnderwaterTimeRemaining(playerId) * 10)
    if oxygen < 0 then oxygen = 0 end
    if self:HasChanged('oxygen', oxygen, 2) then
        self.hud:UpdateState('player', 'oxygen', oxygen)
    end

    -- Talking status is handled by pma-voice events in events.lua

    -- Dead status
    local isDead = IsEntityDead(ped)
    if self:HasChanged('is_dead', isDead) then
        self.hud:UpdateState('player', 'is_dead', isDead)

        -- Reset jungle juice when player dies
        if isDead then
            self.hud:UpdateState('player', 'junglejuice', 0)
            Utils.Debug('Player died - jungle juice reset')
        end

        -- Reset lastValues cache when player respawns to ensure stats track correctly
        if not isDead and self.lastValues['is_dead'] == true then
            self.lastValues = { is_dead = false }
            Utils.Debug('Player respawned - reset stat tracking cache')
        end
    end

    -- Jungle Juice speed boost
    self:UpdateJungleJuiceSpeed()
end

function Player:HasChanged(key, value, threshold)
    threshold = threshold or 1
    local old = self.lastValues[key]

    -- Handle boolean values separately
    if type(value) == 'boolean' or type(old) == 'boolean' then
        if old ~= value then
            self.lastValues[key] = value
            return true
        end
        return false
    end

    -- Handle numeric values with threshold
    if old == nil or math.abs(old - value) >= threshold then
        self.lastValues[key] = value
        return true
    end

    return false
end

-- Update jungle juice speed boost based on current level
function Player:UpdateJungleJuiceSpeed()
    local juiceLevel = self.hud.state.player.junglejuice or 0
    local playerId = PlayerId()
    local ped = PlayerPedId()

    if juiceLevel > 0 then
        -- Speed multiplier scales with jungle juice (1.0 to 1.15 max)
        local multiplier = 1.0 + (juiceLevel / 100) * 0.15
        SetRunSprintMultiplierForPlayer(playerId, multiplier)
        SetSwimMultiplierForPlayer(playerId, multiplier)

        -- Only restore stamina faster when NOT sprinting (allows depletion but faster recovery)
        local isSprinting = IsPedSprinting(ped) or IsPedRunning(ped)
        if not isSprinting then
            -- Restore stamina faster when resting (jungle juice boost)
            -- Higher level = faster recovery (1.5 to 2.5 based on level)
            local regenRate = 1.5 + (juiceLevel / 100) * 1.0
            RestorePlayerStamina(playerId, regenRate)
        end
        -- When sprinting, stamina depletes normally - no restoration
    else
        -- Reset to normal speed
        SetRunSprintMultiplierForPlayer(playerId, 1.0)
        SetSwimMultiplierForPlayer(playerId, 1.0)
        -- Stamina refills naturally at game's default rate (like oxygen does)
    end
end

-- Jungle Juice decay thread
function Player:StartJungleJuiceDecay()
    CreateThread(function()
        while true do
            Wait(30000) -- Every 30 seconds

            local current = self.hud.state.player.junglejuice or 0
            if current > 0 then
                -- Decay by 5 per tick (100% lasts 10 minutes: 20 ticks * 30s = 600s)
                local newValue = math.max(0, current - 5)
                self.hud:UpdateState('player', 'junglejuice', newValue)
            end
        end
    end)
end

return Player
