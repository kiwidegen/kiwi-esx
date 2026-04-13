---@diagnostic disable: undefined-global
ESX = exports['es_extended']:getSharedObject()

--- Check and claim daily reward
RegisterNetEvent('drp_dailyreward:checkAndClaim', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Check if player can claim
    MySQL.scalar('SELECT UNIX_TIMESTAMP() - IFNULL(last_claim, 0) as time_diff FROM daily_rewards WHERE identifier = ?',
        {xPlayer.identifier},
        function(timeDiff)
            if not timeDiff or timeDiff >= Config.DailyReward.CooldownSeconds then
                -- Give reward
                local reward = math.random(Config.DailyReward.MinReward, Config.DailyReward.MaxReward)
                xPlayer.addMoney(reward)

                -- Update last claim time
                MySQL.insert('INSERT INTO daily_rewards (identifier, last_claim, total_claims) VALUES (?, UNIX_TIMESTAMP(), 1) ON DUPLICATE KEY UPDATE last_claim = UNIX_TIMESTAMP(), total_claims = total_claims + 1',
                    {xPlayer.identifier}
                )

                xPlayer.showNotification('You received $' .. reward .. ' as your daily reward!', 'success')
            end
        end
    )
end)
