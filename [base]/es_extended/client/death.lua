Death        = {}
Death._index = Death

function Death:ResetValues()
    self.killerEntity  = nil
    self.deathCause    = nil
    self.killerId      = nil
    self.killerServerId = nil
end

function Death:ByPlayer()
    local ped         = PlayerPedId()
    local victimCoords = GetEntityCoords(ped)
    local killerCoords = GetEntityCoords(self.killerEntity)
    local distance     = #(victimCoords - killerCoords)

    local data = {
        victimCoords = {
            x = ESX.Math.Round(victimCoords.x, 1),
            y = ESX.Math.Round(victimCoords.y, 1),
            z = ESX.Math.Round(victimCoords.z, 1),
        },
        killerCoords = {
            x = ESX.Math.Round(killerCoords.x, 1),
            y = ESX.Math.Round(killerCoords.y, 1),
            z = ESX.Math.Round(killerCoords.z, 1),
        },
        killedByPlayer  = true,
        deathCause      = self.deathCause,
        distance        = ESX.Math.Round(distance, 1),
        killerServerId  = self.killerServerId,
        killerClientId  = self.killerId,
    }

    TriggerEvent('esx:onPlayerDeath', data)
    TriggerServerEvent('esx:onPlayerDeath', data)
end

function Death:Natural()
    local coords = GetEntityCoords(PlayerPedId())

    local data = {
        victimCoords = {
            x = ESX.Math.Round(coords.x, 1),
            y = ESX.Math.Round(coords.y, 1),
            z = ESX.Math.Round(coords.z, 1),
        },
        killedByPlayer = false,
        deathCause     = self.deathCause,
    }

    TriggerEvent('esx:onPlayerDeath', data)
    TriggerServerEvent('esx:onPlayerDeath', data)
end

function Death:Died()
    local ped           = PlayerPedId()
    self.killerEntity   = GetPedSourceOfDeath(ped)
    self.deathCause     = GetPedCauseOfDeath(ped)
    self.killerId       = NetworkGetPlayerIndexFromPed(self.killerEntity)
    self.killerServerId = GetPlayerServerId(self.killerId)

    ESX.PlayerData.dead = true

    if self.killerEntity ~= ped and self.killerId and NetworkIsPlayerActive(self.killerId) then
        self:ByPlayer()
    else
        self:Natural()
    end

    self:ResetValues()
end

-- Restart the death watcher each time the player spawns.
AddEventHandler('esx:onPlayerSpawn', function()
    ESX.PlayerData.dead = false

    Citizen.CreateThreadNow(function()
        while not ESX.PlayerLoaded do Wait(0) end

        while ESX.PlayerLoaded and not ESX.PlayerData.dead do
            local ped = PlayerPedId()
            if DoesEntityExist(ped) and (IsEntityDead(ped, false) or IsPedFatallyInjured(ped)) then
                Death:Died()
                break
            end
            Wait(250)
        end
    end)
end)
