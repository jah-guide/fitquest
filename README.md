# FitQuest

FitQuest is a Flutter fitness app with a Node.js + MongoDB REST API. The project includes authentication, workout/routine management, offline-first exercise tracking, and synchronization support.

## Repository Structure

- `fitquest/` — Flutter mobile app
- `fitquest-api/` — Node.js REST API
- `.github/workflows/build.yml` — automated CI for app + API

## Features Implemented

- User registration and login (password hashing with `bcrypt`)
- Social sign-in endpoint support (Google/Apple token handling)
- Profile and settings management
- Theme switching (light/dark/system)
- Multi-language support: English, isiZulu, Afrikaans
- Real-time push notification integration with Firebase Cloud Messaging (FCM)
- Blob storage integration for profile images (Cloudinary)
- Exercise browsing and routine management
- Offline-capable local exercise storage (`sqflite`)
- Sync flow to reconcile offline and online data
- REST API backed by MongoDB

## Requirement Mapping (POE)

- Registration + login: implemented in app screens and API auth routes.
- Password encryption: implemented using `bcrypt` in API auth route.
- SSO: social auth endpoint implemented in API; app contains Google/Apple dependencies.
- Settings change: implemented via profile/settings screens.
- REST API + database: Node/Express API with Mongoose/MongoDB.
- Offline mode + sync: local storage + sync service present in Flutter app.
- Multi-language (South African languages): isiZulu (`zu`) and Afrikaans (`af`) included.
- Real-time notifications: Firebase Messaging service integrated with runtime permission flow and topic subscription.
- Per-user push targeting: FCM device token is synced to the authenticated user record through secure API endpoints.
- Blob storage: user profile image upload endpoint stores images in Cloudinary and persists URL in MongoDB.
- Automated testing/CI: GitHub Actions pipeline runs Flutter checks/tests/build and API tests.

## Push Notification Setup (FCM)

To run real push notifications on Android device:

1. Create a Firebase project and add the Android app package (`com.example.fitquest` or your final package ID).
2. Download `google-services.json` and place it in `fitquest/android/app/`.
3. In Firebase Console, enable Cloud Messaging.
4. Run app on a physical Android phone and allow notifications when prompted.
5. Use Firebase Console to send a test message to topic: `fitquest_all`.

### Targeted User Push via API

You can now send a push to a specific user (using saved `pushTokens`) via:

- `POST /api/notifications/send-user`
- Auth: Bearer token required
- Body: `{ "userId": "<target-user-id>", "title": "Hi", "body": "Message", "data": { "screen": "profile" } }`

Security behavior:

- If `userId` is omitted, it sends to the currently authenticated user.
- If `userId` is different from current user, include header `x-notify-key: <NOTIFY_API_KEY>`.

Required API environment variables for targeted push:

- `FIREBASE_SERVICE_ACCOUNT_PATH` (path to service account JSON), or
- `FIREBASE_SERVICE_ACCOUNT_JSON` (stringified JSON contents)
- `NOTIFY_API_KEY` (recommended, required for cross-user targeting)

## Blob Storage Setup (Cloudinary)

Add these API environment variables:

- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

Implemented endpoints and app integration:

- `POST /api/user/me/avatar` uploads base64 image to Cloudinary and stores `profileImageUrl`
- Profile screen allows selecting a gallery image and uploading it to blob storage

Implemented files:

- `fitquest/lib/services/notification_service.dart`
- `fitquest/lib/main.dart`
- `fitquest/lib/screens/settings/settings_screen.dart`
- `fitquest/android/app/src/main/AndroidManifest.xml`

## Demonstration Video

Add your final unlisted YouTube link here before submission:

- Demo video link: `PASTE_YOUR_VIDEO_LINK_HERE`

Video checklist:

- Show full feature walkthrough with voice-over.
- Show registration/login flow.
- Show settings changes.
- Show offline usage and sync behavior.
- Show API/database-stored data.

## Release Notes (Prototype ➜ Final)

### v1.0.0 Final POE

- Added full authentication workflow with secure password hashing.
- Added social sign-in API route and conflict handling logic.
- Implemented routines and workout endpoints with persistent storage.
- Implemented offline exercise storage and synchronization flow.
- Added multilingual localization including isiZulu and Afrikaans.
- Improved settings with language, theme, and notifications toggles.
- Added CI workflow for automated Flutter and API validation.

### Notable Innovative Features

- Offline-first exercise management with later synchronization.
- Localized UX with South African language support.
- Combined local + cloud architecture (Flutter + Express + MongoDB).

## AI Tools Usage Write-Up (<= 500 words)

AI tools were used to support development, debugging, and documentation quality during this assessment. The primary use cases were:

1. **Code assistance and refactoring** — AI suggestions were used to speed up repetitive tasks such as creating route scaffolding, provider wiring, and localization key consistency. Suggestions were reviewed and adapted to match project requirements.
2. **Debugging support** — AI was used to diagnose common issues (API route errors, async handling mistakes, CI workflow misconfiguration, and invalid package script definitions). Each suggested fix was tested in the local project before acceptance.
3. **Documentation drafting** — AI support was used to structure README content, requirement mapping, and release notes in a clear format aligned to submission criteria.
4. **Validation workflow setup** — AI was used to help configure and verify GitHub Actions steps for Flutter analysis/testing/build and API smoke testing.

All AI-generated output was manually validated, edited, and integrated by the developer. AI was treated as an assistant for productivity and quality improvement, not as a replacement for understanding or independent verification. Final implementation decisions, testing, and submission checks were completed by the developer.

## Automated Testing & CI

GitHub Actions workflow: `.github/workflows/build.yml`

Pipeline jobs:

- Flutter: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`
- API: `npm ci`, `npm test`

## Publication Preparation Evidence Checklist

Add these files/screenshots to the repo before final submission:

- Signed APK screenshot/export evidence
- App screenshots (main features)
- Google Play Console upload/publish screenshot (if applicable)
- Demonstration video link in this README

Suggested evidence folder:

- `submission-evidence/screenshots/`
- `submission-evidence/video/`
- `submission-evidence/release/`

## Local Run Instructions

### Flutter app

1. `cd fitquest`
2. `flutter pub get`
3. `flutter run`

### API

1. `cd fitquest-api`
2. Create `.env` with:
	- `MONGO_URI=...`
	- `JWT_SECRET=...`
	- `PORT=5000` (optional)
3. `npm install`
4. `npm run dev`

## Quick Test Commands

- Flutter: `cd fitquest && flutter test`
- API: `cd fitquest-api && npm test`
