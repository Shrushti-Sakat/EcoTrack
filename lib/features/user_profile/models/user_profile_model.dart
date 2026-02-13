import 'package:uuid/uuid.dart';

/// User Profile Model
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String city;
  final String region;
  final LifestyleType lifestyleType;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Calculated baseline emission factors based on profile
  final double baselineEmissionFactor;

  UserProfile({
    String? id,
    required this.name,
    required this.age,
    required this.city,
    required this.region,
    required this.lifestyleType,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? baselineEmissionFactor,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        baselineEmissionFactor = baselineEmissionFactor ?? 
            _calculateBaselineEmission(lifestyleType);

  /// Calculate baseline emission based on lifestyle
  static double _calculateBaselineEmission(LifestyleType lifestyle) {
    switch (lifestyle) {
      case LifestyleType.sedentary:
        return 1.0; // Lower activity, potentially higher emissions from indoor activities
      case LifestyleType.moderate:
        return 0.85; // Balanced lifestyle
      case LifestyleType.active:
        return 0.7; // Active lifestyle, typically lower emissions
    }
  }

  /// Copy with method for updating profile
  UserProfile copyWith({
    String? name,
    int? age,
    String? city,
    String? region,
    LifestyleType? lifestyleType,
    DateTime? updatedAt,
  }) {
    final newLifestyle = lifestyleType ?? this.lifestyleType;
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      region: region ?? this.region,
      lifestyleType: newLifestyle,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      baselineEmissionFactor: _calculateBaselineEmission(newLifestyle),
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'city': city,
      'region': region,
      'lifestyle_type': lifestyleType.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'baseline_emission_factor': baselineEmissionFactor,
    };
  }

  /// Create from Map (database record)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      city: map['city'] as String,
      region: map['region'] as String,
      lifestyleType: LifestyleType.values.firstWhere(
        (e) => e.name == map['lifestyle_type'],
        orElse: () => LifestyleType.moderate,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      baselineEmissionFactor: map['baseline_emission_factor'] as double,
    );
  }

  /// Get profile summary
  String get profileSummary {
    return '$name, $age years old\n$city ($region)\nLifestyle: ${lifestyleType.displayName}';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, city: $city, region: $region, lifestyle: ${lifestyleType.name})';
  }
}

/// Lifestyle Type Enum
enum LifestyleType {
  sedentary,
  moderate,
  active;

  String get displayName {
    switch (this) {
      case LifestyleType.sedentary:
        return 'Sedentary';
      case LifestyleType.moderate:
        return 'Moderate';
      case LifestyleType.active:
        return 'Active';
    }
  }

  String get description {
    switch (this) {
      case LifestyleType.sedentary:
        return 'Mostly desk work, minimal physical activity';
      case LifestyleType.moderate:
        return 'Regular activities, some exercise';
      case LifestyleType.active:
        return 'High physical activity, regular outdoor activities';
    }
  }

  String get icon {
    switch (this) {
      case LifestyleType.sedentary:
        return '🪑';
      case LifestyleType.moderate:
        return '🚶';
      case LifestyleType.active:
        return '🏃';
    }
  }
}

/// Available Regions for selection
class Region {
  final String code;
  final String name;
  final double electricityFactor;

  const Region({
    required this.code,
    required this.name,
    required this.electricityFactor,
  });

  static const List<Region> availableRegions = [
    Region(code: 'india', name: 'India', electricityFactor: 0.82),
    Region(code: 'usa', name: 'United States', electricityFactor: 0.42),
    Region(code: 'uk', name: 'United Kingdom', electricityFactor: 0.23),
    Region(code: 'eu', name: 'European Union', electricityFactor: 0.28),
    Region(code: 'australia', name: 'Australia', electricityFactor: 0.79),
    Region(code: 'china', name: 'China', electricityFactor: 0.58),
  ];

  static Region fromCode(String code) {
    return availableRegions.firstWhere(
      (r) => r.code == code,
      orElse: () => availableRegions.first,
    );
  }
}
