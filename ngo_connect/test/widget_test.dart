// Basic smoke test for the NGO Connect app.
// We test pure utility functions rather than the full widget tree,
// since the app requires Firebase initialisation which is not available
// in the unit-test environment.

import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_connect/utils/validators.dart';
import 'package:ngo_connect/models/need_card.dart';

void main() {
  group('Validator smoke tests', () {
    test('validateNgoRegistration accepts a complete payload', () {
      final errors = validateNgoRegistration({
        'name': 'Test NGO',
        'type': 'Education',
        'address': '123 Main St',
        'contactEmail': 'test@ngo.org',
        'coordinatorName': 'Jane Doe',
      });
      expect(errors, isEmpty);
    });

    test('validateNgoRegistration rejects a payload with a blank field', () {
      final errors = validateNgoRegistration({
        'name': '',
        'type': 'Education',
        'address': '123 Main St',
        'contactEmail': 'test@ngo.org',
        'coordinatorName': 'Jane Doe',
      });
      expect(errors, contains('name'));
    });

    test('sortNeeds returns an empty list for empty input', () {
      expect(sortNeeds([]), isEmpty);
    });

    test('sortNeeds orders by urgency descending', () {
      final needs = [
        NeedCard(
          id: '1', ngoId: 'n', title: 'A', description: '', category: '',
          skills: [], urgency: 2, deadline: DateTime(2025),
          location: '', lat: 0, lng: 0, status: 'open',
          applicantCount: 0, createdAt: DateTime(2024),
        ),
        NeedCard(
          id: '2', ngoId: 'n', title: 'B', description: '', category: '',
          skills: [], urgency: 5, deadline: DateTime(2025),
          location: '', lat: 0, lng: 0, status: 'open',
          applicantCount: 0, createdAt: DateTime(2024),
        ),
      ];
      final sorted = sortNeeds(needs);
      expect(sorted.first.urgency, equals(5));
      expect(sorted.last.urgency, equals(2));
    });
  });
}
