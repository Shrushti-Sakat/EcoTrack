# Student 2 Quick Reference Guide

## 📋 What Was Implemented

### Module 1: Carbon Calculation Module ✅
**Status:** Enhanced & Improved

**What it does:**
- Calculates CO₂ emissions based on user activities
- Supports multiple activity types (electricity, travel, appliances, fuel, waste)
- Region-specific emission factors (India, USA, UK, EU, Australia, China)
- Real-time calculation as user enters data

**Files:**
- `lib/features/usage_data/models/usage_data_model.dart`
- `lib/features/usage_data/providers/usage_data_provider.dart`
- `lib/core/services/database_service.dart`

**Key Function:**
```dart
double emission = UsageType.carPetrol.baseEmissionFactor * kmTraveled;
// Result: kg CO₂ for that trip
```

---

### Module 2: Remedy Recommendation Module ✨ NEW
**Status:** Fully Implemented

**What it does:**
- Analyzes user's emission patterns
- Generates personalized eco-friendly tips
- Suggests actions with estimated CO₂ savings
- Categorizes by type (transport, electricity, lifestyle, etc.)

**Files:**
- `lib/features/recommendations/models/recommendation_model.dart`
- `lib/features/recommendations/services/recommendation_engine.dart`
- `lib/features/recommendations/providers/recommendations_provider.dart`
- `lib/features/recommendations/screens/recommendations_screen.dart`

**Example Recommendations:**
1. "Switch to Public Transport" - saves 75% CO₂
2. "Use LED Bulbs" - saves 30% electricity
3. "Cycle for short trips" - zero emissions
4. "Reduce AC usage" - saves 35% energy

**How to Use:**
```dart
final recsProvider = context.read<RecommendationsProvider>();

// Generate recommendations
await recsProvider.generateRecommendations(
  emissionsByCategory: usageData.emissionsByCategory,
  totalEmission: usageData.totalEmission,
  recentEntries: usageData.entries,
);

// Access recommendations
List<Recommendation> recs = recsProvider.recommendations;

// Filter by type
recsProvider.filterByType(RecommendationType.transport);

// Calculate impact
Map impact = recsProvider.calculateImpact(recommendation);
print("Save ${impact['savingsPerYear']} kg/year");
```

---

### Module 3: Sensor Data Mapping Logic ✨ NEW
**Status:** Fully Implemented

**What it does:**
- Detects user's activity (walking, cycling, vehicle, train, stationary)
- Uses accelerometer, gyroscope, and GPS data
- Maps activity to suitable emission factor
- Calculates confidence level for each detection

**Files:**
- `lib/features/sensors/services/sensor_activity_detector.dart`

**Detected Activities:**
```
Walking       → 0-7 km/h, high acceleration variance     → 0 kg CO₂/km
Cycling       → 10-30 km/h, medium variance              → 0 kg CO₂/km
Vehicle       → 20-80 km/h, low variance                 → 0.21 kg CO₂/km
Train         → 50-150+ km/h, very low variance          → 0.041 kg CO₂/km
Stationary    → No movement                              → 0 kg CO₂/km
```

**How to Use:**
```dart
final detector = SensorActivityDetector();

// Detect activity
final activity = detector.detectActivity(
  sensorReadings: sensorList,
  currentSpeed: gpsSpeed,
  accelerationVariance: accVar,
  gyroscopeVariance: gyroVar,
  activityId: 'act_123',
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  distance: 5.0,
);

// Get result
print("Activity: ${activity.type.displayName}"); // "Cycling"
print("Speed: ${activity.speed} km/h");          // 25 km/h
print("Confidence: ${activity.confidence}");      // 0.85 (85%)

// Get emission factor
double emission = detector.getEmissionFactorForActivity(activity.type);
// Result: 0 kg CO₂/km for cycling
```

---

## 🎯 How They Work Together

```
User enters activity data
        ↓
Carbon Calculation Module
  ├─> Calculate CO₂ emission
  └─> Store in database
        ↓
Recommendation Engine (when user views Eco Tips)
  ├─> Fetch user's emissions
  ├─> Analyze patterns
  ├─> Generate personalized tips
  └─> Display with potential savings
```

---

## 📱 UI Navigation

**Home Screen:**
```
┌─────────────────────────────────┐
│         EcoTrack Home           │
├─────────────────────────────────┤
│  Profile  Greeting  Quick Stats │
├─────────────────────────────────┤
│       Quick Actions             │
│  ┌──────────┐ ┌──────────────┐  │
│  │   Log    │ │    View      │  │
│  │ Activity │ │   History    │  │
│  └──────────┘ └──────────────┘  │
│  ┌────────────────────────────┐  │
│  │    Eco Tips (NEW!) ✨      │  │
│  │ Get Personalized Tips      │  │
│  └────────────────────────────┘  │
├─────────────────────────────────┤
│  Emissions by Category (Chart)  │
└─────────────────────────────────┘
```

