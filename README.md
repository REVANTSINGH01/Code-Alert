# 🚀 CodeAlert
### Competitive Programming Tracker & Contest Reminder

CodeAlert is a full-stack mobile application built to centralize competitive programming activities across multiple coding platforms.

Track ratings, solved questions, upcoming contests, and reminders — all from one dashboard.

---

# 📌 Features

✅ User Authentication (Signup/Login)

✅ JWT Session Management

✅ Platform Handle Integration

✅ Contest Tracking

✅ Contest Countdown Timer

✅ Coding Profile Monitoring

✅ Theme Support (Dark / Light)


---

# 🏗️ High Level Design (HLD)

## System Overview

```text
                    ┌────────────────────┐
                    │    Flutter App     │
                    │--------------------│
                    │ Login / Signup     │
                    │ Dashboard          │
                    │ Profile            │
                    │ Contest Feed       │
                    │ Reminders          │
                    └─────────┬──────────┘
                              │
                         REST APIs
                              │
                              ▼

                  ┌────────────────────┐
                  │   FastAPI Backend   │
                  │---------------------│
                  │ Authentication      │
                  │ Dashboard Sync      │
                  │ Contest Aggregator  │
                  │ Reminder Service    │
                  └─────────┬───────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼

 ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
 │ MongoDB      │  │ LeetCode API │  │ Codeforces   │
 │ User Data    │  │ GraphQL      │  │ Public API   │
 │ Profiles     │  │              │  │              │
 │ Contests     │  └──────────────┘  └──────────────┘
 │ Reminders    │
 └──────────────┘
```

---

# ⚙️ Low Level Design (LLD)

## Frontend Structure

```text
lib/
│
├── pages/
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── home_page.dart
│   ├── profile_page.dart
│   ├── platform_detail.dart
│   ├── reminder_page.dart
│   └── settings.dart
│
├── services/
│   └── api_service.dart
│
├── provider/
│   └── theme_provider.dart
│
└── main.dart
```

---

## Backend Structure

```text
backend/
│
├── app/
│
├── routers/
│   ├── users.py
│   ├── dashboard.py
│   ├── contests.py
│   ├── leetcode.py
│   ├── codeforces.py
│   ├── reminders.py
│
├── auth/
│   └── auth_handler.py
│
├── database/
│   └── database.py
│
└── main.py
```

---

# 🧩 System Architecture

## User Authentication Flow

```text
User
↓

Flutter Login

↓

POST /login

↓

JWT Generated

↓

Store SharedPreferences

↓

Navigate Home
```

---

## Dashboard Sync Flow

```text
Profile Open

↓

syncDashboard()

↓

Verify Token

↓

Fetch Platform Data

↓

Update MongoDB

↓

Return Dashboard

↓

Refresh UI
```

---

## Contest Flow

```text
Open Home

↓

GET /contests

↓

Contest Service

↓

Contest Cards

↓

Live Countdown
```

---

# 🗄️ Database Schemas

## users

```json
{
 "_id":"ObjectId",
 "name":"Revant",
 "email":"user@gmail.com",
 "password":"****",
 "handles":{
   "cf_handle":"abc",
   "lc_handle":"xyz"
 }
}
```

---

## lc_profile

```json
{
"user_id":"123",
"rating":1824,
"global_ranking":40000,
"problems_solved":745
}
```

---

## cf_profile

```json
{
"user_id":"123",
"rating":1487
}
```

---

## contests

```json
{
"name":"Weekly Contest",
"platform":"LeetCode",
"start_time":"timestamp"
}
```

---

## reminders

```json
{
"user_id":"123",
"contest_name":"Codeforces Round",
"time":"timestamp"
}
```

---

# 🔌 API Endpoints

## Auth

```http
POST /signup
POST /login
```

## User

```http
PUT /users/handles
POST /dashboard/sync
```

## Contest

```http
GET /contests
```

## Reminder

```http
POST /reminder
GET /reminders/{id}
```

---

# 🛠️ Tech Stack

## Frontend

- Flutter
- Dart
- Provider
- SharedPreferences

---

## Backend

- FastAPI
- JWT Authentication
- Async Processing
- REST APIs

---

## Database

- MongoDB

---

## External APIs

- LeetCode GraphQL
- Codeforces API
- CodeChef Data Source

---

# 📈 Current Progress

## Completed

- [x] Authentication
- [x] JWT Login
- [x] Persistent Session
- [x] Contest Fetch
- [x] Contest Countdown
- [x] Profile Page
- [x] Platform Handle Setup
- [x] Dashboard Sync
- [x] Rating Tracking
- [x] Questions Solved Tracking
- [x] Theme Support
- [x] Auto Refresh
- [x] Reminder Backend

---

## In Progress

- [ ] Notification Integration
- [ ] Profile Analytics
- [ ] Contest Filtering
- [ ] Better Error Handling
- [ ] Background Sync

---

## Planned

- [ ] Push Notifications
- [ ] Leaderboards
- [ ] AI Contest Recommendation
- [ ] Statistics Dashboard
- [ ] Activity Graph
- [ ] Multi-device Sync

---

# 🚀 Installation

```bash
git clone <repo>

cd codealert

flutter pub get

flutter run
```

Backend:

```bash
cd backend

uvicorn app.main:app --host 0.0.0.0 --reload
```

---

# 👨‍💻 Contributors

Built with ❤️ using Flutter + FastAPI + MongoDB
