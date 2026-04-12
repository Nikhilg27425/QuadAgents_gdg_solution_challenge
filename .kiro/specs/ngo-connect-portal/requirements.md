# Requirements Document

## Introduction

NGO Connect is a Next.js fullstack web platform that bridges NGOs and volunteers for smart resource allocation and data-driven volunteer coordination. NGOs register, upload community survey documents (PDFs/CSVs), create prioritized need cards, and track volunteer task completion. Volunteers register with structured skill profiles, browse and accept needs, collaborate via group chat, and receive ratings. A scoring-based matching engine connects the right volunteers to the right needs. The platform integrates maps for location-aware browsing. The entire stack runs in a single Next.js repository using API routes as the backend, Supabase (Postgres + Auth + Storage) as the database and file store, and Leaflet/OpenStreetMap for maps.

## Glossary

- **NGO**: Non-Governmental Organization that registers on the platform to post community needs.
- **Volunteer**: A registered user who browses, accepts, and fulfills NGO needs.
- **Need Card**: A structured record created by an NGO representing a community need, containing title, description, required skills, deadline, urgency score (1–5), location coordinates, and status.
- **Task Assignment**: A Supabase row in `task_assignments` linking a volunteer to a need card with a Kanban lifecycle status.
- **Matching Engine**: The Next.js API route that scores volunteers against open needs using skill overlap, location proximity, and availability fit.
- **Priority Engine**: The system (manual tagging + optional Gemini AI) that assigns urgency scores to need cards.
- **Skill Taxonomy**: The predefined, categorized list of skills used across volunteer profiles and need cards.
- **Kanban Status**: The ordered set of task lifecycle states: `invited` → `accepted` → `in-progress` → `reported` → `verified` → `closed`.
- **Chat Room**: A Supabase Realtime-backed messaging space auto-created per task when 2+ volunteers are assigned.
- **Rating**: A 1–5 star score with optional text note given by an NGO to a volunteer after task completion.
- **Coordinator Point**: The physical address of the NGO's designated field coordinator shown on task cards.
- **Supabase**: The backend platform providing Postgres database, authentication, file storage, and realtime subscriptions.
- **Next.js API Routes**: Server-side endpoints within the same Next.js repository that handle business logic, matching, and Supabase interactions.
- **Leaflet**: The open-source JavaScript mapping library used with OpenStreetMap tiles for all map rendering.
- **Haversine Formula**: The spherical geometry formula used to compute distance in kilometers between two lat/lng coordinate pairs.

---

## Requirements

### Requirement 1 — NGO Registration & Profile

**User Story:** As an NGO administrator, I want to register my organization with full profile details, so that volunteers can discover and trust my organization.

#### Acceptance Criteria

1. WHEN an NGO admin submits the registration form with name, type, location address, contact email, and coordinator point address, THE System SHALL insert a row into the `ngos` Supabase table with all provided fields, the authenticated user's id, and a `created_at` timestamp.
2. WHEN an NGO admin provides a location address during registration, THE System SHALL call the Nominatim geocoding API to resolve the address to latitude/longitude coordinates and store them in the `ngos` table.
3. WHEN an NGO admin logs in, THE System SHALL display the NGO dashboard with the organization's live data fetched from Supabase, containing no hardcoded placeholder values.
4. IF an NGO admin submits the registration form with any required field empty, THEN THE System SHALL display a field-level validation error and prevent form submission.
5. WHEN an NGO admin updates the organization profile, THE System SHALL persist the changes to Supabase and reflect them immediately in the dashboard without a full page reload.

---

### Requirement 2 — Document Upload & Storage

**User Story:** As an NGO administrator, I want to upload PDF and CSV survey documents, so that community needs data is captured and accessible for need card creation.

#### Acceptance Criteria

1. WHEN an NGO admin uploads a PDF or CSV file, THE System SHALL store the file in Supabase Storage under the bucket path `documents/{ngo_id}/{filename}` and insert a metadata row into the `ngo_documents` table containing filename, ngo_id, upload_date, file_size, and public URL.
2. WHEN a file upload completes, THE System SHALL display the uploaded document in the NGO's document list with filename, upload date, file size, and a download link, all sourced from Supabase.
3. IF an NGO admin attempts to upload a file that is not PDF or CSV format, THEN THE System SHALL reject the upload and display an error message specifying the accepted formats.
4. IF an NGO admin attempts to upload a file exceeding 10 MB, THEN THE System SHALL reject the upload and display a file size error before the upload begins.
5. WHEN an NGO admin views the document list, THE System SHALL display all documents fetched live from Supabase with no hardcoded entries.

---

### Requirement 3 — Priority Engine & Need Cards

**User Story:** As an NGO administrator, I want to create prioritized need cards from uploaded documents, so that volunteers can see the most urgent community needs.

#### Acceptance Criteria

