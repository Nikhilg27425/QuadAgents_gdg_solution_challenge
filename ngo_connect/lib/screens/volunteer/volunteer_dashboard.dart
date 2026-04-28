import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../screens/landing_page.dart';
import 'volunteer_profile_view.dart';
import 'explore_needs_view.dart';
import 'my_tasks_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../ngo/views/notifications_view.dart';
import '../ngo/views/chat_view.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 1;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await FirebaseService.getUserProfile(uid);
    if (mounted) {
      setState(() => _userName = profile?['name'] as String? ?? '');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    }
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return const _VolunteerOverviewView();
      case 1:
        return const ExploreNeedsView();
      case 2:
        return const MyTasksView();
      case 3:
        return const VolunteerProfileView();
      case 4:
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return NotificationsView(uid: uid);
      default:
        return const ExploreNeedsView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
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

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(right: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: AppTheme.primaryPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('NGO Connect',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _sidebarItem(Icons.search, 'Explore Needs', 1),
          _sidebarItem(Icons.assignment_outlined, 'My Tasks', 2),
          _sidebarItem(Icons.person_outline, 'My Profile', 3),
          _sidebarItem(Icons.notifications_none, 'Notifications', 4),
          const Spacer(),
          InkWell(
            onTap: _logout,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: AppTheme.errorRed, size: 20),
                  SizedBox(width: 12),
                  Text('Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: AppTheme.errorRed)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppTheme.borderGrey) : null,
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppTheme.primaryPurple : AppTheme.textDark,
                size: 20),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final displayName = _userName.isNotEmpty ? _userName : 'Volunteer';
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_none, color: AppTheme.textDark),
          const SizedBox(width: 8),
          const Text('Volunteer Portal',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(displayName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            radius: 18,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple overview widget shown on the Dashboard tab.
class _VolunteerOverviewView extends StatelessWidget {
  const _VolunteerOverviewView();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FutureBuilder<Map<String, dynamic>?>(
      future: uid != null ? FirebaseService.getUserProfile(uid) : null,
      builder: (context, profileSnap) {
        final name = profileSnap.data?['name'] as String? ?? 'Volunteer';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $name!',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            const Text("Here's a summary of your volunteer activity.",
                style: TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 32),
            if (uid != null) _buildLiveStats(uid),
          ],
        );
      },
    );
  }

  Widget _buildLiveStats(String uid) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchStats(uid),
      builder: (context, snap) {
        final stats = snap.data ?? {};
        return Row(
          children: [
            _statCard(context, Icons.assignment_outlined, AppTheme.primaryPurple,
                'Active Tasks', '${stats['activeTasks'] ?? 0}'),
            const SizedBox(width: 16),
            _statCard(context, Icons.check_circle_outline, AppTheme.successGreen,
                'Completed', '${stats['completed'] ?? 0}'),
            const SizedBox(width: 16),
            _statCard(context, Icons.star, AppTheme.warningOrange, 'Avg Rating',
                stats['avgRating'] != null
                    ? (stats['avgRating'] as double).toStringAsFixed(1)
                    : '—'),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchStats(String uid) async {
    final profile = await FirebaseService.getUserProfile(uid);
    final assignmentsSnap =
        await FirebaseService.getAssignmentsStream(volunteerId: uid).first;
    final docs = assignmentsSnap.docs;
    final active = docs
        .where((d) => !['closed', 'declined']
            .contains((d.data() as Map<String, dynamic>)['status']))
        .length;
    final completed = docs
        .where((d) =>
            (d.data() as Map<String, dynamic>)['status'] == 'closed')
        .length;
    return {
      'activeTasks': active,
      'completed': completed,
      'avgRating': (profile?['averageRating'] as num?)?.toDouble(),
    };
  }

  Widget _statCard(BuildContext context, IconData icon, Color color,
      String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat rooms list for volunteers.
class _VolunteerChatRoomsView extends StatefulWidget {
  const _VolunteerChatRoomsView();

  @override
  State<_VolunteerChatRoomsView> createState() => _VolunteerChatRoomsViewState();
}

class _VolunteerChatRoomsViewState extends State<_VolunteerChatRoomsView> {
  String? _selectedRoomId;
  String? _selectedRoomTitle;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    if (_selectedRoomId != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedRoomId = null),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to rooms'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: ChatView(
              taskId: _selectedRoomId!,
              taskTitle: _selectedRoomTitle ?? _selectedRoomId!,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Group Chats', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        const Text('Chat rooms for your assigned tasks.',
            style: TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where('participantIds', arrayContains: _uid)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final rooms = snap.data?.docs ?? [];
            if (rooms.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGrey)),
                child: const Column(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 48, color: AppTheme.textGrey),
                    SizedBox(height: 16),
                    Text('No chat rooms yet',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    SizedBox(height: 8),
                    Text(
                        'Accept a task to join its group chat.',
                        style: TextStyle(color: AppTheme.textGrey),
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final data = rooms[i].data() as Map<String, dynamic>;
                final roomId = rooms[i].id;
                final needId = data['needId'] as String? ?? roomId;
                return _RoomCard(
                  roomId: roomId,
                  needId: needId,
                  onTap: (title) => setState(() {
                    _selectedRoomId = roomId;
                    _selectedRoomTitle = title;
                  }),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String roomId;
  final String needId;
  final void Function(String title) onTap;

  const _RoomCard({required this.roomId, required this.needId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('needs').doc(needId).get(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final title = data?['title'] as String? ?? 'Task $needId';
        return InkWell(
          onTap: () => onTap(title),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group,
                      color: AppTheme.primaryPurple, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text('Tap to open chat',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textGrey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textGrey),
              ],
            ),
          ),
        );
      },
    );
  }
}
