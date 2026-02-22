/// Sensor Activity Detection Service
/// Maps raw sensor data (accelerometer, gyroscope, GPS) to detected activities
class DetectedActivity {
  final String id;
  final ActivityType type;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // in km
  final double speed; // in km/h
  final double confidence; // 0.0 to 1.0
  final Map<String, dynamic> sensorData;

  DetectedActivity({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.speed,
    required this.confidence,
    required this.sensorData,
  });

  Duration get duration => endTime.difference(startTime);

  @override
  String toString() {
    return 'DetectedActivity(type: ${type.name}, speed: ${speed.toStringAsFixed(1)} km/h, distance: ${distance.toStringAsFixed(2)} km)';
  }
}

/// Activity Types detected from sensor data
enum ActivityType {
  walking,       // 0-7 km/h, high variance
  cycling,       // 10-30 km/h, medium variance
  vehicle,       // 20-80 km/h, low variance
  train,         // 50-150 km/h, very low variance
  stationary;    // No movement, screen on or off

  String get displayName {
    switch (this) {
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.vehicle:
        return 'Vehicle';
      case ActivityType.train:
        return 'Train';
      case ActivityType.stationary:
        return 'At Rest';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.walking:
        return '🚶';
      case ActivityType.cycling:
        return '🚲';
      case ActivityType.vehicle:
        return '🚗';
      case ActivityType.train:
        return '🚂';
      case ActivityType.stationary:
        return '📍';
    }
  }
}

/// Sensor Data Point
class SensorDataPoint {
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;
  final double? gyroscopeX;
  final double? gyroscopeY;
  final double? gyroscopeZ;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  SensorDataPoint({
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    this.gyroscopeX,
    this.gyroscopeY,
    this.gyroscopeZ,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });
}

/// Sensor Activity Detection Engine
class SensorActivityDetector {
  // Constants for activity detection thresholds
  static const double _walkingSpeedMax = 7.0; // km/h
  static const double _cyclingSpeedMin = 10.0; // km/h
  static const double _cyclingSpeedMax = 30.0; // km/h
  static const double _vehicleSpeedMin = 20.0; // km/h
  static const double _vehicleSpeedMax = 80.0; // km/h
  static const double _trainSpeedMin = 50.0; // km/h

  // Acceleration variance thresholds (on squared magnitude of accel vector)
  // Walking causes phone to bounce, producing variance in the 5-500+ range
  // depending on gait and phone position. Threshold set low to catch gentle walking.
  static const double _walkingVarianceThreshold = 0.5; // Walking (accelerometer-based)
  static const double _highVarianceThreshold = 2.0; // Strong walking signal
  static const double _mediumVarianceThreshold = 1.5; // Cycling
  static const double _lowVarianceThreshold = 0.8; // Vehicle
  static const double _veryLowVarianceThreshold = 0.4; // Train

  /// Detect activity from sensor data and GPS
  static DetectedActivity detectActivity({
    required List<SensorDataPoint> sensorReadings,
    required double currentSpeed, // km/h from GPS
    required double accelerationVariance,
    required double gyroscopeVariance,
    required String activityId,
    required DateTime startTime,
    required DateTime endTime,
    required double distance,
  }) {
    final confidence = _calculateConfidence(
      speed: currentSpeed,
      accelerationVariance: accelerationVariance,
      gyroscopeVariance: gyroscopeVariance,
    );

    final activityType = _classifyActivity(
      speed: currentSpeed,
      accelerationVariance: accelerationVariance,
      gyroscopeVariance: gyroscopeVariance,
    );

    return DetectedActivity(
      id: activityId,
      type: activityType,
      startTime: startTime,
      endTime: endTime,
      distance: distance,
      speed: currentSpeed,
      confidence: confidence,
      sensorData: {
        'accelerationVariance': accelerationVariance,
        'gyroscopeVariance': gyroscopeVariance,
        'readingCount': sensorReadings.length,
      },
    );
  }

  /// Classify activity based on sensor data and GPS
  static ActivityType _classifyActivity({
    required double speed,
    required double accelerationVariance,
    required double gyroscopeVariance,
  }) {
    // Check for train activity (high speed, very low variance)
    if (speed >= _trainSpeedMin && gyroscopeVariance < _veryLowVarianceThreshold) {
      return ActivityType.train;
    }

    // Check for vehicle activity (medium to high speed, low variance)
    if (speed >= _vehicleSpeedMin &&
        speed <= _vehicleSpeedMax &&
        gyroscopeVariance < _lowVarianceThreshold) {
      return ActivityType.vehicle;
    }

    // Check for cycling activity
    if (speed >= _cyclingSpeedMin &&
        speed <= _cyclingSpeedMax &&
        accelerationVariance >= _mediumVarianceThreshold &&
        accelerationVariance < _highVarianceThreshold) {
      return ActivityType.cycling;
    }

    // Check for walking activity — use accelerometer variance as primary
    // indicator since GPS speed is unreliable at walking speeds.
    // Accelerometer variance > threshold means the phone is bouncing/moving
    // in a pattern consistent with walking, even if GPS reports speed ~0.
    if (accelerationVariance >= _walkingVarianceThreshold) {
      // High accel variance = definitely moving on foot
      if (speed < _walkingSpeedMax || speed < 0.5) {
        return ActivityType.walking;
      }
    }

    // Also detect walking from GPS speed alone (when accel is borderline)
    if (speed >= 0.5 && speed < _walkingSpeedMax) {
      return ActivityType.walking;
    }

    // Default based on speed for higher speeds
    if (speed > _vehicleSpeedMin) {
      return ActivityType.vehicle;
    } else if (speed > _cyclingSpeedMin) {
      return ActivityType.cycling;
    }

    return ActivityType.stationary;
  }

