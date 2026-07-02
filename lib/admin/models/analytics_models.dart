/// Time-range filter for dashboard analytics.
enum AnalyticsTimeFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
}

/// Report aggregation window.
enum ReportPeriod {
  weekly,
  monthly,
  yearly,
}

/// Summary metrics for dashboard cards and reports.
class ChallanAnalyticsSummary {
  final int totalGenerated;
  final int totalAccepted;
  final int totalPending;
  final int totalPaid;
  final int totalUnpaid;
  final int amountCollected;
  final int amountPending;

  const ChallanAnalyticsSummary({
    this.totalGenerated = 0,
    this.totalAccepted = 0,
    this.totalPending = 0,
    this.totalPaid = 0,
    this.totalUnpaid = 0,
    this.amountCollected = 0,
    this.amountPending = 0,
  });

  static const empty = ChallanAnalyticsSummary();
}

/// One bucket in a monthly chart.
class MonthlyChartPoint {
  final int year;
  final int month;
  final int challanCount;
  final int revenue;

  const MonthlyChartPoint({
    required this.year,
    required this.month,
    this.challanCount = 0,
    this.revenue = 0,
  });

  String get label => '${_monthShort(month)} $year';

  static String _monthShort(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (m < 1 || m > 12) return '?';
    return names[m - 1];
  }
}

/// Period report for weekly / monthly / yearly sections.
class PeriodReport {
  final ReportPeriod period;
  final String title;
  final ChallanAnalyticsSummary summary;

  const PeriodReport({
    required this.period,
    required this.title,
    required this.summary,
  });
}
