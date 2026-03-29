# My Meds!

A simple, private medication list app. Your data stays on your device.

---

<p align="center">
<img width="18%" alt="5" src="https://github.com/user-attachments/assets/c3b535c5-4600-4d9b-8258-369b4911ee5a" />
<img width="18%" alt="4" src="https://github.com/user-attachments/assets/05d6c687-8ebf-4bb0-b331-d3f4d66b1086" />
<img width="18%" alt="3" src="https://github.com/user-attachments/assets/cfe1ef0b-41db-485c-a26a-3d3875240722" />
<img width="18%" alt="2" src="https://github.com/user-attachments/assets/65f17bcb-c83b-497c-8894-1d70dfd3319f" />
<img width="18%" alt="1" src="https://github.com/user-attachments/assets/87c1150d-c22b-4533-bc7a-e6ca8be35a9c" />
</p>


---

## Why My Meds?

Most medication apps are either too complex or send your data to external services.  
**My Meds** was created for people who just want a simple, secure way to track their meds.  
The app has over **7,000 downloads** on the iOS App Store!

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
- **Android:** [Get APKs from GitHub Releases](https://github.com/dhruva-dk/my-meds/releases)

## Architecture Overview

- **Provider**: App-wide state management (`provider` package).
- **Models**: Data structures (e.g. [Medication model](lib/data/model/medication_model.dart)).
- **Services**: Database and native features (e.g. [DatabaseService](lib/data/database/database.dart)).
- **UI**: Screens and widgets (e.g. [CreateMedicationView](lib/ui/create_medication/create_medication_view.dart)).

## Development Setup

1. **Clone the repo**
   ```sh
   git clone https://github.com/yourusername/my-meds.git
   cd my-meds
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
