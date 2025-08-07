-- Example: Behavior Analysis Integration
-- This file shows how other resources can integrate with the enhanced AqquaAC behavior analysis system

-- Example 1: Track player weapon usage
AddEventHandler('weaponDamageEvent', function(sender, data)
    -- Track rapid weapon switching or unusual damage patterns
    TriggerServerEvent('vac:playerAction', 'weapon_damage', {
        weapon = data.weaponType,
        damage = data.damageComponent,
        target = data.entityDamaged
    })
end)

-- Example 2: Track vehicle spawning
RegisterNetEvent('QBCore:Server:SpawnVehicle')
AddEventHandler('QBCore:Server:SpawnVehicle', function(model, coords)
    local source = source
    -- Track vehicle spawning frequency
    TriggerEvent('vac:playerAction', 'vehicle_spawn', {
        model = model,
        location = coords,
        player = source
    })
end)

-- Example 3: Track money transactions (server-side)
RegisterNetEvent('QBCore:Server:OnMoneyChange')
AddEventHandler('QBCore:Server:OnMoneyChange', function(source, moneyType, amount, reason)
    -- Track large or frequent money changes
    if math.abs(amount) > 10000 then
        TriggerEvent('vac:playerAction', 'large_money_change', {
            amount = amount,
            type = moneyType,
            reason = reason
        })
    end
end)

-- Example 4: Track teleportation events
RegisterNetEvent('QBCore:Command:TeleportToPlayer')
AddEventHandler('QBCore:Command:TeleportToPlayer', function(target)
    local source = source
    -- Track admin teleportation usage
    TriggerServerEvent('vac:playerAction', 'admin_teleport', {
        admin = source,
        target = target,
        timestamp = os.time()
    })
end)

-- Example 5: Track item usage patterns
RegisterNetEvent('QBCore:Server:UseItem')
AddEventHandler('QBCore:Server:UseItem', function(source, item)
    -- Track rapid item usage that might indicate duplication
    TriggerEvent('vac:playerAction', 'item_use', {
        item = item.name,
        amount = item.amount or 1
    })
end)

-- Example 6: Custom cheat detection integration
CreateThread(function()
    while true do
        Wait(10000) -- Check every 10 seconds
        
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local playerPed = GetPlayerPed(playerId)
            
            -- Example: Detect players in unusual locations
            local coords = GetEntityCoords(playerPed)
            if coords.z > 1000.0 then -- Very high altitude
                TriggerEvent('vac:playerAction', 'unusual_location', {
                    location = coords,
                    reason = 'extremely_high_altitude'
                })
            end
            
            -- Example: Detect unusual weapon loadouts
            local weapons = {}
            for i = 0, 12 do
                local weapon = GetPedWeapontypeInSlot(playerPed, i)
                if weapon ~= GetHashKey('WEAPON_UNARMED') then
                    table.insert(weapons, weapon)
                end
            end
            
            if #weapons > 5 then -- Too many weapons
                TriggerEvent('vac:playerAction', 'suspicious_loadout', {
                    weaponCount = #weapons,
                    weapons = weapons
                })
            end
        end
    end
end)

-- Example 7: Integration with existing anti-cheat events
AddEventHandler('chatMessage', function(source, name, message)
    -- Track chat patterns for spam or advertising
    local suspiciousPatterns = {
        'discord.gg/',
        'free money',
        'hack menu',
        'mod menu'
    }
    
    for _, pattern in ipairs(suspiciousPatterns) do
        if string.find(string.lower(message), pattern) then
            TriggerServerEvent('vac:playerAction', 'suspicious_chat', {
                message = message,
                pattern = pattern
            })
            break
        end
    end
end)

-- Example 8: Resource-specific monitoring
AddEventHandler('onResourceStart', function(resourceName)
    -- Track resource starts that might indicate injection
    if not IsPlayerAceAllowed(source, 'command') then
        TriggerServerEvent('vac:playerAction', 'resource_start', {
            resource = resourceName,
            player = source
        })
    end
end)

--[[
    Usage Notes:
    
    1. Place behavior tracking calls at strategic points in your resources
    2. Use descriptive action types and include relevant details
    3. The behavior analysis system will automatically detect patterns
    4. Configure thresholds in config.cfg to avoid false positives
    5. Monitor logs/security.log for behavior analysis results
    
    Action Types Suggestions:
    - 'weapon_damage', 'weapon_switch', 'weapon_spawn'
    - 'vehicle_spawn', 'vehicle_modify', 'vehicle_teleport'
    - 'money_change', 'item_use', 'item_give'
    - 'admin_action', 'command_use', 'permission_check'
    - 'location_change', 'teleport', 'noclip'
    - 'chat_message', 'suspicious_chat', 'spam_attempt'
    
    Best Practices:
    - Don't track every single action (performance impact)
    - Focus on actions that could indicate cheating
    - Include relevant context in the details object
    - Use consistent naming conventions for action types
    - Test thoroughly to avoid false positives
--]]