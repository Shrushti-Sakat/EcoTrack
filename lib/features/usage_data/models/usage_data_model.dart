import 'package:uuid/uuid.dart';

/// Usage Data Entry Model
class UsageDataEntry {
  final String id;
  final String userId;
  final UsageCategory category;
  final UsageType type;
  final double value;
  final String unit;
  final DateTime date;
  final DateTime createdAt;
  final String? notes;
  
  // Calculated CO2 emission for this entry
  final double co2Emission;

  UsageDataEntry({
    String? id,
    required this.userId,
    required this.category,
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
    DateTime? createdAt,
    this.notes,
    required this.co2Emission,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Copy with method
  UsageDataEntry copyWith({
    UsageCategory? category,
    UsageType? type,
    double? value,
    String? unit,
    DateTime? date,
    String? notes,
    double? co2Emission,
  }) {
    return UsageDataEntry(
      id: id,
      userId: userId,
      category: category ?? this.category,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      createdAt: createdAt,
      notes: notes ?? this.notes,
      co2Emission: co2Emission ?? this.co2Emission,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category': category.name,
      'type': type.name,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
      'co2_emission': co2Emission,
    };
  }

  /// Create from Map (database record)
  factory UsageDataEntry.fromMap(Map<String, dynamic> map) {
    return UsageDataEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      category: UsageCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => UsageCategory.electricity,
      ),
      type: UsageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => UsageType.electricityGeneral,
      ),
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      notes: map['notes'] as String?,
      co2Emission: (map['co2_emission'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'UsageDataEntry(id: $id, category: ${category.name}, type: ${type.name}, value: $value $unit, co2: $co2Emission kg)';
  }
}

/// Usage Categories
enum UsageCategory {
  electricity,
  fuel,
  travel,
  appliance,
  waste;

  String get displayName {
    switch (this) {
      case UsageCategory.electricity:
        return 'Electricity';
      case UsageCategory.fuel:
        return 'Fuel';
      case UsageCategory.travel:
        return 'Travel';
      case UsageCategory.appliance:
        return 'Appliances';
      case UsageCategory.waste:
        return 'Waste';
    }
  }

  String get icon {
    switch (this) {
      case UsageCategory.electricity:
        return '⚡';
      case UsageCategory.fuel:
        return '⛽';
      case UsageCategory.travel:
        return '🚗';
      case UsageCategory.appliance:
        return '🏠';
      case UsageCategory.waste:
        return '🗑️';
    }
  }

  String get colorHex {
    switch (this) {
      case UsageCategory.electricity:
        return '#FFB74D';
      case UsageCategory.fuel:
        return '#FF7043';
      case UsageCategory.travel:
        return '#4FC3F7';
      case UsageCategory.appliance:
        return '#81C784';
      case UsageCategory.waste:
        return '#BA68C8';
    }
  }
}

/// Usage Types with emission factors
enum UsageType {
  // Electricity
  electricityGeneral,
  
  // Fuel
  petrol,
  diesel,
  lpg,
  cng,
  
  // Travel
  carPetrol,
  carDiesel,
  carElectric,
  motorcycle,
  bus,
  train,
  autoRickshaw,
  bicycle,
  walking,
  
  // Appliances
  airConditioner,
  heater,
  washingMachine,
  refrigerator,
  television,
  computer,
  
  // Waste
  generalWaste,
  recyclableWaste,
  organicWaste;

  String get displayName {
    switch (this) {
      case UsageType.electricityGeneral:
        return 'General Electricity';
      case UsageType.petrol:
        return 'Petrol';
      case UsageType.diesel:
        return 'Diesel';
      case UsageType.lpg:
        return 'LPG';
      case UsageType.cng:
        return 'CNG';
      case UsageType.carPetrol:
        return 'Car (Petrol)';
      case UsageType.carDiesel:
        return 'Car (Diesel)';
      case UsageType.carElectric:
        return 'Car (Electric)';
      case UsageType.motorcycle:
        return 'Motorcycle';
      case UsageType.bus:
        return 'Bus';
      case UsageType.train:
        return 'Train';
      case UsageType.autoRickshaw:
        return 'Auto Rickshaw';
      case UsageType.bicycle:
        return 'Bicycle';
      case UsageType.walking:
        return 'Walking';
      case UsageType.airConditioner:
        return 'Air Conditioner';
      case UsageType.heater:
        return 'Heater';
      case UsageType.washingMachine:
        return 'Washing Machine';
      case UsageType.refrigerator:
        return 'Refrigerator';
      case UsageType.television:
        return 'Television';
      case UsageType.computer:
        return 'Computer';
      case UsageType.generalWaste:
        return 'General Waste';
      case UsageType.recyclableWaste:
        return 'Recyclable Waste';
      case UsageType.organicWaste:
        return 'Organic Waste';
    }
  }

  UsageCategory get category {
    switch (this) {
      case UsageType.electricityGeneral:
        return UsageCategory.electricity;
      case UsageType.petrol:
      case UsageType.diesel:
      case UsageType.lpg:
      case UsageType.cng:
        return UsageCategory.fuel;
      case UsageType.carPetrol:
      case UsageType.carDiesel:
      case UsageType.carElectric:
      case UsageType.motorcycle:
      case UsageType.bus:
      case UsageType.train:
      case UsageType.autoRickshaw:
      case UsageType.bicycle:
      case UsageType.walking:
        return UsageCategory.travel;
      case UsageType.airConditioner:
      case UsageType.heater:
      case UsageType.washingMachine:
      case UsageType.refrigerator:
      case UsageType.television:
      case UsageType.computer:
        return UsageCategory.appliance;
      case UsageType.generalWaste:
      case UsageType.recyclableWaste:
      case UsageType.organicWaste:
        return UsageCategory.waste;
    }
  }

  String get unit {
    switch (this) {
      case UsageType.electricityGeneral:
        return 'kWh';
      case UsageType.petrol:
      case UsageType.diesel:
      case UsageType.lpg:
      case UsageType.cng:
        return 'liters';
      case UsageType.carPetrol:
      case UsageType.carDiesel:
      case UsageType.carElectric:
      case UsageType.motorcycle:
      case UsageType.bus:
      case UsageType.train:
      case UsageType.autoRickshaw:
      case UsageType.bicycle:
      case UsageType.walking:
        return 'km';
      case UsageType.airConditioner:
      case UsageType.heater:
      case UsageType.washingMachine:
      case UsageType.refrigerator:
      case UsageType.television:
      case UsageType.computer:
        return 'hours';
      case UsageType.generalWaste:
      case UsageType.recyclableWaste:
      case UsageType.organicWaste:
        return 'kg';
    }
  }

  /// Base emission factor (kg CO2 per unit) - India defaults
  double get baseEmissionFactor {
    switch (this) {
      case UsageType.electricityGeneral:
        return 0.82; // kg CO2 per kWh
      case UsageType.petrol:
        return 2.31; // kg CO2 per liter
      case UsageType.diesel:
        return 2.68; // kg CO2 per liter
      case UsageType.lpg:
        return 1.51; // kg CO2 per liter
      case UsageType.cng:
        return 2.75; // kg CO2 per kg
      case UsageType.carPetrol:
        return 0.21; // kg CO2 per km
      case UsageType.carDiesel:
        return 0.27; // kg CO2 per km
      case UsageType.carElectric:
        return 0.05; // kg CO2 per km
      case UsageType.motorcycle:
        return 0.103; // kg CO2 per km
      case UsageType.bus:
        return 0.089; // kg CO2 per km per passenger
      case UsageType.train:
        return 0.041; // kg CO2 per km per passenger
      case UsageType.autoRickshaw:
        return 0.08; // kg CO2 per km
      case UsageType.bicycle:
      case UsageType.walking:
        return 0.0; // Zero emissions
      case UsageType.airConditioner:
        return 1.5; // kg CO2 per hour (based on avg power consumption)
      case UsageType.heater:
        return 2.0; // kg CO2 per hour
      case UsageType.washingMachine:
        return 0.5; // kg CO2 per hour
      case UsageType.refrigerator:
        return 0.15; // kg CO2 per hour
      case UsageType.television:
        return 0.1; // kg CO2 per hour
      case UsageType.computer:
        return 0.2; // kg CO2 per hour
      case UsageType.generalWaste:
        return 0.5; // kg CO2 per kg waste
      case UsageType.recyclableWaste:
        return 0.1; // kg CO2 per kg (lower due to recycling)
      case UsageType.organicWaste:
        return 0.3; // kg CO2 per kg
    }
  }

  /// Get types for a specific category
  static List<UsageType> getTypesForCategory(UsageCategory category) {
    return UsageType.values.where((type) => type.category == category).toList();
  }
}

/// Logging frequency
enum LoggingFrequency {
  daily,
  weekly;

  String get displayName {
    switch (this) {
      case LoggingFrequency.daily:
        return 'Daily';
      case LoggingFrequency.weekly:
        return 'Weekly';
    }
  }
}
