import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme.dart';
import 'views/ngo_overview_view.dart';
import 'create_need_view.dart';
import 'views/needs_management_view.dart';
import 'views/kanban_board_view.dart';
import 'views/analytics_view.dart';
import 'views/notifications_view.dart';
import 'views/chat_view.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});

  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  int _selectedIndex = 0;

  final _navItems = const [
    _NavItem(Icons.dashboard_outlined, 'Overview', 0),
    _NavItem(Icons.add_circle_outline, 'Create Need', 1),
    _NavItem(Icons.list_alt_outlined, 'Manage Needs', 2),
    _NavItem(Icons.view_kanban_outlined, 'Task Board', 3),
    _NavItem(Icons.chat_bubble_outline, 'Chat', 4),
    _NavItem(Icons.bar_chart_outlined, 'Analytics', 5),
    _NavItem(Icons.notifications_outlined, 'Notifications', 6),
  ];

  Widget _buildCurrentView() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    switch (_selectedIndex) {
      case 0: return NgoOverviewView(ngoId: uid);
      case 1: return CreateNeedView(ngoId: uid);
      case 2: return NeedsManagementView(ngoId: uid);
      case 3: return KanbanBoardView(ngoId: uid);
      case 4: return _NgoChatRoomsView(ngoId: uid);
      case 5: return AnalyticsView(ngoId: uid);
      case 6: return NotificationsView(uid: uid);
      default: return NgoOverviewView(ngoId: uid);
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
                      padding: const EdgeInsets.all(32),
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
            padding: const EdgeInsets.all(24),
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
                Text(
                  'NGO Connect',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._navItems.map((item) => _sidebarItem(item)),
          const Spacer(),
          _sidebarItemRaw(
              Icons.settings_outlined, 'Settings', -1, color: null),
          _sidebarItemRaw(Icons.logout, 'Logout', -2,
              color: AppTheme.errorRed),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sidebarItem(_NavItem item) {
    final selected = _selectedIndex == item.index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = item.index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: AppTheme.borderGrey) : null,
          boxShadow: selected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
              : [],
        ),
        child: Row(
          children: [
            Icon(item.icon,
                color: selected ? AppTheme.primaryPurple : AppTheme.textDark,
                size: 20),
            const SizedBox(width: 12),
            Text(item.label,
                style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItemRaw(IconData icon, String label, int index,
      {Color? color}) {
    return InkWell(
      onTap: () async {
        if (index == -2) {
          await FirebaseAuth.instance.signOut();
          if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppTheme.textDark, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
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
          Text(
            _navItems
                .firstWhere((n) => n.index == _selectedIndex,
                    orElse: () => _navItems.first)
                .label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            radius: 18,
            child: Icon(Icons.business, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  const _NavItem(this.icon, this.label, this.index);
}

/// NGO Chat Rooms — lists all chat rooms for this NGO's needs.
class _NgoChatRoomsView extends StatefulWidget {
  final String ngoId;
  const _NgoChatRoomsView({required this.ngoId});

  @override
  State<_NgoChatRoomsView> createState() => _NgoChatRoomsViewState();
}

class _NgoChatRoomsViewState extends State<_NgoChatRoomsView> {
  String? _selectedRoomId;
  String? _selectedRoomTitle;

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
        Text('Chat Rooms', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        const Text('Chat with volunteers assigned to your needs.',
            style: TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where('participantIds', arrayContains: widget.ngoId)
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
                child: const Column(children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text('No chat rooms yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Chat rooms are created when volunteers accept your tasks.',
                      style: TextStyle(color: AppTheme.textGrey),
                      textAlign: TextAlign.center),
                ]),
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
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('needs').doc(needId).get(),
                  builder: (context, snap) {
                    final d = snap.data?.data() as Map<String, dynamic>?;
                    final title = d?['title'] as String? ?? 'Task $needId';
                    return InkWell(
                      onTap: () => setState(() {
                        _selectedRoomId = roomId;
                        _selectedRoomTitle = title;
                      }),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderGrey),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.group,
                                color: AppTheme.primaryPurple, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                        ]),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
