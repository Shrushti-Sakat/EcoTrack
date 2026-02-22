
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../features/usage_data/models/usage_data_model.dart';

class ReportService {
  Future<void> generateAndShareReport({
    required List<UsageDataEntry> entries,
    required String periodName,
    required double totalEmission,
    required Map<UsageCategory, double> categoryStats,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('MMM d, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(periodName, dateFormatter.format(now)),
            pw.SizedBox(height: 20),
            _buildSummarySection(totalEmission, entries.length),
            pw.SizedBox(height: 20),
            _buildCategoryTable(categoryStats),
            pw.SizedBox(height: 20),
            _buildRecentActivityList(entries),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    // Share the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ecotrack_report_${now.millisecondsSinceEpoch}.pdf',
    );
  }

  pw.Widget _buildHeader(String period, String date) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('EcoTrack', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text('Carbon Footprint Report', style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Period: $period', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Generated: $date', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection(double total, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Emissions', '${total.toStringAsFixed(1)} kg CO2'),
          _buildStatItem('Activities Logged', '$count'),
        ],
      ),
    );
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
      ],
    );
  }

  pw.Widget _buildCategoryTable(Map<UsageCategory, double> stats) {
    final data = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Emissions by Category', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Category', 'Emissions (kg)', 'Percentage'],
          data: data.map((e) {
            final total = stats.values.reduce((a, b) => a + b);
            final percentage = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
            return [e.key.displayName, e.value.toStringAsFixed(2), '$percentage%'];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue600),
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _buildRecentActivityList(List<UsageDataEntry> entries) {
    // Show last 10 entries details
    // Sort by date descending first
    final sorted = List<UsageDataEntry>.from(entries)..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(10).toList();
    final dateFormatter = DateFormat('MMM d');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Recent Activities (Top 10)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
         pw.Table.fromTextArray(
          headers: ['Date', 'Category', 'Activity', 'Value', 'CO2 (kg)'],
          data: recent.map((e) {
            return [
              dateFormatter.format(e.date),
              e.category.displayName,
              e.type.displayName,
              '${e.value} ${e.unit}',
              e.co2Emission.toStringAsFixed(2)
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          cellStyle: const pw.TextStyle(fontSize: 10),
          border: null,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100))),
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text('Generated by EcoTrack', style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10)),
    );
  }
}
