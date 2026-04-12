# Implementation Plan

- [x] 1. Project setup and dependencies





  - Add `google_maps_flutter`, `geocoding`, `file_picker`, `fast_check`, `fl_chart` to pubspec.yaml
  - Add Google Maps API key to AndroidManifest.xml and index.html (web)
  - Configure Firebase emulator for local testing
  - _Requirements: 10.1, 2.1_

- [x] 2. Core service layer — FirebaseService expansion






- [x] 2.1 Expand FirebaseService with NGO, document, need, assignment, chat, notification, and rating methods


  - Implement all methods defined in the design's FirebaseService interface
  - Remove any remaining hardcoded values from existing methods
  - _Requirements: 1.1, 2.1, 3.1, 6.2, 8.2, 9.1, 11.1_

- [x] 2.2 Write property test for NGO registration round-trip (Property 1)



  - **Property 1: NGO registration round-trip**
  - **Validates: Requirements 1.1**


- [x] 2.3 Write property test for required-field validation (Property 3)


  - **Property 3: Required-field validation rejects incomplete inputs**
  - **Validates: Requirements 1.4, 3.5**

- [x] 3. StorageService — document upload





- [x] 3.1 Implement StorageService with file upload, type validation, and size validation


  - Client-side MIME/extension check (PDF, CSV only) before upload
  - Client-side 10 MB size check before upload
  - Upload to `documents/{ngo_id}/{filename}` in Firebase Storage
  - Write metadata to `ngo_documents` Firestore collection
  - _Requirements: 2.1, 2.3, 2.4_

- [x] 3.2 Write property test for file type validation (Property 5)


  - **Property 5: File type validation rejects non-PDF/CSV**
  - **Validates: Requirements 2.3**

- [x] 3.3 Write property test for document upload metadata round-trip (Property 4)


  - **Property 4: Document upload metadata round-trip**
  - **Validates: Requirements 2.1**

- [x] 4. MatchingService — scoring engine





- [x] 4.1 Implement computeSkillScore, computeProximityScore (Haversine), computeAvailabilityScore, and composite score


  - Skill overlap: Jaccard similarity × 100
  - Proximity: score = max(0, 100 - distanceKm) capped at 100
  - Availability: exact match = 100, partial = 50, none = 0
  - Composite = 0.5×skill + 0.3×proximity + 0.2×availability
  - _Requirements: 5.1, 5.4_

- [x] 4.2 Write property test for composite score formula invariant (Property 8)


  - **Property 8: Composite match score formula invariant**
  - **Validates: Requirements 5.1**


- [x] 4.3 Write property test for Haversine distance symmetry (Property 9)






  - **Property 9: Haversine distance symmetry**
  - **Validates: Requirements 5.4**



- [x] 4.4 Implement matchNeedToVolunteers and matchVolunteerToNeeds with Gemini re-ranking





  - Fetch open needs and volunteer profiles from Firestore
  - Score all pairs, take top 10, send to Gemini for re-ranking with reasoning
  - Store results in `matches` collection
  - _Requirements: 5.1, 5.2, 5.5_

- [x] 5. Kanban status transition validator





- [x] 5.1 Implement isValidTransition(currentStatus, nextStatus) function and integrate into updateAssignmentStatus


  - Enforce order: invited → accepted → in-progress → reported → verified → closed
  - Return error string for invalid transitions
  - _Requirements: 7.3_

- [x] 5.2 Write property test for Kanban status transition enforcement (Property 10)


  - **Property 10: Kanban status transition enforcement**
  - **Validates: Requirements 7.3**

- [x] 6. Rating and average computation






- [x] 6.1 Implement submitRating and recomputeAverageRating in FirebaseService

  - Write rating document to `ratings` collection
  - Recompute average from all volunteer's ratings and update `users/{uid}.averageRating`
  - Apply rating bonus (≤ 10%) in composite score computation
  - _Requirements: 9.1, 9.2, 9.3_

- [x] 6.2 Write property test for average rating computation and bonus cap (Property 11)


  - **Property 11: Average rating computation correctness**
  - **Validates: Requirements 9.2, 9.3**

- [x] 7. Geocoding integration





- [x] 7.1 Integrate `geocoding` package into address fields for NGO registration, need creation, and volunteer profile


  - Resolve address → lat/lng on form submit
  - Store coordinates alongside address string in Firestore
  - _Requirements: 1.2, 4.2, 10.4_

- [x] 7.2 Write property test for geocoding coordinate range validation (Property 2)


  - **Property 2: Geocoding produces valid coordinates**
  - **Validates: Requirements 1.2, 4.2**

