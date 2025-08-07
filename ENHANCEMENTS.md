# AqquaAC Enhanced Features

This document outlines the enhanced anti-cheat features that have been added to the AqquaAC resource.

## New Detection Methods

### 1. Enhanced Speed Detection (On-Foot)
- **Purpose**: Detects players moving at abnormal speeds while not in a vehicle
- **Configuration**:
  - `valkyrie_maximum_speed_strikes`: Maximum strikes before triggering detection (default: 5)
  - `valkyrie_maximum_on_foot_speed`: Maximum allowed speed on foot (default: 15)
- **Detection**: Monitors player speed every 2.5 seconds when not in a vehicle

### 2. Enhanced Health and Armor Detection
- **Purpose**: Detects abnormal health/armor values and rapid regeneration while minimizing false positives
- **Configuration**:
  - `valkyrie_maximum_health_strikes`: Maximum strikes for abnormal health (default: 3)
  - `valkyrie_maximum_health`: Maximum allowed health value (default: 200)
  - `valkyrie_maximum_armor`: Maximum allowed armor value (default: 100)
  - `valkyrie_health_increase_threshold`: Threshold for rapid health increase detection (default: 120)
  - `valkyrie_armor_increase_threshold`: Threshold for rapid armor increase detection (default: 110)
- **Detection**: 
  - **Abnormal Health Values**: Detects players with health significantly above configured maximum (200 HP)
  - **Abnormal Armor Values**: Detects players with armor above configured maximum (100 AP)
  - **Intelligent Regeneration Detection**: Monitors for suspicious rapid increases while avoiding false positives from legitimate medkits/armor vests
  - **Multi-Strike System**: Requires multiple rapid increases (3+) within short timeframes to trigger detection
  - **Time-Based Analysis**: Uses timing analysis to differentiate between legitimate item usage and cheating
  - **Configurable Thresholds**: Adjustable maximum health/armor and regeneration limits with reasonable defaults

## Behavior Analysis System

### Machine Learning Integration
- **Purpose**: Analyzes player behavior patterns to detect suspicious activities
- **Features**:
  - Tracks player actions and timestamps
  - Detects rapid successive actions that may indicate automation
  - Maintains behavior history for pattern analysis
- **Configuration**:
  - `vac:behavior:analysis_enabled`: Enable/disable behavior analysis (default: true)
  - `vac:behavior:rapid_action_threshold`: Actions threshold for suspicious behavior (default: 15)
  - `vac:behavior:time_window`: Time window for action analysis in seconds (default: 10)

### Usage
To track player actions, trigger the following event from your resources:
```lua
TriggerServerEvent('vac:playerAction', 'action_type', 'action_details')
```

## Enhanced Entity Validation

### Advanced Entity Creation Monitoring
- **Purpose**: Validates entity creation attempts and blocks unauthorized entities
- **Features**:
  - Monitors all entity creation events
  - Validates against player permissions
  - Logs blocked entity creation attempts
- **Configuration**:
  - `vac:entity:enhanced_validation`: Enable enhanced validation (default: true)
  - `vac:entity:log_blocked_entities`: Log blocked entities (default: true)

### Customization
Modify the `IsEntityCreationAllowed` function in `sv_main.lua` to implement custom validation logic:
```lua
function IsEntityCreationAllowed(player, model)
  -- Add your custom validation logic here
  -- Examples:
  -- - Check whitelist/blacklist of models
  -- - Validate player location
  -- - Check game state conditions
  return true -- or false to block
end
```

## Enhanced Logging & Monitoring

### Security Event Logging
- **Purpose**: Comprehensive logging of all security events
- **Features**:
  - Detailed log entries with timestamps, player info, and coordinates
  - Console logging with enhanced formatting
  - File-based logging to `logs/security.log`
  - Automatic log rotation and cleanup

### Log Format
```json
{
  "timestamp": 1691234567,
  "player": ["steam:110000123456789", "license:abc123"],
  "playerName": "PlayerName",
  "eventType": "Speed Hack",
  "details": "Abnormal on-foot speed detected: 25.5",
  "location": {"x": 123.45, "y": 678.90, "z": 21.34}
}
```

## Dynamic Signature Updates

### Cheat Signature System
- **Purpose**: Maintains up-to-date detection signatures for known cheats
- **Features**:
  - Automatic signature updates every 5 minutes
  - Configurable detection thresholds
  - Support for external signature sources

### Current Signatures
- **speedHack**: Speed-related cheat detection
- **healthHack**: Health manipulation detection
- **teleportHack**: Teleportation cheat detection

### Customization
Modify the `UpdateSignatures` function to fetch from your own server:
```lua
function UpdateSignatures()
  PerformHttpRequest('https://your-server.com/signatures.json', function(status, response)
    if status == 200 then
      cheatSignatures = json.decode(response)
    end
  end)
end
```

## Installation & Configuration

### 1. Configuration Updates
The enhanced features are automatically configured through the updated `config.cfg` file. Key settings include:

```cfg
### Enhanced Detection Options ###
# Speed Detection Settings
set valkyrie_maximum_speed_strikes 5
set valkyrie_maximum_on_foot_speed 15

# Health and Armor Detection Settings
set valkyrie_maximum_health_strikes 5
set valkyrie_maximum_health 200
set valkyrie_health_increase_threshold 120
set valkyrie_maximum_armor 100
set valkyrie_armor_increase_threshold 110

# Behavior Analysis Settings
set vac:behavior:analysis_enabled true
set vac:behavior:rapid_action_threshold 15
set vac:behavior:time_window 10

# Entity Validation Settings
set vac:entity:enhanced_validation true
set vac:entity:log_blocked_entities true
```

### 2. Permissions
The existing permission system remains unchanged:
- `vac:ultraviolet`: Bypass all checks
- `vac:invincibility`: Bypass invincibility checks
- `vac:superjump`: Bypass super jump checks

### 3. Monitoring
- Check `logs/security.log` for detailed security events
- Monitor server console for real-time security alerts
- Review behavior analysis reports for suspicious patterns

## Performance Considerations

### Optimizations Implemented
- **Efficient Threading**: Detection loops use appropriate wait times
- **Strike System**: Prevents false positives through strike accumulation
- **Data Cleanup**: Automatic cleanup of old behavior data
- **Conditional Checks**: Checks only run when necessary

### Resource Usage
- **Client-side**: Minimal impact with optimized detection loops
- **Server-side**: Efficient data structures and periodic cleanup
- **Storage**: Automatic log rotation prevents disk space issues

## Troubleshooting

### Common Issues
1. **False Positives**: Adjust strike thresholds in configuration
2. **Performance Impact**: Increase wait times in detection loops
3. **Log File Size**: Implement log rotation if needed
4. **Permission Issues**: Ensure proper ACE permissions are set

### Debug Mode
Enable detailed logging by setting:
```cfg
set vac:internal:log_level 5
```

## Future Enhancements

### Planned Features
- **Discord Integration**: Webhook notifications for security events
- **Web Dashboard**: Real-time monitoring interface
- **Advanced ML**: More sophisticated behavior analysis
- **API Integration**: External cheat database integration

### Contributing
To contribute additional detection methods:
1. Follow the existing pattern in `cl_loops.lua` for client-side detection
2. Use the `LogSecurityEvent` function for consistent logging
3. Add appropriate configuration options to `config.cfg`
4. Update this documentation

---

**Note**: These enhancements maintain compatibility with the existing AqquaAC/Valkyrie system while adding powerful new detection capabilities. All features can be individually enabled/disabled through configuration.