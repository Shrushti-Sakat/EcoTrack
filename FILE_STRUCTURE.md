# File Structure - Student 2 Implementation

## New Files Created

```
EcoTrack-main/
│
├── lib/
│   ├── features/
│   │   │
│   │   ├── recommendations/ (NEW FEATURE)
│   │   │   ├── models/
│   │   │   │   └── recommendation_model.dart (313 lines)
│   │   │   │       - Recommendation class
│   │   │   │       - RecommendationType enum
│   │   │   │       - RecommendationCategory class
│   │   │   │
│   │   │   ├── services/
│   │   │   │   └── recommendation_engine.dart (567 lines)
│   │   │   │       - RecommendationEngine (static methods)
│   │   │   │       - Transport recommendations
│   │   │   │       - Electricity recommendations
│   │   │   │       - Appliance recommendations
│   │   │   │       - Fuel recommendations
│   │   │   │       - Waste recommendations
│   │   │   │
│   │   │   ├── providers/
│   │   │   │   └── recommendations_provider.dart (143 lines)
│   │   │   │       - RecommendationsProvider (ChangeNotifier)
│   │   │   │       - State management for recommendations
│   │   │   │       - Filtering, sorting, impact calculation
│   │   │   │
│   │   │   └── screens/
│   │   │       └── recommendations_screen.dart (466 lines)
│   │   │           - RecommendationsScreen (StatefulWidget)
│   │   │           - UI for displaying recommendations
│   │   │           - Filtering by type
│   │   │           - Details modal with impact info
│   │   │
│   │   ├── sensors/ (NEW FEATURE)
│   │   │   └── services/
│   │   │       └── sensor_activity_detector.dart (412 lines)
│   │   │           - DetectedActivity class
│   │   │           - ActivityType enum
│   │   │           - SensorDataPoint class
│   │   │           - SensorActivityDetector (static methods)
│   │   │           - Activity detection algorithms
│   │   │           - Variance calculations
│   │   │           - Confidence scoring
│   │   │
│   │   └── home/
│   │       └── screens/
│   │           └── home_screen.dart (MODIFIED)
│   │               - Added import for RecommendationsScreen
│   │               - Added Eco Tips quick action
│   │               - Added _navigateToRecommendations() method
│   │
│   └── main.dart (MODIFIED)
│       - Added import for RecommendationsProvider
│       - Added RecommendationsProvider to MultiProvider
│
├── STUDENT_2_IMPLEMENTATION.md (NEW)
│   └── Comprehensive documentation
│
└── STUDENT_2_QUICK_START.md (NEW)
    └── Quick reference guide
```

---

## File Line Counts

| File | Purpose | Lines |
|------|---------|-------|
| recommendation_model.dart | Data models | 61 |
| recommendation_engine.dart | Logic engine | 567 |
| recommendations_provider.dart | State management | 143 |
| recommendations_screen.dart | UI | 466 |
| sensor_activity_detector.dart | Sensor logic | 412 |
| **TOTAL NEW CODE** | | **1,649 lines** |
| home_screen.dart | Modified | +8 lines |
| main.dart | Modified | +2 lines |

---

## Imports Structure

### Recommendation Module Imports:
```dart
// recommendation_model.dart
import 'package:uuid/uuid.dart';

// recommendation_engine.dart
import 'package:uuid/uuid.dart';
import '../models/recommendation_model.dart';
import '../../usage_data/models/usage_data_model.dart';

// recommendations_provider.dart
import 'package:flutter/foundation.dart';
import '../models/recommendation_model.dart';
import '../services/recommendation_engine.dart';
import '../../usage_data/models/usage_data_model.dart';

// recommendations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/recommendation_model.dart';
import '../providers/recommendations_provider.dart';
import '../../usage_data/providers/usage_data_provider.dart';
import '../../user_profile/providers/user_profile_provider.dart';
```

### Sensor Module Imports:
```dart
// sensor_activity_detector.dart
// No external dependencies - pure Dart implementation
```

---

## Integration Points

### 1. **main.dart Changes:**
```dart
// Line 6: Added import
import 'features/recommendations/providers/recommendations_provider.dart';

// Lines 40-42: Added provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProfileProvider()),
    ChangeNotifierProvider(create: (_) => UsageDataProvider()),
    ChangeNotifierProvider(create: (_) => RecommendationsProvider()), // NEW
  ],
  ...
)
```

