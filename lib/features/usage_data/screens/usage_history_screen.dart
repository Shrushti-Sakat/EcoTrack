import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/usage_data_model.dart';
import '../providers/usage_data_provider.dart';
import '../../user_profile/providers/user_profile_provider.dart';

/// Usage History Screen - View logged activities
class UsageHistoryScreen extends StatefulWidget {
  const UsageHistoryScreen({super.key});

  @override
  State<UsageHistoryScreen> createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  UsageCategory? _filterCategory;
  String _timeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              Expanded(
                child: _buildEntryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              'Activity History',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Time filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildTimeFilterChip('All', 'all'),
              const SizedBox(width: 8),
              _buildTimeFilterChip('Today', 'today'),
              const SizedBox(width: 8),
              _buildTimeFilterChip('This Week', 'week'),
              const SizedBox(width: 8),
              _buildTimeFilterChip('This Month', 'month'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Category filter
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildCategoryFilterChip(null, 'All', Icons.grid_view_rounded),
              ...UsageCategory.values.map((category) {
                return _buildCategoryFilterChip(
                  category,
                  category.displayName,
                  _getCategoryIcon(category),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeFilterChip(String label, String value) {
    final isSelected = _timeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _timeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(
    UsageCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = _filterCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.inputBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.primaryBlue,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList() {
    return Consumer2<UsageDataProvider, UserProfileProvider>(
      builder: (context, usageProvider, profileProvider, _) {
        List<UsageDataEntry> entries = _getFilteredEntries(usageProvider);

        if (entries.isEmpty) {
          return EmptyState(
            icon: Icons.history_rounded,
            title: 'No Activities Yet',
            message: 'Start logging your daily activities to track your carbon footprint',
            actionText: 'Log Activity',
            onAction: () => Navigator.pushNamed(context, '/usage/add'),
          );
        }

        // Group entries by date
        final groupedEntries = _groupEntriesByDate(entries);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: groupedEntries.length,
          itemBuilder: (context, index) {
            final dateKey = groupedEntries.keys.elementAt(index);
            final dayEntries = groupedEntries[dateKey]!;
            final totalEmission = dayEntries.fold<double>(
              0,
              (sum, entry) => sum + entry.co2Emission,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(dateKey, totalEmission),
                ...dayEntries.map((entry) => _buildEntryCard(entry, usageProvider)),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  List<UsageDataEntry> _getFilteredEntries(UsageDataProvider provider) {
    List<UsageDataEntry> entries;

    switch (_timeFilter) {
      case 'today':
        entries = provider.todayEntries;
        break;
      case 'week':
        entries = provider.weekEntries;
        break;
      case 'month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        entries = provider.entries.where((e) => e.date.isAfter(startOfMonth)).toList();
        break;
      default:
        entries = provider.entries;
    }

    if (_filterCategory != null) {
      entries = entries.where((e) => e.category == _filterCategory).toList();
    }

    return entries;
  }

  Map<String, List<UsageDataEntry>> _groupEntriesByDate(
    List<UsageDataEntry> entries,
  ) {
    final Map<String, List<UsageDataEntry>> grouped = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final entry in entries) {
      final key = dateFormat.format(entry.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    return grouped;
  }

  Widget _buildDateHeader(String dateKey, double totalEmission) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateLabel;
    if (dateOnly == today) {
      dateLabel = 'Today';
    } else if (dateOnly == yesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('MMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            dateLabel,
            style: AppTextStyles.heading4,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${totalEmission.toStringAsFixed(2)} kg',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(UsageDataEntry entry, UsageDataProvider provider) {
    final color = _getCategoryColor(entry.category);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        final userId = context.read<UserProfileProvider>().currentProfile?.id;
        if (userId != null) {
          provider.deleteEntry(userId, entry.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  entry.category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.type.displayName,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.value.toStringAsFixed(1)} ${entry.unit}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.co2Emission.toStringAsFixed(2)} kg',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CO₂',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(UsageCategory category) {
    switch (category) {
      case UsageCategory.electricity:
        return Icons.bolt_rounded;
      case UsageCategory.fuel:
        return Icons.local_gas_station_rounded;
      case UsageCategory.travel:
        return Icons.directions_car_rounded;
      case UsageCategory.appliance:
        return Icons.tv_rounded;
      case UsageCategory.waste:
        return Icons.delete_outline_rounded;
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
}
