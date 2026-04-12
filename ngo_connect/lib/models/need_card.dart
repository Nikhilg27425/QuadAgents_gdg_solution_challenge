/// NeedCard model — mirrors the `needs/{needId}` Firestore document.
class NeedCard {
  final String id;
  final String ngoId;
  final String title;
  final String description;
  final String category;
  final List<String> skills;
  final int urgency; // 1–5
  final DateTime deadline;
  final String location;
  final double lat;
  final double lng;
  final String status;
  final int applicantCount;
  final DateTime createdAt;

  const NeedCard({
    required this.id,
    required this.ngoId,
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.urgency,
    required this.deadline,
    required this.location,
    required this.lat,
    required this.lng,
    required this.status,
    required this.applicantCount,
    required this.createdAt,
  });

  factory NeedCard.fromMap(String id, Map<String, dynamic> data) {
    return NeedCard(
      id: id,
      ngoId: data['ngoId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      skills: List<String>.from(data['skills'] as List? ?? []),
      urgency: _parseUrgency(data['urgency']),
      deadline: (data['deadline'] != null)
          ? DateTime.tryParse(data['deadline'].toString()) ?? DateTime(2099)
          : DateTime(2099),
      location: data['location'] as String? ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'open',
      applicantCount: (data['applicantCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] != null)
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Converts urgency stored as either an int (1–5) or a String label
/// ("Low", "Medium", "High", "Critical", "Immediate") to an int.
int _parseUrgency(dynamic value) {
  if (value == null) return 1;
  if (value is num) return value.toInt().clamp(1, 5);
  switch (value.toString().toLowerCase()) {
    case 'low':
      return 1;
    case 'medium':
      return 2;
    case 'high':
      return 3;
    case 'critical':
      return 4;
    case 'immediate':
      return 5;
    default:
      return int.tryParse(value.toString())?.clamp(1, 5) ?? 1;
  }
}
