import 'package:flutter/material.dart';
import '../../theme.dart';
import 'views/analytics_view.dart';
import 'views/chat_view.dart';
import 'views/notifications_view.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});

  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  int _selectedIndex = 0;
  bool _showNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Sidebar
          _buildSidebar(),
          
          // Main Body
          Expanded(
            child: Column(
              children: [
                // Top Search/Profile Bar
                _buildTopBar(),
                
                // Scrollable Content
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundLight,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildCurrentView(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_showNotifications) {
      return const NotificationsView();
    }
    switch (_selectedIndex) {
      case 0:
        return _buildHomeView();
      case 2:
        return const ChatView();
      case 3:
        return const AnalyticsView();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildHomeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPageHeader(),
        const SizedBox(height: 24),
        _buildTopStatCards(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: _buildNeedsManagement()),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: _buildRightSidePanels()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildDocumentHub()),
            const SizedBox(width: 24),
            Expanded(flex: 4, child: _buildBottomRightPanels()),
          ],
        )
      ],
    );
  }

  // --- Layout Components ---

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(right: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Column(
        children: [
          // Theme Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppTheme.primaryPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('NGO Connect', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _sidebarItem(Icons.add_circle_outline, 'Create Need', 1),
          _sidebarItem(Icons.chat_bubble_outline, 'Chat', 2),
          _sidebarItem(Icons.bar_chart_outlined, 'Analytics', 3),
          const Spacer(),
          _sidebarItem(Icons.settings_outlined, 'Settings', 4),
          _sidebarItem(Icons.logout, 'Logout', 5, color: AppTheme.errorRed),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index, {Color? color}) {
    bool isSelected = _selectedIndex == index && !_showNotifications;
    return InkWell(
      onTap: () => setState(() {
        _selectedIndex = index;
        _showNotifications = false;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppTheme.borderGrey) : null,
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? (isSelected ? AppTheme.primaryPurple : AppTheme.textDark), size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: color ?? AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.textDark),
            onPressed: () => setState(() => _showNotifications = true),
          ),
          const SizedBox(width: 8),
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
          if (_showNotifications) ...[
            const SizedBox(width: 8),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryPurple, shape: BoxShape.circle)),
          ],
          const Spacer(),
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryPurple)),
                filled: true,
                fillColor: AppTheme.backgroundLight,
              ),
            ),
          ),
          const SizedBox(width: 24),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            radius: 18,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NGO Dashboard', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text('Manage your initiatives and track organizational impact.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history, size: 18),
              label: const Text('View History'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create New Need'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTopStatCards() {
    return Row(
      children: [
        Expanded(child: _statCard('NEEDS MET', '128', 'Total successfully completed tasks', Icons.check_circle_outline, AppTheme.successGreen, '+12% this month')),
        const SizedBox(width: 16),
        Expanded(child: _statCard('ACTIVE TASKS', '14', 'Needs currently in progress', Icons.assignment_outlined, AppTheme.infoBlue, null)),
        const SizedBox(width: 16),
        Expanded(child: _statCard('TOTAL VOLUNTEERS', '2,450', 'Engaged community members', Icons.people_outline, AppTheme.primaryPurple, '+5% growth')),
        const SizedBox(width: 16),
        Expanded(child: _statCard('IMPACT RATING', '4.9', 'Based on volunteer feedback', Icons.star_border, AppTheme.warningOrange, null)),
      ],
    );
  }

  Widget _statCard(String title, String value, String sub, IconData icon, Color iconColor, String? badge) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 24)),
              if (badge != null) Text(badge, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildNeedsManagement() {
    return Container(
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
                    Text('Needs Management', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    const Text('Monitor and manage your open volunteer opportunities.', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Title & Category', style: _tableHeaderStyle())),
                Expanded(flex: 1, child: Text('Status', style: _tableHeaderStyle())),
                Expanded(flex: 1, child: Text('Priority', style: _tableHeaderStyle())),
                Expanded(flex: 2, child: Text('Fulfillment', style: _tableHeaderStyle())),
                const SizedBox(width: 48, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Rows
          _needRow('Weekend Food Drive', 'Logistics', 'Active', 'High', 8, 12),
          const Divider(height: 1),
          _needRow('Community Literacy Program', 'Education', 'In Progress', 'Medium', 15, 15),
          const Divider(height: 1),
          _needRow('Senior Tech Workshop', 'Skill Sharing', 'Open', 'Low', 2, 5),
          const Divider(height: 1),
          _needRow('Urban Reforestation Project', 'Environment', 'Completed', 'Medium', 45, 40), // 113%
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Showing 5 of 24 initiatives', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                TextButton(onPressed: () {}, child: const Text('View All Needs')),
              ],
            ),
          )
        ],
      ),
    );
  }

  TextStyle _tableHeaderStyle() => const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey);

  Widget _needRow(String title, String cat, String status, String priority, int joined, int total) {
    Color statusColor = status == 'Active' ? AppTheme.successGreen : (status == 'Open' ? AppTheme.primaryPurple : AppTheme.textDark);
    Color priorityColor = priority == 'High' ? AppTheme.errorRed : AppTheme.textDark;
    double progress = (joined / total).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(cat, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: statusColor.withOpacity(0.3))),
              child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor), textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(priority, style: TextStyle(fontWeight: FontWeight.bold, color: priorityColor, fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.backgroundLight,
                    color: AppTheme.primaryPurple,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(width: 48, child: IconButton(icon: const Icon(Icons.more_vert, size: 20), onPressed: () {})),
        ],
      ),
    );
  }

  Widget _buildRightSidePanels() {
    return Column(
      children: [
        // Recent Applications
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, color: AppTheme.primaryPurple, size: 20),
                  const SizedBox(width: 8),
                  Text('Recent Applications', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Stay updated on new volunteer interest.', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
              const SizedBox(height: 24),
              _appRow('Sarah Jenkins', 'Applied for: Weekend Food Drive', '2h ago'),
              _appRow('Michael Chen', 'Applied for: Senior Tech Workshop', '5h ago'),
              _appRow('Elena Rodriguez', 'Applied for: Urban Reforestation', 'Yesterday'),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Manage Assignments'))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Goal Progress Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.star_border, color: Colors.white)),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monthly Goal Progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('1,240 Hours', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Current Impact', style: TextStyle(color: Colors.white, fontSize: 12)),
                Text('82% of Goal', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: 0.82, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 6, borderRadius: BorderRadius.circular(3)),
              const SizedBox(height: 16),
              const Text('You are 210 hours ahead of last month. Keep up the amazing work supporting the community!', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
            ],
          ),
        )
      ],
    );
  }

  Widget _appRow(String name, String detail, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: AppTheme.borderGrey, child: Icon(Icons.person, size: 16, color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(detail, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildDocumentHub() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document Hub', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          const Text('Upload reports, impact surveys, and logistical documents.', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
          const SizedBox(height: 24),
          
          // Dropzone
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey, style: BorderStyle.solid, width: 2), // dashed normally
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryPurple, size: 40),
                const SizedBox(height: 16),
                const Text('Click or drag files to upload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('PDF, XLSX, DOCX up to 10MB', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text('RECENT UPLOADS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          _docRow('Q1 Impact Report.pdf', 'REPORT • 2.4 MB', 'Mar 15, 2024'),
          _docRow('Volunteer Satisfaction Survey.xlsx', 'SURVEY • 1.1 MB', 'Mar 10, 2024'),
          _docRow('Safety Guidelines 2024.pdf', 'LEGAL • 840 KB', 'Feb 28, 2024'),
        ],
      ),
    );
  }

  Widget _docRow(String title, String meta, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey)
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, color: AppTheme.textGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(meta, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(width: 16),
          const Icon(Icons.open_in_new, size: 16, color: AppTheme.textGrey),
        ],
      ),
    );
  }

  Widget _buildBottomRightPanels() {
    return Column(
      children: [
        // Did you know tips
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Did you know?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Detailed descriptions increase volunteer application rates by up to 45%. Try adding specific skill tags and a clear timeline to your next "Need" creation.', style: TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.5)),
              const SizedBox(height: 16),
              Text('Learn more engagement tips →', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Upcoming Milestones
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Upcoming Milestones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('3 Actions Needed', style: TextStyle(color: AppTheme.primaryPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _milestoneRow('Quarterly Impact Review', 'April 2nd', 'Upcoming', AppTheme.primaryPurple),
              _milestoneRow('Volunteer Appreciation Gala', 'May 15th', 'Planning', AppTheme.primaryPurple),
              _milestoneRow('System Maintenance', 'Tonight', 'Alert', AppTheme.primaryPurple),
            ],
          ),
        )
      ],
    );
  }

  Widget _milestoneRow(String title, String date, String status, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
          ),
          Text(status, style: TextStyle(fontSize: 11, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
