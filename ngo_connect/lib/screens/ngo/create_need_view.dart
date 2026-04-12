import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/firebase_service.dart';
import '../../services/matching_service.dart';
import '../../services/geocoding_service.dart';

/// CreateNeedView — need card creation form with AI extraction and geocoding.
/// Requirements: 3.1, 3.2, 3.4, 3.6, 10.4
class CreateNeedView extends StatefulWidget {
  final String ngoId;

  const CreateNeedView({super.key, required this.ngoId});

  @override
  State<CreateNeedView> createState() => _CreateNeedViewState();
}

class _CreateNeedViewState extends State<CreateNeedView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _aiTextController = TextEditingController();

  bool _isSaving = false;
  bool _isExtracting = false;
  String _urgency = 'Medium';
  String _category = 'Technology';
  List<String> _selectedSkills = [];
  double _lat = 0.0;
  double _lng = 0.0;
  bool _coordsResolved = false;

  final Map<String, List<String>> _skillsByCategory = {
    'Technology': ['Flutter', 'Firebase', 'UI/UX', 'Python', 'JavaScript'],
    'Education': ['Teaching', 'Special Needs', 'Adult Literacy', 'STEM'],
    'Environment': ['Conservation', 'Solar Energy', 'Environmental Science', 'Gardening'],
    'Medical': ['First Aid', 'Nursing', 'Mental Health', 'Counseling'],
    'Legal': ['Legal Aid', 'Advocacy', 'Paralegal', 'Human Rights'],
    'Community': ['Food Distribution', 'Fundraising', 'Event Organization'],
  };

  List<String> get _currentSkills => _skillsByCategory[_category] ?? [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _deadlineController.dispose();
    _aiTextController.dispose();
    super.dispose();
  }

  // ── AI extraction ──────────────────────────────────────────────────────────

  Future<void> _extractFromAI() async {
    final text = _aiTextController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste some survey or report text first.')),
      );
      return;
    }
    setState(() => _isExtracting = true);
    try {
      final results = await MatchingService.extractNeedsFromText(text);
      if (results.isNotEmpty && mounted) {
        final first = results.first;
        setState(() {
          _titleController.text = first['title'] as String? ?? '';
          _descController.text = first['description'] as String? ?? '';
          _locationController.text = first['location'] as String? ?? '';
          _coordsResolved = false;
          final rawSkills = first['skills'];
          if (rawSkills is List) {
            _selectedSkills = rawSkills.map((s) => s.toString()).toList();
          }
          final rawUrgency = first['urgency'];
          if (rawUrgency != null) _urgency = rawUrgency.toString();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fields pre-populated from AI extraction.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No needs found in the provided text.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI extraction failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExtracting = false);
    }
  }

  // ── Geocode location ───────────────────────────────────────────────────────

  Future<void> _resolveLocation() async {
    final address = _locationController.text.trim();
    if (address.isEmpty) return;
    final geo = await GeocodingService.geocodeAddress(address);
    if (geo != null && mounted) {
      setState(() {
        _lat = geo.lat;
        _lng = geo.lng;
        _coordsResolved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location resolved: ${geo.lat.toStringAsFixed(4)}, ${geo.lng.toStringAsFixed(4)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      setState(() => _coordsResolved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address not found — enter a more specific address.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submitNeed() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and description.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    if (!_coordsResolved) {
      await _resolveLocation();
    }

    try {
      final needId = await FirebaseService.createNeed({
        'ngoId': widget.ngoId,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'lat': _lat,
        'lng': _lng,
        'deadline': _deadlineController.text.trim(),
        'urgency': _urgencyToInt(_urgency),
        'category': _category,
        'skills': _selectedSkills,
        'applicantCount': 0,
      });

      // Requirement 3.4: trigger matching on publish
      await MatchingService.matchNeedToVolunteers(needId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Need posted & AI matching started.'),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _descController.clear();
        _locationController.clear();
        _deadlineController.clear();
        _aiTextController.clear();
        setState(() {
          _selectedSkills = [];
          _urgency = 'Medium';
          _lat = 0.0;
          _lng = 0.0;
          _coordsResolved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post need: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int _urgencyToInt(String label) {
    switch (label.toLowerCase()) {
      case 'low': return 1;
      case 'medium': return 2;
      case 'high': return 3;
      case 'critical': return 4;
      case 'immediate': return 5;
      default: return 2;
    }
  }

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month];
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create New Need',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          const Text('Post a volunteer opportunity for your NGO.'),
          const SizedBox(height: 24),

          // ── AI Extraction ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppTheme.primaryPurple, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'AI Pre-fill from Survey / Report Text',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppTheme.primaryPurple),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Paste survey or report text and let Gemini extract need details.',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _aiTextController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Paste survey or report text here…',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isExtracting ? null : _extractFromAI,
                  icon: _isExtracting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.psychology, size: 18),
                  label: Text(_isExtracting ? 'Extracting…' : 'Extract & Pre-fill'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Title ────────────────────────────────────────────────────────
          _label('Title'),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g. Full Stack Developer for Crisis App',
            ),
          ),
          const SizedBox(height: 20),

          // ── Description ──────────────────────────────────────────────────
          _label('Description'),
          TextFormField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe the need in detail…',
            ),
          ),
          const SizedBox(height: 20),

          // ── Category & Urgency ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Category'),
                    DropdownButtonFormField<String>(
                      value: _category,
                      items: [
                        'Technology', 'Education', 'Environment',
                        'Medical', 'Legal', 'Community',
                      ]
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _category = v;
                            _selectedSkills = [];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Urgency'),
                    DropdownButtonFormField<String>(
                      value: _urgency,
                      items: ['Low', 'Medium', 'High', 'Critical', 'Immediate']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _urgency = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Skills ───────────────────────────────────────────────────────
          _label('Skills Required'),
          const SizedBox(height: 2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentSkills.map((skill) {
              final selected = _selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () => setState(() {
                  selected
                      ? _selectedSkills.remove(skill)
                      : _selectedSkills.add(skill);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppTheme.primaryPurple
                          : AppTheme.borderGrey,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Deadline ─────────────────────────────────────────────────────
          _label('Deadline'),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2027),
              );
              if (picked != null) {
                _deadlineController.text =
                    '${picked.day} ${_monthName(picked.month)} ${picked.year}';
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  hintText: 'Select deadline',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Location ─────────────────────────────────────────────────────
          _label('Location'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'City, address, or "Remote"',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _coordsResolved
                            ? Icons.location_on
                            : Icons.location_searching,
                        color: _coordsResolved
                            ? AppTheme.successGreen
                            : AppTheme.textGrey,
                      ),
                      onPressed: _resolveLocation,
                      tooltip: 'Resolve coordinates',
                    ),
                  ),
                  onChanged: (_) => setState(() => _coordsResolved = false),
                ),
              ),
            ],
          ),
          if (_coordsResolved)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '📍 ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                style: const TextStyle(
                    color: AppTheme.successGreen, fontSize: 11),
              ),
            ),
          const SizedBox(height: 24),

          // ── Submit ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _submitNeed,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Post Need & Find AI Matches'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
