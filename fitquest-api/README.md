# 🧠 FitQuest API – Node.js & MongoDB Backend

The FitQuest API is a **RESTful backend service** built with **Node.js and Express**, designed to support the FitQuest mobile application.  
It handles **user authentication**, **secure password hashing**, and **workout and routine data persistence** using a **MongoDB NoSQL database**.

This API serves as the central data layer for the FitQuest Flutter application.

---

## 🧱 API Type & Architecture

- RESTful API
- JSON-based request and response format
- Stateless authentication
- Secure password handling with **bcrypt**
- NoSQL data persistence using **MongoDB**

---

## 🚀 Core Responsibilities

- User registration and login
- Secure password hashing using bcrypt
- Authentication and authorization logic
- Create, read, update, and store workouts and routines
- Serve data to the FitQuest mobile application

---

## 🛠 Technology Stack

| Technology | Purpose |
|----------|--------|
| Node.js | JavaScript runtime |
| Express.js | API framework |
| MongoDB | NoSQL database |
| Mongoose | MongoDB ODM |
| bcrypt | Password hashing |
| dotenv | Environment configuration |

---

## 📋 Prerequisites

Ensure the following are installed:

- Node.js (v18 or later recommended)
- npm
- MongoDB (local or cloud e.g. MongoDB Atlas)
- Git

---

## 🔧 Installation & Setup

### 1️⃣ Navigate to the API Directory

```bash
cd fitquest-api
```

### 2️⃣ Install Dependencies
```bash
npm install
```

```bash
cd fitquest-api
```

### 3️⃣ Environment Configuration
```env
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
```
⚠️ Do not commit the .env file to version control.

### 4️⃣ Start the API Server
```bash
npm start
```

### 🌐 API Access

Once running, the API will be accessible at:

```arduino
http://localhost:5000
```

### 🧪 Testing the API

You can test API endpoints using:

Postman

Thunder Client

Any REST client

Ensure MongoDB is connected before testing endpoints.

### ❗ Troubleshooting

Verify MongoDB connection string is valid

Ensure Node.js version is compatible

Confirm .env values are correctly set

Restart the server after environment changes
