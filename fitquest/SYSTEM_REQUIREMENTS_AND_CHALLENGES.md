# 🖥️ System Requirements & Development Challenges – FitQuest

This document outlines the **system requirements** for running the FitQuest application and reflects on the **technical challenges** encountered during development.

---

## 🖥️ System Requirements

### Development Environment
- Operating System: Windows / macOS / Linux
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio or VS Code
- Android SDK
- Physical Android device (required for final testing)
- Internet connection (for API and database interaction)

---

### Runtime Requirements
- Android device running Android 8.0 (API level 26) or higher
- Minimum 2GB RAM
- Internet connection for cloud features
- Local storage access for SQLite offline mode

---

## ⚙️ Backend & Services Requirements
- REST API service running
- MongoDB database (local or cloud-hosted)
- Authentication service supporting bcrypt hashing
- Optional notification service (partially implemented)

---

## 🚧 Development Challenges Faced

### 1. Flutter State Management
Managing widget state across multiple views (authentication, workouts, routines) required careful planning to avoid unnecessary rebuilds and inconsistent UI behavior.

**Solution:**  
A structured separation between UI, services, and models was implemented.

---

### 2. Offline Mode with SQLite
Ensuring data consistency between **local SQLite storage** and **MongoDB** when transitioning between offline and online modes was challenging.

**Solution:**  
Local data caching and controlled synchronization logic were introduced to ensure data integrity.

---

### 3. Multi-Language Support
Implementing dynamic language switching (English, Afrikaans, isiZulu) required careful handling of localization files and UI updates.

**Solution:**  
Flutter localization utilities were used to manage translations cleanly and efficiently.

---

### 4. Authentication & Security
Implementing secure authentication, password hashing with **bcrypt**, and managing session state required careful attention to security best practices.

**Solution:**  
Passwords were hashed server-side, and input validation was enforced throughout the app.

---

### 5. Single Sign-On (SSO)
SSO integration was one of the most technically challenging aspects of the project.

**Solution:**  
GitHub Copilot was used as a **support tool** to assist with authentication flow configuration. All code was reviewed, tested, and understood before integration.

---

### 6. Push Notifications (Partial Implementation)
Push notifications were explored but not fully completed due to time constraints and configuration complexity.

**Outcome:**  
Foundational work was completed, and the feature is planned for future development.

---

### 7. Cross-Platform Testing
Ensuring consistent behavior across different devices and screen sizes required additional testing and UI refinement.

---

## 📈 Lessons Learned

- Planning data flow early reduces complexity later
- Offline-first design requires careful synchronization logic
- Clear separation of concerns improves maintainability
- Responsible use of AI tools can improve productivity without compromising learning

---

## ✅ Conclusion

Despite the challenges faced, FitQuest was successfully developed as a **fully functional Flutter application** that meets the assessment requirements. The challenges encountered contributed significantly to the developer’s understanding of mobile application development, system design, and deployment readiness.

---
