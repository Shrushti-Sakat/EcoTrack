# AI-Based Carbon Footprint Calculator

An offline-first Flutter mobile application that uses smartphone sensors to automatically detect and calculate carbon emissions from daily activities.

## 🌱 Features

- **Automatic Activity Detection**: Uses accelerometer, gyroscope, and GPS to detect walking, cycling, and vehicle travel
- **Real-time Carbon Tracking**: Calculates CO₂ emissions based on detected activities
- **On-Device AI Analytics**:
  - Linear Regression for emission prediction
  - K-Means Clustering for user classification
  - Z-Score Anomaly Detection
- **Personalized Recommendations**: Eco-friendly suggestions based on your patterns
- **Offline-First**: All data stored locally, no internet required
- **Region Selection**: Emission factors for India, USA, UK, EU, Australia, and China

## 📱 Architecture

This application follows a **Three-Tier Architecture**:

```
┌─────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │  Providers  │  │      Widgets        │  │
│  │  Dashboard  │  │  Dashboard  │  │  CarbonScoreCard   │  │
│  │  Activity   │  │   Sensor    │  │  WeeklyChartCard   │  │
│  │  Insights   │  │  Settings   │  │  RecommendationCard│  │
│  │  Settings   │  │             │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  BUSINESS LOGIC LAYER                        │
│  ┌───────────────────┐    ┌────────────────────────────┐    │
│  │     Services      │    │       ML Modules           │    │
│  │  SensorService    │    │  LinearRegression          │    │
│  │  ActivityRecog    │    │  KMeansClustering          │    │
│  │  CarbonCalculator │    │  AnomalyDetector           │    │
│  │                   │    │  PredictionEngine          │    │
│  └───────────────────┘    └────────────────────────────┘    │
│  ┌───────────────────┐                                      │
│  │     Engines       │                                      │
│  │  Recommendation   │                                      │
│  └───────────────────┘                                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌───────────────────┐    ┌────────────────────────────┐    │
│  │   Repositories    │    │        Models              │    │
│  │  SensorRepository │    │  SensorData                │    │
│  │  ActivityRepository│   │  ActivityLog               │    │
│  │  CarbonRepository │    │  CarbonEntry               │    │
│  │  UserRepository   │    │  DailySummary              │    │
│  └───────────────────┘    │  UserProfile               │    │
│  ┌───────────────────┐    └────────────────────────────┘    │
│  │     Database      │                                      │
│  │  SQLite (sqflite) │                                      │
│  └───────────────────┘                                      │
└─────────────────────────────────────────────────────────────┘
```

## 🔬 Sensor-to-Carbon Mapping

| Sensor Data | Detected Activity | Emission Factor |
|-------------|-------------------|-----------------|
| High accel variance + Speed 0-7 km/h | Walking | 0 kg CO₂/km |
| Medium variance + Speed 10-30 km/h | Cycling | 0 kg CO₂/km |
| Low variance + Speed 20-60 km/h | Vehicle | 0.21 kg CO₂/km |
| Very low variance + Speed >80 km/h | Train | 0.041 kg CO₂/km |
| Stationary + Screen ON | Digital Usage | 0.008 kg CO₂/hour |

## 🤖 On-Device ML Algorithms

### 1. Linear Regression (Emission Prediction)
Predicts future emissions based on historical data using least squares method.

### 2. K-Means Clustering (User Classification)
Classifies users into Low/Medium/High emitters using K-Means++ initialization.

### 3. Z-Score Anomaly Detection
Detects unusual emission spikes or drops using statistical analysis.

## 📊 Database Schema

- **sensor_data**: Raw sensor readings (accelerometer, gyroscope, GPS, battery)
- **activity_log**: Detected activities with duration and distance
- **carbon_entry**: Individual CO₂ emission records
- **daily_summary**: Aggregated daily emissions
- **user_profile**: User preferences and inferred characteristics

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

1. Navigate to the project directory:
```bash
cd carbon_footprint_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Permissions Required
- **Location**: To detect travel and calculate distances
- **Activity Recognition**: To detect walking, cycling, etc.
- **Sensors**: Accelerometer and gyroscope access

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Shared utilities
│   ├── constants/            # Emission factors, app constants
│   ├── theme/                # App theming
│   └── utils/                # Date, math utilities
├── data/                     # Data layer
│   ├── models/               # Data models
│   ├── database/             # SQLite helper
│   └── repositories/         # Data access layer
├── business/                 # Business logic layer
│   ├── services/             # Sensor, activity, carbon services
│   ├── ml/                   # ML algorithms
│   └── engines/              # Recommendation engine
└── presentation/             # UI layer
    ├── providers/            # State management
    ├── screens/              # App screens
    └── widgets/              # Reusable widgets
```

## 🔒 Privacy

- **100% Offline**: No data is sent to any server
- **Local Storage**: All data stored on device using SQLite
- **No Analytics**: No third-party tracking or analytics
- **User Control**: Export or delete all data anytime

## 📄 License

This project is for academic/educational purposes.

## 👤 Author

Carbon Footprint Calculator - AI-Powered Eco-Tracking
