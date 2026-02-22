
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../usage_data/providers/usage_data_provider.dart';
import '../../usage_data/models/usage_data_model.dart';
import '../../sensors/providers/sensor_data_provider.dart';
import '../../sensors/services/sensor_activity_detector.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Filter state
  int _selectedIndex = 0;
  final List<String> _filters = ['This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer2<UsageDataProvider, SensorDataProvider>(
            builder: (context, provider, sensorProvider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              // 1. Filter Data
              final filteredEntries = _filterEntries(provider.entries);
              
              // 2. Calculate Stats from Filtered Data
              final manualEmission = filteredEntries.fold(0.0, (sum, e) => sum + e.co2Emission);
              final sensorEmission = sensorProvider.dailyEstimatedEmission;
              final totalEmission = manualEmission + sensorEmission;
              final categoryStats = _calculateCategoryStats(filteredEntries);
              final dailyStats = _calculateDailyStats(filteredEntries);

              // Add today's sensor estimate to daily stats for trend chart
              final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
              final combinedDailyStats = Map<DateTime, double>.from(dailyStats);
              combinedDailyStats[today] = (combinedDailyStats[today] ?? 0) + sensorEmission;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Toggle
                    _buildFilterToggle(),
                    const SizedBox(height: 24),

                    // Total Summary Card (includes sensor + manual)
                    _buildSummaryCard(totalEmission),
                    const SizedBox(height: 32),

                    // Sensor Activity Details
                    const SectionHeader(title: 'Sensor Activity'),
                    _buildSensorActivityCard(sensorProvider),
                    const SizedBox(height: 32),

                    // Sensor Emission Breakdown
                    const SectionHeader(title: 'Emission Sources'),
                    _buildEmissionSourcesCard(manualEmission, sensorEmission, sensorProvider),
                    const SizedBox(height: 32),

                    // Category Distribution (Pie Chart) - always show, includes sensor
                    const SectionHeader(title: 'Distribution'),
                    _buildPieChartWithSensor(categoryStats, sensorEmission),
                    const SizedBox(height: 32),

                    // Emission Trend (Line Chart) - always shows with sensor data
                    const SectionHeader(title: 'Trend'),
                    _buildCombinedLineChart(combinedDailyStats, dailyStats, sensorEmission),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSensorActivityCard(SensorDataProvider sensorProvider) {
    final data = sensorProvider.currentData;
    final isActive = sensorProvider.isSensorActive;
    final hasPerms = sensorProvider.hasPermissions;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isActive ? const Color(0xFF2E7D32) : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                  color: isActive ? const Color(0xFF2E7D32) : Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'Sensors Active' : (hasPerms ? 'Sensors Paused' : 'Baseline Mode'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive
                          ? 'Detecting movement via accelerometer & GPS'
                          : (hasPerms
                              ? 'Sensor tracking is paused'
                              : 'Using India avg (4.7 kg CO₂/day) — grant location permission for live tracking'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live metrics row
          Row(
            children: [
              // Detected Activity
              Expanded(
                child: _buildSensorMetric(
                  sensorProvider.activityIcon,
                  data.detectedActivity.displayName,
                  _getActivityExplanation(data.detectedActivity),
                ),
              ),
              const SizedBox(width: 12),
              // Speed
              Expanded(
                child: _buildSensorMetric(
                  '⚡',
                  '${data.currentSpeed.toStringAsFixed(1)} km/h',
                  'Current speed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Session distance
              Expanded(
                child: _buildSensorMetric(
                  '📏',
                  '${data.sessionDistance.toStringAsFixed(2)} km',
                  'Session distance',
                ),
              ),
              const SizedBox(width: 12),
              // Confidence
              Expanded(
                child: _buildSensorMetric(
                  '🎯',
                  '${(data.confidence * 100).toStringAsFixed(0)}%',
                  'Detection confidence',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sensor emission breakdown bar
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Baseline: ${(data.dailyEstimatedEmission - data.sessionEmission).toStringAsFixed(2)} kg  •  Travel: ${data.sessionEmission.toStringAsFixed(2)} kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorMetric(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _getActivityExplanation(ActivityType activity) {
    switch (activity) {
      case ActivityType.stationary:
        return 'No physical movement detected';
      case ActivityType.walking:
        return 'Walking detected (0 emissions)';
      case ActivityType.cycling:
        return 'Cycling detected (0 emissions)';
      case ActivityType.vehicle:
        return 'Car/bus travel (~0.21 kg/km)';
      case ActivityType.train:
        return 'Train travel (~0.04 kg/km)';
    }
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

  // --- Logic Helpers ---

  List<UsageDataEntry> _filterEntries(List<UsageDataEntry> allEntries) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedIndex) {
      case 0: // This Week (Last 7 days)
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 1: // This Month (Last 30 days)
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 2: // This Year (Last 365 days)
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    // Filter and sort by date
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

  Map<DateTime, double> _calculateDailyStats(List<UsageDataEntry> entries) {
    final Map<DateTime, double> dailyTotals = {};
    for (var entry in entries) {
      // Normalize date to midnight
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyTotals[normalizedDate] = (dailyTotals[normalizedDate] ?? 0) + entry.co2Emission;
    }
    return dailyTotals;
  }

  // --- UI Builders ---

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

  Widget _buildSummaryCard(double totalEmission) {
    return GradientCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.co2_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                _filters[_selectedIndex],
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalEmission.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'kg CO₂',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartWithSensor(Map<UsageCategory, double> stats, double sensorEmission) {
    final total = stats.values.fold(0.0, (sum, v) => sum + v) + sensorEmission;
    
    if (total <= 0) {
      return const Center(child: Text("No emission data yet", style: AppTextStyles.bodyMedium));
    }

    final List<PieChartSectionData> sections = [];
    final List<MapEntry<String, Color>> legendItems = [];

    // Add sensor emission slice (always present)
    if (sensorEmission > 0) {
      final percentage = (sensorEmission / total) * 100;
      sections.add(PieChartSectionData(
        color: const Color(0xFF2E7D32),
        value: sensorEmission,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: _buildBadge('📡'),
        badgePositionPercentageOffset: 0.98,
      ));
      legendItems.add(const MapEntry('Sensor Estimated', Color(0xFF2E7D32)));
    }

    // Add manual log category slices
    for (final entry in stats.entries) {
      final percentage = (entry.value / total) * 100;
      final color = _getCategoryColor(entry.key);
      sections.add(PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: _buildBadge(entry.key.icon),
        badgePositionPercentageOffset: 0.98,
      ));
      legendItems.add(MapEntry(entry.key.displayName, color));
    }

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 4,
                startDegreeOffset: 180,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: legendItems.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: item.value, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(item.key, style: AppTextStyles.labelMedium),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
    );
  }

  Widget _buildCombinedLineChart(Map<DateTime, double> combinedStats, Map<DateTime, double> manualOnlyStats, double todaySensorEmission) {
    if (combinedStats.isEmpty) {
      return GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.show_chart_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Trend data will appear as sensor readings\nand log entries accumulate over days.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    // Sort dates
    final sortedDates = combinedStats.keys.toList()..sort();
    final combinedSpots = sortedDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), combinedStats[e.value]!);
    }).toList();

    // Manual-only line (to show contribution)
    final manualSpots = sortedDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), manualOnlyStats[e.value] ?? 0);
    }).toList();

    final maxY = combinedStats.values.reduce((curr, next) => curr > next ? curr : next);
    final interval = maxY > 0 ? maxY / 5 : 1.0;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                           if (_selectedIndex > 0 && index % 2 != 0) return const SizedBox.shrink();
                           final date = sortedDates[index];
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(
                               '${date.day}/${date.month}',
                               style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                             ),
                           );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                         return Text(
                           value.toInt().toString(),
                           style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                         );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (combinedSpots.length - 1).toDouble(),
                minY: 0,
                lineBarsData: [
                  // Combined line (sensor + manual)
                  LineChartBarData(
                    spots: combinedSpots,
                    isCurved: true,
                    color: const Color(0xFF2E7D32),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: combinedSpots.length < 15),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32).withValues(alpha: 0.2),
                          const Color(0xFF2E7D32).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Manual-only line
                  LineChartBarData(
                    spots: manualSpots,
                    isCurved: true,
                    color: AppColors.primaryBlue,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: manualSpots.length < 15),
                    dashArray: [6, 4],
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.15),
                          AppColors.primaryBlue.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1B5E20),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = sortedDates[spot.x.toInt()];
                        final isManual = spot.barIndex == 1;
                        return LineTooltipItem(
                          '${date.day}/${date.month}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${spot.y.toStringAsFixed(1)} kg ${isManual ? "(manual)" : "(total)"}',
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Chart legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 20, height: 3, decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text('Total (Sensor + Manual)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const SizedBox(width: 16),
              Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text('Manual Logs Only', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
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
