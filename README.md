# Online Outdoor Pass

A cross-platform **Flutter mobile application** designed to digitise the university outdoor-pass approval process across students, faculty members and wardens.

The application replaces a multi-step manual workflow with a Firebase-backed mobile experience where students can create requests, faculty members can review them, wardens can complete the approval process, and users can follow the current status of their requests.

Built during my undergraduate studies, this was one of my larger early mobile projects and gave me hands-on experience developing user-facing applications for both **Android and iOS**.

## Project Overview

A traditional university outdoor-pass process can involve multiple participants and approval stages.

Online Outdoor Pass models that process digitally using three primary user roles:

```text
Student
   |
   | Submit request
   v
Faculty / HOD
   |
   | Approve / Reject
   v
Chief Warden
   |
   | Final decision
   v
Updated pass status
```

Each role receives a different application experience while sharing data through Firebase.

## Key Features

### Student experience

Students can:

* register and authenticate
* create and update their profile
* upload profile images
* create outdoor-pass requests
* select destination information
* specify travel dates and transport details
* select the appropriate faculty/HOD
* view previously submitted requests
* follow approval status changes

### Faculty / HOD experience

Faculty members can:

* authenticate through a dedicated workflow
* view student pass requests
* inspect student and request information
* approve or reject requests
* propagate status changes through Firestore

### Chief Warden experience

The warden workflow provides:

* a separate authenticated portal
* access to forwarded requests
* request inspection
* final approval/rejection actions
* synchronized status updates

## Tech Stack

| Area               | Technology                           |
| ------------------ | ------------------------------------ |
| Mobile framework   | Flutter                              |
| Language           | Dart                                 |
| Platforms          | Android, iOS                         |
| Authentication     | Firebase Authentication              |
| Database           | Cloud Firestore                      |
| Media              | Firebase Storage                     |
| Backend automation | Firebase Cloud Functions / Node.js   |
| UI                 | Flutter Material widgets             |
| Image handling     | Image Picker, Flutter Image Compress |
| Remote images      | Cached Network Image                 |
| Android build      | Gradle                               |

The Android target was configured using the native Flutter/Gradle project structure with Android SDK support, while the repository also contains the corresponding iOS project.

## Architecture

The application uses Firebase as its shared backend and organizes the Flutter code around the major product workflows.

```text
                     +----------------------+
                     | Firebase Auth        |
                     +----------+-----------+
                                |
                                v
+------------+        +----------------------+        +---------------+
| Student UI |------->| Cloud Firestore      |<-------| Faculty UI    |
+------------+        +----------+-----------+        +---------------+
                                ^
                                |
                        +-------+--------+
                        | Warden UI      |
                        +----------------+

                                |
                                v
                     +----------------------+
                     | Firebase Storage     |
                     +----------------------+

                                |
                                v
                     +----------------------+
                     | Cloud Functions      |
                     +----------------------+
```

The authenticated user's role determines which experience is presented after launch.

## Role-Based Navigation

At startup, the app retrieves the currently authenticated Firebase user and routes the user to the appropriate interface.

The project contains dedicated flows for:

* students
* teachers/faculty
* chief wardens

This allowed one mobile application to support multiple participants in the same real-world workflow while presenting role-specific actions and information.

## Real-Time Request Workflow

Student outdoor-pass requests are stored in Firestore and represented through a series of states.

The application coordinates state updates across the collections used by students, teachers and wardens so each participant can see the appropriate version of the request.

Approval actions update values such as:

```text
approved
transaction
stage
```

This supports states such as pending, approved and cancelled while allowing the UI to communicate progress to the user.

## Form & User Experience

The request workflow includes user-facing functionality for:

* selecting dates
* selecting states and cities
* choosing a Head of Department
* entering the reason for travel
* choosing the mode of transportation
* viewing request details
* confirming approval/rejection actions

Local JSON datasets are included for structured information such as:

```text
states.json
cities.json
courses.json
```

## Image Handling

Users can select or capture images through the mobile device.

The application uses:

* `image_picker`
* `flutter_image_compress`
* Firebase Storage

Images are compressed before upload, helping reduce unnecessary transfer and storage overhead while maintaining the profile-image workflow.

## Real-Time UI

Several parts of the application use Firestore streams and Flutter's asynchronous widgets to keep data-driven views synchronized with backend state.

The application makes use of concepts including:

* `StreamBuilder`
* `FutureBuilder`
* Firestore snapshots
* asynchronous Firebase operations
* stateful Flutter widgets

