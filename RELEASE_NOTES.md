# Release Notes

## FitQuest v1.0.0 (Final POE)

### Overview
This release finalizes FitQuest for POE submission with production-focused features across authentication, localization, offline sync, and CI automation.

### Added
- Secure email/password authentication flow with hashed passwords via `bcrypt`.
- Social authentication endpoint support for Google and Apple token login.
- Multi-language localization support including South African languages: isiZulu and Afrikaans.
- Real-time push notifications using Firebase Cloud Messaging (FCM).
- Per-user notification targeting by storing authenticated device tokens in user profiles.
- Added blob storage for profile images with Cloudinary-backed upload and persisted profile image URLs.
- Offline-first exercise experience with local storage and synchronization behavior.
- Settings improvements for theme, language, and notifications toggles.
- Routines and workout management integrated through REST API endpoints.
- GitHub Actions CI workflow for Flutter app checks and API smoke tests.

### Improved
- Submission documentation with requirement mapping and evidence checklist.
- API project automation scripts (`start`, `dev`, `seed`, `test`).

### Fixed
- CI build workflow step that previously attempted a non-CI-friendly run command.
- API `package.json` duplicate `scripts` block issue.

### Innovative Features Included in Final Version
- Offline mode with synchronization when connectivity returns.
- Multi-language support with localizations targeted to local context.
- Combined cloud + local data architecture (Flutter + Node/Express + MongoDB + SQLite).
