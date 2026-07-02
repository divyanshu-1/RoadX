import '../../models/challan_model.dart';
import '../models/analytics_models.dart';

/// Pure analytics calculations over challan lists (no Firebase I/O).
class AnalyticsService {
  List<ChallanModel> filterByTimeRange(
    List<ChallanModel> challans,
    AnalyticsTimeFilter filter, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    return challans.where((c) {
      final d = c.effectiveDate;
      switch (filter) {
        case AnalyticsTimeFilter.today:
          return _isSameDay(d, ref);
        case AnalyticsTimeFilter.thisWeek:
          final start = ref.subtract(Duration(days: ref.weekday - 1));
          final weekStart = DateTime(start.year, start.month, start.day);
          final weekEnd = weekStart.add(const Duration(days: 7));
          return !d.isBefore(weekStart) && d.isBefore(weekEnd);
        case AnalyticsTimeFilter.thisMonth:
          return d.year == ref.year && d.month == ref.month;
        case AnalyticsTimeFilter.thisYear:
          return d.year == ref.year;
      }
    }).toList();
  }

  List<ChallanModel> filterForReportPeriod(
    List<ChallanModel> challans,
    ReportPeriod period, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    switch (period) {
      case ReportPeriod.weekly:
        return filterByTimeRange(challans, AnalyticsTimeFilter.thisWeek, now: ref);
      case ReportPeriod.monthly:
        return filterByTimeRange(challans, AnalyticsTimeFilter.thisMonth, now: ref);
      case ReportPeriod.yearly:
        return filterByTimeRange(challans, AnalyticsTimeFilter.thisYear, now: ref);
    }
  }

  ChallanAnalyticsSummary summarize(List<ChallanModel> challans) {
    if (challans.isEmpty) return ChallanAnalyticsSummary.empty;

    var accepted = 0;
    var pending = 0;
    var paid = 0;
    var unpaid = 0;
    var collected = 0;
    var pendingAmount = 0;

    for (final c in challans) {
      if (c.isAccepted) {
        accepted++;
      } else {
        pending++;
      }
      if (c.isPaid) {
        paid++;
        collected += c.fineAmount;
      } else {
        unpaid++;
        pendingAmount += c.fineAmount;
      }
    }

    return ChallanAnalyticsSummary(
      totalGenerated: challans.length,
      totalAccepted: accepted,
      totalPending: pending,
      totalPaid: paid,
      totalUnpaid: unpaid,
      amountCollected: collected,
      amountPending: pendingAmount,
    );
  }

  /// Last [months] months of challan counts (oldest → newest).
  List<MonthlyChartPoint> monthlyChallanCounts(
    List<ChallanModel> challans, {
    int months = 6,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final buckets = _monthBuckets(months, ref);
    for (final c in challans) {
      final d = c.effectiveDate;
      final key = '${d.year}-${d.month}';
      final bucket = buckets[key];
      if (bucket != null) {
        buckets[key] = MonthlyChartPoint(
          year: bucket.year,
          month: bucket.month,
          challanCount: bucket.challanCount + 1,
          revenue: bucket.revenue,
        );
      }
    }
    return buckets.values.toList()
      ..sort((a, b) {
        if (a.year != b.year) return a.year.compareTo(b.year);
        return a.month.compareTo(b.month);
      });
  }

  List<MonthlyChartPoint> monthlyRevenue(
    List<ChallanModel> challans, {
    int months = 6,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final buckets = _monthBuckets(months, ref);
    for (final c in challans) {
      if (!c.isPaid) continue;
      final d = c.effectiveDate;
      final key = '${d.year}-${d.month}';
      final bucket = buckets[key];
      if (bucket != null) {
        buckets[key] = MonthlyChartPoint(
          year: bucket.year,
          month: bucket.month,
          challanCount: bucket.challanCount,
          revenue: bucket.revenue + c.fineAmount,
        );
      }
    }
    return buckets.values.toList()
      ..sort((a, b) {
        if (a.year != b.year) return a.year.compareTo(b.year);
        return a.month.compareTo(b.month);
      });
  }

  Map<String, int> paidUnpaidSplit(List<ChallanModel> challans) => {
        'paid': challans.where((c) => c.isPaid).length,
        'unpaid': challans.where((c) => c.isUnpaid).length,
      };

  Map<String, int> acceptedPendingSplit(List<ChallanModel> challans) => {
        'accepted': challans.where((c) => c.isAccepted).length,
        'pending': challans.where((c) => !c.isAccepted).length,
      };

  List<ChallanModel> searchByVehicle(
    List<ChallanModel> challans,
    String query,
  ) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) return challans;
    return challans
        .where((c) => c.vehicleNumber.toUpperCase().contains(q))
        .toList();
  }

  List<ChallanModel> recentChallans(
    List<ChallanModel> challans, {
    int limit = 15,
  }) {
    final sorted = List<ChallanModel>.from(challans)
      ..sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
    return sorted.take(limit).toList();
  }

  PeriodReport buildPeriodReport(
    List<ChallanModel> all,
    ReportPeriod period, {
    DateTime? now,
  }) {
    final filtered = filterForReportPeriod(all, period, now: now);
    final title = switch (period) {
      ReportPeriod.weekly => 'Weekly Report',
      ReportPeriod.monthly => 'Monthly Report',
      ReportPeriod.yearly => 'Yearly Report',
    };
    return PeriodReport(
      period: period,
      title: title,
      summary: summarize(filtered),
    );
  }

  Map<String, MonthlyChartPoint> _monthBuckets(int months, DateTime ref) {
    final map = <String, MonthlyChartPoint>{};
    for (var i = months - 1; i >= 0; i--) {
      final d = DateTime(ref.year, ref.month - i, 1);
      final year = d.year;
      final month = d.month;
      map['$year-$month'] = MonthlyChartPoint(year: year, month: month);
    }
    return map;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
