# Organization Management Platform — Frontend

A Flutter-based mobile application designed to provide a centralized platform for organization content, events, registrations, notifications, and user interaction.

The application provides different experiences based on the authenticated user's role and communicates with a FastAPI backend through REST APIs.

---

## Features

### 🔐 Authentication

* User registration and login
* Firebase Authentication integration
* Email verification
* Password recovery
* Secure authenticated API communication
* Role-based access to application functionality

### 🏠 Home

* Organization-focused home screen
* Image carousel
* Organization information
* Admin-managed home content

### 🎵 Lyrics

* Browse available songs
* Search songs by title
* Search normalization for improved matching
* View complete lyrics
* Filter/search based on lyricist where applicable

### 👤 Characters

* Browse organization-related characters/persons
* Search by name
* View character information
* Image and textual information

### 📅 Events

* Browse organization events
* View event details
* Register for events
* Capacity-based registration
* Waitlist support
* Automatic waitlist promotion when a slot becomes available
* Registration status handling

### 🔔 Notifications

* In-app notification history
* Event-related notifications
* Registration-related notifications
* Waitlist promotion notifications
* Other system notifications

> The current version uses in-app notifications. Native push notifications are outside the current V1 scope.

### 👨‍💼 Administration

The application includes administrative functionality for authorized users.

Depending on the user's role, administrators can:

* Manage application content
* Manage lyrics
* Manage characters
* Manage events
* View and manage users
* Promote users to admin where authorized
* Manage other administrative functionality

### 🌐 Social Media

Provides access to the organization's external social media platforms.

---

## User Roles

The frontend supports role-based application access.

| Role         | Access                                              |
| ------------ | --------------------------------------------------- |
| Normal User  | Basic user functionality                            |
| Premium User | Basic functionality + premium content where enabled |
| Admin        | Administrative content and event management         |
| Super Admin  | Full administrative control                         |

The exact permissions are enforced by the backend; the frontend only provides the appropriate user interface for the authenticated role.

---

## Technology Stack

| Technology              | Purpose                                  |
| ----------------------- | ---------------------------------------- |
| Flutter                 | Mobile application                       |
| Dart                    | Application programming language         |
| Firebase Authentication | Email verification and password recovery |
| REST API                | Backend communication                    |
| FastAPI                 | Backend service                          |
| PostgreSQL / Neon       | Persistent application data              |
| HTTP                    | API communication                        |
| Cloudinary              | Media storage                            |

---

## Application Architecture

The frontend communicates with the backend through REST APIs.

```text
┌──────────────────────────┐
│      Flutter App         │
│                          │
│  Screens / Widgets       │
│  Services                │
│  Models                  │
│  Authentication          │
└────────────┬─────────────┘
             │
             │ REST API
             ▼
┌──────────────────────────┐
│      FastAPI Backend     │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│      PostgreSQL          │
│        (Neon)            │
└──────────────────────────┘

Firebase Authentication
        │
        └── User authentication
```

---

## Project Structure

```text
lib/
├── core
│   ├── app_theme.dart
│   └── constants.dart
├── global/
│   └── global.dart
├── helper/
│   ├── date_utils.dart
│   └── session.dart
├── models/
│   └── content_model.dart
├── screens/
│   ├── admins/
│   │   ├── admin_panel_screen.dart
│   │   ├── create_character_screen.dart
│   │   ├── create_events_screen.dart
│   │   ├── create_lyrics_screen.dart
│   │   ├── dashboard_content.dart
│   │   ├── edit_character_screen.dart
│   │   ├── edit_pad_screen.dart
│   │   ├── manage_users_screen.dart
│   │   └── view_participants_screen.dart
│   ├── common/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── splash_screen.dart
│   ├── details/
│   │   ├── bhakt_detail_screen.dart
│   │   └── pad_screen.dart
│   ├── options/
│   │   ├── bhakt_charitra_screen.dart
│   │   ├── events_screen.dart
│   │   ├── notification_screen.dart
│   │   ├── padavali_screen.dart
│   │   ├── quote_screen.dart
│   │   ├── profile_screen.dart
│   │   └── social_media_screen.dart
│   └── users/
│       └── main_screen.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── character_service.dart
│   ├── content_service.dart
│   ├── dashboard_service.dart
│   ├── participant_service.dart
│   ├── profile_service.dart
│   └── lyrics_service.dart
├── widgets/
│   ├── state_widgets/
│   ├── admin_card.dart
│   ├── app_drawer.dart
│   ├── participant_model.dart
│   ├── section_title.dart
│   ├── social_item.dart
│   └── user_model.dart
├── firebase_options.dart
└── main.dart
```

---

## API Communication

The application communicates with the backend through authenticated HTTP requests.

Authenticated requests include the required authentication credentials and are authorized according to the user's backend role.

The frontend also handles common API states such as:

* Loading
* Successful response
* Empty data
* Authentication failure
* Network failure
* Server errors
* Retry scenarios

---

## Authentication Flow

```text
User
 │
 ▼
Flutter Authentication UI
 │
 ▼
Firebase Authentication
 │
 ├── Email verification
 └── Password recovery
 │
 ▼
Authenticated user
 │
 ▼
Backend API
 │
 ▼
Role-based authorization
```

---

## Event Registration Flow

```text
User
 │
 ▼
Select Event
 │
 ▼
View Event Details
 │
 ▼
Register
 │
 ├── Capacity available
 │       ↓
 │   Registration confirmed
 │
 └── Capacity full
         ↓
      Waitlist
         ↓
 Slot becomes available
         ↓
     User promoted
```

---

## Content Management

Application content is designed to be managed independently of the application build.

Administrative content can include:

* Lyrics
* Characters
* Events
* Home content
* Carousel images
* Current quote

This allows content to be updated without requiring a new mobile application release.

---

## Error Handling

The application provides user-facing handling for common failure states.

Examples include:

* Loading indicators
* Empty-state messages
* Retry options
* Authentication errors
* Network/server errors
* Failed registrations
* Invalid user actions

The goal is to avoid leaving users with unexplained blank screens or failed operations.

---

## Running the Project

### Prerequisites

Install:

* Flutter SDK
* Dart SDK
* Android Studio / Android SDK
* A connected Android device or emulator

Verify the Flutter installation:

```bash
flutter doctor
```

### Install dependencies

```bash
flutter pub get
```

### Configure backend URL

Configure the API base URL according to the environment in which the backend is running.

Do not commit private credentials or secrets to the repository.

### Run

```bash
flutter run
```

---

## Environment Configuration

Environment-specific values should not be hardcoded into the application.

Configure the required API endpoints and other environment-specific values according to the project's configuration approach.

Never commit:

* API secrets
* private keys
* Firebase service-account credentials
* production credentials

---

## Current Scope

The current version focuses on the core organization-management experience:

* Authentication
* Content browsing
* Lyrics
* Characters
* Home content
* Quotes
* Events
* Event registration
* Waitlists
* In-app notifications
* Administrative functionality
* User management
* Social media integration

Additional features may be considered in future versions based on organizational requirements.

---

## Future Possibilities

Potential future extensions include:

* Daily quiz
* Native push notifications
* Advanced analytics
* Support/query system
* Premium-content workflows
* Live classes / video conferencing
* Additional organization-specific modules

These are intentionally outside the core V1 scope.

---

## Status

**V1 — Working MVP**

The application is a functional full-stack product built to demonstrate the complete user and administrative workflows and to serve as a foundation for further organization-specific development.
