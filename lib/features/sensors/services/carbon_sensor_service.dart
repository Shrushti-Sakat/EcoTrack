import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:permission_handler/permission_handler.dart';
import 'sensor_activity_detector.dart';

/// Data class for live sensor emission readings
class SensorEmissionData {
  final ActivityType detectedActivity;
  final double currentSpeed; // km/h
  final double sessionDistance; // km
  final double sessionEmission; // kg CO2
  final double dailyEstimatedEmission; // kg CO2 (baseline + sensor)
  final double confidence;
  final bool isSensorActive;
  final DateTime timestamp;

  SensorEmissionData({
    required this.detectedActivity,
    required this.currentSpeed,
    required this.sessionDistance,
    required this.sessionEmission,
    required this.dailyEstimatedEmission,
    required this.confidence,
    required this.isSensorActive,
    required this.timestamp,
  });

  factory SensorEmissionData.initial() {
    return SensorEmissionData(
      detectedActivity: ActivityType.stationary,
      currentSpeed: 0,
      sessionDistance: 0,
      sessionEmission: 0,
      dailyEstimatedEmission: _calculateDailyBaseline(),
      confidence: 0,
      isSensorActive: false,
      timestamp: DateTime.now(),
    );
  }

  /// Estimated daily baseline emissions from typical household activities
  /// Average Indian household: ~4.7 kg CO2/person/day
  static double _calculateDailyBaseline() {
    final hour = DateTime.now().hour;
    // Scale baseline proportionally through the day
    // So at 6am you see ~1.2kg, at noon ~2.4kg, at 6pm ~3.5kg, etc.
    final hourFraction = hour / 24.0;
    const fullDayBaseline = 4.7; // kg CO2 per person per day

    // Weighted distribution: more emissions during day hours
    double cumulativeFraction;
    if (hour < 6) {
      cumulativeFraction = hourFraction * 0.5; // Low overnight
    } else if (hour < 12) {
      cumulativeFraction = 0.125 + (hour - 6) / 6.0 * 0.3; // Morning ramp-up
    } else if (hour < 18) {
      cumulativeFraction = 0.425 + (hour - 12) / 6.0 * 0.35; // Afternoon peak
    } else {
      cumulativeFraction = 0.775 + (hour - 18) / 6.0 * 0.225; // Evening wind-down
    }

    return fullDayBaseline * cumulativeFraction;
  }
}

