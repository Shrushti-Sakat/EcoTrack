# Student 2 Implementation Summary

## Overview
This document outlines the complete implementation of **Student 2's modules** for the EcoTrack carbon footprint application.

---

## ✅ Module 1: Carbon Calculation Module

### Status: **FULLY IMPLEMENTED** (Enhanced)

**Location:**
- [lib/features/usage_data/models/usage_data_model.dart](lib/features/usage_data/models/usage_data_model.dart)
- [lib/features/usage_data/providers/usage_data_provider.dart](lib/features/usage_data/providers/usage_data_provider.dart)
- [lib/core/services/database_service.dart](lib/core/services/database_service.dart)

**Features:**
- ✅ Comprehensive emission factors for multiple categories:
  - Electricity (kW/h)
  - Travel (petrol, diesel, electric, motorcycle, bus, train, auto-rickshaw, bicycle, walking)
  - Appliances (AC, heater, washing machine, refrigerator, TV, computer)
  - Fuel (petrol, diesel, LPG, CNG)
  - Waste (general, recyclable, organic)

- ✅ Region-specific emission calculations:
  - India (0.82 kg CO₂/kWh)
  - USA (0.42 kg CO₂/kWh)
  - UK (0.23 kg CO₂/kWh)
  - EU (0.28 kg CO₂/kWh)
  - Australia (0.79 kg CO₂/kWh)
  - China (0.58 kg CO₂/kWh)

- ✅ Real-time CO₂ emission calculation
- ✅ Daily, weekly, and total emission tracking
- ✅ Category-wise emission breakdown

---

## ✅ Module 2: Remedy Recommendation Module

### Status: **NEWLY IMPLEMENTED** ✨

**Location:**
- [lib/features/recommendations/models/recommendation_model.dart](lib/features/recommendations/models/recommendation_model.dart)
- [lib/features/recommendations/services/recommendation_engine.dart](lib/features/recommendations/services/recommendation_engine.dart)
- [lib/features/recommendations/providers/recommendations_provider.dart](lib/features/recommendations/providers/recommendations_provider.dart)
- [lib/features/recommendations/screens/recommendations_screen.dart](lib/features/recommendations/screens/recommendations_screen.dart)

**Key Classes:**

### 1. **Recommendation Model** (`recommendation_model.dart`)
```dart
class Recommendation {
  final String id;
  final String title;
  final String description;
  final String icon;
  final RecommendationType type;
  final double potentialCO2Savings; // kg CO2 savings
  final String category;
  final int priority; // 1 (high), 2 (medium), 3 (low)
}

enum RecommendationType {
  transport, electricity, lifestyle, technology, appliances, waste
}
```

### 2. **Recommendation Engine** (`recommendation_engine.dart`)
Intelligent engine that generates personalized recommendations based on user's emission patterns:

**Transportation Recommendations:**
- "Switch to Public Transport" - Saves up to 75% emissions
- "Try Cycling for Short Distances" - Zero emissions
- "Carpool or Use Ride-Sharing" - Saves 40% per person
- "Consider an Electric Vehicle" - 60% reduction

**Electricity Recommendations:**
- "Switch to LED Bulbs" - 30% energy savings
- "Use Smart Power Strips" - 15% reduction
- "Install Solar Panels" - Up to 80% reduction
- "Use Energy-Efficient Appliances" - 25% savings

**Appliance Recommendations:**
- "Reduce Air Conditioning Usage" - 35% savings
- "Optimize Refrigerator Settings" - 15% savings
- "Use Cold Water for Laundry" - 40% savings

**Waste Recommendations:**
- "Increase Recycling" - 60% reduction
- "Reduce Single-Use Plastics" - 40% reduction
- "Compost Organic Waste" - 50% reduction

**Engine Methods:**
```dart
// Generate recommendations based on emission data
generateRecommendations({
  emissionsByCategory,
  totalEmission,
  recentEntries
})

// Filter by type, calculate savings, sort by priority
filterByType(recommendations, type)
calculateTotalPotentialSavings(recommendations)
getTopRecommendations(recommendations, limit)
```

