import 'package:ngo_connect/models/need_card.dart';

/// Pure validation helpers used by NGO registration and need-card creation forms.
/// Returns a list of field-name strings that failed validation.
/// An empty list means the payload is valid.

/// Validates an NGO registration payload.
/// Required fields: name, type, address, contactEmail, coordinatorName.
List<String> validateNgoRegistration(Map<String, dynamic> data) {
  const required = [
    'name',
    'type',
    'address',
    'contactEmail',
    'coordinatorName',
  ];
  return required
      .where((f) => _isBlank(data[f]))
      .toList();
}

/// Validates a need-card creation payload.
/// Required fields: title, description, category, ngoId, urgency, deadline, location.
List<String> validateNeedCard(Map<String, dynamic> data) {
  const required = [
    'title',
    'description',
    'category',
    'ngoId',
    'urgency',
    'deadline',
    'location',
  ];
  return required
      .where((f) => _isBlank(data[f]))
      .toList();
}

bool _isBlank(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  return false;
}

// ── Rating helpers ────────────────────────────────────────────────────────────

/// Computes the average of a non-empty list of star ratings (each in [1, 5]),
/// rounded to two decimal places.
///
/// Requirement 9.2: recompute average from all volunteer's ratings.
double computeAverageRating(List<num> stars) {
  if (stars.isEmpty) return 0.0;
  final total = stars.fold<num>(0, (sum, s) => sum + s);
  return double.parse((total / stars.length).toStringAsFixed(2));
}

/// Computes the rating bonus multiplier for a given [averageRating] (in [0, 5]).
/// The bonus is at most 10% of the composite score (i.e. ≤ 0.10).
///
/// Requirement 9.3: incorporate averageRating as a bonus multiplier of up to 10%.
double computeRatingBonus(double averageRating) {
  return (averageRating / 5.0) * 0.1;
}

// ── Kanban status transition validator ────────────────────────────────────────

/// The ordered Kanban lifecycle for task assignments.
const List<String> kKanbanOrder = [
  'invited',
  'accepted',
  'in-progress',
  'reported',
  'verified',
  'closed',
];

/// Returns `null` when the transition is valid, or a descriptive error string
/// when the proposed [nextStatus] is not the immediate successor of [currentStatus].
///
/// Requirement 7.3: enforce invited → accepted → in-progress → reported →
/// verified → closed; return a 400-style error for any out-of-order transition.
String? isValidTransition(String currentStatus, String nextStatus) {
  final currentIndex = kKanbanOrder.indexOf(currentStatus);
  final nextIndex = kKanbanOrder.indexOf(nextStatus);

  if (currentIndex == -1) {
    return 'Invalid current status: "$currentStatus". '
        'Must be one of: ${kKanbanOrder.join(', ')}.';
  }
  if (nextIndex == -1) {
    return 'Invalid next status: "$nextStatus". '
        'Must be one of: ${kKanbanOrder.join(', ')}.';
  }
  if (nextIndex != currentIndex + 1) {
    return 'Invalid transition from "$currentStatus" to "$nextStatus". '
        'Expected next status: "${kKanbanOrder[currentIndex + 1 < kKanbanOrder.length ? currentIndex + 1 : currentIndex]}".';
  }
  return null; // valid
}

// ── Need list sort utility ────────────────────────────────────────────────────

/// Sorts [needs] in-place by urgency descending, then deadline ascending.
///
/// Requirement 3.3: needs displayed on any listing screen SHALL be sorted by
/// urgency score descending and then by deadline ascending.
///
/// Property 7: for every consecutive pair (i, i+1) after sorting:
///   urgency[i] >= urgency[i+1]
///   when urgency[i] == urgency[i+1]: deadline[i] <= deadline[i+1]
List<NeedCard> sortNeeds(List<NeedCard> needs) {
  final sorted = List<NeedCard>.from(needs);
  sorted.sort((a, b) {
    final urgencyCmp = b.urgency.compareTo(a.urgency); // descending
    if (urgencyCmp != 0) return urgencyCmp;
    return a.deadline.compareTo(b.deadline); // ascending
  });
  return sorted;
}

// ── Chat room access control ──────────────────────────────────────────────────

/// Returns `true` when [uid] is present in [participantIds], meaning the user
/// is allowed to read messages from the chat room.
///
/// Returns `false` (access denied) when [uid] is absent from [participantIds].
///
/// Requirement 8.5: IF a volunteer who is not assigned to a task attempts to
/// access that task's chat room, THEN THE System SHALL return a 403 response
/// and display an unauthorized message.
///
/// Property 12: For any chat room with a defined participantIds list, a
/// volunteer whose uid is not in that list should receive an access-denied
/// result when attempting to read messages from that room.
bool isChatRoomParticipant(List<String> participantIds, String uid) {
  return participantIds.contains(uid);
}