/// Carbon Sensor Service — uses device sensors to detect travel and estimate emissions
/// Works fully offline on Android. Uses accelerometer + GPS.
class CarbonSensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _updateTimer;
  Timer? _baselineTimer;

  // State
  final List<SensorDataPoint> _recentReadings = [];
  final List<DetectedActivity> _detectedActivities = [];
  Position? _lastPosition;
  DateTime? _sessionStartTime;
  double _sessionDistance = 0;
  double _sessionEmission = 0;
  double _currentSpeed = 0;
  ActivityType _currentActivity = ActivityType.stationary;
  double _currentConfidence = 0;
  bool _isActive = false;
  bool _permissionsGranted = false;

  // Stream controller for emitting data
  final _emissionController = StreamController<SensorEmissionData>.broadcast();
  Stream<SensorEmissionData> get emissionStream => _emissionController.stream;

  /// Get the latest snapshot
  SensorEmissionData get currentData => SensorEmissionData(
        detectedActivity: _currentActivity,
        currentSpeed: _currentSpeed,
        sessionDistance: _sessionDistance,
        sessionEmission: _sessionEmission,
        dailyEstimatedEmission:
            SensorEmissionData._calculateDailyBaseline() + _sessionEmission,
        confidence: _currentConfidence,
        isSensorActive: _isActive,
        timestamp: DateTime.now(),
      );

  /// Initialize and start listening to sensors
  Future<bool> initialize() async {
    _permissionsGranted = await _requestPermissions();
    if (!_permissionsGranted) {
      // Still provide baseline data even without sensor permissions
      _isActive = false;
      _startBaselineTimer();
      _emitUpdate();
      return false;
    }

    _sessionStartTime = DateTime.now();
    _isActive = true;

    // Start accelerometer listening
    _startAccelerometer();

    // Start GPS listening
    await _startGPS();

    // Periodic activity classification (every 5 seconds)
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _classifyAndUpdate();
    });

    // Periodic baseline recalculation (every 60 seconds)
    _startBaselineTimer();

    // Emit initial data
    _emitUpdate();
    return true;
  }

  /// Start timer to recalculate baseline every 60 seconds
  void _startBaselineTimer() {
    _baselineTimer?.cancel();
    _baselineTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _emitUpdate(); // This recalculates baseline via currentData getter
    });
  }

  /// Request necessary permissions
  Future<bool> _requestPermissions() async {
    try {
      // Check location permission
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) {
          return false;
        }
      }

      // Check activity recognition permission
      var activityStatus = await Permission.activityRecognition.status;
      if (!activityStatus.isGranted) {
        activityStatus = await Permission.activityRecognition.request();
        // Not critical — we can work without it
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start accelerometer sensor
  void _startAccelerometer() {
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 500),
      ).listen(
        (AccelerometerEvent event) {
          _recentReadings.add(SensorDataPoint(
            accelerometerX: event.x,
            accelerometerY: event.y,
            accelerometerZ: event.z,
            timestamp: DateTime.now(),
          ));

          // Keep only last 60 readings (30 seconds at 2Hz)
          if (_recentReadings.length > 60) {
            _recentReadings.removeRange(0, _recentReadings.length - 60);
          }
        },
        onError: (error) {
          // Accelerometer not available — continue with GPS only
        },
      );
    } catch (e) {
      // Sensor not available
    }
  }

  /// Start GPS tracking
  Future<void> _startGPS() async {
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Update frequently for walking detection
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (_lastPosition != null) {
            // Calculate distance from last position
            final distance = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            _sessionDistance += distance / 1000.0; // Convert meters to km
          }

          _currentSpeed = position.speed * 3.6; // m/s to km/h
          if (_currentSpeed < 0) _currentSpeed = 0;

          _lastPosition = position;

          // Update readings with GPS data
          if (_recentReadings.isNotEmpty) {
            final lastReading = _recentReadings.last;
            _recentReadings[_recentReadings.length - 1] = SensorDataPoint(
              accelerometerX: lastReading.accelerometerX,
              accelerometerY: lastReading.accelerometerY,
              accelerometerZ: lastReading.accelerometerZ,
              latitude: position.latitude,
              longitude: position.longitude,
              timestamp: lastReading.timestamp,
            );
          }
        },
        onError: (error) {
          // GPS error — continue with accelerometer only
        },
      );
    } catch (e) {
      // Location service not available
    }
  }

  /// Classify current activity and compute emissions
  void _classifyAndUpdate() {
    if (_recentReadings.length < 4) {
      _emitUpdate();
      return;
    }

    // Calculate variances
    final accelVariance =
        SensorActivityDetector.calculateAccelerometerVariance(_recentReadings);
    final gyroVariance =
        SensorActivityDetector.calculateGyroscopeVariance(_recentReadings);

    // Detect activity
    final now = DateTime.now();
    final detected = SensorActivityDetector.detectActivity(
      sensorReadings: _recentReadings,
      currentSpeed: _currentSpeed,
      accelerationVariance: accelVariance,
      gyroscopeVariance: gyroVariance,
      activityId: 'live_${now.millisecondsSinceEpoch}',
      startTime: now.subtract(const Duration(seconds: 5)),
      endTime: now,
      distance: _sessionDistance,
    );

    _detectedActivities.add(detected);
    if (_detectedActivities.length > 20) {
      _detectedActivities.removeRange(0, _detectedActivities.length - 20);
    }

    // Smooth activity detection
    _currentActivity = SensorActivityDetector.smoothActivityDetection(
      _detectedActivities,
      confidenceThreshold: 0.5,
    );
    _currentConfidence = detected.confidence;

    // Calculate emission from the last 5-second interval
    final emissionFactor =
        SensorActivityDetector.getEmissionFactorForActivity(_currentActivity);
    final intervalDistanceKm = _currentSpeed * (5.0 / 3600.0); // 5 seconds
    _sessionEmission += emissionFactor * intervalDistanceKm;

    _emitUpdate();
  }

  /// Emit current data to listeners
  void _emitUpdate() {
    if (!_emissionController.isClosed) {
      _emissionController.add(currentData);
    }
  }

  /// Stop all sensors
  void dispose() {
    _accelerometerSubscription?.cancel();
    _positionSubscription?.cancel();
    _updateTimer?.cancel();
    _baselineTimer?.cancel();
    _emissionController.close();
    _isActive = false;
  }

  /// Pause sensor tracking
  void pause() {
    _accelerometerSubscription?.pause();
    _positionSubscription?.pause();
    _updateTimer?.cancel();
    _isActive = false;
    _emitUpdate();
  }

  /// Resume sensor tracking
  void resume() {
    _accelerometerSubscription?.resume();
    _positionSubscription?.resume();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _classifyAndUpdate();
    });
    _isActive = true;
    _emitUpdate();
  }

  /// Reset session data
  void resetSession() {
    _sessionDistance = 0;
    _sessionEmission = 0;
    _recentReadings.clear();
    _detectedActivities.clear();
    _lastPosition = null;
    _sessionStartTime = DateTime.now();
    _emitUpdate();
  }
}
