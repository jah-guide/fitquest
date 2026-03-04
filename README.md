# 🏋️‍♂️ FitQuest – Gamified Fitness Mobile Application

FitQuest is a **cross-platform mobile fitness application built with Flutter** that applies **gamification principles** to encourage consistent physical activity. The app allows users to register, log in securely, create workout routines, save exercises, and track fitness-related data both online and offline.

This repository contains the **complete Flutter source code** for the FitQuest application and is submitted as part of the **Final Portfolio of Evidence (POE)**.

---

## 📽️ Video Demonstration

🎥 **Feature Demonstration Video (Unlisted YouTube Link)**  
👉 https://www.youtube.com/watch?v=R9quQulg0o

The demonstration video includes:
- A full walkthrough of the application features
- User registration and login flow
- User registration, **Single Sign-On (SSO)**, and traditional login flow
- Workout and routine creation
- Data stored in MongoDB via the REST API
- Offline mode using SQLite and data synchronization
- Theme switching (Dark / Light mode)
- Multi-language support
- Voice-over explanation of implementation decisions and architecture

---

## 📱 Application Overview

FitQuest is designed to make fitness **engaging, accessible, and sustainable** by allowing users to build structured workout routines and manage them efficiently across devices.

### Core Features
- Secure user authentication
- Workout and exercise management
- Routine creation and cloud storage
- Offline functionality with local persistence
- Multi-language support
- Dark and Light theme toggle
- REST API and NoSQL database integration

---

## 🧱 Technology Stack

| Layer | Technology |
|-----|-----------|
| Framework | Flutter |
| Language | Dart |
| Backend | REST API |
| Database | MongoDB (NoSQL) |
| Authentication | bcrypt (password hashing) |
| Offline Storage | SQLite |
| State & UI | Flutter Widgets |
| Version Control | Git & GitHub |

---

## 📂 Project Structure
```
fitquest/
│
├── lib/
│ ├── views/ # UI screens (auth, workouts, routines)
│ ├── models/ # Data models
│ ├── services/ # API and database services
│ ├── utils/ # Helpers and constants
│ └── main.dart
│
├── assets/
│ └── images/
│
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 🔐 Authentication & Security

- Users can **register and log in**
- **Single Sign-On (SSO)** allows authentication through a trusted third-party provider
- Passwords are **securely hashed using bcrypt**
- Authentication data is stored securely in the backend database
- Input validation prevents invalid or malformed data from crashing the app

---

## 🌐 REST API & Database Integration

- FitQuest connects to a **REST API** backed by **MongoDB**
- Users can:
  - Save workouts and exercises
  - Group workouts into routines
  - Retrieve routines from the database
- All persistent workout data is stored in MongoDB and demonstrated in the video

---

## 🗄️ Offline Mode with SQLite

FitQuest supports **offline usage** through local storage:

- Workout and routine data can be accessed without internet connectivity
- Data is stored locally using **SQLite**
- Synchronization occurs when the device reconnects to the internet

This ensures usability even in low-connectivity environments.

---

## 🌍 Multi-Language Support

The application supports multiple languages, including:

- English (EN)
- Afrikaans (AFR)
- isiZulu (ZU)

Language switching is handled dynamically and updates UI text accordingly.

---

## 🎨 Theme Support (Dark / Light Mode)

- Users can toggle between **Dark Mode** and **Light Mode**
- Theme preference is persisted across app sessions
- Improves accessibility and user experience

---

## 🔔 Push Notifications (Partial Implementation)

Push notifications were explored during development.  
While the **full notification system is not yet complete**, foundational work was done toward supporting real-time user alerts.

This feature is planned for future expansion.

---

## 🔑 Single Sign-On (SSO) Integration

The application includes **Single Sign-On (SSO)** functionality to streamline user authentication:
- Users can authenticate using an external identity provider
- Eliminates the need to manually create and remember credentials
- On first SSO login, a user profile is automatically created in the backend
- Returning users are authenticated seamlessly
- SSO accounts are linked to workouts and routines stored in MongoDB

This feature improves usability, accessibility, and user retention.

---

## 🧪 Automated Testing & Version Control

- The project uses **GitHub for version control**
- Regular commits were made throughout development
- The repository includes a README and well-structured codebase
- Logging is used throughout the application to demonstrate understanding of execution flow

---

## 📝 Release Notes

### Version 1.0.0 – Final POE Release

**Enhancements Since Prototype:**
- Offline mode implemented using SQLite
- Multi-language support (EN, AFR, ZU)
- Workout and routine management
- MongoDB integration for persistent storage
- Dark / Light theme toggle
- Improved UI and validation handling

These updates represent the **innovative and functional improvements** introduced in the final version.

---

## 🤖 AI Tools Usage (≤ 500 Words)

AI tools were used responsibly to assist during development. Their use included:
- Debugging Dart and Flutter errors
- Improving widget structure and state handling
- Assisting with database query logic
- Drafting documentation content

All AI-generated suggestions were **reviewed, modified, and implemented manually**.  
The developer maintains full understanding and ownership of the final implementation. AI tools were used strictly as **supporting tools**, not as replacements for learning or development.

---

## 📦 Preparation for Publication

The application is prepared for publication and includes:
- Final app icon and assets
- Screenshots of the app running on a physical mobile device
- Signed build configuration (where applicable)
- Clean, production-ready UI and navigation

The app runs on a **real mobile device**, not an emulator.

---

## 📤 Submission Requirements Checklist

✔ Complete Flutter source code on GitHub  
✔ README.md included  
✔ No ZIP files submitted  
✔ Code commented and logged  
✔ GitHub version control used consistently  
✔ Final commit pushed as **Final POE**

---

## 📄 License

This project is submitted for academic assessment purposes only.  
All rights reserved by the author.

---

## 👨‍💻 Author

**FitQuest**  
Final Portfolio of Evidence – Mobile Application Development