This enabled interfaces such as activity/request lists to respond as cloud data changed.

## Backend Automation

The repository also contains a Firebase Cloud Functions project.

The included function reacts to new student out-pass documents under teacher workflows and contains notification logic using Firebase Admin messaging.

```text
Firestore event
      |
      v
Firebase Cloud Function
      |
      v
Notification workflow
```

This was an early exploration of event-driven backend behavior alongside the mobile client.

## Project Structure

```text
.
├── android/
├── ios/
├── functions/
├── images/
├── jsonFile/
│   ├── cities.json
│   ├── courses.json
│   └── states.json
│
└── lib/
    ├── ChiefWardenMainPage/
    ├── Outpass/
    ├── TeacherMainPage/
    ├── TeachersPortal/
    ├── chiefwardenPortal/
    ├── mainPage/
    ├── outpass_display/
    ├── sign_up/
    ├── userProfile/
    └── main.dart
```

The feature-oriented folders separate major user workflows such as authentication, profiles, pass creation, activity history and approval interfaces.

## Running the Project

> **Note:** This is a historical Flutter project built against older Flutter/Firebase package versions. A modern Flutter SDK may require dependency and Android build updates before the application runs unchanged.

### Requirements

The original project uses:

* Dart SDK `>=2.1.0 <3.0.0`
* Flutter
* Android SDK
* Firebase Authentication
* Cloud Firestore
* Firebase Storage

### Install dependencies

```bash
flutter pub get
```

### Firebase

The application requires a Firebase project configured for the mobile targets.

For your own deployment, configure:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Android Firebase configuration
* iOS Firebase configuration

Use your own Firebase project configuration rather than relying on the historical project environment.

### Run

```bash
flutter run
```

Depending on your installed Flutter/Gradle versions, the legacy dependencies in `pubspec.yaml` may need to be upgraded first.

## Engineering Challenges

### 1. Modelling a multi-stage real-world workflow

The application needed to represent a request moving between multiple participants instead of simply storing a single form submission.

The solution used explicit status fields and role-specific Firestore collections to represent the progression of a request.

### 2. Building one product for multiple user types

Students, faculty and wardens require substantially different actions.

Role-aware navigation and separate feature flows allowed the application to expose the appropriate interface after authentication.

### 3. Keeping cloud-backed UI synchronized

Firestore streams and asynchronous Flutter components were used to keep request lists and statuses synchronized with cloud data without requiring manual refreshes.

### 4. Handling user-generated media

Profile images needed to move from a mobile device to cloud storage efficiently.

The application combined image selection, compression and Firebase Storage uploads as part of the account workflow.

## What I Learned

This project gave me practical experience with:

* Android/iOS application development through Flutter
* Dart and asynchronous programming
* designing user-facing mobile workflows
* Firebase Authentication
* NoSQL data modelling with Firestore
* cloud-backed application state
* media upload and storage
* multi-role authorization flows
* event-driven backend concepts
* translating a real-world process into product behavior

It also taught me that mobile engineering is as much about **workflow clarity and state management** as it is about rendering individual screens.

## How I Would Modernize It Today

This repository reflects the Flutter/Firebase ecosystem available when I originally built it.

If rebuilding it today, I would:

* migrate to the current stable Flutter/Dart toolchain
* enable modern null safety
* introduce structured state management such as Riverpod
* separate presentation, domain and data layers
* centralize Firebase access behind repositories/services
* introduce explicit domain models for pass states
* strengthen role-based authorization through Firebase Security Rules
* add automated unit and widget tests
* add end-to-end/integration tests for approval journeys
* introduce dependency injection
* improve accessibility and responsive layouts
* move notification logic into a more robust event-driven backend flow

These changes would improve testability, maintainability and separation of concerns while retaining the original product workflow.

## Why I Keep This Project Public

This is an undergraduate project, and the code reflects the engineering experience I had at that stage.

I keep it public because it represents an important part of my progression as a software engineer: moving from individual mobile screens toward a complete user-facing application involving authentication, cloud data, multi-stage workflows and multiple user roles.

My later work has built on many of those same fundamentals across production frontend, backend and distributed systems.

## Author

**Sabih Ayaz Khan**

* GitHub: [khansabih](https://github.com/khansabih)
* LinkedIn: [Sabih Khan](https://linkedin.com/in/sabih-khan-1824021a3)

> Historical undergraduate mobile project demonstrating hands-on Flutter, Android/iOS and Firebase application development.
