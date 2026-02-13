import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';
import '../../../core/services/database_service.dart';

/// User Profile Provider for state management
class UserProfileProvider extends ChangeNotifier {
  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProfileComplete = false;

  // Getters
  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProfileComplete => _isProfileComplete;
  bool get hasProfile => _currentProfile != null;

  /// Initialize provider and load existing profile
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentProfile = await DatabaseService.instance.getCurrentUserProfile();
      _isProfileComplete = _currentProfile != null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load profile: ${e.toString()}';
    }
    _setLoading(false);
  }

  /// Create new user profile
  Future<bool> createProfile({
    required String name,
    required int age,
    required String city,
    required String region,
    required LifestyleType lifestyleType,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        throw Exception('Name is required');
      }
      if (age < 1 || age > 120) {
        throw Exception('Please enter a valid age');
      }
      if (city.trim().isEmpty) {
        throw Exception('City is required');
      }

      final profile = UserProfile(
        name: name.trim(),
        age: age,
        city: city.trim(),
        region: region,
        lifestyleType: lifestyleType,
      );

      await DatabaseService.instance.saveUserProfile(profile);
      _currentProfile = profile;
      _isProfileComplete = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Update existing profile
  Future<bool> updateProfile({
    String? name,
    int? age,
    String? city,
    String? region,
    LifestyleType? lifestyleType,
  }) async {
    if (_currentProfile == null) {
      _errorMessage = 'No profile to update';
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // Validate inputs
      if (name != null && name.trim().isEmpty) {
        throw Exception('Name cannot be empty');
      }
      if (age != null && (age < 1 || age > 120)) {
        throw Exception('Please enter a valid age');
      }
      if (city != null && city.trim().isEmpty) {
        throw Exception('City cannot be empty');
      }

      final updatedProfile = _currentProfile!.copyWith(
        name: name?.trim(),
        age: age,
        city: city?.trim(),
        region: region,
        lifestyleType: lifestyleType,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.instance.saveUserProfile(updatedProfile);
      _currentProfile = updatedProfile;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Delete current profile
  Future<bool> deleteProfile() async {
    if (_currentProfile == null) {
      return true;
    }

    _setLoading(true);
    try {
      await DatabaseService.instance.deleteUserProfile(_currentProfile!.id);
      await DatabaseService.instance.deleteAllUserUsageEntries(_currentProfile!.id);
      _currentProfile = null;
      _isProfileComplete = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete profile: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Get emission factor for the current region
  double getRegionElectricityFactor() {
    if (_currentProfile == null) {
      return 0.82; // Default to India
    }
    final region = Region.fromCode(_currentProfile!.region);
    return region.electricityFactor;
  }

  /// Get lifestyle adjustment factor
  double getLifestyleAdjustmentFactor() {
    return _currentProfile?.baselineEmissionFactor ?? 1.0;
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
