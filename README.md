# School Manager

A clean, offline-first Flutter app for managing students, teachers and daily attendance. Everything is stored on the device, so it works without internet, accounts or a backend.

## Features

### Dashboard
- Total students and total teachers
- Today's attendance summary (present, absent, not marked, percentage)
- Quick navigation cards to every module
- Recent activity feed (adds, edits, deletes, attendance saved)

### Student Management
- Add, edit and delete students with a confirmation dialog
- Fields: name, roll number, class, age, gender, contact information
- Unique roll numbers
- Clean list view with search and class filter

### Teacher Management
- Add, edit and delete teachers with a confirmation dialog
- Fields: name, employee ID, subject, contact number, email address
- Unique employee IDs
- Clean list view with search

### Attendance
- Pick a date, select a class, mark each student Present or Absent
- Save records and edit them later by reopening the same date and class
- Mark all present / absent shortcuts
- Unsaved-changes protection when leaving the screen
- Attendance records screen with search and filters

### Attendance Summary
- Total present and total absent students
- Daily summary
- Monthly summary with per-day breakdown
- Attendance percentage, overall and per student

### Search & Filters
- Search students, teachers and attendance records
- Filter by class, date and attendance status
- Active filters shown as chips and easy to clear

### Data Persistence
- Local SQLite database (`sqflite`)
- All data is available after restarting the app
- Deleting a student also removes their attendance records
- Theme preference is saved

### Form Validation
- Required field validation
- Email format validation
- Numeric validation (age, contact number)
- Clear inline error messages, including duplicate roll number / employee ID

### UI / UX
- Material 3 design with a consistent light and dark theme
- Follows the device theme automatically, with a manual System / Light / Dark option
- Skeleton loaders, empty states, error states with retry, and success feedback
- Responsive layout for phones and tablets
- Subtle animations only where they help

## Tech Stack

| Area | Choice |
|---|---|
| Framework | Flutter, Dart 3, Material 3 |
| State management | Riverpod |
| Local database | SQLite via `sqflite` |
| Preferences | `shared_preferences` |
| Date formatting | `intl` |
| Testing | `flutter_test`, `sqflite_common_ffi` |

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/      # app and database constants
│   ├── database/       # SQLite setup and provider
│   ├── theme/          # colors, typography, light/dark themes
│   ├── utils/          # validators, date utils, debouncer, responsive helper
│   ├── error/          # app exceptions
│   └── widgets/        # shared UI (cards, fields, skeletons, states)
└── features/
    ├── shell/          # bottom navigation / rail
    ├── dashboard/
    ├── students/
    ├── teachers/
    ├── attendance/
    ├── reports/
    ├── activity/
    └── settings/
        # each feature: data/ (repository), domain/ (models),
        #               providers/ (state), presentation/ (screens, widgets)
```

The app follows a simple layered architecture: **UI → Riverpod providers → repositories → SQLite**. Widgets contain no database or business logic.

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android Studio or VS Code with the Flutter extension
- An Android device/emulator or an iOS simulator (macOS with Xcode)

### Run the app

```bash
git clone <repository-url>
cd schoolmanager
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

### Build the APK

```bash
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Usage Guide

1. **Add students and teachers** from their tabs using the add button.
2. **Mark attendance** in the Attendance tab: choose a date and class, set Present or Absent for each student, then save.
3. **Edit attendance** by opening the same date and class again, or by tapping a record in the Attendance Records screen.
4. **View summaries** in the Reports tab, switching between Daily and Monthly.
5. **Change the theme** from Settings (System, Light or Dark).

## Validation Rules

| Field | Rule |
|---|---|
| Name | Required, 2–60 characters, letters and basic punctuation |
| Roll number | Required, alphanumeric, unique |
| Employee ID | Required, alphanumeric, unique |
| Class | Required |
| Age | Required, numeric, between 3 and 25 |
| Contact | Required, digits only, 10–15 digits |
| Email | Required, valid email format |
| Subject | Required |

Email validation checks the address format only. No backend or verification service is used.

## App Details

| | |
|---|---|
| App name | School Manager |
| Package / bundle ID | `com.mudasir.schoolmanager` |
| Platforms | Android, iOS |
| Data storage | On-device SQLite, no internet required |

## Future Improvements

- Cloud backup and sync
- User login and roles
- Export attendance reports to CSV or PDF
- Class timetables and notifications

## Author

**Mudasir Ali**