# My Meds!

A simple, private medication list app. Your data stays on your device.

---

<p align="center">
  <img src="https://github.com/user-attachments/assets/fc699ae1-50c4-4903-a2a6-20ccbc0f5959" width="18%" />
  <img src="https://github.com/user-attachments/assets/fe35acba-78f0-4589-b103-f6087ccb34d2" width="18%" />
  <img src="https://github.com/user-attachments/assets/70a094aa-bb49-43d8-89dc-ec892ebc3162" width="18%" />
  <img src="https://github.com/user-attachments/assets/f3c5d2c8-1254-4925-96d0-5d4edd84aef2" width="18%" />
  <img src="https://github.com/user-attachments/assets/008b4fb9-f56d-456a-9222-a782dbc56cc7" width="18%" />
</p>

---

## Why My Meds?

Most medication apps are either too complex or send your data to external services.  
**My Meds** was created for people who just want a simple, secure way to track their meds.  
The app has over 5,000 downloads on the iOS App Store!

## Tech Stack
Built with Flutter (cross-platform mobile application framework)

## Features

- Search for meds using FDA NDC API
- Add, edit, and delete meds (SQLite with `flutter_sqflite`)
- Personal notes and profile info
- Add images with `image_picker`
- Export your list to PDF (`flutter_pdf`)

## Download

- **iOS:** [My Meds on the App Store](https://apps.apple.com/us/app/my-meds-personal-meds-list/id6475703887)
- **Android:** [Get APKs from GitHub Releases](https://github.com/subbuguru/medication_tracker/releases)

## Architecture Overview

- **Provider**: App-wide state management (`provider` package).
- **Models**: Data structures (e.g. [Medication model](lib/data/model/medication_model.dart)).
- **Services**: Database and native features (e.g. [DatabaseService](lib/data/database/database.dart)).
- **UI**: Screens and widgets (e.g. [CreateMedicationView](lib/ui/create_medication/create_medication_view.dart)).

## Development Setup

1. **Clone the repo**
    ```sh
    git clone https://github.com/yourusername/medication_tracker.git
    cd medication_tracker
    ```
2. **Install Flutter**  
   [Flutter install guide](https://flutter.dev/docs/get-started/install)

3. **Install dependencies**
    ```sh
    flutter pub get
    ```

4. **Run the app**
    ```sh
    flutter run
    ```