1. WHEN an NGO admin creates a need card with title, description, required skills, deadline, urgency (1–5), category, and location coordinates, THE System SHALL insert a row into the `needs` Supabase table with status `open` and the NGO's id.
2. WHEN an NGO admin requests AI-assisted need extraction from an uploaded document's text, THE System SHALL call the Gemini API via a Next.js API route and return extracted title, description, skills, urgency, and location fields to pre-populate the need creation form.
3. WHEN needs are displayed on any listing screen, THE System SHALL sort them by urgency score descending and then by deadline ascending, with all data sourced from Supabase.
4. WHEN an NGO admin publishes a need card, THE System SHALL immediately call the `/api/matching/run` API route to compute and store ranked volunteer matches for that need in the `matches` table.
5. IF an NGO admin submits a need card with title or description empty, THEN THE System SHALL display a validation error and prevent submission.
6. WHEN a need card is displayed, THE System SHALL show the NGO's coordinator point address so volunteers know where to report.

---

### Requirement 4 — Volunteer Profile Builder

**User Story:** As a volunteer, I want to build a structured profile with skills, availability, and location, so that the matching engine can connect me to the most relevant needs.

#### Acceptance Criteria

1. WHEN a volunteer completes profile setup with skills (multi-select from the Skill Taxonomy), languages, availability (days/hours), location, and preferred causes, THE System SHALL upsert the full profile into the `volunteers` Supabase table for that volunteer's auth uid.
2. WHEN a volunteer selects a location, THE System SHALL call the Nominatim geocoding API to resolve the location to latitude/longitude coordinates and store them in the `volunteers` table.
3. WHEN a volunteer saves the profile, THE System SHALL display a success confirmation and immediately reflect the updated profile data without requiring re-login.
4. IF a volunteer attempts to save a profile with no skills selected, THEN THE System SHALL display a validation warning prompting skill selection before saving.
5. WHEN a volunteer's profile is updated, THE System SHALL call the `/api/matching/run` API route to re-score that volunteer against all open needs and update the `matches` table.

---

### Requirement 5 — Matching Engine

**User Story:** As the system, I want to automatically score and rank volunteers against open needs, so that the best-fit volunteers receive invitations.

#### Acceptance Criteria

1. WHEN the matching engine runs for a need, THE System SHALL compute a composite score for each available volunteer using skill overlap percentage (weight 50%), location proximity in kilometers via the Haversine formula (weight 30%), and availability fit (weight 20%), and upsert the ranked results into the `matches` Supabase table.
2. WHEN a new need is published, THE System SHALL trigger the matching engine immediately for that need and insert notification rows into the `notifications` table for the top 5 ranked volunteers.
3. WHEN a volunteer's profile is updated, THE System SHALL re-run matching for all open needs and update the `matches` table entries for that volunteer.
4. WHEN the matching engine computes location proximity, THE System SHALL apply the Haversine formula to the stored latitude/longitude coordinates of both the need and the volunteer.
5. WHERE the Gemini AI integration is enabled, THE System SHALL use the Gemini API to re-rank the top 10 skill-matched volunteers and return a final ranked list with a reasoning string per match stored in the `matches` table.

---

### Requirement 6 — Accept / Reject Flow

**User Story:** As a volunteer, I want to accept or decline task invitations, so that I can commit to needs that fit my schedule and skills.

#### Acceptance Criteria

1. WHEN a volunteer receives a task invitation, THE System SHALL display a task detail page showing need title, description, required skills, deadline, coordinator point address, and the NGO's location on a Leaflet map.
2. WHEN a volunteer clicks Accept on a task invitation, THE System SHALL update the `task_assignments` row status to `accepted`, insert a notification row for the NGO admin, and remove the invitation from the volunteer's pending list.
3. WHEN a volunteer clicks Decline on a task invitation, THE System SHALL update the `task_assignments` row status to `declined` in Supabase and insert a notification row offering the invitation to the next ranked volunteer.
4. WHEN an NGO views their dashboard, THE System SHALL display all accepted assignments for each need, sourced live from Supabase with no hardcoded data.
5. IF a volunteer attempts to accept a task for which the deadline has passed, THEN THE System SHALL prevent acceptance and display a deadline-expired message.

---

### Requirement 7 — Task Tracking (Kanban)

**User Story:** As a volunteer and NGO admin, I want to track task progress through a Kanban board, so that both parties have real-time visibility into task status.

#### Acceptance Criteria

1. WHEN a task assignment is created, THE System SHALL initialize the `task_assignments` row status to `invited` and display it in the Kanban board under the invited column.
2. WHEN a volunteer updates a task's status, THE System SHALL write the new status to the `task_assignments` Supabase row and update the Kanban board in real time using Supabase Realtime subscriptions.
3. THE System SHALL enforce the status transition order: `invited` → `accepted` → `in-progress` → `reported` → `verified` → `closed`, and return a 400 error with a descriptive message for any out-of-order transition.
4. WHEN a volunteer marks a task as `reported`, THE System SHALL insert a notification row for the NGO admin to verify the completion.
5. WHEN an NGO admin marks a task as `verified`, THE System SHALL prompt the NGO to submit a rating for the volunteer.

