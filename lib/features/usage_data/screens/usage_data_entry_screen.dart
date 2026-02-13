import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/usage_data_model.dart';
import '../providers/usage_data_provider.dart';
import '../../user_profile/providers/user_profile_provider.dart';

/// Usage Data Entry Screen - Manual Data Entry Interface
class UsageDataEntryScreen extends StatefulWidget {
  const UsageDataEntryScreen({super.key});

  @override
  State<UsageDataEntryScreen> createState() => _UsageDataEntryScreenState();
}

class _UsageDataEntryScreenState extends State<UsageDataEntryScreen>
    with SingleTickerProviderStateMixin {
  UsageCategory _selectedCategory = UsageCategory.electricity;
  UsageType? _selectedType;
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  LoggingFrequency _frequency = LoggingFrequency.daily;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Set default type for initial category
    _selectedType = UsageType.getTypesForCategory(_selectedCategory).first;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
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
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFrequencySelector(),
                        const SizedBox(height: 24),
                        _buildDateSelector(),
                        const SizedBox(height: 24),
                        _buildCategorySelector(),
                        const SizedBox(height: 24),
                        _buildTypeSelector(),
                        const SizedBox(height: 24),
                        _buildValueInput(),
                        const SizedBox(height: 24),
                        _buildNotesInput(),
                        const SizedBox(height: 24),
                        _buildEmissionPreview(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
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
          ),
          const Expanded(
            child: Text(
              'Log Activity',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logging Frequency',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: LoggingFrequency.values.map((freq) {
            final isSelected = _frequency == freq;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _frequency = freq),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: freq == LoggingFrequency.daily ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.inputBorder,
                    ),
                    boxShadow: isSelected
                        ? AppShadows.buttonShadow
                        : AppShadows.softShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        freq == LoggingFrequency.daily
                            ? Icons.today_rounded
                            : Icons.date_range_rounded,
                        color: isSelected ? Colors.white : AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        freq.displayName,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: _selectDate,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_selectedDate),
                  style: AppTextStyles.heading4,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Category',
              style: AppTextStyles.labelLarge,
            ),
            const Spacer(),
            Text(
              _selectedCategory.displayName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: UsageCategory.values.length,
            itemBuilder: (context, index) {
              final category = UsageCategory.values[index];
              final isSelected = _selectedCategory == category;
              final color = _getCategoryColor(category);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _selectedType = UsageType.getTypesForCategory(category).first;
                    _valueController.clear();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : AppColors.inputBorder,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : AppShadows.softShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.displayName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = UsageType.getTypesForCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Type',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: types.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  _valueController.clear();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.inputBorder,
                  ),
                  boxShadow: isSelected
                      ? AppShadows.buttonShadow
                      : AppShadows.softShadow,
                ),
                child: Text(
                  type.displayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildValueInput() {
    final unit = _selectedType?.unit ?? 'units';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Value ($unit)',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _decrementValue(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: AppTextStyles.heading2.copyWith(
                      color: AppColors.textLight,
                    ),
                    suffix: Text(
                      unit,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                onPressed: () => _incrementValue(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getValueHint(),
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return CustomTextField(
      controller: _notesController,
      label: 'Notes (Optional)',
      hint: 'Add any additional details...',
      prefixIcon: Icons.notes_rounded,
      maxLines: 3,
    );
  }

  Widget _buildEmissionPreview() {
    final value = double.tryParse(_valueController.text) ?? 0;
    final emission = _selectedType != null
        ? _selectedType!.baseEmissionFactor * value
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: emission > 0
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor(_selectedCategory),
                  _getCategoryColor(_selectedCategory).withValues(alpha: 0.7),
                ],
              )
            : null,
        color: emission > 0 ? null : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: emission > 0
            ? [
                BoxShadow(
                  color: _getCategoryColor(_selectedCategory).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: emission > 0
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.textLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.eco_rounded,
              color: emission > 0 ? Colors.white : AppColors.textLight,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated CO₂ Emission',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: emission > 0
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      emission.toStringAsFixed(2),
                      style: AppTextStyles.heading2.copyWith(
                        color: emission > 0 ? Colors.white : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'kg CO₂',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: emission > 0
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer2<UsageDataProvider, UserProfileProvider>(
      builder: (context, usageProvider, profileProvider, _) {
        final hasValue = _valueController.text.isNotEmpty &&
            (double.tryParse(_valueController.text) ?? 0) > 0;

        return Column(
          children: [
            if (usageProvider.errorMessage != null)
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
                        usageProvider.errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            PrimaryButton(
              text: 'Log Activity',
              icon: Icons.add_task_rounded,
              isLoading: usageProvider.isLoading,
              onPressed: hasValue
                  ? () => _submitEntry(usageProvider, profileProvider)
                  : null,
            ),
          ],
        );
      },
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _incrementValue() {
    final current = double.tryParse(_valueController.text) ?? 0;
    _valueController.text = (current + 1).toStringAsFixed(
      _valueController.text.contains('.') ? 1 : 0,
    );
    setState(() {});
  }

  void _decrementValue() {
    final current = double.tryParse(_valueController.text) ?? 0;
    if (current > 0) {
      _valueController.text = (current - 1).toStringAsFixed(
        _valueController.text.contains('.') ? 1 : 0,
      );
      setState(() {});
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _getValueHint() {
    if (_selectedType == null) return '';
    
    switch (_selectedType!) {
      case UsageType.electricityGeneral:
        return 'Enter electricity consumed in kilowatt-hours (kWh)';
      case UsageType.petrol:
      case UsageType.diesel:
      case UsageType.lpg:
      case UsageType.cng:
        return 'Enter fuel consumed in liters';
      case UsageType.carPetrol:
      case UsageType.carDiesel:
      case UsageType.carElectric:
      case UsageType.motorcycle:
      case UsageType.bus:
      case UsageType.train:
      case UsageType.autoRickshaw:
      case UsageType.bicycle:
      case UsageType.walking:
        return 'Enter distance traveled in kilometers';
      case UsageType.airConditioner:
      case UsageType.heater:
      case UsageType.washingMachine:
      case UsageType.refrigerator:
      case UsageType.television:
      case UsageType.computer:
        return 'Enter usage duration in hours';
      case UsageType.generalWaste:
      case UsageType.recyclableWaste:
      case UsageType.organicWaste:
        return 'Enter waste weight in kilograms';
    }
  }

  Color _getCategoryColor(UsageCategory category) {
    switch (category) {
      case UsageCategory.electricity:
        return AppColors.electricityColor;
      case UsageCategory.fuel:
        return AppColors.fuelColor;
      case UsageCategory.travel:
        return AppColors.travelColor;
      case UsageCategory.appliance:
        return AppColors.applianceColor;
      case UsageCategory.waste:
        return AppColors.wasteColor;
    }
  }

  void _submitEntry(
    UsageDataProvider usageProvider,
    UserProfileProvider profileProvider,
  ) async {
    usageProvider.clearError();

    final userId = profileProvider.currentProfile?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a profile first')),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid value')),
      );
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an activity type')),
      );
      return;
    }

    final success = await usageProvider.addEntry(
      userId: userId,
      type: _selectedType!,
      value: value,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Activity logged successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
