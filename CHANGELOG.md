# 📋 Changelog – FitQuest

All notable changes to this project are documented in this file.

---

## [Unreleased] – 2026-03-09

### Added
- Compared and reviewed PR #6 ("Merge pull request #3 from jah-guide/frontend"), confirming all its changes are already present on `main`.

---

## [1.0.0] – 2026-02-01 — Final POE Release

### Documentation
- Updated `README.md` with comprehensive project overview, technology stack, architecture, feature descriptions, AI tools usage, and submission checklist.
- Formatted project structure section in `README.md` using a code block for improved readability (2026-03-04).
- Added `fitquest/AI_Usage.md` — Academic declaration of how AI tools (GitHub Copilot) were used during development.
- Added `fitquest/SYSTEM_REQUIREMENTS_AND_CHALLENGES.md` — Documents development environment requirements, runtime requirements, and technical challenges overcome.
- Added `fitquest-api/README.md` — API setup guide, prerequisites, environment configuration, and troubleshooting.
- Removed the generic Flutter starter `fitquest/README.md`.

### CI/CD
- Added `.github/workflows/dart.yml` — Dart CI workflow that runs `dart pub get`, `dart analyze`, and `dart test` on every push and pull request to `main`.

---

## [0.9.0] – 2026-01-31 — Frontend Polish & Services

### Flutter – Screens
- **Auth:** Updated `login_screen.dart` and `register_screen.dart` with improved input validation and UI.
- **Main:** Updated `home_screen.dart`, `exercises_screen.dart`, `profile_screen.dart`, `progress_screen.dart`, and `main_app.dart`.
- **Exercises:** Added `exercise_detail_screen.dart` and `offline_exercises_screen.dart` for browsing exercises online and offline.
- **Routines:** Added `create_routine_screen.dart`, `routine_detail_screen.dart`, and `routines_screen.dart` for full routine CRUD.
- **Settings:** Added `settings_screen.dart` and `language_screen.dart` for theme toggling and language selection.

### Flutter – Services
- Added `api_service.dart` — HTTP client for communicating with the FitQuest REST API.
- Added `exercise_api_service.dart` — Dedicated service for fetching exercise data from the API.
- Added `database_helper.dart` — SQLite local database helper for offline data persistence.
- Added `sync_service.dart` — Synchronises local SQLite data with MongoDB when the device comes back online.
- Added `sample_data.dart` — Seed data used for offline exercise browsing.

### Flutter – Providers (State Management)
- Added `exercise_provider.dart` — Manages exercise list state across the app.
- Added `language_provider.dart` — Manages the active locale for multi-language support.
- Added `theme_provider.dart` — Manages Dark / Light mode preference with session persistence.
- Updated `auth_provider.dart` — Enhanced authentication state including SSO support.

### Flutter – Widgets
- Added `exercise_card.dart` — Reusable card widget for displaying exercise summaries.
- Added `placeholder_image.dart` — Fallback widget for missing exercise images.

### Flutter – Models
- Added `exercise.dart` — Dart data model representing an exercise entity.

### Flutter – Locale
- Updated `main.dart` to wire up providers, theme, and localisation.
- Updated `widget_test.dart` to reflect the updated app entry point.

---

## [0.8.0] – 2026-01-31 — Multi-Language Support

### Flutter
- Added `app_localizations.dart` — Dynamic localisation support for English (EN), Afrikaans (AFR), and isiZulu (ZU).
- Added `exercise.dart` model (initial version, later refined).

---

## [0.7.0] – 2026-01-30 — API v2.0

### Backend (fitquest-api – Node.js / Express / MongoDB)
- Updated `User.js` model — Added fields for SSO and profile data.
- Added `Workout.js` model — Mongoose schema for individual workouts.
- Added `Routine.js` model — Mongoose schema for grouping workouts into routines.
- Updated `auth.js` route — Registration, login, and SSO authentication with bcrypt password hashing.
- Added `workouts.js` route — CRUD endpoints for workout management.
- Added `routines.js` route — CRUD endpoints for routine management.
- Updated `server.js` — Registered new routes and configured middleware.
- Updated `package.json` / `package-lock.json` — Added Mongoose, bcrypt, dotenv, and JWT dependencies.
- Added `seed/seedWorkout.js` — Script to seed the database with sample workout data.
- Added `generate-test-token.js` — Utility script for generating JWT tokens during API testing.

---

## [0.5.0] – 2025-10-14 — Initial MVP

### Flutter (fitquest)
- Initial commit with complete authentication system (login / register screens).
- Workout tracking foundation with gamification-ready architecture.
- Base project structure: `lib/`, `models/`, `providers/`, `screens/`, `services/`, `widgets/`.

### CI/CD
- Added `.github/workflows/build.yml` — GitHub Actions workflow for Flutter build and testing on push/PR to `main`.

---

## Legend

| Symbol | Meaning |
|--------|---------|
| Added  | New file or feature introduced |
| Updated | Existing file or feature modified |
| Removed | File or feature deleted |