### 3. **Recommendations Provider** (`recommendations_provider.dart`)
State management for recommendations using Provider pattern:

```dart
class RecommendationsProvider extends ChangeNotifier {
  // Generate recommendations
  generateRecommendations({...})
  
  // Filter & sort
  filterByType(type)
  getByPriority()
  getByPotentialSavings()
  
  // Calculate impact
  calculateImpact(recommendation) // Monthly, yearly, trees equivalent
  
  // User interaction
  dismissRecommendation(id)
}
```

### 4. **Recommendations Screen** (`recommendations_screen.dart`)
Beautiful UI for displaying recommendations:

**Features:**
- ✅ Filter by recommendation type (Transport, Electricity, Lifestyle, etc.)
- ✅ Cards displaying:
  - Icon, title, description
  - Potential CO₂ savings
  - Priority level (High/Medium/Low)
  - Progress bar showing impact
- ✅ Bottom sheet details view with:
  - Full description
  - Monthly & yearly savings
  - Tree equivalent (how many trees needed to absorb CO₂)
- ✅ Empty state when no recommendations

**UI Integration:**
- Added "Eco Tips" button in Quick Actions on Home Screen
- Accessible from home screen dashboard

---

## ✅ Module 3: Sensor Data Mapping Logic

### Status: **NEWLY IMPLEMENTED** ✨

**Location:**
- [lib/features/sensors/services/sensor_activity_detector.dart](lib/features/sensors/services/sensor_activity_detector.dart)

**Key Classes:**

### 1. **DetectedActivity Model**
```dart
class DetectedActivity {
  final ActivityType type;
  final DateTime startTime, endTime;
  final double distance; // km
  final double speed; // km/h
  final double confidence; // 0 to 1
  final Map<String, dynamic> sensorData;
}
```

### 2. **Activity Types**
```dart
enum ActivityType {
  walking,    // 0-7 km/h
  cycling,    // 10-30 km/h
  vehicle,    // 20-80 km/h
  train,      // 50-150+ km/h
  stationary  // No movement
}
```

### 3. **Sensor Data Point**
```dart
class SensorDataPoint {
  final double accelerometerX, Y, Z;
  final double? gyroscopeX, Y, Z;
  final double? latitude, longitude;
  final DateTime timestamp;
}
```

### 4. **Sensor Activity Detector Engine**

**Core Detection Algorithm:**

The engine uses **sensor variance and GPS speed** to classify activities:

```
Activity Detection Logic:
├── Speed < 0.5 km/h
│   └─> STATIONARY
├── Speed >= 50 km/h + Very Low Gyro Variance
│   └─> TRAIN (0.041 kg CO₂/km)
├── Speed 20-80 km/h + Low Gyro Variance
│   └─> VEHICLE (0.21 kg CO₂/km)
├── Speed 10-30 km/h + Medium Accel Variance
│   └─> CYCLING (0 kg CO₂/km)
└── Speed < 7 km/h + High Accel Variance
    └─> WALKING (0 kg CO₂/km)
```

**Sensor Variance Thresholds:**
- Walking: High acceleration variance (>2.0)
- Cycling: Medium variance (1.5-2.0)
- Vehicle: Low variance (<0.8)
- Train: Very low variance (<0.4)

**Key Methods:**

```dart
// Main detection method
detectActivity({
  sensorReadings,
  currentSpeed,
  accelerationVariance,
  gyroscopeVariance,
  ...
}) -> DetectedActivity

// Calculate variance
calculateAccelerometerVariance(readings) -> double
calculateGyroscopeVariance(readings) -> double

// Get emission factor for activity
getEmissionFactorForActivity(type) -> double

// Smooth detection (filters low confidence activities)
smoothActivityDetection(recentActivities, confidenceThreshold)
```

**Confidence Calculation:**
- Base: 0.5
- Speed match: +0.15-0.25
- Variance consistency: +0.05-0.10
- Final: 0.0-1.0 range

---

## Integration Points

