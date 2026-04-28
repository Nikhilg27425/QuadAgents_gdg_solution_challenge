import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme.dart';
import '../../../services/firebase_service.dart';

/// NotificationsView — live Firestore notification stream with mark-as-read.
/// Requirements 11.1–11.5.
class NotificationsView extends StatelessWidget {
  final String uid;
  const NotificationsView({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 32),
        _buildNotificationsList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getNotificationsStream(uid),
      builder: (context, snap) {
        final unread = (snap.data?.docs ?? [])
            .where((d) => !(d['read'] as bool? ?? false))
            .length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Notifications',
                        style:
                            Theme.of(context).textTheme.displayMedium),
                    const SizedBox(width: 16),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppTheme.primaryPurple,
                            borderRadius: BorderRadius.circular(16)),
                        child: Text('$unread New',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                    'Stay updated on volunteer activity and task progress.',
                    style: TextStyle(color: AppTheme.textGrey)),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => _markAllRead(snap.data?.docs ?? []),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getNotificationsStream(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGrey)),
            child: const Center(
              child: Text('No notifications yet.',
                  style: TextStyle(color: AppTheme.textGrey)),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrey)),
          child: Column(
            children: docs.asMap().entries.map((entry) {
              final i = entry.key;
              final doc = entry.value;
              final d = doc.data() as Map<String, dynamic>;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1),
                  _notificationRow(context, doc.id, d),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _notificationRow(BuildContext context, String docId,
      Map<String, dynamic> d) {
    final isUnread = !(d['read'] as bool? ?? false);
    final type = d['type'] as String? ?? 'assignment';
    final title = d['title'] as String? ?? 'Notification';
    final body = d['body'] as String? ?? '';
    final createdAt = d['createdAt'];
    String timeStr = '—';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours}h ago';
      } else {
        timeStr = '${diff.inDays}d ago';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: isUnread
                    ? AppTheme.primaryPurple
                    : Colors.transparent,
                shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: AppTheme.backgroundLight,
            radius: 20,
            child: Icon(_iconForType(type),
                color: AppTheme.textDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(body,
                    style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 13,
                        height: 1.4)),
                if (isUnread) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        FirebaseService.markNotificationRead(docId),
                    child: const Text('Mark Read',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
                if (type == 'rating_prompt') ...[
                  const SizedBox(height: 8),
                  _RateFromNotificationButton(
                    assignmentId: d['relatedId'] as String? ?? '',
                    notificationId: docId,
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 12, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(timeStr,
                  style: const TextStyle(
                      color: AppTheme.textGrey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _markAllRead(List<QueryDocumentSnapshot> docs) async {
    for (final doc in docs) {
      final isRead = (doc.data() as Map<String, dynamic>)['read']
              as bool? ??
          false;
      if (!isRead) {
        await FirebaseService.markNotificationRead(doc.id);
      }
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'match_invite':
        return Icons.person_search_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'status_change':
        return Icons.update_outlined;
      case 'rating_prompt':
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}

/// Rate volunteer button shown on rating_prompt notifications.
class _RateFromNotificationButton extends StatefulWidget {
  final String assignmentId;
  final String notificationId;
  const _RateFromNotificationButton({
    required this.assignmentId,
    required this.notificationId,
  });

  @override
  State<_RateFromNotificationButton> createState() =>
      _RateFromNotificationButtonState();
}

class _RateFromNotificationButtonState
    extends State<_RateFromNotificationButton> {
  bool _rated = false;

  Future<void> _showRatingDialog() async {
    if (_rated) return;

    // Fetch assignment to get volunteerId and ngoId
    final doc = await FirebaseFirestore.instance
        .collection('task_assignments')
        .doc(widget.assignmentId)
        .get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final volunteerId = data['volunteerId'] as String? ?? '';
    final ngoId = data['ngoId'] as String? ?? '';

    // Fetch volunteer name
    final vDoc = await FirebaseFirestore.instance
        .collection('users').doc(volunteerId).get();
    final volunteerName = (vDoc.data() as Map<String, dynamic>?)?['name'] as String? ?? volunteerId;

    int selectedStars = 5;
    final commentCtrl = TextEditingController();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rate Volunteer'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Volunteer: $volunteerName',
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () => setInner(() => selectedStars = star),
                      child: Icon(
                        star <= selectedStars ? Icons.star : Icons.star_border,
                        color: AppTheme.warningOrange,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a comment (optional)…',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseService.submitRating({
                  'volunteerId': volunteerId,
                  'ngoId': ngoId,
                  'assignmentId': widget.assignmentId,
                  'stars': selectedStars,
                  'comment': commentCtrl.text.trim(),
                });
                await FirebaseService.markNotificationRead(widget.notificationId);
                if (mounted) {
                  setState(() => _rated = true);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Rated $volunteerName: $selectedStars ⭐'),
                    backgroundColor: AppTheme.successGreen,
                  ));
                }
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_rated) {
      return const Text('✓ Rated', style: TextStyle(color: AppTheme.successGreen, fontSize: 12));
    }
    return ElevatedButton.icon(
      onPressed: _showRatingDialog,
      icon: const Icon(Icons.star, size: 14),
      label: const Text('Rate Volunteer', style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: AppTheme.warningOrange),
    );
  }
}
