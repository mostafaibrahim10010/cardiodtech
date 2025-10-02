import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Robust Health Connect service with comprehensive error handling
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  Health? _health;
  bool _isInitialized = false;
  String _lastError = '';
  bool _healthConnectAvailable = false;

  // Health data types we want to read from Health Connect
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.WORKOUT,
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('Health service: Initializing Health Connect...');
      
      // Create Health instance
      _health = Health();
      
      // Configure the health plugin before use
      await _health!.configure();
      debugPrint('Health service: Health plugin configured');
      
      // First, request runtime permissions
      await _requestRuntimePermissions();
      
      // Check if Health Connect is available by trying to request permissions
      try {
        // Try to request permissions to check if Health Connect is available
        bool hasPermissions = await _health!.requestAuthorization(_healthDataTypes);
        _healthConnectAvailable = true; // If we get here without error, Health Connect is available
        debugPrint('Health service: Health Connect available: $_healthConnectAvailable');
        
        if (!hasPermissions) {
          _lastError = 'Health Connect permissions not granted. Please grant permissions in app settings.';
          debugPrint('Health service: $_lastError');
          _isInitialized = true;
          return;
        }
      } catch (e) {
        _healthConnectAvailable = false;
        _lastError = 'Health Connect is not available on this device. Please install Health Connect from Google Play Store.';
        debugPrint('Health service: $_lastError');
        _isInitialized = true;
        return;
      }

      // Test data access to verify everything is working
      debugPrint('Health service: Testing data access...');
      try {
        final testData = await _health!.getHealthDataFromTypes(
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now(),
          types: [HealthDataType.HEART_RATE],
        );
        debugPrint('Health service: Test data access successful - found ${testData.length} data points');
      } catch (e) {
        debugPrint('Health service: Test data access failed: $e');
        // Don't fail initialization just because no data is available
      }

      _isInitialized = true;
      _lastError = '';
      debugPrint('Health service: Initialized successfully with Health Connect');
    } catch (e) {
      _lastError = 'Failed to initialize health service: $e';
      debugPrint('Health service: $_lastError');
      _isInitialized = true;
      
      // Automatically run diagnostic when initialization fails
      _runAutomaticDiagnostic();
    }
  }

  /// Request runtime permissions required for health data access
  Future<void> _requestRuntimePermissions() async {
    try {
      debugPrint('Health service: Requesting runtime permissions...');
      
      // Request activity recognition permission
      var activityStatus = await Permission.activityRecognition.request();
      debugPrint('Health service: Activity recognition permission: $activityStatus');
      
      // Request location permissions for workout distance
      var locationStatus = await Permission.location.request();
      debugPrint('Health service: Location permission: $locationStatus');
      
      // Request body sensors permission
      var sensorStatus = await Permission.sensors.request();
      debugPrint('Health service: Body sensors permission: $sensorStatus');
      
    } catch (e) {
      debugPrint('Health service: Error requesting runtime permissions: $e');
    }
  }

  /// Get all health data with comprehensive error handling
  Future<Map<String, dynamic>> getAllHealthData() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        debugPrint('Health service: Cannot get health data - not initialized');
        return {};
      }
    }

    if (_health == null) {
      debugPrint('Health service: Health instance is null');
      return {};
    }

    try {
      final now = DateTime.now();
      Map<String, dynamic> result = {};

      debugPrint('Health service: Fetching all health data...');

      // First, verify permissions are still valid
      final permissionsValid = await checkAllPermissions();
      if (!permissionsValid) {
        _lastError = 'Permissions are not valid. Please re-grant permissions.';
        debugPrint('Health service: $_lastError');
        return {};
      }

      // Try multiple time ranges to find data
      final timeRanges = [
        {'name': '24 hours', 'duration': const Duration(hours: 24)},
        {'name': '3 days', 'duration': const Duration(days: 3)},
        {'name': '7 days', 'duration': const Duration(days: 7)},
        {'name': '30 days', 'duration': const Duration(days: 30)},
      ];

      bool dataFound = false;
      
      for (final range in timeRanges) {
        final startTime = now.subtract(range['duration'] as Duration);
        debugPrint('Health service: Trying ${range['name']} range: $startTime to $now');

        try {
          final healthData = await _health!.getHealthDataFromTypes(
            startTime: startTime,
            endTime: now,
            types: _healthDataTypes,
          );

          debugPrint('Health service: Found ${healthData.length} total health data points in ${range['name']} range');

          if (healthData.isNotEmpty) {
            // Process each data type to get the most recent values
            _processHealthDataRealTime(healthData, result);
            dataFound = true;
            debugPrint('Health service: Successfully processed data from ${range['name']} range');
            break; // Stop trying other ranges once we find data
          }
        } catch (e) {
          debugPrint('Health service: Error fetching data from ${range['name']} range: $e');
          
          // If it's a permission error, update the error message and stop trying
          if (e.toString().contains('permission') || e.toString().contains('denied')) {
            _lastError = 'Health Connect permissions have been revoked. Please re-grant permissions.';
            debugPrint('Health service: Permission error detected: $_lastError');
            return {};
          }
          
          // Continue to next time range if this one failed
          continue;
        }
      }
      
      if (!dataFound) {
        debugPrint('Health service: No health data found in any time range');
      }

      debugPrint('Health service: Final result: $result');
      
      // If no data found, run diagnostic to help troubleshoot
      if (result.isEmpty) {
        debugPrint('Health service: No health data found - running diagnostic...');
        _runAutomaticDiagnostic();
      }
      
      return result;
    } catch (e) {
      _lastError = 'Error getting all health data: $e';
      debugPrint('Health service: $_lastError');
      
      // Automatically run diagnostic when data retrieval fails
      _runAutomaticDiagnostic();
      return {};
    }
  }

  /// Process health data and extract the most recent values for real-time display
  void _processHealthDataRealTime(List<HealthDataPoint> healthData, Map<String, dynamic> result) {
    debugPrint('Health service: Processing ${healthData.length} health data points...');
    
    // Group data by type for easier processing
    final dataByType = <HealthDataType, List<HealthDataPoint>>{};
    for (final data in healthData) {
      dataByType.putIfAbsent(data.type, () => []).add(data);
    }
    
    debugPrint('Health service: Data breakdown by type:');
    dataByType.forEach((type, data) {
      debugPrint('  $type: ${data.length} data points');
    });

    // Process heart rate - get the most recent value
    final heartRateData = dataByType[HealthDataType.HEART_RATE] ?? [];
    debugPrint('Health service: Found ${heartRateData.length} heart rate data points');
    if (heartRateData.isNotEmpty) {
      heartRateData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latestHeartRate = heartRateData.first;
      if (latestHeartRate.value is NumericHealthValue) {
        final heartRateValue = (latestHeartRate.value as NumericHealthValue).numericValue;
        if (heartRateValue > 0) {
          result['heartRate'] = heartRateValue.round();
          result['heartRateTime'] = latestHeartRate.dateFrom;
          debugPrint('Health service: Latest heart rate: ${result['heartRate']} bpm at ${result['heartRateTime']}');
        }
      }
    }

    // Process oxygen saturation - get the most recent value
    final oxygenData = dataByType[HealthDataType.BLOOD_OXYGEN] ?? [];
    debugPrint('Health service: Found ${oxygenData.length} oxygen saturation data points');
    if (oxygenData.isNotEmpty) {
      oxygenData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latestOxygen = oxygenData.first;
      if (latestOxygen.value is NumericHealthValue) {
        final oxygenValue = (latestOxygen.value as NumericHealthValue).numericValue;
        if (oxygenValue > 0) {
          result['oxygenSaturation'] = oxygenValue.round();
          result['oxygenTime'] = latestOxygen.dateFrom;
          debugPrint('Health service: Latest oxygen saturation: ${result['oxygenSaturation']}% at ${result['oxygenTime']}');
        }
      }
    }

    // Process calories - sum for today only
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final caloriesData = dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] ?? [];
    final todayCaloriesData = caloriesData
        .where((data) => data.dateFrom.isAfter(todayStart))
        .toList();
    debugPrint('Health service: Found ${todayCaloriesData.length} calories data points for today');
    if (todayCaloriesData.isNotEmpty) {
      double totalCalories = 0;
      for (var data in todayCaloriesData) {
        if (data.value is NumericHealthValue) {
          totalCalories += (data.value as NumericHealthValue).numericValue;
        }
      }
      if (totalCalories > 0) {
        result['calories'] = totalCalories.round();
        result['caloriesTime'] = todayCaloriesData.last.dateFrom; // Use last data point time
        debugPrint('Health service: Today\'s calories: ${result['calories']} kcal');
      }
    }

    // Process sleep - get the most recent sleep session
    final sleepData = dataByType[HealthDataType.SLEEP_IN_BED] ?? [];
    debugPrint('Health service: Found ${sleepData.length} sleep data points');
    if (sleepData.isNotEmpty) {
      sleepData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latestSleep = sleepData.first;
      if (latestSleep.value is NumericHealthValue) {
        final sleepValue = (latestSleep.value as NumericHealthValue).numericValue;
        if (sleepValue > 0) {
          result['sleepHours'] = sleepValue;
          result['sleepTime'] = latestSleep.dateFrom;
          debugPrint('Health service: Latest sleep: ${result['sleepHours']} hours at ${result['sleepTime']}');
        }
      }
    }

    // Process steps - get today's total steps
    final stepsData = dataByType[HealthDataType.STEPS] ?? [];
    final todayStepsData = stepsData
        .where((data) => data.dateFrom.isAfter(todayStart))
        .toList();
    debugPrint('Health service: Found ${todayStepsData.length} steps data points for today');
    if (todayStepsData.isNotEmpty) {
      double totalSteps = 0;
      for (var data in todayStepsData) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue;
        }
      }
      if (totalSteps > 0) {
        result['steps'] = totalSteps.round();
        debugPrint('Health service: Today\'s steps: ${result['steps']}');
      }
    }

    // Process distance - get today's total distance
    final distanceData = dataByType[HealthDataType.DISTANCE_DELTA] ?? [];
    final todayDistanceData = distanceData
        .where((data) => data.dateFrom.isAfter(todayStart))
        .toList();
    debugPrint('Health service: Found ${todayDistanceData.length} distance data points for today');
    if (todayDistanceData.isNotEmpty) {
      double totalDistance = 0;
      for (var data in todayDistanceData) {
        if (data.value is NumericHealthValue) {
          totalDistance += (data.value as NumericHealthValue).numericValue;
        }
      }
      if (totalDistance > 0) {
        result['distance'] = totalDistance;
        debugPrint('Health service: Today\'s distance: ${result['distance']} km');
      }
    }

    // Process workouts - get the most recent workout
    final workoutData = dataByType[HealthDataType.WORKOUT] ?? [];
    debugPrint('Health service: Found ${workoutData.length} workout data points');
    if (workoutData.isNotEmpty) {
      workoutData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latestWorkout = workoutData.first;
      result['lastWorkout'] = {
        'type': latestWorkout.value.toString(),
        'time': latestWorkout.dateFrom,
      };
      debugPrint('Health service: Latest workout: ${result['lastWorkout']}');
    }
    
    debugPrint('Health service: Final processed result: $result');
  }

  /// Check if we have any health data available
  Future<bool> hasAnyHealthData() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return false;
    }

    if (_health == null) return false;

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final healthData = await _health!.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: _healthDataTypes,
      );

      debugPrint('Health service: Checking for any health data - found ${healthData.length} data points');
      return healthData.isNotEmpty;
    } catch (e) {
      debugPrint('Health service: Error checking for health data: $e');
      return false;
    }
  }

  /// Check if all required permissions are granted
  Future<bool> checkAllPermissions() async {
    try {
      debugPrint('Health service: Checking all permissions...');
      
      // Check runtime permissions
      final activityStatus = await Permission.activityRecognition.status;
      final locationStatus = await Permission.location.status;
      final sensorStatus = await Permission.sensors.status;
      
      debugPrint('Health service: Activity recognition: $activityStatus');
      debugPrint('Health service: Location: $locationStatus');
      debugPrint('Health service: Body sensors: $sensorStatus');
      
      final runtimePermissionsGranted = activityStatus.isGranted && 
                                       locationStatus.isGranted && 
                                       sensorStatus.isGranted;
      
      debugPrint('Health service: Runtime permissions granted: $runtimePermissionsGranted');
      
      // Check Health Connect permissions
      if (!_isInitialized) {
        await initialize();
      }
      
      if (!_isInitialized) {
        debugPrint('Health service: Cannot check Health Connect permissions - not initialized');
        return false;
      }
      
      // Verify Health Connect permissions by trying to access data
      if (_health != null && _healthConnectAvailable) {
        try {
          final now = DateTime.now();
          // Try a broader time range and more data types for permission verification
          final testData = await _health!.getHealthDataFromTypes(
            startTime: now.subtract(const Duration(days: 1)),
            endTime: now,
            types: _healthDataTypes,
          );
          debugPrint('Health service: Health Connect permissions verified - can access data (${testData.length} data points)');
          return runtimePermissionsGranted && true;
        } catch (e) {
          debugPrint('Health service: Health Connect permissions verification failed: $e');
          
          // Check if it's a permission error or just no data
          if (e.toString().contains('permission') || 
              e.toString().contains('denied') || 
              e.toString().contains('unauthorized')) {
            _lastError = 'Health Connect permissions may have been revoked. Please re-grant permissions.';
            return false;
          } else {
            // If it's not a permission error, permissions might be OK but no data available
            debugPrint('Health service: Permission check passed but no data available: $e');
            return runtimePermissionsGranted && _healthConnectAvailable;
          }
        }
      }
      
      return runtimePermissionsGranted && _healthConnectAvailable;
    } catch (e) {
      debugPrint('Health service: Error checking permissions: $e');
      return false;
    }
  }

  bool get isInitialized => _isInitialized;
  String get lastError => _lastError;
  bool get healthConnectAvailable => _healthConnectAvailable;

  Future<bool> isHealthDataAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return _isInitialized && _lastError.isEmpty && _healthConnectAvailable;
    } catch (e) {
      _lastError = 'Error checking health data availability: $e';
      debugPrint('Health service: $_lastError');
      return false;
    }
  }

  /// Get user-friendly error message with actionable steps
  String getUserFriendlyErrorMessage() {
    if (_lastError.isEmpty) return '';
    
    if (_lastError.contains('not available')) {
      return 'Health Connect is not installed. Please install it from Google Play Store and try again.';
    } else if (_lastError.contains('permissions not granted') || _lastError.contains('permissions are not valid')) {
      return 'Please grant health permissions in your device settings: Settings > Apps > CardioDTech > Permissions';
    } else if (_lastError.contains('permissions have been revoked')) {
      return 'Health Connect permissions have been revoked. Please re-grant permissions in your device settings.';
    } else if (_lastError.contains('No data') || _lastError.contains('not found')) {
      return 'No health data found. Make sure your fitness tracker is connected and syncing with Health Connect.';
    } else if (_lastError.contains('Failed to initialize')) {
      return 'Unable to initialize Health Connect. Please check if Health Connect is installed and try again.';
    } else {
      return 'Unable to access health data. Please check your Health Connect settings and try again.';
    }
  }

  // Method to reset the service (useful for debugging)
  void reset() {
    _isInitialized = false;
    _lastError = '';
    _healthConnectAvailable = false;
    _health = null;
    debugPrint('Health service: Reset');
  }

  /// Re-request all permissions (useful when permissions are denied)
  Future<bool> requestPermissions() async {
    try {
      debugPrint('Health service: Re-requesting all permissions...');
      
      // Reset the service state
      reset();
      
      // Request runtime permissions first
      await _requestRuntimePermissions();
      
      // Re-initialize Health Connect
      await initialize();
      
      // Check if permissions are now granted
      final permissionsGranted = await checkAllPermissions();
      
      if (permissionsGranted) {
        debugPrint('Health service: All permissions granted successfully');
        return true;
      } else {
        debugPrint('Health service: Some permissions still not granted');
        return false;
      }
    } catch (e) {
      debugPrint('Health service: Error requesting permissions: $e');
      _lastError = 'Failed to request permissions: $e';
      return false;
    }
  }

  /// Automatically run diagnostic when there are issues
  Future<void> _runAutomaticDiagnostic() async {
    try {
      debugPrint('=== AUTOMATIC HEALTH CONNECT DIAGNOSTIC ===');
      debugPrint('Running diagnostic due to initialization failure...');
      
      final diagnostic = await runDiagnostic();
      
      debugPrint('=== AUTOMATIC DIAGNOSTIC RESULTS ===');
      debugPrint('Health Connect Available: ${diagnostic['healthConnectAvailable']}');
      debugPrint('Runtime Permissions: ${diagnostic['runtimePermissions']}');
      debugPrint('Health Connect Permissions: ${diagnostic['healthConnectPermissions']}');
      debugPrint('Data Available: ${diagnostic['dataAvailable']}');
      debugPrint('Data Points Found: ${diagnostic['dataPointsFound']}');
      
      if (diagnostic['dataBreakdown'] != null) {
        debugPrint('Data Breakdown:');
        (diagnostic['dataBreakdown'] as Map).forEach((key, value) {
          debugPrint('  $key: $value data points');
        });
      }
      
      if (diagnostic['errors'].isNotEmpty) {
        debugPrint('Errors found:');
        for (String error in diagnostic['errors']) {
          debugPrint('  - $error');
        }
      }
      
      if (diagnostic['success']) {
        debugPrint(' Health Connect integration is working correctly!');
      } else {
        debugPrint(' Health Connect integration has issues - check errors above');
      }
      
      debugPrint('=== AUTOMATIC DIAGNOSTIC COMPLETE ===');
    } catch (e) {
      debugPrint(' Error during automatic diagnostic: $e');
    }
  }

  /// Comprehensive diagnostic method
  Future<Map<String, dynamic>> runDiagnostic() async {
    Map<String, dynamic> diagnostic = {
      'healthConnectAvailable': false,
      'runtimePermissions': {},
      'healthConnectPermissions': false,
      'dataAvailable': false,
      'dataPointsFound': 0,
      'dataBreakdown': {},
      'errors': [],
      'success': false,
    };

    try {
      debugPrint('=== HEALTH CONNECT DIAGNOSTIC ===');
      
      // 1. Check Health Connect availability
      debugPrint('1. Checking Health Connect availability...');
      _health = Health();
      await _health!.configure();
      
      // Try to request permissions to check if Health Connect is available
      try {
        bool hasPermissions = await _health!.requestAuthorization(_healthDataTypes);
        diagnostic['healthConnectAvailable'] = true;
        debugPrint('Health Connect available: ${diagnostic['healthConnectAvailable']}');
        
        if (!hasPermissions) {
          diagnostic['errors'].add('Health Connect permissions not granted');
          return diagnostic;
        }
      } catch (e) {
        diagnostic['healthConnectAvailable'] = false;
        diagnostic['errors'].add('Health Connect is not available on this device: $e');
        debugPrint('Health Connect not available: $e');
        return diagnostic;
      }
      
      // 2. Check runtime permissions
      debugPrint('2. Checking runtime permissions...');
      final activityStatus = await Permission.activityRecognition.status;
      final locationStatus = await Permission.location.status;
      final sensorStatus = await Permission.sensors.status;
      
      diagnostic['runtimePermissions'] = {
        'activityRecognition': activityStatus.toString(),
        'location': locationStatus.toString(),
        'bodySensors': sensorStatus.toString(),
      };
      
      final allRuntimePermissionsGranted = activityStatus.isGranted && 
                                         locationStatus.isGranted && 
                                         sensorStatus.isGranted;
      
      debugPrint('All runtime permissions granted: $allRuntimePermissionsGranted');
      
      if (!allRuntimePermissionsGranted) {
        diagnostic['errors'].add('Some runtime permissions are not granted');
        return diagnostic;
      }
      
      // 3. Health Connect permissions already checked above
      debugPrint('3. Health Connect permissions already verified');
      diagnostic['healthConnectPermissions'] = true;
      
      // 4. Check for data across multiple time ranges
      debugPrint('4. Checking for health data across multiple time ranges...');
      final now = DateTime.now();
      final timeRanges = [
        {'name': '24 hours', 'duration': const Duration(hours: 24)},
        {'name': '3 days', 'duration': const Duration(days: 3)},
        {'name': '7 days', 'duration': const Duration(days: 7)},
        {'name': '30 days', 'duration': const Duration(days: 30)},
      ];
      
      List<HealthDataPoint> allHealthData = [];
      
      for (final range in timeRanges) {
        final startTime = now.subtract(range['duration'] as Duration);
        debugPrint('Checking ${range['name']} range: $startTime to $now');
        
        try {
          final healthData = await _health!.getHealthDataFromTypes(
            startTime: startTime,
            endTime: now,
            types: _healthDataTypes,
          );
          
          debugPrint('Found ${healthData.length} data points in ${range['name']} range');
          
          if (healthData.isNotEmpty) {
            allHealthData = healthData;
            diagnostic['dataAvailable'] = true;
            diagnostic['dataPointsFound'] = healthData.length;
            diagnostic['dataFoundInRange'] = range['name'];
            debugPrint('Data found in ${range['name']} range');
            break;
          }
        } catch (e) {
          debugPrint('Error checking ${range['name']} range: $e');
          continue;
        }
      }
      
      if (allHealthData.isNotEmpty) {
        // Group data by type
        final dataByType = <HealthDataType, List<HealthDataPoint>>{};
        for (final data in allHealthData) {
          dataByType.putIfAbsent(data.type, () => []).add(data);
        }
        
        diagnostic['dataBreakdown'] = {};
        for (final entry in dataByType.entries) {
          diagnostic['dataBreakdown'][entry.key.toString()] = entry.value.length;
        }
        
        // Test data processing
        debugPrint('5. Testing data processing...');
        final testResult = <String, dynamic>{};
        _processHealthDataRealTime(allHealthData, testResult);
        diagnostic['processedData'] = testResult;
        debugPrint('Processed data: $testResult');
      } else {
        diagnostic['errors'].add('No health data found in any time range');
      }
      
      diagnostic['success'] = diagnostic['dataAvailable'] && diagnostic['healthConnectAvailable'] && diagnostic['healthConnectPermissions'];
      
      if (diagnostic['success']) {
        debugPrint(' Health Connect integration is working correctly!');
      } else {
        debugPrint(' Health Connect integration has issues');
      }
      
    } catch (e) {
      diagnostic['errors'].add('Error during diagnostic: $e');
      debugPrint(' Error during diagnostic: $e');
    }
    
    debugPrint('=== DIAGNOSTIC COMPLETE ===');
    return diagnostic;
  }
}
