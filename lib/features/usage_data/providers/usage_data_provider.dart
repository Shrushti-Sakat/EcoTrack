import 'package:flutter/foundation.dart';
import '../models/usage_data_model.dart';
import '../../../core/services/database_service.dart';

/// Usage Data Provider for state management
class UsageDataProvider extends ChangeNotifier {
  List<UsageDataEntry> _entries = [];
  List<UsageDataEntry> _todayEntries = [];
  List<UsageDataEntry> _weekEntries = [];
  Map<UsageCategory, double> _emissionsByCategory = {};
  bool _isLoading = false;
  String? _errorMessage;
  double _totalCO2Emission = 0.0;
  UsageCategory _selectedCategory = UsageCategory.electricity;
  LoggingFrequency _loggingFrequency = LoggingFrequency.daily;

  // Getters
  List<UsageDataEntry> get entries => _entries;
  List<UsageDataEntry> get todayEntries => _todayEntries;
  List<UsageDataEntry> get weekEntries => _weekEntries;
  Map<UsageCategory, double> get emissionsByCategory => _emissionsByCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalCO2Emission => _totalCO2Emission;
  UsageCategory get selectedCategory => _selectedCategory;
  LoggingFrequency get loggingFrequency => _loggingFrequency;

  /// Initialize provider and load data for user
  Future<void> initialize(String userId) async {
    _setLoading(true);
    try {
      await _loadAllData(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load usage data: ${e.toString()}';
    }
    _setLoading(false);
  }

  /// Load all usage data for a user
  Future<void> _loadAllData(String userId) async {
    _entries = await DatabaseService.instance.getUserUsageEntries(userId);
    _todayEntries = await DatabaseService.instance.getTodayUsageEntries(userId);
    _weekEntries = await DatabaseService.instance.getThisWeekUsageEntries(userId);
    _emissionsByCategory = await DatabaseService.instance.getCO2EmissionByCategory(userId);
    _totalCO2Emission = await DatabaseService.instance.getTotalCO2Emission(userId);
  }

  /// Refresh data
  Future<void> refresh(String userId) async {
    await initialize(userId);
  }

  /// Set selected category
  void setSelectedCategory(UsageCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set logging frequency
  void setLoggingFrequency(LoggingFrequency frequency) {
    _loggingFrequency = frequency;
    notifyListeners();
  }

  /// Add new usage entry
  Future<bool> addEntry({
    required String userId,
    required UsageType type,
    required double value,
    required DateTime date,
    String? notes,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Validate input
      if (value <= 0) {
        throw Exception('Value must be greater than 0');
      }

      // Calculate CO2 emission
      final co2Emission = _calculateCO2Emission(type, value);

      final entry = UsageDataEntry(
        userId: userId,
        category: type.category,
        type: type,
        value: value,
        unit: type.unit,
        date: date,
        notes: notes?.trim(),
        co2Emission: co2Emission,
      );

      await DatabaseService.instance.saveUsageEntry(entry);
      await _loadAllData(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Add multiple entries at once
  Future<bool> addMultipleEntries({
    required String userId,
    required List<Map<String, dynamic>> entriesData,
    required DateTime date,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final List<UsageDataEntry> newEntries = [];

      for (final data in entriesData) {
        final type = data['type'] as UsageType;
        final value = data['value'] as double;
        
        if (value > 0) {
          final co2Emission = _calculateCO2Emission(type, value);
          newEntries.add(UsageDataEntry(
            userId: userId,
            category: type.category,
            type: type,
            value: value,
            unit: type.unit,
            date: date,
            notes: data['notes'] as String?,
            co2Emission: co2Emission,
          ));
        }
      }

      if (newEntries.isEmpty) {
        throw Exception('No valid entries to add');
      }

      await DatabaseService.instance.saveUsageEntries(newEntries);
      await _loadAllData(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Update existing entry
  Future<bool> updateEntry({
    required String userId,
    required String entryId,
    UsageType? type,
    double? value,
    DateTime? date,
    String? notes,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final existingEntry = await DatabaseService.instance.getUsageEntry(entryId);
      if (existingEntry == null) {
        throw Exception('Entry not found');
      }

      final newType = type ?? existingEntry.type;
      final newValue = value ?? existingEntry.value;

      if (newValue <= 0) {
        throw Exception('Value must be greater than 0');
      }

      final co2Emission = _calculateCO2Emission(newType, newValue);

      final updatedEntry = existingEntry.copyWith(
        type: newType,
        category: newType.category,
        value: newValue,
        unit: newType.unit,
        date: date,
        notes: notes?.trim(),
        co2Emission: co2Emission,
      );

      await DatabaseService.instance.saveUsageEntry(updatedEntry);
      await _loadAllData(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Delete entry
  Future<bool> deleteEntry(String userId, String entryId) async {
    _setLoading(true);
    try {
      await DatabaseService.instance.deleteUsageEntry(entryId);
      await _loadAllData(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete entry: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Get entries filtered by category
  List<UsageDataEntry> getEntriesByCategory(UsageCategory category) {
    return _entries.where((e) => e.category == category).toList();
  }

  /// Get entries for a specific date
  List<UsageDataEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) =>
      e.date.year == date.year &&
      e.date.month == date.month &&
      e.date.day == date.day
    ).toList();
  }

  /// Get today's total emission
  double getTodayTotalEmission() {
    return _todayEntries.fold(0.0, (sum, entry) => sum + entry.co2Emission);
  }

  /// Get this week's total emission
  double getWeekTotalEmission() {
    return _weekEntries.fold(0.0, (sum, entry) => sum + entry.co2Emission);
  }

  /// Calculate CO2 emission for an entry
  double _calculateCO2Emission(UsageType type, double value) {
    return type.baseEmissionFactor * value;
  }

  /// Get emission factor for a type (allows for region adjustment)
  double getEmissionFactor(UsageType type, {double? regionFactor}) {
    double baseFactor = type.baseEmissionFactor;
    
    // Adjust for region-specific factors (mainly for electricity)
    if (type == UsageType.electricityGeneral && regionFactor != null) {
      baseFactor = regionFactor;
    }
    
    return baseFactor;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _entries = [];
    _todayEntries = [];
    _weekEntries = [];
    _emissionsByCategory = {};
    _totalCO2Emission = 0.0;
    notifyListeners();
  }

  /// Private helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
