import 'package:flutter/foundation.dart';
import '../models/recommendation_model.dart';
import '../services/recommendation_engine.dart';
import '../../usage_data/models/usage_data_model.dart';

/// Recommendations Provider for state management
class RecommendationsProvider extends ChangeNotifier {
  List<Recommendation> _recommendations = [];
  List<Recommendation> _filteredRecommendations = [];
  bool _isLoading = false;
  String? _errorMessage;
  RecommendationType? _selectedFilter;
  double _totalPotentialSavings = 0.0;

  // Getters
  List<Recommendation> get recommendations => _recommendations;
  List<Recommendation> get filteredRecommendations => _filteredRecommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecommendationType? get selectedFilter => _selectedFilter;
  double get totalPotentialSavings => _totalPotentialSavings;

  /// Generate recommendations based on emission data
  Future<void> generateRecommendations({
    required Map<UsageCategory, double> emissionsByCategory,
    required double totalEmission,
    required List<UsageDataEntry> recentEntries,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Generate recommendations using the engine
      _recommendations = RecommendationEngine.generateRecommendations(
        emissionsByCategory: emissionsByCategory,
        totalEmission: totalEmission,
        recentEntries: recentEntries,
      );

      // Calculate total potential savings
      _totalPotentialSavings =
          RecommendationEngine.calculateTotalPotentialSavings(_recommendations);

      // Initialize filtered list
      _filteredRecommendations = List.from(_recommendations);
    } catch (e) {
      _errorMessage = 'Failed to generate recommendations: ${e.toString()}';
    }

    _setLoading(false);
    notifyListeners();
  }

  /// Filter recommendations by type
  void filterByType(RecommendationType? type) {
    _selectedFilter = type;

    if (type == null) {
      _filteredRecommendations = List.from(_recommendations);
    } else {
      _filteredRecommendations =
          RecommendationEngine.filterByType(_recommendations, type);
    }

    notifyListeners();
  }

  /// Get top N recommendations
  List<Recommendation> getTopRecommendations({int limit = 5}) {
    return RecommendationEngine.getTopRecommendations(
      _filteredRecommendations,
      limit: limit,
    );
  }

  /// Get recommendations sorted by priority
  List<Recommendation> getByPriority() {
    final sorted = List<Recommendation>.from(_filteredRecommendations);
    sorted.sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }

  /// Get recommendations sorted by potential savings
  List<Recommendation> getByPotentialSavings() {
    final sorted = List<Recommendation>.from(_filteredRecommendations);
    sorted.sort((a, b) => b.potentialCO2Savings.compareTo(a.potentialCO2Savings));
    return sorted;
  }

  /// Mark recommendation as read/dismissed (for future UI tracking)
  void dismissRecommendation(String recommendationId) {
    _recommendations
        .removeWhere((rec) => rec.id == recommendationId);
    _filteredRecommendations
        .removeWhere((rec) => rec.id == recommendationId);

    _totalPotentialSavings =
        RecommendationEngine.calculateTotalPotentialSavings(_recommendations);

    notifyListeners();
  }

  /// Get all recommendations for a category
  List<Recommendation> getRecommendationsForCategory(String category) {
    return _filteredRecommendations
        .where((rec) => rec.category == category)
        .toList();
  }

  /// Calculate impact of implementing a recommendation
  Map<String, dynamic> calculateImpact(Recommendation recommendation) {
    return {
      'savingsPerMonth': recommendation.potentialCO2Savings * 30,
      'savingsPerYear': recommendation.potentialCO2Savings * 365,
      'equivalentTreesPerYear':
          (recommendation.potentialCO2Savings * 365) / 21.77, // kg CO2 per tree per year
    };
  }

  /// Clear all recommendations
  void clearRecommendations() {
    _recommendations = [];
    _filteredRecommendations = [];
    _selectedFilter = null;
    _totalPotentialSavings = 0.0;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Private helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
