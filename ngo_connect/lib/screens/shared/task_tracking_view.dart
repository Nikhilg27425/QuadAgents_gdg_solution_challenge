import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme.dart';

class TaskTrackingView extends StatelessWidget {
  const TaskTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Task Tracking', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        const Text('Monitor all active volunteer assignments', style: TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColumn(context, 'Pending', Colors.orange, 'pending'),
            const SizedBox(width: 16),
            _buildColumn(context, 'Active', Colors.blue, 'active'),
            const SizedBox(width: 16),
            _buildColumn(context, 'Completed', Colors.green, 'completed'),
          ],
        ),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, String title, Color color, String status) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ]),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('status', isEqualTo: status)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const CircularProgressIndicator();
              final docs = snap.data!.docs;
              if (docs.isEmpty) return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderGrey)),
                child: const Text('No tasks', style: TextStyle(color: AppTheme.textGrey)),
              );
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderGrey),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need #${data['needId'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Volunteer: ${data['volunteerId']?.toString().substring(0, 8) ?? ''}...', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['appliedAt']?.toDate()?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                            if (status == 'pending')
                              TextButton(
                                onPressed: () => _updateStatus(doc.id, 'active'),
                                child: const Text('Accept', style: TextStyle(fontSize: 12)),
                              ),
                            if (status == 'active')
                              TextButton(
                                onPressed: () => _updateStatus(doc.id, 'completed'),
                                child: const Text('Mark Done', style: TextStyle(fontSize: 12, color: Colors.green)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateStatus(String docId, String newStatus) {
    FirebaseFirestore.instance.collection('applications').doc(docId).update({'status': newStatus});
  }
}