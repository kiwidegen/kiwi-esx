-- Buffs module (Jungle Juice & Money Booster)

Buffs = {}

function Buffs:new(hud)
    local obj = {
        hud = hud,
        juiceActive = false
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Start all jungle juice buff systems
function Buffs:StartJungleJuiceSystem()
    self:StartArmorRegen()
    self:StartReloadSpeed()
    Utils.Debug('Jungle Juice buff system started')
end

-- Armor Regeneration Thread
function Buffs:StartArmorRegen()
    CreateThread(function()
        while true do
            Wait(HudConfig.JungleJuice.ArmorRegenInterval)

            local juiceLevel = self.hud.state.player.junglejuice or 0

            if juiceLevel > 0 then
                local ped = PlayerPedId()
                local currentArmor = GetPedArmour(ped)

                if currentArmor < 100 then
                    local newArmor = math.min(100, currentArmor + HudConfig.JungleJuice.ArmorRegenRate)
                    SetPedArmour(ped, newArmor)
                    self.hud:UpdateState('player', 'armor', newArmor)
                    Utils.Debug('Armor regen:', currentArmor, '->', newArmor)
                end
            end
        end
    end)
end

-- Reload Speed Buff Thread
function Buffs:StartReloadSpeed()
    CreateThread(function()
        while true do
            Wait(100)

            local juiceLevel = self.hud.state.player.junglejuice or 0
            local ped = PlayerPedId()

            if juiceLevel > 0 then
                -- Check if player is reloading and speed it up
                if IsPedReloading(ped) then
                    if not self.juiceActive then
                        Utils.Debug('Fast reload activated')
                        self.juiceActive = true
                    end

                    -- Force fast reload
                    local currentWeapon = GetSelectedPedWeapon(ped)
                    if currentWeapon ~= `WEAPON_UNARMED` then
                        TaskReloadWeapon(ped, true) -- true = fast reload
                    end
                end
            else
                if self.juiceActive then
                    self.juiceActive = false
                    Utils.Debug('Fast reload deactivated')
                end
            end
        end
    end)
end

return Buffs
