import 'package:flutter/material.dart';
import '../../../theme.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildMetricsRow(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: _buildLineChartCard()),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: _buildDonutChartCard()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: _buildBarChartCard()),
            const SizedBox(width: 24),
            Expanded(flex: 5, child: _buildProjectsTableCard()),
          ],
        ),
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
            Text('Analytics Dashboard', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text('Monitoring your organization\'s social impact and volunteer efficiency.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('Last 30 Days v'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text('Filter'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Export Report'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(child: _metricCard('Total Needs Met', '1,284', '+12.5%', true, Icons.check_circle_outline)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard('Volunteer Hours', '8,420', '+8.2%', true, Icons.schedule)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard('Active Volunteers', '452', '-2.4%', false, Icons.people_outline)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard('Impact Score', '94/100', '+5.1%', true, Icons.trending_up)),
      ],
    );
  }

  Widget _metricCard(String label, String value, String change, bool isPositive, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.backgroundLight, shape: BoxShape.circle), child: Icon(icon, color: AppTheme.primaryPurple, size: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isPositive ? AppTheme.primaryPurple : AppTheme.errorRed, borderRadius: BorderRadius.circular(12)),
                child: Text(change, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fulfillment Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Visualizing completed vs. pending needs monthly.', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 32),
          // Mock Line Chart representation
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
              ),
              child: const Center(child: Text('[Line Chart Placeholder: fl_chart or similar needed]', style: TextStyle(color: AppTheme.primaryPurple))),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppTheme.primaryPurple, 'Completed Needs'),
              const SizedBox(width: 24),
              _legendDot(const Color(0xFF00B4D8), 'Pending Tasks'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDonutChartCard() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills Utilization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Breakdown by volunteer expertise.', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 32),
          // Mock Donut Chart
          Expanded(
            child: Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryPurple, width: 24),
                ),
                child: Center(child: Container(decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle))),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _chartRow(AppTheme.primaryPurple, 'Teaching', '38%'),
          const SizedBox(height: 12),
          _chartRow(const Color(0xFF00B4D8), 'Medical', '29%'),
          const SizedBox(height: 12),
          _chartRow(AppTheme.textGrey, 'Logistics', '19%'),
          const SizedBox(height: 12),
          _chartRow(AppTheme.backgroundLight, 'Legal', '14%'),
        ],
      ),
    );
  }

  Widget _chartRow(Color c, String label, String pct) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
        ]),
        Text(pct, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Engagement Velocity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Daily volunteer hours tracked this week.', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(110, 'Mon'), _bar(140, 'Tue'), _bar(165, 'Wed'), _bar(135, 'Thu'), _bar(200, 'Fri'), _bar(80, 'Sat'), _bar(55, 'Sun'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bar(double height, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 40, height: height, decoration: BoxDecoration(color: AppTheme.primaryPurple, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildProjectsTableCard() {
    return Container(
      height: 350,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Impact Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Detailed drill-down of key initiatives.', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                  ],
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
          ),
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('PROJECT NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
                Expanded(flex: 1, child: Text('HOURS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
                Expanded(flex: 1, child: Text('IMPACT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _projRow('Downtown Literacy Program', '450h', 'Complete', 'High', AppTheme.primaryPurple),
                  _projRow('Mobile Vaccination Clinic', '1200h', 'Active', 'Critical', AppTheme.errorRed),
                  _projRow('Emergency Shelter Relief', '820h', 'Active', 'High', AppTheme.primaryPurple),
                  _projRow('Legal Aid Workshop', '120h', 'Complete', 'Medium', AppTheme.textDark),
                  _projRow('Community Garden Phase 2', '340h', 'Pending', 'Low', AppTheme.textGrey),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _projRow(String name, String hrs, String status, String impact, Color impactColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 1, child: Text(hrs, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(12)),
              child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(flex: 1, child: Text(impact, style: TextStyle(color: impactColor, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
      ],
    );
  }
}
