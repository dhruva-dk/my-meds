| ![Image 5](https://github.com/user-attachments/assets/fc699ae1-50c4-4903-a2a6-20ccbc0f5959) | ![Image 4](https://github.com/user-attachments/assets/fe35acba-78f0-4589-b103-f6087ccb34d2) | ![Image 3](https://github.com/user-attachments/assets/70a094aa-bb49-43d8-89dc-ec892ebc3162) | ![Image 2](https://github.com/user-attachments/assets/f3c5d2c8-1254-4925-96d0-5d4edd84aef2) | ![Image 1](https://github.com/user-attachments/assets/008b4fb9-f56d-456a-9222-a782dbc56cc7) |
|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|

# My Meds!

A simple medication list app made to be easy to use and not send your data off-device.

## Architecture

The app follows a provider-based architecture using the `provider` package for state management. The main components are:

- **Providers**: Manage the state of the app. For example, the [MedicationProvider](lib/data/providers/medication_provider.dart) handles medication-related operations and exposes the active medication.
- **Models**: Define the data structures used in the app. For example, the [Medication](lib/data/model/medication_model.dart) model represents a medication.
- **Services**: Handle data operations and native package operations such as Image picking. For example, the [DatabaseService](lib/data/database/database.dart) interacts with the SQLite database.
- **UI**: The user interface components, including screens and widgets. For example, the [CreateMedicationView](lib/ui/create_medication/create_medication_view.dart) allows users to add new medications.

## Environment Setup

To set up the development environment for this project, follow these steps:

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/medication_tracker.git
    cd medication_tracker
    ```

2. **Install Flutter**:
    Follow the instructions on the [official Flutter website](https://flutter.dev/docs/get-started/install) to install Flutter on your machine.

3. **Install dependencies**:
    ```bash
    flutter pub get
    ```

4. **Run the app**:
    ```bash
    flutter run
    ```

## Features

- Search functionality using FDA NDC REST APIs
- Full CRUD functionality using SQLite (`flutter_sqflite`) to add medications
- Profile input for personal notes
- Support for image upload using `image_picker`
- PDF export functionality using `flutter_pdf`

## Installation

Install on the iOS App Store: [My Meds on the App Store](https://apps.apple.com/us/app/my-meds-personal-meds-list/id6475703887)

Install on Android: [APKs available in GitHub Releases](https://github.com/subbuguru/medication_tracker/releases)

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Dhruva Kumar - [dkumardevelopment@gmail.com](mailto:dkumardevelopment@gmail.com)

Thank you!
