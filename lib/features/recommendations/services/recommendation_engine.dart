import 'package:uuid/uuid.dart';
import '../models/recommendation_model.dart';
import '../../usage_data/models/usage_data_model.dart';

/// Recommendation Engine - Generates eco-friendly suggestions based on user patterns
class RecommendationEngine {
  static const _uuid = Uuid();

  /// Generate recommendations based on emission data and patterns
  static List<Recommendation> generateRecommendations({
    required Map<UsageCategory, double> emissionsByCategory,
    required double totalEmission,
    required List<UsageDataEntry> recentEntries,
  }) {
    final recommendations = <Recommendation>[];

    // Analyze each category and generate recommendations
    emissionsByCategory.forEach((category, emission) {
      if (emission > 0) {
        final categoryRecommendations =
            _generateCategoryRecommendations(category, emission, totalEmission);
        recommendations.addAll(categoryRecommendations);
      }
    });

    // Sort by priority and potential savings
    recommendations.sort((a, b) {
      if (a.priority != b.priority) {
        return a.priority.compareTo(b.priority);
      }
      return b.potentialCO2Savings.compareTo(a.potentialCO2Savings);
    });

    // Return top recommendations (max 5)
    return recommendations.take(5).toList();
  }

  /// Generate recommendations for a specific category
  static List<Recommendation> _generateCategoryRecommendations(
    UsageCategory category,
    double emission,
    double totalEmission,
  ) {
    final recommendations = <Recommendation>[];
    final percentage = (emission / totalEmission * 100).toStringAsFixed(1);

    switch (category) {
      case UsageCategory.travel:
        recommendations.addAll(_generateTransportRecommendations(emission));
        break;
      case UsageCategory.electricity:
        recommendations.addAll(_generateElectricityRecommendations(emission));
        break;
      case UsageCategory.appliance:
        recommendations.addAll(_generateApplianceRecommendations(emission));
        break;
      case UsageCategory.fuel:
        recommendations.addAll(_generateFuelRecommendations(emission));
        break;
      case UsageCategory.waste:
        recommendations.addAll(_generateWasteRecommendations(emission));
        break;
    }

    return recommendations;
  }

  /// Transport recommendations
  static List<Recommendation> _generateTransportRecommendations(
      double emission) {
    return [
      if (emission > 2.0)
        Recommendation(
          id: _uuid.v4(),
          title: 'Switch to Public Transport',
          description:
              'Using public transit can reduce your carbon emissions by up to 75% compared to personal vehicles',
          icon: '🚌',
          type: RecommendationType.transport,
          potentialCO2Savings: emission * 0.75,
          category: UsageCategory.travel.displayName,
          priority: 1,
        ),
      if (emission > 1.5)
        Recommendation(
          id: _uuid.v4(),
          title: 'Try Cycling for Short Distances',
          description:
              'Trips under 5 km are perfect for cycling. Zero emissions and great exercise!',
          icon: '🚲',
          type: RecommendationType.transport,
          potentialCO2Savings: emission * 0.5,
          category: UsageCategory.travel.displayName,
          priority: 1,
        ),
      if (emission > 1.0)
        Recommendation(
          id: _uuid.v4(),
          title: 'Carpool or Use Ride-Sharing',
          description:
              'Sharing rides with others reduces per-person emissions. Apps like carpooling services help find riders',
          icon: '🤝',
          type: RecommendationType.transport,
          potentialCO2Savings: emission * 0.4,
          category: UsageCategory.travel.displayName,
          priority: 2,
        ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Consider an Electric Vehicle',
        description:
            'Electric vehicles produce 50-70% fewer emissions than petrol/diesel cars over their lifetime',
        icon: '⚡🚗',
        type: RecommendationType.transport,
        potentialCO2Savings: emission * 0.6,
        category: UsageCategory.travel.displayName,
        priority: 3,
      ),
    ];
  }

  /// Electricity recommendations
  static List<Recommendation> _generateElectricityRecommendations(
      double emission) {
    return [
      if (emission > 3.0)
        Recommendation(
          id: _uuid.v4(),
          title: 'Switch to LED Bulbs',
          description:
              'LED lighting uses 75% less energy than incandescent bulbs and lasts much longer',
          icon: '💡',
          type: RecommendationType.electricity,
          potentialCO2Savings: emission * 0.3,
          category: UsageCategory.electricity.displayName,
          priority: 1,
        ),
      if (emission > 2.5)
        Recommendation(
          id: _uuid.v4(),
          title: 'Use Smart Power Strips',
          description:
              'Eliminate phantom power drain by using smart power strips that cut power to idle devices',
          icon: '🔌',
          type: RecommendationType.electricity,
          potentialCO2Savings: emission * 0.15,
          category: UsageCategory.electricity.displayName,
          priority: 2,
        ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Install Solar Panels',
        description:
            'Solar energy is renewable and can reduce your grid electricity needs by up to 80%',
        icon: '☀️',
        type: RecommendationType.electricity,
        potentialCO2Savings: emission * 0.8,
        category: UsageCategory.electricity.displayName,
        priority: 3,
      ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Use Energy-Efficient Appliances',
        description:
            'ENERGY STAR certified appliances use 10-50% less energy than standard models',
        icon: '⭐',
        type: RecommendationType.electricity,
        potentialCO2Savings: emission * 0.25,
        category: UsageCategory.electricity.displayName,
        priority: 2,
      ),
    ];
  }