---

### Requirement 8 — Group Chat

**User Story:** As a volunteer assigned to a task, I want to chat with other volunteers on the same task, so that we can coordinate effectively.

#### Acceptance Criteria

1. WHEN 2 or more volunteers are assigned to the same need, THE System SHALL insert a row into the `chat_rooms` Supabase table keyed by `task_id` if one does not already exist.
2. WHEN a volunteer sends a message in a chat room, THE System SHALL insert a row into the `chat_messages` Supabase table with sender_id, display_name, message_text, room_id, and created_at timestamp.
3. WHEN a volunteer views a chat room, THE System SHALL display messages in chronological order sourced from a live Supabase Realtime subscription so new messages appear without manual refresh.
4. WHEN a new message arrives in a chat room the volunteer is viewing, THE System SHALL scroll the message list to the latest message automatically.
5. IF a volunteer who is not assigned to a task attempts to access that task's chat room, THEN THE System SHALL return a 403 response and display an unauthorized message.

---

### Requirement 9 — Rating & Reporting

**User Story:** As an NGO administrator, I want to rate volunteers after task completion, so that the matching engine can improve future recommendations.

#### Acceptance Criteria

1. WHEN an NGO admin submits a rating for a volunteer, THE System SHALL insert a row into the `ratings` Supabase table containing volunteer_id, ngo_id, task_id, star_score (1–5), and optional note text.
2. WHEN a rating is inserted, THE System SHALL recompute the volunteer's average rating from all their `ratings` rows and update the `average_rating` column on the `volunteers` Supabase table.
3. WHEN the matching engine scores a volunteer, THE System SHALL incorporate the volunteer's `average_rating` as a bonus multiplier of up to 10% on the composite match score.
4. WHEN a volunteer views their profile, THE System SHALL display their average rating and total completed task count, both sourced from Supabase queries.
5. IF an NGO admin attempts to submit a rating for a task that has not reached `reported` status, THEN THE System SHALL return a 400 error and display a status requirement message.

---

### Requirement 10 — Maps Integration

**User Story:** As a volunteer, I want to see needs and NGO locations on a map, so that I can make location-aware decisions about which tasks to accept.

#### Acceptance Criteria

1. WHEN a volunteer views the Explore Needs screen, THE System SHALL render an interactive Leaflet map displaying markers for all open needs, with marker color indicating urgency level (green=1–2, yellow=3, red=4–5).
2. WHEN a volunteer clicks a map marker, THE System SHALL display a popup card with need title, NGO name, urgency, required skills, and a link to the task detail page.
3. WHEN a volunteer views a task detail page, THE System SHALL display the NGO's coordinator point location on an embedded Leaflet map.
4. WHEN an NGO admin creates a need card, THE System SHALL provide a Leaflet-based location picker that resolves the selected point to an address via reverse geocoding and stores the coordinates in the `needs` table.
5. WHEN the map is rendered, THE System SHALL source all marker data from Supabase in real time with no hardcoded coordinates or location strings.

---

### Requirement 11 — Notifications

**User Story:** As a user, I want to receive in-app notifications for key events, so that I stay informed without manually checking the dashboard.

#### Acceptance Criteria

1. WHEN the matching engine identifies top volunteer matches for a need, THE System SHALL insert notification rows into the `notifications` Supabase table for each matched volunteer with type `match_invite`.
2. WHEN a volunteer accepts or declines a task, THE System SHALL insert a notification row for the NGO admin with the relevant status update.
3. WHEN a task status changes, THE System SHALL insert notification rows for all parties involved in that task assignment.
4. WHEN a user views the notifications panel, THE System SHALL display all unread notifications sourced from a live Supabase Realtime subscription, ordered by created_at descending.
5. WHEN a user marks a notification as read, THE System SHALL update the `read` column on the `notifications` Supabase row immediately via a PATCH API call.

---

### Requirement 12 — Analytics Dashboard

**User Story:** As an NGO administrator, I want to view real-time analytics about needs, volunteers, and task outcomes, so that I can measure social impact.

#### Acceptance Criteria

1. WHEN an NGO admin views the analytics dashboard, THE System SHALL display total needs posted, open needs count, fulfilled needs count, active volunteer count, and total volunteer hours, all computed from live Supabase queries with no hardcoded values.
2. WHEN the analytics dashboard renders charts, THE System SHALL source all chart data from Supabase aggregation queries with no hardcoded values.
3. WHEN an NGO admin filters analytics by date range, THE System SHALL re-query Supabase with the selected date bounds and update all metrics and charts accordingly.
4. WHEN an NGO admin exports a report, THE System SHALL generate a CSV file from the current Supabase query results and trigger a browser download.
5. WHEN the volunteer dashboard renders the open needs count badge, THE System SHALL display the live count of open needs from Supabase, not a hardcoded number.
