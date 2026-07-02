import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_indicator.dart';
import 'charts/monthly_challan_bar_chart.dart';
import 'charts/monthly_revenue_line_chart.dart';
import 'charts/paid_unpaid_pie_chart.dart';
import 'charts/status_doughnut_chart.dart';
import 'models/analytics_models.dart';
import 'providers/admin_dashboard_provider.dart';
import 'widgets/admin_glass_panel.dart';
import 'widgets/analytics_filter_bar.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/recent_challans_table.dart';
import 'widgets/report_summary_panel.dart';

/// Admin analytics & reporting — realtime challan stats, charts, PDF export.
class AdminAnalyticsDashboard extends StatelessWidget {
  const AdminAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading && admin.allChallans.isEmpty) {
          return const Center(
            child: AppLoadingIndicator(color: Color(0xFF4FC3F7)),
          );
        }

        if (admin.error != null && admin.allChallans.isEmpty) {
          return _ErrorView(message: admin.error!, onRetry: admin.refresh);
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: admin.refresh,
            color: const Color(0xFF4FC3F7),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _Header(admin: admin)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 24 : 16,
                        vertical: 8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: wide
                            ? _WideLayout(admin: admin)
                            : _NarrowLayout(admin: admin),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final AdminDashboardProvider admin;

  const _Header({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics & Reports',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live challan statistics from Firebase Realtime Database',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              if (admin.isRefreshing)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4FC3F7),
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: admin.refresh,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Export PDF',
                onPressed: () => admin.exportPdfReport(),
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnalyticsFilterBar(
            selected: admin.timeFilter,
            onChanged: admin.setTimeFilter,
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: admin.setVehicleSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search vehicle number...',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final AdminDashboardProvider admin;

  const _NarrowLayout({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryGrid(admin: admin, crossAxisCount: 2),
        const SizedBox(height: 20),
        _ChartsSection(admin: admin),
        const SizedBox(height: 20),
        _ReportsSection(admin: admin),
        const SizedBox(height: 20),
        _RecentSection(admin: admin),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  final AdminDashboardProvider admin;

  const _WideLayout({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _SummaryGrid(admin: admin, crossAxisCount: 4),
              const SizedBox(height: 20),
              _ChartsSection(admin: admin),
              const SizedBox(height: 20),
              _RecentSection(admin: admin),
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 300,
          child: _ReportsSection(admin: admin, vertical: true),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final AdminDashboardProvider admin;
  final int crossAxisCount;

  const _SummaryGrid({required this.admin, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final s = admin.summary;
    final currency = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');

    final cards = [
      _card('Total Generated', '${s.totalGenerated}', Icons.receipt_long_rounded,
          [const Color(0xFF4FC3F7), const Color(0xFF0288D1)], 0),
      _card('Accepted', '${s.totalAccepted}', Icons.check_circle_outline,
          [const Color(0xFF6366F1), const Color(0xFF4F46E5)], 1),
      _card('Pending', '${s.totalPending}', Icons.hourglass_empty_rounded,
          [const Color(0xFFF59E0B), const Color(0xFFD97706)], 2),
      _card('Paid', '${s.totalPaid}', Icons.payments_outlined,
          [const Color(0xFF10B981), const Color(0xFF059669)], 3),
      _card('Unpaid', '${s.totalUnpaid}', Icons.money_off_csred_rounded,
          [const Color(0xFFEF4444), const Color(0xFFDC2626)], 4),
      _card(
        'Collected',
        currency.format(s.amountCollected),
        Icons.account_balance_wallet_outlined,
        [const Color(0xFF14B8A6), const Color(0xFF0D9488)],
        5,
      ),
      _card(
        'Pending Amount',
        currency.format(s.amountPending),
        Icons.pending_actions_rounded,
        [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        6,
      ),
      _card(
        'All-time Total',
        '${admin.fullSummary.totalGenerated}',
        Icons.analytics_outlined,
        [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        7,
      ),
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: crossAxisCount >= 4 ? 1.35 : 1.1,
      children: cards,
    );
  }

  Widget _card(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
    int index,
  ) {
    return DashboardStatCard(
      title: title,
      value: value,
      icon: icon,
      gradientColors: colors,
      animationIndex: index,
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final AdminDashboardProvider admin;

  const _ChartsSection({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminGlassPanel(
          title: 'Monthly Challan Report',
          child: MonthlyChallanBarChart(points: admin.monthlyChallanPoints),
        ),
        const SizedBox(height: 16),
        AdminGlassPanel(
          title: 'Monthly Revenue',
          child: MonthlyRevenueLineChart(points: admin.monthlyRevenuePoints),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final sideBySide = c.maxWidth > 500;
            final pieRow = sideBySide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AdminGlassPanel(
                          title: 'Paid vs Unpaid',
                          child: PaidUnpaidPieChart(split: admin.paidUnpaidSplit),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AdminGlassPanel(
                          title: 'Accepted vs Pending',
                          child: StatusDoughnutChart(
                            split: admin.acceptedPendingSplit,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      AdminGlassPanel(
                        title: 'Paid vs Unpaid',
                        child: PaidUnpaidPieChart(split: admin.paidUnpaidSplit),
                      ),
                      const SizedBox(height: 16),
                      AdminGlassPanel(
                        title: 'Accepted vs Pending',
                        child: StatusDoughnutChart(
                          split: admin.acceptedPendingSplit,
                        ),
                      ),
                    ],
                  );
            return pieRow;
          },
        ),
      ],
    );
  }
}

class _ReportsSection extends StatelessWidget {
  final AdminDashboardProvider admin;
  final bool vertical;

  const _ReportsSection({required this.admin, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    return AdminGlassPanel(
      title: 'Reports',
      trailing: SegmentedButton<ReportPeriod>(
        segments: const [
          ButtonSegment(
            value: ReportPeriod.weekly,
            label: Text('Week', style: TextStyle(fontSize: 11)),
          ),
          ButtonSegment(
            value: ReportPeriod.monthly,
            label: Text('Month', style: TextStyle(fontSize: 11)),
          ),
          ButtonSegment(
            value: ReportPeriod.yearly,
            label: Text('Year', style: TextStyle(fontSize: 11)),
          ),
        ],
        selected: {admin.reportPeriod},
        onSelectionChanged: (s) => admin.setReportPeriod(s.first),
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      child: vertical
          ? Column(
              children: admin.allReports
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReportSummaryPanel(
                        report: r,
                        isSelected: r.period == admin.reportPeriod,
                        onTap: () => admin.setReportPeriod(r.period),
                      ),
                    ),
                  )
                  .toList(),
            )
          : Column(
              children: admin.allReports
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReportSummaryPanel(
                        report: r,
                        isSelected: r.period == admin.reportPeriod,
                        onTap: () => admin.setReportPeriod(r.period),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  final AdminDashboardProvider admin;

  const _RecentSection({required this.admin});

  @override
  Widget build(BuildContext context) {
    return AdminGlassPanel(
      title: 'Recent Challans',
      child: RecentChallansTable(challans: admin.recentChallans),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
