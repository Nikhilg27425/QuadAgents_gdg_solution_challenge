import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme.dart';
import '../../../services/firebase_service.dart';
import '../../../utils/validators.dart';
import '../../../models/need_card.dart';

/// NeedsManagementView — list, edit, and publish needs from Firestore stream.
/// Requirements 3.3, 6.4: sorted by urgency desc / deadline asc; live data.
class NeedsManagementView extends StatefulWidget {
  final String ngoId;
  const NeedsManagementView({super.key, required this.ngoId});

  @override
  State<NeedsManagementView> createState() => _NeedsManagementViewState();
}

class _NeedsManagementViewState extends State<NeedsManagementView> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildFilterBar(),
        const SizedBox(height: 16),
        _buildNeedsList(),
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
            Text('Manage Needs',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            const Text('View, edit, and manage all your posted needs.',
                style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    const statuses = ['all', 'open', 'in-progress', 'closed'];
    return Row(
      children: statuses.map((s) {
        final selected = _filterStatus == s;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _filterStatus = s),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryPurple
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? AppTheme.primaryPurple
                        : AppTheme.borderGrey),
              ),
              child: Text(
                s == 'all' ? 'All' : _capitalize(s),
                style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNeedsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getNeedsStream(ngoId: widget.ngoId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Text('Error: ${snap.error}',
              style: const TextStyle(color: AppTheme.errorRed));
        }

        final allDocs = snap.data?.docs ?? [];

        // Build NeedCard list and apply sort (Requirement 3.3)
        final needs = allDocs.map((doc) {
          final d = doc.data() as Map<String, dynamic>;
          return NeedCard.fromMap(doc.id, d);
        }).toList();

        final sorted = sortNeeds(needs);

        // Apply status filter
        final filtered = _filterStatus == 'all'
            ? sorted
            : sorted.where((n) => n.status == _filterStatus).toList();

        if (filtered.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGrey)),
            child: const Center(
              child: Text('No needs found.',
                  style: TextStyle(color: AppTheme.textGrey)),
            ),
          );
        }

        return Column(
          children: filtered
              .map((need) => _needCard(context, need))
              .toList(),
        );
      },
    );
  }

  Widget _needCard(BuildContext context, NeedCard need) {
    final urgencyColor = _urgencyColor(need.urgency);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(need.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _statusBadge(need.status),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('Urgency ${need.urgency}',
                    style: TextStyle(
                        color: urgencyColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(need.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textGrey, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(need.location,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textGrey)),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                  '${need.deadline.day}/${need.deadline.month}/${need.deadline.year}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textGrey)),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline,
                  size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text('${need.applicantCount} applicants',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textGrey)),
            ],
          ),
          if (need.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: need.skills
                  .take(5)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(s,
                            style: const TextStyle(fontSize: 11)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(context, need),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit',
                    style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10)),
              ),
              const SizedBox(width: 8),
              if (need.status == 'open')
                OutlinedButton.icon(
                  onPressed: () => _closeNeed(need.id),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close',
                      style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      foregroundColor: AppTheme.errorRed),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _closeNeed(String needId) async {
    await FirebaseService.updateNeed(needId, {'status': 'closed'});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need closed.')),
      );
    }
  }

  void _showEditDialog(BuildContext context, NeedCard need) {
    final titleCtrl = TextEditingController(text: need.title);
    final descCtrl = TextEditingController(text: need.description);
    String urgency = need.urgency.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Need'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: titleCtrl),
              const SizedBox(height: 16),
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, maxLines: 3),
              const SizedBox(height: 16),
              const Text('Urgency (1–5)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx2, setInner) =>
                    DropdownButtonFormField<String>(
                  value: urgency,
                  items: ['1', '2', '3', '4', '5']
                      .map((u) => DropdownMenuItem(
                          value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setInner(() => urgency = v!),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseService.updateNeed(need.id, {
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'urgency': int.tryParse(urgency) ?? need.urgency,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Need updated.'),
                      backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(int urgency) {
    if (urgency >= 4) return AppTheme.errorRed;
    if (urgency == 3) return AppTheme.warningOrange;
    return AppTheme.successGreen;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return AppTheme.infoBlue;
      case 'in-progress':
        return AppTheme.warningOrange;
      case 'closed':
        return AppTheme.successGreen;
      default:
        return AppTheme.textGrey;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
