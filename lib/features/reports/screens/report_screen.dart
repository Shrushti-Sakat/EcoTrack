
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../usage_data/providers/usage_data_provider.dart';
import '../../usage_data/models/usage_data_model.dart';
import '../../../services/report_service.dart';
import '../../sensors/providers/sensor_data_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedIndex = 0;
  final List<String> _filters = ['This Week', 'This Month', 'This Year'];
  final ReportService _reportService = ReportService();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGenerating ? Icons.hourglass_top_rounded : Icons.ios_share_rounded, color: AppColors.primaryBlue),
            onPressed: _isGenerating ? null : _exportReport,
            tooltip: 'Export PDF',
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer2<UsageDataProvider, SensorDataProvider>(
            builder: (context, provider, sensorProvider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
              }

              // Filter Data
              final filteredEntries = _filterEntries(provider.entries);
              final manualEmission = filteredEntries.fold(0.0, (sum, e) => sum + e.co2Emission);
              final sensorEmission = sensorProvider.dailyEstimatedEmission;
              final totalEmission = manualEmission + sensorEmission;
              final categoryStats = _calculateCategoryStats(filteredEntries);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterToggle(),
                    const SizedBox(height: 24),
                    
                    const Text('Summary', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    _buildSummaryCard(totalEmission, filteredEntries.length),
                    const SizedBox(height: 32),

                    // Sensor Activity Summary
                    const Text('Sensor Activity', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    _buildSensorSummaryCard(sensorProvider),
                    const SizedBox(height: 32),

                    // Emission Sources Breakdown
                    const Text('Emission Sources', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    _buildEmissionSourcesCard(manualEmission, sensorEmission, sensorProvider),
                    const SizedBox(height: 32),

                    // Category Breakdown (always show, include sensor categories)
                    const Text('Category Breakdown', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    _buildCategoryListWithSensor(categoryStats, sensorProvider, totalEmission),
                    const SizedBox(height: 32),
                    
                    // Trend Analysis (always show, include sensor data)
                    const Text('Trend Analysis', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    Text(
                      _generateTrendTextWithSensor(filteredEntries, sensorProvider),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmissionSourcesCard(double manualEmission, double sensorEmission, SensorDataProvider sensorProvider) {
    final total = manualEmission + sensorEmission;
    final sensorPercent = total > 0 ? (sensorEmission / total * 100) : 100.0;
    final manualPercent = total > 0 ? (manualEmission / total * 100) : 0.0;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  if (sensorPercent > 0)
                    Expanded(
                      flex: sensorPercent.round().clamp(1, 100),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: sensorPercent > 15
                            ? Text('${sensorPercent.toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                            : null,
                      ),
                    ),
                  if (manualPercent > 0)
                    Expanded(
                      flex: manualPercent.round().clamp(1, 100),
                      child: Container(
                        color: AppColors.primaryBlue,
                        alignment: Alignment.center,
                        child: manualPercent > 15
                            ? Text('${manualPercent.toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sensor row
          Row(
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sensor Estimated', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('${sensorProvider.statusText} • Auto-detected',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text('${sensorEmission.toStringAsFixed(2)} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E7D32))),
            ],
          ),
          const SizedBox(height: 12),

          // Manual row
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manual Logged', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('From your activity logs', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text('${manualEmission.toStringAsFixed(2)} kg',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimated', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text('${total.toStringAsFixed(2)} kg CO₂',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport() async {
    final provider = Provider.of<UsageDataProvider>(context, listen: false);
    final filteredEntries = _filterEntries(provider.entries);
    
    if (filteredEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export for this period')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final totalEmission = filteredEntries.fold(0.0, (sum, e) => sum + e.co2Emission);
      final categoryStats = _calculateCategoryStats(filteredEntries);

      await _reportService.generateAndShareReport(
        entries: filteredEntries,
        periodName: _filters[_selectedIndex],
        totalEmission: totalEmission,
        categoryStats: categoryStats,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  // Reuse logic from Analytics (could be refactored into a shared helper)
  List<UsageDataEntry> _filterEntries(List<UsageDataEntry> allEntries) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedIndex) {
      case 0: startDate = now.subtract(const Duration(days: 7)); break;
      case 1: startDate = now.subtract(const Duration(days: 30)); break;
      case 2: startDate = now.subtract(const Duration(days: 365)); break;
      default: startDate = now.subtract(const Duration(days: 7));
    }

    final filtered = allEntries.where((e) => e.date.isAfter(startDate)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  Map<UsageCategory, double> _calculateCategoryStats(List<UsageDataEntry> entries) {
    final Map<UsageCategory, double> stats = {};
    for (var entry in entries) {
      stats[entry.category] = (stats[entry.category] ?? 0) + entry.co2Emission;
    }
    return stats;
  }
  
  String _generateTrendTextWithSensor(List<UsageDataEntry> entries, SensorDataProvider sensorProvider) {
    final data = sensorProvider.currentData;
    final sensorEmission = sensorProvider.dailyEstimatedEmission;
    final sessionEmission = data.sessionEmission;
    final baselineEmission = sensorEmission - sessionEmission;
    final hasPerms = sensorProvider.hasPermissions;

    final lines = <String>[];

    // Manual entries trend
    if (entries.length >= 2) {
      final mid = entries.length ~/ 2;
      final firstHalf = entries.sublist(0, mid);
      final secondHalf = entries.sublist(mid);
      final firstSum = firstHalf.fold(0.0, (s, e) => s + e.co2Emission);
      final secondSum = secondHalf.fold(0.0, (s, e) => s + e.co2Emission);

      if (secondSum > firstSum) {
        lines.add('\u2022 Manual logs: Trending upwards. Review your ${_findTopCategory(secondHalf)} usage.');
      } else if (secondSum < firstSum) {
        lines.add('\u2022 Manual logs: Trending downwards \u2014 great job!');
      } else {
        lines.add('\u2022 Manual logs: Stable emissions over this period.');
      }
    } else if (entries.isEmpty) {
      lines.add('\u2022 Manual logs: No entries logged yet. Start logging activities for detailed tracking.');
    } else {
      lines.add('\u2022 Manual logs: Only 1 entry \u2014 log more for trend analysis.');
    }

    // Sensor data insight
    if (hasPerms) {
      lines.add('\u2022 Sensor: Today\'s baseline is ${baselineEmission.toStringAsFixed(2)} kg CO\u2082, with ${sessionEmission.toStringAsFixed(2)} kg from detected travel (${data.detectedActivity.displayName}).');
    } else {
      lines.add('\u2022 Sensor: Using estimated daily average (${sensorEmission.toStringAsFixed(2)} kg CO\u2082). Grant location permission for real-time tracking.');
    }

    // Activity-specific insight
    if (sessionEmission > 0.5) {
      lines.add('\u2022 Tip: Your detected travel is adding significant emissions. Consider walking or cycling for short distances.');
    } else if (hasPerms && sessionEmission == 0) {
      lines.add('\u2022 Tip: No travel emissions detected today \u2014 keep it up!');
    }

    return lines.join('\n\n');
  }
  
  String _findTopCategory(List<UsageDataEntry> entries) {
    if (entries.isEmpty) return "activity";
    final stats = _calculateCategoryStats(entries);
    final top = stats.entries.reduce((a, b) => a.value > b.value ? a : b);
    return top.key.displayName.toLowerCase();
  }

  // UI Components

  Widget _buildFilterToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? AppShadows.buttonShadow : null,
                ),
                child: Text(
                  _filters[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(double totalEmission, int count) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text('Total Emission', style: AppTextStyles.bodyMedium),
               const SizedBox(height: 8),
               Text(
                 '${totalEmission.toStringAsFixed(1)} kg',
                 style: AppTextStyles.heading2.copyWith(color: AppColors.primaryBlue),
               ),
            ],
          ),
          Container(
            height: 50,
            width: 1,
            color: AppColors.divider,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text('Activities', style: AppTextStyles.bodyMedium),
               const SizedBox(height: 8),
               Text(
                 '$count',
                 style: AppTextStyles.heading2,
               ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(UsageCategory category) {
    switch (category) {
      case UsageCategory.electricity: return AppColors.electricityColor;
      case UsageCategory.fuel: return AppColors.fuelColor;
      case UsageCategory.travel: return AppColors.travelColor;
      case UsageCategory.appliance: return AppColors.applianceColor;
      case UsageCategory.waste: return AppColors.wasteColor;
    }
  }

  Widget _buildSensorSummaryCard(SensorDataProvider sensorProvider) {
    final data = sensorProvider.currentData;
    final isActive = sensorProvider.isSensorActive;
    final hasPerms = sensorProvider.hasPermissions;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                color: isActive ? const Color(0xFF2E7D32) : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isActive ? 'Live Tracking Active' : (hasPerms ? 'Sensors Paused' : 'Baseline Mode'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Activity details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activity', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(
                      '${data.detectedActivity.icon} ${data.detectedActivity.displayName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Speed', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(
                      '${data.currentSpeed.toStringAsFixed(1)} km/h',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(
                      '${data.sessionDistance.toStringAsFixed(2)} km',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isActive
                ? 'Sensors are actively detecting your movement and estimating emissions from travel.'
                : (hasPerms
                    ? 'Sensor tracking is currently paused.'
                    : 'Using India\'s average daily household emission (4.7 kg CO\u2082/person/day) scaled to time of day. Grant location permission in Settings for real-time sensor-based tracking.'),
            style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListWithSensor(Map<UsageCategory, double> stats, SensorDataProvider sensorProvider, double totalFromAll) {
    final sensorData = sensorProvider.currentData;
    final baselineEmission = sensorData.dailyEstimatedEmission - sensorData.sessionEmission;
    final travelEmission = sensorData.sessionEmission;

    // Build list of all categories (sensor + manual)
    final List<_CategoryItem> items = [];

    // Add sensor categories
    if (baselineEmission > 0) {
      items.add(_CategoryItem(
        name: 'Sensor — Daily Baseline',
        value: baselineEmission,
        color: const Color(0xFF2E7D32),
        icon: '\ud83c\udfe0',
      ));
    }
    if (travelEmission > 0) {
      items.add(_CategoryItem(
        name: 'Sensor — Detected Travel',
        value: travelEmission,
        color: const Color(0xFF66BB6A),
        icon: sensorProvider.activityIcon,
      ));
    }

    // Add manual categories
    for (final entry in stats.entries) {
      items.add(_CategoryItem(
        name: entry.key.displayName,
        value: entry.value,
        color: _getCategoryColor(entry.key),
        icon: entry.key.icon,
      ));
    }

    // Sort by value descending
    items.sort((a, b) => b.value.compareTo(a.value));

    if (items.isEmpty) {
      return GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(20),
        child: Text(
          'No emission data yet. Log activities or enable sensor tracking.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final total = items.fold(0.0, (s, e) => s + e.value);

    return Column(
      children: items.map((item) {
        final percentage = total > 0 ? (item.value / total * 100) : 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.name, style: AppTextStyles.bodyMedium),
              ),
              Text(
                '${item.value.toStringAsFixed(2)} kg',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '(${percentage.toStringAsFixed(0)}%)',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryItem {
  final String name;
  final double value;
  final Color color;
  final String icon;

  _CategoryItem({required this.name, required this.value, required this.color, required this.icon});
}