- [x] 8. Need list sort utility





- [x] 8.1 Implement sortNeeds(List<NeedCard>) utility function and apply to all need listing screens


  - Sort by urgency descending, then deadline ascending
  - _Requirements: 3.3_

- [x] 8.2 Write property test for need list sort order invariant (Property 7)


  - **Property 7: Need list sort order invariant**
  - **Validates: Requirements 3.3**

- [x] 9. NGO Dashboard — complete implementation





- [x] 9.1 Implement NgoOverviewView with live Firestore stats (needs posted, open, fulfilled, active volunteers)


  - Replace all hardcoded analytics values with live Firestore queries
  - _Requirements: 12.1, 12.2_

- [x] 9.2 Implement DocumentUploadView with file picker, upload progress, and live document list


  - Use StorageService for upload; stream `ngo_documents` for list
  - _Requirements: 2.1, 2.2, 2.5_

- [x] 9.3 Complete CreateNeedView with map-based location picker and AI extraction


  - Embed Google Maps picker for coordinate selection
  - Wire Gemini extraction button to MatchingService.extractNeedsFromText
  - Trigger matchNeedToVolunteers on publish and send notifications to top 5
  - _Requirements: 3.1, 3.2, 3.4, 3.6, 10.4_

- [x] 9.4 Implement NeedsManagementView — list, edit, publish needs from Firestore stream


  - _Requirements: 3.3, 6.4_

- [x] 9.5 Implement KanbanBoardView for NGO — real-time assignment status board


  - Stream `task_assignments` filtered by ngoId; group by status column
  - _Requirements: 7.1, 7.2, 7.4, 7.5_

- [x] 9.6 Complete AnalyticsView with live Firestore data and fl_chart charts


  - Replace all hardcoded chart data and metric values
  - Implement date range filter and CSV export
  - _Requirements: 12.1, 12.2, 12.3, 12.4_

- [x] 10. Volunteer Dashboard — complete implementation






- [x] 10.1 Implement ExploreNeedsView with list + map toggle

  - Map view: Google Maps with urgency-colored pins from live Firestore stream
  - Tap pin → show need summary card with Accept button
  - List view: filter by category, keyword search; live count badge from Firestore
  - _Requirements: 10.1, 10.2, 12.5_


- [x] 10.2 Implement TaskDetailView with accept/decline flow and embedded map

  - Show coordinator point on embedded map
  - Deadline expiry check before accept
  - On accept: create assignment, notify NGO, remove from pending
  - On decline: update status, offer to next ranked volunteer
  - _Requirements: 6.1, 6.2, 6.3, 6.5, 10.3_

- [x] 10.3 Implement MyTasksView — volunteer Kanban board with status update controls


  - Stream volunteer's assignments; enforce transition order via isValidTransition
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 10.4 Complete VolunteerProfileView with full profile fields and re-matching on save


  - Add languages, preferred causes, past experience fields
  - Geocode location on save; trigger re-matching for all open needs
  - Display averageRating and completedTaskCount from Firestore
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 9.4_

- [x] 11. Group chat module





- [x] 11.1 Implement ChatView with real-time Firestore message stream


  - Auto-create chat room when 2nd volunteer is assigned (ensureChatRoom)
  - Access control: check participantIds before subscribing to stream
  - Auto-scroll to latest message on new arrival
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_


- [x] 11.2 Write property test for chat room access control (Property 12)

  - **Property 12: Chat room access control**
  - **Validates: Requirements 8.5**

- [x] 12. Notifications system






- [x] 12.1 Implement NotificationsPanel with live Firestore stream and mark-as-read

  - Write notifications on: match found, assignment accepted/declined, status change, rating prompt
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 13. NGO registration flow — complete






- [x] 13.1 Extend LoginScreen registration path for NGO role with full NGO profile fields

  - Name, type, address (geocoded), contact email, coordinator name + address (geocoded)
  - Write to both `users` and `ngos` Firestore collections on register
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 14. Checkpoint — ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.

- [x] 15. Remove all hardcoded values






- [x] 15.1 Audit and replace every hardcoded string, number, and coordinate across all screens

  - Volunteer dashboard need cards (currently hardcoded 3 cards)
  - Analytics metrics (currently hardcoded numbers)
  - Landing page stats bar (currently hardcoded counts)
  - _Requirements: 1.3, 2.5, 6.4, 12.2, 12.5_

- [x] 16. Final Checkpoint — ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.
