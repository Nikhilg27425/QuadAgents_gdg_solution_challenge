# Design Document — NGO Connect Portal

## Overview

NGO Connect is a Flutter web/mobile application that bridges NGOs and volunteers for smart resource allocation. The stack is:

- **Frontend**: Flutter (web + mobile) with Riverpod state management
- **Auth & Database**: Firebase Auth + Cloud Firestore
- **Storage**: Firebase Storage (documents)
- **AI**: Google Gemini API (need extraction + volunteer matching re-ranking)
- **Maps**: Google Maps Flutter plugin (`google_maps_flutter`)
- **Real-time**: Firestore streams (chat, notifications, Kanban)

The existing Flutter codebase is retained and extended. The Python FastAPI backend is deprecated in favour of direct Firestore access from the Flutter client and Gemini calls from the `MatchingService`.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Web + Mobile)            │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │  NGO     │  │Volunteer │  │ Matching │  │ Chat   │  │
│  │ Portal   │  │ Portal   │  │ Engine   │  │ Module │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───┬────┘  │
│       │              │              │             │       │
│  ┌────▼──────────────▼──────────────▼─────────────▼────┐ │
│  │              Service Layer (Dart)                    │ │
│  │  FirebaseService │ MatchingService │ StorageService  │ │
│  └────┬──────────────────────────────────────────┬─────┘ │
└───────┼──────────────────────────────────────────┼───────┘
        │                                          │
   ┌────▼────────────────┐              ┌──────────▼──────┐
   │  Firebase           │              │  Google APIs    │
   │  Auth + Firestore   │              │  Maps + Gemini  │
   │  + Storage          │              │                 │
   └─────────────────────┘              └─────────────────┘
```

### Key Architectural Decisions

- **No separate backend**: All data operations go directly to Firestore from Flutter. The FastAPI backend is removed.
- **Riverpod providers** wrap Firestore streams so UI rebuilds reactively.
- **Matching runs client-side** (NGO device) on publish, and is stored back to Firestore. Heavy re-ranking uses Gemini.
- **Maps**: `google_maps_flutter` for embedded maps; `geocoding` package for address → lat/lng resolution.
- **Chat**: Firestore sub-collections with `StreamBuilder` for real-time updates.

---

## Components and Interfaces

### Screen Hierarchy

```
LandingPage
├── LoginScreen (auth: login / register, role: ngo | volunteer)
│
├── NgoDashboard (role-gated)
│   ├── NgoOverviewView        — stats, recent needs, assignments
│   ├── DocumentUploadView     — upload PDF/CSV, list docs
│   ├── CreateNeedView         — need card form + AI extraction + map picker
│   ├── NeedsManagementView    — list/edit/publish needs
│   ├── KanbanBoardView        — task status board (NGO perspective)
│   ├── AnalyticsView          — charts from live Firestore data
│   └── NotificationsPanel     — live notification feed
│
└── VolunteerDashboard (role-gated)
    ├── VolunteerOverviewView  — matched needs, active tasks
    ├── ExploreNeedsView       — list + map toggle, filters
    ├── TaskDetailView         — need detail + accept/decline + map
    ├── MyTasksView            — Kanban board (volunteer perspective)
    ├── ChatView               — per-task group chat
    ├── VolunteerProfileView   — skills, availability, location, ratings
    └── NotificationsPanel     — live notification feed
```

### Service Interfaces

```dart
// FirebaseService — all Firestore CRUD + Auth
class FirebaseService {
  // Auth
  static Future<Map<String, dynamic>> register(name, email, password, role, {ngoData?})
  static Future<Map<String, dynamic>> login(email, password)
  static Future<void> logout()

  // NGO
  static Future<void> createOrUpdateNgo(String uid, Map<String, dynamic> data)
  static Future<Map<String, dynamic>?> getNgoProfile(String uid)

  // Documents
  static Future<String> uploadDocument(String ngoId, File file)
  static Stream<QuerySnapshot> getDocumentsStream(String ngoId)