### 1. **Main App Setup** (`lib/main.dart`)
```dart
// Added RecommendationsProvider to MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProfileProvider()),
    ChangeNotifierProvider(create: (_) => UsageDataProvider()),
    ChangeNotifierProvider(create: (_) => RecommendationsProvider()), // NEW
  ],
  ...
)
```

### 2. **Home Screen Integration** (`lib/features/home/screens/home_screen.dart`)
```dart
// Added in Quick Actions section:
- Log Activity (existing)
- View History (existing)
- Eco Tips (NEW) -> Recommendations Screen
```

**Quick Action Flow:**
```
Home Screen
└─> Quick Actions
    ├─> Log Activity -> UsageDataEntryScreen
    ├─> View History -> UsageHistoryScreen
    └─> Eco Tips -> RecommendationsScreen (NEW)
```

---

## Data Flow Diagrams

### Recommendation Generation Flow:
```
Home Screen
    ↓
UsageDataProvider (active emissions data)
    ↓
RecommendationsProvider.generateRecommendations()
    ↓
RecommendationEngine.generateRecommendations()
    ├─> Analyze emissions by category
    ├─> Generate category-specific recommendations
    ├─> Sort by priority & potential savings
    └─> Return top 5 recommendations
    ↓
RecommendationsScreen (displays with filters)
```

### Sensor Activity Detection Flow:
```
Sensors (Accelerometer, Gyroscope, GPS)
    ↓
SensorDataPoint collection
    ↓
SensorActivityDetector.detectActivity()
    ├─> Calculate accelerometer variance
    ├─> Calculate gyroscope variance
    ├─> Compare with GPS speed
    └─> Classify activity type & calculate confidence
    ↓
DetectedActivity (with emission factor)
    ↓
UsageDataProvider (stores and aggregates)
```

---

## Features Summary

### Recommendation Engine Features:
✅ Personalized recommendations based on user's top emission categories
✅ Priority-based sorting (high/medium/low impact)
✅ Potential CO₂ savings calculation
✅ Impact calculation (daily, monthly, yearly, tree equivalent)
✅ Type filtering (transport, electricity, lifestyle, etc.)
✅ Dismissable recommendations
✅ Empty state handling

### Sensor Detection Features:
✅ 5-activity classification (walking, cycling, vehicle, train, stationary)
✅ Speed-based detection (0-150+ km/h range)
✅ Variance-based smoothing
✅ Confidence scoring (0-1.0)
✅ GPS integration
✅ Emission factor assignment per activity
✅ Duration and distance tracking

---

## Dependencies Used
- `provider`: State management (already in pubspec.yaml)
- `uuid`: Generating unique IDs for recommendations
- `sensors_plus`: Sensor data access
- `geolocator`: GPS location and speed

---

## Testing Recommendations

### Unit Tests for RecommendationEngine:
```dart
- Test recommendation generation with high electricity usage
- Test filtering by type
- Test saving calculations
- Test priority sorting
```

### Unit Tests for SensorActivityDetector:
```dart
- Test walking detection (low speed, high variance)
- Test vehicle detection (medium speed, low variance)
- Test train detection (high speed, very low variance)
- Test confidence calculation
- Test variance calculations
```

### Integration Tests:
```dart
- Generate recommendations and display on screen
- Filter recommendations by type
- Navigate from home to recommendations screen
- Auto-detect activities from sensor data
```

---

## Future Enhancements

### Recommendations:
- Machine learning model to predict user behavior
- Personalization based on user location/lifestyle
- A/B testing to identify most effective recommendations
- Recommendation tracking (which ones user follows)
- Social sharing of eco-achievements

### Sensor Detection:
- Hybrid activity detection (multiple sensors weighted)
- Background activity detection service
- Real-time activity log creation
- Deep learning model for activity classification
- Battery/Light/Network sensor integration

---

## Notes
- All modules are modular and can be extended
- Color scheme uses AppColors.success (green) for eco-friendly theme
- Recommendations generated on-demand in RecommendationsScreen
- Sensor detection ready to integrate with background service
- Code follows Flutter best practices and clean architecture

