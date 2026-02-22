
import '../models/carbon_entry.dart';

class DailyCarbonStats {
  final DateTime date;
  final double totalEmission;

  DailyCarbonStats(this.date, this.totalEmission);
}

class AnalyticsService {
  /// Calculates daily total carbon emissions from a list of entries.
  /// Returns a list of DailyCarbonStats sorted by date.
  List<DailyCarbonStats> calculateDailyEmissions(List<CarbonEntry> entries) {
    if (entries.isEmpty) {
      return [];
    }

    final Map<DateTime, double> dailyTotals = {};

    for (var entry in entries) {
      try {
        // Parse the date string into a DateTime object
        DateTime date = DateTime.parse(entry.date);
        
        // Normalize date to remove time component (set to midnight) for grouping
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);

        if (dailyTotals.containsKey(normalizedDate)) {
          dailyTotals[normalizedDate] = dailyTotals[normalizedDate]! + entry.carbonValue;
        } else {
          dailyTotals[normalizedDate] = entry.carbonValue;
        }
      } catch (e) {
        // Skip entries with invalid dates
        // In a real app, you might log this or handle it differently
        continue;
      }
    }

    // Convert map to list of DailyCarbonStats objects
    List<DailyCarbonStats> result = dailyTotals.entries.map((entry) {
      return DailyCarbonStats(entry.key, entry.value);
    }).toList();

    // Sort by date ascending to ensure line chart draws correctly
    result.sort((a, b) => a.date.compareTo(b.date));

    return result;
  }
}