  /// Appliance recommendations
  static List<Recommendation> _generateApplianceRecommendations(
      double emission) {
    return [
      if (emission > 1.5)
        Recommendation(
          id: _uuid.v4(),
          title: 'Reduce Air Conditioning Usage',
          description:
              'Use fans, open windows, or increase thermostat to 25°C. Each degree saves ~6% energy',
          icon: '❄️',
          type: RecommendationType.appliances,
          potentialCO2Savings: emission * 0.35,
          category: UsageCategory.appliance.displayName,
          priority: 1,
        ),
      if (emission > 1.0)
        Recommendation(
          id: _uuid.v4(),
          title: 'Optimize Refrigerator Settings',
          description:
              'Set fridge to 3-4°C and freezer to -18°C. Clean coils regularly to improve efficiency',
          icon: '🧊',
          type: RecommendationType.appliances,
          potentialCO2Savings: emission * 0.15,
          category: UsageCategory.appliance.displayName,
          priority: 2,
        ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Use Cold Water for Laundry',
        description:
            'Washing machines use 80-90% of energy for heating water. Cold water is equally effective',
        icon: '🌊',
        type: RecommendationType.appliances,
        potentialCO2Savings: emission * 0.4,
        category: UsageCategory.appliance.displayName,
        priority: 1,
      ),
    ];
  }

  /// Fuel consumption recommendations
  static List<Recommendation> _generateFuelRecommendations(double emission) {
    return [
      if (emission > 1.0)
        Recommendation(
          id: _uuid.v4(),
          title: 'Reduce Short Car Trips',
          description:
              'Multiple short trips use more fuel. Combine errands into one trip or walk instead',
          icon: '🚶',
          type: RecommendationType.transport,
          potentialCO2Savings: emission * 0.3,
          category: UsageCategory.fuel.displayName,
          priority: 1,
        ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Maintain Your Vehicle',
        description:
            'Regular maintenance (tire pressure, oil changes) improves fuel efficiency by 3-5%',
        icon: '🔧',
        type: RecommendationType.transport,
        potentialCO2Savings: emission * 0.04,
        category: UsageCategory.fuel.displayName,
        priority: 2,
      ),
    ];
  }

  /// Waste recommendations
  static List<Recommendation> _generateWasteRecommendations(double emission) {
    return [
      if (emission > 0.5)
        Recommendation(
          id: _uuid.v4(),
          title: 'Increase Recycling',
          description:
              'Recycling reduces methane emissions from landfills. Separate plastic, paper, and glass',
          icon: '♻️',
          type: RecommendationType.waste,
          potentialCO2Savings: emission * 0.6,
          category: UsageCategory.waste.displayName,
          priority: 1,
        ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Reduce Single-Use Plastics',
        description:
            'Use reusable bags, bottles, and containers. This reduces manufacturing emissions',
        icon: '🛍️',
        type: RecommendationType.waste,
        potentialCO2Savings: emission * 0.4,
        category: UsageCategory.waste.displayName,
        priority: 2,
      ),
      Recommendation(
        id: _uuid.v4(),
        title: 'Compost Organic Waste',
        description:
            'Composting reduces landfill methane and creates nutrient-rich soil for gardening',
        icon: '🌱',
        type: RecommendationType.waste,
        potentialCO2Savings: emission * 0.5,
        category: UsageCategory.waste.displayName,
        priority: 2,
      ),
    ];
  }

  /// Calculate total potential savings from all recommendations
  static double calculateTotalPotentialSavings(
      List<Recommendation> recommendations) {
    return recommendations.fold<double>(
      0.0,
      (sum, rec) => sum + rec.potentialCO2Savings,
    );
  }

  /// Get recommendations by type
  static List<Recommendation> filterByType(
    List<Recommendation> recommendations,
    RecommendationType type,
  ) {
    return recommendations.where((rec) => rec.type == type).toList();
  }

  /// Get top N recommendations by priority and savings
  static List<Recommendation> getTopRecommendations(
    List<Recommendation> recommendations, {
    int limit = 5,
  }) {
    return recommendations.take(limit).toList();
  }
}