**Clicking Eco Tips opens:**
```
┌──────────────────────────────────┐
│    Eco-Friendly Tips Screen      │
├──────────────────────────────────┤
│  Filter: All | 🚗 | ⚡ | 🌿 | 📱 │
├──────────────────────────────────┤
│  Card 1:                         │
│  🚌 Switch to Public Transport   │
│  Save 75% CO₂ (HIGH PRIORITY)    │
│  └> Tap for details              │
├──────────────────────────────────┤
│  Card 2:                         │
│  💡 Switch to LED Bulbs          │
│  Save 30% electricity (MEDIUM)   │
│  └> Tap for details              │
├──────────────────────────────────┤
│  Card 3:                         │
│  🚲 Cycle Short Distances        │
│  Zero emissions (HIGH PRIORITY)  │
└──────────────────────────────────┘
```

---

## 🔧 Implementation Checklist

### ✅ Recommendation Module
- [x] Model: Recommendation class with all fields
- [x] Engine: ML logic to generate recommendations
- [x] Provider: State management with filtering
- [x] Screen: Beautiful UI with cards
- [x] Integration: Added to main.dart providers
- [x] Navigation: Quick action button in home
- [x] Filtering: By type with chips
- [x] Details: Bottom sheet with impact calculation

### ✅ Sensor Mapping Module
- [x] Model: DetectedActivity class
- [x] Detector: Activity classification logic
- [x] Algorithms: Variance calculation
- [x] Thresholds: Speed + sensor variance
- [x] Confidence: Scoring system
- [x] Emission factors: Per activity type

---

## 📊 Emission Factors Reference

### Transport (by activity type):
```
Walking    → 0.00 kg CO₂/km
Cycling    → 0.00 kg CO₂/km
Motorcycle → 0.10 kg CO₂/km
Car Petrol → 0.21 kg CO₂/km
Car Diesel → 0.27 kg CO₂/km
Bus        → 0.089 kg CO₂/km per person
Train      → 0.041 kg CO₂/km per person
```

### Electricity (by region):
```
India      → 0.82 kg CO₂/kWh
USA        → 0.42 kg CO₂/kWh
UK         → 0.23 kg CO₂/kWh
EU         → 0.28 kg CO₂/kWh
Australia  → 0.79 kg CO₂/kWh
China      → 0.58 kg CO₂/kWh
```

---

## 🚀 How to Test

### Test Recommendations:
1. Open app
2. Log several activities (electricity, travel, appliances)
3. Click "Eco Tips" in Quick Actions
4. View personalized recommendations
5. Tap a card to see details (monthly/yearly impact)
6. Use filter buttons to see only transport tips

### Test Sensor Detection:
```dart
// In test or debug widget:
final readings = [
  SensorDataPoint(
    accelerometerX: 0.1, Y: 0.2, Z: 9.8,
    gyroscopeX: 0.01, Y: 0.01, Z: 0.01,
    timestamp: DateTime.now(),
  ),
  // More readings...
];

final activity = SensorActivityDetector.detectActivity(
  sensorReadings: readings,
  currentSpeed: 15.0,  // 15 km/h
  accelerationVariance: 1.2,
  gyroscopeVariance: 0.3,
  // ... other params
);

print(activity.type);      // Should be "cycling"
print(activity.confidence); // Should be high (0.8+)
```

---

## 💡 Key Metrics

### Recommendation Impact:
- **High Priority:** >20% emission reduction
- **Medium Priority:** 10-20% reduction
- **Low Priority:** <10% reduction

### Sensor Confidence:
- **High Confidence:** 0.8-1.0 (good detection)
- **Medium Confidence:** 0.6-0.8 (okay detection)
- **Low Confidence:** 0.4-0.6 (needs refinement)

---

## 📝 Notes

1. **Recommendations are generated on-demand** when user opens Eco Tips screen
2. **No background processing** currently - detect activities when needed
3. **All calculations happen locally** (offline-first)
4. **Emission factors are from real data** (EPA, IEA sources)
5. **Previous implementations are untouched** - all backward compatible

---

## 🔗 Related Files Updated

- `lib/main.dart` - Added RecommendationsProvider
- `lib/features/home/screens/home_screen.dart` - Added Eco Tips button

---

**Total Implementation:** ~1500 lines of code across 4 new files + integrations
