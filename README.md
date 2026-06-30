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

<img width="434" height="459" alt="image" src="https://github.com/user-attachments/assets/f68e70a7-aebf-42bf-a568-744cebfbd35d" />


---

---

# 📖 Use Case Diagram

<img width="2224" height="1146" alt="mermaid-diagram-2026-06-29-233949" src="https://github.com/user-attachments/assets/0a39eca0-b285-45fa-8d6a-80ad3b79fa95" />

---

# ⚙️ Low Level Design (LLD)

## Frontend Structure

<img width="371" height="359" alt="image" src="https://github.com/user-attachments/assets/bf0a0d3e-ccb8-4601-a46d-3e393fe97482" />

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
# 🗄️ Entity Relationship Diagram (ER Diagram)

The following diagram illustrates the logical relationships between the MongoDB collections used in CodeAlert.

<img width="2567" height="1260" alt="mermaid-diagram-2026-06-30-235804" src="https://github.com/user-attachments/assets/2b6e8df4-2085-4e9b-918c-69e9c6125654" />


---

# 🧩 System Architecture

<img width="915" height="271" alt="image" src="https://github.com/user-attachments/assets/5acbef2a-03b4-4055-a131-79b460483f20" />


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

### Frontend

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State_Management-blue?style=for-the-badge)
![SharedPreferences](https://img.shields.io/badge/SharedPreferences-Local_Storage-orange?style=for-the-badge)

### Backend

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-Authentication-black?style=for-the-badge&logo=jsonwebtokens&logoColor=white)
![Async](https://img.shields.io/badge/Async-Processing-green?style=for-the-badge)
![REST_API](https://img.shields.io/badge/REST-APIs-red?style=for-the-badge)

### Database

![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)

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
- [x] Contest Fetch
- [x] Contest Countdown
- [x] Profile Page
- [x] Platform Handle Setup
- [x] Dashboard Sync
- [x] Rating Tracking
- [x] Questions Solved Tracking
- [x] Theme Support
- [x] Auto Refresh
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