  // Needs
  static Future<String> createNeed(Map<String, dynamic> need)
  static Stream<QuerySnapshot> getNeedsStream({String? ngoId, String? status})
  static Future<void> updateNeed(String needId, Map<String, dynamic> data)

  // Matching
  static Future<void> storeMatches(String needId, List<Map<String, dynamic>> matches)
  static Stream<QuerySnapshot> getMatchesStream(String volunteerId)

  // Assignments
  static Future<String> createAssignment(Map<String, dynamic> assignment)
  static Future<void> updateAssignmentStatus(String assignmentId, String status)
  static Stream<QuerySnapshot> getAssignmentsStream({String? needId, String? volunteerId})

  // Chat
  static Future<void> ensureChatRoom(String taskId)
  static Future<void> sendMessage(String roomId, Map<String, dynamic> message)
  static Stream<QuerySnapshot> getMessagesStream(String roomId)

  // Notifications
  static Future<void> createNotification(String uid, Map<String, dynamic> notification)
  static Stream<QuerySnapshot> getNotificationsStream(String uid)
  static Future<void> markNotificationRead(String notificationId)

  // Ratings
  static Future<void> submitRating(Map<String, dynamic> rating)
  static Future<void> recomputeAverageRating(String volunteerId)

  // Analytics
  static Future<Map<String, dynamic>> getNgoAnalytics(String ngoId)
}

// MatchingService — scoring + Gemini re-ranking
class MatchingService {
  static Future<List<Map<String, dynamic>>> matchVolunteerToNeeds(String volunteerId)
  static Future<List<Map<String, dynamic>>> matchNeedToVolunteers(String needId)
  static Future<List<Map<String, dynamic>>> prioritizeNeeds(List<Map<String, dynamic>> needs)
  static Future<List<Map<String, dynamic>>> extractNeedsFromText(String rawText)
  static double computeSkillScore(List skills1, List skills2)
  static double computeProximityScore(double lat1, double lng1, double lat2, double lng2)
  static double computeAvailabilityScore(String needSchedule, String volunteerAvailability)
}

// StorageService — Firebase Storage uploads
class StorageService {
  static Future<String> uploadFile(String path, Uint8List bytes, String contentType)
  static Future<void> deleteFile(String path)
}
```

---

## Data Models

### Firestore Collections

```
users/{uid}
  name: string
  email: string
  role: 'ngo' | 'volunteer'
  createdAt: timestamp
  // volunteer-only
  skills: string[]
  languages: string[]
  availability: string          // 'Weekdays' | 'Weekends' | 'Evenings' | 'Full-time' | 'Flexible'
  location: string
  lat: number
  lng: number
  preferredCauses: string[]
  pastExperience: string
  averageRating: number
  completedTaskCount: number
  // ngo-only
  ngoId: string                 // same as uid for NGO users

ngos/{uid}
  name: string
  type: string                  // 'Education' | 'Medical' | 'Environment' | ...
  address: string
  lat: number
  lng: number
  contactEmail: string
  coordinatorName: string
  coordinatorAddress: string    // the "common local reporting point"
  coordinatorLat: number
  coordinatorLng: number
  createdAt: timestamp

ngo_documents/{docId}
  ngoId: string
  filename: string
  contentType: string
  downloadUrl: string
  storagePath: string
  uploadedAt: timestamp
  sizeBytes: number

needs/{needId}
  ngoId: string
  title: string
  description: string
  category: string
  skills: string[]
  urgency: number               // 1–5
  deadline: timestamp
  location: string
  lat: number
  lng: number
  status: 'open' | 'in-progress' | 'closed'
  applicantCount: number
  createdAt: timestamp

matches/{matchId}
  needId: string
  volunteerId: string
  skillScore: number
  proximityScore: number
  availabilityScore: number
  compositeScore: number
  ratingBonus: number
  finalScore: number
  geminiReason: string
  createdAt: timestamp

