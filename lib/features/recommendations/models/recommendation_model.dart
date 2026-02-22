/// Recommendation Model
class Recommendation {
  final String id;
  final String title;
  final String description;
  final String icon;
  final RecommendationType type;
  final double potentialCO2Savings; // kg CO2 that can be saved
  final String category; // The emission category it targets
  final int priority; // 1 (high) to 3 (low)
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.potentialCO2Savings,
    required this.category,
    required this.priority,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'Recommendation(id: $id, title: $title, type: ${type.name}, savings: ${potentialCO2Savings}kg)';
  }
}

/// Recommendation Types
enum RecommendationType {
  transport,        // Related to travel
  electricity,      // Related to power usage
  lifestyle,        // General lifestyle changes
  technology,       // Digital/tech usage
  appliances,       // Home appliances
  waste;            // Waste reduction

  String get displayName {
    switch (this) {
      case RecommendationType.transport:
        return '🚗 Transport';
      case RecommendationType.electricity:
        return '⚡ Electricity';
      case RecommendationType.lifestyle:
        return '🌿 Lifestyle';
      case RecommendationType.technology:
        return '📱 Technology';
      case RecommendationType.appliances:
        return '🏠 Appliances';
      case RecommendationType.waste:
        return '♻️ Waste';
    }
  }
}

/// Recommendation Category
class RecommendationCategory {
  final String category;
  final double weeklyEmission;
  final double averageEmission;
  final int entryCount;

  RecommendationCategory({
    required this.category,
    required this.weeklyEmission,
    required this.averageEmission,
    required this.entryCount,
  });
}
