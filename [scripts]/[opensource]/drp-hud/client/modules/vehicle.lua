-- Vehicle module

Vehicle = {}

function Vehicle:new(hud)
    local obj = {
        hud = hud,
        vehicle = 0,
        lastValues = {},
        inVehicle = false
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Vehicle:OnEnter()
    local ped = PlayerPedId()
    self.vehicle = GetVehiclePedIsIn(ped, false)
    self.inVehicle = true

    self.hud:UpdateState('ui', 'inVehicle', true)

    Utils.Debug('Entered vehicle:', self.vehicle)
end

function Vehicle:OnExit()
    self.vehicle = 0
    self.inVehicle = false

    self.hud:UpdateState('ui', 'inVehicle', false)
    self:ResetValues()

    Utils.Debug('Exited vehicle')
end

function Vehicle:Update()
    -- Check if player is actually in a vehicle
    local ped = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(ped, false)

    -- If we think we're in a vehicle but we're not, reset
    if self.inVehicle and currentVehicle == 0 then
        self:OnExit()
        return
    end

    -- If we're not tracking being in a vehicle, exit
    if not self.inVehicle or self.vehicle == 0 then return end

    local vehicle = self.vehicle

    -- Double check vehicle still exists
    if not DoesEntityExist(vehicle) then
        self:OnExit()
        return
    end

    -- Check vehicle class
    local vehicleClass = GetVehicleClass(vehicle)
    local isAircraft = vehicleClass == 15 or vehicleClass == 16 -- 15 = helicopters, 16 = planes

    -- Speed (KM/h)
    local speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Convert m/s to km/h
    if speed < 2 then speed = 0 end -- Show 0 when nearly stopped
    if self:HasChanged('speed', speed, 2) then
        self.hud:UpdateState('vehicle', 'speed', speed)
    end

    -- Engine running state
    local engineOn = GetIsVehicleEngineRunning(vehicle)
    if self:HasChanged('engine_on', engineOn) then
        self.hud:UpdateState('vehicle', 'engine_on', engineOn)
    end

    -- RPM (0-8000 range)
    local rpm = GetVehicleCurrentRpm(vehicle)
    local rpmValue = math.floor(rpm * 8000)

    if self:HasChanged('rpm', rpmValue, 50) then
        self.hud:UpdateState('vehicle', 'rpm', rpmValue)
    end

    -- Gear (0 = neutral, negative = reverse) - Skip for aircraft
    if not isAircraft then
        local gear = GetVehicleCurrentGear(vehicle)
        local gearDisplay = gear

        -- Check if in reverse
        if GetEntitySpeedVector(vehicle, true).y < 0 and speed > 1 then
            gearDisplay = -1 -- Reverse
        elseif gear == 0 then
            gearDisplay = 0 -- Neutral
        end

        if self:HasChanged('gear', gearDisplay) then
            self.hud:UpdateState('vehicle', 'gear', gearDisplay)
        end
    else
        -- For aircraft, set gear to nil to hide it
        if self:HasChanged('gear', -999) then -- Use special value for aircraft
            self.hud:UpdateState('vehicle', 'gear', -999)
        end
    end

    -- Engine health
    local health = math.floor(GetVehicleEngineHealth(vehicle))
    if self:HasChanged('health', health, 10) then
        self.hud:UpdateState('vehicle', 'health', health)
    end

    -- Fuel
    local fuel = self:GetFuel(vehicle)
    if self:HasChanged('fuel', fuel, 1) then
        self.hud:UpdateState('vehicle', 'fuel', fuel)
    end

    -- Traction control (only for ground vehicles, check for actual wheel slip)
    local tractionLost = false

    if not isAircraft and speed > 10 then
        -- Only show traction control warning if wheels are spinning/slipping on ground
        local isOnAllWheels = IsVehicleOnAllWheels(vehicle)

        -- Check if wheels are actually slipping (losing traction while accelerating)
        if isOnAllWheels then
            -- If on all wheels, check for wheelspin via RPM vs speed mismatch
            local rpmPercent = rpmValue / 8000
            local speedPercent = speed / 200 -- Rough conversion

            -- If RPM is much higher than speed suggests, wheels are spinning
            if rpmPercent > (speedPercent + 0.3) then
                tractionLost = true
            end
        end
    end

    if self:HasChanged('traction_lost', tractionLost) then
        self.hud:UpdateState('vehicle', 'traction_lost', tractionLost)
    end
end

function Vehicle:GetFuel(vehicle)
    -- ox_fuel uses entity state
    local fuel = Entity(vehicle).state.fuel or 0
    return math.floor(fuel)
end

function Vehicle:ResetValues()
    self.hud:UpdateState('vehicle', 'speed', 0)
    self.hud:UpdateState('vehicle', 'rpm', 0)
    self.hud:UpdateState('vehicle', 'gear', 0)
    self.hud:UpdateState('vehicle', 'health', 0)
    self.hud:UpdateState('vehicle', 'fuel', 0)
    self.hud:UpdateState('vehicle', 'seatbelt', false)
    self.hud:UpdateState('vehicle', 'tracker', 0)
    self.hud:UpdateState('vehicle', 'engine_on', false)
    self.hud:UpdateState('vehicle', 'traction_lost', false)
    self.lastValues = {}
end

function Vehicle:HasChanged(key, value, threshold)
    local old = self.lastValues[key]

    -- Handle boolean values separately (check BEFORE doing math)
    if type(value) == 'boolean' or type(old) == 'boolean' then
        if old ~= value then
            self.lastValues[key] = value
            return true
        end
        return false
    end

    -- Handle numeric values with threshold
    threshold = threshold or 1
    if old == nil or math.abs(old - value) >= threshold then
        self.lastValues[key] = value
        return true
    end

    return false
end

return Vehicle