import 'package:flutter/material.dart';
import '../../theme.dart';
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

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return const _VolunteerOverviewView();
      case 1:
        return const ExploreNeedsView();
      case 2:
        return const MyTasksView();
      case 3:
        return const _VolunteerChatRoomsView();
      case 4:
        return const VolunteerProfileView();
      case 5:
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
                  child: const Icon(Icons.show_chart,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('NGO Connect',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _sidebarItem(Icons.search, 'Explore Needs', 1),
          _sidebarItem(Icons.assignment_outlined, 'My Tasks', 2),
          _sidebarItem(Icons.chat_bubble_outline, 'Chat', 3),
          _sidebarItem(Icons.person_outline, 'My Profile', 4),
          _sidebarItem(Icons.notifications_none, 'Notifications', 5),
          const Spacer(),
          _sidebarItem(Icons.logout, 'Logout', 99,
              color: AppTheme.errorRed),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index,
      {Color? color}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 99) {
          FirebaseService.logout();
          return;
        }
        setState(() => _selectedIndex = index);
      },
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
                color: color ??
                    (isSelected
                        ? AppTheme.primaryPurple
                        : AppTheme.textDark),
                size: 20),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: color ?? AppTheme.textDark)),
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
          const Icon(Icons.notifications_none, color: AppTheme.textDark),
          const SizedBox(width: 8),
          const Text('Volunteer Portal',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            radius: 18,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          )
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back!',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        const Text('Here\'s a summary of your volunteer activity.',
            style: TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 32),
        if (uid != null) _buildLiveStats(uid),
      ],
    );
  }

  Widget _buildLiveStats(String uid) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchStats(uid),
      builder: (context, snap) {
        final stats = snap.data ?? {};
        return Row(
          children: [
            _statCard(context, Icons.assignment_outlined,
                AppTheme.primaryPurple, 'Active Tasks',
                '${stats['activeTasks'] ?? 0}'),
            const SizedBox(width: 16),
            _statCard(context, Icons.check_circle_outline,
                AppTheme.successGreen, 'Completed',
                '${stats['completed'] ?? 0}'),
            const SizedBox(width: 16),
            _statCard(context, Icons.star, AppTheme.warningOrange,
                'Avg Rating',
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
    final assignmentsSnap = await FirebaseService.getAssignmentsStream(
            volunteerId: uid)
        .first;
    final docs = assignmentsSnap.docs;
    final active = docs
        .where((d) =>
            !['closed', 'declined'].contains(
                (d.data() as Map<String, dynamic>)['status']))
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
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textGrey)),
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

/// Shows the volunteer's chat rooms (one per assigned task) and lets them
/// open a specific room's ChatView.
///
/// Requirements 8.1–8.5: lists chat rooms where the volunteer is a participant.
class _VolunteerChatRoomsView extends StatefulWidget {
  const _VolunteerChatRoomsView();

  @override
  State<_VolunteerChatRoomsView> createState() =>
      _VolunteerChatRoomsViewState();
}

class _VolunteerChatRoomsViewState extends State<_VolunteerChatRoomsView> {
  /// Currently selected room id, or null when showing the room list.
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
            onPressed: () =>
                setState(() => _selectedRoomId = null),
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
        Text('Group Chats',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        const Text('Chat rooms for your assigned tasks.',
            style: TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          // Query chat rooms where this volunteer is a participant.
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
              return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey)),
      child: Column(
        children: [
          const Icon(Icons.chat_bubble_outline,
              size: 48, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text('No chat rooms yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text(
              'Chat rooms are created when 2+ volunteers are assigned to the same task.',
              style: TextStyle(color: AppTheme.textGrey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// A card representing a single chat room, fetching the need title for display.
class _RoomCard extends StatelessWidget {
  final String roomId;
  final String needId;
  final void Function(String title) onTap;

  const _RoomCard({
    required this.roomId,
    required this.needId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('needs').doc(needId).get(),
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
                      Text('Room: $roomId',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textGrey),
                          overflow: TextOverflow.ellipsis),
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
