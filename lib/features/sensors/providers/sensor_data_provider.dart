import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/carbon_sensor_service.dart';
import '../services/sensor_activity_detector.dart';

/// Provider for sensor-based carbon emission data
/// Exposes live emission data, detected activity, and sensor status to the UI.
class SensorDataProvider extends ChangeNotifier {
  CarbonSensorService? _sensorService;
  StreamSubscription<SensorEmissionData>? _subscription;

  SensorEmissionData _currentData = SensorEmissionData.initial();
  bool _isInitialized = false;
  bool _hasPermissions = false;
  String? _errorMessage;

  // Getters
  SensorEmissionData get currentData => _currentData;
  bool get isInitialized => _isInitialized;
  bool get hasPermissions => _hasPermissions;
  bool get isSensorActive => _currentData.isSensorActive;
  String? get errorMessage => _errorMessage;

  /// Current detected activity type
  ActivityType get detectedActivity => _currentData.detectedActivity;

  /// Current speed in km/h
  double get currentSpeed => _currentData.currentSpeed;

  /// Total session distance in km
  double get sessionDistance => _currentData.sessionDistance;

  /// Sensor-detected emission for this session (kg CO2)
  double get sessionEmission => _currentData.sessionEmission;

  /// Estimated daily emission including baseline + sensor (kg CO2)
  double get dailyEstimatedEmission => _currentData.dailyEstimatedEmission;

  /// Confidence of activity detection (0.0 - 1.0)
  double get confidence => _currentData.confidence;

  /// Initialize sensor tracking
  Future<void> initialize() async {
    if (_isInitialized && _hasPermissions) return;

    // If re-initializing after permission denial, clean up first
    if (_isInitialized && !_hasPermissions) {
      _subscription?.cancel();
      _sensorService?.dispose();
      _isInitialized = false;
    }

    try {
      _sensorService = CarbonSensorService();
      _hasPermissions = await _sensorService!.initialize();

      // Listen to emission updates
      _subscription = _sensorService!.emissionStream.listen(
        (data) {
          _currentData = data;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Sensor error: $error';
          notifyListeners();
        },
      );

      _isInitialized = true;
      _errorMessage = null;

      // Even without full permissions, we still have baseline data
      _currentData = _sensorService!.currentData;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize sensors: $e';
      // Still provide baseline data
      _currentData = SensorEmissionData.initial();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Pause sensor tracking (e.g., when app goes to background on some platforms)
  void pauseSensors() {
    _sensorService?.pause();
    notifyListeners();
  }

  /// Resume sensor tracking
  void resumeSensors() {
    _sensorService?.resume();
    notifyListeners();
  }

  /// Reset the current session data
  void resetSession() {
    _sensorService?.resetSession();
    notifyListeners();
  }

  /// Get a human-readable status string
  String get statusText {
    if (!_isInitialized) return 'Initializing sensors...';
    if (!_hasPermissions) return 'Baseline Mode \u2022 Using India avg (4.7 kg/day)';
    if (!isSensorActive) return 'Paused \u2022 Tap to resume tracking';

    switch (detectedActivity) {
      case ActivityType.stationary:
        return 'At Rest \u2022 Phone sensors detect no movement';
      case ActivityType.walking:
        return 'Walking \u2022 ${currentSpeed.toStringAsFixed(1)} km/h \u2022 Zero emissions';
      case ActivityType.cycling:
        return 'Cycling \u2022 ${currentSpeed.toStringAsFixed(1)} km/h \u2022 Zero emissions';
      case ActivityType.vehicle:
        return 'In Vehicle \u2022 ${currentSpeed.toStringAsFixed(1)} km/h \u2022 ~0.21 kg/km';
      case ActivityType.train:
        return 'On Train \u2022 ${currentSpeed.toStringAsFixed(1)} km/h \u2022 ~0.04 kg/km';
    }
  }

  /// Get activity icon
  String get activityIcon => detectedActivity.icon;

  @override
  void dispose() {
    _subscription?.cancel();
    _sensorService?.dispose();
    super.dispose();
  }
}
