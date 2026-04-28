import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme.dart';
import '../../../services/firebase_service.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// AnalyticsView — live Firestore data with fl_chart charts, date range filter,
/// and CSV export.
/// Requirements 12.1, 12.2, 12.3, 12.4: all data from Supabase/Firestore,
/// no hardcoded values.
class AnalyticsView extends StatefulWidget {
  final String ngoId;
  const AnalyticsView({super.key, required this.ngoId});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isLoading = false;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final data =
        await FirebaseService.getNgoAnalytics(widget.ngoId);
    if (mounted) setState(() {
      _analytics = data;
      _isLoading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadAnalytics();
    }
  }

  Future<void> _exportCsv() async {
    final needs = await FirebaseFirestore.instance
        .collection('needs')
        .where('ngoId', isEqualTo: widget.ngoId)
        .get();

    final rows = <List<String>>[
      ['Title', 'Status', 'Urgency', 'Category', 'Deadline', 'Applicants'],
      ...needs.docs.map((doc) {
        final d = doc.data();
        return [
          d['title'] as String? ?? '',
          d['status'] as String? ?? '',
          d['urgency']?.toString() ?? '',
          d['category'] as String? ?? '',
          d['deadline'] as String? ?? '',
          d['applicantCount']?.toString() ?? '0',
        ];
      }),
    ];

    final csv = rows.map((r) => r.join(',')).join('\n');

    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'ngo_needs_export.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Downloaded ${rows.length - 1} rows as CSV.'),
          backgroundColor: AppTheme.successGreen,
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('CSV export is only available on web.'),
          backgroundColor: AppTheme.infoBlue,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          _buildMetricsRow(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildFulfillmentChart()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildStatusDonutChart()),
            ],
          ),
          const SizedBox(height: 24),
          _buildTopNeedsTable(context),
        ],
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics Dashboard',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            const Text(
                'Monitoring your organization\'s social impact.',
                style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                  '${_dateRange.start.day}/${_dateRange.start.month} – ${_dateRange.end.day}/${_dateRange.end.month}'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _exportCsv,
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Export CSV'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    final needsPosted = _analytics['needsPosted'] ?? 0;
    final openNeeds = _analytics['openNeeds'] ?? 0;
    final fulfilledNeeds = _analytics['fulfilledNeeds'] ?? 0;
    final activeVolunteers = _analytics['activeVolunteers'] ?? 0;

    return Row(
      children: [
        Expanded(
            child: _metricCard('Total Needs Posted', '$needsPosted',
                Icons.assignment_outlined, AppTheme.primaryPurple)),
        const SizedBox(width: 16),
        Expanded(
            child: _metricCard('Open Needs', '$openNeeds',
                Icons.pending_actions_outlined, AppTheme.infoBlue)),
        const SizedBox(width: 16),
        Expanded(
            child: _metricCard('Fulfilled Needs', '$fulfilledNeeds',
                Icons.check_circle_outline, AppTheme.successGreen)),
        const SizedBox(width: 16),
        Expanded(
            child: _metricCard('Active Volunteers', '$activeVolunteers',
                Icons.people_outline, AppTheme.warningOrange)),
      ],
    );
  }

  Widget _metricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildFulfillmentChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('needs')
          .where('ngoId', isEqualTo: widget.ngoId)
          .get(),
      builder: (context, snap) {
        // Build monthly counts from real data
        final Map<int, int> openByMonth = {};
        final Map<int, int> closedByMonth = {};

        if (snap.hasData) {
          for (final doc in snap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            final createdAt = d['createdAt'];
            if (createdAt is Timestamp) {
              final month = createdAt.toDate().month;
              final status = d['status'] as String? ?? 'open';
              if (status == 'open') {
                openByMonth[month] = (openByMonth[month] ?? 0) + 1;
              } else if (status == 'closed') {
                closedByMonth[month] =
                    (closedByMonth[month] ?? 0) + 1;
              }
            }
          }
        }

        final spots1 = List.generate(
            12,
            (i) => FlSpot(
                i.toDouble(), (openByMonth[i + 1] ?? 0).toDouble()));
        final spots2 = List.generate(
            12,
            (i) => FlSpot(
                i.toDouble(), (closedByMonth[i + 1] ?? 0).toDouble()));

        return Container(
          height: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrey)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fulfillment Trends',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Open vs. fulfilled needs by month.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textGrey)),
              const SizedBox(height: 24),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const months = [
                              'J', 'F', 'M', 'A', 'M', 'J',
                              'J', 'A', 'S', 'O', 'N', 'D'
                            ];
                            final idx = v.toInt();
                            if (idx < 0 || idx >= months.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(months[idx],
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textGrey));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textGrey)),
                          reservedSize: 28,
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots1,
                        isCurved: true,
                        color: AppTheme.primaryPurple,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryPurple
                                .withOpacity(0.08)),
                      ),
                      LineChartBarData(
                        spots: spots2,
                        isCurved: true,
                        color: AppTheme.successGreen,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.successGreen
                                .withOpacity(0.08)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(AppTheme.primaryPurple, 'Open'),
                  const SizedBox(width: 24),
                  _legendDot(AppTheme.successGreen, 'Fulfilled'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusDonutChart() {
    final needsPosted =
        (_analytics['needsPosted'] as int?) ?? 0;
    final openNeeds = (_analytics['openNeeds'] as int?) ?? 0;
    final fulfilledNeeds =
        (_analytics['fulfilledNeeds'] as int?) ?? 0;
    final inProgress =
        needsPosted - openNeeds - fulfilledNeeds;

    final sections = <PieChartSectionData>[];
    if (openNeeds > 0) {
      sections.add(PieChartSectionData(
          value: openNeeds.toDouble(),
          color: AppTheme.infoBlue,
          title: '$openNeeds',
          radius: 50,
          titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)));
    }
    if (fulfilledNeeds > 0) {
      sections.add(PieChartSectionData(
          value: fulfilledNeeds.toDouble(),
          color: AppTheme.successGreen,
          title: '$fulfilledNeeds',
          radius: 50,
          titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)));
    }
    if (inProgress > 0) {
      sections.add(PieChartSectionData(
          value: inProgress.toDouble(),
          color: AppTheme.warningOrange,
          title: '$inProgress',
          radius: 50,
          titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)));
    }
    if (sections.isEmpty) {
      sections.add(PieChartSectionData(
          value: 1,
          color: AppTheme.borderGrey,
          title: '',
          radius: 50));
    }

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Need Status',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Breakdown by status.',
              style:
                  TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            )),
          ),
          const SizedBox(height: 12),
          _chartRow(AppTheme.infoBlue, 'Open', '$openNeeds'),
          const SizedBox(height: 8),
          _chartRow(AppTheme.successGreen, 'Fulfilled',
              '$fulfilledNeeds'),
          const SizedBox(height: 8),
          _chartRow(AppTheme.warningOrange, 'In Progress',
              '${inProgress > 0 ? inProgress : 0}'),
        ],
      ),
    );
  }

  Widget _buildTopNeedsTable(BuildContext context) {
    final future = FirebaseFirestore.instance
        .collection('needs')
        .where('ngoId', isEqualTo: widget.ngoId)
        .get()
        .then((snap) {
      final sorted = List.of(snap.docs)
        ..sort((a, b) {
          final aC = (a.data() as Map)['applicantCount'] as int? ?? 0;
          final bC = (b.data() as Map)['applicantCount'] as int? ?? 0;
          return bC.compareTo(aC);
        });
      return sorted.take(5).toList();
    });

    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: future,
      builder: (context, snap) {
        final docs = snap.data ?? [];
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrey)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Top Needs by Applicants',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: const [
                    Expanded(
                        flex: 4,
                        child: Text('TITLE',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGrey))),
                    Expanded(
                        flex: 2,
                        child: Text('CATEGORY',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGrey))),
                    Expanded(
                        flex: 1,
                        child: Text('STATUS',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGrey))),
                    Expanded(
                        flex: 1,
                        child: Text('APPLICANTS',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGrey),
                            textAlign: TextAlign.right)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No needs yet.',
                      style: TextStyle(color: AppTheme.textGrey)),
                )
              else
                ...docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                                d['title'] as String? ?? '—',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13),
                                overflow: TextOverflow.ellipsis)),
                        Expanded(
                            flex: 2,
                            child: Text(
                                d['category'] as String? ?? '—',
                                style: const TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 13))),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppTheme.backgroundLight,
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: Text(
                                d['status'] as String? ?? '—',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Text(
                                '${d['applicantCount'] ?? 0}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                textAlign: TextAlign.right)),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color c, String text) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _chartRow(Color c, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textDark)),
        ]),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
