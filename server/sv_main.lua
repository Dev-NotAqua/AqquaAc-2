-- Copyright (C) 2019 - 2023  NotSomething

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local RESOURCE_NAME <const> = GetCurrentResourceName()
local CURRENT_VERSION <const> = GetResourceMetadata(RESOURCE_NAME, 'version', 0)
-- Repository to check for updates; override with ConVar 'vac:main:update_repo'
local UPDATE_REPO <const> = GetConvar('vac:main:update_repo', 'Dev-NotAqua/AqquaAc-2')

AddEventHandler('onResourceStart', function(resourceName)
  if RESOURCE_NAME ~= resourceName then
    return
  end

  PerformHttpRequest(('https://api.github.com/repos/%s/releases'):format(UPDATE_REPO), function(code, data, _)
    local latestVersion = CURRENT_VERSION

    if code == 200 then
      local success, releases = pcall(json.decode, data)
      if success and type(releases) == 'table' and releases[1] and releases[1].name then
        latestVersion = releases[1].name
      end
    else
      log.warn(('[MAIN]: GitHub version check failed with code %s'):format(code))
    end

    if CURRENT_VERSION ~= latestVersion then
      log.info(('This version of AqquaAC is outdated! Please update as soon as possible!\n Latest Version: %s | Current Version: %s^7'):format(latestVersion, CURRENT_VERSION))
    end
  end, 'GET', '', {['User-Agent'] = 'AqquaAC'})

  TriggerEvent('__vac_internal:initialize', 'all')
end)

local function checkForInvincibility()
  local players = PlayerCache()

  for netId, player in pairs(players) do
    -- We need GetEntityProofs and SetEntityHealth server side before we can do any meaningful checks
    if not IsPlayerAceAllowed(netId, 'vac:invincible') and GetPlayerInvincible(netId) then
      player:punish('playerUsingInvincibility', 'Positive result from GetPlayerInvincible')
    end
  end
end

local invincibilityCheck = false

CreateThread(function()
  while true do
    if invincibilityCheck then
      checkForInvincibility()
      Wait(2500) -- reduced frequency while active
    else
      Wait(5000) -- longer sleep when check disabled
    end
  end
end)

local function checkForSuperJump()
  local players = PlayerCache()

  for netId, player in pairs(players) do
    if not IsPlayerAceAllowed(netId, 'vac:superJump') and IsPlayerUsingSuperJump(netId) then
      player:punish('playerUsingSuperJump', 'Positive result from IsPlayerUsingSuperJump')
    end
  end
end

local superJumpCheck = false

CreateThread(function()
  while true do
    if superJumpCheck then
      checkForSuperJump()
      Wait(2500)
    else
      Wait(5000)
    end
  end
end)

AddEventHandler('__vac_internal:initialize', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'main' then
    return
  end

  invincibilityCheck = GetConvarBool('vac:main:god_mode_check', false)
  superJumpCheck = GetConvarBool('vac:main:super_jump_check', false)

  log.info(('[MAIN]: Data synced | Invincibility Check: %s | Super Jump Check: %s'):format(invincibilityCheck, superJumpCheck))
end)

-- Enhanced Behavior Analysis System
local playerBehavior = {}
local cheatSignatures = {}

-- Enhanced Security Event Logging
function LogSecurityEvent(source, eventType, details)
  local logEntry = {
    timestamp = os.time(),
    player = GetPlayerIdentifiers(source),
    playerName = GetPlayerName(source),
    eventType = eventType,
    details = details,
    location = GetEntityCoords(GetPlayerPed(source))
  }
  
  -- Log to server console with enhanced formatting
  log.warn(('[SECURITY]: %s | Player: %s (%s) | Event: %s | Details: %s'):format(
    os.date('%Y-%m-%d %H:%M:%S', logEntry.timestamp),
    logEntry.playerName,
    source,
    eventType,
    details
  ))
  
  -- Save to security log file
  local logData = json.encode(logEntry) .. '\n'
  SaveResourceFile(GetCurrentResourceName(), 'logs/security.log', logData, true)
end

-- Player Behavior Analysis
RegisterNetEvent('vac:playerAction')
AddEventHandler('vac:playerAction', function(actionType, details)
  local source = source
  if not playerBehavior[source] then
    playerBehavior[source] = {}
  end
  
  table.insert(playerBehavior[source], {
    type = actionType,
    details = details,
    timestamp = os.time()
  })
  
  -- Analyze patterns after collecting enough data
  if #playerBehavior[source] > 10 then
    AnalyzeBehavior(source)
  end
end)

function AnalyzeBehavior(source)
  local behavior = playerBehavior[source]
  if not behavior then return end
  
  -- Pattern detection: Rapid successive actions
  local rapidActions = 0
  local timeWindow = 10 -- seconds
  local currentTime = os.time()
  
  for i = #behavior, math.max(1, #behavior - 20), -1 do
    if currentTime - behavior[i].timestamp <= timeWindow then
      rapidActions = rapidActions + 1
    end
  end
  
  -- Trigger alert for suspicious rapid actions
  if rapidActions > 15 then
    LogSecurityEvent(source, 'Suspicious Behavior', 'Rapid actions detected: ' .. rapidActions .. ' actions in ' .. timeWindow .. ' seconds')
  end
  
  -- Clean old behavior data (keep last 50 entries)
  if #behavior > 50 then
    for i = 1, #behavior - 50 do
      table.remove(behavior, 1)
    end
  end
end

-- Enhanced Entity Validation
AddEventHandler('entityCreating', function(entity)
  local model = GetEntityModel(entity)
  local owner = NetworkGetEntityOwner(entity)
  
  -- Check if entity creation is legitimate
  if not IsEntityCreationAllowed(owner, model) then
    CancelEvent()
    LogSecurityEvent(owner, 'Suspicious Entity', 'Blocked entity creation: ' .. tostring(model))
  end
end)

function IsEntityCreationAllowed(player, model)
  -- Check if player has elevated permissions
  if IsPlayerAceAllowed(player, 'vac:ultraviolet') then
    return true
  end
  
  -- Add your custom validation logic here
  -- For example, check if model is in whitelist, player location, etc.
  
  return true -- Default allow for now
end

-- Dynamic Signature Updates
function UpdateSignatures()
  -- You can implement fetching from your own server
  -- For now, we'll use local signatures
  cheatSignatures = {
    speedHack = { threshold = 50.0, strikes = 3 },
    healthHack = { maxHealth = 200, regenThreshold = 50 },
    teleportHack = { maxDistance = 100.0, timeWindow = 5 }
  }
end

-- Update signatures periodically
CreateThread(function()
  while true do
    Wait(300000) -- Update every 5 minutes
    UpdateSignatures()
  end
end)

-- Initialize signatures on startup
UpdateSignatures()

-- Clean up player behavior data on disconnect
AddEventHandler('playerDropped', function()
  local source = source
  if playerBehavior[source] then
    playerBehavior[source] = nil
  end
end)