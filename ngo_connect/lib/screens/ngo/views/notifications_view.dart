import 'package:flutter/material.dart';
import '../../../theme.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Notifications', style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryPurple, borderRadius: BorderRadius.circular(16)),
                      child: const Text('2 New', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('Stay updated on volunteer activity, task progress, and system alerts.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all read'),
                ),
                const SizedBox(width: 16),
                IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
              ],
            )
          ],
        ),
        const SizedBox(height: 32),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _tab('All Activity', true),
                const SizedBox(width: 16),
                _tab('Unread', false),
                const SizedBox(width: 16),
                _tab('Critical Updates', false),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text('Filters'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Column(
            children: [
              _notificationRow(
                iconData: Icons.person_add_alt_1,
                title: 'New Volunteer Application',
                body: 'David Chen has applied for the "Lead Web Developer" position for your project: Social Impact Hub Rebuild.',
                time: '12 mins ago',
                isUnread: true,
                hasActions: true,
              ),
              const Divider(height: 1),
              _notificationRow(
                iconData: Icons.emoji_events_outlined,
                title: 'Milestone Completed',
                body: 'The "Market Research Phase" for the Youth Mentorship Program has been marked as complete by Sarah Jenkins.',
                time: '2 hours ago',
                isUnread: true,
                hasActions: true,
              ),
              const Divider(height: 1),
              _notificationRow(
                iconData: Icons.chat_bubble_outline,
                title: 'New Message from Alex',
                body: '"Hey there! I just uploaded the draft for the fundraising proposal. Let me know what you think when you have a moment."',
                time: '5 hours ago',
                isUnread: false,
                hasActions: false,
              ),
              const Divider(height: 1),
              _notificationRow(
                iconData: Icons.data_usage,
                title: 'Profile Engagement Update',
                body: 'Your NGO profile was viewed by 15 potential volunteers this week! That\'s a 25% increase from last week.',
                time: 'Yesterday',
                isUnread: false,
                hasActions: false,
              ),
              const Divider(height: 1),
              _notificationRow(
                iconData: Icons.person_search_outlined,
                title: 'Volunteer Match Found',
                body: 'We found a high-probability match: Elena Rodriguez has the "UX Design" skills you need for "The Green Path" project.',
                time: '2 days ago',
                isUnread: false,
                hasActions: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Showing 5 notifications', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Notification Settings', style: TextStyle(color: AppTheme.textDark))),
                const SizedBox(width: 16),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.textDark), label: const Text('Clear History', style: TextStyle(color: AppTheme.textDark))),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget _tab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? AppTheme.primaryPurple : AppTheme.textDark)),
    );
  }

  Widget _notificationRow({required IconData iconData, required String title, required String body, required String time, required bool isUnread, required bool hasActions}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 8, height: 8,
            decoration: BoxDecoration(color: isUnread ? AppTheme.primaryPurple : Colors.transparent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: AppTheme.backgroundLight,
            radius: 20,
            child: Icon(iconData, color: AppTheme.textDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(color: AppTheme.textDark, fontSize: 13, height: 1.4)),
                if (hasActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                        child: const Row(
                          children: [
                            Text('Go to Task', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Icon(Icons.open_in_new, size: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), side: BorderSide.none, backgroundColor: AppTheme.backgroundLight),
                        child: const Text('Review Application', style: TextStyle(fontSize: 12, color: AppTheme.textDark)),
                      ),
                      const SizedBox(width: 12),
                      if (isUnread)
                        TextButton(onPressed: () {}, child: const Text('Mark Read', style: TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.bold))),
                    ],
                  )
                ]
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(time, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
