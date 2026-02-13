import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/country_city_data.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/user_profile_model.dart';
import '../providers/user_profile_provider.dart';

/// User Profile Screen - Registration and Profile Management
class UserProfileScreen extends StatefulWidget {
  final bool isEditing;

  const UserProfileScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedCountry = 'india';
  String? _selectedState;
  String? _selectedCity;
  String _selectedRegion = 'india';
  LifestyleType _selectedLifestyle = LifestyleType.moderate;
  int _currentStep = 0;
  String _citySearchQuery = '';
  String _stateSearchQuery = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Pre-fill if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing) {
        _loadExistingProfile();
      }
    });
  }

  void _loadExistingProfile() {
    final provider = context.read<UserProfileProvider>();
    final profile = provider.currentProfile;
    if (profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        // Try to find the country and state for this city
        _selectedCity = profile.city;
        for (final countryEntry in CountryData.countries.entries) {
          for (final stateEntry in countryEntry.value.states.entries) {
            if (stateEntry.value.cities.contains(profile.city)) {
              _selectedCountry = countryEntry.key;
              _selectedState = stateEntry.key;
              break;
            }
          }
        }
        _selectedRegion = profile.region;
        _selectedLifestyle = profile.lifestyleType;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: _buildStepContent(),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              if (widget.isEditing || _currentStep > 0)
                IconButton(
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.softShadow,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  widget.isEditing ? 'Edit Profile' : 'Create Profile',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Tell us about yourself';
      case 1:
        return 'Where are you located?';
      case 2:
        return 'What\'s your lifestyle like?';
      default:
        return '';
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          final stepIcons = [
            Icons.person_rounded,
            Icons.location_on_rounded,
            Icons.eco_rounded,
          ];
          
          return Expanded(
            child: Row(
              children: [
                // Step circle with icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isActive || isCompleted
                        ? AppGradients.primaryGradient
                        : null,
                    color: !isActive && !isCompleted
                        ? Colors.white
                        : null,
                    shape: BoxShape.circle,
                    border: !isActive && !isCompleted
                        ? Border.all(color: AppColors.inputBorder, width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : AppShadows.softShadow,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          )
                        : Icon(
                            stepIcons[index],
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                  ),
                ),
                // Connector line
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: index < _currentStep
                            ? AppGradients.primaryGradient
                            : null,
                        color: index >= _currentStep
                            ? AppColors.inputBorder
                            : null,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        key: ValueKey(_currentStep),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: _getStepWidget(),
        ),
      ),
    );
  }

  Widget _getStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildLifestyleStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Avatar placeholder
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppShadows.buttonShadow,
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your name',
          prefixIcon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _ageController,
          label: 'Age',
          hint: 'Enter your age',
          prefixIcon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = int.tryParse(value);
            if (age == null || age < 1 || age > 120) {
              return 'Please enter a valid age';
            }
            return null;
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLocationStep() {
    final cities = (_selectedCountry != null && _selectedState != null)
        ? CountryData.getCities(_selectedCountry!, _selectedState!)
        : <String>[];
    final filteredCities = _citySearchQuery.isEmpty
        ? cities
        : cities
            .where((c) =>
                c.toLowerCase().contains(_citySearchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Location icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on_rounded,
            size: 50,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 32),
        // Country Selection
        _buildCountrySelector(),
        const SizedBox(height: 20),
        // State Selection
        if (_selectedCountry != null) _buildStateSelector(),
        const SizedBox(height: 20),
        // City Selection
        if (_selectedCountry != null && _selectedState != null) 
          _buildCitySelector(filteredCities),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Region',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This helps us calculate accurate emission factors',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ...Region.availableRegions.map((region) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectionChip(
                  label: region.name,
                  subtitle: 'Electricity: ${region.electricityFactor} kg CO₂/kWh',
                  isSelected: _selectedRegion == region.code,
                  onTap: () => setState(() => _selectedRegion = region.code),
                  icon: Icons.public_rounded,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStateSelector() {
    final states = CountryData.getStates(_selectedCountry!);
    final selectedState = _selectedState != null
        ? CountryData.getState(_selectedCountry!, _selectedState!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State / Province',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showStatePicker(states),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedState != null
                    ? AppColors.primaryBlue
                    : AppColors.inputBorder,
                width: selectedState != null ? 2 : 1,
              ),
              boxShadow: AppShadows.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedState?.name ?? 'Select your state',
                    style: selectedState != null
                        ? AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          )
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showStatePicker(List<StateInfo> states) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildStatePickerSheet(states, setModalState);
        },
      ),
    );
  }

  Widget _buildStatePickerSheet(List<StateInfo> allStates, StateSetter setModalState) {
    final filteredStates = _stateSearchQuery.isEmpty
        ? allStates
        : allStates
            .where((s) =>
                s.name.toLowerCase().contains(_stateSearchQuery.toLowerCase()))
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select State',
                  style: AppTextStyles.heading3,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _stateSearchQuery = '';
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: TextField(
                onChanged: (value) {
                  setModalState(() {
                    _stateSearchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search state...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          // State List
          Expanded(
            child: filteredStates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No states found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredStates.length,
                    itemBuilder: (context, index) {
                      final state = filteredStates[index];
                      final isSelected = _selectedState == state.code;
                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedState = state.code;
                            _selectedCity = null; // Reset city when state changes
                            _stateSearchQuery = '';
                          });
                          Navigator.pop(context);
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : AppColors.inputBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.map_rounded,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          state.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${state.cities.length} cities',
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showCountryPicker(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
              boxShadow: AppShadows.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _selectedCountry != null
                      ? Row(
                          children: [
                            Text(
                              CountryData.getCountry(_selectedCountry!)?.flag ?? '',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                CountryData.getCountry(_selectedCountry!)?.name ?? '',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Select your country',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySelector(List<String> cities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showCityPicker(cities),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedCity != null
                    ? AppColors.primaryBlue
                    : AppColors.inputBorder,
                width: _selectedCity != null ? 2 : 1,
              ),
              boxShadow: AppShadows.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedCity ?? 'Select your city',
                    style: _selectedCity != null
                        ? AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          )
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCountryPickerSheet(),
    );
  }

  Widget _buildCountryPickerSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select Country',
                  style: AppTextStyles.heading3,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Country List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: CountryData.allCountries.length,
              itemBuilder: (context, index) {
                final country = CountryData.allCountries[index];
                final isSelected = _selectedCountry == country.code;
                return ListTile(
                  onTap: () {
                    setState(() {
                      _selectedCountry = country.code;
                      _selectedState = null; // Reset state when country changes
                      _selectedCity = null; // Reset city when country changes
                    });
                    Navigator.pop(context);
                  },
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    country.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${country.states.length} states/provinces',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryBlue,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCityPicker(List<String> allCities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildCityPickerSheet(allCities, setModalState);
        },
      ),
    );
  }

  Widget _buildCityPickerSheet(List<String> allCities, StateSetter setModalState) {
    final filteredCities = _citySearchQuery.isEmpty
        ? allCities
        : allCities
            .where(
                (c) => c.toLowerCase().contains(_citySearchQuery.toLowerCase()))
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select City',
                  style: AppTextStyles.heading3,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _citySearchQuery = '';
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: TextField(
                onChanged: (value) {
                  setModalState(() {
                    _citySearchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search city...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          // City List
          Expanded(
            child: filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cities found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      final isSelected = _selectedCity == city;
                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedCity = city;
                            _citySearchQuery = '';
                          });
                          Navigator.pop(context);
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : AppColors.inputBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          city,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Lifestyle icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 50,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Select Your Lifestyle',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 8),
        const Text(
          'This helps personalize your carbon footprint calculations',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...LifestyleType.values.map((lifestyle) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildLifestyleCard(lifestyle),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLifestyleCard(LifestyleType lifestyle) {
    final isSelected = _selectedLifestyle == lifestyle;
    
    IconData iconData;
    switch (lifestyle) {
      case LifestyleType.sedentary:
        iconData = Icons.weekend_rounded;
        break;
      case LifestyleType.moderate:
        iconData = Icons.directions_walk_rounded;
        break;
      case LifestyleType.active:
        iconData = Icons.directions_run_rounded;
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedLifestyle = lifestyle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.inputBorder,
            width: 2,
          ),
          boxShadow: isSelected ? AppShadows.buttonShadow : AppShadows.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                iconData,
                size: 28,
                color: isSelected ? Colors.white : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lifestyle.displayName,
                    style: AppTextStyles.heading4.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lifestyle.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              if (provider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Navigation arrows with center action button
              Row(
                children: [
                  // Left Arrow - Previous
                  _buildNavArrow(
                    icon: Icons.arrow_back_ios_rounded,
                    isEnabled: _currentStep > 0,
                    onTap: _currentStep > 0
                        ? () => setState(() => _currentStep--)
                        : null,
                    isLeft: true,
                  ),
                  const SizedBox(width: 16),
                  // Center Action Button
                  Expanded(
                    child: _buildActionButton(
                      text: _currentStep == 2
                          ? (widget.isEditing ? 'Save Changes' : 'Create Profile')
                          : 'Continue',
                      icon: _currentStep == 2
                          ? Icons.check_rounded
                          : Icons.double_arrow_rounded,
                      isLoading: provider.isLoading,
                      onPressed: () => _onContinue(provider),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right Arrow - Next
                  _buildNavArrow(
                    icon: Icons.arrow_forward_ios_rounded,
                    isEnabled: _currentStep < 2,
                    onTap: _currentStep < 2
                        ? () {
                            // Validate before moving forward
                            if (_validateCurrentStep()) {
                              setState(() => _currentStep++);
                            }
                          }
                        : null,
                    isLeft: false,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Step indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isActive = index == _currentStep;
                  final isCompleted = index < _currentStep;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: isActive || isCompleted
                            ? AppGradients.primaryGradient
                            : null,
                        color: !isActive && !isCompleted
                            ? AppColors.inputBorder
                            : null,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback? onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: isEnabled ? AppGradients.primaryGradient : null,
          color: isEnabled ? null : AppColors.inputBorder.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : AppColors.textSecondary.withValues(alpha: 0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your name'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return false;
      }
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 1 || age > 120) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a valid age'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return false;
      }
    } else if (_currentStep == 1) {
      if (_selectedCity == null || _selectedCity!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your city'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _onContinue(UserProfileProvider provider) async {
    provider.clearError();

    // Validate current step
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 1 || age > 120) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid age')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedCity == null || _selectedCity!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your city')),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    // Final step - save profile
    bool success;
    if (widget.isEditing) {
      success = await provider.updateProfile(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        city: _selectedCity ?? '',
        region: _selectedRegion,
        lifestyleType: _selectedLifestyle,
      );
    } else {
      success = await provider.createProfile(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        city: _selectedCity ?? '',
        region: _selectedRegion,
        lifestyleType: _selectedLifestyle,
      );
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }
}
