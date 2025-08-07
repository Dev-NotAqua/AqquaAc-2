local PlayerPedId = PlayerPedId
local PlayerId = PlayerId
local GetPlayerName = GetPlayerName
local GetPlayerInvincible_2 = GetPlayerInvincible_2
local SetEntityHealth = SetEntityHealth
local GetEntityHealth = GetEntityHealth
local NetworkIsInSpectatorMode = NetworkIsInSpectatorMode
local GetEntityCoords = GetEntityCoords
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetVehicleTopSpeedModifier = GetVehicleTopSpeedModifier
local GetVehicleCheatPowerIncrease = GetVehicleCheatPowerIncrease
local GetEntitySpeed = GetEntitySpeed
local IsPedInAnyVehicle = IsPedInAnyVehicle

AddEventHandler('playerSpawned', function()
  TriggerServerEvent('vac_player_activated')
end)

permissions = nil
RegisterNetEvent('vac_receive_permission')
AddEventHandler('vac_receive_permission', function(hasPermission)
  if hasPermission then
    permissions = true
  else
    permissions = false
  end
end)

CreateThread(function()
  local strikes = 0
  local maxStrikes = GetConvarInt('aqqua_maximum_godmode_strikes', 5)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then

    while true do
      Wait(2500)
      local playerPed = PlayerPedId()

      if GetPlayerInvincible_2(playerPed) then
        TriggerServerEvent('vac_detection', 'GodMode', 'GodMode `GetPlayerInvincible_2()`', true)
      end

      local health = GetEntityHealth(playerPed)
      SetEntityHealth(playerPed, health - 2)
      Wait(math.random(0, 1000))

      if not IsPlayerDead(PlayerId()) then
        if GetEntityHealth(playerPed) == health and health ~= 0 then
          strikes = strikes + 1
        end
      end
      SetEntityHealth(playerPed, health + 2)

      if strikes >= maxStrikes then
        TriggerServerEvent('vac_detection', 'GodMode', 'GodMode `GetEntityHealth()`', true)
      end
    end
  end
  return print('^6[INFO] [AQQUA]^7 Terminated GodMode thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)

CreateThread(function()
  local strikes = 0
  local maxStrikes = GetConvarInt('aqqua_maximum_spectator_strikes', 5)
        local camDistance = GetConvarInt('aqqua_maximum_cam_distance', 200)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then
    while true do
      Wait(2500)

      local playerPed = PlayerPedId()

      if NetworkIsInSpectatorMode() then
        strikes = strikes + 1
      end

      local cam = #(GetEntityCoords(playerPed) - GetFinalRenderedCamCoord())

      if cam >= camDistance then
        strikes = strikes + 1
      end

      if strikes >= maxStrikes then
        TriggerServerEvent('vac_detection', 'Spectating', 'Spectating', true)
      end
    end
  end
  return print('^6[INFO] [AQQUA]^7 Terminated Spectator thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)


CreateThread(function()
  local maxModifier = GetConvarInt('aqqua_maximum_modifier', 2)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then

    if maxModifier >= 2 then

      while true do
        Wait(2500)

        local playerPed = PlayerPedId()
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)

        if playerVehicle ~= 0 then
          if GetVehicleTopSpeedModifier(playerVehicle) > maxModifier then
            TriggerServerEvent('vac_detection', 'Speed Modifier', 'Exceeded maximum speed modifier', true)
          end

          if GetVehicleCheatPowerIncrease(playerVehicle) > maxModifier then
            TriggerServerEvent('vac_detection', 'Speed Modifier', 'Exceeded maximum speed modifier', true)
          end
        end
      end
      return print('^6[INFO] [AQQUA]^7 Terminated Speed Modifier Thread improper configuration, MaximumSpeedModifier cannot be less than or equal to one.')
    end
  end
  return print('^6[INFO] [AQQUA]^7 Terminated Speed Modifier thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)

-- Enhanced Speed Detection (On Foot)
CreateThread(function()
  local strikes = 0
  local maxStrikes = GetConvarInt('aqqua_maximum_speed_strikes', 5)
        local maxSpeed = GetConvarInt('aqqua_maximum_on_foot_speed', 15)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then
    while true do
      Wait(2500)
      local playerPed = PlayerPedId()
      
      if not IsPedInAnyVehicle(playerPed, false) then
        local speed = GetEntitySpeed(playerPed)
        
        if speed > maxSpeed then
          strikes = strikes + 1
          
          if strikes >= maxStrikes then
            TriggerServerEvent('vac_detection', 'Speed Hack', 'Abnormal on-foot speed detected: ' .. tostring(speed), true)
            strikes = 0
          end
        else
          strikes = math.max(0, strikes - 1)
        end
      end
    end
  end
  return print('^6[INFO] [AQQUA]^7 Terminated Speed Detection thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)

-- Enhanced Health and Armor Detection
CreateThread(function()
  local strikes = 0
  local maxStrikes = GetConvarInt('aqqua_maximum_health_strikes', 5)
        local maxHealth = GetConvarInt('aqqua_maximum_health', 200)
        local maxArmor = GetConvarInt('aqqua_maximum_armor', 100)
  local lastHealth = 0
  local lastArmor = 0
  local healthIncreaseThreshold = GetConvarInt('aqqua_health_increase_threshold', 120)
        local armorIncreaseThreshold = GetConvarInt('aqqua_armor_increase_threshold', 110)
  local rapidIncreaseCount = 0
  local lastIncreaseTime = 0

  while permissions == nil do
    Wait(500)
  end

  if not permissions then
    while true do
      Wait(3000)
      local playerPed = PlayerPedId()
      local currentHealth = GetEntityHealth(playerPed)
      local currentArmor = GetPedArmour(playerPed)
      local currentTime = GetGameTimer()
      
      -- Check for abnormal max health (only if significantly above normal)
      if currentHealth > maxHealth then
        strikes = strikes + 1
        
        if strikes >= maxStrikes then
          TriggerServerEvent('vac_detection', 'Health Hack', 'Abnormal health detected: ' .. tostring(currentHealth), true)
          strikes = 0
        end
      -- Check for abnormal max armor
      elseif currentArmor > maxArmor then
        strikes = strikes + 1
        
        if strikes >= maxStrikes then
          TriggerServerEvent('vac_detection', 'Armor Hack', 'Abnormal armor detected: ' .. tostring(currentArmor), true)
          strikes = 0
        end
      else
        -- Check for suspicious rapid increases (multiple large increases in short time)
        local healthIncrease = currentHealth - lastHealth
        local armorIncrease = currentArmor - lastArmor
        local timeSinceLastIncrease = currentTime - lastIncreaseTime
        
        -- Only flag if increase is very large AND happens frequently
        if (healthIncrease > healthIncreaseThreshold and timeSinceLastIncrease < 5000) or
           (armorIncrease > armorIncreaseThreshold and timeSinceLastIncrease < 5000) then
          rapidIncreaseCount = rapidIncreaseCount + 1
          lastIncreaseTime = currentTime
          
          -- Only trigger after multiple rapid increases (reduces false positives)
          if rapidIncreaseCount >= 3 then
            if healthIncrease > healthIncreaseThreshold then
              TriggerServerEvent('vac_detection', 'Health Hack', 'Suspicious rapid health increases detected', true)
            else
              TriggerServerEvent('vac_detection', 'Armor Hack', 'Suspicious rapid armor increases detected', true)
            end
            rapidIncreaseCount = 0
          end
        else
          -- Reset counters if no suspicious activity
          strikes = math.max(0, strikes - 1)
          if timeSinceLastIncrease > 10000 then -- Reset after 10 seconds of normal behavior
            rapidIncreaseCount = 0
          end
        end
      end
      
      lastHealth = currentHealth
      lastArmor = currentArmor
    end
  end
  return print('^6[INFO] [AQQUA]^7 Terminated Health/Armor Detection thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)