### 2. **home_screen.dart Changes:**
```dart
// Line 11: Added import
import '../../recommendations/screens/recommendations_screen.dart';

// Lines 328-362: Modified _buildQuickActions()
// Added third action card for Eco Tips

// Lines 748-758: Added method
void _navigateToRecommendations() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const RecommendationsScreen(),
    ),
  );
}
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Home Screen                              │
│                                                             │
│  [Quick Actions]                                           │
│  ┌──────────────┬──────────────┬─────────────────────────┐ │
│  │   Log Acc    │  History     │  Eco Tips (NEW) ✨     │ │
│  │   (Existing) │  (Existing)  │  -> RecommendScreen   │ │
│  └──────────────┴──────────────┴─────────────────────────┘ │
└────────┬──────────────────────────────────────────────────────┘
         │
         │ Tap "Eco Tips"
         ↓
┌─────────────────────────────────────────────────────────────┐
│        Recommendations Screen (NEW) ✨                      │
│                                                             │
│  [Filter: All | 🚗 | ⚡ | 🌿 | 📱 | 🏠 | ♻️]              │
│                                                             │
│  RecommendationsProvider                                  │
│  │                                                         │
│  ├─> generateRecommendations()                            │
│  │   └─> RecommendationEngine.generateRecommendations()   │
│  │       ├─> Category-specific generators                 │
│  │       ├─> Sort by priority                             │
│  │       └─> Limit to top 5                               │
│  │                                                         │
│  ├─> filterByType(type)                                   │
│  ├─> getByPriority()                                      │
│  └─> calculateImpact(rec)                                 │
│                                                             │
│  [💡 Recommendation Card 1] → Details Modal               │
│  [💡 Recommendation Card 2] → Details Modal               │
│  [💡 Recommendation Card 3] → Details Modal               │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│      Sensor Activity Detection Engine (NEW) ✨             │
│                                                             │
│  SensorActivityDetector (static methods)                   │
│  │                                                         │
│  ├─> detectActivity()                                     │
│  │   ├─> calculateAccelerometerVariance()               │
│  │   ├─> calculateGyroscopeVariance()                    │
│  │   ├─> _classifyActivity()                             │
│  │   └─> Returns: DetectedActivity                       │
│  │                                                         │
│  ├─> smoothActivityDetection()                            │
│  │   └─> Filters low-confidence activities               │
│  │                                                         │
│  └─> getEmissionFactorForActivity()                       │
│      └─> Returns kg CO₂/km based on activity              │
│                                                             │
│  Supports 5 Activity Types:                                │
│  ├─ Walking    (0-7 km/h)                                 │
│  ├─ Cycling    (10-30 km/h)                               │
│  ├─ Vehicle    (20-80 km/h)                               │
│  ├─ Train      (50-150+ km/h)                             │
│  └─ Stationary (no movement)                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## File Dependencies Graph

```
main.dart
├─> recommendations_provider.dart
│   ├─> recommendation_model.dart
│   ├─> recommendation_engine.dart
│   │   ├─> recommendation_model.dart
│   │   └─> usage_data_model.dart
│   └─> usage_data_model.dart
│
├─> home_screen.dart (MODIFIED)
│   └─> recommendations_screen.dart
│       ├─> recommendation_model.dart
│       ├─> recommendations_provider.dart
│       └─> custom_widgets.dart
│
└─> sensor_activity_detector.dart
    └─ No external dependencies (pure Dart)
```

---

## Test File Structure (Optional)

Recommended test files to create:

```
test/
├── features/
│   ├── recommendations/
│   │   ├── recommendation_engine_test.dart
│   │   ├── recommendations_provider_test.dart
│   │   └── recommendations_screen_test.dart
│   │
│   └── sensors/
│       └── sensor_activity_detector_test.dart
```

---

## API/Function Reference

### RecommendationEngine (static)
```
generateRecommendations() → List<Recommendation>
filterByType(List, type) → List<Recommendation>
calculateTotalPotentialSavings(List) → double
getTopRecommendations(List, limit) → List<Recommendation>
_generateCategoryRecommendations() [private]
_generateTransportRecommendations() [private]
_generateElectricityRecommendations() [private]
_generateApplianceRecommendations() [private]
_generateFuelRecommendations() [private]
_generateWasteRecommendations() [private]
```

### RecommendationsProvider (ChangeNotifier)
```
generateRecommendations() → Future<void>
filterByType(RecommendationType?) → void
getTopRecommendations(limit) → List<Recommendation>
getByPriority() → List<Recommendation>
getByPotentialSavings() → List<Recommendation>
dismissRecommendation(id) → void
getRecommendationsForCategory(category) → List<Recommendation>
calculateImpact(Recommendation) → Map
clearRecommendations() → void
clearError() → void
```

### SensorActivityDetector (static)
```
detectActivity() → DetectedActivity
calculateAccelerometerVariance(readings) → double
calculateGyroscopeVariance(readings) → double
getEmissionFactorForActivity(type) → double
smoothActivityDetection(activities) → ActivityType
_classifyActivity() [private] → ActivityType
_calculateConfidence() [private] → double
```

---

## Version Info

- **Implementation Date:** February 14, 2026
- **Flutter Version:** >=3.0.0 (from pubspec.yaml)
- **Dart Version:** >=3.0.0
- **Provider Package:** ^6.1.1
- **UUID Package:** (already in pubspec.yaml)

---

## Next Steps for Integration

1. ✅ All files created
2. ✅ main.dart updated
3. ✅ home_screen.dart updated
4. ✅ Run `flutter pub get` (no new dependencies)
5. ✅ Run `flutter run` to test
6. 📋 (Optional) Add unit tests
7. 📋 (Optional) Add E2E tests
8. 📋 (Optional) Background sensor service

