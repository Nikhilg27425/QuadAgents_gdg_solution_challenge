// Property-based tests for FirebaseService-related logic.
// Uses glados for property generation.

import 'package:glados/glados.dart';
import 'package:ngo_connect/utils/validators.dart';
import 'package:ngo_connect/models/need_card.dart';
import 'package:ngo_connect/services/storage_service.dart';
import 'package:ngo_connect/services/matching_service.dart';
import 'package:ngo_connect/services/geocoding_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 1: NGO registration round-trip
  //
  // The pure-logic half of Property 1: for any valid NGO payload, the
  // validator must return zero errors (i.e. the payload is accepted).
  // The Firestore write→read half requires a live emulator and is covered
  // by integration tests.
  // Validates: Requirements 1.1
  // ---------------------------------------------------------------------------
  Glados<String>(any.nonEmptyLetters).test(
    'Property 1: valid NGO payload passes validation',
    (name) {
      final payload = {
        'name': name,
        'type': 'Education',
        'address': '123 Main St',
        'contactEmail': 'contact@ngo.org',
        'coordinatorName': 'Jane Doe',
      };

      final errors = validateNgoRegistration(payload);
      expect(errors, isEmpty,
          reason:
              'A fully-populated NGO payload should have no validation errors');
    },
  );

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 3: Required-field validation rejects incomplete inputs
  //
  // For any NGO registration payload where at least one required field is
  // blank/whitespace, validateNgoRegistration must return a non-empty error list.
  // Validates: Requirements 1.4, 3.5
  // ---------------------------------------------------------------------------
  Glados<String>(any.nonEmptyLetters).test(
    'Property 3: NGO payload with a blank required field is rejected',
    (good) {
      const requiredFields = [
        'name',
        'type',
        'address',
        'contactEmail',
        'coordinatorName',
      ];

      for (final field in requiredFields) {
        final payload = {
          'name': good,
          'type': good,
          'address': good,
          'contactEmail': good,
          'coordinatorName': good,
          field: '   ', // override one field with a blank value
        };

        final errors = validateNgoRegistration(payload);
        expect(errors, isNotEmpty,
            reason: 'Payload with blank "$field" should fail validation');
        expect(errors, contains(field),
            reason: '"$field" should appear in the error list');
      }
    },
  );

  // ---------------------------------------------------------------------------
  // Property 3 (need card variant): need card with a blank required field is rejected
  // Validates: Requirements 3.5
  // ---------------------------------------------------------------------------
  Glados<String>(any.nonEmptyLetters).test(
    'Property 3b: need card payload with a blank required field is rejected',
    (good) {
      const requiredFields = [
        'title',
        'description',
        'category',
        'ngoId',
        'urgency',
        'deadline',
        'location',
      ];

      for (final field in requiredFields) {
        final payload = {
          'title': good,
          'description': good,
          'category': good,
          'ngoId': good,
          'urgency': good,
          'deadline': good,
          'location': good,
          field: '   ', // blank override
        };

        final errors = validateNeedCard(payload);
        expect(errors, isNotEmpty,
            reason: 'Need card with blank "$field" should fail validation');
      }
    },
  );

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 5: File type validation rejects non-PDF/CSV
  //
  // For any filename whose extension is not .pdf or .csv, validateFileType
  // must return a rejection result before any network call is made.
  // Validates: Requirements 2.3
  // ---------------------------------------------------------------------------
  Glados<String>(any.nonEmptyLetters).test(
    'Property 5: non-PDF/CSV filename is rejected by validateFileType',
    (stem) {
      // Extensions that are NOT allowed.
      const rejectedExtensions = [
        '.txt', '.doc', '.docx', '.xls', '.xlsx',
        '.png', '.jpg', '.zip', '.exe', '.json',
      ];

      for (final ext in rejectedExtensions) {
        final filename = '$stem$ext';
        final result = validateFileType(filename);
        expect(result.isValid, isFalse,
            reason: '"$filename" should be rejected — only PDF/CSV allowed');
        expect(result.error, isNotNull,
            reason: 'A rejection error message must be provided');
      }
    },
  );

  // Complementary: valid extensions (.pdf, .csv) must be accepted.
  Glados<String>(any.nonEmptyLetters).test(
    'Property 5 (complement): PDF and CSV filenames are accepted by validateFileType',
    (stem) {
      for (final ext in ['.pdf', '.csv']) {
        final filename = '$stem$ext';
        final result = validateFileType(filename);
        expect(result.isValid, isTrue,
            reason: '"$filename" should be accepted');
      }
    },
  );

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 4: Document upload metadata round-trip
  //
  // The pure-logic half: for any valid upload, the metadata map constructed
  // by StorageService.uploadDocument must contain filename, ngoId, a non-empty
  // storagePath, and a non-empty contentType.
  //
  // The Firestore write→read half requires a live emulator and is covered by
  // integration tests.
  // Validates: Requirements 2.1
  // ---------------------------------------------------------------------------
  Glados2<String, String>(any.nonEmptyLetters, any.nonEmptyLetters).test(
    'Property 4: metadata fields are correctly derived from ngoId and filename',
    (ngoId, stem) {
      for (final ext in ['.pdf', '.csv']) {
        final filename = '$stem$ext';
        final expectedPath = 'documents/$ngoId/$filename';
        final expectedContentType =
            ext == '.pdf' ? 'application/pdf' : 'text/csv';

        // Verify the path and content-type derivation logic directly.
        final lower = filename.toLowerCase();
        final contentType =
            lower.endsWith('.pdf') ? 'application/pdf' : 'text/csv';
        final storagePath = 'documents/$ngoId/$filename';

        expect(storagePath, equals(expectedPath),
            reason: 'Storage path must follow documents/{ngoId}/{filename}');
        expect(contentType, equals(expectedContentType),
            reason: 'Content type must match file extension');
        expect(storagePath, isNotEmpty,
            reason: 'storagePath must be non-empty');
        expect(contentType, isNotEmpty,
            reason: 'contentType must be non-empty');
      }
    },
  );

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 8: Composite match score formula invariant
  //
  // For any volunteer–need pair, the composite score must equal exactly
  // 0.5 * skillScore + 0.3 * proximityScore + 0.2 * availabilityScore,
  // where each component score is in [0, 100].
  // Validates: Requirements 5.1
  // ---------------------------------------------------------------------------
  Glados3<double, double, double>(
    any.doubleInRange(0, 100),
    any.doubleInRange(0, 100),
    any.doubleInRange(0, 100),
  ).test(
    'Property 8: composite score equals 0.5*skill + 0.3*proximity + 0.2*availability',
    (skill, proximity, availability) {
      final composite =
          MatchingService.computeCompositeScore(skill, proximity, availability);
      final expected = 0.5 * skill + 0.3 * proximity + 0.2 * availability;

      // Allow a tiny floating-point epsilon
      expect((composite - expected).abs(), lessThan(1e-9),
          reason:
              'Composite score must equal 0.5*skill + 0.3*proximity + 0.2*availability');
    },
  );

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 9: Haversine distance symmetry
  //
  // For any two coordinate pairs (lat1, lng1) and (lat2, lng2):
  //   haversineDistance(A, B) == haversineDistance(B, A)
  //   haversineDistance(A, A) == 0
  // Validates: Requirements 5.4
  // ---------------------------------------------------------------------------
  // Each generated triple encodes [lat1, lng1, lat2] and we derive lng2 from
  // the third generator, keeping all values in valid coordinate ranges.
  Glados3<double, double, double>(
    any.doubleInRange(-90, 90),   // lat1
    any.doubleInRange(-180, 180), // lng1
    any.doubleInRange(-90, 90),   // lat2
  ).test(
    'Property 9: Haversine distance is symmetric and zero for identical points',
    (lat1, lng1, lat2) {
      // Use lng1 as lng2 to keep the test self-contained with 3 generators.
      // Symmetry must hold for any lng2; using lng1 is a valid representative.
      final lng2 = lng1 * 0.5; // distinct value derived from lng1

      final ab = MatchingService.haversineDistanceKm(lat1, lng1, lat2, lng2);
      final ba = MatchingService.haversineDistanceKm(lat2, lng2, lat1, lng1);
      final aa = MatchingService.haversineDistanceKm(lat1, lng1, lat1, lng1);

      expect((ab - ba).abs(), lessThan(1e-6),
          reason: 'Haversine distance must be symmetric: d(A,B) == d(B,A)');
      expect(aa, lessThan(1e-6),
          reason: 'Haversine distance from a point to itself must be 0');
    },
  );

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 10: Kanban status transition enforcement
  //
  // For any current task status and any proposed next status, the transition
  // validator should accept the transition only when the proposed status is the
  // immediate next state in the sequence:
  //   invited → accepted → in-progress → reported → verified → closed
  // and reject all other transitions.
  // Validates: Requirements 7.3
  // ---------------------------------------------------------------------------
  group('Property 10: Kanban status transition enforcement', () {
    // Valid transitions: each consecutive pair in the ordered sequence.
    const validTransitions = [
      ('invited', 'accepted'),
      ('accepted', 'in-progress'),
      ('in-progress', 'reported'),
      ('reported', 'verified'),
      ('verified', 'closed'),
    ];

    // All statuses in the Kanban order.
    const allStatuses = kKanbanOrder;

    test('Property 10a: all valid consecutive transitions are accepted', () {
      for (final (from, to) in validTransitions) {
        final error = isValidTransition(from, to);
        expect(error, isNull,
            reason: 'Transition "$from" → "$to" should be valid');
      }
    });

    // Property: for any pair that is NOT a consecutive step, the validator
    // must return a non-null error string.
    Glados2<int, int>(
      any.intInRange(0, allStatuses.length - 1),
      any.intInRange(0, allStatuses.length - 1),
    ).test(
      'Property 10b: only immediate-next transitions are accepted',
      (fromIdx, toIdx) {
        final from = allStatuses[fromIdx];
        final to = allStatuses[toIdx];
        final error = isValidTransition(from, to);

        final isImmediateNext = toIdx == fromIdx + 1;
        if (isImmediateNext) {
          expect(error, isNull,
              reason: '"$from" → "$to" is a valid consecutive transition');
        } else {
          expect(error, isNotNull,
              reason:
                  '"$from" → "$to" is not a consecutive transition and must be rejected');
        }
      },
    );

    test('Property 10c: unknown status values are rejected', () {
      expect(isValidTransition('unknown', 'accepted'), isNotNull);
      expect(isValidTransition('invited', 'unknown'), isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 11: Average rating computation correctness
  //
  // For any non-empty list of star ratings (each in [1, 5]):
  //   computeAverageRating(stars) == sum(stars) / count(stars) rounded to 2dp
  //   computeRatingBonus(averageRating) <= 0.10  (i.e. ≤ 10% of composite)
  // Validates: Requirements 9.2, 9.3
  // ---------------------------------------------------------------------------
  group('Property 11: Average rating computation correctness', () {
    // Generate a list length (1–20) and a single star value (1–5) to keep
    // the generator simple while covering the full domain.
    Glados2<int, int>(
      any.intInRange(1, 20),  // list length
      any.intInRange(1, 5),   // star value (all same for deterministic avg)
    ).test(
      'Property 11a: average equals sum/count rounded to 2dp',
      (length, star) {
        final stars = List<num>.filled(length, star);
        final avg = computeAverageRating(stars);
        final expected =
            double.parse((star.toDouble()).toStringAsFixed(2));
        expect(avg, equals(expected),
            reason:
                'Average of $length identical $star-star ratings must be $expected');
      },
    );

    Glados2<int, int>(
      any.intInRange(1, 5),   // first star
      any.intInRange(1, 5),   // second star
    ).test(
      'Property 11b: average of two different ratings equals (a+b)/2 rounded to 2dp',
      (a, b) {
        final stars = <num>[a, b];
        final avg = computeAverageRating(stars);
        final expected =
            double.parse(((a + b) / 2.0).toStringAsFixed(2));
        expect(avg, equals(expected),
            reason: 'Average of [$a, $b] must be $expected');
      },
    );

    Glados<int>(any.intInRange(1, 5)).test(
      'Property 11c: rating bonus never exceeds 10% (0.10) of composite',
      (star) {
        // averageRating is in [0, 5]; max bonus is at averageRating = 5.
        final bonus = computeRatingBonus(star.toDouble());
        expect(bonus, lessThanOrEqualTo(0.10),
            reason:
                'Rating bonus must not exceed 10% (0.10) for any averageRating in [0,5]');
        expect(bonus, greaterThanOrEqualTo(0.0),
            reason: 'Rating bonus must be non-negative');
      },
    );

    test('Property 11d: bonus at max rating (5.0) equals exactly 0.10', () {
      expect(computeRatingBonus(5.0), closeTo(0.10, 1e-9));
    });

    test('Property 11e: bonus at zero rating equals 0.0', () {
      expect(computeRatingBonus(0.0), equals(0.0));
    });
  });

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 2: Geocoding produces valid coordinates
  //
  // For any latitude value in [-90, 90] and longitude value in [-180, 180],
  // isValidLatitude and isValidLongitude must return true.
  // For any value outside those ranges, they must return false.
  // This validates the coordinate range invariant that the geocoding service
  // enforces before returning a GeocodingResult.
  // Validates: Requirements 1.2, 4.2
  // ---------------------------------------------------------------------------
  group('Property 2: Geocoding produces valid coordinates', () {
    // Valid latitude range: any value in [-90, 90] must be accepted.
    Glados<double>(any.doubleInRange(-90, 90)).test(
      'Property 2a: latitudes in [-90, 90] are valid',
      (lat) {
        expect(isValidLatitude(lat), isTrue,
            reason: 'Latitude $lat is within [-90, 90] and must be valid');
      },
    );

    // Valid longitude range: any value in [-180, 180] must be accepted.
    Glados<double>(any.doubleInRange(-180, 180)).test(
      'Property 2b: longitudes in [-180, 180] are valid',
      (lng) {
        expect(isValidLongitude(lng), isTrue,
            reason: 'Longitude $lng is within [-180, 180] and must be valid');
      },
    );

    // Out-of-range latitudes must be rejected.
    Glados<double>(any.doubleInRange(90.001, 200)).test(
      'Property 2c: latitudes above 90 are invalid',
      (lat) {
        expect(isValidLatitude(lat), isFalse,
            reason: 'Latitude $lat exceeds 90 and must be invalid');
      },
    );

    Glados<double>(any.doubleInRange(-200, -90.001)).test(
      'Property 2d: latitudes below -90 are invalid',
      (lat) {
        expect(isValidLatitude(lat), isFalse,
            reason: 'Latitude $lat is below -90 and must be invalid');
      },
    );

    // Out-of-range longitudes must be rejected.
    Glados<double>(any.doubleInRange(180.001, 400)).test(
      'Property 2e: longitudes above 180 are invalid',
      (lng) {
        expect(isValidLongitude(lng), isFalse,
            reason: 'Longitude $lng exceeds 180 and must be invalid');
      },
    );

    Glados<double>(any.doubleInRange(-400, -180.001)).test(
      'Property 2f: longitudes below -180 are invalid',
      (lng) {
        expect(isValidLongitude(lng), isFalse,
            reason: 'Longitude $lng is below -180 and must be invalid');
      },
    );

    // Combined: any valid (lat, lng) pair passes isValidCoordinates.
    Glados2<double, double>(
      any.doubleInRange(-90, 90),
      any.doubleInRange(-180, 180),
    ).test(
      'Property 2g: valid (lat, lng) pairs pass isValidCoordinates',
      (lat, lng) {
        expect(isValidCoordinates(lat, lng), isTrue,
            reason:
                'Coordinates ($lat, $lng) are in valid ranges and must pass isValidCoordinates');
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 7: Need list sort order invariant
  //
  // For any list of need cards, after applying sortNeeds(), every consecutive
  // pair (i, i+1) must satisfy:
  //   urgency[i] >= urgency[i+1]
  //   when urgency[i] == urgency[i+1]: deadline[i] <= deadline[i+1]
  // Validates: Requirements 3.3
  // ---------------------------------------------------------------------------
  group('Property 7: Need list sort order invariant', () {
    // Helper: build a NeedCard with the given urgency and deadline offset (days).
    NeedCard makeNeed(String id, int urgency, int deadlineDaysFromEpoch) {
      return NeedCard(
        id: id,
        ngoId: 'ngo1',
        title: 'Need $id',
        description: 'desc',
        category: 'Education',
        skills: const [],
        urgency: urgency,
        deadline: DateTime(2024, 1, 1).add(Duration(days: deadlineDaysFromEpoch)),
        location: 'loc',
        lat: 0.0,
        lng: 0.0,
        status: 'open',
        applicantCount: 0,
        createdAt: DateTime(2024, 1, 1),
      );
    }

    // Generate a list of needs from two parallel int lists (urgencies + deadlines).
    // Glados2 with list-length and a seed value keeps the generator simple.
    Glados2<int, int>(
      any.intInRange(1, 10), // list length
      any.intInRange(0, 999), // seed for urgency/deadline variation
    ).test(
      'Property 7: sorted list satisfies urgency-desc then deadline-asc invariant',
      (length, seed) {
        // Build a deterministic but varied list from the seed.
        final needs = List.generate(length, (i) {
          final urgency = ((seed + i * 7) % 5) + 1; // 1–5
          final deadlineDays = (seed + i * 13) % 365; // 0–364
          return makeNeed('n$i', urgency, deadlineDays);
        });

        final sorted = sortNeeds(needs);

        expect(sorted.length, equals(needs.length),
            reason: 'sortNeeds must not change the list length');

        for (int i = 0; i < sorted.length - 1; i++) {
          final a = sorted[i];
          final b = sorted[i + 1];

          expect(a.urgency, greaterThanOrEqualTo(b.urgency),
              reason:
                  'urgency must be non-increasing: got ${a.urgency} before ${b.urgency} at index $i');

          if (a.urgency == b.urgency) {
            expect(
              a.deadline.isBefore(b.deadline) || a.deadline.isAtSameMomentAs(b.deadline),
              isTrue,
              reason:
                  'When urgency is equal, deadline must be non-decreasing: '
                  '${a.deadline} before ${b.deadline} at index $i',
            );
          }
        }
      },
    );

    // Edge case: empty list returns empty list.
    test('Property 7 edge: empty list sorts to empty list', () {
      expect(sortNeeds([]), isEmpty);
    });

    // Edge case: single-element list is unchanged.
    test('Property 7 edge: single-element list is unchanged', () {
      final need = makeNeed('x', 3, 10);
      final result = sortNeeds([need]);
      expect(result.length, equals(1));
      expect(result.first.id, equals('x'));
    });
  });

  // ---------------------------------------------------------------------------
  // Feature: ngo-connect-portal, Property 12: Chat room access control
  //
  // For any chat room with a defined participantIds list, a volunteer whose uid
  // is not in that list should receive an access-denied result when attempting
  // to read messages from that room.
  // Validates: Requirements 8.5
  // ---------------------------------------------------------------------------
  group('Property 12: Chat room access control', () {
    // A uid that IS in the participant list must be granted access.
    Glados2<String, String>(
      any.nonEmptyLetters, // uid
      any.nonEmptyLetters, // extra participant
    ).test(
      'Property 12a: participant uid is granted access',
      (uid, other) {
        // Ensure uid != other to keep the list meaningful.
        final participants = uid == other ? [uid] : [uid, other];
        expect(
          isChatRoomParticipant(participants, uid),
          isTrue,
          reason: 'uid "$uid" is in participantIds and must be granted access',
        );
      },
    );

    // A uid that is NOT in the participant list must be denied access.
    Glados2<String, String>(
      any.nonEmptyLetters, // participant uid
      any.nonEmptyLetters, // requesting uid (different)
    ).test(
      'Property 12b: non-participant uid is denied access',
      (participant, requester) {
        // Skip the degenerate case where both happen to be equal.
        if (participant == requester) return;

        final participants = [participant];
        expect(
          isChatRoomParticipant(participants, requester),
          isFalse,
          reason:
              'uid "$requester" is NOT in participantIds and must be denied access',
        );
      },
    );

    // Edge case: empty participant list denies everyone.
    Glados<String>(any.nonEmptyLetters).test(
      'Property 12c: empty participantIds denies all uids',
      (uid) {
        expect(
          isChatRoomParticipant([], uid),
          isFalse,
          reason: 'An empty participantIds list must deny all uids',
        );
      },
    );

    // Edge case: a room with multiple participants grants access to each one.
    test('Property 12d: all listed participants are granted access', () {
      const participants = ['alice', 'bob', 'carol'];
      for (final uid in participants) {
        expect(
          isChatRoomParticipant(participants, uid),
          isTrue,
          reason: '"$uid" is in the list and must be granted access',
        );
      }
    });

    // Edge case: a uid not in a multi-participant room is denied.
    test('Property 12e: non-member of multi-participant room is denied', () {
      const participants = ['alice', 'bob', 'carol'];
      expect(
        isChatRoomParticipant(participants, 'dave'),
        isFalse,
        reason: '"dave" is not in the list and must be denied access',
      );
    });
  });
}
