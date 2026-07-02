import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../models/challan_model.dart';
import '../../services/challan_service.dart';
import '../../services/firebase_service.dart';
import '../models/analytics_models.dart';
import '../services/admin_pdf_export_service.dart';
import '../services/analytics_service.dart';

/// Realtime admin analytics state — single RTDB stream, derived metrics.
class AdminDashboardProvider extends ChangeNotifier {
  final ChallanService _challanService = ChallanService();
  final AnalyticsService _analytics = AnalyticsService();
  final AdminPdfExportService _pdf = AdminPdfExportService();

  List<ChallanModel> _allChallans = [];
  AnalyticsTimeFilter _timeFilter = AnalyticsTimeFilter.thisMonth;
  ReportPeriod _reportPeriod = ReportPeriod.monthly;
  String _vehicleSearch = '';
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  StreamSubscription<List<ChallanModel>>? _sub;

  List<ChallanModel> get allChallans => List.unmodifiable(_allChallans);
  AnalyticsTimeFilter get timeFilter => _timeFilter;
  ReportPeriod get reportPeriod => _reportPeriod;
  String get vehicleSearch => _vehicleSearch;
  bool get isLoading => _loading;
  bool get isRefreshing => _refreshing;
  String? get error => _error;

  List<ChallanModel> get filteredChallans =>
      _analytics.filterByTimeRange(_allChallans, _timeFilter);

  List<ChallanModel> get displayChallans {
    var list = filteredChallans;
    if (_vehicleSearch.trim().isNotEmpty) {
      list = _analytics.searchByVehicle(list, _vehicleSearch);
    }
    return list;
  }

  ChallanAnalyticsSummary get summary =>
      _analytics.summarize(filteredChallans);

  ChallanAnalyticsSummary get fullSummary =>
      _analytics.summarize(_allChallans);

  List<MonthlyChartPoint> get monthlyChallanPoints =>
      _analytics.monthlyChallanCounts(_allChallans);

  List<MonthlyChartPoint> get monthlyRevenuePoints =>
      _analytics.monthlyRevenue(_allChallans);

  Map<String, int> get paidUnpaidSplit =>
      _analytics.paidUnpaidSplit(filteredChallans);

  Map<String, int> get acceptedPendingSplit =>
      _analytics.acceptedPendingSplit(filteredChallans);

  PeriodReport get activeReport =>
      _analytics.buildPeriodReport(_allChallans, _reportPeriod);

  List<PeriodReport> get allReports => [
        _analytics.buildPeriodReport(_allChallans, ReportPeriod.weekly),
        _analytics.buildPeriodReport(_allChallans, ReportPeriod.monthly),
        _analytics.buildPeriodReport(_allChallans, ReportPeriod.yearly),
      ];

  List<ChallanModel> get recentChallans =>
      _analytics.recentChallans(displayChallans);

  void startListening() {
    if (_sub != null) return;
    _loading = true;
    notifyListeners();

    _sub = _challanService.watchChallans().listen(
      (data) {
        _allChallans = data;
        _error = null;
        _loading = false;
        _refreshing = false;
        notifyListeners();
      },
      onError: (e) {
        _error = FirebaseService.friendlyError(e);
        _loading = false;
        _refreshing = false;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    _refreshing = true;
    notifyListeners();
    try {
      _allChallans = await _challanService.fetchChallansOnce();
      _error = null;
    } catch (e) {
      _error = FirebaseService.friendlyError(e);
    } finally {
      _refreshing = false;
      _loading = false;
      notifyListeners();
    }
  }

  void setTimeFilter(AnalyticsTimeFilter filter) {
    if (_timeFilter == filter) return;
    _timeFilter = filter;
    notifyListeners();
  }

  void setReportPeriod(ReportPeriod period) {
    if (_reportPeriod == period) return;
    _reportPeriod = period;
    notifyListeners();
  }

  void setVehicleSearch(String query) {
    if (_vehicleSearch == query) return;
    _vehicleSearch = query;
    notifyListeners();
  }

  Future<void> exportPdfReport() async {
    await _pdf.shareReport(
      summary: activeReport.summary,
      title: activeReport.title,
      filterLabel: _filterLabel(_timeFilter),
      generatedAt: DateTime.now(),
    );
  }

  String _filterLabel(AnalyticsTimeFilter f) => switch (f) {
        AnalyticsTimeFilter.today => 'Today',
        AnalyticsTimeFilter.thisWeek => 'This Week',
        AnalyticsTimeFilter.thisMonth => 'This Month',
        AnalyticsTimeFilter.thisYear => 'This Year',
      };

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
