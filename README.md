# FitQuest 🏋️

FitQuest is a Flutter fitness app with a Node.js + MongoDB REST API.
It supports secure authentication, routine/workout management, offline-first usage, syncing, multilingual UX, notifications, and blob-based profile image storage.

## 🎬 Demo Video

- YouTube demo: https://youtu.be/a7T3cw1dqqA

## 📁 Repository Structure

- `fitquest/` - Flutter mobile app
- `fitquest-api/` - Node.js/Express REST API
- `.github/workflows/build.yml` - CI pipeline (Flutter + API)
- `submission-evidence/` - POE evidence checklist and artifacts

## ✅ Feature Summary

- Registration and login with encrypted passwords (`bcrypt`)
- Social sign-in endpoint support (Google/Apple token flow)
- Profile and settings management
- Theme switching: light, dark, system
- Multi-language support: English, isiZulu, Afrikaans
- Push notifications via Firebase Cloud Messaging (FCM)
- Blob storage for avatars via Cloudinary (with fallback behavior)
- Exercise browsing and routine management
- Offline local exercise storage (`sqflite`) and sync flow
- REST API backed by MongoDB
- Automated CI checks for app and API

## 📌 POE Requirement Mapping

- Auth flow (register/login): Implemented in Flutter auth screens + API auth routes
- Password encryption: Implemented with `bcrypt`
- SSO: API social auth endpoint and app dependencies integrated
- Settings changes: Theme/language/notification settings implemented
- REST API + DB: Express + Mongoose + MongoDB
- Offline + sync: Local storage and sync service implemented
- Multilingual support: Includes isiZulu (`zu`) and Afrikaans (`af`)
- Real-time notifications: FCM service and permission flow implemented
- User-targeted push: Device tokens linked to authenticated users via secure endpoints
- Blob storage: Avatar upload endpoint persists Cloudinary URL in MongoDB
- Testing + CI: GitHub Actions workflow validates app and API

## 🔔 Push Notifications Setup (FCM)

To test real push notifications on Android:

1. Create a Firebase project and register your Android package.
2. Add `google-services.json` to `fitquest/android/app/`.
3. Enable Cloud Messaging in Firebase Console.
4. Run on a physical device and allow notifications.
5. Send a test notification to topic `fitquest_all`.

### Targeted User Push API

- Endpoint: `POST /api/notifications/send-user`
- Auth: Bearer token required
- Body example:

```json
{
  "userId": "<target-user-id>",
  "title": "Hi",
  "body": "Message",
  "data": { "screen": "profile" }
}
```

Security behavior:

- If `userId` is omitted, notification is sent to the authenticated user.
- If `userId` is different from current user, include header `x-notify-key: <NOTIFY_API_KEY>`.

Required API environment variables:

- `FIREBASE_SERVICE_ACCOUNT_PATH` or `FIREBASE_SERVICE_ACCOUNT_JSON`
- `NOTIFY_API_KEY`

## ☁️ Blob Storage Setup (Cloudinary)

Required API environment variables:

- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

Implemented integration:

- `POST /api/user/me/avatar` accepts base64 and stores `profileImageUrl`
- Flutter profile screen supports gallery selection and upload

## 🧪 Testing and CI

Workflow file: `.github/workflows/build.yml`

Pipeline jobs:

- Flutter: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`
- API: `npm ci`, `npm test`

## 🚀 Local Run Instructions

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

## 📝 Release Notes

See `RELEASE_NOTES.md` for prototype-to-final evolution, bug fixes, and innovations.

## 📷 Submission Evidence Checklist

Before final hand-in, confirm:

- Demo recorded on physical phone with voice-over
- Demo link included in this `README.md`
- Auth + SSO shown in video
- Settings changes shown (theme/language/notifications)
- REST API + database-backed behavior shown
- Offline usage + sync shown
- APK export evidence captured
- Feature screenshots captured
- CI checks passing on latest commit
- Final POE tag present

Suggested evidence folders:

- `submission-evidence/screenshots/`
- `submission-evidence/video/`
- `submission-evidence/release/`

## 🤖 AI Tools Usage (<= 500 words)

AI assistance was used to improve development speed, debugging quality, and documentation clarity.

1. Code assistance and refactoring: AI suggestions helped accelerate repetitive scaffolding (routes, providers, localization consistency) and cleanup tasks.
2. Debugging support: AI helped diagnose API integration issues, async/UI test flakiness, and CI workflow misconfigurations.
3. Documentation support: AI was used to structure this README, requirement mapping, and release-note clarity.
4. Validation setup: AI contributed to refining CI checks for Flutter and API workflows.

All suggested output was manually reviewed, tested, and adapted before being accepted. Final implementation decisions and validation remained developer-driven.