task_assignments/{assignmentId}
  needId: string
  volunteerId: string
  ngoId: string
  status: 'invited' | 'accepted' | 'in-progress' | 'reported' | 'verified' | 'closed'
  invitedAt: timestamp
  acceptedAt: timestamp?
  reportedAt: timestamp?
  verifiedAt: timestamp?

chat_rooms/{taskId}
  needId: string
  createdAt: timestamp
  participantIds: string[]

chat_rooms/{taskId}/messages/{msgId}
  senderUid: string
  senderName: string
  text: string
  sentAt: timestamp

notifications/{notifId}
  recipientUid: string
  type: 'match' | 'assignment' | 'status_change' | 'rating_prompt'
  title: string
  body: string
  relatedId: string             // needId or assignmentId
  read: boolean
  createdAt: timestamp

ratings/{ratingId}
  volunteerId: string
  ngoId: string
  taskId: string
  stars: number                 // 1–5
  note: string
  createdAt: timestamp
```

### Dart Model Classes

```dart
class NeedCard {
  final String id, ngoId, title, description, category;
  final List<String> skills;
  final int urgency;            // 1–5
  final DateTime deadline;
  final String location;
  final double lat, lng;
  final String status;
  final int applicantCount;
  final DateTime createdAt;
}

class VolunteerProfile {
  final String uid, name, email;
  final List<String> skills, languages, preferredCauses;
  final String availability, location, pastExperience;
  final double lat, lng, averageRating;
  final int completedTaskCount;
}

class TaskAssignment {
  final String id, needId, volunteerId, ngoId;
  final String status;          // Kanban state
  final DateTime invitedAt;
  final DateTime? acceptedAt, reportedAt, verifiedAt;
}

class ChatMessage {
  final String id, senderUid, senderName, text;
  final DateTime sentAt;
}

class AppNotification {
  final String id, recipientUid, type, title, body, relatedId;
  final bool read;
  final DateTime createdAt;
}
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: NGO registration round-trip
*For any* valid NGO registration payload (name, type, address, contact, coordinator point), writing it to Firestore and reading it back should produce a document containing all submitted fields plus a non-null `createdAt` timestamp.
**Validates: Requirements 1.1**

### Property 2: Geocoding produces valid coordinates
*For any* non-empty address string passed to the geocoding service, the returned latitude must be in the range [-90, 90] and longitude in the range [-180, 180].
**Validates: Requirements 1.2, 4.2**

### Property 3: Required-field validation rejects incomplete inputs
*For any* form submission (NGO registration or need card creation) where one or more required fields are empty or whitespace-only, the validator function should return a non-empty list of field errors and the submission should be blocked.
**Validates: Requirements 1.4, 3.5**

### Property 4: Document upload metadata round-trip
*For any* uploaded file, the metadata document written to `ngo_documents` should contain the original filename, the uploading NGO's id, a non-null `uploadedAt` timestamp, and a non-empty `downloadUrl`.
**Validates: Requirements 2.1**

### Property 5: File type validation rejects non-PDF/CSV
*For any* file whose MIME type or extension is not `application/pdf`, `text/csv`, or `.pdf`/`.csv`, the upload validator should return a rejection error before any network call is made.
**Validates: Requirements 2.3**

### Property 6: Need card creation round-trip with open status
*For any* valid need card payload, after persisting to Firestore the read-back document should have `status = 'open'` and `ngoId` equal to the creating NGO's uid.
**Validates: Requirements 3.1**

### Property 7: Need list sort order invariant
*For any* list of need cards, after applying the sort function, every consecutive pair (i, i+1) must satisfy: `urgency[i] >= urgency[i+1]`, and when `urgency[i] == urgency[i+1]`, `deadline[i] <= deadline[i+1]`.
**Validates: Requirements 3.3**

### Property 8: Composite match score formula invariant
*For any* volunteer–need pair, the composite score computed by the matching engine must equal exactly `0.5 * skillScore + 0.3 * proximityScore + 0.2 * availabilityScore`, where each component score is in [0, 100].
**Validates: Requirements 5.1**

