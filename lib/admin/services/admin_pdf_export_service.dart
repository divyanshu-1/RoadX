import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/analytics_models.dart';

/// Generates and shares PDF analytics reports.
class AdminPdfExportService {
  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  Future<void> shareReport({
    required ChallanAnalyticsSummary summary,
    required String title,
    required String filterLabel,
    required DateTime generatedAt,
  }) async {
    final doc = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(generatedAt);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'RoadX — $title',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Generated: $dateStr'),
          pw.Text('Filter: $filterLabel'),
          pw.Divider(),
          pw.SizedBox(height: 16),
          _row('Total Challans', '${summary.totalGenerated}'),
          _row('Accepted', '${summary.totalAccepted}'),
          _row('Pending', '${summary.totalPending}'),
          _row('Paid', '${summary.totalPaid}'),
          _row('Unpaid', '${summary.totalUnpaid}'),
          _row('Revenue Collected', _currency.format(summary.amountCollected)),
          _row('Pending Revenue', _currency.format(summary.amountPending)),
          pw.Spacer(),
          pw.Text(
            'RoadX Traffic Management — Confidential',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 14)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