  /// Calculate detection confidence (0.0 to 1.0)
  static double _calculateConfidence({
    required double speed,
    required double accelerationVariance,
    required double gyroscopeVariance,
  }) {
    double confidence = 0.5; // Base confidence

    // Adjust based on speed consistency
    if (speed > 0 && speed < _walkingSpeedMax) {
      confidence += 0.15;
    } else if (speed >= _walkingSpeedMax && speed < _cyclingSpeedMax) {
      confidence += 0.20;
    } else if (speed >= _cyclingSpeedMax && speed < _vehicleSpeedMax) {
      confidence += 0.25;
    } else if (speed >= _vehicleSpeedMax) {
      confidence += 0.20;
    }

    // Adjust based on variance consistency
    if (accelerationVariance < _veryLowVarianceThreshold) {
      confidence += 0.10;
    } else if (accelerationVariance < _lowVarianceThreshold) {
      confidence += 0.08;
    } else if (accelerationVariance < _mediumVarianceThreshold) {
      confidence += 0.05;
    }

    return (confidence).clamp(0.0, 1.0);
  }

  /// Get emission factor for detected activity
  static double getEmissionFactorForActivity(ActivityType activity) {
    switch (activity) {
      case ActivityType.walking:
        return 0.0; // Zero emissions
      case ActivityType.cycling:
        return 0.0; // Zero emissions
      case ActivityType.vehicle:
        return 0.21; // kg CO2 per km (average car)
      case ActivityType.train:
        return 0.041; // kg CO2 per km per passenger
      case ActivityType.stationary:
        return 0.0; // No movement, but digital usage possible
    }
  }

  /// Calculate accelerometer variance
  static double calculateAccelerometerVariance(
      List<SensorDataPoint> readings) {
    if (readings.length < 2) return 0.0;

    final accelerations = readings.map((r) {
      return (r.accelerometerX * r.accelerometerX +
              r.accelerometerY * r.accelerometerY +
              r.accelerometerZ * r.accelerometerZ)
          .toDouble();
    }).toList();

    final mean = accelerations.reduce((a, b) => a + b) / accelerations.length;
    final variance = accelerations
        .fold<double>(0.0, (sum, val) => sum + (val - mean) * (val - mean)) /
        accelerations.length;

    return variance.toDouble();
  }

  /// Calculate gyroscope variance
  static double calculateGyroscopeVariance(List<SensorDataPoint> readings) {
    if (readings.length < 2) return 0.0;

    final gyroReadings = readings
        .where((r) => r.gyroscopeX != null && r.gyroscopeY != null)
        .toList();

    if (gyroReadings.isEmpty) return 0.0;

    final rotations = gyroReadings.map((r) {
      return (r.gyroscopeX! * r.gyroscopeX! +
              r.gyroscopeY! * r.gyroscopeY! +
              r.gyroscopeZ! * r.gyroscopeZ!)
          .toDouble();
    }).toList();

    if (rotations.isEmpty) return 0.0;

    final mean = rotations.reduce((a, b) => a + b) / rotations.length;
    final variance =
        rotations.fold<double>(0.0, (sum, val) => sum + (val - mean) * (val - mean)) /
            rotations.length;

    return variance.toDouble();
  }

  /// Smooth activity detection with confidence filtering
  static ActivityType smoothActivityDetection(
    List<DetectedActivity> recentActivities, {
    double confidenceThreshold = 0.6,
  }) {
    if (recentActivities.isEmpty) {
      return ActivityType.stationary;
    }

    // Filter by confidence
    final highConfidenceActivities = recentActivities
        .where((activity) => activity.confidence >= confidenceThreshold)
        .toList();

    if (highConfidenceActivities.isEmpty) {
      return recentActivities.last.type;
    }

    // Most common activity type
    final activityCounts = <ActivityType, int>{};
    for (final activity in highConfidenceActivities) {
      activityCounts[activity.type] = (activityCounts[activity.type] ?? 0) + 1;
    }

    return activityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