### Property 9: Haversine distance symmetry
*For any* two coordinate pairs (lat1, lng1) and (lat2, lng2), `haversineDistance(A, B) == haversineDistance(B, A)`, and `haversineDistance(A, A) == 0`.
**Validates: Requirements 5.4**

### Property 10: Kanban status transition enforcement
*For any* current task status and any proposed next status, the transition validator should accept the transition only when the proposed status is the immediate next state in the sequence `invited → accepted → in-progress → reported → verified → closed`, and reject all other transitions.
**Validates: Requirements 7.3**

### Property 11: Average rating computation correctness
*For any* non-empty list of star ratings (each in [1, 5]), the computed `averageRating` must equal `sum(stars) / count(ratings)` rounded to two decimal places, and the rating bonus applied to the match score must not exceed 10% of the base composite score.
**Validates: Requirements 9.2, 9.3**

### Property 12: Chat room access control
*For any* chat room with a defined `participantIds` list, a volunteer whose uid is not in that list should receive an access-denied result when attempting to read messages from that room.
**Validates: Requirements 8.5**

---

## Error Handling

| Scenario | Handling |
|---|---|
| Firestore write fails | Show SnackBar with retry option; log error |
| Geocoding returns no results | Show inline error "Address not found, enter manually" |
| Gemini API timeout / error | Fall back to rule-based matching; show warning banner |
| File upload exceeds 10 MB | Client-side size check before upload; show error |
| Invalid file type | Client-side MIME check; reject before upload |
| Expired task deadline on accept | Check `deadline < DateTime.now()` before writing assignment |
| Out-of-order Kanban transition | Validate transition in service layer; return error string |
| Unauthorized chat access | Check `participantIds.contains(uid)` before stream subscription |
| Firebase Auth errors | Surface `FirebaseAuthException.message` in UI |

---

## Testing Strategy

### Unit Testing

Using Flutter's built-in `flutter_test` package.

- Test `MatchingService.computeSkillScore` with known skill lists
- Test `MatchingService.computeProximityScore` (Haversine) with known coordinates
- Test `sortNeeds()` utility with generated need lists
- Test Kanban transition validator with all valid and invalid state pairs
- Test form validators for NGO registration and need card creation
- Test file type and size validators
- Test average rating computation
- Test rating bonus cap (≤ 10%)

### Property-Based Testing

Using the **`glados`** Dart package configured to run a minimum of **100 iterations** per property.

Each property-based test must be tagged with a comment in this exact format:
`// Feature: ngo-connect-portal, Property {N}: {property_text}`

Rules:
- Each correctness property from this document maps to exactly one property-based test.
- Generators must constrain inputs to valid domain ranges (e.g., urgency in [1,5], lat in [-90,90]).
- Tests must not use mocks for the pure logic under test (validators, scoring functions, sort functions).
- Integration-level properties (Firestore round-trips) use the Firebase emulator suite.

**Property test mapping:**

| Property | Test description |
|---|---|
| P1 | Generate random NGO payloads → write → read → assert all fields present |
| P2 | Generate random address strings → geocode → assert coordinate ranges |
| P3 | Generate forms with random empty fields → validate → assert errors returned |
| P4 | Generate random file uploads → write metadata → read → assert fields |
| P5 | Generate random file extensions → validate → assert non-PDF/CSV rejected |
| P6 | Generate random need payloads → write → read → assert status='open', ngoId correct |
| P7 | Generate random need lists → sort → assert urgency desc + deadline asc invariant |
| P8 | Generate random score triples → compute composite → assert formula holds |
| P9 | Generate random coordinate pairs → assert Haversine symmetry and zero-distance |
| P10 | Generate random (currentStatus, nextStatus) pairs → assert only valid transitions accepted |
| P11 | Generate random rating lists → compute average → assert formula + bonus cap |
| P12 | Generate random (participantIds, requestingUid) pairs → assert non-members denied |
